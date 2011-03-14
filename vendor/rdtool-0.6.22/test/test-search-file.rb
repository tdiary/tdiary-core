require 'test/unit'

require 'rd/search-file'

include RD
class TestSearchFile < Test::Unit::TestCase
  include SearchFile

  def test_search_file
    include_path = ["test/data/sub", "test/data"]
    suffixes = ["xhtml", "html"]

    assert_equal("test/data/includee1.html",
                 search_file("includee1", include_path, suffixes))
    assert_equal("test/data/sub/includee2.html",
                 search_file("includee2", include_path, suffixes))
    assert_equal(nil,
                 search_file("includee3", include_path, suffixes))
    assert_equal("test/data/sub/includee4.html",
                 search_file("includee4", include_path, suffixes))
  end
end
