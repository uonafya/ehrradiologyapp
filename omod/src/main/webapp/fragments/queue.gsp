<%
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
    ui.includeJavascript("radiologyapp", "ko-utils.js");
%>
<script>
var queueData;
    jq(function () {
        queueData = new QueueData();
        var radiologyQueueTable = jq('#radiology-queue-results-table');
        var radiologyQueueDataTable;
        ko.applyBindings(queueData, jq("#radiology-queue-results")[0]);

        initializeDataTable();

        jq("#get-ordered-tests").on("click", function () {
            var orderDate = jq("#order-date-field").val();
            var phrase = jq("#phrase").val();
            var investigation = jq("#investigation").val();
            jq.getJSON('${ui.actionLink("radiologyapp", "Queue", "searchQueue")}',
              {
                "orderDate": moment(orderDate).format('DD/MM/YYYY'),
                "phrase": phrase,
                "investigation": investigation,
              }
            ).success(function (data) {
                radiologyQueueDataTable.clear();
                radiologyQueueDataTable.destroy();
                if (data.length === 0) {
                    jq().toastmessage('showNoticeToast', "No match found!");
                    queueData.tests([]);
                } else {
                    queueData.tests(data);
                }
                initializeDataTable();
            });
        });


        function QueueData() {
            self = this;
            self.tests = ko.observableArray([]);
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
            ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'order-date', label: 'Date Ordered', formFieldName: 'orderDate', useTime: false, defaultToday: true])}
            <label for="phrase">Patient Identifier/Name</label>
            <input id="phrase" type="text"/>
            <label for="investigation">Investigation</label>
            <select name="investigation" id="investigation">
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
                            <a title="Accept" data-bind="attr: { href: 'javascript:accept(' + orderId + ')' }" ><i class="icon-ok small"></i></a>
                        </span>

                        <span data-bind="ifnot: status"> 
                            <a title="Reschedule" data-bind="attr: { href : 'javascript:reschedule(' + orderId + ')' }"><i class="icon-repeat small"></i></a>
                        </span>
                    </center>
                </td>
            </tr>
        </tbody>
    </table>
</div>
