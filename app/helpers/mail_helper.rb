module MailHelper

  def notify_nitrate(physical_object)

  end

  def test
    send_mail('jaalbrec@indiana.edu', "testing automated email", "this is only a test...")
  end

  private
  def send_mail(to_address, email_subject, email_body)
    Mail.deliver do
      from     'jaalbrec@indiana.edu'
      to       to_address
      subject  email_subject
      body     email_body
    end

  end
end