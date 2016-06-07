<%
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
    ui.includeJavascript("radiologyapp", "ko-utils.js");
%>
<script>
	var queueData = new QueueData();
	var radiologyQueueTable;
	var radiologyQueueDataTable;
	var details = { 'patientName' : 'Patient Name', 'startDate' : 'Start Date', 'testName' : 'Test Name' }; 
	var scheduleDate;
	var orderId;
	
    jq(function () {
		orderId = jq("#order");
		scheduleDate = jq("#reschedule-date-field");
		radiologyQueueTable = jq('#radiology-queue-results-table');
		var testDetails = { details : ko.observable(details) };
		
        var rescheduleDialog = emr.setupConfirmationDialog({
			dialogOpts: {
				overlayClose: false,
				close: true
			},
            selector: '#reschedule-form',
            actions: {
                confirm: function() {
                    saveQueueSchedule();
					jq.post('${ui.actionLink("radiologyapp", "queue", "rescheduleOrder")}', { 
						"orderId" : orderId.val(), 
						"rescheduledDate" : moment(scheduleDate.val()).format('DD/MM/YYYY') },
						function (data) {
							if (data.status === "fail") {
								jq().toastmessage('showErrorToast', data.error);
							} else {
								jq().toastmessage('showSuccessToast', data.message);
								getQueueData();
								rescheduleDialog.close();
							}
						},
						'json'
					);
                },
                cancel: function() {
                    rescheduleDialog.close();
                }
            }
        });
		
        ko.applyBindings(queueData, jq("#radiology-queue-results")[0]);
        ko.applyBindings(testDetails, jq("#reschedule-form")[0]);

        initializeDataTable();
		getQueueData(false);
		
		jq('#queue-order-date-display, #investigation').change(function(){
			getQueueData();
		});
		
		jq("#queue-phrase").on("keyup", function(){
			var searchPhrase = jq(this).val();
			radiologyQueueDataTable.search(searchPhrase).draw();
		});

        jq('#radiology-queue-results-table').on('click', '.accept-link', function () {
            var orderId = jq(this).data('orderId');
            jq.post('${ui.actionLink("radiologyapp", "queue", "acceptOrder")}', {
                'orderId' : orderId,
            },
            function (data) {
                  if (data.status === "success") {
                      getQueueData();
                  } else if (data.status === "fail") {
                      jq().toastmessage('showErrorToast', data.message);
                  }
            },
            'json'
          );
        });

        jq('#radiology-queue-results-table').on('click', '.reschedule-link', function () {
            var orderId = jq(this).data('orderId');
            jq("#reschedule-form #order").val(orderId);
            var details = ko.utils.arrayFirst(queueData.tests(), function(item) {
                return item.orderId == orderId;
            });
            testDetails.details(details);
            rescheduleDialog.show();
        });		
    }); //function End of Doc Ready
	
	function getQueueData(showNotification){
		if (typeof showNotification == 'undefined'){
			showNotification = true;
		}
		
		var orderDate = jq("#queue-order-date-field").val();
		var investigation = jq("#investigation").val();
		
		jq.getJSON('${ui.actionLink("radiologyapp", "queue", "searchQueue")}',{
			"orderDate": moment(orderDate).format('DD/MM/YYYY'),
			"phrase": '',
			"investigation": investigation,
		}).success(function (data) {
			destroyDataTable();
			if (data.length === 0) {
				queueData.tests([]);
				if (showNotification){
					jq().toastmessage('showErrorToast', "No Records found!");
				}
			} else {
				queueData.tests(data);
			}
			
			initializeDataTable(jq('#queue-phrase').val());
		});
	}

	function QueueData() {
		self = this;
		self.tests = ko.observableArray([]);
	}

	function destroyDataTable() {
		radiologyQueueDataTable.clear();
		radiologyQueueDataTable.destroy();
	}

	function refreshDataTable() {
		initializeDataTable();
	}

	function saveQueueSchedule() {
		
	}

	function initializeDataTable(phrase) {
		if (typeof phrase == 'undefined'){
			phrase = '';
		}
		
		radiologyQueueDataTable = radiologyQueueTable.DataTable({
			searching: true,
			lengthChange: false,
			pageLength: 15,
			jQueryUI: true,
			pagingType: 'full_numbers',
			sort: false,
			dom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			language: {
				zeroRecords: 'No investigations ordered.',
				paginate: {
					first: 'First',
					previous: 'Previous',
					next: 'Next',
					last: 'Last'
				}
			},
			
		}).search(phrase).draw();
		
	}
</script>


<div class="fieldset">
	<i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 56px ! important; padding: 0px 10px 0px 0px;"></i>
	<div>
		<label for="queue-order-date-display"> Date Ordered </label><br/>
		${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'queue-order-date', label: 'Date Ordered', formFieldName: 'orderDate', useTime: false, defaultToday: true])}	
	</div>
	
	<div style="margin-right: 30px; width: 42%;">
		<label for="queue-phrase">Filter Patient</label><br/>
		<input id="queue-phrase" type="text" placeholder="Enter Criteria to Filter" style="width: 100%; padding-left: 30px;"/>
		<i class="icon-search small" style="color: rgb(242, 101, 34); float: right; position: relative; margin-top: -32px; margin-right: 92.5%;"></i>
	</div>
	
	<div>
		<label for="investigation">Investigation</label><br/>
		<select name="queue-investigation" id="investigation" style="width: 200px">
			<option value="0">ALL</option>
			<% investigations.each { investigation -> %>
			<option value="${investigation.id}">${investigation.name.name}</option>
			<% } %>
		</select>
	</div>	
</div>    


<div id="radiology-queue-results" style="display: block; margin-top:3px;">
    <table id="radiology-queue-results-table">
        <thead>
            <tr>
                <th>#</th>
                <th>DATE</th>
                <th>IDENTIFIER</th>
                <th>PATIENT</th>
                <th>GENDER</th>
                <th>AGE</th>
                <th>TEST</th>
                <th>ACTIONS</th>
            </tr>
        </thead>

        <tbody data-bind="foreach: tests">
            <tr style="font-size: 14px;">
                <td data-bind="text: \$index() + 1"></td>
                <td data-bind="text: startDate"></td>
                <td data-bind="text: patientIdentifier"></td>
                <td data-bind="text: patientName"></td>
                <td data-bind="text: gender"></td>
                <td data-bind="text: age"></td>
                <td data-bind="text: testName"></td>
                <td>
                    <center id="action-icons">
                        <span data-bind="if: status" class="accepted">Accepted</span>
                        <span data-bind="ifnot: status">
                            <a title="Accept" class="accept-link" data-bind="attr: { 'data-order-id': orderId }" ><i class="icon-ok small"></i></a>
                        </span>

                        <span data-bind="ifnot: status"> 
                            <a title="Reschedule" class="reschedule-link" data-bind="attr: { 'data-order-id' : orderId }"><i class="icon-repeat small"></i></a>
                        </span>
                    </center>
                </td>
            </tr>
        </tbody>
    </table>
</div>

<div id="reschedule-form" title="Reschedule" class="dialog">
    <div class="dialog-header">
      <i class="icon-repeat"></i>
      <h3>Reschedule Tests</h3>
    </div>
    
    <div class="dialog-content">
        <ul>
            <li>
                <label>Patient Name:</label>
				<input type="text" readonly="" size="null" data-bind="value: details().patientName" style="background: #fffdf7"/>
            </li> 
            
            <li>
                <label>Test Name:</label>
				<input type="text" readonly="" size="null" data-bind="value: details().testName" style="background: #fffdf7"/>
            </li>
            
            
            <li>
                <label>Test Date:</label>
				<input type="text" readonly="" size="null" data-bind="value: details().startDate" style="background: #fffdf7"/>
            </li>
            
            <li>
                ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'reschedule-date', label: 'Reschedule To', formFieldName: 'rescheduleDate', useTime: false, defaultToday: true, startToday: true])}
            </li>
                    
            
            <input type="hidden" id="order" name="order" >

            <!-- Allow form submission with keyboard without duplicating the dialog button -->
            <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
        </ul>
        
        <span class="button confirm right" style="margin-right: 0px">Confirm </span>
        <span class="button cancel"> Cancel </span>
    </div>
</div>
