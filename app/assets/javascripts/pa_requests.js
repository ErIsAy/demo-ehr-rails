$(function () {
  var options = window.config;

  var new_statuses = ["New"];
  var open_statuses = ["Appealed", "PA Request", "Shared", "Shared \\ Accessed Online", "Sent to Plan", "Question Request", "Question Response", "Cancel Request Sent", "Failure"];
  var closed_statuses = ["PA Response", "Provider Cancel", "Expired", "Archived" ];
  var appealed_statuses = ["Appeal Request", "Appeal Response", "Appealed"];
  var all_statuses = new_statuses.concat(open_statuses).concat(closed_statuses).concat(appealed_statuses);

  var dashboard_options = {
    apiId: options.apiId,
    version: 1,
    tokenIds: $('#dashboard').data('tokens'),
    folders: {
      'All':{ workflow_statuses: all_statuses, data: [] },
      'New': { workflow_statuses: new_statuses, data: [] },
      'Open': { workflow_statuses: open_statuses, data: [] },
      'Closed': { workflow_statuses: closed_statuses, data:[]},
      'Appeal': { workflow_statuses: appealed_statuses, data:[]},
    }
  };
  $('#dashboard').dashboard(dashboard_options);

  // drug search for the "new pa" form
  $('#prescription_drug_number').drugSearch(options);

  // if we got here from choosing a patient, the drug will already be filled in
  if ($('#prescription_drug_number').val()) {
    $('#pa_request_form_id').formSearch({
        apiId: options.apiId,
        version: 1,
        drugId: $('#prescription_drug_number').val(),
        state: $('#pa_request_state').val()
      });
  }
  else {
    // when the drug search completes, we activate the formSearch box
    $('#prescription_drug_number').change(function() {
      $('#prescription_drug_name').val($('#prescription_drug_number').select2('data').text);
      $('#pa_request_form_id').formSearch({
        apiId: options.apiId,
        version: 1,
        drugId: $('#prescription_drug_number').val(),
        state: $('#pa_request_state').val()
      });
    });
  }

  $('.date').datepicker();

});
