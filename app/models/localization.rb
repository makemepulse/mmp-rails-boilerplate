class Localization < ActiveRecord::Base
  belongs_to :country

  scope :published, -> {  where(published: true)}
  scope :default, -> {  where(is_default: true)}

  after_save :clean_cache

  
  def code_enum
    I18n.available_locales.map(&:to_s)
  end


  private 

    def clean_cache
      Rails.cache.clear("locale_#{self.code}")
    end

end
