/**
 * comment_ajax.js:
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kohei@machu.jp>
 * You can distribute it under GPL2 or any later version.
 */

$(function() {
	$(document).on('submit', 'form.comment', function(e) {
		e.preventDefault();
		var form = $(this);
		$('<input type="hidden">').attr('name', 'comment').appendTo(form);
		$(':submit', form).attr('disabled', 'disabled');
		$('div.button input', form).hide();
		$('div.button', form).append('<div id="loading-button"><img src="' + $tDiary.plugin.comment_ajax.theme + '/loading.gif">')
		$.post(form.attr('action'), form.serialize(), function(data) {
			$('#loading-button').remove();
			$('div.button input', form).show();
			form[0].reset();
			$(':submit', form).removeAttr('disabled');
			// $(data) is a diary HTML of the day
			$('div.comment:first', form.parents('div.day'))
				.after($('div.comment', $(data)))
				.remove();
		}, 'html');
	});
});
