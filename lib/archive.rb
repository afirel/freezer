require 'active_record'

class Archive < ActiveRecord::Base

  belongs_to :package

end
