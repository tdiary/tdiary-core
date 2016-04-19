#
# en/category.rb : tDiary plugin for show category pages
#
# Copyright (C) 2016 TADA Tadashi
# Distributed under the GPL2 or any later version.
#

@category_conf_label = 'Category'

def category_conf_html
	r = <<-HTML
		<h3 class="subtitle">Build category index</h3>
		<p>
		To use the category feature, you should build category index.
		Check the box below and press OK to build category index.
		</p>
		<p><label for="category_initialize">
		<input type="checkbox" id="category_initialize" name="category_initialize" value="1">Build category index
		</label></p>
		<p>
		It takes several or several tens of second to create it. But your diaries are many or the server has low spec, it will be timeout. Rebuild index on off-line again.
		</p>

		<h3 class="subtitle">Edit Support</h3>
		<p>
		Category names can be shown under the 'Article' form.
		</p>
		<p>
		<select name="category.edit_support">
		<option value="1"#{" selected" if @conf['category.edit_support'] == 1}>Flat List</option>
		<option value="2"#{" selected" if @conf['category.edit_support'] == 2}>Dropdown List/option>
		<option value="0"#{" selected" if @conf['category.edit_support'] == 0}>Hide</option>
		</select>
		</p>
	HTML
	r
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
