/*
 * amazon.js : replace amazon URL using bit.ly (amzn.to).
 *
 * Copyright (C) 2011 by TADA Tadashi <t@tdtds.jp>
 * You can distribute it under GPL2 or any later version.
 */

$(function(){
	function shorten(link){
		var url = link.attr('href');
		var api = 'http://api.bit.ly/v3/shorten'
				+ '?format=json'
				+ '&longUrl=' + encodeURIComponent(url)
				+ '&login=' + $tDiary.plugin.bitly.login
				+ '&apiKey=' + $tDiary.plugin.bitly.apiKey;

		$.ajax({
			type: 'GET',
			url: api,
			dataType: 'jsonp',
			success: function(data){
				if (data['data']){
					link.attr('href',data['data']['url']);
				}
				else{
					//console.warn('fail to short: ' + link.attr('href'));
				}
			}
		});
	}

	$(window).bind('scroll', function(event){
		var bottom = $(window).height() + $(window).scrollTop();
		//console.warn('window.bottom: ' + bottom);
		$('a[href*="://www.amazon.co.jp/"]').each(function(){
			var a = $(this);
			if (bottom > a.offset().top){
				//console.warn('appear!: ' + a.text());
				shorten(a);
			}
		});
	});
});
