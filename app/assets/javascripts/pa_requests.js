$(function () {
  var options = window.config;

  var new_statuses = ["New"];
  var open_statuses = ["Appealed", "PA Request", "Shared", "Shared \\ Accessed Online", "Sent to Plan", "Question Request", "Question Response", "Cancel Request Sent", "Failure"];
  var closed_statuses = ["PA Response", "Provider Cancel", "Expired", "Archived" ];
  var appealed_statuses = ["Appeal Request", "Appeal Response", "Appealed"];
  var all_statuses = new_statuses.concat(open_statuses).concat(closed_statuses).concat(appealed_statuses);

  var dashboard_options = {
    apiId: options.apiId,
    apiUrl: options.apiUrl,
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

  $("#prescription_drug_name").autocomplete({
    source: '/drugs',
    select: function(e, selected) {
      $("#prescription_drug_number").val(selected.item.id);
      $("#prescription_drug_name").val(selected.item.full_name);
      return false;
    },
    change: function(e, ui) { 
      enable_form_pick($("#prescription_drug_number").val(),
        $("#pa_request_state").val());
    }
  }).autocomplete("instance")._renderItem = function(ul, item) {
    return $("<li>").append(item.full_name).appendTo(ul);
  };

  function enable_form_pick(drug_id, state) {
    $("#form_name").autocomplete({
      source: function(request, response) {
        $.get("/forms?"+
          "drug_id="+$("#prescription_drug_number").val()+
          "&state="+$("#pa_request_state").val()+
          "&term="+request.term, 
          function(data, status){
            response(data);
          })
      },
      select: function(e, selected) {
        $("#pa_request_form_id").val(selected.item.id);
        $("#form_name").val(selected.item.description);
        return false;
      },
      change: function(e, ui) { 
        if(document.URL.indexOf('prescription') != -1) {
          check_pa_required(ui.val());
        }
      }
    }).autocomplete("instance")._renderItem = function(ul, item) {
      return $("<li>").append(item.description).appendTo(ul);
    };
  }

  // else {
  //   // when the drug search completes, we activate the formSearch box
  //   $('#prescription_drug_number').change(function() {
  //     $('#prescription_drug_name').val($('#prescription_drug_number').select2('data').text);
  //     $('#pa_request_form_id').formSearch({
  //       apiId: options.apiId,
  //       apiUrl: options.apiUrl,
  //       version: 1,
  //       drugId: $('#prescription_drug_number').val(),
  //       state: $('#pa_request_state').val()
  //     });
  //   });
  // }

  $('.date').datepicker();

});
