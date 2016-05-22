<script>
	var radiologyWorklistTable = jq('#radiology-worklist-table');
	var radiologyWorklistDataTable;
	var worklistData;

	jq(function() {
		radiologyWorklistTable = jq('#radiology-worklist-table');
		worklistData = new WorklistData();

		ko.applyBindings(worklistData, jq("#radiology-worklist")[0]);

		initializeWorklistDataTable();
		getWorklistData(false);
		
		jq('#worklist-order-date-display, #worklist-investigation').change(function(){
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
	});//End of Document Ready
	
	function getWorklistData(showNotification){
		if (typeof showNotification == 'undefined'){
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
				jq().toastmessage('showNoticeToast', "No match found!");
				worklistData.worklistItems([]);
			} else {
				worklistData.worklistItems(worklist.data);
			}
			
			initializeWorklistDataTable(jq('#worklist-phrase').val());
		});
	}
	
	function initializeWorklistDataTable(phrase) {
		if (typeof phrase == 'undefined'){
			phrase = '';
		}
		
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
		}).search(phrase).draw();
	}
	
	function destroyWorklistDataTable() {
		radiologyWorklistDataTable.clear();
		radiologyWorklistDataTable.destroy();
	}

	function getResultTemplate(testId) {
		jq.getJSON('${ui.actionLink("radiologyapp", "radResults", "getResultTemp")}',
				{ "testId" : testId }
		).success(function(parameterOptions){
			parameterOpts.parameterOptions.removeAll();
			var details = ko.utils.arrayFirst(workList.items(), function(item) {
				return item.testId == testId;
			});
			jq.each(parameterOptions, function(index, parameterOption) {
				parameterOption['patientName'] = details.patientName;
				parameterOption['testName'] = details.test.name;
				parameterOption['startDate'] = details.startDate;
				parameterOpts.parameterOptions.push(parameterOption);
			});
		});
	}
</script>

<div class="fieldset">
	<i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 56px ! important; padding: 0px 10px 0px 0px;"></i>
	<div>
		<label for="worklist-order-date-display"> Date Ordered </label><br/>
		${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'worklist-order-date', label: 'Date Ordered', formFieldName: 'orderedDate', useTime: false, defaultToday: true])}
	</div>
	
	<div style="margin-right: 30px; width: 42%;">
		<label for="worklist-phrase">Filter Patient</label><br/>
		<input id="worklist-phrase" type="text" placeholder="Enter Criteria to Filter" style="width: 100%; padding-left: 30px;"/>
		<i class="icon-search small" style="color: rgb(242, 101, 34); float: right; position: relative; margin-top: -32px; margin-right: 92.5%;"></i>
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
				<td></td>
			</tr>
		</tbody>
	</table>
</div>