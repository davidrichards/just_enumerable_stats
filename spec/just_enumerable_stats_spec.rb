require File.dirname(__FILE__) + '/spec_helper'

describe "JustEnumerableStats" do
  
  before do 
    @a = [1,2,3]
    @b = [8,4,2]
    @doubler = lambda{|e| e * 2}
    @inverser = lambda{|e| 1/e.to_f}
    @inverse_matcher = lambda{|a, b| 1/a <=> 1/b}
  end
  
  it "should be able to generate a random number between two integers" do
    val = (1..100).map {rand_between(1,10)}
    (val.min >= 1).should be_true
    (val.max <= 10).should be_true
  end
  
  it "should be able to generate a random number between two floats" do
    val = (1..100).map {rand_in_floats(1.0,10.0)}
    (val.min >= 1).should be_true
    (val.max <= 10).should be_true
    val.all? {|v| v.should be_is_a(Float)}
  end
  
  it "should be able to work with floats from rand_between" do
    val = (1..100).map {rand_between(1.0,10.0)}
    (val.min >= 1).should be_true
    (val.max <= 10).should be_true
    val.all? {|v| v.should be_is_a(Float)}
  end
  
  it "should have an original max" do
    @a.original_max.should eql(3)
  end
  
  it "should have an original min" do
    @a.original_min.should eql(1)
  end
  
  it "should have a max" do
    @a.max.should eql(3)
  end
  
  it "should have a max that takes a block" do
    val = @a.max &@inverse_matcher
    val.should eql(1)
  end
  
  it "should be able to use a default block for max" do
    @a.default_block = @inverse_matcher
    @a.max.should eql(1)
  end
  
  it "should know the index of the max value" do
    @a.max_index.should eql(2)
  end
  
  it "should find the first index value with max_index, in case there are duplicates" do
    [1,2,3,3].max_index.should eql(2)
  end
  
  it "should use a block to find the max index" do
    val = @a.max_index &@inverse_matcher
    val.should eql(0)
  end
  
  it "should be able to use a default block to find the max index" do
    @a.default_block = @inverse_matcher
    @a.max_index.should eql(0)
  end
  
  it "should have a min" do
    @a.min.should eql(1)
  end
  
  it "should have a min that takes a block" do
    val = @a.min &@inverse_matcher
    val.should eql(3)
  end
  
  it "should be able to use a default block for min" do
    @a.default_block = @inverse_matcher
    @a.min.should eql(3)
  end
  
  it "should know the index of the min value" do
    @a.min_index.should eql(0)
  end
  
  it "should find the first index value with min_index, in case there are duplicates" do
    [1,1,2,3].min_index.should eql(0)
  end
  
  it "should use a block to find the min index" do
    val = @a.min_index &@inverse_matcher
    val.should eql(2)
  end
  
  it "should be able to use a default block to find the min index" do
    @a.default_block = @inverse_matcher
    @a.min_index.should eql(2)
  end
  
  it "should be able to sum a list" do
    @a.sum.should eql(6)
    [1, 2, 3.0].sum.should eql(6.0)
  end
  
  it "should offer sum with a precision of 1.0e-15" do
    [0.1, 0.2, 0.3].sum.should be_close(0.6, 1.0e-15)
    [0.1, 0.2, 0.3].sum.should_not be_close(0.6, 1.0e-16)
  end
  
  it "should be able to evaluate a sum with a block" do
    @a.sum(&@doubler).should eql(12)
  end
  
  it "should be able to use the default block to evaluate sum" do
    @a.default_block = @doubler
    @a.sum.should eql(12)
  end
  
  it "should be able to find the arithmetic average, mean, or avg" do
    @a.average.should eql(2)
    @a.mean.should eql(2)
    @a.avg.should eql(2)
    [1, 2, 3.0].average.should eql(2.0)
  end
  
  it "should be able to calculate average with a block" do
    @a.average(&@doubler).should eql(4)
    @a.mean(&@doubler).should eql(4)
    @a.avg(&@doubler).should eql(4)
    [1, 2, 3.0].average(&@doubler).should eql(4.0)
  end
  
  it "should be able to calculate average with a default block" do
    @a.default_block = @doubler
    @a.average.should eql(4)
    @a.mean.should eql(4)
    @a.avg.should eql(4)
    b = [1, 2, 3.0]
    b.default_block = @doubler
    b.average.should eql(4.0)
  end
  
  it "should be able to calculate the variance" do
    @a.variance.should eql(1)
    @a.var.should eql(1)
  end
  
  it "should be able to calculate the variance with a block" do
    @a.variance(&@doubler).should eql(4)
    @a.var(&@doubler).should eql(4)
  end
  
  it "should be able to calculate the variance with a default block" do
    @a.default_block = @doubler
    @a.variance.should eql(4)
    @a.var.should eql(4)
  end
  
  it "should be able to calculate the standard deviation" do
    @a.standard_deviation.should eql(1)
    @a.std.should eql(1)
  end
  
  it "should be able to calculate the standard deviation with a block" do
    @a.standard_deviation(&@doubler).should eql(2)
    @a.std(&@doubler).should eql(2)
  end
  
  it "should be able to calculate the standard deviation with a default block" do
    @a.default_block = @doubler
    @a.standard_deviation.should eql(2)
    @a.std.should eql(2)
  end
  
  it "should be able to calculate the median value" do
    @a.median.should eql(2)
    [1,4,3,2,5].median.should eql(3)
    [1,9,2,8].median.should eql(5.0)
  end
  
  it "should be able to get a max and min range from the list" do
    @a.range.should eql([1, 3])
  end
  
  it "should be able to pass a block to the range method" do
    @a.range(&@inverse_matcher).should eql([3, 1])
  end
  
  it "should be able to use a default block for the range method" do
    @a.default_block = @inverse_matcher
    @a.range.should eql([3, 1])
  end

  it "should have a getter and a setter on the range class" do
    @a.set_range_class Array
    @a.range_class.should eql(Array)
  end
  
  it "should be able to send extra arguments for the range class" do
    @a.set_range_class FixedRange, 1, 3, 0.25
    @a.range_as_range.should be_is_a(FixedRange)
    @a.range_instance.should be_is_a(FixedRange)
  end
  
  it "should use the range arguments when instantiating a range" do
    @a.set_range_class FixedRange, 1, 3, 0.5
    @a.range_instance.should be_is_a(FixedRange)
    @a.range_instance.min.should eql(1)
    @a.range_instance.max.should eql(3)
    @a.range_instance.step_size.should eql(0.5)
  end

  it "should be able to instantiate a range" do
    @a.range_as_range.should eql(Range.new(1, 3))
  end
  
  it "should know its categories, based on its range" do
    @a.categories.should eql([1,2,3])
  end
  
  it "should know its categories with a different range class" do
    @a.set_range_class FixedRange, 1, 3, 0.5
    @a.categories.should eql([1.0, 1.5, 2.0, 2.5, 3.0])
  end
  
  it "should know its categories from non-numeric values" do
    a = [:this, :and, :that]
    a.categories.should eql(a)
  end
  
  it "should be able to set a range with a hash of lambdas" do
    @a.set_range({
      "<= 2" => lambda{ |e| e <= 2 },
      "> 2" => lambda{ |e| e > 2 }
    })
    @a.categories.sort.should eql(["<= 2", "> 2"].sort)
  end

  it "should be able to set a category as an alias to set_range" do
    @a.set_categories({
      "<= 2" => lambda{ |e| e <= 2 },
      "> 2" => lambda{ |e| e > 2 }
    })
    @a.categories.sort.should eql(["<= 2", "> 2"].sort)
  end
  
  it "should be able to add a category" do
    @a.add_category({">= 2" => lambda{ |e| e >= 2}})
    @a.categories.sort.should eql([">= 2"].sort)
    @a.category_values[">= 2"].should eql([2,3])
  end
  
  it "should be able to add a category with categories already set" do
    @a.set_categories({
      "<= 2" => lambda{ |e| e <= 2 },
      "== 2" => lambda{ |e| e == 2 }
    })
    @a.category_values["<= 2"].should eql([1,2])
    @a.category_values["== 2"].should eql([2])
    @a.add_category({">= 2" => lambda{ |e| e >= 2}})
    @a.categories.sort.should eql([">= 2", "<= 2", "== 2"].sort)
    @a.category_values[">= 2"].should eql([2,3])
  end
  
  it "should be able to get a hash of category values" do
    @a.set_range({
      "<= 2" => lambda{ |e| e <= 2 },
      "> 2" => lambda{ |e| e > 2 }
    })
    @a.category_values["<= 2"].should eql([1,2])
    @a.category_values["> 2"].should eql([3])
  end
  
  it "should be able to get categories with dot notation" do
    @a.set_range({
      :small => lambda{ |e| e <= 2 },
      :large => lambda{ |e| e > 2 }
    })
    @a.small.should eql([1,2])
  end
  
  it "should be able to get category values with a regular range" do
    @a.category_values[1].should eql([1])
    @a.category_values[2].should eql([2])
    @a.category_values[3].should eql([3])
  end
  
  it "should be able to get category values with a custom range" do
    @a.set_range_class(FixedRange, 1, 3, 0.5)
    @a.category_values[1.0].should eql([1])
    @a.category_values[1.5].should eql([])
    @a.category_values[2.0].should eql([2])
    @a.category_values[2.5].should eql([])
    @a.category_values[3.0].should eql([3])
  end
    
  it "should be able to count conditionally" do
    @a.count_if {|e| e == 2}.should eql(1)
  end
  
  it "should be able to dichotomize a list" do
    @a.dichotomize(2, :small, :big)
    @a.categories.map{|e| e.to_s}.sort.map{|e| e.to_sym}.should eql([:big, :small])
    @a.category_values[:small].should eql([1,2])
    @a.category_values[:big].should eql([3])
  end
  
  it "should be able to instantiate a range with a block" do
    @a.range_as_range(&@inverse_matcher).should eql(Range.new(3, 1))
  end
  
  it "should be able to instantiate a range with a default block" do
    @a.default_block = @inverse_matcher
    @a.range_as_range.should eql(Range.new(3, 1))
  end
  
  it "should be able to create a new object, sorted" do
    a = [3,1,2]
    b = a.new_sort
    b.object_id.should_not eql(a.object_id)
    b.should eql([1,2,3])
    a << 4
    b.should eql([1,2,3])
  end
  
  it "should be able to take a block and still do new_sort" do
    @a.new_sort(&@doubler).should eql([2,4,6])
  end

  it "should be able to take a default block and still do new_sort" do
    @a.default_block = @doubler
    @a.new_sort.should eql([2,4,6])
  end

  it "should be able to rank a list" do
    @b.rank.should eql([3,2,1])
  end
  
  it "should be able to use a block in rank" do
    @b.rank(&@inverser).should eql([1,2,3])
  end
  
  it "should be able to use a default block in rank" do
    @b.default_block = @inverser
    @b.rank.should eql([1,2,3])
  end
  
  it "should have ordinalize work like ranke" do
    @b.ordinalize.should eql([3,2,1])
  end
  
  it "should be able to get the order of values, handling duplicates" do
    [10,5,5,1].order.should eql([4,2,3,1])
  end
  
  it "should be able to take a block in the ordering" do
    [10,5,5,1].order(&@inverser).should eql([1,2,3,4])
  end

  it "should be able to take a default block in the ordering" do
    a = [10,5,5,1]
    a.default_block = @inverser
    a.order.should eql([1,2,3,4])
  end

  it "should be able to calculate the cumulative sum" do
    @a.cumulative_sum.should eql([1,3,6])
    @a.cum_sum.should eql([1,3,6])
    [1,2,3.0].cum_sum.should eql([1.0, 3.0, 6.0])
  end
  
  it "should be able to take a block to produce the cumulative sum" do
    @a.cumulative_sum(&@doubler).should eql([2,6,12])
    @a.cum_sum(&@doubler).should eql([2,6,12])
    [1,2,3.0].cum_sum(&@doubler).should eql([2.0, 6.0, 12.0])
  end
  
  it "should be able to take a default block to produce the cumlative sum" do
    @a.default_block = @doubler
    @a.cumulative_sum.should eql([2,6,12])
    @a.cum_sum.should eql([2,6,12])
    b = [1,2,3.0]
    b.default_block = @doubler
    b.cum_sum.should eql([2.0, 6.0, 12.0])
  end

  it "should be able to calculate the cumulative product" do
    @a.cumulative_product.should eql([1,2,6])
    @a.cum_prod.should eql([1,2,6])
    [1,2,3.0].cum_prod.should eql([1.0, 2.0, 6.0])
  end
  
  it "should be able to take a block to produce the cumulative product" do
    @a.cumulative_product(&@doubler).should eql([2,8,48])
    @a.cum_prod(&@doubler).should eql([2,8,48])
    [1,2,3.0].cum_prod(&@doubler).should eql([2.0, 8.0, 48.0])
  end
  
  it "should be able to take a default block to produce the cumlative product" do
    @a.default_block = @doubler
    @a.cumulative_product.should eql([2,8,48])
    @a.cum_prod.should eql([2,8,48])
    b = [1,2,3.0]
    b.default_block = @doubler
    b.cum_prod.should eql([2.0, 8.0, 48.0])
  end

  it "should be able to produce the cumulative max" do
    @a.cumulative_max.should eql([1,2,3])
    @a.cum_max.should eql([1,2,3])
  end
  
  it "should be able to produce the cumulative max with a block" do
    @a.cumulative_max(&@doubler).should eql([2,4,6])
    @a.cum_max(&@doubler).should eql([2,4,6])
  end
  
  it "should be able to produce the cumulative max with a default block" do
    @a.default_block = @doubler
    @a.cumulative_max.should eql([2,4,6])
    @a.cum_max.should eql([2,4,6])
  end

  it "should be able to produce the cumulative min" do
    @a.cumulative_min.should eql([1,1,1])
    @a.cum_min.should eql([1,1,1])
  end
  
  it "should be able to produce the cumulative min with a block" do
    @a.cumulative_min(&@doubler).should eql([2,2,2])
    @a.cum_min(&@doubler).should eql([2,2,2])
  end
  
  it "should be able to produce the cumulative min with a default block" do
    @a.default_block = @doubler
    @a.cumulative_min.should eql([2,2,2])
    @a.cum_min.should eql([2,2,2])
  end
  
  it "should be able to multiply the values in the list" do
    @a.product.should eql(6)
  end

  it "should be able to yield an operation on pairs" do
    val = @a.to_pairs(@b) {|a, b| a + b}
    val.should eql([9,6,5])
  end
  
  # [1,2,3] and [2,3,4] have 2 items in common, and 4 unique items together.
  # So 2 items / 4 items is 0.5
  it "should be able to find the tanimoto coefficient" do
    b = [2,3,4]
    @a.tanimoto_pairs(b).should eql(0.5)
    @a.tanimoto_correlation(b).should eql(0.5)
  end
  
  it "should have long hand for union" do
    @a.union(@b).should eql([1, 2, 3, 8, 4])
  end
  
  it "should have long hand for intersect" do
    @a.intersect(@b).should eql([2])
  end
  
  it "should have a long hand for compliment" do
    @a.compliment(@b).should eql([1, 3])
  end
  
  it "should have a long hand for exclusive not" do
    @a.exclusive_not(@b).should eql([1,3,8,4])
  end
  
  it "should be able to generate a cartesian product" do
    @a.cartesian_product(@b).should eql([[1, 8], [1, 4], [1, 2], [2, 8], [2, 4], [3, 8], [3, 4], [3, 2]])
    @a.cp(@b).should eql([[1, 8], [1, 4], [1, 2], [2, 8], [2, 4], [3, 8], [3, 4], [3, 2]])
    @a.permutations(@b).should eql([[1, 8], [1, 4], [1, 2], [2, 8], [2, 4], [3, 8], [3, 4], [3, 2]])
  end
  
  it "should be able to add pairwise computations" do
    # Remember:
    # @a = [1,2,3]
    # @b = [8,4,2]
    val = @a.sigma_pairs(@b) {|a, b| a / b}
    val.should eql(1/8 + 2/4 + 3/2)
    val = @a.sigma_pairs(@b) {|a, b| a * b}
    val.should eql(1*8 + 2*4 + 3*2)
  end
  
  it "should be able to find the euclidian distance between two lists" do
    @a.euclidian_distance(@b).should be_close(7.348, 0.001)
    [1,2,3].euclidian_distance([2,3,4]).should eql(Math.sqrt(3.0))
  end
  
  it "should be able to generate a list of random numbers, each within the range between two lists" do
    a = [1,0,-1]
    b = [10,0,-20]
    list_min = a.min_of_lists(b)
    list_max = a.max_of_lists(b)
    100.times do
      val = a.rand_in_range(b)
      val.each_with_index do |e, i|
        e >= list_min[i]
        e <= list_max[i]
      end
    end
  end
  
  it "should be able to find random numbers in the range between many lists" do
    a = [1,0,-2]
    b = [10,0,-20]
    c = [2,0,-1]
    list_min = a.min_of_lists(b)
    list_max = a.max_of_lists(b)
    100.times do
      val = a.rand_in_range(b)
      val.each_with_index do |e, i|
        e >= list_min[i]
        e <= list_max[i]
      end
    end
  end
  
  it "should be able to yield a block for columns of values" do
    a = [1,2,6.0]
    b = [2,6.0,1]
    c = [6.0,1,2]
    val = a.yield_transpose(b, c) {|e| e.mean}
    val.should eql([3.0, 3.0, 3.0])
  end
  
  it "should be able to transpose a list of lists (not dependent on Array#transpose)" do
    a = [1,2,6.0]
    b = [2,6.0,1]
    c = [6.0,1,2]
    val = a.yield_transpose(b, c)
    val.should eql( [[1, 2, 6.0], [2, 6.0, 1], [6.0, 1, 2]])
  end
  
  it "should be able to get the correlation between two lists" do
    @a.correlation([2,3,5]).should be_close(0.981, 0.001)
    @a.cor([2,3,5]).should be_close(0.981, 0.001)
  end

  it "should be able to return the max of lists" do
    @a.max_of_lists(@b).should eql([8,4,3])
    @a.max_of_lists(@b, [10,10,10]).should eql([10,10,10])
  end
  
  it "should be able to return the min of lists" do
    @a.min_of_lists(@b).should eql([1,2,2])
  end
  
  it "should return the covariance of two lists" do
    a = [1,2,3,4]
    b = [3,3,4,3]
    a.covariance(b).should eql(0.125)
  end
  
  it "should be able to force the list into floats" do
    [1,2,3].to_f!.should eql([1.0, 2.0, 3.0])
  end
  
  it "should have the ability to scale the list by a number" do
    a = [1,2,3,4]
    a.scale!(0.5)
    a.should eql([0.5, 1.0, 1.5, 2.0])
  end
  
  it "should be able to scale a list by a calculation on the list" do
    a = (1..10).inject([]) {|list, i| list << rand}
    std = a.std
    b = a.map {|e| e * std}
    a.should_receive(:std).once.and_return(std)
    a.scale!(a.std)
    a.should eql(b)
  end
  
  it "should be able to scale by a function" do
    a = [-4, -2, 0, 2, 4]
    a.scale! { |e| 1 / (1 + Math.exp( -1 * (e))) }
    a[0].should be_close(0.01798, 1.0e-5)
    a[1].should be_close(0.11920, 1.0e-5)
    a[2].should eql(0.5)
    a[3].should be_close(0.88079, 1.0e-5)
    a[4].should be_close(0.98201, 1.0e-5)
  end
  
  it "should have a non-desctructive scale_to_sigmoid" do
    a = [-4, -2, 0, 2, 4]
    b = a.scale_to_sigmoid
    b[0].should be_close(0.01798, 1.0e-5)
    b[1].should be_close(0.11920, 1.0e-5)
    b[2].should eql(0.5)
    b[3].should be_close(0.88079, 1.0e-5)
    b[4].should be_close(0.98201, 1.0e-5)
  end

  it "should be able to scale to a sigmoid" do
    a = [-4, -2, 0, 2, 4]
    a.scale_to_sigmoid!
    a[0].should be_close(0.01798, 1.0e-5)
    a[1].should be_close(0.11920, 1.0e-5)
    a[2].should eql(0.5)
    a[3].should be_close(0.88079, 1.0e-5)
    a[4].should be_close(0.98201, 1.0e-5)
  end

  it "should be able to normalize a list" do
    b = @a.normalize
    b.should eql([1/6.0, 2/6.0, 3/6.0])
    @a.normalize!
    @a.should eql(b)
  end

  context "scale_between" do
    before do
      @a = [-4, -2, 0, 2, 4]
    end
    
    it "should require two parameters" do
      lambda{@a.scale_between(1)}.should raise_error(ArgumentError, 'Must provide two values')
      lambda{@a.scale_between(1,2)}.should_not raise_error
      lambda{@a.scale_between(1,2,3)}.should raise_error(ArgumentError, 'Must provide two values')
    end
    
    it "should return a new array between the scaled values" do
      b = @a.scale_between(1,2)
      b.should eql([1.0, 1.25, 1.5, 1.75, 2.0])
    end
    
    it "should be able to transform into a scaled set" do
      b = @a.scale_between(1,2)
      @a.scale_between!(1,2)
      @a.should eql(b)
    end
  end
  
  context "frequency" do
    it "should be able to generate a frequency" do
      @a.frequency[1].should eql(1/3)
      @a.frequency[2].should eql(1/3)
      @a.frequency[3].should eql(1/3)
    end
    
    it "should be able to generate a frequency for a specific value" do
      a = [3,3,3,2]
      a.frequency_for(3).should eql(3/4)
    end
  end
end
