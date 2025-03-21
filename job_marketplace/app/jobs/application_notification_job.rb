class ApplicationNotificationJob < ApplicationJob
  queue_as :default
  
  def self.perform_async(job_application_id)
    perform_later(job_application_id)
  end

  def perform(job_application_id)
    job_application = JobApplication.find_by(id: job_application_id)
    return unless job_application
    
    # Get the associated models
    opportunity = job_application.opportunity
    job_seeker = job_application.job_seeker
    client = opportunity.client
    
    # Here we would normally send an email notification
    # This is a placeholder for the actual email sending logic
    Rails.logger.info "====== APPLICATION NOTIFICATION ======="
    Rails.logger.info "Application received for: #{opportunity.title}"
    Rails.logger.info "From job seeker: #{job_seeker.name} (#{job_seeker.email})"
    Rails.logger.info "To client: #{client.name} at #{client.company} (#{client.email})"
    Rails.logger.info "Status: #{job_application.status}"
    Rails.logger.info "======================================="
    
    # In a real application, we would use ActionMailer to send emails:
    # ClientMailer.with(job_application: job_application).new_application_email.deliver_now
    # JobSeekerMailer.with(job_application: job_application).application_confirmation_email.deliver_now
  end
end
