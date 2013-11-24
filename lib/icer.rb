require 'logging'
require 'glacier_client'
require 'hashing'

module Icer
  extend self
  include Logging
  extend Hashing

  def config_path
    File.join(ENV['HOME'], '.icer')
  end

  def config
    YAML.load(File.read(File.join(config_path, 'icer.yml')))
  end

  def database_url
    config[:journal][:database_url].gsub("~", ENV['HOME'])
  end

  def glacier_client(vault = nil)
    vault = vault || config[:aws][:glacier][:vault]
    aws = config[:aws]
    aws.delete :glacier
    GlacierClient.new(vault, aws)
  end

end
