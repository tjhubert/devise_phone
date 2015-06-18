module ActionDispatch::Routing
  class Mapper
    
    protected
      def devise_phone_verification(mapping, controllers)
        resource :phone_verification, :only => [:new, :create], :path => mapping.path_names[:phone_verification], :controller => controllers[:phone_verifications] do
          match :consume, :path => mapping.path_names[:consume], :as => :consume
          get :insert, :path => mapping.path_names[:insert], :as => :insert
        end
      end

  end
end