# why is autoloading so flaky here?!
# require '/tosca/app/workers/oldweather_ocr/request_ocr'

class Api::V1::NanoWeatherController < ApplicationController
  respond_to :json

  def notifyAggregates()
    begin
      subject_id = params[:subject_id]
      workflow_id = params[:workflow_id]
      csv_data = request.raw_post

      #TODO get subject location once the panoptes-client gem is working
      location ="https://panoptes-uploads.zooniverse.org/staging/subject_location/416134c3-0650-4414-9e05-7ea0c600ee4e.jpeg"

      # ::Toscanini::Workers::OldWeatherOCR::RequestOCR.perform_async subject_id, workflow_id, location, csv_data
      # ::Toscanini::Workers::OldWeatherOCR::RequestOCR.perform_async subject_id, workflow_id, location, csv_data
      OldWeatherOCR::RequestOCR.perform_async subject_id, workflow_id, location, csv_data

      render json: true
    rescue Exception => ex
      logger.error "NanoWeatherController#notifyAggregates failed for subject #{subject_id} and workflow #{workflow_id}: #{ex.to_s}"
      render json: false
    end

  end

  def doThing()
    # respond_with(params) # should work but doesn't when using null_session
    # render json: params
    render json: request.raw_post
  end

end
