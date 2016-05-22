<script>
	jq(function() {
		getResultsData(false);
	});
	
	function getResultsData(showNotification){
		if (typeof showNotification == 'undefined'){
			showNotification = true;
		}
		
		//Code here
	}

</script>

<div class="fieldset">
	<i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 56px ! important; padding: 0px 10px 0px 0px;"></i>
	<div>
		<label for="results-order-date-display"> Date Ordered </label><br/>
		${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'results-order-date', label: 'Date Ordered', formFieldName: 'orderedDate', useTime: false, defaultToday: true])}
	</div>
	
	<div style="margin-right: 30px; width: 42%;">
		<label for="results-phrase">Filter Patient</label><br/>
		<input id="results-phrase" type="text" placeholder="Enter Criteria to Filter" style="width: 100%; padding-left: 30px;"/>
		<i class="icon-search small" style="color: rgb(242, 101, 34); float: right; position: relative; margin-top: -32px; margin-right: 92.5%;"></i>
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

		<tbody data-bind="foreach: worklistItems">
			<tr style="font-size: 14px;">
				<td></td>
				<td colspan="7">NO RESULTS FOUND</td>
			</tr>
		</tbody>
	</table>
</div>