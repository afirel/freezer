require 'active_record'

class Package < ActiveRecord::Base
  has_many :archives
end
