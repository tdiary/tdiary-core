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
	$(document)
	.on('hover', '.image-img', function(){
		$(this).css('cursor', 'pointer');
	}, function(){
		$(this).css('cursor', 'default');
	})
	.on('click', '.image-img', function(){
		$('#body').insertAtCaret(imageTag(this));
	});

	var imageTag = function(img, context){
		var idx = img.id.replace('image-index-', '');
		var w = $('#image-info-' + idx + ' .image-width', context).text();
		var h = $('#image-info-' + idx + ' .image-height', context).text();
		return $.makePluginTag('image', function(){
			return [idx, "'" + $tDiary.plugin.image.alt + "'", 'nil', '[' + w + ',' + h + ']']
		});
	};

	var imageFiles = function(files){
		return $.grep(files, function(file){
			return /^image\//.test(file.type);
		});
	};

	var ImagePlugin = function(url){
		this.url =url;
	};
	ImagePlugin.prototype = {
		upload: function(formData){
			return $.ajax({
				url: this.url,
				type: 'post',
				data: formData,
				processData: false,
				contentType: false,
				beforeSend: function(){
					$('#plugin-image-addimage input[type="submit"]').attr('disabled', 'disabled');
					$('#plugin-image-uploading').show();
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
		
		uploadFiles($.makeArray(this.plugin_image_file.files));
		this.reset();
		return false;
	});
	
	var replaceMarker = function(marker, text){
		var body = $('#body').get(0);
		var start = body.value.indexOf(marker);
		if(start < 0){
			if(text){
				$('#body').insertAtCaret(text);
			}
			return;
		}
		var end = start + marker.length;
		body.setRangeText(text, start, end, body.selectionStart == end ? 'end' : 'preserve');
	};

	var uploads = 0;
	var uploading = Promise.resolve();
	var uploadFiles = function(files) {
		if(!files.length){
			return false;
		}
		var marker = '[Uploading image ' + (++uploads) + '...]';
		$('#body').insertAtCaret(marker);
		uploading = uploading.then(function(){
			var formData = new FormData();
			formData.append('plugin', 'image');
			formData.append('plugin_image_addimage', 'true');
			formData.append('date', $tDiary.plugin.image.date);
			$('form.update [name=csrf_protection_key]').first().each(function(){
				formData.append(this.name, this.value);
			});
			$.each(files, function(i, file){
				formData.append('plugin_image_file', file);
			});

			var imagePlugin = new ImagePlugin($('form.update').attr('action'));
			return imagePlugin.upload(formData);
		}).then(function(result){
			var list = $('#plugin-image-delimage', result).parents('div.form');
			var tags = $.map(list.find('.image-img[data-added]'), function(img){
				return imageTag(img, list);
			});
			if(!tags.length){
				throw new Error('no image was saved');
			}
			$('#plugin-image-delimage').parents('div.form').remove();
			$('<div>')
				.attr({
					'class': 'form'
				})
				.append(list.html())
				.insertBefore('#plugin-image-addimage');
			var timestamp = new Date().getTime();
			$.each($('#plugin-image-delimage img'), function(){
				$(this).attr('src', $(this).attr('src') + '?' + timestamp);
			});
			replaceMarker(marker, tags.join("\n"));
		}).catch(function(error){
			replaceMarker(marker, '');
			console.error(error);
			alert($tDiary.plugin.image.failed);
		});
		return false;
	};

	$('#body').on('paste', function(e){
		var clipboard = e.originalEvent.clipboardData;
		if(!clipboard || $.inArray('text/plain', clipboard.types) >= 0){
			return;
		}
		var files = imageFiles(clipboard.files);
		if(files.length){
			e.preventDefault();
			this.setRangeText('', this.selectionStart, this.selectionEnd, 'end');
			uploadFiles(files);
		}
	});

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
			.on('dragenter', function(){
				$(this).css('border', 'solid 3px #AAA');
				return false;
			})
			.on('dragleave', function(){
				$(this).css('border', 'dashed 3px #CCC');
				return false;
			})
			.on('drop', function(e){
				$('#plugin_image_dnd').hide();
				$(this).css('border', 'dashed 3px #CCC');
				$('#plugin-image-addimage form').show();
				uploadFiles($.makeArray(e.originalEvent.dataTransfer.files));
				return false;
			})
			.text($tDiary.plugin.image.drop_here)
			.hide()
			.appendTo('#plugin-image-addimage');

		$('#body').on('drop', function(e){
			var files = imageFiles(e.originalEvent.dataTransfer.files);
			if(files.length){
				e.preventDefault();
				$('#plugin_image_dnd').hide();
				$('#plugin-image-addimage form').show();
				uploadFiles(files);
			}
		});

		var dnd_timer = false;
		$('body')
			.on('dragenter', function() {
				if (dnd_timer) {
					clearTimeout( dnd_timer );
				}
				$('#plugin-image-addimage form').hide();
				$('#plugin_image_dnd').show();
			})
			.on('dragover', function(){
				if (dnd_timer) {
					clearTimeout( dnd_timer );
				}
				return false;
			})
			.on('dragleave', function(){
				dnd_timer = setTimeout(function(){
					$('#plugin_image_dnd').hide();
					$('#plugin-image-addimage form').show();
				}, 500);
				return false;
			});
	}
});
