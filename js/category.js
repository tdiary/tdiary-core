/*
 category.js: javascript for category.rb plugin of tDiary

 Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 You can redistribute it and/or modify it under GPL2.
 */

$(function(){
	// insert clicked category item into textarea of update form
	$('.category-item').click(function(){
		var item = $(this);
		$('#body').insertAtCaret( '[' + item.text() + ']' );
	});
});
