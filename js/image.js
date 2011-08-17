/*
 image.js: javascript for image.rb plugin of tDiary

 Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 Copyright (C) 2011 by hb <smallstyle@gmail.com>
 You can redistribute it and/or modify it under GPL2.
 */

function insertImage(text){
	$('#body').insertAtCaret(text);
}

$(function(){
	$('.image-img')
	.live('hover', function(){
		$(this).css('cursor', 'pointer');
	}, function(){
		$(this).css('cursor', 'default');
	})
	.live('click', function(){
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
		
		var self = this;
		var formData = new FormData();
		formData.append('plugin', 'image');
		$.each($('#plugin-image-addimage input[type="hidden"]'), function(){
			formData.append($(this).attr('name'), $(this).val());
		});
		$.each(this.plugin_image_file.files, function(i, file){
			formData.append('plugin_image_file', file);
		});
		
		var imagePlugin = new ImagePlugin($(this).attr('action'));
		imagePlugin.upload(formData, function(result){
			self.reset();
			$('#plugin-image-delimage').parents('div.form').remove();
			$('#plugin-image-addimage').before($('#plugin-image-delimage', result).parents('div.form').html());
		});
		return false;
	});
	
	$('#plugin-image-delimage')
	.live('submit', function(e){
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
});
