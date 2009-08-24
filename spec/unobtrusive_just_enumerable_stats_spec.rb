require File.dirname(__FILE__) + '/spec_helper'

describe "JustEnumerableStats" do
  
  context "unobstrusive" do
    before do
      @a = BusyClass.new(1,2,3)
      @b = [2,3,1]
    end
    
    it "should not use the native max" do
      lambda{@a._jes_max}.should_not raise_error
    end

    it "should not use the native max_index" do
      lambda{@a._jes_max_index}.should_not raise_error
    end
    
    it "should not use the native min" do
      lambda{@a._jes_min}.should_not raise_error
    end
    
    it "should not use the native min_index" do
      lambda{@a._jes_min_index}.should_not raise_error
    end
    
    it "should not use the native default_block" do
      lambda{@a._jes_default_block}.should_not raise_error
    end

    it "should not use the native default_block=" do
      lambda{@a._jes_default_block= lambda{|e| 1} }.should_not raise_error
    end
    
    it "should not use the native sum" do
      lambda{@a._jes_sum}.should_not raise_error
    end
    
    it "should not use the native average" do
      lambda{@a._jes_average}.should_not raise_error
    end
    
    it "should not use the native variance" do
      lambda{@a._jes_variance}.should_not raise_error
    end
    
    it "should not use the native standard_deviation" do
      lambda{@a._jes_standard_deviation}.should_not raise_error
    end
    
    it "should not use the native median" do
      lambda{@a._jes_median}.should_not raise_error
    end
    
    it "should not use the native categories" do
      lambda{@a._jes_categories}.should_not raise_error
    end
    
    it "should not use the native is_numeric?" do
      lambda{@a._jes_is_numeric?}.should_not raise_error
    end
    
    it "should not use the native range" do
      lambda{@a._jes_range}.should_not raise_error
    end
    
    it "should not use the native set_range_class" do
      lambda{@a._jes_set_range_class(FixedRange)}.should_not raise_error
    end

    it "should not use the native set_range" do
      lambda{@a._jes_set_range({:a => 1})}.should_not raise_error
    end
    
    it "should not use the native set_categories" do
      lambda{@a._jes_set_categories({:a => 1})}.should_not raise_error
    end
    
    it "should not use the native add_category" do
      lambda{@a._jes_add_category({:a => 1})}.should_not raise_error
    end
    
    it "should not use the native dichotomize" do
      lambda{@a._jes_dichotomize(2, :small, :big)}.should_not raise_error
    end

    it "should not use the native count_if" do
      lambda{@a._jes_count_if {|e| e == 2}}.should_not raise_error
    end
    
    it "should not use the native category_values" do
      lambda{@a._jes_category_values}.should_not raise_error
    end
    
    it "should not use the native first_category" do
      lambda{@a._jes_first_category(1)}.should_not raise_error
    end
    
    it "should not use the native all_categories" do
      lambda{@a._jes_all_categories(1)}.should_not raise_error
    end
    
    it "should not use the native category_map" do
      lambda{@a._jes_category_map}.should_not raise_error
    end
    
    it "should not use the native range_class" do
      lambda{@a._jes_range_class}.should_not raise_error
    end
    
    it "should not use the native range_as_range" do
      lambda{@a._jes_range_as_range}.should_not raise_error
    end
    
    it "should not use the native new_sort" do
      lambda{@a._jes_new_sort}.should_not raise_error
    end
    
    it "should not use the native rank" do
      lambda{@a._jes_rank}.should_not raise_error
    end
    
    it "should not use the native ordinalize" do
      lambda{@a._jes_ordinalize}.should_not raise_error
    end
    
    it "should not use the native order" do
      lambda{@a._jes_order}.should_not raise_error
    end
    
    it "should not use the native quantile" do
      lambda{@a._jes_quantile}.should_not raise_error
    end
    
    it "should not use the native cum_sum" do
      lambda{@a._jes_cum_sum}.should_not raise_error
    end
    
    it "should not use the native cum_prod" do
      lambda{@a._jes_cum_prod}.should_not raise_error
    end
    
    it "should not use the native cum_max" do
      lambda{@a._jes_cum_max}.should_not raise_error
    end
    
    it "should not use the native cum_min" do
      lambda{@a._jes_cum_min}.should_not raise_error
    end
    
    it "should not use the native product" do
      lambda{@a._jes_product}.should_not raise_error
    end
    
    it "should not use the native to_pairs" do
      lambda{@a._jes_to_pairs(@b) {|a, b| a}}.should_not raise_error
    end
    
    it "should not use the native tanimoto_pairs" do
      lambda{@a._jes_tanimoto_pairs(@b)}.should_not raise_error
    end
    
    it "should not use the native union" do
      lambda{@a._jes_union(@b)}.should_not raise_error
    end
    
    it "should not use the native intersect" do
      lambda{@a._jes_intersect(@b)}.should_not raise_error
    end
    
    it "should not use the native compliment" do
      lambda{@a._jes_compliment(@b)}.should_not raise_error
    end
    
    it "should not use the native exclusive_not" do
      lambda{@a._jes_exclusive_not(@b)}.should_not raise_error
    end
    
    it "should not use the native cartesian_product" do
      lambda{@a._jes_cartesian_product(@b)}.should_not raise_error
    end
    
    it "should not use the native sigma_pairs" do
      lambda{@a._jes_sigma_pairs(@b) {|a, b| a}}.should_not raise_error
    end
    
    it "should not use the native euclidian_distance" do
      lambda{@a._jes_euclidian_distance(@b)}.should_not raise_error
    end
    
    it "should not use the native rand_in_range" do
      lambda{@a._jes_rand_in_range(1, 2)}.should_not raise_error
    end
    
    it "should not use the native correlation" do
      lambda{@a._jes_correlation(@b)}.should_not raise_error
    end
    
    it "should not use the native yield_transpose" do
      lambda{@a._jes_yield_transpose(@b)}.should_not raise_error
    end
    
    it "should not use the native max_of_lists" do
      lambda{@a._jes_max_of_lists(@b)}.should_not raise_error
    end
    
    it "should not use the native min_of_lists" do
      lambda{@a._jes_min_of_lists(@b)}.should_not raise_error
    end
    
    it "should not use the native covariance" do
      lambda{@a._jes_covariance(@b)}.should_not raise_error
    end
    
    it "should not use the native pearson_correlation" do
      lambda{@a._jes_pearson_correlation(@b)}.should_not raise_error
    end
    
    it "should not use the native to_f!" do
      lambda{@a._jes_to_f!}.should_not raise_error
    end
    
    it "should not use the native scale!" do
      lambda{@a._jes_scale!(1)}.should_not raise_error
    end
    
    it "should not use the native scale_to_sigmoid" do
      lambda{@a._jes_scale_to_sigmoid}.should_not raise_error
    end
    
    it "should not use the native scale_to_sigmoid!" do
      lambda{@a._jes_scale_to_sigmoid!}.should_not raise_error
    end
    
    it "should not use the native normalize" do
      lambda{@a._jes_normalize}.should_not raise_error
    end
    
    it "should not use the native normalize!" do
      lambda{@a._jes_normalize!}.should_not raise_error
    end
    
    it "should not use the native scale_between" do
      lambda{@a._jes_scale_between(6,8)}.should_not raise_error
    end
    
    it "should not use the native scale_between!" do
      lambda{@a._jes_scale_between!(6,8)}.should_not raise_error
    end

    it "should not use the native frequency" do
      lambda{@a._jes_frequency}.should_not raise_error
    end
    
    it "should not use the native frequency_for" do
      lambda{@a._jes_frequency_for(2)}.should_not raise_error
    end
    
  end
  
end
