/**
 * referer.js: fetch referer with ajax
 *
 * Copyright (C) 2013 by MATSUOKA Kohei <kmachu@gmail.com>
 * You can distribute it under GPL.
 */

$(function() {
  var referer_div = $('div#referer');
  var endpoint = referer_div.data('endpoint');
  var date = referer_div.data('date');
  var button = $('<button></button>').text($tDiary.plugin.referer.today);

  function create_referer_list (items) {
    var referer_list = $('<ul>');
    $.each(items, function(i, item) {
      referer_list.append(
        $('<li>')
          .append($('<span>').text(item.count + ' '))
          .append($('<a>').attr('href', item.href).text(item.title))
      );
    });
    return referer_list;
  }

  button.click(function() {
    button.attr("disabled", "disabled");
    $.ajax({
      type: 'GET',
      dataType: "json",
      url: referer_div.data('endpoint'),
      success: function(data) {
        // console.debug(data);
        if (data['volatile']) {
          var volatile_referer_div = $('<div>')
            .attr('class', 'caption')
            .text($tDiary.plugin.referer.volatile)
            .after(create_referer_list(data['volatile']));
          referer_div.after(volatile_referer_div);
        }
        referer_div.after(create_referer_list(data[date]));
        button.hide();
        referer_div.show();
      }
    });
  });

  referer_div.before(button);
  referer_div.hide();
});
