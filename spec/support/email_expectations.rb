module EmailExpectations
  def expect_email_to(to, template, nth = :first)
    email = sent_emails.send(nth)
    expect(email).not_to be_nil
    expect(email.to).to eq [to]
    expect(email[:template_id].value).to eq template
  end

  def sent_emails
    @sent_emails ||=
      begin
        perform_enqueued_jobs

        ActionMailer::Base.deliveries
      end
  end
end
