class Test::Unit::TestCase
  
  def assert_not_empty(v)
    assert !v.nil?, "expected to not be empty, but was nil"
    assert !v.empty?, "expected to not be empty" if v.respond_to?(:empty?)
    assert !v.strip.empty?, "expected to not be empty" if v.is_a?(String)
  end
  
end