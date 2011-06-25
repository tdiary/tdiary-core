# -*- coding: utf-8 -*-
#
# English resource of image plugin
#

#
# Image Diary -  Upload images and insert to diary.
#
# image( number, 'altword', thumbnail ) - show an image.
#    number - image ID as 0, 1, 2...
#    altword - alt strings of the img element.
#    thumbnail - image ID of thumbnail (optional)
#
# image_left( number, 'altword', thumbnail ) - show an image with "class=left"
# image_right( number, 'altword', thumbnail ) - show an image with "class=right"
#
# image_link( number, 'desc' ) - make link to an image.
#    number - image ID as 0, 1, 2...
#    desc - description of the image.
#
# options in tdiary.conf:
#  @options['image.dir']
#     Directory of uploading images. Default is './images/'.
#     You have to set parmission to writable by web server.
#  @options['image.url']
#     URL of the image directory. Default is './images/'.
#  @options['image.maxnum']
#     Max of number of images per a day. Default is 1.
#     This option is effective in @secure = true.
#  @options['image.maxsize']
#     Max size of an image. Default is 10000 bytes.
#     This option is effective in @secure = true.
#
def image_error_num( max ); "每則日誌最多可貼 #{h max} 張圖片"; end
def image_error_size( max ); "每張圖片最大限制為 #{h max} bytes"; end
def image_label_list_caption; '列出或刪除圖片 - Click an image to insert'; end
def image_label_add_caption; '附加圖片'; end
def image_label_description; '圖片的附註'; end
def image_label_add_plugin; '附加到文章當中'; end
def image_label_delete; '將選取的圖片刪除'; end
def image_label_only_jpeg; '只接受 JPEG 格式'; end
def image_label_add_image; '上傳圖片'; end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
