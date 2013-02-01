module Crowdblog
  class SectionPost < ActiveRecord::Base
    attr_accessible :home_section_id, :post_id, :type
    belongs_to :home_section
    belongs_to :post
  end
end
