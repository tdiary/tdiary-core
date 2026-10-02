const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const jquerySource = fs.readFileSync(path.join(__dirname, '../../node_modules/jquery/dist/jquery.js'), 'utf8');
const draftSource = fs.readFileSync(path.join(__dirname, '../../js/draft.js'), 'utf8');

describe("draft.js", function() {
  let win;

  async function boot(options) {
    const dom = new JSDOM(`<!DOCTYPE html><html><body>
      <form class="update" method="post" action="update.rb">
        <input type="hidden" name="csrf_protection_key" value="secret">
        <textarea id="body" name="body">${options.body || ''}</textarea>
        <select name="drafts"></select>
        <button type="button" id="draft_load">load</button>
        <input type="hidden" name="plugin_draft_id" value="">
      </form>
    </body></html>`, { url: 'http://localhost/update.rb', runScripts: 'outside-only', pretendToBeVisual: true });
    win = dom.window;
    win.eval(jquerySource);
    win.$tDiary = { plugin: { draft: {
      server: Object.assign({ drafts: [], deleted: [], max: 10 }, options.server),
      interval: 300
    } } };
    if (options.local) {
      win.localStorage.drafts = JSON.stringify(options.local);
    }
    win.fetch = jasmine.createSpy('fetch').and.returnValue(Promise.resolve({ ok: true }));
    win.eval(draftSource);
    await new Promise(resolve => win.$(resolve));
  }

  function stored() {
    return JSON.parse(win.localStorage.drafts);
  }

  async function hide() {
    Object.defineProperty(win.document, 'visibilityState', { configurable: true, get: () => 'hidden' });
    win.document.dispatchEvent(new win.Event('visibilitychange'));
    await new Promise(resolve => win.setTimeout(resolve, 0));
  }

  function uploaded() {
    return JSON.parse(win.fetch.calls.mostRecent().args[1].body.get('plugin_draft_sync'));
  }

  function submittedId() {
    win.$('form').triggerHandler('submit');
    return win.$('[name=plugin_draft_id]').val();
  }

  afterEach(function() {
    win.close();
  });

  describe("when the form is opened", function() {
    it("merges the drafts kept on the server", async function() {
      await boot({
        local: [{ id: 'a1', date: 1, value: 'local' }],
        server: { drafts: [{ id: 'b2', date: 2, value: 'remote' }] }
      });
      expect(stored().map(item => item.id)).toEqual(['a1', 'b2']);
      expect(win.$('[name=drafts] option').length).toEqual(2);
    });

    it("takes the newer version of the same draft", async function() {
      await boot({
        local: [{ id: 'a1', date: 1, value: 'old' }],
        server: { drafts: [{ id: 'a1', date: 2, value: 'new' }] }
      });
      expect(stored()).toEqual([{ id: 'a1', date: 2, value: 'new' }]);
    });

    it("drops a draft submitted as a diary", async function() {
      await boot({
        local: [{ id: 'a1', date: 1, value: 'submitted' }],
        server: { deleted: ['a1'] }
      });
      expect(stored()).toEqual([]);
    });

    it("gives an id to a draft saved by an older version", async function() {
      await boot({ local: [{ date: 1, value: 'legacy' }] });
      expect(stored()[0].id).toMatch(/^[0-9a-z]{1,32}$/);
    });

    it("keeps only the newest drafts", async function() {
      const drafts = [];
      for (let i = 1; i <= 12; i++) { drafts.push({ id: 'a' + i, date: i, value: 'draft ' + i }); }
      await boot({ server: { drafts: drafts } });
      expect(stored().length).toEqual(10);
      expect(stored()[0].id).toEqual('a3');
    });
  });

  describe("when the diary is edited", function() {
    it("does not save the diary as it was opened", async function() {
      await boot({ body: 'existing diary' });
      await hide();
      expect(stored()).toEqual([]);
      expect(win.fetch).not.toHaveBeenCalled();
      expect(submittedId()).toEqual('');
    });

    it("saves the changed text as one draft", async function() {
      await boot({ body: 'existing diary' });
      win.$('#body').val('first change').trigger('change');
      win.$('#body').val('second change').trigger('change');
      expect(stored().length).toEqual(1);
      expect(stored()[0].value).toEqual('second change');
      expect(submittedId()).toEqual(stored()[0].id);
    });

    it("keeps editing the draft holding the same text", async function() {
      await boot({ body: 'same text\n', local: [{ id: 'a1', date: 1, value: 'same text' }] });
      expect(submittedId()).toEqual('a1');
      win.$('#body').val('same text and more').trigger('change');
      expect(stored()).toEqual([jasmine.objectContaining({ id: 'a1', value: 'same text and more' })]);
    });

    it("keeps editing a loaded draft", async function() {
      await boot({ local: [{ id: 'a1', date: 1, value: 'first' }, { id: 'b2', date: 2, value: 'second' }] });
      win.$('[name=drafts]').val('a1');
      win.$('#draft_load').trigger('click');
      expect(win.$('#body').val()).toEqual('first');
      expect(submittedId()).toEqual('a1');
    });
  });

  describe("when the page is hidden", function() {
    it("uploads only the drafts the server does not have", async function() {
      await boot({
        local: [{ id: 'a1', date: 1, value: 'kept' }, { id: 'b2', date: 2, value: 'not yet' }],
        server: { drafts: [{ id: 'a1', date: 1, value: 'kept' }] }
      });
      await hide();
      expect(win.fetch).toHaveBeenCalledTimes(1);
      const [url, request] = win.fetch.calls.mostRecent().args;
      expect(url).toEqual('update.rb');
      expect(request.keepalive).toBe(true);
      expect(request.body.get('plugin')).toEqual('draft');
      expect(request.body.get('csrf_protection_key')).toEqual('secret');
      expect(uploaded()).toEqual([{ id: 'b2', date: 2, value: 'not yet' }]);
    });

    it("does not upload a draft twice", async function() {
      await boot({ local: [{ id: 'a1', date: 1, value: 'draft' }] });
      await hide();
      await hide();
      expect(win.fetch).toHaveBeenCalledTimes(1);
    });

    it("uploads the draft again after the server failed", async function() {
      await boot({ local: [{ id: 'a1', date: 1, value: 'draft' }] });
      win.fetch.and.returnValue(Promise.resolve({ ok: false }));
      await hide();
      await hide();
      expect(win.fetch).toHaveBeenCalledTimes(2);
    });
  });
});
