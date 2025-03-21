require 'rails_helper'

RSpec.describe OpportunityService do
  let!(:client) { create(:client) }
  let!(:opportunities) { create_list(:opportunity, 5, client: client) }
  let!(:job_seeker) { create(:job_seeker) }

  describe '.search' do
    it 'returns opportunities with pagination' do
      result = OpportunityService.search({})
      
      expect(result[:opportunities].size).to eq(5)
      expect(result[:pagination][:current_page]).to eq(1)
    end
    
    it 'filters opportunities by search term' do
      create(:opportunity, title: "Ruby Developer", client: client)
      
      result = OpportunityService.search({ search: "Ruby" })
      
      expect(result[:opportunities].size).to eq(1)
      expect(result[:opportunities].first["title"]).to eq("Ruby Developer")
    end
    
    it 'paginates results correctly' do
      result = OpportunityService.search({ page: 1, per_page: 2 })
      
      expect(result[:opportunities].size).to eq(2)
      expect(result[:pagination][:total_pages]).to eq(3)
    end
    
    it 'includes client information' do
      result = OpportunityService.search({})
      
      expect(result[:opportunities].first["client"]).to be_present
      expect(result[:opportunities].first["client"]["name"]).to eq(client.name)
    end
    
    it 'caches results' do
      expect(Rails.cache).to receive(:fetch).and_call_original
      
      OpportunityService.search({})
    end
  end
  
  describe '.create' do
    it 'creates a new opportunity' do
      params = {
        title: "New Opportunity",
        description: "New description",
        salary: 95000.00,
        client_id: client.id
      }
      
      result = OpportunityService.create(params)
      
      expect(result[:success]).to be true
      expect(result[:opportunity].title).to eq("New Opportunity")
    end
    
    it 'returns errors for invalid attributes' do
      params = {
        title: "",
        description: "Invalid",
        salary: -1000,
        client_id: client.id
      }
      
      result = OpportunityService.create(params)
      
      expect(result[:success]).to be false
      expect(result[:errors]).to be_present
    end
  end
  
  describe '.apply' do
    let(:opportunity) { opportunities.first }
    
    it 'creates a job application' do
      result = OpportunityService.apply(opportunity.id, job_seeker.id)
      
      expect(result[:success]).to be true
      expect(result[:application]).to be_present
      expect(result[:application].job_seeker).to eq(job_seeker)
      expect(result[:application].opportunity).to eq(opportunity)
    end
    
    it 'returns error for non-existent opportunity' do
      result = OpportunityService.apply(9999, job_seeker.id)
      
      expect(result[:success]).to be false
      expect(result[:error]).to include("Opportunity not found")
    end
    
    it 'returns error for non-existent job seeker' do
      result = OpportunityService.apply(opportunity.id, 9999)
      
      expect(result[:success]).to be false
      expect(result[:error]).to include("Job seeker not found")
    end
    
    it 'returns errors for duplicate application' do
      create(:job_application, job_seeker: job_seeker, opportunity: opportunity)
      
      result = OpportunityService.apply(opportunity.id, job_seeker.id)
      
      expect(result[:success]).to be false
      expect(result[:errors]).to be_present
    end
    
    it 'enqueues a notification job' do
      expect(ApplicationNotificationJob).to receive(:perform_async)
      
      OpportunityService.apply(opportunity.id, job_seeker.id)
    end
  end
end