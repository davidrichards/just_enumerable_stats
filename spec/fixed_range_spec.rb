require File.join(File.dirname(__FILE__), "/spec_helper")
require 'fixed_range'

describe FixedRange, "initialize" do
  it "should take three paramaters, a min, max, and step_size" do
    lambda{@f = FixedRange.new(1,5,1)}.should_not raise_error
    @f.min.should eql(1)
    @f.max.should eql(5)
    @f.step_size.should eql(1)
  end
  
  it "should assume step of 1 if not given" do
    FixedRange.new(1,5).step_size.should eql(1)
  end
  
  it "should straighten out min and max (no reverse ranges here)" do
    @f = FixedRange.new(5,1)
    @f.min.should eql(1)
    @f.max.should eql(5)
  end
end

describe FixedRange do
  
  before(:each) do
    @f = FixedRange.new(1,5)
  end
  
  it "should be able to step with an arbitrary step size" do
    # 1.0 + 3.5
    count_values(@f, 2.5).should eql(4.5)
    # 1.0 + 1.5 + 2.0 ... 5.0
    count_values(@f, 0.5).should eql(27.0)
    count_values(@f, 5).should eql(1.0)
  end
  
  it "should expose each" do
    sum = 0.0
    @f.each {|x| sum += x}
    sum.should eql(15.0)
  end
  
  it "should expose min and max" do
    @f.min.should eql(1)
    @f.max.should eql(5)
  end
  
  it "should expose size" do
    @f.size.should eql(5.0)
  end
  
  it "should have an index lookup" do
    @f[0].should eql(1)
    @f[1].should eql(2)
    @f[2].should eql(3)
    @f[3].should eql(4)
    @f[4].should eql(5)
    lambda{@f[5].should eql(5)}.should raise_error
    @f[-1].should eql(5)
    @f[-2].should eql(4)
    @f[-3].should eql(3)
    @f[-4].should eql(2)
    @f[-5].should eql(1)
  end
end

def count_values(obj, step_size)
  sum = 0.0
  obj.step(step_size) {|x| sum += x}
  return sum
end


# @f = FixedRange.new(1.0,5.0)
# @f.each {|x| puts x}
# puts @f.size, @f.min, @f.max
# @f.step(2.5) {|x| puts x}