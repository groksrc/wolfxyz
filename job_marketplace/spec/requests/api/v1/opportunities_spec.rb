require 'rails_helper'
require 'swagger_helper'

RSpec.describe "Api::V1::Opportunities", type: :request do
  let!(:client) { create(:client) }
  let!(:opportunities) { create_list(:opportunity, 5, client: client) }
  let!(:job_seeker) { create(:job_seeker) }

  describe "GET /api/v1/opportunities" do
    before { get "/api/v1/opportunities" }

    it "returns HTTP success" do
      expect(response).to have_http_status(:success)
    end

    it "returns all opportunities" do
      json = JSON.parse(response.body)
      expect(json["opportunities"].size).to eq(5)
    end

    it "includes pagination information" do
      json = JSON.parse(response.body)
      expect(json["pagination"]).to be_present
      expect(json["pagination"]["current_page"]).to eq(1)
    end

    context "with search parameter" do
      before { get "/api/v1/opportunities", params: { search: "Test" } }

      it "returns filtered opportunities" do
        json = JSON.parse(response.body)
        expect(json["opportunities"].size).to be > 0
      end
    end

    context "with pagination parameters" do
      before { get "/api/v1/opportunities", params: { page: 1, per_page: 2 } }

      it "returns correct number of opportunities" do
        json = JSON.parse(response.body)
        expect(json["opportunities"].size).to eq(2)
      end
    end
  end

  describe "POST /api/v1/opportunities" do
    let(:valid_attributes) do
      {
        opportunity: {
          title: "New Job Opportunity",
          description: "This is a new job opportunity",
          salary: 95000.00,
          client_id: client.id
        }
      }
    end

    context "with valid parameters" do
      before { post "/api/v1/opportunities", params: valid_attributes }

      it "creates a new opportunity" do
        expect(response).to have_http_status(:created)
      end

      it "returns the created opportunity" do
        json = JSON.parse(response.body)
        expect(json["title"]).to eq("New Job Opportunity")
      end
    end

    context "with invalid parameters" do
      before do
        post "/api/v1/opportunities", params: {
          opportunity: {
            title: "",
            description: "Invalid opportunity",
            salary: -1000,
            client_id: client.id
          }
        }
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "POST /api/v1/opportunities/:id/apply" do
    let(:opportunity) { opportunities.first }

    context "with valid parameters" do
      before do
        post "/api/v1/opportunities/#{opportunity.id}/apply", params: {
          job_seeker_id: job_seeker.id
        }
      end

      it "creates a new job application" do
        expect(response).to have_http_status(:created)
      end

      it "returns the created application" do
        json = JSON.parse(response.body)
        expect(json["job_seeker_id"]).to eq(job_seeker.id)
        expect(json["opportunity_id"]).to eq(opportunity.id)
      end
    end

    context "with invalid job seeker id" do
      before do
        post "/api/v1/opportunities/#{opportunity.id}/apply", params: {
          job_seeker_id: 9999
        }
      end

      it "returns not found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        json = JSON.parse(response.body)
        expect(json["error"]).to include("not found")
      end
    end

    context "with duplicate application" do
      before do
        create(:job_application, job_seeker: job_seeker, opportunity: opportunity)
        post "/api/v1/opportunities/#{opportunity.id}/apply", params: {
          job_seeker_id: job_seeker.id
        }
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  # Removing Swagger docs testing from this file to prevent conflicts
  # Swagger test has been moved to swagger_spec.rb
end
