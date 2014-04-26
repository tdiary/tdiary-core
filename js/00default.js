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

/* 
 * https://github.com/jquery/jquery/blob/1.8.3/src/deprecated.js
 */

(function() {
    var matched, browser;

    // Use of jQuery.browser is frowned upon.
    // More details: http://api.jquery.com/jQuery.browser
    // jQuery.uaMatch maintained for back-compat
    jQuery.uaMatch = function( ua ) {
        ua = ua.toLowerCase();

        var match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
            /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
            /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
            /(msie) ([\w.]+)/.exec( ua ) ||
            ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
            [];

        return {
            browser: match[ 1 ] || "",
            version: match[ 2 ] || "0"
        };
    };

    matched = jQuery.uaMatch( navigator.userAgent );
    browser = {};

    if ( matched.browser ) {
        browser[ matched.browser ] = true;
        browser.version = matched.version;
    }

    // Chrome is Webkit, but Webkit is also Safari.
    if ( browser.chrome ) {
        browser.webkit = true;
    } else if ( browser.webkit ) {
        browser.safari = true;
    }

    jQuery.browser = browser;
})();

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
