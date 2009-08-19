require 'rubygems'
require 'mathn'

# Need the FixedRange
$:.unshift File.dirname(__FILE__)
require 'fixed_range'

begin
  require 'facets/dictionary'
rescue LoadError => e
  # Do nothing
end

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
  def _jes_block_sorter(a, b, &block)
    if block
      val = yield(a, b)
    elsif _jes_default_block
      val = _jes_default_block.call(a, b)
    else
      val = a <=> b
    end
  end
  protected :_jes_block_sorter
  
  # Defines the new methods unobtrusively.
  def self.safe_alias(sym1, sym2=nil)
  
    return false if not sym2 and not sym1.to_s.match(/^_jes_/)
    
    if sym2
      old_meth = sym2
      new_meth = sym1
    else
      old_meth = sym1
      new_meth = sym1.to_s.sub(/^_jes_/, '').to_sym
      return false if self.class.respond_to?(new_meth)
    end
    alias_method new_meth, old_meth
  end
    
  # Returns the max, using an optional block.
  def _jes_max(&block)
    self.inject do |best, e|
      val = _jes_block_sorter(best, e, &block)
      best = val > 0 ? best : e
    end
  end
  safe_alias :_jes_max
  
  # Returns the first index of the max value
  def _jes_max_index(&block)
    self.index(_jes_max(&block))
  end
  safe_alias :_jes_max_index

  # Min of any number of items
  def _jes_min(&block)
    self.inject do |best, e|
      val = _jes_block_sorter(best, e, &block)
      best = val < 0 ? best : e
    end
  end
  safe_alias :_jes_min
  
  # Returns the first index of the min value
  def _jes_min_index(&block)
    self.index(_jes_min(&block))
  end
  safe_alias :_jes_min_index
  
  # The block called to filter the values in the object.
  def _jes_default_block
    @_jes_default_stat_block 
  end
  safe_alias :_jes_default_block

  # Allows me to setup a block for a series of operations.  Example:
  # a = [1,2,3]
  # a.sum # => 6.0
  # a.default_block = lambda{|e| 1 / e}
  # a.sum # => 1.0
  def _jes_default_block=(block)
    @_jes_default_stat_block = block
  end
  safe_alias :_jes_default_block=

  # Provides zero in the right class (Numeric or Float)
  def _jes_zero
    any? {|e| e.is_a?(Float)} ? 0.0 : 0
  end
  protected :_jes_zero
  
  # Provides one in the right class (Numeric or Float)
  def _jes_one
    any? {|e| e.is_a?(Float)} ? 1.0 : 1
  end
  protected :_jes_one
  
  # Adds up the list.  Uses a block or default block if present.
  def _jes_sum
    sum = _jes_zero
    if block_given?
      each{|i| sum += yield(i)}
    elsif _jes_default_block
      each{|i| sum += _jes_default_block[*i]}
    else
      each{|i| sum += i}
    end
    sum
  end
  safe_alias :_jes_sum

  # The arithmetic mean, uses a block or default block.
  def _jes_average(&block)
    _jes_sum(&block)/size
  end
  safe_alias :_jes_average
  safe_alias :mean, :_jes_average
  safe_alias :avg, :_jes_average

  # The variance, uses a block or default block.
  def _jes_variance(&block)
    m = _jes_average(&block)
    sum_of_differences = if block_given?
      _jes_sum{ |i| j=yield(i); (m - j) ** 2 }
    elsif _jes_default_block
      _jes_sum{ |i| j=_jes_default_block[*i]; (m - j) ** 2 }
    else
      _jes_sum{ |i| (m - i) ** 2 }
    end
    sum_of_differences / (size - 1)
  end
  safe_alias :_jes_variance
  safe_alias :var, :_jes_variance

  # The standard deviation.  Uses a block or default block.
  def _jes_standard_deviation(&block)
    Math::sqrt(_jes_variance(&block))
  end
  safe_alias :_jes_standard_deviation
  safe_alias :std, :_jes_standard_deviation

  # The slow way is to iterate up to the middle point.  A faster way is to
  # use the index, when available.  If a block is supplied, always iterate
  # to the middle point. 
  def _jes_median(ratio=0.5, &block)
    return _jes_iterate_midway(ratio, &block) if block_given?
    begin
      mid1, mid2 = _jes_middle_two
      sorted = sort
      med1, med2 = sorted[mid1], sorted[mid2]
      return med1 if med1 == med2
      return med1 + ((med2 - med1) * ratio)
    rescue
      _jes_iterate_midway(ratio, &block)
    end
  end
  safe_alias :_jes_median
  

  def _jes_middle_two
    mid2 = size.div(2)
    mid1 = (size % 2 == 0) ? mid2 - 1 : mid2
    return mid1, mid2
  end
  protected :_jes_middle_two

  def _jes_median_position
    _jes_middle_two.last
  end
  protected :_jes_median_position

  def _jes_first_half(&block)
    fh = self[0.._jes_median_position].dup
  end
  protected :_jes_first_half

  def _jes_second_half(&block)
    # Total crap, but it's the way R does things, and this will most likely
    # only be used to feed R some numbers to plot, if at all. 
    sh = size <= 5 ? self[_jes_median_position..-1].dup : self[_jes_median_position - 1..-1].dup
  end
  protected :_jes_second_half

  # An iterative version of median
  def _jes_iterate_midway(ratio, &block)
    mid1, mid2, last_value, j, sorted, sort1, sort2 = _jes_middle_two, nil, 0, sort, nil, nil

    if block_given?
      sorted.each do |i|
        last_value = yield(i)
        j += 1
        sort1 = last_value if j == mid1
        sort2 = last_value if j == mid2
        break if j >= mid2
      end
    elsif _jes_default_block
      sorted.each do |i|
        last_value = _jes_default_block[*i]
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
  protected :_jes_iterate_midway

  # Takes the range_class and returns its map.
  # Example:
  # require 'mathn'
  # a = [1,2,3]
  # a
  # range_class = FixedRange, a.min, a.max, 1/4
  # a.categories
  # => [1, 5/4, 3/2, 7/4, 2, 9/4, 5/2, 11/4, 3]
  # For non-numeric values, returns a unique set, 
  # ordered if possible.
  def _jes_categories
    if @_jes_categories
      @_jes_categories
    elsif self._jes_is_numeric?
      self._jes_range_instance.map
    else
      self.uniq.sort rescue self.uniq
    end
  end
  safe_alias :_jes_categories
  
  def _jes_is_numeric?
    self.all? {|e| e.is_a?(Numeric)}
  end
  safe_alias :_jes_is_numeric?
  
  # Just an array of [min, max] to comply with R uses of the work.  Use
  # range_as_range if you want a real Range. 
  def _jes_range(&block)
    [_jes_min(&block), _jes_max(&block)]
  end
  safe_alias :_jes_range

  # Useful for setting a real range class (FixedRange).
  def _jes_set_range_class(klass, *args)
    @_jes_range_class = klass
    @_jes_range_class_args = args
    self._jes_range_class
  end
  safe_alias :_jes_set_range_class
  
  # Takes a hash of arrays for categories
  # If Facets happens to be loaded on the computer, this keeps the order
  # of the categories straight. 
  def _jes_set_range(hash)
    if defined?(Dictionary)
      @_jes_range_hash = Dictionary.new
      @_jes_range_hash.merge!(hash)
      @_jes_categories = @_jes_range_hash.keys.dup
    else
      @_jes_categories = hash.keys.dup
      @_jes_range_hash = hash
    end
    @_jes_category_values = nil
    @_jes_categories
  end
  safe_alias :_jes_set_range
  safe_alias :_jes_set_categories, :_jes_set_range
  safe_alias :set_categories, :_jes_set_range
  
  # Allows you to add one category at a time.  You can actually add more
  # than one category at a time, but it won't disrupt any previously-set
  # categories. 
  def _jes_add_category(hash)
    _jes_init_range_hash
    hash.each do |k, v|
      @_jes_range_hash[k] = v
      @_jes_categories << k
    end
    @_jes_category_values = nil
    hash
  end
  safe_alias :_jes_add_category
  
  def method_missing(sym, *args, &block)
    if self.categories.include?(sym)
      self._jes_render_category(sym)
    else
      super
    end
  end

  # Returns a specific category's values
  def _jes_render_category(category)
    self.category_values[category]
  end
  
  def _jes_init_range_hash
    if defined?(Dictionary)
      @_jes_range_hash ||= Dictionary.new
      @_jes_categories ||= []
    else
      @_jes_range_hash ||= {}
      @_jes_categories ||= []
    end
  end
  protected :_jes_init_range_hash
  
  # The hash of lambdas that are used to categorize the enumerable.
  attr_reader :_jes_range_hash
  safe_alias :_jes_range_hash
  
  # The arguments needed to instantiate the custom-defined range class.
  attr_reader :_jes_range_class_args
  safe_alias :_jes_range_class_args

  # Splits the values in two, <= the value and > the value.
  def _jes_dichotomize(split_value, first_label, second_label)
    container = defined?(Dictionary) ? Dictionary.new : Hash.new
    container[first_label] = lambda{|e| e <= split_value}
    container[second_label] = lambda{|e| e > split_value}
    _jes_set_range(container)
  end
  safe_alias :_jes_dichotomize
  
  # Counts each element where the block evaluates to true
  # Example:
  # a = [1,2,3]
  # a.count_if {|e| e % 2 == 0}
  def _jes_count_if(&block)
    self.inject(0) do |s, e|
      s += 1 if block.call(e)
      s
    end
  end
  safe_alias :_jes_count_if
  
  # Returns a Hash or Dictionary (if available) for each category with a
  # value as the set of matching values as an array. 
  # Because this is supposed to be lean (just enumerables), but this is an
  # expensive call, I'm going to cache it and offer a parameter to reset
  # the cache.  So, call category_values(true) if you need to reset the
  # cache. 
  def _jes_category_values(reset=false)
    @_jes_category_values = nil if reset
    return @_jes_category_values if @_jes_category_values
    container = defined?(Dictionary) ? Dictionary.new : Hash.new
    if self.range_hash
      @_jes_category_values = self._jes_categories.inject(container) do |cont, cat|
        cont[cat] = self.find_all &self._jes_range_hash[cat]
        cont
      end
    else
      @_jes_category_values = self._jes_categories.inject(container) do |cont, cat|
        cont[cat] = self.find_all {|e| e == cat}
        cont
      end
    end
  end
  safe_alias :_jes_category_values

  # When creating a range, what class will it be?  Defaults to Range, but
  # other classes are sometimes useful. 
  def _jes_range_class
    @_jes_range_class ||= Range
  end
  safe_alias :_jes_range_class

  # Actually instantiates the range, instead of producing a min and max array.
  def _jes_range_as_range(&block)
    if @_jes_range_class_args and not @_jes_range_class_args.empty?
      self._jes_range_class.new(*@_jes_range_class_args)
    else
      self._jes_range_class.new(_jes_min(&block), _jes_max(&block))
    end
  end
  safe_alias :_jes_range_as_range
  safe_alias :_jes_range_instance, :_jes_range_as_range
  safe_alias :range_instance, :_jes_range_as_range

  # I don't pass the block to the sort, because a sort block needs to look
  # something like: {|x,y| x <=> y}.  To get around this, set the default 
  # block on the object.
  def _jes_new_sort(&block)
    if block_given?
      map { |i| yield(i) }.sort.dup
    elsif _jes_default_block
      map { |i| _jes_default_block[*i] }.sort.dup
    else
      sort().dup
    end
  end
  safe_alias :_jes_new_sort

  # Ranks the values
  def _jes_rank(&block)

    sorted = _jes_new_sort(&block)
    # rank = map { |i| sorted.index(i) + 1 }

    if block_given?
      map { |i| sorted.index(yield(i)) + 1 }
    elsif _jes_default_block
      map { |i| 
        sorted.index(_jes_default_block[*i]) + 1 }
    else
      map { |i| sorted.index(i) + 1 }
    end

  end
  safe_alias :_jes_rank
  safe_alias :_jes_ordinalize, :_jes_rank
  safe_alias :ordinalize, :_jes_rank

  # Given values like [10,5,5,1]
  # Rank should produce something like [4,2,2,1]
  # And order should produce something like [4,2,3,1]
  # The trick is that rank skips as many as were duplicated, so there
  # could not be a 3 in the rank from the example above. 
  def _jes_order(&block)
    hold = []
    _jes_rank(&block).each do |x|
      while hold.include?(x) do
        x += 1
      end
      hold << x
    end
    hold
  end
  safe_alias :_jes_order

  # First quartile: nth_split_by_m(1, 4)
  # Third quartile: nth_split_by_m(3, 4)
  # Median: nth_split_by_m(1, 2)
  # Doesn't match R, and it's silly to try to.
  # def _jes_nth_split_by_m(n, m)
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
  def _jes_quantile(&block)
    [
      _jes_min(&block), 
      _jes_first_half(&block)._jes_median(0.25, &block), 
      _jes_median(&block), 
      _jes_second_half(&block)._jes_median(0.75, &block), 
      _jes_max(&block)
    ]
  end
  safe_alias :_jes_quantile

  # The cummulative sum.  Example:
  # [1,2,3].cum_sum # => [1, 3, 6]
  def _jes_cum_sum(sorted=false, &block)
    sum = _jes_zero
    obj = sorted ? self.sort : self
    if block_given?
      obj.map { |i| sum += yield(i) }
    elsif _jes_default_block
      obj.map { |i| sum += _jes_default_block[*i] }
    else
      obj.map { |i| sum += i }
    end
  end
  safe_alias :_jes_cum_sum
  safe_alias :cumulative_sum, :_jes_cum_sum

  # The cummulative product.  Example:
  # [1,2,3].cum_prod # => [1.0, 2.0, 6.0]
  def _jes_cum_prod(sorted=false, &block)
    prod = _jes_one
    obj = sorted ? self.sort : self
    if block_given?
      obj.map { |i| prod *= yield(i) }
    elsif _jes_default_block
      obj.map { |i| prod *= _jes_default_block[*i] }
    else
      obj.map { |i| prod *= i }
    end
  end
  safe_alias :_jes_cum_prod
  safe_alias :cumulative_product, :_jes_cum_prod

  # Used to preprocess the list
  def _jes_morph_list(&block)
    if block
      self.map{ |e| block.call(e) }
    elsif self._jes_default_block
      self.map{ |e| self._jes_default_block.call(e) }
    else
      self
    end
  end
  protected :_jes_morph_list
  
  # Example:
  # [1,2,3,0,5].cum_max # => [1,2,3,3,5]
  def _jes_cum_max(&block)
    _jes_morph_list(&block).inject([]) do |list, e|
      found = (list | [e])._jes_max
      list << (found ? found : e)
    end
  end
  safe_alias :_jes_cum_max
  safe_alias :cumulative_max, :_jes_cum_max

  # Example: 
  # [1,2,3,0,5].cum_min # => [1,1,1,0,0]
  def _jes_cum_min(&block)
      _jes_morph_list(&block).inject([]) do |list, e|
      found = (list | [e]).min
      list << (found ? found : e)
    end
  end
  safe_alias :_jes_cum_min
  safe_alias :cumulative_min, :_jes_cum_min

  # Multiplies the values:
  # >> product(1,2,3)
  # => 6.0
  def _jes_product
    self.inject(_jes_one) {|sum, a| sum *= a}
  end
  safe_alias :_jes_product

  # There are going to be a lot more of these kinds of things, so pay
  # attention. 
  def _jes_to_pairs(other, &block)
    n = [self.size, other.size]._jes_min
    (0...n).map {|i| block.call(self[i], other[i]) }
  end
  safe_alias :_jes_to_pairs

  # Finds the tanimoto coefficient: the intersection set size / union set
  # size.  This is used to find the distance between two vectors.
  # >> [1,2,3].cor([2,3,5])
  # => 0.981980506061966
  # >> [1,2,3].tanimoto_pairs([2,3,5])
  # => 0.5
  def _jes_tanimoto_pairs(other)
    _jes_intersect(other).size / _jes_union(other).size.to_f
  end
  safe_alias :_jes_tanimoto_pairs
  safe_alias :tanimoto_correlation, :_jes_tanimoto_pairs

  # Sometimes it just helps to have things spelled out.  These are all
  # part of the Array class. This means, you have methods that you can't
  # run on some kinds of enumerables. 

  # All of the left and right hand sides, excluding duplicates.
  # "The union of x and y"
  def _jes_union(other)
    self | other
  end
  safe_alias :_jes_union

  # What's shared on the left and right hand sides
  # "The intersection of x and y"
  def _jes_intersect(other)
    self & other
  end
  safe_alias :_jes_intersect

  # Everything on the left hand side except what's shared on the right
  # hand side. 
  # "The relative compliment of y in x"
  def _jes_compliment(other)
    self - other
  end
  safe_alias :_jes_compliment

  # Everything but what's shared
  def _jes_exclusive_not(other)
    (self | other) - (self & other)
  end
  safe_alias :_jes_exclusive_not

  # Finds the cartesian product, excluding duplicates items and self-
  # referential pairs.  Yields the block value if given. 
  def _jes_cartesian_product(other, &block)
    x,y = self.uniq.dup, other.uniq.dup
    pairs = x.inject([]) do |cp, i|
      cp | y.map{|b| i == b ? nil : [i,b]}.compact
    end
    return pairs unless block_given?
    pairs.map{|p| yield p.first, p.last}
  end
  safe_alias :_jes_cartesian_product
  safe_alias :cp, :_jes_cartesian_product
  safe_alias :permutations, :_jes_cartesian_product

  # Sigma of pairs.  Returns a single float, or whatever object is sent in.
  # Example: [1,2,3].sigma_pairs([4,5,6], 0) {|x, y| x + y}
  # returns 21 instead of 21.0.
  def _jes_sigma_pairs(other, z=_jes_zero, &block)
    self._jes_to_pairs(other,&block).inject(z) {|sum, i| sum += i}
  end
  safe_alias :_jes_sigma_pairs

  # Returns the Euclidian distance between all points of a set of enumerables
  def _jes_euclidian_distance(other)
    Math.sqrt(self._jes_sigma_pairs(other) {|a, b| (a - b) ** 2})
  end
  safe_alias :_jes_euclidian_distance

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
  def _jes_rand_in_range(*args)
    min = self._jes_min_of_lists(*args)
    max = self._jes_max_of_lists(*args)
    (0...size).inject([]) do |ary, i|
      ary << rand_between(min[i], max[i])
    end
  end
  safe_alias :_jes_rand_in_range

  # Finds the correlation between two enumerables.
  # Example: [1,2,3].cor [2,3,5]
  # returns 0.981980506061966
  def _jes_correlation(other)
    n = [self.size, other.size]._jes_min
    sum_of_products_of_pairs = self._jes_sigma_pairs(other) {|a, b| a * b}
    self_sum = self._jes_sum
    other_sum = other._jes_sum
    sum_of_squared_self_scores = self._jes_sum { |e| e * e }
    sum_of_squared_other_scores = other._jes_sum { |e| e * e }
    
    numerator = (n * sum_of_products_of_pairs) - (self_sum * other_sum)
    self_denominator = ((n * sum_of_squared_self_scores) - (self_sum ** 2))
    other_denominator = ((n * sum_of_squared_other_scores) - (other_sum ** 2))
    denominator = Math.sqrt(self_denominator * other_denominator)
    return numerator / denominator
  end
  safe_alias :_jes_correlation
  safe_alias :cor, :_jes_correlation

  # Transposes arrays of arrays and yields a block on the value.
  # The regular Array#transpose ignores blocks
  def _jes_yield_transpose(*enums, &block)
    enums.unshift(self)
    n = enums.map{ |x| x.size}.min
    block ||= lambda{|e| e}
    (0...n).map { |i| block.call enums.map{ |x| x[i] } }
  end
  safe_alias :_jes_yield_transpose
  
  # Returns the max of two or more enumerables.
  # >> [1,2,3].max_of_lists([0,5,6], [0,2,9])
  # => [1, 5, 9]
  def _jes_max_of_lists(*enums)
    _jes_yield_transpose(*enums) {|e| e._jes_max}
  end
  safe_alias :_jes_max_of_lists

  # Returns the min of two or more enumerables.
  # >> [1,2,3].min_of_lists([4,5,6], [0,2,9])
  # => [0, 2, 3]
  def _jes_min_of_lists(*enums)
    _jes_yield_transpose(*enums) {|e| e.min}
  end
  safe_alias :_jes_min_of_lists
  
  # Returns the covariance of two lists.
  def _jes_covariance(other)
    self._jes_to_f!
    other._jes_to_f!
    n = [self.size, other.size]._jes_min
    self_average = self._jes_average
    other_average = other._jes_average
    total_expected = self._jes_sigma_pairs(other) {|a, b| (a - self_average) * (b - other_average)}
    total_expected / n
  end
  safe_alias :_jes_covariance
  
  # The covariance / product of standard deviations
  # http://en.wikipedia.org/wiki/Correlation
  def _jes_pearson_correlation(other)
    self._jes_to_f!
    other._jes_to_f!
    denominator = self._jes_standard_deviation * other._jes_standard_deviation
    self._jes_covariance(other) / denominator
  end
  safe_alias :_jes_pearson_correlation
  
  # Some calculations have to have at least floating point numbers.  This
  # generates a cached version of the operation--only runs once per object. 
  def _jes_to_f!
    return true if @_jes_to_f
    @_jes_to_f = self.map! {|e| e.to_f}
  end
  
  # Scale a list by a number.  The implementation of this can be self-referential.
  # Example: a.scale!(a.standard_deviation)
  safe_alias :_jes_to_f!

  def _jes_scale(val=nil, &block)
    if block
      self.map{|e| block.call(e)}
    else
      self.map{|e| e * val}
    end
  end
  safe_alias :_jes_scale
  
  def _jes_scale!(val=nil, &block)
    if block
      self.map!{|e| block.call(e)}
    else
      self.map!{|e| e * val}
    end
  end
  safe_alias :_jes_scale!
  
  def _jes_scale_to_sigmoid
    self._jes_scale { |e| 1 / (1 + Math.exp( -1 * (e))) }
  end
  safe_alias :_jes_scale_to_sigmoid

  def _jes_scale_to_sigmoid!
    self._jes_scale! { |e| 1 / (1 + Math.exp( -1 * (e))) }
  end
  safe_alias :_jes_scale_to_sigmoid!

  def _jes_normalize
    self.map {|e| e.to_f / self._jes_sum }
  end
  safe_alias :_jes_normalize
  
  def _jes_normalize!
    sum = self._jes_sum
    self.map! {|e| e.to_f / sum }
  end
  safe_alias :_jes_normalize!
  
  def _jes_scale_between(*values)
    raise ArgumentError, "Must provide two values" unless values.size == 2
    values.sort!
    min = values[0]
    max = values[1]
    orig_min = self._jes_min
    scalar = (max - min) / (self._jes_max - orig_min).to_f
    shift = min - (orig_min * scalar)
    self._jes_scale{|e| (e * scalar) + shift}
  end
  safe_alias :_jes_scale_between

  def _jes_scale_between!(*values)
    raise ArgumentError, "Must provide two values" unless values.size == 2
    values.sort!
    min = values[0]
    max = values[1]
    orig_min = self._jes_min
    scalar = (max - min) / (self._jes_max - orig_min).to_f
    shift = min - (orig_min * scalar)
    self._jes_scale!{|e| (e * scalar) + shift}
  end
  safe_alias :_jes_scale_between!
  
  # Returns a hash or dictionary (if installed) of the frequency of each category.
  def _jes_frequency
    dict = defined?(Dictionary) ? Dictionary.new : Hash.new
    self._jes_category_values.each do |k, v|
      dict[k] = v.size / self.size
    end
    dict
  end
  safe_alias :_jes_frequency
  
  def _jes_frequency_for(key)
    self._jes_frequency[key]
  end
  safe_alias :_jes_frequency_for

end

# @a = [1,2,3]
