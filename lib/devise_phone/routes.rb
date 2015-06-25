module ActionDispatch::Routing
  class Mapper
    
    protected
      def devise_phone_verification(mapping, controllers)
        resource :phone_verification, :only => [:new, :create], :path => mapping.path_names[:phone_verification], :controller => controllers[:phone_verifications] do
          post :verify_code, :path => mapping.path_names[:verify_code], :as => :verify_code
          get :send_code, :path => mapping.path_names[:send_code], :as => :send_code
        end
      end

  end
end