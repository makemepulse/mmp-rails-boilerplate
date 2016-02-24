require Rails.root.join('lib', 'rails_admin/dashboard.rb')
require Rails.root.join('lib', 'rails_admin/publish.rb')
RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user_admin
  end
  config.current_user_method(&:current_user_admin)

  ## == Cancan ==
  config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    edit
    delete

    publish
  end

  config.model Country do
    navigation_label "Configuration"
    label "Country"
  end

  config.model Localization do
    label "Locale"
    navigation_label 'Configuration'
    field :country
    field :name
    field :code
    field :is_default do
      label "Default locale for country"
    end
  end

  config.model UserAdmin do
    label "Backoffice Users"
    navigation_label 'Users'

    exclude_fields :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip
  end

end
