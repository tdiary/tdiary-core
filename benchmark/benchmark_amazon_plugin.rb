def enable_js(*args); end
def add_conf_proc(*args); end
def h(args); args; end

class Dummyconf
  def [](*args);
    if args[0] == 'amazon.imgsize'
      0
    end
  end
  def []=(*args); end

  def to_native( str, charset = nil )
    str = str.dup
    if str.encoding == Encoding::ASCII_8BIT
      str.force_encoding(charset || 'utf-8')
    end
    unless str.valid_encoding?
      str.encode!('utf-16be', {invalid: :replace, undef: :replace})
    end
    unless str.encoding == Encoding::UTF_8
      str.encode!('utf-8', {invalid: :replace, undef: :replace})
    end
    str
  end
end
@conf = Dummyconf.new

require 'benchmark/ips'
Benchmark.ips do |x|
  xml = File.read('../spec/fixtures/jpB00H91KK26.xml')
  require_relative '../misc/plugin/amazon'
  x.report('rexml') do
    item = AmazonItem.new(xml)
    amazon_detail_html( item )
  end
  x.report('oga') do
    require 'oga'
    item = AmazonItem.new(xml, :oga)
    amazon_detail_html(item)
  end
end
