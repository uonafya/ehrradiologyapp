<script>
    var radiologyWorklistTable = jq('#radiology-worklist-table');
    var radiologyWorklistDataTable;
    var worklistData, reorderDialog, reorderForm, resultsDialog;
    var orderIdd, files;
    var isXray, testId;
    var details = {'patientName': 'Patient Name', 'startDate': 'Start Date', 'test': {'name': 'Test Name'}};
    var scanDetails = {details: ko.observable(details)};
    var resultDetails = {details: ko.observable(details)};
    var errorStatus = false;
    jq(function () {

        var options = {
            target: '#resultsForm',
            success: showSuccessResponse,
            error: showErrorResponse,
            clearForm: true,
            dataType: 'json'
        };

        jq('#resultsForm').ajaxForm(options);


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


        // Add events
        jq('input[type=file]').on('change', prepareUpload);

        // Grab the files and set them to our variable
        function prepareUpload(event) {
            files = event.target.files;
        }


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
                confirm: function () {
                    saveSchedule();
                    reorderDialog.close();
                },
                cancel: function () {
                    reorderDialog.close();
                }
            }
        });
        resultsDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#results-form',
            actions: {
                confirm: function () {
                    saveXrayResults();//save xray results
                    if (!errorStatus) {
                        resultsDialog.close();
                    }
                },
                cancel: function () {
                    resultsDialog.close();
                }
            }
        });

        jq("#filmSelect").on('change',function(){
            if(jq(this).val() !== "RADIOLOGY XRAY DEFAULT FORM FILM GIVEN" ){
                jq("#filmSize").prop('disabled', 'disabled');
            }else{
                jq("#filmSize").prop('disabled', false);
            }
        })


        reorderForm = jq("#reorder-form").find("form").on("submit", function (event) {
            event.preventDefault();
            saveSchedule();
        });
        ko.applyBindings(scanDetails, jq("#reorder-form")[0]);
        ko.applyBindings(resultDetails, jq("#results-form")[0]);
        ko.applyBindings(worklistData, jq("#radiology-worklist")[0]);
    });//End of Document Ready

    //To handle success cases on posting results
    function showSuccessResponse(responseText, statusText) {
        location.reload();
    }

    //To handle error cases on posting results
    function showErrorResponse(responseText, statusText) {
        console.log(responseText);
        console.log(statusText);
    }


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
        resultDetails.details(testDetail);
        orderIdd = testDetail.orderId;
        testId = testDetail.testId;
        isXray = testDetail.xray;
        jq("#testId").val(testId);
        jq("#isXray").val(isXray);
        resultsDialog.show();


    }

    function reorder(orderId) {
        jq("#reorder-form #order").val(orderId);
        orderIdd = orderId;
        var details = ko.utils.arrayFirst(worklistData.worklistItems(), function (item) {
            return item.orderId == orderId;
        });
        scanDetails.details(details);
        reorderDialog.show();
    }

    function saveSchedule() {
        jq.post('${ui.actionLink("radiologyapp", "queue", "rescheduleOrder")}',
                {"orderId": orderIdd, "rescheduledDate": moment(jq("#reorder-date-field").val()).format('DD/MM/YYYY')},
                function (data) {
                    if (data.status === "fail") {
                        jq().toastmessage('showErrorToast', data.error);
                    } else {
                        jq().toastmessage('showSuccessToast', data.message);
                        var reorderedTest = ko.utils.arrayFirst(worklistData.worklistItems(), function (item) {
                            return item.orderId == orderIdd;
                        });
                        worklistData.worklistItems.remove(reorderedTest);
                    }
                },
                'json'
        );
    }

    function saveXrayResults() {
        if (jq("#filmSelect").val() == "0") {
            jq().toastmessage('showErrorToast', "Specify Film Given Status!");
            errorStatus = true;
        } else if (jq.trim(jq("#note").val()) <= 0) {
            jq().toastmessage('showErrorToast', "Results Note is Mandatory!");
            errorStatus = true;
        }else{
            errorStatus = false;
        }



        if (errorStatus) {
            return false;
        } else {
            jq("#resultsForm").submit();
        }

    }

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
            <td data-bind="text: age"></td>
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

<div id="results-form" title="Enter Results" class="dialog">
    <div class="dialog-header">
        <i class="icon-share"></i>

        <h3>Scan Results</h3>
    </div>

    <div class="dialog-content">
        <form id="resultsForm" method="post" enctype="multipart/form-data"
              action="${ui.actionLink("radiologyapp", "radiationResults", "saveXrayResults")}">

            <input type="hidden" name="testId" value="" id="testId"/>
            <input type="hidden" name="isXray" value="" id="isXray"/>

            <p>

            <div class="dialog-data">Patient Name:</div>

            <div class="inline" data-bind="text: details().patientName"></div>
        </p>
            <p>

            <div class="dialog-data">Test Date:</div>

            <div class="inline" data-bind="text: details().startDate"></div>
        </p>
            <p>

            <div class="dialog-data">Film Given:</div>

            <div class="inline">
                <select id="filmSelect" name="RADIOLOGY XRAY DEFAULT FORM REPORT STATUS">
                    <option value="0" selected>Please Select</option>
                    <option value="RADIOLOGY XRAY DEFAULT FORM FILM GIVEN">Film Given</option>
                    <option value="RADIOLOGY XRAY DEFAULT FORM FILM NOT GIVEN">Film Not Given</option>
                </select>

            </div>
        </p>
            <p>

            <div class="dialog-data">Scan Note</div>

            <div class="inline"><input id="note" name="RADIOLOGY XRAY DEFAULT FORM NOTE" placeholder="Enter Scan Notes"
                                       required/></div>
        </p>


            <p>

            <div class="dialog-data">Film Size:</div>

            <div class="inline">
                <select id="filmSize" name="RADIOLOGY XRAY FILM SIZE TYPE">
                    <option value="RADIOLOGY XRAY FILM SIZENA" selected>N/A</option>
                    <option value="RADIOLOGY XRAY FILM SIZE1">8*10</option>
                    <option value="RADIOLOGY XRAY FILM SIZE2">10*12</option>
                    <option value="RADIOLOGY XRAY FILM SIZE3">12*15</option>

                </select>

            </div>
        </p>

            <p>

            <div class="dialog-data">File Upload</div>

            <div class="inline">
                <input size="30" type="file" name="file" id="file"/><br/>
            </div>
        </p>



            <!-- Allow form submission with keyboard without duplicating the dialog button -->
            <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
            <span class="button confirm right">Save</span>
            <span class="button cancel">Cancel</span>
        </form>

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