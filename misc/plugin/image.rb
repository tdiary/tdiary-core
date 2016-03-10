# -*- coding: utf-8 -*-
# image.rb
# -pv-
#
# 名称:
# 絵日記Plugin
#
# 概要:
# 日記更新画面からの画像アップロード、本文への表示
#
# 使う場所:
# 本文
#
# 使い方:
# image( number, 'altword', thumbnail, size, place ) - 画像を表示します。
#    number - 画像の番号0、1、2等
#    altword - imgタグの altに入れる文字列
#    thumbnail - サムネイル(小さな画像)を指定する(省略可)
#    size - 画像のサイズ(Array)。[width, height]の形式で指定(省略可)
#    place - imgタグのclass名(省略可)。省略時は'photo'
#
# image_left( number, 'altword', thumbnail, size ) - imageにclass=leftを追加します。
# image_right( number, 'altword', thumbnail, size ) - imageにclass=rightを追加します。
#
# image_link( number, 'desc' ) - 画像へのリンクを生成します。
#    number - 画像の番号0、1、2等
#    desc - 画像の説明
#
# その他:
# tDiary version 1.5.4以降で動作します。
# tdiary.confで指定できるオプション:
#  @options['image.dir']
#     画像ファイルを保存するディレクトリ。無指定時は'./images/'
#     Webサーバの権限で書き込めるようにしておく必要があります。
#  @options['image.url']
#     画像ファイルを保存するディレクトリのURL。無指定時は'./images/'
#  @options['image.maxwidth']
#     sizeを指定しなかった場合に指定できる画像の最大表示幅。無指定時はnil
#     表示のたびにファイルアクセスが入るので、重くなるかも?
#
# ライセンスについて:
# Copyright (c) 2002,2003 Daisuke Kato <dai@kato-agri.com>
# Copyright (c) 2002 Toshi Okada <toshi@neverland.to>
# Copyright (c) 2003 Yoshimi KURUMA <yoshimik@iris.dti.ne.jp>
# Distributed under the GPL2 or any later version.
#

unless @resource_loaded then
	def image_error_num( max ); "画像は1日#{h max}枚までです。不要な画像を削除してから追加してください"; end
	def image_error_size( max ); "画像の最大サイズは#{h max}バイトまでです"; end
	def image_label_list_caption; '絵日記(一覧・削除) - 画像をクリックすると本文に追加できます'; end
	def image_label_add_caption; '絵日記(追加)'; end
	def image_label_description; '画像の説明'; end
	def image_label_add_plugin; '本文に追加'; end
	def image_label_delete; 'チェックした画像の削除'; end
	def image_label_only_jpeg; 'JPEGのみ'; end
	def image_label_add_image; 'この画像をアップロードする'; end
	def image_label_drop_here; 'ここにファイルをドロップ'; end
end

def image( id, alt = 'image', thumbnail = nil, size = nil, place = 'photo' )
  	image = image_list( @image_date )[id.to_i]
  	image_t = image_list( @image_date )[thumbnail.to_i] if thumbnail
	if size
		if size.kind_of?(Array)
			if size.length > 1
				size = %Q| width="#{h size[0]}" height="#{h size[1]}"|
			elsif size.length > 0
				size = %Q| width="#{h size[0]}"|
			end
		else
			size = %Q| width="#{size.to_i}"|
		end
	elsif @image_maxwidth then
		_, w, _ = image_info( "#{@image_dir}/#{image}".untaint )
		if w > @image_maxwidth then
			size = %Q[ width="#{h @image_maxwidth}"]
		else
			size = ""
		end
	end
	if thumbnail then
	  	%Q[<a href="#{h @image_url}/#{h image}"><img class="#{h place}" src="#{h @image_url}/#{h image_t}" alt="#{h alt}" title="#{h alt}"#{size}></a>]
	else
		%Q[<img class="#{h place}" src="#{h @image_url}/#{h image}" alt="#{h alt}" title="#{h alt}"#{size}>]
	end
end

def image_left( id, alt = "image", thumbnail = nil, width = nil )
   image( id, alt, thumbnail, width, "left" )
end

def image_right( id, alt = "image", thumbnail = nil, width = nil )
   image( id, alt, thumbnail, width, "right" )
end

def image_link( id, desc )
  	image = image_list( @image_date )[id.to_i]
   %Q[<a href="#{h @image_url}/#{h image}">#{desc}</a>]
end

#
# initialize
#
@image_dir = (@options && @options['image.dir']) || File.join(TDiary.server_root, @cgi.is_a?(RackCGI) ? 'public/images' : 'images')
@image_dir.chop! if /\/$/ =~ @image_dir
FileUtils.mkdir_p @image_dir unless File.exist?(@image_dir)

@image_url = @options && @options['image.url'] || "#{base_url}images/"
@image_url.chop! if /\/$/ =~ @image_url

@image_maxwidth = @options && @options['image.maxwidth'] || nil

add_body_enter_proc do |date|
   @image_date = date.strftime( "%Y%m%d" )
   ""
end

#
# service methods below.
#

def image_info( f )
	require 'fastimage'
	info = FastImage.new( f )
	[info.type.to_s.sub( /jpeg/, 'jpg' ), info.size].flatten
end

def image_ext
	'jpg|jpeg|gif|png'
end

def image_list( date )
	list = []
	reg = /#{date}_(\d+)\.(#{image_ext})$/
	begin
		Dir::glob( @image_dir + "/#{date}_*" ) do |file|
			file = File.basename( file )
			list[$1.to_i] = file if reg =~ file
		end
	rescue Errno::ENOENT
	end
	list
end

if /^(form|edit|formplugin|showcomment)$/ =~ @mode then
	enable_js( 'image.js' )
	add_js_setting( '$tDiary.plugin.image' )
	add_js_setting( '$tDiary.plugin.image.alt', %Q|'#{image_label_description}'| )
	add_js_setting( '$tDiary.plugin.image.drop_here', %Q|'#{image_label_drop_here}'| )
end

if /^formplugin$/ =~ @mode then
   maxnum = @options['image.maxnum'] || 1
   maxsize = @options['image.maxsize'] || 10000

	begin
	   date = @date.strftime( "%Y%m%d" )
		images = image_list( date )
	   if @cgi.params['plugin_image_addimage'][0]
			@cgi.params['plugin_image_file'].each do |file|
				extension, = image_info( file )
				file.rewind

				if extension =~ /\A(#{image_ext})\z/i
					begin
						size = file.size
					rescue NameError
						size = file.stat.size
					end
					output = "#{@image_dir}/#{date}_#{images.length}.#{extension}".untaint
					File::umask( 022 )
					File::open( output, "wb" ) do |f|
						f.print file.read
					end
				end
			end
	   elsif @cgi.params['plugin_image_delimage'][0]
	      @cgi.params['plugin_image_id'].each do |id|
	         file = "#{@image_dir}/#{images[id.to_i]}".untaint
	         if File::file?( file ) && File::exist?( file )
	            File::delete( file )
	         end
	      end
	   end
	rescue
		@image_message = $!.to_s
	end
end

add_form_proc do |date|
	r = ''
	tabidx = 1200
	images = image_list( date.strftime( '%Y%m%d' ) )
	if images.length > 0 then
	   r << %Q[<div class="form">
		<div class="caption">
		#{image_label_list_caption}
		</div>
		<form id="plugin-image-delimage" class="update" method="post" action="#{h @update}"><div>
		#{csrf_protection}
		<table id="image-table">
		<tr>]
		tmp = ''
	   images.each_with_index do |img,id|
			next unless img
			_, img_w, img_h = image_info(File.join(@image_dir,img).untaint)
			r << %Q[<td><img id="image-index-#{id}" class="image-img form" src="#{h @image_url}/#{h img}" alt="#{id}" width="#{h( (img_w && img_w > 160) ? 160 : (img_w ? img_w : 160) )}"></td>]
			img_info = ''
			if img_w && img_h
				img_info << %Q|<span class="image-width">#{img_w}</span> x <span class="image-height">#{img_h}</span>|
			end
			tmp << %Q[<td id="image-info-#{id}">
			<label><input type="checkbox" tabindex="#{tabidx+id*2}" name="plugin_image_id" value="#{id}">&nbsp;#{img_info}</label>
			</td>]
	   end
		r << "</tr><tr>"
		r << tmp
	   r << %Q[</tr>
		</table>
		<input type="hidden" name="plugin_image_delimage" value="true">
	   <input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}">
	   <input type="submit" tabindex="#{tabidx+97}" name="plugin" value="#{image_label_delete}">
	   </div></form>
		</div>]
	end

   r << %Q[<div id="plugin-image-addimage" class="form">
	<div class="caption">
	#{image_label_add_caption}
	</div>]
	if @image_message then
		r << %Q[<p class="message">#{@image_message}</p>]
	end
   r << %Q[<form class="update" method="post" enctype="multipart/form-data" action="#{h @update}"><div>
	#{csrf_protection}
   <input type="hidden" name="plugin_image_addimage" value="true">
   <input type="hidden" name="date" value="#{date.strftime( '%Y%m%d' )}">
   <input type="file" tabindex="#{tabidx+98}" name="plugin_image_file" size="50" multiple="multiple">
   <input type="submit" tabindex="#{tabidx+99}" name="plugin" value="#{h image_label_add_image}">
   </div></form>
	</div>]
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
