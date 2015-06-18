module DeviseInvitable
  class Engine < ::Rails::Engine

    ActiveSupport.on_load(:action_controller) { include DevisePhone::Controllers::UrlHelpers }
    ActiveSupport.on_load(:action_view)       { include DevisePhone::Controllers::UrlHelpers }

    config.after_initialize do
    
    end

  end
end
