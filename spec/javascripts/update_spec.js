const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const jquerySource = fs.readFileSync(path.join(__dirname, '../../node_modules/jquery/dist/jquery.js'), 'utf8');
const updateSource = fs.readFileSync(path.join(__dirname, '../../js/update.js'), 'utf8');

describe("update.js", function() {
  let win, form, title, body;

  async function boot(unsaved) {
    const dom = new JSDOM(`<!DOCTYPE html><html><body>
      <form class="update" method="post" action="update.rb"${unsaved ? ' data-unsaved="true"' : ''}>
        <input name="year" value="2026">
        <input type="submit" name="edit" value="edit this day">
        <input id="title" name="title" value="title">
        <textarea id="body" name="body">saved text</textarea>
        <input type="submit" name="replacepreview" value="preview">
        <input type="submit" name="replace" value="save">
      </form>
    </body></html>`, { url: 'http://localhost/update.rb', runScripts: 'outside-only', pretendToBeVisual: true });
    win = dom.window;
    win.eval(jquerySource);
    win.eval(updateSource);
    await new Promise(resolve => win.$(resolve));
    form = win.document.querySelector('form');
    title = win.document.getElementById('title');
    body = win.document.getElementById('body');
  }

  function press(target, init) {
    const event = new win.KeyboardEvent('keydown', Object.assign({ key: 'Enter', bubbles: true, cancelable: true }, init));
    target.dispatchEvent(event);
    return event;
  }

  function leave() {
    const event = new win.Event('beforeunload', { cancelable: true });
    win.dispatchEvent(event);
    return event.defaultPrevented;
  }

  function submitWith(name) {
    const event = new win.SubmitEvent('submit', { bubbles: true, cancelable: true, submitter: form.elements[name] });
    form.dispatchEvent(event);
    return event.defaultPrevented;
  }

  afterEach(function() {
    win.close();
  });

  describe("Enter in the title", function() {
    it("moves to the body instead of loading the saved diary", async function() {
      await boot();
      title.focus();
      expect(press(title).defaultPrevented).toBe(true);
      expect(win.document.activeElement).toBe(body);
    });

    it("is left to the input method while composing", async function() {
      await boot();
      title.focus();
      expect(press(title, { isComposing: true }).defaultPrevented).toBe(false);
      expect(win.document.activeElement).toBe(title);
    });
  });

  describe("leaving the page", function() {
    it("goes on when nothing was changed", async function() {
      await boot();
      expect(leave()).toBe(false);
    });

    it("asks when the body was changed", async function() {
      await boot();
      body.value = 'saved text and more';
      expect(leave()).toBe(true);
    });

    it("asks when the title was changed", async function() {
      await boot();
      title.value = 'new title';
      expect(leave()).toBe(true);
    });

    it("asks on a page holding text that was never saved", async function() {
      await boot(true);
      expect(leave()).toBe(true);
    });

    it("goes on while the text is being saved", async function() {
      await boot();
      body.value = 'saved text and more';
      submitWith('replace');
      expect(leave()).toBe(false);
    });

    it("asks when another day is opened over changed text", async function() {
      await boot();
      body.value = 'saved text and more';
      submitWith('edit');
      expect(leave()).toBe(true);
    });
  });

  describe("sending the form", function() {
    it("sends a save only once", async function() {
      await boot();
      expect(submitWith('replace')).toBe(false);
      expect(submitWith('replace')).toBe(true);
      expect(submitWith('replacepreview')).toBe(true);
    });

    it("sends again after coming back to the page", async function() {
      await boot();
      submitWith('replace');
      win.dispatchEvent(new win.Event('pageshow'));
      expect(submitWith('replace')).toBe(false);
    });

    it("does not count opening another day as a save", async function() {
      await boot();
      submitWith('edit');
      expect(submitWith('replace')).toBe(false);
    });
  });
});
