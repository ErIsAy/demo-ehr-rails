class CmmCallbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]

  before_action :set_callback, only: [:show]


  # GET /callbacks
  # GET /callbacks.json
  def index
    @callbacks = CmmCallback.all
  end

  # GET /callbacks/1
  # GET /callbacks/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @callback }
    end
  end

  # POST /callbacks.json {JSON body}
  # this is the method that is called directly by CoverMyMeds when a PA is created
  # retrospectively by a pharmacist. This method needs to create a new PA record in
  # the demo system, and respond appropriately, if it can match the PA to a prescription
  # that we created previously.

  # this method is also called whenever the status or a value of a property in the PA
  # changes. In that case, we need to update the PA record in our system with the
  # new values in the callback.
  def create
    # create a callback object to log that we received this callback
    callback = CmmCallback.new content: request_params.to_json

    handler = PaHandler.new(cmm_id: request_params['id'], npi: request_params['prescriber']['npi'], drug_number: request_params['prescription']['drug_id'])

    user = User.find_by_npi(request_params['prescriber']['npi'])
    # see if we have the prescriptions in the EHR
    pa = PaRequest.find_by_cmm_id(request_params['id'])

    case handler.call.status
    when :npi_not_found
      render(status: 410, text: 'NPI not found') and return
    when :prescription_not_found
      create_alert(user, "Your NPI was found, but the prescription didn't match")
      render(status: 404, text: 'prescription not found') and return
    when :new_retrospective
      # couldn't find it in our db, must be a retrospective
      pa = PaRequest.new
      pa.init_from_callback(request_params)
    when :pa_found
      # if we have a record of the PA, delete it if appropriate
      if is_delete_request?(request_params)
        pa.update_attributes(cmm_token: nil)
        create_alert(user, 'A PA was deleted.')
      else
        # if it's not a delete, then it's an update
        pa.update_from_callback(request_params)
        create_alert(user, 'A PA was updated')
      end
    end

    # save our updated PA, and keep track of the callback that spawned it
    pa.save
    callback.pa_request = pa
    pa.cmm_callbacks << callback
    callback.save!

    # send our response back to CMM
    respond_to do |format|
      if pa.save
        format.html { redirect_to pa }
        format.json { render json: pa }
      else
        format.html { render :error }
        format.json { render json: callback }
      end
    end
  end

  private

  def is_delete_request?(callback)
    (callback['events'] || []).any? { |ev| ev['type'] == 'DELETE' }
  end

  def request_params
    params.require(:request)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def callback_params
    params.require(:callback)
  end

  def set_callback
    @callback = CmmCallback.find(params[:id])
  end

  def create_alert(user, message)
    user.alerts.create(message: message)
  end
end
