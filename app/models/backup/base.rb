module Backup
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :backup
  end
end