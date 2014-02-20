/*
 01conf.js: javascript for preferences pages of tDiary

 Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 You can redistribute it and/or modify it under GPL2.
 */

$(function(){
	$('#saving')
		.hide()
		.css('text-align', 'center')
		.css('margin-top', '10em');

	$('#conf-form').submit(function(){
		var form = $(this);
		$.ajax({
			type: 'post',
			url: form.attr('action'),
			data: form.serialize() + '&saveconf=OK',
			dataType: 'html',
			beforeSend: function(){
				form.hide();
				$('#saving').show();
			},
			success: function(data){
				if(location.search.match(/conf=(sp|csrf_protection)$/)){
					location.reload();
				} else {
					var result = data.match(/<form id="conf-form"[\s\S]*<\/form>/)[0];
					$('#saving').hide();
					form.empty().append($('div:first', result)).show();
				}
			},
			error: function(){
				$('#saving').hide();
				form.show();
				alert('cannot save!');
			}
		});
		return false;
	});

	/*
	 * theme thumbnail changer
	 */
	$(document).on('change', '#theme_selection',function(){
		var list = $(this);
		var image = $('#theme_thumbnail');

		var theme = '';
		if ( list.selectedIndex == 0 ) {
			theme = 'nowprinting';
		} else {
			theme = list.val().replace(/^.*\//, '');
		}
		image.attr('src', 'http://www.tdiary.org/theme.image/' + theme + '.jpg');
	});

	/*
	 * old ruby alert
	 */
	$('#alert-old-ruby').on('click', function(){
		var data = 'conf=old_ruby_alert;saveconf=OK';
		var csrf_key = $('#conf-form input[name=csrf_protection_key]').attr('value');
		if (csrf_key){ data += ';csrf_protection_key=' + csrf_key; }

		$.ajax({
			url: $('#conf-form').attr('action'),
			type: 'POST',
			dataType: 'html',
			data: data
		}).done(function(html){
			$('.alert-warn').hide();
		}).fail(function(XMLHttpRequest, textStatus, errorThrown){
			alert('failed saving settings.' + textStatus);
		});
	});
});
