# Because the standard Range isn't robust enough to handle floating
# point ranges correctly. 
class FixedRange
  include Enumerable
  
  attr_reader :step_size, :max, :min
  def initialize(min, max, step_size=1)
    @step_size = step_size
    if (min <=> max) < 0
      @min = min
      @max = max
    else
      @min = max
      @max = min
    end
  end
  
  def size
    @size ||= calc_size
  end
  
  def step(enn=self.step_size, &block)
    calc_size(enn).to_i.times do |i|
      block.call(step_value(i, enn))
    end
  end
  
  def each(&block)
    step(&block)
  end
  
  def step_value(index, step_size=self.step_size)
    index = size.to_i + index if index < 0
    val = (index * step_size) + self.min
    raise ArgumentError, "You have supplied an index and/or step_size that is outside of the range" if
      val < self.min or val > self.max
    return val
  end
  alias :[] :step_value
  
  protected
    def calc_size(step_size=self.step_size)
      ((self.max - self.min) / step_size) + 1.0
    end

end
