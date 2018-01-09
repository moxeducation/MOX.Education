class NotificationsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.ready_for_approve.subject
  #
  def ready_for_approve user, product
    @user = user
    @product = product

    mail to: User.admins.notificable.pluck(:email), subject: "Product is ready for approve" do |format|
      format.html
    end
  end
end
