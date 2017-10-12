# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    if gotcha_valid?
      super
    else
      clean_up_passwords resource
      set_minimum_password_length
      flash[:notice] = 'Invalid Captcha'
      respond_with resource
    end
  end
end
