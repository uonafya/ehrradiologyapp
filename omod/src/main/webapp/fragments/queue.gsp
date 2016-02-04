<%
    def props = ["startDate", "patientIdentifier", "patientName", "gender", "age", "testName", "action"]
%>

<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.11.0/moment.js"></script>

<script>
    jq(function () {
        jq("#get-tests").on("click", function () {
            var date = jq("#referred-date-field").val();
            var phrase = jq("#phrase").val();
            var investigation = jq("#investigation").val();
            jq.getJSON('${ui.actionLink("radiologyapp", "Queue", "searchQueue")}',
                    {
                        "date": moment(date).format('DD/MM/YYYY'),
                        "phrase": phrase,
                        "investigation": investigation,
                        "currentPage": 1
                    }
            ).success(function (data) {
                        if (data.length === 0) {
                            jq().toastmessage('showNoticeToast', "No match found!");
                        } else {
                            updateQueueTable(data)
                        }
//                        queueData.tests.removeAll();
//                        jq.each(data, function(index, testInfo){
//                            queueData.tests.push(testInfo);
//                        });
                    });
        });
    });
</script>
<script>
    //update the queue table
    function updateQueueTable(tests) {
        var jq = jQuery;
        jq('#patient-search-results-table > tbody > tr').remove();
        var tbody = jq('#patient-search-results-table > tbody');
        var row = '<tr>';
        for (index in tests) {
            var item = tests[index];

            <% props.each {
              if(it == props.last()){
                  def pageLinkEdit = ui.pageLink("registration", "editPatient");
                      %>
            row += '<td> <a title="Patient Revisit" href="${pageLinkEdit}?patientId=' +
                    item.patientIdentifier + '&revisit=true"><i class="icon-user-md small" ></i></a>';

            <% } else {%>

            row += '<td>' + item.${ it } + '</td>';
            <% }
              } %>
            row += '</tr>';
            tbody.append(row);
        }
    }
</script>

<div>
    <form>
        <fieldset>
            ${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'referred-date', label: 'Date Ordered', formFieldName: 'referredDate', useTime: false, defaultToday: true])}
            <label for="phrase">Patient Identifier/Name</label>
            <input id="phrase"/>
            <label for="investigation">Investigation</label>
            <select name="investigation" id="investigation">
                <option value="0">ALL</option>
                <% investigations.each { investigation -> %>
                <option value="${investigation.id}">${investigation.name.name}</option>
                <% } %>
            </select>
            <br/>
            <input type="button" value="Get patients" id="get-tests"/>
        </fieldset>
    </form>
</div>

<div id="patient-search-results" style="display: block; margin-top:3px;">
    <div role="grid" class="dataTables_wrapper" id="patient-search-results-table_wrapper">
        <table id="patient-search-results-table" class="dataTable" aria-describedby="patient-search-results-table_info">
            <thead>
            <tr role="row">
                <th class="ui-state-default" role="columnheader" style="width: 220px;">
                    <div class="DataTables_sort_wrapper">startDate<span class="DataTables_sort_icon"></span></div>
                </th>

                <th class="ui-state-default" role="columnheader">
                    <div class="DataTables_sort_wrapper">patientIdentifier<span class="DataTables_sort_icon"></span>
                    </div>
                </th>

                <th class="ui-state-default" role="columnheader" style="width:60px;">
                    <div class="DataTables_sort_wrapper">patientName<span class="DataTables_sort_icon"></span></div>
                </th>

                <th class="ui-state-default" role="columnheader" style="width: 60px;">
                    <div class="DataTables_sort_wrapper">Age<span class="DataTables_sort_icon"></span></div>
                </th>

                <th class="ui-state-default" role="columnheader" style="width:120px;">
                    <div class="DataTables_sort_wrapper">gender<span class="DataTables_sort_icon"></span></div>
                </th>

                <th class="ui-state-default" role="columnheader" style="width: 100px;">
                    <div class="DataTables_sort_wrapper">testName<span class="DataTables_sort_icon"></span></div>
                </th>

                <th class="ui-state-default" role="columnheader" style="width: 60px;">
                    <div class="DataTables_sort_wrapper">action<span class="DataTables_sort_icon"></span></div>
                </th>
            </tr>
            </thead>

            <tbody role="alert" aria-live="polite" aria-relevant="all">
            <tr align="center">
                <td colspan="6">No patients found</td>
            </tr>
            </tbody>
        </table>

    </div>
</div>
