# frozen_string_literal: true

# User Welcome Email
class UserNotifier < ApplicationMailer
  helper UserNotifierHelper

  default from: 'EndBiasWiki@gmail.com'

  def welcome_email(user:)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EndBiasWiki')
  end
end
