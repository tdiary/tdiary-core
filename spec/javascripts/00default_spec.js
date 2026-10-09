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

    it('should insert text before the selection and leave the caret after it', function() {
      $('#body')[0].setSelectionRange(0, 6);
      $('#body').insertAtCaret('[c]');
      expect($('#body').val()).toEqual('[c]sample diary');
      expect($('#body')[0].selectionStart).toEqual(3);
      expect($('#body')[0].selectionEnd).toEqual(3);
    });
  });

  describe("#replaceText", function() {
    let body;

    beforeEach(function() {
      loadFixtures('00default.html');
      body = $('#body')[0];
    });

    afterEach(function() {
      delete document.execCommand;
    });

    it('should edit through the browser command to keep the undo history', function() {
      document.execCommand = jasmine.createSpy('execCommand').and.callFake(function(command, ui, text) {
        body.setRangeText(text, body.selectionStart, body.selectionEnd, 'end');
        return true;
      });
      body.focus();
      body.setSelectionRange(12, 12);

      $.replaceText(body, 'my', 0, 6);

      expect(document.execCommand).toHaveBeenCalledWith('insertText', false, 'my');
      expect(body.value).toEqual('my diary');
      expect(body.selectionStart).toEqual(8);
    });

    it('should leave the focus where it is', function() {
      document.execCommand = jasmine.createSpy('execCommand');
      body.blur();
      body.setSelectionRange(12, 12);

      $.replaceText(body, 'my', 0, 6);

      expect(document.execCommand).not.toHaveBeenCalled();
      expect(body.value).toEqual('my diary');
      expect(body.selectionStart).toEqual(8);
    });
  });
});
