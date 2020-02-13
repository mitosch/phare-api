# frozen_string_literal: true

# Extending Enumerable with arithmetic mean, sample variance and
# standard deviation
module Enumerable
  def mean
    sum / length.to_f
  end

  def sample_variance
    m = mean
    sum = inject(0.0) { |accum, i| accum + (i - m)**2 }
    sum / (length - 1).to_f
  end

  def standard_deviation
    Math.sqrt(sample_variance)
  end
end
