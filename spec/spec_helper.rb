$: << File.join(File.dirname(__FILE__), "/../lib") 
require 'rubygems' 
require 'spec' 
require 'just_enumerable_stats'

Spec::Runner.configure do |config|
  
end


# This is one monster class that happens to have everything that we want
# to define with this gem.  Since all the definitions raise an error,
# all we have to do is call the _jes_ version of each method and make
# sure that no error is raised.  This helps us make sure there are no
# dependencies from within the method that use a non-jes version of a
# method. 
class BusyClass
  include Enumerable
  def initialize(*vals)
    @values = vals
  end
  
  def method_missing(sym, *args, &block)
    @values.send(sym, *args, &block)
  end
  
  def max(&block); raise ArgumentError, "Should not be called"; end
  def max_index(&block); raise ArgumentError, "Should not be called"; end
  def min(&block); raise ArgumentError, "Should not be called"; end
  def min_index(&block); raise ArgumentError, "Should not be called"; end
  def default_block; raise ArgumentError, "Should not be called"; end
  def default_block=(block); raise ArgumentError, "Should not be called"; end
  def sum; raise ArgumentError, "Should not be called"; end
  def average(&block); raise ArgumentError, "Should not be called"; end
  def variance(&block); raise ArgumentError, "Should not be called"; end
  def standard_deviation(&block); raise ArgumentError, "Should not be called"; end
  def median(ratio=0.5, &block); raise ArgumentError, "Should not be called"; end
  def categories; raise ArgumentError, "Should not be called"; end
  def is_numeric?; raise ArgumentError, "Should not be called"; end
  def range(&block); raise ArgumentError, "Should not be called"; end
  def set_range_class(klass, *args); raise ArgumentError, "Should not be called"; end
  def set_range(hash); raise ArgumentError, "Should not be called"; end
  def set_categories(hash); raise ArgumentError, "Should not be called"; end
  def add_category(hash); raise ArgumentError, "Should not be called"; end
  def dichotomize(split_value, first_label, second_label); raise ArgumentError, "Should not be called"; end
  def count_if(&block); raise ArgumentError, "Should not be called"; end
  def category_values(reset=false); raise ArgumentError, "Should not be called"; end
  def range_class; raise ArgumentError, "Should not be called"; end
  def range_as_range(&block); raise ArgumentError, "Should not be called"; end
  def new_sort(&block); raise ArgumentError, "Should not be called"; end
  def rank(&block); raise ArgumentError, "Should not be called"; end
  def ordinalize(&block); raise ArgumentError, "Should not be called"; end
  def order(&block); raise ArgumentError, "Should not be called"; end
  def quantile(&block); raise ArgumentError, "Should not be called"; end
  def cum_sum(sorted=false, &block); raise ArgumentError, "Should not be called"; end
  def cum_prod(sorted=false, &block); raise ArgumentError, "Should not be called"; end
  def cum_max(&block); raise ArgumentError, "Should not be called"; end
  def cum_min(&block); raise ArgumentError, "Should not be called"; end
  def product; raise ArgumentError, "Should not be called"; end
  def to_pairs(other, &block); raise ArgumentError, "Should not be called"; end
  def tanimoto_pairs(other); raise ArgumentError, "Should not be called"; end
  def union(other); raise ArgumentError, "Should not be called"; end
  def intersect(other); raise ArgumentError, "Should not be called"; end
  def compliment(other); raise ArgumentError, "Should not be called"; end
  def exclusive_not(other); raise ArgumentError, "Should not be called"; end
  def cartesian_product(other, &block); raise ArgumentError, "Should not be called"; end
  def sigma_pairs(other, z=_jes_zero, &block); raise ArgumentError, "Should not be called"; end
  def euclidian_distance(other); raise ArgumentError, "Should not be called"; end
  def rand_in_range(*args); raise ArgumentError, "Should not be called"; end
  def correlation(other); raise ArgumentError, "Should not be called"; end
  def yield_transpose(*enums, &block); raise ArgumentError, "Should not be called"; end
  def max_of_lists(*enums); raise ArgumentError, "Should not be called"; end
  def min_of_lists(*enums); raise ArgumentError, "Should not be called"; end
  def covariance(other); raise ArgumentError, "Should not be called"; end
  def pearson_correlation(other); raise ArgumentError, "Should not be called"; end
  def to_f!; raise ArgumentError, "Should not be called"; end
  def scale!; raise ArgumentError, "Should not be called"; end
  def scale_to_sigmoid; raise ArgumentError, "Should not be called"; end
  def scale_to_sigmoid!; raise ArgumentError, "Should not be called"; end
  def normalize; raise ArgumentError, "Should not be called"; end
  def normalize!; raise ArgumentError, "Should not be called"; end
  def scale_between; raise ArgumentError, "Should not be called"; end
  def scale_between!; raise ArgumentError, "Should not be called"; end
  def frequency; raise ArgumentError, "Should not be called"; end
  def frequency_for(val); raise ArgumentError, "Should not be called"; end
end

    