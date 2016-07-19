<%
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
%>
<script type="text/javascript">
    var dataTable;
    var billableServices;
    var serviceIds = [];
    jQuery(document).ready(function() {

        jq('#fTable').on('change', 'input.service-status', function() {
            var index = jq.inArray(jq(this).val(), serviceIds);
            if (index > -1) {
                serviceIds.splice(index, 1);
            } else {
                serviceIds.push(jq(this).val());
            }
        });
		
		jq('#filter-status').on('keyup',function(){
			var searchPhrase = jq(this).val();
            dataTable.search(searchPhrase).draw();
		});

        dataTable=jQuery('#fTable').DataTable({
            searching: true,
            lengthChange: false,
            pageLength: 25,
            jQueryUI: true,
            pagingType: 'full_numbers',
            sort: false,
            dom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
            language: {
                zeroRecords: 'No Services Found',
                paginate: {
                    first: 'First',
                    previous: 'Previous',
                    next: 'Next',
                    last: 'Last'
                }
            }
        });
		
		dataTable.on( 'order.dt search.dt', function () {
			dataTable.column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		} ).draw();

        getBillableServices();

        jQuery('#fTable tbody').on("click", function(){
            jq('#submitSave').on("click", function(){

                jq.post('${ui.actionLink('radiologyapp','functionalStatus','updateBillServices')}',
                        { "serviceIds" : serviceIds.toString() },
                        function (data) {
                            if (data.status === "fail") {
                                jq().toastmessage('showErrorToast', data.error);
                            } else {
                                jq().toastmessage('showSuccessToast', data.message);

                            }
                        },
                        'json'
                );
            });
        });


    });

    function getBillableServices() {
        jq.ajax({
            type: "GET",
            url: "${ui.actionLink('radiologyapp','functionalStatus','getBillableServices')}",
            dataType: "json",
            success: function (data) {
                billableServices = data

                var dataRows = [];

                _.each(billableServices, function(billableService) {
                    var isChecked = (billableService.disable === true) ?"checked=checked":"";
                    dataRows.push([0, billableService.name, '<input type="checkbox" class="service-status" '+ isChecked + '" value="'+ billableService.serviceId +'">'])
                });

                dataTable.rows.add(dataRows);
                dataTable.draw();
            },
            error: function (xhr, ajaxOptions, thrownError) {
                alert(xhr);
                jQuery("#ajaxLoader").hide();
            }
        });
    }
</script>

<style>
	.paging_full_numbers .fg-button {
		margin: 1px;
	}
	.paging_full_numbers {
		width: 62% !important;
	}	
	.dataTables_info {
		float: left;
		width: 35%;
	}
</style>

<div class="fieldset">
	<i class="icon-filter" style="color: rgb(91, 87, 166); float: left; font-size: 56px ! important; padding: 0px 10px 0px 0px;"></i>
	<div style="margin-right: 30px; width: 88%;">
		<label for="filter-status">Filter Functional Status</label><br/>
		<input id="filter-status" type="text" placeholder="Filter Functional Status" style="width: 100%; padding-left: 30px;"/>
		<i class="icon-search small" style="color: rgb(242, 101, 34); float: right; position: relative; margin-top: -32px; margin-right: 96.2%;"></i>
	</div>
</div>

<table id='fTable'>
    <thead>
    <tr>
        <th>#</th>
        <th>Test</th>
        <th>Disabled</th>
    </tr>
    </thead>
    <tbody>
    </tbody>
</table>

<input type='hidden' id='serviceIds' name='serviceIds' value=''/>
<input type='submit' id='submitSave' value='Save'/>
