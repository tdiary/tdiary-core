/*
 * update_preview.js: preview the diary without leaving the update form
 *
 * Copyright (C) 2026 by SHIBATA Hiroshi <hsbt@ruby-lang.org>
 * You can distribute it under GPL2 or any later version.
 */

(function() {
	var form = function() { return $('#body').closest('form'); };
	var button = function() {
		return form().find('input[name=appendpreview], input[name=replacepreview]');
	};
	// the diary shown above the update form, where preview.rhtml puts it
	var day = function(root) {
		return root.find('div.update').prevAll('div.day').first();
	};
	var shown = function() {
		var current = day($(document));
		return current.length > 0 && current.css('display') != 'none';
	};

	// a response is dropped once a newer request is sent or the preview is hidden
	var latest = 0;

	var load = function() {
		var data = new URLSearchParams(form().serialize());
		data.append(button().attr('name'), button().val());
		var id = ++latest;
		return fetch(form().prop('action'), { method: 'POST', body: data })
			.then(function(response) { return response.text(); })
			.then(function(html) {
				if (id != latest) { return; }
				var rendered = day($(new DOMParser().parseFromString(html, 'text/html')));
				if (rendered.length == 0) { throw new Error('no preview in the response'); }
				var current = day($(document));
				if (current.length == 0) {
					current = rendered.insertBefore('div.update');
				} else {
					current.attr('class', rendered.attr('class')).empty().append(rendered.contents()).show();
				}
				current[0].scrollIntoView();
			})
			.catch(function() {
				// the preview page shows what went wrong
				if (id == latest) { form()[0].requestSubmit(button()[0]); }
			});
	};

	var hide = function() {
		latest++;
		day($(document)).hide();
		$('#body').focus();
	};

	$(function() {
		if (button().length == 0) { return; }

		// cancelling the click keeps the form from being submitted at all, so
		// the scripts that take a submit for posting the diary are not run
		button().on('click', function(e) {
			e.preventDefault();
			load();
		});

		$(document).on('keydown', function(e) {
			if ((e.metaKey || e.ctrlKey) && e.shiftKey && !e.altKey &&
					e.key.toLowerCase() == 'p' && !e.originalEvent.isComposing) {
				e.preventDefault();
				if (shown()) { hide(); } else { load(); }
			}
		});
	});
})();
