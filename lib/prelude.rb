require 'optparse'
require 'ostruct'
require 'logger'
require 'yaml'

module Kernel
  def log_filter(pattern)
    (@@log_filters ||= []) << pattern
  end

  def log
    @@logger ||= (
      l = Logger.new(STDOUT,'daily')
      l.formatter = proc do |severity, datetime, progname, msg|
        next if progname && (@@log_filters ||= []).count > 0 && @@log_filters.none?{|pat| progname =~ pat}
        "[#{progname || severity}] #{msg}\n"
      end
      l
    )
  end
end

log.level = Logger::WARN

module Enumerable
  def mean
    inject(&:+) / length.to_f
  end
  def sample_variance
    m = mean
    inject(0){|sum,i| sum + (i-m)**2} / (length-1).to_f
  end
  def sigma
    Math.sqrt(sample_variance)
  end
  def stats
    ['min', 'max', 'mean', 'sigma'].map{|key| [key, send(key)]}.to_h
  end
end

class OpenStruct
  def self.new_recursive(hash)
    pairs = hash.map do |key, value|
      new_value = value.is_a?(Hash) ? new_recursive(value) : value
      [key, new_value]
    end
    new(Hash[pairs])
  end
end
