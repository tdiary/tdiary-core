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
    doc = REXML::Document::new( REXML::Source::new( xml ) ).root
    item = doc.elements.to_a( '*/Item' )[0]
    amazon_detail_html( item )
  end
  require_relative '../misc/plugin/ogamazon'
  x.report('oga') do
    doc = Oga.parse_xml(xml)
    item = doc.xpath('*/*/Item')[0]
    ogamazon_detail_html(item)
  end
end
