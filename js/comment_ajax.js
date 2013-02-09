/**
 * comment_ajax.js:
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kohei@machu.jp>
 * You can distribute it under GPL.
 */

$(function() {
	var form = $('form.comment');
	$('<input type="hidden">')
		.attr('name', 'comment')
		.appendTo(form);
	form.submit(function(e) {
		e.preventDefault();
		$(':submit', form).attr('disabled', 'disabled');
		$.post(form.attr('action'), form.serialize(), function(data) {
			form[0].reset();
			$(':submit', form).removeAttr('disabled');
			var comment = $('div.comment');
			// $(data) is a diary HTML of the day
			comment.after($('div.comment', $(data)));
			comment.remove();
		}, 'html');
	});
});
