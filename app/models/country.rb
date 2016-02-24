class Country < ActiveRecord::Base

  has_many :localization
  scope :published, -> {  where(published: true)}
  

  after_save :clean_cache

  def name_enum
    IsoCountryCodes.for_select
  end

  private 

    def clean_cache
      Rails.cache.delete_matched(/country_#{self.name}/)
    end
  
end
