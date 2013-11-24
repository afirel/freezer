require 'forwardable'
require 'log4r'
include Log4r

module Logging
  extend Forwardable

  @@log = Logger.new 'logger'
  @@log.outputters = Outputter.stdout
  @@log.level = Log4r::INFO

  def method_missing(meth, *args, &block)
    if [:debug, :info, :warn, :error].include?(meth)
      @@log.send(meth, *args)
    else
      super
    end
  end

end
