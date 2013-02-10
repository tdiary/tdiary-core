/**
 * comment_ajax.js:
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kohei@machu.jp>
 * You can distribute it under GPL.
 */

$(function() {
	function comment_ajax(target) {
		var form = $('form.comment', target);
		var comment = $('div.comment', target);
		$('<input type="hidden">')
		.attr('name', 'comment')
		.appendTo(form);
		form.submit(function(e) {
			e.preventDefault();
			$(':submit', form).attr('disabled', 'disabled');
			$.post(form.attr('action'), form.serialize(), function(data) {
				form[0].reset();
				$(':submit', form).removeAttr('disabled');
				// $(data) is a diary HTML of the day
				var new_comment = $('div.comment', $(data));
				comment.after(new_comment).remove();
				comment = new_comment;
			}, 'html');
		});
	}

	$(window).bind('AutoPagerize_DOMNodeInserted', function(event) {
		comment_ajax(event.target);
	});

	// does not support IE8 or earlier
	if (window.addEventListener) {
		window.addEventListener('AutoPatchWork.DOMNodeInserted', function(event) {
			comment_ajax(event.target);
		}, false);
	}

	comment_ajax(document);
});
