$:.unshift File.join(__dir__, "lib")

require 'rubygems'
require 'bundler/setup'
require 'logging'
require 'active_record'

require 'icer'
ENV['DATABASE_URL'] = Icer.database_url

require 'standalone_migrations'
StandaloneMigrations::Tasks.load_tasks

class StandaloneMigrations::Configurator
  def config_for(env=nil)
    ENV['DATABASE_URL']
  end
end
