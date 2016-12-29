module MailHelper

  def notify_nitrate(physical_object)
    msg = "A physical object was marked as having a Nitrate base by #{physical_object.modifier.name}.\nBarcode: #{physical_object.iu_barcode}\nTitle: #{physical_object.title.title_text}"
    send_mail('jaalbrec@indiana.edu', 'Physical Object with Nitrate Base', msg)
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