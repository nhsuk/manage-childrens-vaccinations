require "rails_helper"

RSpec.describe ConsentRemindersJob, type: :job do
  before { ActiveJob::Base.queue_adapter.enqueued_jobs.clear }

  context "with draft and active sessions" do
    it "enqueues ConsentRemindersSessionBatchJob for each active sessions" do
      active_session =
        create(:session, draft: false, send_reminders_at: Time.zone.today)
      _draft_session = create(:session, draft: true)

      described_class.perform_now
      expect(ConsentRemindersSessionBatchJob).to have_been_enqueued.once
      expect(ConsentRemindersSessionBatchJob).to have_been_enqueued.with(
        active_session
      )
    end
  end

  context "with sessions set to send consent today and in the future" do
    it "enqueues ConsentRemindersSessionBatchJob for the session set to send consent today" do
      active_session =
        create(:session, draft: false, send_reminders_at: Time.zone.today)
      _later_session =
        create(:session, draft: false, send_reminders_at: 2.days.from_now)

      described_class.perform_now
      expect(ConsentRemindersSessionBatchJob).to have_been_enqueued.once
      expect(ConsentRemindersSessionBatchJob).to have_been_enqueued.with(
        active_session
      )
    end
  end
end
