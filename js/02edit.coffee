$(document).ready ->
  form = $('textarea')
  targetArea = $('div.update > div.form').first()
  form.width(targetArea.width()/2.5) if form.width() < targetArea.width()/2.5
  form.height(targetArea.height()/1.5) if form.height() < targetArea.height()/1.5
