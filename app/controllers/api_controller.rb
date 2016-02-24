class ApiController < ActionController::Base
  
  respond_to :json

  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  skip_before_filter  :verify_authenticity_token

  # For all responses in this controller, return the CORS access control headers.
  before_filter :cors_preflight_check, :set_locale
  after_filter :cors_set_access_control_headers

  def respond_with(*resources, &block)
    *content = format_message(*resources)
    super *content, &block
  end

  def format_message(*resources)

    # Format status
    options = resources.size == 1 ? {} : resources.extract_options!
    options[:status] = 200 if options[:status].nil?

    response['X-Api-Version']     = current_version.to_s if defined? current_version
    response['X-Api-Environment'] = Rails.env unless Rails.env.production?

    return *resources,
    status: options[:status],
    location: request.original_fullpath

  end

  protected

    def set_locale 

      @country =  Rails.cache.fetch("country_#{params[:country]}") do
        Country.where(name: params[:country]).published.first
      end
#
      if !@country
        render json: {status: 400, error: 'Unknow country'}
      end
#
      @locale =  Rails.cache.fetch("locale_#{params[:locale]}") do
        @country.localization.where(code: params[:locale]).published.first
      end
#
      if !@locale
        render json: {status: 400, error: 'Unknow locale for country'}
      end

      
      I18n.locale = @locale.code || I18n.default_locale

    end

    # For all responses in this controller, return the CORS access control headers.
    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = '*'
      headers['Access-Control-Max-Age'] = "1728000"
    end

    # If this is a preflight OPTIONS request, then short-circuit the
    # request, return only the necessary headers and return an empty
    # text/plain.

    def cors_preflight_check
      if request.method == :options
        headers['Access-Control-Max-Age'] = '1728000'
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
        render :text => '', :content_type => 'text/plain'
      end
    end

end