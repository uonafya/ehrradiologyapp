<%
    ui.decorateWith("appui", "standardEmrPage")

    ui.includeJavascript("uicommons", "moment.js")
%>

<script>
jq(function(){
	jq(".radiology-tabs").tabs();
});
</script>

<div class="radiology-tabs">
    <ul>
        <li><a href="#queue">Queue</a></li>
        <li><a href="#worklist">Worklist</a></li>
    </ul>

    <div id="queue">
        ${ ui.includeFragment("radiologyapp", "queue") }
    </div>
    <div id="worklist">
        ${ ui.includeFragment("radiologyapp", "worklist", [investigations: investigations]) }
    </div>
</div>
