const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const jquerySource = fs.readFileSync(path.join(__dirname, '../../node_modules/jquery/dist/jquery.js'), 'utf8');
const updateSource = fs.readFileSync(path.join(__dirname, '../../js/update.js'), 'utf8');

describe("update.js", function() {
  let win, title, body;

  async function boot() {
    const dom = new JSDOM(`<!DOCTYPE html><html><body>
      <form class="update" method="post" action="update.rb">
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
    title = win.document.getElementById('title');
    body = win.document.getElementById('body');
  }

  function press(target, init) {
    const event = new win.KeyboardEvent('keydown', Object.assign({ key: 'Enter', bubbles: true, cancelable: true }, init));
    target.dispatchEvent(event);
    return event;
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
});
