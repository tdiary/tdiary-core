# -*- coding: utf-8 -*-
#
# Japanese resource of amazon plugin
#
# Copyright (C) 2002 HAL99 <hal99@mtj.biglobe.ne.jp>
# You can redistribute it and/or modify it under GPL2.
#

#
# isbn_image_left: 指定したISBNの書影をclass="left"で表示
#   パラメタ:
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(省略可)
#
# isbn_image_right: 指定したISBNの書影をclass="right"で表示
#   パラメタ:
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(省略可)
#
# isbn_image: 指定したISBNの書影をclass="amazon"で表示
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(省略可)
#
# isbn_detail: 指定したISBNの書籍を書影付きで詳細表示
#     asin:    ASINまたはISBN(必須)
#
# isbn: amazonにアクセスしない簡易バージョン。
#     asin:    ASINまたはISBN(必須)
#     comment: コメント(必須)
#
#   ASINとはアマゾン独自の商品管理IDです。
#   書籍のISBNをASINに入力すると書籍が表示されます。
#
#   それぞれ商品画像が見つからなかった場合は
#       <a href="amazonのページ">商品名</a>
#   のように商品名を表示します。
#   コメントが記述されている場合は商品名がコメントの内容に変わります。
#
# tdiary.confにおける設定:
#   @options['amazon.aid']:      アソシエイトIDを指定することで、自分のア
#                                ソシエイトプログラムを利用できます
#                                このオプションは設定画面から変更可能です
#   @options['amazon.hideconf']: 設定画面上でアソシエイトIDを入力不可能
#                                にしたい場合、trueに設定します
#   @options['amazon.imgsize']:  表示するイメージのサイズを指定します
#                                (0:大  1:中  2:小)
#   @options['amazon.hidename']: class="amazon"のときに商品名を表示したく
#                                ない場合、trueに設定します
#   @options['amazon.default_image_base']: デフォルトのイメージを格納した
#                                 URLを指定します。無指定時にはtDiary.org
#                                 にあるものが使われます。自作したい場合には
#                                 プラグイン集amazonディレクトリにあるPNG
#                                 ファイルを参考にして下さい
#   @options['amazon.nodefault']: デフォルトのイメージを表示したくない場合
#                                 trueに設定します
#
#
# 注意：著作権が関連する為、www.amazon.co.jpのアソシエイトプログラムを
# 確認の上利用して下さい。
#

@amazon_default_country = 'jp'
@amazon_item_name = /^Amazon.co.jp： (.*)<.*$/
@amazon_item_image = %r|(<img src="(http://images-jp\.amazon\.com/images/P/(.*MZZZZZZZ_?.jpg))".*?>)|i
@amazon_label_conf ='Amazon'
@amazon_label_aid = 'AmazonアソシエイトIDの指定'
@amazon_label_aid_desc = '日本のAmazonが扱う商品にのみ適用されます。他の国のアソシエイトIDを利用する場合はtdiary.confで指定して下さい。なお指定しない場合には、Amazon認証Proxyサービスの指定するIDが使われますのでご注意下さい。'
@amazon_label_imgsize = '表示するイメージのサイズ'
@amazon_label_large = '大きい'
@amazon_label_regular = '普通'
@amazon_label_small = '小さい'
@amazon_label_title = 'isbn_imageプラグインで商品名を'
@amazon_label_hide = '表示しない'
@amazon_label_show = '表示する'
@amazon_label_bitly = 'bit.lyを使って商品のURLを'
@amazon_label_bitly_enabled = '短縮する'
@amazon_label_bitly_disabled = '短縮しない'
@amazon_label_notfound = 'イメージが見つからないときは'
@amazon_label_usetitle = '商品名を表示する'
@amazon_label_usedefault = 'デフォルトのイメージを使う'
@amazon_label_clearcache = 'キャッシュの削除'
@amazon_label_clearcache_desc = 'イメージ関連情報のキャッシュを削除する(Amazon上の表示と矛盾がある場合に試して下さい)'

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
