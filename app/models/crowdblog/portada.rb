module Crowdblog
  class Portada < ActiveRecord::Base
    attr_accessible :breaking_news, :publication
    has_many :home_sections
    accepts_nested_attributes_for :home_sections, allow_destroy: true
  end
end
