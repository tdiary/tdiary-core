/*
 image.js: javascript for image.rb plugin of tDiary

 Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 Copyright (C) 2011 by hb <smallstyle@gmail.com>
 You can redistribute it and/or modify it under GPL2 or any later version.
 */

function insertImage(text){
	$('#body').insertAtCaret(text);
}

$(function(){
	$('.image-img')
	.on('hover', function(){
		$(this).css('cursor', 'pointer');
	}, function(){
		$(this).css('cursor', 'default');
	})
	.on('click', function(){
		var idx = this.id.replace('image-index-', '');
		var w = $('#image-info-' + idx + ' .image-width').text();
		var h = $('#image-info-' + idx + ' .image-height').text();
		$('#body').insertAtCaret($.makePluginTag('image', function(){
			return [idx, "'" + $tDiary.plugin.image.alt + "'", 'nil', '[' + w + ',' + h + ']']
		}));
	});
	
	var ImagePlugin = function(url){
		this.url =url;
	};
	ImagePlugin.prototype = {
		upload: function(formData, callback){
			$.ajax({
				url: this.url,
				type: 'post',
				data: formData,
				processData: false,
				contentType: false,
				beforeSend: function(){
					$('#plugin-image-addimage input[type="submit"]').attr('disabled', 'disabled');
					$('#plugin-image-uploading').show();
				},
				success: function(data){
					callback(data);
				},
				complete: function(){
					$('#plugin-image-addimage input[type="submit"]').removeAttr('disabled');
					$('#plugin-image-uploading').hide();
				}
			});
		},
		
		remove: function(data, callback){
			$.ajax({
				url: this.url,
				type: 'post',
				data: data,
				dataType: 'html',
				success: function(response){
					callback();
				}				
			});
		}
	};
	
	$('#plugin-image-addimage input[name="plugin"]')
	.after($('<span>', {text: 'Uploading...'}).attr('id', 'plugin-image-uploading').hide());
		
	$('#plugin-image-addimage form')
	.submit(function(e){
		if(typeof(FormData) == 'undefined') {
			return true;
		}
		e.preventDefault();
		
		uploadFiles(this.plugin_image_file.files);
		this.reset();
		return false;
	});
	
	var uploadFiles = function(files) {
		var formData = new FormData();
		formData.append('plugin', 'image');
		$.each($('#plugin-image-addimage input[type="hidden"]'), function(){
			formData.append($(this).attr('name'), $(this).val());
		});
		$.each(files, function(i, file){
			formData.append('plugin_image_file', file);
		});

		var imagePlugin = new ImagePlugin($(this).attr('action'));
		imagePlugin.upload(formData, function(result){
			$('#plugin-image-delimage').parents('div.form').remove();
			$('<div>')
				.attr({
					'class': 'form'
				})
				.append($('#plugin-image-delimage', result).parents('div.form').html())
				.insertBefore('#plugin-image-addimage');
			var timestamp = new Date().getTime();
			$.each($('#plugin-image-delimage img'), function(){
				$(this).attr('src', $(this).attr('src') + '?' + timestamp);
			});
		});
		return false;
	};

	$('#plugin-image-delimage')
	.on('submit', function(e){
		e.preventDefault();
		
		var ids = $.map($('#image-table input[name="plugin_image_id"]:checked'), function(i){
			return $(i).val();
		});
		var imagePlugin = new ImagePlugin($(this).attr('action'));
		imagePlugin.remove($(this).serialize() + '&plugin=image', function(){
			$.each(ids, function(i, id){
				$('#image-index-' + id).parent().fadeOut();
				$('#image-info-' + id).fadeOut();
			});
		});
		return false;
	});

	if(window.File) {
		$('<div>')
			.attr({
				id: 'plugin_image_dnd'
			})
			.css({
				'height': '5em',
				'text-align': 'center',
				'line-height': '5em',
				'background': '#ddd',
				'border': 'dashed 3px #AAA'
			})
			.bind('dragenter', function(){
				$(this).css('border', 'solid 3px #AAA');
				return false;
			})
			.bind('dragleave', function(){
				$(this).css('border', 'dashed 3px #CCC');
				return false;
			})
			.bind('drop', function(e){
				$('#plugin_image_dnd').hide();
				$(this).css('border', 'dashed 3px #CCC');
				$('#plugin-image-addimage form').show();
				var files = e.originalEvent.dataTransfer.files;
				uploadFiles(files);
				return false;
			})
			.text($tDiary.plugin.image.drop_here)
			.hide()
			.appendTo('#plugin-image-addimage');

		var dnd_timer = false;
		$('body')
			.bind('dragenter', function() {
				if (dnd_timer) {
					clearTimeout( dnd_timer );
				}
				$('#plugin-image-addimage form').hide();
				$('#plugin_image_dnd').show();
			})
			.bind('dragover', function(){
				if (dnd_timer) {
					clearTimeout( dnd_timer );
				}
				return false;
			})
			.bind('dragleave', function(){
				dnd_timer = setTimeout(function(){
					$('#plugin_image_dnd').hide();
					$('#plugin-image-addimage form').show();
				}, 500);
				return false;
			});
	}
});
