describe("$tDiary", function() {
  beforeEach(function() {
  });

  it("should exist a global $tDiary object", function() {
    expect($tDiary).toEqual(jasmine.any(Object));
    expect($tDiary.plugin).toEqual(jasmine.any(Object));
  });
});
