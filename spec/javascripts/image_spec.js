const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

const jquerySource = fs.readFileSync(path.join(__dirname, '../../node_modules/jquery/dist/jquery.js'), 'utf8');
const defaultSource = fs.readFileSync(path.join(__dirname, '../../js/00default.js'), 'utf8');
const imageSource = fs.readFileSync(path.join(__dirname, '../../js/image.js'), 'utf8');

describe("image.js", function() {
  let win, drawn, closed, requests;

  function imageList(sizes, added = []) {
    const cells = sizes.map((size, id) => `<td><img id="image-index-${id}" class="image-img form"${added.includes(id) ? ' data-added="true"' : ''} src="images/20261005_${id}.jpg"></td>`);
    const infos = sizes.map((size, id) => `<td id="image-info-${id}"><span class="image-width">${size[0]}</span> x <span class="image-height">${size[1]}</span></td>`);
    return `<div class="form"><form id="plugin-image-delimage"><table id="image-table"><tr>${cells.join('')}</tr><tr>${infos.join('')}</tr></table></form></div>`;
  }

  async function boot(sizes, preview) {
    const imageForm = `<div id="plugin-image-addimage" class="form">
        <form class="update" method="post" action="update.rb">
          <input type="hidden" name="csrf_protection_key" value="secret">
          <input type="hidden" name="date" value="20261005">
          <input type="file" name="plugin_image_file">
          <input type="submit" name="plugin" value="upload">
        </form>
      </div>`;
    const dom = new JSDOM(`<!DOCTYPE html><html><body>
      <form class="update" method="post" action="update.rb">
        <input type="hidden" name="csrf_protection_key" value="secret">
        <textarea id="body" name="body">text</textarea>
      </form>
      ${sizes.length ? imageList(sizes) : ''}
      ${preview ? '' : imageForm}
    </body></html>`, { url: 'http://localhost/update.rb', runScripts: 'outside-only', pretendToBeVisual: true });
    win = dom.window;
    win.eval(jquerySource);
    win.eval(defaultSource);
    win.$tDiary.style = 'gfm';
    win.$tDiary.plugin.image = { alt: 'image', drop_here: 'drop here', failed: 'upload failed', resize: 1600, date: '20261005' };
    win.alert = jasmine.createSpy('alert');
    win.console.error = function() {};

    drawn = jasmine.createSpy('drawImage');
    win.HTMLCanvasElement.prototype.getContext = () => ({ fillRect() {}, drawImage: drawn });
    win.HTMLCanvasElement.prototype.toBlob = function(callback, type) {
      callback(new win.Blob(['encoded'], { type: type }));
    };
    closed = jasmine.createSpy('close');
    win.createImageBitmap = jasmine.createSpy('createImageBitmap').and.returnValue(Promise.resolve({ width: 3200, height: 1800, close: closed }));

    requests = [];
    win.$.ajax = function(options) {
      const deferred = win.$.Deferred();
      requests.push({ options: options, deferred: deferred });
      return deferred;
    };

    win.eval(imageSource);
    await new Promise(resolve => win.$(resolve));
    win.$('#body')[0].setSelectionRange(4, 4);
  }

  async function settle() {
    for (let i = 0; i < 5; i++) {
      await new Promise(resolve => win.setTimeout(resolve, 0));
    }
  }

  function respond(request, sizes, added) {
    request.deferred.resolve(`<html><body>${imageList(sizes, added)}</body></html>`);
  }

  function paste(files, types) {
    const event = {
      type: 'paste',
      clipboardData: { files: files, types: types || ['Files'] },
      preventDefault: jasmine.createSpy('preventDefault')
    };
    win.$('#body').trigger(win.$.Event(event));
    return event;
  }

  function png() {
    return new win.File(['png'], 'image.png', { type: 'image/png' });
  }

  afterEach(function() {
    win.close();
  });

  it("uploads a pasted image and puts its tag at the caret", async function() {
    await boot([[640, 480]]);

    const event = paste([png()]);
    await settle();
    expect(event.preventDefault).toHaveBeenCalled();

    const sent = requests[0].options.data;
    expect(sent.get('plugin')).toEqual('image');
    expect(sent.get('csrf_protection_key')).toEqual('secret');
    expect(sent.get('date')).toEqual('20261005');
    expect(sent.get('plugin_image_addimage')).toEqual('true');
    expect(sent.get('plugin_image_file').type).toEqual('image/jpeg');
    expect(sent.get('plugin_image_file').name).toEqual('image.jpg');
    expect(win.$('#body').val()).toEqual('text[Uploading image 1...]');

    respond(requests[0], [[640, 480], [1600, 900]], [1]);
    await settle();
    expect(win.$('#body').val()).toEqual("text{{image 1, 'image', nil, [1600,900]}}");
  });

  it("puts the tag where the image was pasted while the author keeps typing", async function() {
    await boot([]);
    const body = win.$('#body')[0];

    paste([png()]);
    await settle();
    body.setRangeText(' more', body.selectionStart, body.selectionEnd, 'end');
    respond(requests[0], [[1600, 900]], [0]);
    await settle();

    expect(body.value).toEqual("text{{image 0, 'image', nil, [1600,900]}} more");
    expect(body.selectionStart).toEqual(body.value.length);
  });

  it("replaces the selected text with the pasted image", async function() {
    await boot([]);
    win.$('#body')[0].setSelectionRange(0, 4);

    paste([png()]);
    await settle();
    respond(requests[0], [[1600, 900]], [0]);
    await settle();

    expect(win.$('#body').val()).toEqual("{{image 0, 'image', nil, [1600,900]}}");
  });

  it("uploads an image pasted on the preview page, which has no image form", async function() {
    await boot([], true);

    paste([png()]);
    await settle();
    expect(requests[0].options.url).toEqual('update.rb');
    expect(requests[0].options.data.get('date')).toEqual('20261005');

    respond(requests[0], [[1600, 900]], [0]);
    await settle();
    expect(win.$('#body').val()).toEqual("text{{image 0, 'image', nil, [1600,900]}}");
    expect(win.$('#plugin-image-delimage').length).toEqual(0);
  });

  it("puts the tag of an image that took the number of a deleted one", async function() {
    await boot([[640, 480], [800, 600]]);
    win.$('#image-index-1').parent().hide();

    paste([png()]);
    await settle();
    respond(requests[0], [[640, 480], [1600, 900]], [1]);
    await settle();

    expect(win.$('#body').val()).toEqual("text{{image 1, 'image', nil, [1600,900]}}");
  });

  it("shrinks the longer side to the configured size", async function() {
    await boot([]);

    paste([png()]);
    await settle();

    expect(drawn).toHaveBeenCalledWith(jasmine.any(Object), 0, 0, 1600, 900);
    expect(closed).toHaveBeenCalled();
    expect(win.createImageBitmap).toHaveBeenCalledWith(jasmine.any(win.File), { imageOrientation: 'from-image' });
  });

  it("keeps at least one pixel on the shorter side", async function() {
    await boot([]);
    win.createImageBitmap = file => Promise.resolve({ width: 10000, height: 2, close() {} });

    paste([png()]);
    await settle();

    expect(drawn).toHaveBeenCalledWith(jasmine.any(Object), 0, 0, 1600, 1);
  });

  it("keeps a PNG that needs no shrinking lossless", async function() {
    await boot([]);
    win.createImageBitmap = file => Promise.resolve({ width: 800, height: 600, close() {} });

    paste([png()]);
    await settle();

    const sent = requests[0].options.data.get('plugin_image_file');
    expect(sent.type).toEqual('image/png');
    expect(sent.name).toEqual('image.png');
  });

  it("decodes the images of one paste one at a time", async function() {
    await boot([]);
    const decoding = [];
    win.createImageBitmap = file => new Promise(resolve => decoding.push(resolve));

    paste([png(), png()]);
    await settle();
    expect(decoding.length).toEqual(1);

    decoding[0]({ width: 800, height: 600, close() {} });
    await settle();
    expect(decoding.length).toEqual(2);
  });

  it("sends a GIF as it is", async function() {
    await boot([]);
    const gif = new win.File(['gif'], 'anime.gif', { type: 'image/gif' });

    paste([gif]);
    await settle();

    expect(drawn).not.toHaveBeenCalled();
    expect(requests[0].options.data.get('plugin_image_file').name).toEqual('anime.gif');
  });

  it("sends a chosen file whose type the browser does not know", async function() {
    await boot([]);
    const input = win.$('#plugin-image-addimage input[type=file]')[0];
    Object.defineProperty(input, 'files', { value: [new win.File(['jpeg'], 'photo.jfif', { type: '' })] });
    const form = win.$('#plugin-image-addimage form')[0];
    Object.defineProperty(form, 'plugin_image_file', { value: input });

    win.$(form).trigger('submit');
    await settle();

    expect(requests.length).toEqual(1);
  });

  it("tells the author when the upload fails", async function() {
    await boot([[640, 480]]);

    paste([png()]);
    await settle();
    requests[0].deferred.reject();
    await settle();

    expect(win.alert).toHaveBeenCalledWith('upload failed');
    expect(win.$('#body').val()).toEqual('text');
    expect(win.$('#image-index-0').length).toEqual(1);
  });

  it("tells the author when the server saved nothing", async function() {
    await boot([[640, 480]]);

    paste([png()]);
    await settle();
    requests[0].deferred.resolve('<html><body>error</body></html>');
    await settle();

    expect(win.alert).toHaveBeenCalledWith('upload failed');
    expect(win.$('#image-index-0').length).toEqual(1);
  });

  it("leaves the text copied from a spreadsheet to the browser", async function() {
    await boot([]);

    const event = paste([png()], ['text/plain', 'text/html', 'Files']);
    await settle();

    expect(event.preventDefault).not.toHaveBeenCalled();
    expect(requests.length).toEqual(0);
  });

  it("deletes from the list replaced by an upload without leaving the page", async function() {
    await boot([]);

    paste([png()]);
    await settle();
    respond(requests[0], [[1600, 900]], [0]);
    await settle();

    win.$('#plugin-image-delimage').trigger('submit');
    expect(requests.length).toEqual(2);
    expect(requests[1].options.data).toContain('plugin=image');
  });

  it("waits for the previous upload before sending the next", async function() {
    await boot([]);

    paste([png()]);
    paste([png()]);
    await settle();
    expect(requests.length).toEqual(1);

    respond(requests[0], [[1600, 900]], [0]);
    await settle();
    expect(requests.length).toEqual(2);

    respond(requests[1], [[1600, 900], [1600, 900]], [1]);
    await settle();
    expect(win.$('#body').val()).toEqual("text{{image 0, 'image', nil, [1600,900]}}{{image 1, 'image', nil, [1600,900]}}");
  });
});
