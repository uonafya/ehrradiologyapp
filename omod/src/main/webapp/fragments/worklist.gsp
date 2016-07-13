<script>
    var radiologyWorklistTable = jq('#radiology-worklist-table');
    var radiologyWorklistDataTable;
    var worklistData,reorderDialog,reorderForm;
    var orderIdd;
    var details = { 'patientName' : 'Patient Name', 'startDate' : 'Start Date', 'test' : { 'name' : 'Test Name' } };
    var scanDetails = { details : ko.observable(details) }
    jq(function () {
        radiologyWorklistTable = jq('#radiology-worklist-table');
        worklistData = new WorklistData();

        initializeWorklistDataTable();
        getWorklistData(false);

        jq('#worklist-order-date-display, #worklist-investigation').change(function () {
            getWorklistData();
        });

        jq("#worklist-phrase").on("keyup", function () {
            var searchPhrase = jq(this).val();
            radiologyWorklistDataTable.search(searchPhrase).draw();
        });

        function WorklistData() {
            self = this;
            self.worklistItems = ko.observableArray([]);
        }

        reorderDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#reorder-form',
            actions: {
                confirm: function() {
                    saveSchedule();
                    reorderDialog.close();
                },
                cancel: function() {
                    reorderDialog.close();
                }
            }
        });
        reorderForm = jq("#reorder-form").find( "form" ).on( "submit", function( event ) {
            event.preventDefault();
            saveSchedule();
        });
        ko.applyBindings(scanDetails, jq("#reorder-form")[0]);
        ko.applyBindings(worklistData, jq("#radiology-worklist")[0]);
    });//End of Document Ready

    function getWorklistData(showNotification) {
        if (typeof showNotification == 'undefined') {
            showNotification = true;
        }

        var orderedDate = jq("#worklist-order-date-field").val();
        var phrase = jq("#worklist-phrase").val();
        var investigation = jq("#worklist-investigation").val();
        jq.getJSON('${ui.actionLink("radiologyapp", "worklist", "searchWorkList")}', {
            "orderedDate": moment(orderedDate).format('DD/MM/YYYY'),
            "phrase": phrase,
            "investigation": investigation,
        }).success(function (worklist) {
            destroyWorklistDataTable();

            if (worklist.data.length === 0) {
                if (showNotification) {
                    jq().toastmessage('showNoticeToast', "No match found!");
                }
                worklistData.worklistItems([]);
            } else {
                worklistData.worklistItems(worklist.data);
            }

            initializeWorklistDataTable(jq('#worklist-phrase').val());
        });
    }

    function initializeWorklistDataTable(phrase) {
        if (typeof phrase == 'undefined') {
            phrase = '';
        }

        radiologyWorklistDataTable = radiologyWorklistTable.DataTable({
            responsive: true,
            searching: true,
            lengthChange: false,
            pageLength: 15,
            jQueryUI: true,
            pagingType: 'full_numbers',
            sort: false,
            dom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
            language: {
                zeroRecords: 'No tests in worklist.',
                paginate: {
                    first: 'First',
                    previous: 'Previous',
                    next: 'Next',
                    last: 'Last'
                }
            }
        }).search(phrase).draw();
    }

    function destroyWorklistDataTable() {
        radiologyWorklistDataTable.clear();
        radiologyWorklistDataTable.destroy();
    }
    function showResultForm(testDetail) {
        alert("about to edit" + testDetail);
    }

    function reorder(orderId) {
        jq("#reorder-form #order").val(orderId);
        orderIdd = orderId;
        var details = ko.utils.arrayFirst(worklistData.worklistItems(), function(item) {
            return item.orderId == orderId;
        });
        scanDetails.details(details);
        reorderDialog.show();
    }

    function saveSchedule() {
        jq.post('${ui.actionLink("radiologyapp", "queue", "rescheduleOrder")}',
                { "orderId" : orderIdd, "rescheduledDate" : moment(jq("#reorder-date-field").val()).format('DD/MM/YYYY') },
                function (data) {
                    if (data.status === "fail") {
                        jq().toastmessage('showErrorToast', data.error);
                    } else {
                        jq().toastmessage('showSuccessToast', data.message);
                        var reorderedTest = ko.utils.arrayFirst(worklistData.worklistItems(), function(item) {
                            return item.orderId == orderIdd;
                        });
                        worklistData.worklistItems.remove(reorderedTest);
                    }
                },
                'json'
        );
    }

   /* function getResultTemplate(testId) {
        jq.getJSON('${ui.actionLink("radiologyapp", "radResults", "getResultTemp")}',
                {"testId": testId}
        ).success(function (parameterOptions) {
                    parameterOpts.parameterOptions.removeAll();
                    var details = ko.utils.arrayFirst(workList.items(), function (item) {
                        return item.testId == testId;
                    });
                    jq.each(parameterOptions, function (index, parameterOption) {
                        parameterOption['patientName'] = details.patientName;
                        parameterOption['testName'] = details.test.name;
                        parameterOption['startDate'] = details.startDate;
                        parameterOpts.parameterOptions.push(parameterOption);
                    });
                });
    }*/
</script>

<div class="fieldset">
    <i class="icon-filter"
       style="color: rgb(91, 87, 166); float: left; font-size: 56px ! important; padding: 0px 10px 0px 0px;"></i>

    <div>
        <label for="worklist-order-date-display">Date Ordered</label><br/>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'worklist-order-date', label: 'Date Ordered', formFieldName: 'orderedDate', useTime: false, defaultToday: true])}
    </div>

    <div style="margin-right: 30px; width: 42%;">
        <label for="worklist-phrase">Filter Patient</label><br/>
        <input id="worklist-phrase" type="text" placeholder="Enter Criteria to Filter"
               style="width: 100%; padding-left: 30px;"/>
        <i class="icon-search small"
           style="color: rgb(242, 101, 34); float: right; position: relative; margin-top: -32px; margin-right: 92.5%;"></i>
    </div>

    <div>
        <label for="worklist-investigation">Investigation</label><br/>
        <select name="investigation" id="worklist-investigation" style="width: 200px">
            <option value="0">ALL</option>
            <% investigations.each { investigation -> %>
            <option value="${investigation.id}">${investigation.name.name}</option>
            <% } %>
        </select>
    </div>
</div>

<div id="radiology-worklist" style="display: block; margin-top: 3px;">
    <table id="radiology-worklist-table">
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

        <tbody data-bind="foreach: worklistItems">
        <tr style="font-size: 14px;">
            <td data-bind="text: \$index() + 1"></td>
            <td data-bind="text: startDate"></td>
            <td data-bind="text: patientIdentifier"></td>
            <td data-bind="text: patientName"></td>
            <td data-bind="text: gender"></td>
            <td>
                <span data-bind="if: age < 1">< 1</span>
                <!-- ko if: age > 1 -->
                <span data-bind="text: age"></span>
                <!-- /ko -->
            </td>
            <td data-bind="text: testName"></td>
            <td>
                <a title="Enter Results" data-bind="click: showResultForm, attr: { href : '#' }"><i
                        class="icon-list-ul small"></i></a>
                <a title="Re-order Test" data-bind="attr: { href : 'javascript:reorder(' + orderId + ')' }"><i
                        class="icon-share small"></i></a>
            </td>
        </tr>
        </tbody>
    </table>

</div>


<div id="reorder-form" title="Re-order" class="dialog">
    <div class="dialog-header">
        <i class="icon-share"></i>

        <h3>Re-order Scan</h3>
    </div>

    <div class="dialog-content">
        <form>
            <p>

            <div class="dialog-data">Patient Name:</div>

            <div class="inline" data-bind="text: details().patientName"></div>
        </p>

            <p>

            <div class="dialog-data">Test Name:</div>

            <div class="inline" data-bind="text: details().testName"></div>
        </p>

            <p>

            <div class="dialog-data">Test Date:</div>

            <div class="inline" data-bind="text: details().startDate"></div>
        </p>

            <p>
                <label for="reorder-date-display" class="dialog-data">Reorder Date:</label>
                ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'reorder-date', label: 'Reschedule To', formFieldName: 'rescheduleDate', useTime: false, defaultToday: true, startToday: true])}
                <input type="hidden" id="order" name="order">
            </p>

            <!-- Allow form submission with keyboard without duplicating the dialog button -->
            <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
        </form>
        <span class="button confirm right">Re-order</span>
        <span class="button cancel">Cancel</span>
    </div>
</div>


<div style="border-top: 1px solid #eee; height: 40px; padding: 5px 11px 0 5px;">
    <label for="include-result">
        <input id="include-result" type="checkbox">
        Include result
    </label>

    <span class="button task right">
        <i class="icon-print small"></i>
        Print
    </span>

    <span class="button cancel right" style="margin-right: 5px;">
        <i class="icon-print small"></i>
        Export
    </span>

</div>