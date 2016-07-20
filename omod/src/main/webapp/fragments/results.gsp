<script>
    var radiologyResultsListTable, radiologyResultsListDataTable;
    var resultsListData
    jq(function () {
        radiologyResultsListTable = jq('#radiology-results-table');
		resultsListData = new ResultsListData();
        initializeResultsListDataTable();
		getResultsData(false);



        //Attach events to the Filter inputs
        jq('#results-order-date-display, #results-investigation').change(function () {
            getResultsData();
        });

        jq("#results-phrase").on("keyup", function () {
            var searchPhrase = jq(this).val();
            radiologyResultsListDataTable.search(searchPhrase).draw();
        });


        ko.applyBindings(resultsListData, jq("#radiology-results")[0]);
    });//end of doc ready

    function ResultsListData() {
        self = this;
        self.resultsListItems = ko.observableArray([]);
    }

    function getResultsData(showNotification) {
        if (typeof showNotification == 'undefined') {
            showNotification = true;
        }

        var orderedDate = jq("#results-order-date-field").val();
        var phrase = jq("#results-phrase").val();
        var investigation = jq("#results-investigation").val();
        jq.getJSON('${ui.actionLink("radiologyapp", "results", "searchResultsList")}', {
            "orderedDate": moment(orderedDate).format('DD/MM/YYYY'),
            "phrase": phrase,
            "investigation": investigation,
        }).success(function (worklist) {
            console.log(worklist);
            destroyResultslistDataTable();

            if (worklist.data.length === 0) {
                if (showNotification) {
                    jq().toastmessage('showNoticeToast', "No match found!");
                }
                resultsListData.resultsListItems([]);
            } else {
                resultsListData.resultsListItems(worklist.data);
            }

            initializeResultsListDataTable(jq('#results-phrase').val());
        });
    }

    function initializeResultsListDataTable(phrase) {
        if (typeof phrase == 'undefined') {
            phrase = '';
        }

        radiologyResultsListDataTable = radiologyResultsListTable.DataTable({
            responsive: true,
            searching: true,
            lengthChange: false,
            pageLength: 15,
            jQueryUI: true,
            pagingType: 'full_numbers',
            sort: false,
            dom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
            language: {
                zeroRecords: 'No tests in Result list.',
                paginate: {
                    first: 'First',
                    previous: 'Previous',
                    next: 'Next',
                    last: 'Last'
                }
            }
        }).search(phrase).draw();
    }

    function destroyResultslistDataTable() {
        radiologyResultsListDataTable.clear();
        radiologyResultsListDataTable.destroy();
    }

    function showEditResultForm(testDetail) {
        resultDetails.details(testDetail);
        orderIdd = testDetail.orderId;
        testId = testDetail.testId;
        isXray = testDetail.xray;
        jq("#testId").val(testId);
        jq("#isXray").val(isXray);
        resultsDialog.show();
    }

    function loadPatientReport(patientId,testId) {
        window.location = emr.pageLink("radiologyapp", "patientReport", {patientId: patientId, testId: testId});
    }

</script>

<div class="fieldset">
    <i class="icon-filter"
       style="color: rgb(91, 87, 166); float: left; font-size: 56px ! important; padding: 0px 10px 0px 0px;"></i>

    <div>
        <label for="results-order-date-display">Date Ordered</label><br/>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'results-order-date', label: 'Date Ordered', formFieldName: 'orderedDate', useTime: false, defaultToday: true])}
    </div>

    <div style="margin-right: 30px; width: 42%;">
        <label for="results-phrase">Filter Patient</label><br/>
        <input id="results-phrase" type="text" placeholder="Enter Criteria to Filter"
               style="width: 100%; padding-left: 30px;"/>
        <i class="icon-search small"
           style="color: rgb(242, 101, 34); float: right; position: relative; margin-top: -32px; margin-right: 92.5%;"></i>
    </div>

    <div>
        <label for="results-investigation">Investigation</label><br/>
        <select name="investigation" id="results-investigation" style="width: 200px">
            <option value="0">ALL</option>
            <% investigations.each { investigation -> %>
            <option value="${investigation.id}">${investigation.name.name}</option>
            <% } %>
        </select>
    </div>
</div>

<div id="radiology-results" style="display: block; margin-top: 3px;">
    <table id="radiology-results-table">
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

        <tbody data-bind="foreach: resultsListItems">
        <tr style="font-size: 14px;">
            <td data-bind="text: \$index() + 1"></td>
            <td data-bind="text: startDate"></td>
            <td data-bind="text: patientIdentifier"></td>
            <td data-bind="text: patientName"></td>
            <td data-bind="text: gender"></td>
            <td data-bind="text: age"></td>
            <td data-bind="text: testName"></td>
            <td>
                <a title="Edit Results" data-bind="click: showEditResultForm, attr: { href : '#' }"><i
                        class="icon-file-alt small"></i></a>
                <a title="View Report" data-bind="attr: { href : 'javascript:loadPatientReport(' + orderId + ', ' + testId + ')' }"><i
                        class="icon-bar-chart small"></i></a>
            </td>
        </tr>
        </tbody>
    </table>

</div>
