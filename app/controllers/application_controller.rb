class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_locale
  before_filter :update_last_sign_in_at

  after_filter :store_location

  # Apply strong_parameters filtering before CanCan authorization
  # See https://github.com/ryanb/cancan/issues/571#issuecomment-10753675
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  protected

    def update_last_sign_in_at
      if user_signed_in? && !session[:logged_signin]
        sign_in(current_user, :force => true)
        session[:logged_signin] = true
      end
    end

  private

    def set_locale
      if params[:locale].present?
        I18n.locale = params[:locale]
      elsif browser_lang && I18n.available_locales.include?(browser_lang)
        I18n.locale = browser_lang
      else
        I18n.locale = I18n.default_locale
      end

      ActionMailer::Base.default_url_options[:locale] = I18n.locale
      # current_user.locale
      # request.subdomain
      # request.remote_ip
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || current_user
    end

    # store last url for post-login redirect to whatever the user last visited
    def store_location
      unless (request.fullpath =~ /signin/    || \
              request.fullpath =~ /signout/   || \
              request.fullpath == root_path   || \
              request.fullpath =~ /sign_up/   || \
              request.fullpath =~ /password/  || \
              request.xhr?) # don't store ajax calls
        session[:user_return_to] = request.fullpath
      end
    end

    def browser_lang
      if request.env['HTTP_ACCEPT_LANGUAGE'].present?
        request.env['HTTP_ACCEPT_LANGUAGE'][/^[a-z]{2}/].to_sym
      end
    end
end
