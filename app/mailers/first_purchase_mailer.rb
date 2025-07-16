class FirstPurchaseMailer < ApplicationMailer
  def first_purchase_notification(purchase)
    @purchase = purchase
    @product = purchase.product
    @customer = purchase.customer
    @product_creator = @product.created_by
  
    admin_users = User.joins(:role).where(roles: { name: 'admin' })

    to_email = @product_creator.email
    cc_emails = admin_users.where.not(id: @product_creator.id).pluck(:email)
    
    mail(
      to: to_email,
      cc: cc_emails,
      subject: "First purchase of #{@product.name}!"
    )
  end
end
