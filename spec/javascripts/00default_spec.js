describe("$tDiary", function() {
  beforeEach(function() {
  });

  it("should exist a global $tDiary object", function() {
    expect($tDiary).toEqual(jasmine.any(Object));
    expect($tDiary.plugin).toEqual(jasmine.any(Object));
  });
});

describe("$", function() {
  describe("#makePluginTag", function() {
    describe("when Wiki style", function() {
      beforeEach(function() {
        $tDiary.style = 'wiki';
      });

      it('should create wiki style plugin tag', function() {
        var tag = $.makePluginTag("plugin_name", ["param1", "param2"]);
        expect(tag).toEqual('{{plugin_name "param1", "param2"}}');
        loadFixtures('00default.html');
      });
    });
  });

  describe("#insertAtCaret", function() {
    beforeEach(function() {
      loadFixtures('00default.html');
    });
    it('should insert text to the textarea', function() {
      $('#body').insertAtCaret('[category] ');
      expect($('#body').val()).toEqual('[category] sample diary');
    });
  });
});
