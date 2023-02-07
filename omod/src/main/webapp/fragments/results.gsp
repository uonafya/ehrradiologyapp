<script>
    var radiologyResultsListTable, radiologyResultsListDataTable;
    var resultsListData;
    var editResultDetails = {details: ko.observable(details)};
    var editTestId, editOrderId, editIsXray, encounterId;
    var editResultDialog;
    var editErrorStatus = false;
    jq(function () {
        var options = {
            target: '#editResultsForm',
            success: showSuccessResponse,
            error: showErrorResponse,
            clearForm: true,
            dataType: 'json'
        };

        jq('#editResultsForm').ajaxForm(options);

        //To handle success cases on posting results
        function showSuccessResponse(responseText, statusText) {
            location.reload();
        }

        //To handle error cases on posting results
        function showErrorResponse(responseText, statusText) {
            console.log(responseText);
            console.log(statusText);
        }

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

        editResultDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#edit-results-form',
            actions: {
                confirm: function () {
                    saveEditedXrayResults();//save xray results
                    if (!editErrorStatus) {
                        editResultDialog.close();
                    }
                },
                cancel: function () {
                    editResultDialog.close();
                }
            }
        });


        ko.applyBindings(editResultDetails, jq("#edit-results-form")[0]);
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

    function loadPreviousResult(encounterId) {
        jq.getJSON('${ui.actionLink("radiologyapp", "results", "loadResultsFromEncounter")}', {
            "encounterId": encounterId
        }).success(function (worklist) {
            if (worklist.length === 0) {
            } else {
                jq.each(worklist, function (index, value) {
                    if (value.concept.name === "RADIOLOGY XRAY DEFAULT FORM NOTE") {
                        jq("#editNote").val(value.valueText);
                    } else if (value.concept.name === "RADIOLOGY XRAY FILM SIZE TYPE") {
                        jq("#editFilmSize").val(value.valueCoded.name);
                    } else if (value.concept.name === "RADIOLOGY XRAY DEFAULT FORM REPORT STATUS") {
                        jq("#editFilmSelect").val(value.valueCoded.name);
                    }
                });
            }
        });
    }

    function showEditResultForm(testDetail) {
        editResultDetails.details(testDetail);
        editOrderId = testDetail.orderId;
        editTestId = testDetail.testId;
        editIsXray = testDetail.xray;
        encounterId = testDetail.givenEncounterId;
        jq("#editTestId").val(editTestId);
        jq("#editIsXray").val(editIsXray);
        jq("#encounterId").val(encounterId);
        loadPreviousResult(testDetail.givenEncounterId);
        //preload the test
        editResultDialog.show();
    }

    function loadPatientReport(patientId, testId, encounterId) {
        window.location = emr.pageLink("radiologyapp", "patientReport", {
            patientId: patientId,
            testId: testId,
            encounterId: encounterId
        });
    }

    function saveEditedXrayResults() {
        if (jq("#editFilmSelect").val() == "0") {
            jq().toastmessage('showErrorToast', "Specify Film Given Status!");
            editErrorStatus = true;
        } else if (jq.trim(jq("#editNote").val()) <= 0) {
            jq().toastmessage('showErrorToast', "Results Note is Mandatory!");
            editErrorStatus = true;
        } else {
            editErrorStatus = false;
        }


        if (editErrorStatus) {
            return false;
        } else {
            jq("#editResultsForm").submit();
        }

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
                        class="icon-edit small"></i></a>
                <a title="View Report"
                   data-bind="attr: { href : 'javascript:loadPatientReport(' + orderId + ', ' + testId + ', ' + givenEncounterId+ ')' }"><i
                        class="icon-bar-chart small"></i></a>
            </td>
        </tr>
        </tbody>
    </table>

</div>


<div id="edit-results-form" title="Edit Radiology Results" class="dialog">
    <div class="dialog-header">
        <i class="icon-share"></i>

        <h3>Edit Radiology Results</h3>
    </div>

    <div class="dialog-content">
        <form id="editResultsForm" method="post" enctype="multipart/form-data"
              action="${ui.actionLink("radiologyapp", "radiationResults", "editXrayResults")}">
            <input type="hidden" name="testId" value="" id="editTestId"/>
            <input type="hidden" name="isXray" value="" id="editIsXray"/>
            <input type="hidden" name="encounterId" value="" id="encounterId"/>

            <p>

            <div class="dialog-data">Patient Name:</div>

            <div class="inline" data-bind="text: details().patientName"></div>
        </p>
            <p>

            <div class="dialog-data">Test Date:</div>

            <div class="inline" data-bind="text: details().startDate"></div>

        </p>
            <p>

            <div class="dialog-data">Test Name:</div>

            <div class="inline" data-bind="text: details().testName"></div>
        </p>
            <p>

            <div class="dialog-data">Film Given:</div>

            <div class="inline">
                <select id="editFilmSelect" name="RADIOLOGY XRAY DEFAULT FORM REPORT STATUS">
                    <option value="0" selected>Please Select</option>
                    <option value="RADIOLOGY XRAY DEFAULT FORM FILM GIVEN">Film Given</option>
                    <option value="RADIOLOGY XRAY DEFAULT FORM FILM NOT GIVEN">Film Not Given</option>
                </select>

            </div>
        </p>
            <p>

            <div class="dialog-data">Scan Note</div>

            <div class="inline">
                <textarea id="editNote" name="RADIOLOGY XRAY DEFAULT FORM NOTE"
                                       placeholder="Enter Scan Notes" cols="30" rows="10"
                          required> </textarea>
            </div>
        </p>

            <!-- Allow form submission with keyboard without duplicating the dialog button -->
            <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
            <span class="button confirm right">Save</span>
            <span class="button cancel">Cancel</span>
        </form>

    </div>
</div>


