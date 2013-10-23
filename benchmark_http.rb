require "rubygems" 
require "bundler/setup"
require 'client'
require 'benchmark'
require 'persistent_httparty'

repeat = 90
url = ARGV[0] || 'http://www.google.com'


class Std
  include HTTParty
end

class Phttp
  include HTTParty
  persistent_connection_adapter
end


# warm it up
2.times do
  Std.get(url)
end

p "persistent HTTP calls..."
time = Benchmark.realtime do
  repeat.times do
    Phttp.get(url)
  end
end
p "persistent time was #{time}"

p "standard HTTP calls..."
std_time = Benchmark.realtime do
  repeat.times do
    Std.get(url)
  end
end
p "standard time was #{std_time}"

p "delta total #{"%.3f" % (std_time - time)} per-call #{"%.3f" % ((std_time - time)/repeat)}"
