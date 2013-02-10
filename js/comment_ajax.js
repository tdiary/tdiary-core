/**
 * comment_ajax.js:
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kohei@machu.jp>
 * You can distribute it under GPL.
 */

$(function() {
	$(document).on('submit', 'form.comment', function(e) {
		e.preventDefault();
		var form = $(this);
		$('<input type="hidden">').attr('name', 'comment').appendTo(form);
		$(':submit', form).attr('disabled', 'disabled');
		$.post(form.attr('action'), form.serialize(), function(data) {
			form[0].reset();
			$(':submit', form).removeAttr('disabled');
			// $(data) is a diary HTML of the day
			$('div.comment', form.parents('div.day'))
				.after($('div.comment', $(data)))
				.remove();
		}, 'html');
	});
});
