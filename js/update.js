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
});
