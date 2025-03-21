require 'rails_helper'

RSpec.describe ApplicationNotificationJob, type: :job do
  describe "#perform" do
    let(:client) { create(:client) }
    let(:opportunity) { create(:opportunity, client: client) }
    let(:job_seeker) { create(:job_seeker) }
    let(:job_application) { create(:job_application, opportunity: opportunity, job_seeker: job_seeker) }
    
    it "processes a valid job application" do
      expect(Rails.logger).to receive(:info).at_least(1).times
      
      ApplicationNotificationJob.new.perform(job_application.id)
    end
    
    it "does nothing for an invalid job application ID" do
      expect(Rails.logger).not_to receive(:info)
      
      ApplicationNotificationJob.new.perform(999999)
    end
  end
end