#
# English resource of amazon plugin
#
# Copyright (C) 2002 HAL99 <hal99@mtj.biglobe.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#

#
# isbn_image_left: show the item image of specified ISBN by class="left".
#   Parameter:
#     asin:    ASIN or ISBN
#     comment: comment (optional)
#
# isbn_image_right:
#   Parameter:
#     asin:    ASIN or ISBN
#     comment: comment (optional)
#
# isbn_image: show the item image of specified ISBN by class="right".
#     asin:    ASIN or ISBN
#     comment: comment (optional)
#
# isbn_detail: show the item detail with image
#     asin:    ASIN or ISBN
#
# isbn: light version. it dose not access to amazon.
#     asin:    ASIN or ISBN
#     comment: comment
#
# options in tdiary.conf:
#   @options['amazon.aid']: Your Amazon Assosiate ID. This option can be
#                           changed in preferences page.
#   @options['amazon.hideconf']: When you want to prohibit changing amazon.aid
#                             via preferences page, set false.
#   @options['amazon.imgsize']: specify image size (0:laege, 1:regular, 2:small)
#   @options['amazon.hidename']: hide book name when class="amazon", set true.
#   @options['amazon.default_image_base']: URL that include default images.
#                             amazon.rb uses images on tDiary.org when this
#                             option not specified. If you want to use your
#                             original images, modify PNG file in amazon directory.
#   @options['amazon.nodefault']: If you dosen't want to show default image
#                             when the book image not found, set true.

@amazon_default_country = 'us'
@amazon_item_name = /^Amazon\.com: (.*)$/
@amazon_item_image = %r|(<img src="(http://images\.amazon\.com/images/P/(.*MZZZZZZZ_?.jpg))".*?>)|i
@amazon_label_conf = 'Amazon'
@amazon_label_aid = 'Amazon Assosiate ID'
@amazon_label_aid_desc = "This ID will be used for US Amazon only. If you want to use other country's Amazon, specify in tdiary.conf."
@amazon_label_imgsize = 'Image size of the book'
@amazon_label_large = 'Large'
@amazon_label_regular = 'Regular'
@amazon_label_small = 'Small'
@amazon_label_title = 'When using isbn_image plugin'
@amazon_label_hide = 'Hide book title'
@amazon_label_show = 'Show book title'
@amazon_label_bitly = 'Using bit.ly'
@amazon_label_bitly_enabled = 'Shorten products url by bit.ly'
@amazon_label_bitly_disabled = 'Do not shorten'
@amazon_label_notfound = 'If book image dose not found'
@amazon_label_usetitle = 'Show book title'
@amazon_label_usedefault = 'Use default image'
@amazon_label_clearcache = 'Clear Cache'
@amazon_label_clearcache_desc = 'Delete local cache file about book images'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
