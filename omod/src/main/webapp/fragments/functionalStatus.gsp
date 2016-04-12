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
            console.log(serviceIds)
        });


        dataTable=jQuery('#fTable').DataTable({
            searching: false,
            lengthChange: false,
            pageLength: 15,
            jQueryUI: true,
            pagingType: 'full_numbers',
            sort: false,
            dom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
            language: {
                zeroRecords: 'No Service Found',
                paginate: {
                    first: 'First',
                    previous: 'Previous',
                    next: 'Next',
                    last: 'Last'
                }
            }
        });

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
        jQuery.ajax({
            type: "GET",
            url: "${ui.actionLink('radiologyapp','functionalStatus','getBillableServices')}",
            dataType: "json",
            success: function (data) {
                billableServices = data
                console.log(data);

                var dataRows = [];

                _.each(billableServices, function(billableService) {
                    var isChecked = (billableService.disable === true) ?"checked=checked":"";
                    dataRows.push([billableService.name, '<input type="checkbox" class="service-status" '+ isChecked + '" value="'+ billableService.serviceId +'">'])
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

<table id='fTable'>
    <thead>
    <tr>
        <th>Test</th>
        <th>Disabled</th>
    </tr>
    </thead>
    <tbody>
    </tbody>
</table>

<input type='hidden' id='serviceIds' name='serviceIds' value=''/>
<input type='submit' id='submitSave' value='Save'/>
