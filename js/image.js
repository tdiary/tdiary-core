/*
 image.js: javascript for image.rb plugin of tDiary

 Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 You can redistribute it and/or modify it under GPL2.
 */

function insertImage(text){
	$('#body').insertAtCaret(text);
}

$(function(){
	$('.image-img')
	.hover(function(){
		$(this).css('cursor', 'pointer');
	}, function(){
		$(this).css('cursor', 'default');
	})
	.click(function(){
		var idx = this.id.replace('image-index-', '');
		var w = $('#image-info-' + idx + ' .image-width').text();
		var h = $('#image-info-' + idx + ' .image-height').text();
		$('#body').insertAtCaret($.makePluginTag('image', function(){
			return [idx, "'" + $tDiary.plugin.image.alt + "'", 'nil', '[' + w + ',' + h + ']']
		}));
	});
});
