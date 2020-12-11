<cfparam name="plant" default="HighPoint">
<cfparam name="period" default="#MonthAsString(Month(DateAdd('m',-1,now())))# #DateFormat(now(),'yyyy')#">
<cfparam name="fromSrc" default="report">
	
<cfquery name="getPeriods" datasource="cfweb">
	SELECT DISTINCT
		Month + ' ' + Year as period,
		YearMonthNo,
		Created
	FROM 
		OPS_Monthly
	ORDER BY Created Desc
</cfquery>
<cfquery name="getPlant" datasource="cfweb">
	SELECT DISTINCT
		Company
	FROM 
		CompanyList
	WHERE
		Company = <cfqueryparam value="#plant#" cfsqltype="CF_SQL_VARCHAR" maxlength="12">
</cfquery>

	
	
<!--- 
This page is meant to let users input data before the report runs, so that the data can be factored into the report.  

Because access to this portion of the UI is given BEFORE the report runs, we need to hide the main dashboard.
If the given period does not exist in OPS_Monthly, we'll hide the dash.
--->
	


<cfset hideDashFlag = 0>
<cfset periodList = ValueList(getPeriods.period)>
<cfif ListContains(periodList,period) eq 0>
	<cfset hideDashFlag = 1>
</cfif>



<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OpsDash Demo | tomfafard.com</title>
	
<style>
	
	button:focus {outline:0;}
	
	th {
		transition: 0.3s ease;
	}
	
	th:hover {
		background-color: #efefef;
	}
	
	tbody > tr:hover{
		background-color: rgba(31,58,142,0.05) !important;
	}
	
	
	tfoot tr th {
		white-space: nowrap;
	}
	
	table.dataTable tfoot th, table.dataTable tfoot td{
		padding: 5px 18px 6px 18px !important;
	}
	
	
	
	/*CUSTOM CHECKBOX*/
	
	/* Base for label styling */
	[type="checkbox"]:not(:checked),
	[type="checkbox"]:checked {
	  position: absolute;
	  left: -9999px;
	}
	[type="checkbox"]:not(:checked) + label,
	[type="checkbox"]:checked + label {
	  position: relative;
	  padding-left: 1.95em;
	  cursor: pointer;
	}

	/* checkbox aspect */
	[type="checkbox"]:not(:checked) + label:before,
	[type="checkbox"]:checked + label:before {
	  content: '';
	  position: absolute;
	  left: 0; top: 0;
	  width: 1.25em; height: 1.25em;
	  border: 2px solid #ccc;
	  background: #ededed;
	  border-radius: 4px;
	  box-shadow: inset 0 1px 3px rgba(0,0,0,.1);
	}
	/* checked mark aspect */
	[type="checkbox"]:not(:checked) + label:after,
	[type="checkbox"]:checked + label:after {
	  content: '\2713';
	  position: absolute;
	  top: .14em;
	  left: .1em;
	  font-size: 1.4em;
	  line-height: 0.8;
	  color: #275DA4;
	  transition: all .2s;
	  font-family: Helvetica, Arial, sans-serif;
	}
	/* checked mark aspect changes */
	[type="checkbox"]:not(:checked) + label:after {
	  opacity: 0;
	  transform: scale(0);
	}
	[type="checkbox"]:checked + label:after {
	  opacity: 1;
	  transform: scale(1);
	}
	/* disabled checkbox */
	[type="checkbox"]:disabled:not(:checked) + label:before,
	[type="checkbox"]:disabled:checked + label:before {
	  box-shadow: none;
	  border-color: #bbb;
	  background-color: #ddd;
	}
	[type="checkbox"]:disabled:checked + label:after {
	  color: #999;
	}
	[type="checkbox"]:disabled + label {
	  color: #aaa;
	}
	/* accessibility */
	[type="checkbox"]:checked:focus + label:before,
	[type="checkbox"]:not(:checked):focus + label:before {
	  border: 2px dotted blue;
	}

	/* hover style just for information */
	label:hover:before {
	  border: 2px solid #4778d9!important;
	}
	
	.dataTables_info{
		padding-top: 0px !important;
		position: absolute !important;
		bottom: 0 !important;
	}
	
	.typeahead__container{
		font-size: 14px !important;
	}
	
	.typeahead__field{
		color: #333333 !important;
	}
	
	.typeahead__field input{
		border-radius: 4px !important;
	}

	.formType .typeahead__result .typeahead__list{
		width: auto !important;
		left: 80px !important;
	}
	
	.formType .typeahead__field .typeahead__query .typeahead__cancel-button{
		visibility: hidden !important;
	}
	
	.sorting_1{
		background-color: rgba(234,234,234,0.5);
	}
	
	.noselect {
 		-webkit-touch-callout: none; /* iOS Safari */
    	-webkit-user-select: none; /* Safari */
    	-khtml-user-select: none; /* Konqueror HTML */
       	-moz-user-select: none; /* Firefox */
        -ms-user-select: none; /* Internet Explorer/Edge */
            user-select: none; /* Non-prefixed version, currently
                                  supported by Chrome and Opera */
		cursor: default;
	}
	
	.navbar{
		border-radius: 0 !important;
		background-color: #1B3D5A !important;
		border-color: rgba(255,255,255,0.2) !important;
	}
	
	.easyTransition {
		-webkit-transition: all 100ms linear;
		-moz-transition: all 100ms linear;
		transition: all 100ms linear;
	}
	
	.selectStyle {
		display: inline-block !important;
		width: 40% !important;
	}
	
	.inputStyle {
		display: inline-block;
	}
	
	.upperHeaderDiv {
		font-weight: bold; 
		color: #fff; 
		background-color: #1B5FA6;
		font-size: 13px;
	}
	
	.rangeStyle{
		position: absolute;
		padding-left: 12px;
		padding-top: 5px
	}
	
	.tableFootnote {
		float: right;
		padding-right: 10px;
		color: rgba(0,0,0,0.4);
		font-style: italic;
		cursor: default;
		user-select: none;
		-webkit-user-select: none;
	}
	
	.loader {
		width: 150px;
		text-align: center;
		font-size: 6em;
		color: rgba(39, 93, 164, 0.6);
		animation: spin 1s linear infinite;
	}
	
	.loader > img {
		width: inherit;
	}
	
	.spinner{
		color: #555;
		animation: spin 875ms linear infinite;
	}
	
	.filterInfo{
		cursor: help;
	}
	
	.modal-dialog{
		width: 90% !important;
	}
	
	.modal-body {
    	max-height: calc(100vh - 100px);
		overflow-y: scroll;
	}
	
	.genCSVButton{
		float: right;
		height: 20px !important;
		line-height: 0.3 !important;
		font-size: 13px !important;
		transition: 0.2s ease-in-out !important;
	}
	
	.genCSVButton:hover{
		-webkit-box-shadow: 0 0 8px limegreen;
		-moz-box-shadow: 0 0 8px limegreen;
		box-shadow: 0 0 8px limegreen;
	}
	
	.upperTableGroup{
		transition: 0.3s linear;
		margin-bottom: 3px;
	}
	
	.notifyIcon{
		position: absolute;
		top: 17px;
		left: 10px;
		font-size: 20px;
	}
	
	.itemButtonDiv{
		border-radius: 20px;
		float: left;
		padding-left: 15px;
		padding-right: 15px;
		transition: ease 0.3s;
	}
	
	.itemButtonDiv:hover, .itemButtonDiv.hovered {
		-webkit-box-shadow: 0 0 20px rgba(0,0,0,0.8);
		-moz-box-shadow: 0 0 20px rgba(0,0,0,0.8);
		box-shadow: 0 0 6px rgba(0,0,0,0.6);
		background-color: #4ABDAC;
		color: #FEFEFE;
	}
	
	
	.itemButtonDiv:hover a span{
		color: rgba(255,255,255,0.7) !important;
	}
	
	.ticketButtonDiv{
		border-radius: 20px;
		padding-left: 15px;
		padding-right: 15px;
		padding-top: 5px;
		padding-bottom: 5px;
		transition: ease 0.3s;
		display: inline-block;
	}
	
	.ticketButtonDiv:hover, .ticketButtonDiv.hovered {
		-webkit-box-shadow: 0 0 20px rgba(0,0,0,0.8);
		-moz-box-shadow: 0 0 20px rgba(0,0,0,0.8);
		box-shadow: 0 0 6px rgba(0,0,0,0.6);
		background-color: #E74339;
		color: #FEFEFE;
	}
	
	
	.modalTrigger{
		float: left;
		text-decoration: none !important;
	}
	
	.timeline__item:hover:after{
		background-color: #3F576C;
	}
	
	.timeline__content > p {
		font-size: 14px !important;
	}
	
	.timeline__content > h2 {
		font-size: 13px !important;
	}
	
	.dt-buttons{
		text-align: right !important;
		margin-bottom: 5px !important;
	}
	
	.dt-button{
		color: #fff;
		background-color: #5cb85c;
		border-color: #4cae4c;
		border: 0;
		border-radius: 5px;
		transition: 0.2s ease-in-out !important;
	}
	
	.dt-button:hover{
		-webkit-box-shadow: 0 0 8px limegreen;
		-moz-box-shadow: 0 0 8px limegreen;
		box-shadow: 0 0 8px limegreen;
	}
	
	.selectedRow {
		background-color: #A0C6E8 !important;
	}
	
	.selectedRow:hover {
		background-color: #A0C6E8 !important;
	}
	
	.thisBucketClicked {
		transform: scale(1.1) !important;
		color: #fff !important;
	}
	
	.carousel-control.left{
		filter: none;
		background-image: none !important;
		background-repeat: no-repeat !important;
		color: #3679B5 !important;
		text-shadow: 0 1px 2px !important;
	}
	
	.carousel-control.right{
		filter: none;
		background-image: none !important;
		background-repeat: no-repeat !important;
		color: #3679B5 !important;
		text-shadow: 0 1px 2px !important;
	}
	
	.carousel-control .icon-next{
		line-height: 22px !important;
		border-radius: 30px;
		border: 1px solid #444;
		box-shadow: 0 0 1px 0px #444 inset, 0 0 1px 0px #444 !important;
		background-color: #fff;
	}
	
	.carousel-control .icon-prev{
		line-height: 22px !important;
		border-radius: 30px;
		border: 1px solid #444;
		box-shadow: 0 0 1px 0px #444 inset, 0 0 1px 0px #444 !important;
		background-color: #fff;
	}
	
	.carousel-control .icon-next:before{
		padding-left: 3px !important;
	}
	
	.highcharts-data-table{
		border-bottom: 1px solid #ddd !important;
	}
	
	.highcharts-data-table > table{
		width: 50%;
		margin: 0 auto !important;
		text-align: center !important;
	}
	
	.highcharts-data-table > table > caption{
		text-align: center !important;
	}
	
	.highcharts-data-table > table > thead > tr > th{
		text-align: center !important;
	}
	
	.highcharts-data-table > table > tbody > tr > th{
		text-align: center !important;
	}
	
	.searchFilterInput {
		width: 181px !important;
		height: 34px !important;
	}
	
	.searchFilterSelect {
		margin-top: 2px;
		width: 139px !important;
		height: 34px !important;
	}
	
	.searchFilterStyle{
		display: inline;
		margin-right: 4px;
	}
	
	
	.filterHeader{
		position: absolute;
		top: -39px;
	}
	
	.searchButtonGroup{
		display: inline-flex !important;
		position: absolute;
		margin-left: 4px;
	}
	
	.form-group > label{
		width: 75px;
		text-align: right;
	}
	
	.mainCol{
		white-space: nowrap;
	}
	
	.bBorder{
		border-bottom: 1px solid #ededed;
	}
	
	.navbar-default .navbar-nav > li > a {
		color: #eee !important;
	}
	
	.navbar-default .navbar-nav > .active > a {
		color: #fff !important;
		background-color: #1B3D5A !important;
		font-weight: bold;
	}
	
	.success{
		color: #53AB58 !important;
	}
	
	.failure{
		color: #FE1E1F !important;
	}
	
	
	#navbar-uline{
		height: 3px;
		width: 33%;
		margin: 0;
		background: skyblue;
		border: none;
		transition: .3s ease-in-out;
		margin-left: 65%;
		border-top: none !important;
	}
	
	#dash:hover ~ #navbar-uline{
		margin-left: 2%;
		width: 35%;
	}
	
	#goals:hover ~ #navbar-uline{
		margin-left: 38%;
		width: 25%;
	}
	
	#dataentry:hover ~ #navbar-uline{
		margin-left: 65%;
		width: 33%;
	}
	
	
	#itemTixTable_wrapper .dt-buttons{
		position: absolute;
		z-index: 200 !important;
		right: 0px;
		top: -23px;
	}
	
	#itemTixTable_wrapper .dt-buttons > .dt-button{
		color: #000;
		background-color: rgba(255,255,255,0);
		border: 0;
		border-radius: 5px;
		transition: 0.2s ease-in-out !important;
	}
	
	#itemTixTable_wrapper .dt-buttons > .dt-button:hover{
		-webkit-box-shadow: none;
		-moz-box-shadow: none;
		box-shadow: none;
		color: #3679B5;
	}
	
	#itemTixTable_wrapper .dataTables_scroll .dataTables_scrollHead .dataTables_scrollHeadInner table thead {
		line-height: 5px !important;
		white-space: nowrap !important;
	}
	
	#itemTixTable_wrapper .dataTables_scroll .dataTables_scrollHead .dataTables_scrollHeadInner table thead tr {
		height: 5px !important;
	}
	
	#itemTixTable_wrapper{
		width: 70% !important;
		margin: 0 auto !important;
	}
	
	#itemTixTable > tbody > tr > td {
		padding: 0 !important;
	}
	
	#nav {
		user-select: none;
		-webkit-user-select: none;
		margin-bottom: 20px;
		display: block;
		float: none;
		position: relative;
		text-align: center;
	}
	
	#nav > div > a {
		width: 100%;
		height: 100%;
		text-decoration: inherit;
		color: inherit;
		cursor: inherit !important;
	}
	
	#nav > div {
		padding: 5px;
		border: 1px solid #ebebeb;
		margin: -2px;
		text-decoration: none !important;
		color: #275DA4;
		width: 40px;
		height: 100%;
		text-align: center;
		display: inline-block;
		cursor: pointer;
	}
	
	#nav > div:first-child {
		padding: 5px;
		border: 1px solid #ebebeb;
		border-top-left-radius: 8px;
		border-bottom-left-radius: 8px;
	}
	
	#nav > div:last-child {
		padding: 5px;
		border: 1px solid #ebebeb;
		border-top-right-radius: 8px;
		border-bottom-right-radius: 8px;
	}
	
	#nav > div:hover {
		background-color: #275DA4;
/*		box-shadow: 0 8px 6px -6px black;*/
		transition: ease 0.2s;
		color: #fff;
	}
	
	#brand-image {
		width: 190px;
		height: 45px;
		top: 2px;
		left: -2px;
		position: absolute;
	}
	
	#reportFilterFormDiv {
		margin: auto;
		width: 90%;
		transition: 1s ease;
	}
	
	
	#addFilterDiv{
		display: inline;
		margin-right: 3px;
	}
	
	#addFilter{
		background-color: rgba(255,255,255,0);
		border: 1px solid #C0C0C0;
	}
	
	#addFilter:hover{
		color: #fff;
		background-color: #C0C0C0;
	}
	
	#submitDiv {
		display: inline;
	}
	
	#submitBtn {
		margin-bottom: 3px !important;
		padding: 6px 12px !important;
		border-radius: 5px !important;
		background-color: #C0C0C0 !important;
	}
	
	#submitBtn:hover {
		background-color: #1B5FA6 !important;
		color: #FFF !important;
	}
	
	#plantSelect {
/*		width: 325px !important;*/
		display: block;
		height: 34px;
		padding: 6px 12px;
		font-size: 14px;
		line-height: 1.42857143;
		color: #555;
		background-color: #fff;
		background-image: none;
		border: 1px solid #ccc;
		border-radius: 4px;
		-webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
		box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
		-webkit-transition: border-color ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
		-o-transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
		transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
	}
	
	#customerRangeInput {
		width: 50px !important;
		height: 26px !important;
		text-align: center;
	}
	
	#vendorInput {
		width: 325px !important;
		display: block;
		height: 34px;
		padding: 6px 12px;
		font-size: 14px;
		line-height: 1.42857143;
		color: #555;
		background-color: #fff;
		background-image: none;
		border: 1px solid #ccc;
		border-radius: 4px;
		-webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
		box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
		-webkit-transition: border-color ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
		-o-transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
		transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
	}
	
	#vendorRangeInput {
		width: 50px !important;
		height: 26px !important;
		text-align: center;
	}
	
	#filterGradeInput {
		width: 90px !important;
		height: 22px !important;
		margin-left: 3px;
	}
	
	#rowThresholdInput{
		height: 30px !important;
		margin-left: 3px;
	}
	
	#displayFilterToggle {
		display: block;
		padding-left: 8px;
		color: black;
		margin-top: 2px;
		width: 140px;
		outline: none;
	}
	
	#displayFilterToggle:hover {
		text-decoration: none;
	}
	
	#displayFilterToggle > i {
		transition: linear 200ms;
	}
	
	#checkFilters {
		margin-top: 5px;
		padding-left: 8px;
	}
	
	#resultRow {
/*		margin-bottom: 50px;*/
		height: 20vh;
/*
		margin-right: -150px !important;
		margin-left: -150px !important;
*/
	}
	
	#resultTable_length{
		display: none;
	}
	
	#resultTable {
/*		margin-top: 30px;*/
/*		margin-bottom: 50px;*/
		table-layout:fixed;
		width: 98% !important; 
	}
	
	#resultTable > tbody > tr > td:first-child { 
		border-top-left-radius: 2px; 
		border-bottom-left-radius: 2px; 
	}
	
	#resultTable > tbody > tr > td:last-child { 
		border-top-right-radius: 2px;
		border-bottom-right-radius: 2px; 
	}
		

	
	#TableStyleContainer{
		display: inline-grid;
	}
	
	#resultDiv{
		height: 100%;
		transition: 1s ease;
	}
	

	
	#itemAnalysisDiv{
		transform: translateY(250px);
		transition: 1s ease;
	}
	
	#upperHeaderRow {
		height: 40px;
	}
	
	#headerRow {
		background-color: #5E90C4; 
		height: 20px; 
		color: #eee
	}
	
	#emailConfirm {
		background-color: #ACDAB5;
		font-size: 1.15em;
		width: 220px;
		color: rgba(255, 255, 255, 0.85);
		text-align: center;
		border-radius: 10px;
		position: absolute;
		right: 0px;
		top: 75px;
		padding: 3px;
		margin-right: 10%;
		box-shadow: 0 8px 6px -6px rgba(0,0,0,0.4);
	}
	
	#introPanel {	
		width: 100%;
		height: calc(100vh + 100px);
		top: -100px;
		position: absolute;
		background-color: #fefefe;
		z-index: 9999;
		text-align: center;
		top: 0;
		left: 0;
	}
	
	#reportTitleDiv {
		z-index: 9999;
		/*	text-align: center;*/
		/*	padding-top: 25vh;*/
		transition: ease 0.5s;
		position: absolute;
		top: 50%;
		left: 50%;
		margin-top: 150px;
		/*margin-left: 80px;*/
		width: 800px;
		transform: translate(-50%, 50%);
	}
	
	#reportTitle {
		font-size: 3.5em;
		text-align: center;
		display: block;
		transition: all 0.5s;
		font-family: Constantia, "Lucida Bright", "DejaVu Serif", Georgia, "serif"
	}
	
	#titleIcon {
		vertical-align: bottom;
	}
	
	#loader-label {
		font-size: 1.5em;
		color: rgba(0,0,0,0.6)
	}
	
	#moreButton{
		position: absolute;
		width: 75px;
		height: 75px;
		background-color: #FFF;
		bottom: -12px;
		left: 50%;
		border-radius: 50px;
		text-align: center;
		transition: ease 0.2s;
		cursor: pointer;
		border: 1px solid rgba(0,0,0,0.2);
	}
	
	#moreButton:hover{
		background-color: #1B5FA6 !important;
		color: #FFF !important;
		-webkit-box-shadow: 0 10px 6px -6px #777;
        -moz-box-shadow: 0 10px 6px -6px #777;
        box-shadow: 0 10px 6px -6px #777;
	}
	
	#moreButtonText{
		font-size: 40px;
		margin-top: 10%;
	}
	
	#moreButtonSpinner{
		font-size: 40px;
		margin-top: 1%;
		animation: spin 2s linear infinite;
	}
	
	#csvPrompt{
		transition: 0.3s linear;
		transform: translateX(-150px);
		opacity: 0;
		position: absolute;
		right: 15px;
		top: -9px;
		font-family: Verdana, "sans-serif";
	}
	
	#csvRowsInput{
		width: 55px;
		text-align: center;
	}
	
	#csvRowsSubmit{
		
	}
	
	#includeAmtechContainer{
		padding-left: 20px;
	}
	
	
	
	#notifyBox{
		position: fixed;
		width: 150px;
		height: 50px;
		color: #fff;
		right: 0;
		top: 85px;
		z-index: 9999;
		transition: ease 0.3s;
		transform: translateX(250px);
		border-top-left-radius: 5px;
		border-bottom-left-radius: 5px;
	}
	
	#notifySpinner{
		color: whitesmoke;
		animation: spin 1s linear infinite;
	}
	
	#notifySuccess{
		
	}
	
	#notifyFailure{
		
	}
	
	#orderInput {
	}
	
	#notifyMessage{
		position: absolute;
		top: 16px;
		left: 40px;
		font-size: 16px;
	}
	
	#refreshNote{
		position: absolute;
		right: 10px;
		top: 50px;
		color: rgba(211,211,211,0.6);
		font-style: italic;
	}
	
	#resultWarning{
		position: absolute;
		width: 345px;
		right: 50px;
		top: 90px;
		color: red;
		font-size: 12px;
	}
	
	#resultTable_filter > label > input{
		display: inline !important;
		width: initial !important;
	}
	
	#timelineHeader{
/*		margin: 0;*/
		text-align: center;
	}
	
	#actionButtons{
		position: absolute; 
		right: 285px; 
		top: 30px;
		z-index: 999
	}
	
	#itemButton {
		background-color: #D3D3D3;
		color: #eee;
		border-radius: 20px;
		cursor: default;
		transition: 0.2s ease-in-out;
	}
	
	#ticketButton {
		background-color: #D3D3D3;
		color: #eee;
		border-radius: 20px;
		margin-left: 5px;
		cursor: default;
		transition: 0.2s ease-in-out;
	}
	
	#itemButton.activeAction{
		background-color: #4ABDAC;
		color: #fff;
		cursor: pointer;
	}
	
	#ticketButton.activeAction{
		background-color: #269ED5;
		color: #fff;
		cursor: pointer;
	}
	
	#itemButton.activeAction:hover{
		-webkit-box-shadow: 0 0 8px #4ABDAC;
		-moz-box-shadow: 0 0 8px #4ABDAC;
		box-shadow: 0 0 8px #4ABDAC;
	}
	
	#ticketButton.activeAction:hover{
		-webkit-box-shadow: 0 0 8px #269ED5;
		-moz-box-shadow: 0 0 8px #269ED5;
		box-shadow: 0 0 8px #269ED5;
	}
	
	
	
	body{
		background-color: #eee !important;
	}
	
	hr{
		border-top: 1px solid #ddd !important;
	}
	
	#mainContain{
		padding-top: 60px; 
		width: 50% !important;
		border-left: 1px solid #ddd; 
		border-right: 1px solid #ddd;
		min-height: 100vh;
		background-color: #fefefe;
	}
	
	#mainHead{
		text-align: center;
	}
	
	#mainSub{
		text-align: center;
	}
	
	.helpBoxContainer{
		width: 91%;
		margin: 0 auto;
	}
	
	.helpBox{
		width: 100%;
		background-color: #CDEDFA;
		border-radius: 15px;
		border: 1px solid #bbb;
		display: flex;
		align-items: center;
	}
	
	.flagDiv{
		width: 10%;
		text-align: center;
		float: left;
		margin-right: 15px;
		margin-left: 10px;
		display: table;
		border-bottom-left-radius: 15px;
		border-top-left-radius: 15px;
	}
	
	.flagDiv > i{
		font-size: 24px;
		display: table-cell;
		vertical-align: middle;
		color: #4C6985;
	}
	
	.messageDiv{
		display: inline;
		padding: 10px;
	}
	
	.hideDiv{
		margin-left: auto;
		margin-right: 15px;
		cursor: pointer;
	}
	
	.messageDiv > p{
		margin: 0 auto !important;
	}
	
	.form-group > input {
		width: 50% !important;
	}
	
	.form-group > label {
		width: 150px !important;
	}
	.enterBtnContainer{
		display: inline-block;
		vertical-align: middle;
		margin-left: -30px;
		opacity: 0;
		transition: 325ms ease-in;
		position: relative;
		z-index: -1;
		transform: rotate(90deg);
	}
	
	.enterBtn{
		color: #777;
		font-size: 20px;
		cursor: pointer;
	}
	
	
	.inputHolder{
		display: inline-block;
		width: 50%;
		height: 34px;
		padding: 6px 12px;
		font-size: 14px;
		line-height: 1.42857143;
		color: #555;
		background-color: #eee;
		background-image: none;
		border: 1px solid #ccc;
		border-radius: 4px;
		-webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
		box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
	}
	

	
	@keyframes wave {
	  0%, 60%, 100% {
		transform: initial;
	  }
	  30% {
		transform: translateY(-4px);
	  }
	}


	@keyframes blink {50% { color: transparent }}
	.loader__dot { animation: 1s blink infinite }
	.loader__dot:nth-child(2) { animation-delay: 250ms }
	.loader__dot:nth-child(3) { animation-delay: 500ms }
	
	
	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
	
	@keyframes fadeBG {
	  0%   { background-color: #FFFFFF; }
	  100% { background-color: rgba(0,0,0,0); }
	}
	
	
	
	
	/* MEDIA */
	
	@media only screen and (max-width: 576px) { 
	
		#reportTitle{
			display: none;
		}
		
		#navbar > ul{
			margin-left: -15px !important;
			text-align: center
		}
		
		#navbar-uline{
			display: none;
		}
		
		.form-group > input {
			width: 100% !important;
		}
		
		.form-group > label {
			text-align: left !important;
		}
		
		#mainContain{
			width: 75% !important;
		}
	
	}
	
	
</style>
	<link href="/includes/plugins/bootstrap3/css/bootstrap.min.css" rel="stylesheet">
	<link href="/includes/plugins/basicTypeahead/jquery.typeahead.min.css" rel="stylesheet">
	<link href="/includes/plugins/fontawesome/css/all.min.css" rel="stylesheet">
	<link href="/includes/plugins/datetimepicker/jquery.datetimepicker.css" rel="stylesheet">
	<link href="/includes/plugins/webui-popover/dist/jquery.webui-popover.css" rel="stylesheet">
</head>
<body>
<cfoutput>
<cfif getPlant.recordCount>
	
	<cfset plant = getPlant.company>
	
	<cfquery name="getEntryCols" datasource="cfweb">
		SELECT OPS_Column
		FROM OPS_Goals
		WHERE Company = <cfqueryparam value="#plant#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
		AND manualEntryFlag = 1
	</cfquery>
	<cfset entryColsArr = ArrayNew(1)>
	<cfloop query="getEntryCols">
		<cfset ArrayAppend(entryColsArr,getEntryCols.OPS_Column)>
	</cfloop>
		
	<script type="text/javascript" language="JavaScript">
	<cfoutput> 
		var #toScript(plant, "plant")#;
		var #toScript(period, "period")#;
		var #toScript(entryColsArr, "entryColsArr")#;
	</cfoutput> 				
	</script>
	
	
	<nav class="navbar navbar-default navbar-fixed-top">
	  <div class="container-fluid">
		<div class="navbar-header">

			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="##navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          	</button>

		<a href="https://tomfafard.com">
			<img id="brand-image" alt="Brand" src="/includes/images/projects/shared/logo.png" draggable="false">
		</a>
		</div>
		
	  </div>
		<div class="navbar-collapse collapse" id="navbar">
			<cfif hideDashFlag eq 0>
			<ul class="nav navbar-nav" style="margin-left: 220px">
				<li class="classic-menu-dropdown " id="dash">
					<a href="OpsDash.cfm?Plant=#plant#&Period=#period#"><i class="fas fa-chart-line"></i> Dashboard <span class="selected"></span></a>
				</li>
				
				<li class="classic-menu-dropdown " id="goals">
					<a href="Ops_Goals.cfm?plant=#plant#&Period=#period#"><i class="fas fa-bullseye"></i> Goals  </a>
				</li>
                
                <li class="classic-menu-dropdown active" id="dataentry">
					<a href="Ops_UserEntry.cfm?Plant=#plant#&Period=#period#"><i class="far fa-edit"></i></i> Data Entry </a>
				</li>
				<hr id="navbar-uline">
			</ul>
			</cfif>
			<ul class="nav navbar-nav navbar-right" style="margin-right: 560px">
				<li id="nav-right" style="position: static">
					<div id="introPanel"></div>
					<div id="reportTitleDiv">
						<h1 id="reportTitle" class="noselect"><i id="titleIcon" class="far fa-edit" style="opacity: 1"></i> Data Entry</h1>
						<div class="loader" style="position: absolute;left: 40.5%"><img src="/includes/images/projects/shared/blue_loading.png"></div>
					</div>
				</li>
			</ul>
		</div>
	</nav>
	
	<div class="container" id="mainContain">
		<div class="row">
			<div class="col-sm-12">
				<h1 id="mainHead">#plant# Operations</h1>
				<h3 id="mainSub">#period# Data Entry</h3>
				
<!---
				<div id="selectSection">
					<div id="plantSelect">
						<div class="btn-group">
							<button type="button" id="plantBtn" class="form-control btn btn-default dropdown-toggle" data-toggle="dropdown">
								<span id="selectedPlant">#plant#</span> <span class="caret"></span>
							</button>
							<ul id="plantMenu" class="dropdown-menu" role="menu">
								<cfloop query="getCompany">
									<li><a href="##">#getCompany.Company#</a></li>
								</cfloop>
							</ul>
						</div>
					</div>

					<div id="reportMonthSelect">
						<div class="btn-group">
							<button type="button" id="monthBtn" class="form-control btn btn-default dropdown-toggle" data-toggle="dropdown">
								<span id="selectedMonth">#period#</span> <span class="caret"></span>
							</button>
							<ul id="monthMenu" class="dropdown-menu" role="menu">
								<cfloop query="getReportMonths">
									<li><a href="##">#getReportMonths.Month#</a></li>
								</cfloop>
							</ul>
						</div>
					</div>
					<div id="reportYearSelect">
						<div class="btn-group">
							<button type="button" id="yearBtn" class="form-control btn btn-default dropdown-toggle" data-toggle="dropdown">
								<span id="selectedYear">#getOps.Year#</span> <span class="caret"></span>
							</button>
							<ul id="yearMenu" class="dropdown-menu" role="menu">
								<cfloop query="getReportYears">
									<li><a href="##">#getReportYears.Year#</a></li>
								</cfloop>
							</ul>
						</div>
					</div>
				</div>
--->
				
				<cfif fromSrc eq 'email'>
				<div class="helpBoxContainer" style="margin-bottom: 10px">
					<div class="helpBox" style="background-color: ##FEEA8F">
						<div class="flagDiv"><i class="far fa-flag"></i></div>
						<div class="messageDiv">
						<p>After entering a value, press "enter" to submit it.</p>
						</div>
						<div class="hideDiv"><i class="fas fa-times"></i></div>
					</div>
				</div>
				
				<div class="helpBoxContainer">
					<div class="helpBox">
						<div class="flagDiv"><i class="far fa-flag"></i></div>
						<div class="messageDiv">
						<p>You are only responsible for entering the values listed in the "Entry Reminder" email.</p>
						</div>
						<div class="hideDiv"><i class="fas fa-times"></i></div>
					</div>
				</div>
					
				</cfif>
				
				<hr>
				<div id="entryFormContainer" style="padding-left: 10%">
					<form action="Ops_UserEntry.cfm" method="put" name="entryForm" id="entryForm">

						<cfloop query="getEntryCols">
							
							<cfquery name="getExistingValue" datasource="cfweb">
								SELECT value 
								FROM OPS_DataEntry_Staging
								WHERE OPS_Column = '#getEntryCols.OPS_Column#'
								AND Company = <cfqueryparam value="#plant#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
								AND Month + ' ' + Year = <cfqueryparam value="#period#" cfsqltype="CF_SQL_VARCHAR" maxlength="30">
							</cfquery>
								
								
							<cfset idname = LCase(ReReplaceNoCase(getEntryCols.OPS_Column,"_","","all"))>
							<cfif getEntryCols.OPS_Column eq 'MSF_Per_ManHour'>
								<cfset displayname = 'Man Hours'>
							<cfelseif getEntryCols.OPS_Column eq 'MSF_Per_ManHour_Overtime'>
								<cfset displayname = 'Man Hours (Overtime)'>
							<cfelse>
								<cfset displayname = REReplaceNoCase(REReplaceNoCase(REReplaceNoCase(REReplaceNoCase(getEntryCols.OPS_Column, chr(95), ' ', 'all'), 'Percent', '%', 'all'), 'Dollar', '$', 'all'), 'Per', '/', 'all')>
							</cfif>
							
								
								
								
							<div class="form-group form-inline">
								<label for="#idname#">#displayname#: </label>
								<cfif getExistingValue.value eq ''>
									
									<input type="text" id="#getEntryCols.OPS_Column#" class="form-control" name="#idname#" data-column="#getEntryCols.OPS_Column#">

									<div class="enterBtnContainer" title="click or press enter to submit">
										<i class="fas fa-level-down-alt enterBtn"></i>
									</div>
									
								<cfelse>
									
									<cfquery name="getDataType" datasource="cfweb">
										SELECT DATA_TYPE 
											FROM INFORMATION_SCHEMA.COLUMNS
											WHERE 
												 TABLE_NAME = 'OPS_Monthly' AND 
												 COLUMN_NAME = '#getEntryCols.OPS_Column#'	
									</cfquery>

									<cfswitch expression="#LEFT(getDataType.DATA_TYPE,4)#">
										<cfcase value="int">
											<cfset numFormat = ",">
										</cfcase>
										<cfcase value="deci">
											<cfset numFormat = "0.99">
										</cfcase>
										<cfdefaultcase>
											<cfset numFormat = ",">
										</cfdefaultcase>
									</cfswitch>
									
									
									<div class="inputHolder" id="#idname#">#lsNumberFormat(getExistingValue.value,numFormat)#</div>
								</cfif>
							</div>
							
							
						</cfloop>
						
						
						
						

					</form>
				</div>
				<hr>
							
				<cfif fromSrc eq 'report'>
				<div class="helpBoxContainer">
					<div class="helpBox" style="background-color: ##EFEFEF;width: 80%;margin: 0 auto">
						<div class="flagDiv"><i class="far fa-flag"></i></div>
						<div class="messageDiv">
						<p>These values are entered manually for use in the report.</p>
						</div>
					</div>
				</div>
				</cfif>		
				
			</div>
		</div>
	</div>
	
	
<cfelse>
	invalid plant
</cfif>
</cfoutput>
<script src="/includes/plugins/jquery_2.2.4/jquery-2.2.4.min.js"></script>
<script src="/includes/plugins/bootstrap3/js/bootstrap.min.js"></script>
<script src="/includes/plugins/basicTypeahead/jquery.typeahead.min.js"></script>
<script src="/includes/plugins/datetimepicker/jquery.datetimepicker.full.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/includes/plugins/webui-popover/dist/jquery.webui-popover.js" type="text/javascript"></script>
	
<script type="text/javascript">
	
	$('#introPanel').css("top",$('.navbar-fixed-top').outerHeight() + "px");
	
	//intro
	setTimeout(function(){
			$('#reportTitleDiv > div').fadeOut();

			setTimeout(function(){
				$('#reportTitleDiv').css({"z-index":"9999","position":"absolute"});
				$('#reportTitleDiv').css({"transform":"translate(0, 0)"});
				$('#reportTitleDiv').css({"margin-left":"-40px","margin-top":"-46px","left":"inherit","top":" "});
				$('#reportTitle').css({"transform":"scale(0.5)"});
				setTimeout(function (){
					$('#introPanel').css({"animation":"fadeBG ease 1s"});
					$('#reportTitle').css({"color":"#fff","text-indent":"150px"});
//					setTimeout(function (){
//						$('#titleIcon').css("opacity","1");
//					},200);
					setTimeout(function (){
						$('#introPanel').css({"background-color":"rgba(0,0,0,0)","z-index":"0","display":"none"});
//						$('#refreshNote').fadeIn(800);
					},900);
				},150); //fade speed
			},1000);

		},850);


	$(document).ready(function(){

		//Set change listener on relevant inputs
		$('.form-group').find('input').on('keyup',function() { 
			var input = $(this);
        	if(input.val() !== ''){
				input.next('.enterBtnContainer').css({"opacity":"1","z-index":"1"});
			} else {
				input.next('.enterBtnContainer').css({"opacity":"0","z-index":"-1"});
			}
   		});
		
		
		
		
		$('.hideDiv').on('click',function(){
			$(this).parent().parent().fadeOut();
		});
		
		
		//Set table for this report
		var table = 'OPS_DataEntry_Staging';
		
		
		for(var i = 0; i < entryColsArr.length; i++){
			$("#" + entryColsArr[i]).on('keyup', function (e) {
				if (e.keyCode == 13) {
					
					var thisInput = $(this);
					var thisBtn = $(this).next('.enterBtnContainer');
					
					
					var submit = doSubmit(thisInput,thisBtn);


				}
			});
		}
		
		$('.enterBtnContainer').on('click',function(){
			var thisInput = $(this).prev('input');
			var thisBtn = $(this);


			var submit = doSubmit(thisInput,thisBtn);
		});
		
		
		
		
		
function doSubmit(thisInput,thisBtn) {
	
	thisInput.css("border-color","#CCCCCC")
	thisInput.prop('disabled',true);
	
	
	if(thisInput.val().trim() !== ''){
	if(!isNaN(thisInput.val())){
		if(confirm('Please confirm whether the following value is correct. After submission, further changes must be made by IT.\n\n\t\t\t\t\t\t\t' + thisInput.val() + '\n')){

			var thisValue = thisInput.val().replace(/[^0-9.]/g, "").trim();
			var thisColumn = thisInput.data('column');

			$.ajax({
				type: "get",
				url: "OpsDash_CFC.cfc?method=setValue",
				dataType: "text",
				data: {
					value: thisValue,
					column: thisColumn,
					plant: plant,
					period: period,
					table: table
				},
				cache: false,
				success: function( data ){
					var json = data.trim();
					obj = JSON.parse(json);
					if (obj.result == 'pass') {
//											thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-check success");

						thisInput.css({"border-color":"#53AB58","background-color":"#daf2da","font-weight":"bold","text-align":"center","color":"#111111"});

						thisBtn.hide();
					} else {
						thisInput.css({"border-color":"#FE1E1F"});

						alert('Entry failed... IT has been notified.');
					}
				}
			});
		} else {
//								thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-arrow-alt-circle-right");
//								thisBtn.css("cursor","default");
			thisInput.prop('disabled',false);
		}
	} else {
//							thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-arrow-alt-circle-right");
//							thisBtn.css("cursor","default");
		thisInput.css("border-color","#FE1E1F");
		thisInput.prop('disabled',false);

		alert('Values must be numerical.');
	}
} else {
//						thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-arrow-alt-circle-right");
//						thisBtn.css("cursor","default");
	thisInput.css("border-color","#FE1E1F");
	thisInput.prop('disabled',false);

	alert('Enter a value.');
}
}
		

		
		

//		
//		$('.submitBtn').on('click',function(){
//			var thisBtn = $(this);
//			var thisInput = $(this).parent().prev('input');
//			
//			thisInput.css("border-color","#CCCCCC")
//			thisInput.prop('disabled',true);
//			thisBtn.css("cursor","not-allowed");
//			thisBtn.removeClass("far fa-arrow-alt-circle-right").addClass("far fa-spinner spinner");
//			
//			if(thisInput.val() !== ''){
//				if(!isNaN(thisInput.val())){
//					if(confirm('Please confirm whether the following value is correct. After submission, further changes must be made by IT.\n\n\t\t\t\t\t\t\t' + thisInput.val() + '\n')){
//					
//						var thisValue = thisInput.val().replace(/[^0-9.]/g, "").trim();
//						var thisColumn = thisInput.data('column');
//
//						$.ajax({
//							type: "get",
//							url: "OpsDash_CFC.cfc?method=setValue",
//							dataType: "text",
//							data: {
//								value: thisValue,
//								column: thisColumn,
//								plant: plant,
//								period: period,
//								table: table
//							},
//							cache: false,
//							success: function( data ){
//								var json = data.trim();
//								obj = JSON.parse(json);
//								if (obj.result == 'pass') {
//									thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-check success");
//									thisInput.css("border-color","#53AB58");
//								} else {
//
//								}
//							}
//						});
//					} else {
//						thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-arrow-alt-circle-right");
//						thisBtn.css("cursor","default");
//						thisInput.prop('disabled',false);
//					}
//				} else {
//					thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-arrow-alt-circle-right");
//					thisBtn.css("cursor","default");
//					thisInput.css("border-color","#FE1E1F");
//					thisInput.prop('disabled',false);
//					
//					alert('Values must be numerical.');
//				}
//			} else {
//				thisBtn.removeClass("far fa-spinner spinner").addClass("far fa-arrow-alt-circle-right");
//				thisBtn.css("cursor","default");
//				thisInput.css("border-color","#FE1E1F");
//				thisInput.prop('disabled',false);
//				
//				alert('Enter a value.');
//			}
//		});


	});
	
	
</script>
</body>
</html>
