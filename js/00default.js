/*
 00default.js: default javascript file for tDiary

 Copyright (C) 2010, TADA Tadashi <t@tdtds.jp>
 You can redistribute it and/or modify it under GPL2.
 */

/*
	values of plugin settings
 */
$tDiary = new Object();
$tDiary.plugin = new Object();

/*
	utility functions
 */
$.fn.extend({
	insertAtCaret: function(text){
		var elem = this.get(0);
		elem.focus();

		if(jQuery.browser.msie){
			var selection = document.selection.createRange();
			selection.text = text;
			selection.select();
		}else{
			var orig = elem.value;
			var posStart = elem.selectionStart;
			var posEnd = posStart + text.length;
			elem.value = orig.substr(0, posStart) + text + orig.substr(posStart);
			elem.setSelectionRange(posEnd, posEnd);
		}
	}
});
