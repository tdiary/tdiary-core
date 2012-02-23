(function() {

  $(document).ready(function() {
    var form, targetArea;
    form = $('textarea');
    targetArea = $('div.update > div.form').first();
    if (form.width() < targetArea.width() / 2.5) {
      form.width(targetArea.width() / 2.5);
    }
    if (form.height() < targetArea.height() / 1.5) {
      return form.height(targetArea.height() / 1.5);
    }
  });

}).call(this);
