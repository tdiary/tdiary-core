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
$tDiary.blogkit = false;
$tDiary.enabledPlugins = [];

/*
	plugin adding interface
	Usage: 
		$tDiary.plugin.add('sample', function() {
			// do anything
		});
 */
(function($) {
	var plugins = {};

	$tDiary.plugin.add = function(name, func) {
		console.log('add plugin: ' + name);
		plugins[name] = func;
	};

	// load enabled plugins
	$(function() {
		$.each($tDiary.enabledPlugins, function(i, name) {
			console.log('load plugin:' + name);
			if (typeof plugins[name] !== "undefined") {
				plugins[name]();
			} else {
				console.log("cannot load plugin: " + name);
			}
		});
	});
})(jQuery);

/*
$tDiary.plugin.add('p1', function() { $tDiary.test1 = true; });
$tDiary.plugin.add('p2', function() { $tDiary.test2 = true; });
$tDiary.plugin.add('p3', function() { $tDiary.test3 = true; });
$tDiary.enabledPlugins = ['p1', 'p2'];
*/

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

$.extend({
	makePluginTag: function(name, params){
		params = params || [];
		var tag = [];
		
		switch($tDiary.style){
			case 'wiki':
		        case 'gfm':
			case 'markdown':
				tag = ['{{', '}}'];
				break;
			case 'rd':
				tag = ['((%', '%))'];
				break;
			default:
				tag = ['<%=', '%>'];
				break;
		}
		
		return tag[0] + name + ' ' + ($.isFunction(params) ? params() : $.map(params, function(p){
				return '"' + p + '"';
			})).join(', ') + tag[1];
	}
});
