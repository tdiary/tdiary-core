/*
 * update.js: keep the text in the diary update form from being lost
 *
 * Copyright (C) 2026 by SHIBATA Hiroshi <hsbt@ruby-lang.org>
 * You can distribute it under GPL2 or any later version.
 */

$(function() {
	var body = $('#body');
	var form = body.closest('form');
	if (form.length == 0) { return; }
	var title = form.find('#title');

	// Enter in the title presses the first submit button, "edit this day",
	// which loads the saved diary over what was typed
	title.on('keydown', function(e) {
		if (e.key == 'Enter' && !e.originalEvent.isComposing && e.keyCode != 229) {
			e.preventDefault();
			body.focus();
		}
	});

	var saving = false;
	var unsaved = function() {
		return form.data('unsaved') ||
			title.val() != title.prop('defaultValue') ||
			body.val() != body.prop('defaultValue');
	};

	$(window).on('beforeunload', function(e) {
		if (!saving && unsaved()) {
			e.preventDefault();
			e.originalEvent.returnValue = '';
		}
	});

	// a second press while the first post is on its way appends the text twice.
	// A post stopped by the author brings no pageshow, so the guard also ends by
	// time instead of blocking every later post and the question on leaving.
	form.on('submit', function(e) {
		var submitter = e.originalEvent && e.originalEvent.submitter;
		if (submitter && submitter.name == 'edit') { return; }
		if (saving) {
			e.preventDefault();
			return;
		}
		saving = true;
		setTimeout(function() { saving = false; }, 10 * 1000);
	});

	$(window).on('pageshow', function() {
		saving = false;
	});
});
