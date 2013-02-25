module Goldencobra
  class SessionsController < Goldencobra::ApplicationController
    layout "application"

    def login
      @errors = []
      if params[:usermodel] && params[:usermodel].constantize && params[:usermodel].constantize.present? && params[:usermodel].constantize.attribute_method?(:email)
        @usermodel = params[:usermodel].constantize.find_by_email(params[:loginmodel][:email])
      end

      if @usermodel.present?
        if ::BCrypt::Password.new(@usermodel.encrypted_password) == "#{params[:loginmodel][:password]}#{Devise.pepper}"
          sign_in @usermodel
          @redirect_to = @usermodel.roles.try(:first).try(:redirect_after_login)
        else
          @errors << "Wrong username or password"
        end
      else
        @errors << "No User found with this email"
      end
    end


    def logout
      if params[:usermodel] && params[:usermodel].constantize && params[:usermodel].constantize.present? && params[:usermodel].constantize.attribute_method?(:email)
        sign_out
        reset_session
      end
      render :js => "location.reload();"
    end

    def register

    end

  end
end