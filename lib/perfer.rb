require 'yaml'
require 'optparse'
require 'forwardable'
require 'ffi'
require 'epath'
require 'backports/1.9'

Path.require_tree('perfer', :except => %w[platform/])

module Perfer
  DIR = Path('~/.perfer')

  @sessions = []

  class << self
    attr_reader :sessions

    def configuration
      @configuration ||= Configuration.new
    end

    def session(name, &block)
      Session.new(name, Path.file(caller), &block).tap { |session|
        @sessions << session
      }
    end

    def measure
      times_before = Process.times
      realtime_before = Time.now
      yield
      times = Process.times
      realtime = Time.now

      data = { :real => realtime-realtime_before }
      times.members.each { |field|
        # precision of times(3) or getrusage(2) is no more than 1e-6
        value = (times[field] - times_before[field]).round(6)
        if value != 0.0 # do not keep these if they measured nothing
          data[field.to_sym] = value
        end
      }
      data
    end
  end
end
