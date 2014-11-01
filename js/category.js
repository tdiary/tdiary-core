/*
 category.js: javascript for category.rb plugin of tDiary

 Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 You can redistribute it and/or modify it under GPL2 or any later version.
 */

$(function(){
	// insert clicked category item into textarea of update form
	function insertCategoryItem(item) {
		$('#body').insertAtCaret( '[' + item.text() + ']' );
	}

	$('.category-item')
	.hover(function(){
		$(this).css('cursor', 'pointer');
	}, function(){
		$(this).css('cursor', 'default');
	})
	.click(function(){
		insertCategoryItem($(this));
	});

	$('#category-candidate').change(function(){
		$('option:selected', this).each(function(){
			insertCategoryItem($(this));
		});
	});
});
