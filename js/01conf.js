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
});
