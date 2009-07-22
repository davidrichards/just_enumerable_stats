# Borrowed this from my own gem, sirb

class Object
  
  # Simpler way to handle a random number between to values
  def rand_between(a, b)
    return rand_in_floats(a, b) if a.is_a?(Float) or b.is_a?(Float)
    range = (a - b).abs + 1
    rand(range) + [a,b].min
  end
  
  # Handles non-integers
  def rand_in_floats(a, b)
    range = (a - b).abs
    (rand * range) + [a,b].min
  end
  
end

module Enumerable    
  
  alias :original_max :max
  alias :original_min :min

  # To keep max and min DRY.
  def block_sorter(a, b, &block)
    if block
      val = yield(a, b)
    elsif default_block
      val = default_block.call(a, b)
    else
      val = a <=> b
    end
  end
  protected :block_sorter
  
  # Returns the max, using an optional block.
  def max(&block)
    self.inject do |best, e|
      val = block_sorter(best, e, &block)
      best = val > 0 ? best : e
    end
  end
  
  # Returns the first index of the max value
  def max_index(&block)
    self.index(max(&block))
  end

  # Min of any number of items
  def min(&block)
    self.inject do |best, e|
      val = block_sorter(best, e, &block)
      best = val < 0 ? best : e
    end
  end
  
  # Returns the first index of the min value
  def min_index(&block)
    self.index(min(&block))
  end
  
  # The block called to filter the values in the object.
  def default_block
    @default_stat_block 
  end

  # Allows me to setup a block for a series of operations.  Example:
  # a = [1,2,3]
  # a.sum # => 6.0
  # a.default_block = lambda{|e| 1 / e}
  # a.sum # => 1.0
  def default_block=(block)
    @default_stat_block = block
  end

  # Provides zero in the right class (Numeric or Float)
  def zero
    any? {|e| e.is_a?(Float)} ? 0.0 : 0
  end
  protected :zero
  
  # Provides one in the right class (Numeric or Float)
  def one
    any? {|e| e.is_a?(Float)} ? 1.0 : 1
  end
  protected :one
  
  # Adds up the list.  Uses a block or default block if present.
  def sum
    sum = zero
    if block_given?
      each{|i| sum += yield(i)}
    elsif default_block
      each{|i| sum += default_block[*i]}
    else
      each{|i| sum += i}
    end
    sum
  end

  # The arithmetic mean, uses a block or default block.
  def average(&block)
    sum(&block)/size
  end
  alias :mean :average
  alias :avg :average

  # The variance, uses a block or default block.
  def variance(&block)
    m = mean(&block)
    sum_of_differences = if block_given?
      sum{ |i| j=yield(i); (m - j) ** 2 }
    elsif default_block
      sum{ |i| j=default_block[*i]; (m - j) ** 2 }
    else
      sum{ |i| (m - i) ** 2 }
    end
    sum_of_differences / (size - 1)
  end
  alias :var :variance

  # The standard deviation.  Uses a block or default block.
  def standard_deviation(&block)
    Math::sqrt(variance(&block))
  end
  alias :std :standard_deviation

  # The slow way is to iterate up to the middle point.  A faster way is to
  # use the index, when available.  If a block is supplied, always iterate
  # to the middle point. 
  def median(ratio=0.5, &block)
    return iterate_midway(ratio, &block) if block_given?
    begin
      mid1, mid2 = middle_two
      sorted = new_sort
      med1, med2 = sorted[mid1], sorted[mid2]
      return med1 if med1 == med2
      return med1 + ((med2 - med1) * ratio)
    rescue
      iterate_midway(ratio, &block)
    end
  end

  def middle_two
    mid2 = size.div(2)
    mid1 = (size % 2 == 0) ? mid2 - 1 : mid2
    return mid1, mid2
  end
  protected :middle_two

  def median_position
    middle_two.last
  end
  protected :median_position

  def first_half(&block)
    fh = self[0..median_position].dup
  end
  protected :first_half

  def second_half(&block)
    # Total crap, but it's the way R does things, and this will most likely
    # only be used to feed R some numbers to plot, if at all. 
    sh = size <= 5 ? self[median_position..-1].dup : self[median_position - 1..-1].dup
  end
  protected :second_half

  # An iterative version of median
  def iterate_midway(ratio, &block)
    mid1, mid2, last_value, j, sorted, sort1, sort2 = middle_two, nil, 0, new_sort, nil, nil

    if block_given?
      sorted.each do |i|
        last_value = yield(i)
        j += 1
        sort1 = last_value if j == mid1
        sort2 = last_value if j == mid2
        break if j >= mid2
      end
    elsif default_block
      sorted.each do |i|
        last_value = default_block[*i]
        j += 1
        sort1 = last_value if j == mid1
        sort2 = last_value if j == mid2
        break if j >= mid2
      end
    else
      sorted.each do |i|
        last_value = i
        sort1 = last_value if j == mid1
        sort2 = last_value if j == mid2
        j += 1
        break if j >= mid2
      end
    end
    return med1 if med1 == med2
    return med1 + ((med2 - med1) * ratio)
  end
  protected :iterate_midway

  # Just an array of [min, max] to comply with R uses of the work.  Use
  # range_as_range if you want a real Range. 
  def range(&block)
    [min(&block), max(&block)]
  end

  # Useful for setting a real range class (FixedRange).
  def range_class=(klass)
    @range_class = klass
  end

  # When creating a range, what class will it be?  Defaults to Range, but
  # other classes are sometimes useful. 
  def range_class
    @range_class ||= Range
  end

  # Actually instantiates the range, instead of producing a min and max array.
  def range_as_range(&block)
    range_class.new(min(&block), max(&block))
  end

  # I don't pass the block to the sort, because a sort block needs to look
  # something like: {|x,y| x <=> y}.  To get around this, set the default 
  # block on the object.
  def new_sort(&block)
    if block_given?
      map { |i| yield(i) }.sort.dup
    elsif default_block
      map { |i| default_block[*i] }.sort.dup
    else
      sort().dup
    end
  end

  # Doesn't overwrite things like Matrix#rank
  def rank(&block)

    sorted = new_sort(&block)

    if block_given?
      map { |i| sorted.index(yield(i)) + 1 }
    elsif default_block
      map { |i| sorted.index(default_block[*i]) + 1 }
    else
      map { |i| sorted.index(i) + 1 }
    end

  end unless defined?(rank)

  # Given values like [10,5,5,1]
  # Rank should produce something like [4,2,2,1]
  # And order should produce something like [4,2,3,1]
  # The trick is that rank skips as many as were duplicated, so there
  # could not be a 3 in the rank from the example above. 
  def order(&block)
    hold = []
    rank(&block).each do |x|
      while hold.include?(x) do
        x += 1
      end
      hold << x
    end
    hold
  end

  # First quartile: nth_split_by_m(1, 4)
  # Third quartile: nth_split_by_m(3, 4)
  # Median: nth_split_by_m(1, 2)
  # Doesn't match R, and it's silly to try to.
  # def nth_split_by_m(n, m)
  #   sorted  = new_sort
  #   dividers = m - 1
  #   if size % m == dividers # Divides evenly
  #     # Because we have a 0-based list, we get the floor
  #     i = ((size / m.to_f) * n).floor
  #     j = i
  #   else
  #     # This reflects R's approach, which I don't think I agree with.
  #     i = (((size / m.to_f) * n) - 1)
  #     i = i > (size / m.to_f) ? i.floor : i.ceil
  #     j = i + 1
  #   end
  #   sorted[i] + ((n / m.to_f) * (sorted[j] - sorted[i]))
  # end
  def quantile(&block)
    [
      min(&block), 
      first_half(&block).median(0.25, &block), 
      median(&block), 
      second_half(&block).median(0.75, &block), 
      max(&block)
    ]
  end

  # The cummulative sum.  Example:
  # [1,2,3].cum_sum # => [1, 3, 6]
  def cum_sum(sorted=false, &block)
    sum = zero
    obj = sorted ? self.new_sort : self
    if block_given?
      obj.map { |i| sum += yield(i) }
    elsif default_block
      obj.map { |i| sum += default_block[*i] }
    else
      obj.map { |i| sum += i }
    end
  end
  alias :cumulative_sum :cum_sum

  # The cummulative product.  Example:
  # [1,2,3].cum_prod # => [1.0, 2.0, 6.0]
  def cum_prod(sorted=false, &block)
    prod = one
    obj = sorted ? self.new_sort : self
    if block_given?
      obj.map { |i| prod *= yield(i) }
    elsif default_block
      obj.map { |i| prod *= default_block[*i] }
    else
      obj.map { |i| prod *= i }
    end
  end
  alias :cumulative_product :cum_prod

  # Used to preprocess the list
  def morph_list(&block)
    if block
      self.map{ |e| block.call(e) }
    elsif self.default_block
      self.map{ |e| self.default_block.call(e) }
    else
      self
    end
  end
  protected :morph_list
  
  # Example:
  # [1,2,3,0,5].cum_max # => [1,2,3,3,5]
  def cum_max(&block)
    morph_list(&block).inject([]) do |list, e|
      found = (list | [e]).max
      list << (found ? found : e)
    end
  end
  alias :cumulative_max :cum_max

  # Example: 
  # [1,2,3,0,5].cum_min # => [1,1,1,0,0]
  def cum_min(&block)
    morph_list(&block).inject([]) do |list, e|
      found = (list | [e]).min
      list << (found ? found : e)
    end
  end
  alias :cumulative_min :cum_min

  # Multiplies the values:
  # >> product(1,2,3)
  # => 6.0
  def product
    self.inject(one) {|sum, a| sum *= a}
  end

  # There are going to be a lot more of these kinds of things, so pay
  # attention. 
  def to_pairs(other, &block)
    n = [self.size, other.size].min
    (0...n).map {|i| block.call(self[i], other[i]) }
  end

  # Finds the tanimoto coefficient: the intersection set size / union set
  # size.  This is used to find the distance between two vectors.
  # >> [1,2,3].cor([2,3,5])
  # => 0.981980506061966
  # >> [1,2,3].tanimoto_pairs([2,3,5])
  # => 0.5
  def tanimoto_pairs(other)
    intersect(other).size / union(other).size.to_f
  end
  alias :tanimoto_correlation :tanimoto_pairs

  # Sometimes it just helps to have things spelled out.  These are all
  # part of the Array class. This means, you have methods that you can't
  # run on some kinds of enumerables. 

  # All of the left and right hand sides, excluding duplicates.
  # "The union of x and y"
  def union(other)
    self | other
  end

  # What's shared on the left and right hand sides
  # "The intersection of x and y"
  def intersect(other)
    self & other
  end

  # Everything on the left hand side except what's shared on the right
  # hand side. 
  # "The relative compliment of y in x"
  def compliment(other)
    self - other
  end

  # Everything but what's shared
  def exclusive_not(other)
    (self | other) - (self & other)
  end

  # Finds the cartesian product, excluding duplicates items and self-
  # referential pairs.  Yields the block value if given. 
  def cartesian_product(other, &block)
    x,y = self.uniq.dup, other.uniq.dup
    pairs = x.inject([]) do |cp, i|
      cp | y.map{|b| i == b ? nil : [i,b]}.compact
    end
    return pairs unless block_given?
    pairs.map{|p| yield p.first, p.last}
  end
  alias :cp :cartesian_product
  alias :permutations :cartesian_product

  # Sigma of pairs.  Returns a single float, or whatever object is sent in.
  # Example: [1,2,3].sigma_pairs([4,5,6], 0) {|x, y| x + y}
  # returns 21 instead of 21.0.
  def sigma_pairs(other, z=zero, &block)
    self.to_pairs(other,&block).inject(z) {|sum, i| sum += i}
  end

  # Returns the Euclidian distance between all points of a set of enumerables
  def euclidian_distance(other)
    Math.sqrt(self.sigma_pairs(other) {|a, b| (a - b) ** 2})
  end

  # Returns a random integer in the range for any number of lists.  This
  # is a way to get a random vector that is tenable based on the sample
  # data.  For example, given two sets of numbers: 
  # 
  # a = [1,2,3]; b = [8,8,8]
  # 
  # rand_in_pair_range will return a value >= 1 and <= 8 in the first
  # place, >= 2 and <= 8 in the second place, and >= 3 and <= 8 in the
  # last place. 
  # Works for integers.  Rethink this for floats.  May consider setting up
  # FixedRange for floats.  O(n*5)
  def rand_in_range(*args)
    min = self.min_of_lists(*args)
    max = self.max_of_lists(*args)
    (0...size).inject([]) do |ary, i|
      ary << rand_between(min[i], max[i])
    end
  end

  # Finds the correlation between two enumerables.
  # Example: [1,2,3].cor [2,3,5]
  # returns 0.981980506061966
  def correlation(other)
    n = [self.size, other.size].min
    sum_of_products_of_pairs = self.sigma_pairs(other) {|a, b| a * b}
    self_sum = self.sum
    other_sum = other.sum
    sum_of_squared_self_scores = self.sum { |e| e * e }
    sum_of_squared_other_scores = other.sum { |e| e * e }
    
    numerator = (n * sum_of_products_of_pairs) - (self_sum * other_sum)
    self_denominator = ((n * sum_of_squared_self_scores) - (self_sum ** 2))
    other_denominator = ((n * sum_of_squared_other_scores) - (other_sum ** 2))
    denominator = Math.sqrt(self_denominator * other_denominator)
    return numerator / denominator
  end
  alias :cor :correlation

  # Transposes arrays of arrays and yields a block on the value.
  # The regular Array#transpose ignores blocks
  def yield_transpose(*enums, &block)
    enums.unshift(self)
    n = enums.map{ |x| x.size}.min
    block ||= lambda{|e| e}
    (0...n).map { |i| block.call enums.map{ |x| x[i] } }
  end
  
  # Returns the max of two or more enumerables.
  # >> [1,2,3].max_of_lists([0,5,6], [0,2,9])
  # => [1, 5, 9]
  def max_of_lists(*enums)
    yield_transpose(*enums) {|e| e.max}
  end

  # Returns the min of two or more enumerables.
  # >> [1,2,3].min_of_lists([4,5,6], [0,2,9])
  # => [0, 2, 3]
  def min_of_lists(*enums)
    yield_transpose(*enums) {|e| e.min}
  end
end