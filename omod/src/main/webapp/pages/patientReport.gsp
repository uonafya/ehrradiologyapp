<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Radiology Reports"])
    ui.includeJavascript("billingui", "moment.js")


%>

<script>
    var results = {'items': ko.observableArray([])};
    var initialResults = [];

    jq(document).ready(function () {
        jq(".dashboard-tabs").tabs();
        jq('#surname').html(stringReplace('${patient.names.familyName}') + ',<em>surname</em>');
        jq('#othname').html(stringReplace('${patient.names.givenName}') + ' &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <em>other names</em>');
        jq('#agename').html('${patient.age} years (' + moment('${patient.birthdate}').format('DD,MMM YYYY') + ')');
        jq('.tad').text('Last Visit: ' + moment('${previousVisit}').format('DD.MM.YYYY hh:mm') + ' HRS');

    });
</script>

<style>
.new-patient-header .demographics .gender-age {
    font-size: 14px;
    margin-left: -55px;
    margin-top: 12px;
}

.new-patient-header .demographics .gender-age span {
    border-bottom: 1px none #ddd;
}

.new-patient-header .identifiers {
    margin-top: 5px;
}

#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
    text-decoration: none;
}

#breadcrumbs a:hover {
    text-decoration: underline;
}

.new-patient-header .demographics .gender-age {
    font-size: 14px;
    margin-left: -55px;
    margin-top: 12px;
}

.new-patient-header .demographics .gender-age span {
    border-bottom: 1px none #ddd;
}

.new-patient-header .identifiers {
    margin-top: 5px;
}

.tag {
    padding: 2px 10px;
}

.tad {
    background: #666 none repeat scroll 0 0;
    border-radius: 1px;
    color: white;
    display: inline;
    font-size: 0.8em;
    margin-left: 4px;
    padding: 2px 10px;
}

.status-container {
    padding: 5px 10px 5px 5px;
}

.catg {
    color: #363463;
    margin: 35px 10px 0 0;
}
</style>

<body>
<div class="clear"></div>

<div class="container">
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('radiologyapp', 'main')}#results">Radiology</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Radiology Reports
            </li>
        </ul>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name">
                <span id="surname"></span>
                <span id="othname"></span>

                <span class="gender-age">
                    <span>
                        <% if (patient.gender == "F") { %>
                        Female
                        <% } else { %>
                        Male
                        <% } %>
                    </span>
                    <span id="agename"></span>

                </span>
            </h1>

            <br/>

            <div id="stacont" class="status-container">
                <span class="status active"></span>
                Visit Status
            </div>

            <div class="tag">Outpatient ${fileNumber}</div>

            <div class="tad">Last Visit</div>
        </div>

        <div class="identifiers">
            <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
            <span>${patient.getPatientIdentifier()}</span>
            <br>

            <div class="catg">
                <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${category}
            </div>
        </div>

        <div class="close"></div>
    </div>
</div>



<table id="patient-report" style="margin-top: 5px">
    <thead>
    <tr>
        <th>Test</th>
        <th>Note</th>
        <th>Film Given</th>
        <th>Film Size</th>
    </tr>
    </thead>

    <tbody>
    <tr style="font-size: 14px;">
        <td align="center">${radiologyTest}</td>
        <td align="center">${_2539}</td>
        <td align="center">${_2495}</td>
        <td align="center">${_3710}</td>
    </tr>
    </tbody>
</table>
</body>