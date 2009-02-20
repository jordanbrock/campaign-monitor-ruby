class Test::Unit::TestCase
  
  def assert_not_empty(v)
    assert !v.nil? and !v==""
  end
  
end