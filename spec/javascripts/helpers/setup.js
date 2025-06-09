// Setup for Jasmine tests with JSDOM
const jsdom = require('jsdom');
const { JSDOM } = jsdom;
const fs = require('fs');
const path = require('path');

// Create DOM environment
const dom = new JSDOM(`
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body></body>
</html>
`, {
  url: 'http://localhost',
  pretendToBeVisual: true,
  resources: 'usable'
});

// Set up global objects
global.window = dom.window;
global.document = dom.window.document;
global.navigator = dom.window.navigator;

// Load jQuery
const jqueryPath = path.join(__dirname, '../../../node_modules/jquery/dist/jquery.js');
const jquerySource = fs.readFileSync(jqueryPath, 'utf8');
dom.window.eval(jquerySource);
global.$ = dom.window.$;
global.jQuery = dom.window.jQuery;

// Load jasmine-jquery
const jasmineJqueryPath = path.join(__dirname, '../../../node_modules/jasmine-jquery/lib/jasmine-jquery.js');
const jasmineJquerySource = fs.readFileSync(jasmineJqueryPath, 'utf8');
dom.window.eval(jasmineJquerySource);

// Set up loadFixtures function
global.loadFixtures = function(...fixtures) {
  fixtures.forEach(fixture => {
    const fixturePath = path.join(__dirname, '../fixtures', fixture);
    if (fs.existsSync(fixturePath)) {
      const content = fs.readFileSync(fixturePath, 'utf8');
      global.document.body.innerHTML = content;
    }
  });
};

// Initialize $tDiary object
global.$tDiary = {
  style: 'default',
  plugin: {}
};

// Load source JavaScript files
const jsSourcePath = path.join(__dirname, '../../../js/00default.js');
if (fs.existsSync(jsSourcePath)) {
  const sourceCode = fs.readFileSync(jsSourcePath, 'utf8');
  
  // Execute in window context with $ as global variable
  dom.window.$ = global.$;
  dom.window.jQuery = global.jQuery;
  
  try {
    dom.window.eval(sourceCode);
  } catch (e) {
    console.warn('Warning: Could not evaluate source file:', e.message);
  }
  
  // Copy globals from window to global scope
  if (dom.window.$tDiary) {
    global.$tDiary = dom.window.$tDiary;
  }
  global.$ = dom.window.$;
  global.jQuery = dom.window.jQuery;
}
