class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale
  layout :layout

  private
    def set_locale

      if self.kind_of?(RailsAdmin::ApplicationController) || self.kind_of?(DeviseController)
        I18n.locale = :en
      else

        set_default_country() if !params[:country] || !get_country()

        if !params[:locale] || !get_locale()
          return redirect_to_default_locale()
        end

        I18n.locale = @locale.code || I18n.default_locale

      end

    end

    def layout
      is_a?(Devise::SessionsController) ? false : "application"
    end

    def get_country
      @country =  Rails.cache.fetch("country_#{params[:country]}") do
        Country.where(name: params[:country]).published.first
      end
      return !@country.nil?
    end

    def set_default_country
      params[:country] = "FR"
      get_country()
    end

    def get_locale
      @locale =  Rails.cache.fetch("locale_#{params[:locale]}") do
        @country.localization.where(code: params[:locale]).published.first
      end
      return !@locale.nil?
    end

    def redirect_to_default_locale
      locale = Rails.cache.fetch("country_#{params[:country]}_default_locale") do
        @country.localization.published.default.first || @country.localization.published.first
      end

      if locale
        return redirect_to default_path(:locale => locale.code, :country => params[:country])
      end
    end

end
