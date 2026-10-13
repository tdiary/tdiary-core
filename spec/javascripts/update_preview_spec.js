const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const jquerySource = fs.readFileSync(path.join(__dirname, '../../node_modules/jquery/dist/jquery.js'), 'utf8');
const previewSource = fs.readFileSync(path.join(__dirname, '../../js/update_preview.js'), 'utf8');

function page(day) {
  return `<!DOCTYPE html><html><body><div class="whole-content">
    <h1>diary</h1>
    ${day || ''}
    <div class="update day">
      <form class="update" method="post" action="update.rb">
        <input type="hidden" name="old" value="20261009">
        <input id="title" name="title" value="title">
        <textarea id="body" name="body">body</textarea>
        <input type="submit" name="appendpreview" value="Preview">
        <input type="submit" name="append" value="Append">
      </form>
      <form class="update" method="post" action="update.rb">
        <input type="hidden" name="plugin_image_addimage" value="true">
      </form>
    </div>
  </div></body></html>`;
}

function rendered(title) {
  return page(`<div class="day autopagerize_page_element"><h2>${title}</h2></div>`);
}

describe("update_preview.js", function() {
  let win, submitted;

  async function boot(options = {}) {
    const dom = new JSDOM(page(options.day), { url: 'http://localhost/update.rb', runScripts: 'outside-only', pretendToBeVisual: true });
    win = dom.window;
    win.eval(jquerySource);
    win.$tDiary = { plugin: {} };
    respond(rendered('rendered'));
    win.Element.prototype.scrollIntoView = jasmine.createSpy('scrollIntoView');
    win.eval(previewSource);
    await new Promise(resolve => win.$(resolve));
    submitted = false;
    win.$('form').on('submit', function(e) {
      submitted = true;
      e.preventDefault();
    });
  }

  function respond(html) {
    win.fetch = jasmine.createSpy('fetch').and.returnValue(Promise.resolve({ text: () => Promise.resolve(html) }));
  }

  function settle() {
    return new Promise(resolve => setImmediate(resolve));
  }

  function sent() {
    return win.fetch.calls.mostRecent().args[1].body;
  }

  function preview() {
    return win.$('div.update').prevAll('div.day');
  }

  function press(keys) {
    const event = new win.KeyboardEvent('keydown', Object.assign({ key: 'P', shiftKey: true, bubbles: true, cancelable: true }, keys));
    return win.document.getElementById('body').dispatchEvent(event);
  }

  afterEach(function() {
    win.close();
  });

  describe("when the preview button is pressed", function() {
    it("shows the preview above the form without leaving the page", async function() {
      await boot();
      win.$('[name=appendpreview]')[0].click();
      await settle();
      expect(submitted).toBe(false);
      expect(win.fetch.calls.mostRecent().args[0]).toEqual('http://localhost/update.rb');
      expect(win.fetch.calls.mostRecent().args[1].method).toEqual('POST');
      expect(sent().get('appendpreview')).toEqual('Preview');
      expect(preview().find('h2').text()).toEqual('rendered');
      expect(win.Element.prototype.scrollIntoView).toHaveBeenCalled();
    });

    it("sends only the diary form", async function() {
      await boot();
      win.$('#body').val('typed text');
      win.$('[name=appendpreview]')[0].click();
      await settle();
      expect(sent().get('body')).toEqual('typed text');
      expect(sent().has('plugin_image_addimage')).toBe(false);
    });

    it("replaces the preview already on the page", async function() {
      await boot({ day: '<div class="day autopagerize_page_element"><h2>old</h2></div>' });
      win.$('[name=appendpreview]')[0].click();
      await settle();
      expect(preview().length).toEqual(1);
      expect(preview().find('h2').text()).toEqual('rendered');
    });

    it("goes to the preview page when the server returns no preview", async function() {
      await boot();
      respond(page());
      const form = win.$('form')[0];
      spyOn(form, 'requestSubmit');
      win.$('[name=appendpreview]')[0].click();
      await settle();
      expect(form.requestSubmit).toHaveBeenCalledWith(win.$('[name=appendpreview]')[0]);
      expect(preview().length).toEqual(0);
    });

    it("goes to the preview page when the request fails", async function() {
      await boot();
      win.fetch.and.callFake(() => Promise.reject(new TypeError('Failed to fetch')));
      const form = win.$('form')[0];
      spyOn(form, 'requestSubmit');
      win.$('[name=appendpreview]')[0].click();
      await settle();
      expect(form.requestSubmit).toHaveBeenCalledWith(win.$('[name=appendpreview]')[0]);
    });
  });

  describe("when Cmd or Ctrl+Shift+P is pressed", function() {
    it("switches between writing and the preview", async function() {
      await boot();
      expect(press({ metaKey: true })).toBe(false);
      await settle();
      expect(preview().find('h2').text()).toEqual('rendered');

      press({ metaKey: true });
      await settle();
      expect(preview().css('display')).toEqual('none');
      expect(win.document.activeElement.id).toEqual('body');

      press({ ctrlKey: true });
      await settle();
      expect(preview().css('display')).not.toEqual('none');
      expect(win.fetch).toHaveBeenCalledTimes(2);
    });

    it("keeps the preview hidden when it is hidden while loading", async function() {
      await boot({ day: '<div class="day autopagerize_page_element"><h2>old</h2></div>' });
      win.$('[name=appendpreview]')[0].click();
      press({ ctrlKey: true });
      await settle();
      expect(preview().css('display')).toEqual('none');
      expect(preview().find('h2').text()).toEqual('old');
    });

    it("leaves Shift+P to the text", async function() {
      await boot();
      expect(press({})).toBe(true);
      expect(press({ metaKey: true, isComposing: true })).toBe(true);
      await settle();
      expect(win.fetch).not.toHaveBeenCalled();
    });
  });

  describe("$tDiary.preview.refresh", function() {
    it("updates the shown preview without scrolling to it", async function() {
      await boot({ day: '<div class="day autopagerize_page_element"><h2>old</h2></div>' });
      win.$tDiary.preview.refresh();
      await settle();
      expect(preview().find('h2').text()).toEqual('rendered');
      expect(win.Element.prototype.scrollIntoView).not.toHaveBeenCalled();
    });

    it("does nothing while no preview is shown", async function() {
      await boot();
      win.$tDiary.preview.refresh();
      await settle();
      expect(win.fetch).not.toHaveBeenCalled();
    });
  });
});
