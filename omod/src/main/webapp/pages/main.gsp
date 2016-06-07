<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Radiology"])
	ui.includeCss("radiologyapp", "radiology.css")
    ui.includeJavascript("uicommons", "moment.js")
%>

<script>
	jq(function(){
		jq(".radiology-tabs").tabs();
		
		jq("#refresh").on("click", function(){
			if (jq('#queue').is(':visible')){
				getQueueData();
			}
			else if(jq('#worklist').is(':visible')){
				getWorklistData();
			}
			else if(jq('#results').is(':visible')){
				getResultsData();
			}
			else {
				jq().toastmessage('showErrorToast', "Tab Content not Available");
			}
		});
		
		jq("#inline-tabs li").click(function() {
			if (jq(this).attr("aria-controls") == "queue"){
				jq('#refresh a').html('<i class="icon-refresh"></i> Get Patients');
				jq('#refresh a').show(500);
				getQueueData(false);
			}
			else if (jq(this).attr("aria-controls") == "worklist"){
				jq('#refresh a').html('<i class="icon-refresh"></i> Get Worklist');
				jq('#refresh a').show(500);
				getWorklistData(false);
			}
			else if (jq(this).attr("aria-controls") == "results"){
				jq('#refresh a').html('<i class="icon-refresh"></i> Get Results');
				jq('#refresh a').show(500);
				getResultsData(false);
			}
			else if (jq(this).attr("aria-controls") == "status"){
				jq('#refresh a').hide(500);
				getBillableServices();
			}
        });
	});
</script>

<style>
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
				${ ui.includeFragment("radiologyapp", "queue") }
			</div>
			
			<div id="worklist">
				${ ui.includeFragment("radiologyapp", "worklist", [investigations: investigations]) }
			</div>
			
			<div id="results">
				${ ui.includeFragment("radiologyapp", "results") }
			</div>
			
			<div id="status">
				${ ui.includeFragment("radiologyapp", "functionalStatus") }
			</div>
		</div>
	</div>
</div>

