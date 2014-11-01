/**
 * highlight.js: Highlighting the element jumped from other pages. 
 *
 * Copyright (C) 2003 by Ryuji SAKAI
 * Copyright (C) 2003 by Kazuhiro NISHIYAMA
 * Copyright (C) 2011 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL2 or any later version.
 */

$(function() {
  function highlight(anchor) {
    // clear current highlight
    $(".highlight").removeClass("highlight");

    // change document title
    var target = $(anchor).parent();
    if (target.filter('h3').size() > 0) {
      document.title = target.children("a").attr("title") + " - " + $tDiary.title;
    }

    target.addClass("highlight");
  }

  // bind click event to anchors
  $(document.anchors)
    .filter(function() {
      return $(this).attr("name").match(/^[pc]/);
    })
    .bind("click", function() {
      highlight(this);
    })

  if (document.location.hash) {
    highlight($('[name=' + document.location.hash.replace(/[^\w]/g, "") + ']')[0]);
  }
});
