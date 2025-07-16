class DailyReportMailer < ApplicationMailer
  def daily_report_notification(admin_user, report_data, date)
    @admin_user = admin_user
    @report_data = report_data
    @date = date
    
    mail(
      to: @admin_user.email,
      subject: "Daily Purchase Report - #{@date.strftime('%B %d, %Y')}"
    )
  end
end
