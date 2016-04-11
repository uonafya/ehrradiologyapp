<script>
	jq(function() {
		var radiologyWorklistTable = jq('#radiology-worklist-table');
		var radiologyWorklistDataTable;
		var worklistData = new WorklistData();

		ko.applyBindings(worklistData, jq("#radiology-worklist")[0]);

		initializeWorklistDataTable();

        jq("#get-worklist").on("click", function () {
            var orderedDate = jq("#worklist-order-date-field").val();
            var phrase = jq("#worklist-phrase").val();
            var investigation = jq("#worklist-investigation").val();
            jq.getJSON('${ui.actionLink("radiologyapp", "worklist", "searchWorkList")}',
              {
                "orderedDate": moment(orderedDate).format('DD/MM/YYYY'),
                "phrase": phrase,
                "investigation": investigation,
              }
            ).success(function (worklist) {
                destroyWorklistDataTable();
                if (worklist.data.length === 0) {
                    jq().toastmessage('showNoticeToast', "No match found!");
                    worklistData.worklistItems([]);
                } else {
                    worklistData.worklistItems(worklist.data);
                }
                refreshWorklistDataTable();
            });
        });

        function WorklistData() {
            self = this;
            self.worklistItems = ko.observableArray([]);
        }

        function destroyWorklistDataTable() {
            radiologyWorklistDataTable.clear();
            radiologyWorklistDataTable.destroy();
        }

        function refreshWorklistDataTable() {
            initializeWorklistDataTable();
        }

		function initializeWorklistDataTable() {
			radiologyWorklistDataTable = radiologyWorklistTable.DataTable({
				responsive: true,
				searching : true,
				lengthChange : false,
				pageLength : 15,
				jQueryUI : true,
				pagingType : 'full_numbers',
				sort : false,
				dom : 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
				language : {
					zeroRecords : 'No tests in worklist.',
					paginate : {
						first : 'First',
						previous : 'Previous',
						next : 'Next',
						last : 'Last'
					}
				}
			});
		}
	});
</script>

<div>
    <form>
        <fieldset>
            ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'worklist-order-date', label: 'Date Ordered', formFieldName: 'orderedDate', useTime: false, defaultToday: true])}
            <label for="worklist-phrase">Patient Identifier/Name</label>
            <input id="worklist-phrase" type="text"/>
            <label for="worklist-investigation">Investigation</label>
            <select name="investigation" id="worklist-investigation">
                <option value="0">ALL</option>
                <% investigations.each { investigation -> %>
                <option value="${investigation.id}">${investigation.name.name}</option>
                <% } %>
            </select>
            <br/>
            <input type="button" value="Get Worklist" id="get-worklist"/>
        </fieldset>
    </form>
</div>

<div id="radiology-worklist" style="display: block; margin-top: 3px;">
	<table id="radiology-worklist-table">
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

		<tbody data-bind="foreach: worklistItems">
			<tr>
				<td data-bind="text: startDate"></td>
				<td data-bind="text: patientIdentifier"></td>
				<td data-bind="text: patientName"></td>
				<td data-bind="text: gender"></td>
				<td data-bind="text: age"></td>
				<td data-bind="text: testName"></td>
				<td></td>
			</tr>
		</tbody>
	</table>
</div>