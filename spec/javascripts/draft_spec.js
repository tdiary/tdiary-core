const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const jquerySource = fs.readFileSync(path.join(__dirname, '../../node_modules/jquery/dist/jquery.js'), 'utf8');
const defaultSource = fs.readFileSync(path.join(__dirname, '../../js/00default.js'), 'utf8');
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
        <input type="hidden" name="old" value="${options.old || '20261008'}">
        <input type="hidden" name="plugin_draft_id" value="">
        <input type="submit" name="${options.command || 'append'}" value="save">
      </form>
    </body></html>`, { url: 'http://localhost/update.rb', runScripts: 'outside-only', pretendToBeVisual: true });
    win = dom.window;
    win.eval(jquerySource);
    win.eval(defaultSource);
    win.$tDiary = { plugin: { draft: {
      server: Object.assign({ drafts: [], deleted: [], max: 10 }, options.server),
      interval: 300,
      label: {
        saved: 'saved: here %local, server %server', unsent: 'not yet',
        found: 'found %title', restore: 'restore', dismiss: 'dismiss'
      }
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

  function status() {
    return win.$('.draft-status').text();
  }

  function notice() {
    return win.$('.draft-notice');
  }

  function clock(time) {
    const date = new Date(time);
    return [date.getHours(), date.getMinutes()].map(n => String(n).padStart(2, '0')).join(':');
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
        local: [{ id: 'a1', date: 1, value: 'old', form: 'append:20261007' }],
        server: { drafts: [{ id: 'a1', date: 2, value: 'new', form: 'replace:20261008' }] }
      });
      expect(stored()).toEqual([{ id: 'a1', date: 2, value: 'new', form: 'replace:20261008' }]);
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

    it("remembers the form the draft was written in", async function() {
      await boot({ body: 'existing diary', command: 'replace', old: '20261007' });
      win.$('#body').val('changed').trigger('change');
      expect(stored()[0].form).toEqual('replace:20261007');
      await hide();
      expect(uploaded()[0].form).toEqual('replace:20261007');
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

  describe("the time of the last save", function() {
    it("is not shown while the diary is as it was opened", async function() {
      await boot({ body: 'existing diary' });
      expect(status()).toEqual('');
    });

    it("is put below the submit button so that the button does not move under the cursor", async function() {
      await boot({ body: 'existing diary' });
      expect(win.$('[name=append]').nextAll('.draft-status').length).toEqual(1);
    });

    it("tells the save in this browser from the one on the server", async function() {
      await boot({ body: 'existing diary' });
      win.$('#body').val('changed').trigger('change');
      const saved = clock(stored()[0].date);
      expect(status()).toEqual(`saved: here ${saved}, server not yet`);
      await hide();
      expect(status()).toEqual(`saved: here ${saved}, server ${saved}`);
    });

    it("shows the date of a save made on another day", async function() {
      const local = new Date(2026, 0, 2, 3, 4, 5).getTime();
      const server = new Date(2026, 0, 1, 23, 45, 0).getTime();
      await boot({
        body: 'same text',
        local: [{ id: 'a1', date: local, value: 'same text' }],
        server: { drafts: [{ id: 'a1', date: server, value: 'older text' }] }
      });
      expect(status()).toEqual('saved: here 2026-01-02 03:04, server 2026-01-01 23:45');
    });
  });

  describe("a draft written on the same form", function() {
    const form = 'append:20261008';

    it("is offered above the body and restored in one click", async function() {
      const date = new Date(2026, 0, 2, 3, 4, 5).getTime();
      await boot({ body: 'existing diary', local: [{ id: 'a1', date: 1, value: 'older', form }, { id: 'b2', date: date, value: 'newer', form }] });
      expect(notice().text()).toEqual('found newer (2026-01-02 03:04:05) restore dismiss');
      expect(win.$('#body').prev().is(notice())).toBe(true);
      notice().find('button:contains(restore)').trigger('click');
      expect(win.$('#body').val()).toEqual('newer');
      expect(submittedId()).toEqual('b2');
      expect(notice().length).toEqual(0);
    });

    it("is the only one offered, not one for another day or the other kind of form", async function() {
      await boot({
        body: 'diary of the day', command: 'replace',
        local: [
          { id: 'a1', date: 1, value: 'edit of this day', form: 'replace:20261008' },
          { id: 'b2', date: 2, value: 'edit of another day', form: 'replace:20261007' },
          { id: 'c3', date: 3, value: 'append to this day', form: 'append:20261008' },
          { id: 'd4', date: 4, value: 'saved by an older version' }
        ]
      });
      expect(notice().text()).toMatch(/^found edit of this day /);
    });

    it("is not offered when it holds the body", async function() {
      await boot({ body: 'same text\n', local: [{ id: 'a1', date: 1, value: 'other', form }, { id: 'b2', date: 2, value: 'same text', form }] });
      expect(notice().length).toEqual(0);
    });

    it("is not offered again once dismissed until it changes", async function() {
      await boot({ local: [{ id: 'a1', date: 1, value: 'draft', form }] });
      notice().find('button:contains(dismiss)').trigger('click');
      expect(notice().length).toEqual(0);
      const dismissed = stored();
      win.close();

      await boot({ local: dismissed });
      expect(notice().length).toEqual(0);
      win.close();

      await boot({ local: dismissed, server: { drafts: [{ id: 'a1', date: 2, value: 'changed elsewhere', form }] } });
      expect(notice().length).toEqual(1);
    });
  });
});
