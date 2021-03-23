<%
    ui.decorateWith("kenyaemr", "standardPage")

    ui.includeJavascript("ehrcashier", "paging.js")
    ui.includeJavascript("ehrconfigs", "moment.js")
    ui.includeJavascript("ehrcashier", "common.js")
    ui.includeJavascript("ehrcashier", "jquery.PrintArea.js")
    ui.includeJavascript("ehrconfigs", "knockout-3.4.0.js")
    ui.includeJavascript("ehrconfigs", "jquery-ui-1.9.2.custom.min.js")
    ui.includeJavascript("ehrconfigs", "underscore-min.js")
    ui.includeJavascript("ehrconfigs", "emr.js")
    ui.includeJavascript("ehrconfigs", "jquery.simplemodal.1.4.4.min.js")

    ui.includeCss("ehrconfigs", "jquery-ui-1.9.2.custom.min.css")
    ui.includeCss("ehrcashier", "paging.css")
    ui.includeCss("ehrconfigs", "referenceapplication.css")

    ui.includeCss("radiologyapp", "radiology.css")
    ui.includeJavascript("uicommons", "moment.js")
    ui.includeJavascript("radiologyapp", "jquery.form.js")
    ui.includeJavascript("radiologyapp", "jq.browser.select.js")
%>

<script>
    jq(function () {
        jq(".radiology-tabs").tabs();

        jq("#refresh").on("click", function () {
            if (jq('#queue').is(':visible')) {
                getQueueData();
            }
            else if (jq('#worklist').is(':visible')) {
                getWorklistData();
            }
            else if (jq('#results').is(':visible')) {
                getResultsData();
            }
            else {
                jq().toastmessage('showErrorToast', "Tab Content not Available");
            }
        });

        jq("#inline-tabs li").click(function () {
            if (jq(this).attr("aria-controls") == "queue") {
                jq('#refresh a').html('<i class="icon-refresh"></i> Get Patients');
                jq('#refresh a').show(500);
                getQueueData(false);
            }
            else if (jq(this).attr("aria-controls") == "worklist") {
                jq('#refresh a').html('<i class="icon-refresh"></i> Get Worklist');
                jq('#refresh a').show(500);
                getWorklistData(false);
            }
            else if (jq(this).attr("aria-controls") == "results") {
                jq('#refresh a').html('<i class="icon-refresh"></i> Get Results');
                jq('#refresh a').show(500);
                getResultsData(false);
            }
            else if (jq(this).attr("aria-controls") == "status") {
                jq('#refresh a').hide(500);
                getBillableServices();
            }
        });
    });
</script>

<style>
.new-patient-header .identifiers {
    margin-top: 5px;
}

.name {
    color: #f26522;
}

#inline-tabs {
    background: #f9f9f9 none repeat scroll 0 0;
}

#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
    text-decoration: none;
}

form fieldset, .form fieldset {
    padding: 10px;
    width: 97.4%;
}

#referred-date label,
#accepted-date label,
#accepted-date-edit label {
    display: none;
}

form input[type="text"],
form input[type="number"] {
    width: 92%;
}

form select {
    width: 100%;
}

form input:focus, form select:focus {
    outline: 2px none #007fff;
    border: 1px solid #777;
}

.add-on {
    color: #f26522;
    float: right;
    left: auto;
    margin-left: -31px;
    margin-top: 8px;
    position: absolute;
}

.webkit .add-on {
    color: #F26522;
    float: right;
    left: auto;
    margin-left: -31px;
    margin-top: -27px !important;
    position: relative !important;
}

.toast-item {
    background: #333 none repeat scroll 0 0;
}

#queue table, #worklist table, #results table {
    font-size: 14px;
    margin-top: 10px;
}

#refresh {
    border: 1px none #88af28;
    color: #fff !important;
    float: right;
    margin-right: -10px;
    margin-top: 5px;
}

#refresh a i {
    font-size: 12px;
}

form label, .form label {
    color: #028b7d;
}

.col5 {
    width: 65%;
}

.col5 button {
    float: right;
    margin-left: 3px;
    margin-right: 0;
    min-width: 180px;
}

form input[type="checkbox"] {
    margin: 5px 8px 8px;
}

.toast-item-image {
    top: 25px;
}

.ui-widget-content a {
    color: #007fff;
}

.accepted {
    color: #f26522;
}

#modal-overlay {
    background: #000 none repeat scroll 0 0;
    opacity: 0.4 !important;
}

.dialog-data {
    display: inline-block;
    width: 120px;
    color: #028b7d;
}

.inline {
    display: inline-block;
}

#reschedule-date label,
#reorder-date label {
    display: none;
}

#reschedule-date-display,
#reorder-date-display {
    min-width: 1px;
    width: 235px;
}

.dialog {
    display: none;
}

.dialog select {
    display: inline;
    width: 255px;
}

.dialog select option {
    font-size: 1em;
}

#modal-overlay {
    background: #000 none repeat scroll 0 0;
    opacity: 0.4 !important;
}
</style>

<div class="clear"></div>

<div id="main-div">
    <div class="container">
        <div class="example">
            <ul id="breadcrumbs">
                <li>
                    <a href="${ui.pageLink('referenceapplication', 'home')}">
                        <i class="icon-home small"></i></a>
                </li>

                <li>
                    <i class="icon-chevron-right link"></i>
                    Radiology
                </li>
            </ul>
        </div>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>&nbsp;RADIOLOGY MODULE &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
            </h1>
        </div>

        <div class="show-icon">
            &nbsp;
        </div>

        <div class="radiology-tabs" style="margin-top: 12px;">
            <ul id="inline-tabs">
                <li><a href="#queue">Queue</a></li>
                <li><a href="#worklist">Worklist</a></li>
                <li><a href="#results">Results</a></li>
                <li><a href="#status">Functional Status</a></li>

                <li id="refresh" class="ui-state-default">
                    <a style="color:#fff" class="button confirm">
                        <i class="icon-refresh"></i>
                        Get Patients
                    </a>
                </li>
            </ul>

            <div id="queue">
                ${ui.includeFragment("radiologyapp", "queue")}
            </div>

            <div id="worklist">
                ${ui.includeFragment("radiologyapp", "worklist", [investigations: investigations])}
            </div>

            <div id="results">
                ${ui.includeFragment("radiologyapp", "results")}
            </div>

            <div id="status">
                ${ui.includeFragment("radiologyapp", "functionalStatus")}
            </div>
        </div>
    </div>
</div>

