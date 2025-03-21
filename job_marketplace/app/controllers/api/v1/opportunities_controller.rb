class Api::V1::OpportunitiesController < ApplicationController
  # GET /api/v1/opportunities
  def index
    result = OpportunityService.search(params)
    render json: result
  end

  # POST /api/v1/opportunities
  def create
    result = OpportunityService.create(opportunity_params)
    
    if result[:success]
      render json: result[:opportunity], status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end
  
  # POST /api/v1/opportunities/:id/apply
  def apply
    result = OpportunityService.apply(params[:id], params[:job_seeker_id])
    
    if result[:success]
      render json: result[:application], status: :created
    else
      if result[:error] && result[:error].include?("not found")
        render json: { error: result[:error] }, status: :not_found
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    end
  end
  
  private
  
  def opportunity_params
    params.require(:opportunity).permit(:title, :description, :salary, :client_id)
  end
end
