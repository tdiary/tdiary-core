const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const jquerySource = fs.readFileSync(path.join(__dirname, '../../node_modules/jquery/dist/jquery.js'), 'utf8');
// in the order script_tag loads them
const sources = ['preview.js', 'update_preview.js'].map(name => fs.readFileSync(path.join(__dirname, '../../js', name), 'utf8'));

function page(day) {
  return `<!DOCTYPE html><html><body><div class="whole-content">
    <h1>diary</h1>
    ${day || ''}
    <div class="update day">
      <form class="update" method="post" action="update.rb">
        <textarea id="body" name="body">body</textarea>
        <input type="submit" name="replacepreview" value="Preview">
      </form>
    </div>
  </div></body></html>`;
}

describe("preview.js", function() {
  let win;

  async function boot(options = {}) {
    const dom = new JSDOM(page(options.day), { url: 'http://localhost/update.rb', runScripts: 'outside-only', pretendToBeVisual: true });
    win = dom.window;
    win.setTimeout = (fn, ms) => setTimeout(fn, ms);
    win.clearTimeout = id => clearTimeout(id);
    win.eval(jquerySource);
    win.$tDiary = { plugin: { preview: { minWidth: 896 } } };
    win.fetch = jasmine.createSpy('fetch').and.returnValue(Promise.resolve({
      text: () => Promise.resolve(page('<div class="day autopagerize_page_element"><h2>rendered</h2></div>'))
    }));
    win.Element.prototype.scrollIntoView = function() {};
    sources.forEach(source => win.eval(source));
    const ready = new Promise(resolve => win.$(resolve));
    await settle();
    // jQuery calls the ready handlers through setTimeout
    jasmine.clock().tick(0);
    await ready;
    await settle();
  }

  function settle() {
    return new Promise(resolve => setImmediate(resolve));
  }

  function type(text) {
    win.$('#body').val(text);
    win.document.getElementById('body').dispatchEvent(new win.Event('input', { bubbles: true }));
  }

  beforeEach(function() {
    jasmine.clock().install();
  });

  afterEach(function() {
    jasmine.clock().uninstall();
    win.close();
  });

  it("shows the preview beside the form when the form is opened", async function() {
    await boot();
    const container = win.$('div.preview-container');
    expect(container.css('display')).toEqual('flex');
    expect(container.children('div.day').length).toEqual(2);
    expect(container.children().first().find('h2').text()).toEqual('rendered');
    expect(container.children().last()).toHaveClass('update');
    expect(win.fetch).toHaveBeenCalledTimes(1);
  });

  it("keeps the preview the server has rendered", async function() {
    await boot({ day: '<div class="day autopagerize_page_element"><h2>server</h2></div>' });
    expect(win.$('div.preview-container > div.day:first h2').text()).toEqual('server');
    expect(win.fetch).not.toHaveBeenCalled();
  });

  it("sends nothing while nothing is typed", async function() {
    await boot();
    win.fetch.calls.reset();
    jasmine.clock().tick(60 * 1000);
    await settle();
    expect(win.fetch).not.toHaveBeenCalled();
  });

  it("refreshes the preview a second after the typing stops", async function() {
    await boot();
    win.fetch.calls.reset();
    type('a');
    jasmine.clock().tick(500);
    type('ab');
    jasmine.clock().tick(999);
    expect(win.fetch).not.toHaveBeenCalled();
    jasmine.clock().tick(1);
    expect(win.fetch).toHaveBeenCalledTimes(1);
    expect(win.fetch.calls.mostRecent().args[1].body.get('body')).toEqual('ab');
  });
});
