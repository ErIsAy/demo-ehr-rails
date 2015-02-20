module ApplicationHelper

  def current_user
    @current_user ||= User.find_by_id(session["user_id"])
    @current_user
  end

  def flash_class(key)
    return 'alert alert-info' if key == 'notice'
    return 'alert alert-success' if key == 'success'
    return 'alert alert-danger' if key == 'error' || key == 'alert'
  end

  def cmm_request_link_for(request)
    params = {
      api_id: Rails.application.secrets.api_id,
      token_id: request.cmm_token,
      remote_user: {
        display_name: 'Johnny Rocket',
        phone_number: '614-555-1212'
      }
    }
    if request.cmm_link
      request.cmm_link
    else
      "https://api.covermymeds.com/requests/#{request.cmm_id}?v=1&#{params.to_query}"
    end
  end

  def pa_request_edit_link(request, title = "View")
    if @_use_custom_ui
      link_to title, pa_request_request_pages_path(request), id: 'edit_pa_request'
    else
      link_to title, patient_prescription_pa_request_path(request.prescription.patient, request.prescription, request), id: 'edit_pa_request'
    end
  end


end
