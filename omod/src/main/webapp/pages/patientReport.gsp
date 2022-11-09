<%
    ui.decorateWith("kenyaemr", "standardPage")

    ui.includeJavascript("ehrconfigs", "paging.js")
    ui.includeJavascript("ehrconfigs", "moment.js")
    ui.includeJavascript("radiologyapp", "jq.print.js")
    ui.includeJavascript("ehrconfigs", "knockout-3.4.0.js")
    ui.includeJavascript("ehrconfigs", "jquery-ui-1.9.2.custom.min.js")
    ui.includeJavascript("ehrconfigs", "underscore-min.js")
    ui.includeJavascript("ehrconfigs", "emr.js")
    ui.includeJavascript("ehrconfigs", "jquery.simplemodal.1.4.4.min.js")
    ui.includeJavascript("radiologyapp", "cornerstone.min.js")
    ui.includeJavascript("radiologyapp", "cornerstoneMath.js")
    ui.includeJavascript("radiologyapp", "cornerstoneTools.js")
    ui.includeJavascript("radiologyapp", "cornerstoneWADOImageLoader.min.js")
    ui.includeJavascript("radiologyapp", "dicomParser.min.js")
    ui.includeJavascript("radiologyapp", "jpx.min.js")
    ui.includeJavascript("radiologyapp", "libCharLS.js")
    ui.includeJavascript("radiologyapp", "libopenjpeg.js")
    ui.includeJavascript("radiologyapp", "uids.js")

    ui.includeCss("ehrconfigs", "jquery-ui-1.9.2.custom.min.css")
    ui.includeCss("ehrconfigs", "paging.css")
    ui.includeCss("ehrconfigs", "referenceapplication.css")
    ui.includeCss("radiologyapp", "cornerstone.min.css")
    ui.includeCss("ehrconfigs", "onepcssgrid.css")




%>

<script>
    var results = {'items': ko.observableArray([])};
    var initialResults = [];
    jQuery.noConflict();
    jq(document).ready(function () {
        jq(".dashboard-tabs").tabs();
        jq('#surname').html('${patientFamilyName}' + ',<em>surname</em>');
        jq('#othname').html('${patientGivenName}' + ' &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <em>other names</em>');
        jq('#agename').html('${patient.age} years (' + moment('${patient.birthdate}').format('DD,MMM YYYY') + ')');
        jq('.tad').text('Last Visit: ' + moment('${previousVisit}').format('DD.MM.YYYY hh:mm') + ' HRS');
        jq("#radImage").hide();
    });

    function getDicom(fileName) {
        jq.ajax({
            url: '${ui.actionLink("radiologyapp", "radiationResults", "loadDicomImage")}',
            data: {
                "fileName": fileName
            },
            success: successResult(data),
            dataType: 'binary'
        });
    }

    function successResult(data) {
        console.log(data);
    }

    function printPatientReport() {
        jq("#radReports").print({
            globalStyles: false,
            mediaPrint: false,
            stylesheet: '${ui.resourceLink("ehrconfigs","styles/referenceapplication.css")}',
            iframe: false,
            width: 600,
            height: 700
        });

    }

    function loadRadiologyImage() {
        jq("#radImage").toggle();
        console.log("Not Yet Implemented!");
    }
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
                <a href="${ui.pageLink('kenyaemr', 'userHome')}">
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

    <div id="radReports">

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
        <table id="patient-report" style="margin-top: 5px">
            <thead>
            <tr>
                <th>Test</th>
                <th>Notes</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            </thead>

            <tbody>
            <tr style="font-size: 14px;">
                <td align="center">${radiologyTest}</td>
                <td align="center">${_1000170}</td>
                <td align="center">${_1000171}</td>
                <td align="center">
                    <a title="View Image"
                       onclick="loadRadiologyImage()"><i
                            class="icon-picture small"></i></a>

                    <a title="Print Report"
                       onclick="printPatientReport()"><i
                            class="icon-print small"></i></a>

                </td>
            </tr>

            <tr id="radImage">

            </tr>
            </tbody>
        </table>
    </div>

</div>


<div class="container" style="display: none">
    <div id="loadProgress">Image Load Progress:</div>
    <input type="checkbox" id="toggleModalityLUT">Apply Modality LUT</input>
    <input type="checkbox" id="toggleVOILUT">Apply VOI LUT</input>
    <br>

    <div class="row">
        <div class="col-md-6">
            <div style="width:512px;height:512px;position:relative;color: white;display:inline-block;border-style:solid;border-color:black;"
                 oncontextmenu="return false"
                 class='disable-selection noIbar'
                 unselectable='on'
                 onselectstart='return false;'
                 onmousedown='return false;'>
                <div id="dicomImage"
                     style="width:512px;height:512px;top:0px;left:0px; position:absolute">
                </div>
            </div>
        </div>
    </div>
</div>
</body>
<script>


    // this function gets called once the user drops the file onto the div
    function handleFileSelect(evt) {
        evt.stopPropagation();
        evt.preventDefault();

        // Get the FileList object that contains the list of files that were dropped
        var files = evt.dataTransfer.files;

        // this UI is only built for a single file so just dump the first one
        file = files[0];
        var imageId = cornerstoneWADOImageLoader.fileManager.add(file);
        loadAndViewImage(imageId);
    }

    function handleDragOver(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
    }

    // Setup the dnd listeners.
    var dropZone = document.getElementById('dicomImage');
    dropZone.addEventListener('dragover', handleDragOver, false);
    dropZone.addEventListener('drop', handleFileSelect, false);


    cornerstoneWADOImageLoader.configure({
        beforeSend: function (xhr) {
            // Add custom headers here (e.g. auth tokens)
            //xhr.setRequestHeader('x-auth-token', 'my auth token');
        }
    });

    var loaded = false;

    function loadAndViewImage(imageId) {
        var element = jq('#dicomImage').get(0);
        //try {
        var start = new Date().getTime();
        cornerstone.loadImage(imageId).then(function (image) {
            console.log(image);
            var viewport = cornerstone.getDefaultViewportForImage(element, image);
            jq('#toggleModalityLUT').attr("checked", viewport.modalityLUT !== undefined);
            jq('#toggleVOILUT').attr("checked", viewport.voiLUT !== undefined);
            cornerstone.displayImage(element, image, viewport);
            if (loaded === false) {
                cornerstoneTools.mouseInput.enable(element);
                cornerstoneTools.mouseWheelInput.enable(element);
                cornerstoneTools.wwwc.activate(element, 1); // ww/wc is the default tool for left mouse button
                cornerstoneTools.pan.activate(element, 2); // pan is the default tool for middle mouse button
                cornerstoneTools.zoom.activate(element, 4); // zoom is the default tool for right mouse button
                cornerstoneTools.zoomWheel.activate(element); // zoom is the default tool for middle mouse wheel
                loaded = true;
            }

            function getTransferSyntax() {
                var value = image.data.string('x00020010');
                return value + ' [' + uids[value] + ']';
            }

            function getSopClass() {
                var value = image.data.string('x00080016');
                return value + ' [' + uids[value] + ']';
            }

            function getPixelRepresentation() {
                var value = image.data.uint16('x00280103');
                if (value === undefined) {
                    return;
                }
                return value + (value === 0 ? ' (unsigned)' : ' (signed)');
            }

            function getPlanarConfiguration() {
                var value = image.data.uint16('x00280006');
                if (value === undefined) {
                    return;
                }
                return value + (value === 0 ? ' (pixel)' : ' (plane)');
            }
        }, function (err) {
            alert(err);
        });
        /*}
         catch(err) {
         alert(err);
         }*/
    }

    jq(cornerstone).bind('CornerstoneImageLoadProgress', function (eventData) {
        jq('#loadProgress').text('Image Load Progress: ' + eventData.percentComplete + "%");
    });

    jq(document).ready(function () {

        var element = jq('#dicomImage').get(0);
        cornerstone.enable(element);


        jq('#selectFile').on('change', function (e) {
            // Add the file to the cornerstoneFileImageLoader and get unique
            // number for that file
            var file = e.target.files[0];
            var imageId = cornerstoneWADOImageLoader.fileManager.add(file);
            loadAndViewImage(imageId);
        });

        jq('#toggleModalityLUT').on('click', function () {
            var applyModalityLUT = jq('#toggleModalityLUT').is(":checked");
            console.log('applyModalityLUT=', applyModalityLUT);
            var image = cornerstone.getImage(element);
            var viewport = cornerstone.getViewport(element);
            if (applyModalityLUT) {
                viewport.modalityLUT = image.modalityLUT;
            } else {
                viewport.modalityLUT = undefined;
            }
            cornerstone.setViewport(element, viewport);
        });

        jq('#toggleVOILUT').on('click', function () {
            var applyVOILUT = jq('#toggleVOILUT').is(":checked");
            console.log('applyVOILUT=', applyVOILUT);
            var image = cornerstone.getImage(element);
            var viewport = cornerstone.getViewport(element);
            if (applyVOILUT) {
                viewport.voiLUT = image.voiLUT;
            } else {
                viewport.voiLUT = undefined;
            }
            cornerstone.setViewport(element, viewport);
        });


    });

</script>