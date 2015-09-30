/*
 * amazon.js :
 *   * remove height / width infomation of images
 *
 * Copyright (C) 2015 by TADA Tadashi <t@tdtds.jp>
 * You can distribute it under GPL2 or any later version.
 */

$(function(){
	if($(window).width() <= 360) {
		$('img.amazon').attr('height', null).attr('width', null);
	}
});
