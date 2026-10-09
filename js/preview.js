/*
 * preview.js: view preview automatically
 *
 * Copyright (c) MATSUOKA Kohei <http://www.machu.jp/>
 * Distributed under the GPL2 or any later version.
 */
$(function() {

var update = $('div.update');
var day = update.prevAll('div.day').first();
if (day.length == 0) {
  day = $('<div class="day autopagerize_page_element"></div>').insertBefore(update);
  $tDiary.preview.refresh();
}

$('<div class="preview-container"></div>')
  .css('display', 'flex')
  .css('flex-flow', 'row-reverse wrap')
  .insertAfter('h1')
  .append(day, update);
day.add(update)
  .css('flex', "1 1 " + $tDiary.plugin.preview.minWidth / 2 + "px");
$("div.whole-content").css('max-width', 'none');

var timer;
$('#body').closest('form').on('input', function() {
  clearTimeout(timer);
  timer = setTimeout($tDiary.preview.refresh, 1000);
});

});
