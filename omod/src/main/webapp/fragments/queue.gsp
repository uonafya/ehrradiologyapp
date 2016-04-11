<%
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
    ui.includeJavascript("radiologyapp", "ko-utils.js");
%>
<script>
    jq(function () {
        var queueData = new QueueData();
        var radiologyQueueTable = jq('#radiology-queue-results-table');
        var radiologyQueueDataTable;
        var details = { 'patientName' : 'Patient Name', 'startDate' : 'Start Date', 'testName' : 'Test Name' }; 
        var testDetails = { details : ko.observable(details) };
        var scheduleDate = jq("#reschedule-date-field");
        var orderId = jq("#order");
        rescheduleDialog = emr.setupConfirmationDialog({
            selector: '#reschedule-form',
            actions: {
                confirm: function() {
                    saveQueueSchedule();
                    rescheduleDialog.close();
                },
                cancel: function() {
                    rescheduleDialog.close();
                }
            }
        });
        ko.applyBindings(queueData, jq("#radiology-queue-results")[0]);
        ko.applyBindings(testDetails, jq("#reschedule-form")[0]);

        initializeDataTable();

        jq("#get-ordered-tests").on("click", function () {
            var orderDate = jq("#queue-order-date-field").val();
            var phrase = jq("#queue-phrase").val();
            var investigation = jq("#queue-investigation").val();
            jq.getJSON('${ui.actionLink("radiologyapp", "queue", "searchQueue")}',
              {
                "orderDate": moment(orderDate).format('DD/MM/YYYY'),
                "phrase": phrase,
                "investigation": investigation,
              }
            ).success(function (data) {
                destroyDataTable();
                if (data.length === 0) {
                    jq().toastmessage('showNoticeToast', "No match found!");
                    queueData.tests([]);
                } else {
                    queueData.tests(data);
                }
                refreshDataTable();
            });
        });

        jq('#radiology-queue-results-table').on('click', '.accept-link', function () {
            var orderId = jq(this).data('orderId');
            jq.post('${ui.actionLink("radiologyapp", "queue", "acceptOrder")}',
              { 
                'orderId' : orderId,
              },
              function (data) {
                  if (data.status === "success") {
                      destroyDataTable();
                      var acceptedTest = ko.utils.arrayFirst(queueData.tests(), function(item) {
                          return item.orderId == orderId.val();
                      });
                      queueData.tests.remove(acceptedTest);
                      acceptedTest.status = "accepted";
                      queueData.tests.push(acceptedTest);
                      refreshDataTable();
                  } else if (data.status === "fail") {
                      jq().toastmessage('showErrorToast', data.message);
                  }
              },
              'json'
          );
        })

        jq('#radiology-queue-results-table').on('click', '.reschedule-link', function () {
            var orderId = jq(this).data('orderId');
            jq("#reschedule-form #order").val(orderId);
            var details = ko.utils.arrayFirst(queueData.tests(), function(item) {
                return item.orderId == orderId;
            });
            testDetails.details(details);
            rescheduleDialog.show();
        });


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
            jq.post('${ui.actionLink("radiologyapp", "queue", "rescheduleOrder")}',
                { "orderId" : orderId.val(), "rescheduledDate" : moment(scheduleDate.val()).format('DD/MM/YYYY') },
                function (data) {
                    if (data.status === "fail") {
                        jq().toastmessage('showErrorToast', data.error);
                    } else {
                        jq().toastmessage('showSuccessToast', data.message);
                        var rescheduledTest = ko.utils.arrayFirst(queueData.tests(), function(item) {
                            return item.orderId == orderId.val();
                        });
                        console.log(rescheduledTest);
                        queueData.tests.remove(rescheduledTest);
                    }
                },
                'json'
            );
        }

        function initializeDataTable() {
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
                }
            });
        }
    });
</script>

<div>
    <form>
        <fieldset>
            ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'queue-order-date', label: 'Date Ordered', formFieldName: 'orderDate', useTime: false, defaultToday: true])}
            <label for="queue-phrase">Patient Identifier/Name</label>
            <input id="queue-phrase" type="text"/>
            <label for="queue-investigation">Investigation</label>
            <select name="queue-investigation" id="investigation">
                <option value="0">ALL</option>
                <% investigations.each { investigation -> %>
                <option value="${investigation.id}">${investigation.name.name}</option>
                <% } %>
            </select>
            <br/>
            <input type="button" value="Get patients" id="get-ordered-tests"/>
        </fieldset>
    </form>
</div>

<div id="radiology-queue-results" style="display: block; margin-top:3px;">
    <table id="radiology-queue-results-table">
        <thead>
            <tr>
                <th>Date Ordered</th>
                <th>Identifier</th>
                <th>Patient Name</th>
                <th>Gender</th>
                <th>Age</th>
                <th>Test Name</th>
                <th>Actions</th>
            </tr>
        </thead>

        <tbody data-bind="foreach: tests">
            <tr>
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
        <form>
            <p>
                <div class="dialog-data">Patient Name:</div>
                <div class="inline" data-bind="text: details().patientName"></div>
            </p> 
            
            <p >
                <div class="dialog-data">Test Name:</div>
                <div class="inline" data-bind="text: details().testName"></div>
            </p>
            
            
            <p>
                <div class="dialog-data">Test Date:</div>
                <div class="inline" data-bind="text: details().startDate"></div>
            </p>
            
            <p>
                ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'reschedule-date', label: 'Reschedule To', formFieldName: 'rescheduleDate', useTime: false, defaultToday: true, startToday: true])}
            </p>
                    
            
            <input type="hidden" id="order" name="order" >

            <!-- Allow form submission with keyboard without duplicating the dialog button -->
            <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
        </form>
        
        <span class="button confirm right"> Confirm </span>
        <span class="button cancel"> Cancel </span>
    </div>
</div>
