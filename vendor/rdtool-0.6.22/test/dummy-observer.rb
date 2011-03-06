class DummyObserver
  attr_reader :args
  def update(*args)
    @args = args
  end
end
