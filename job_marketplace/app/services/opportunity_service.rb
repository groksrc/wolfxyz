class OpportunityService
  def self.search(params)
    # Create a cache key based on search parameters
    search_term = params[:search].to_s
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    
    cache_key = "opportunities/search/#{search_term}/page/#{page}/per/#{per_page}"
    
    # Try to fetch from cache first
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      opportunities = Opportunity.with_client.order(created_at: :desc)
      
      # Apply search filter if provided
      if params[:search].present?
        opportunities = opportunities.where("title ILIKE ? OR description ILIKE ?", 
                                           "%#{params[:search]}%", 
                                           "%#{params[:search]}%")
      end
      
      # Apply pagination
      page = params[:page] || 1
      per_page = params[:per_page] || 10
      opportunities = opportunities.page(page).per(per_page)
      
      # Convert to JSON and transform salary from string to number
      opportunities_json = opportunities.as_json(include: { client: { only: [:id, :name, :company] } })
      opportunities_json.each do |opp|
        opp["salary"] = opp["salary"].to_f if opp["salary"]
      end
      
      {
        opportunities: opportunities_json,
        pagination: {
          current_page: opportunities.current_page,
          total_pages: opportunities.total_pages,
          total_count: opportunities.total_count
        }
      }
    end
  end
  
  def self.create(params)
    opportunity = Opportunity.new(params)
    
    if opportunity.save
      { success: true, opportunity: opportunity }
    else
      { success: false, errors: opportunity.errors.full_messages }
    end
  end
  
  def self.apply(opportunity_id, job_seeker_id)
    opportunity = Opportunity.find_by(id: opportunity_id)
    job_seeker = JobSeeker.find_by(id: job_seeker_id)
    
    return { success: false, error: "Opportunity not found" } unless opportunity
    return { success: false, error: "Job seeker not found" } unless job_seeker
    
    # Check for existing application to prevent unique constraint violation
    existing_application = JobApplication.find_by(job_seeker: job_seeker, opportunity: opportunity)
    return { success: false, errors: ["Application already exists"] } if existing_application
    
    application = JobApplication.new(
      job_seeker: job_seeker,
      opportunity: opportunity
    )
    
    if application.save
      # Enqueue background job for sending notification
      ApplicationNotificationJob.perform_async(application.id)
      { success: true, application: application }
    else
      { success: false, errors: application.errors.full_messages }
    end
  end
end