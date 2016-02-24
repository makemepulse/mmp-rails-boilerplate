require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminPublish
end
 
module RailsAdmin
  module Config
    module Actions
      class Publish < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :visible? do
        authorized? && bindings[:object].respond_to?(:published)
    end

    register_instance_option :member? do
      true
    end

    register_instance_option :link_icon do
      if bindings[:object].published
        'icon-minus-sign'
      else
        'icon-ok-sign'
      end
    end

    register_instance_option :controller do
      Proc.new do

            @object.update_attribute(:published, !@object.published)

        flash[:notice] = "This item is published"
     
        redirect_to back_or_index
      end
    end

      end
    end
  end
end