<cfparam name="plant" default="HighPoint">
<!---<cfparam name="period" default="#MonthAsString(Month(DateAdd('m',-1,now())))# #DateFormat(now(),'yyyy')#">--->
<cfparam name="month" default="#MonthAsString(Month(DateAdd('m',-1,now())))#">
<cfparam name="year" default="#DateFormat(DateAdd('m',-1,now()),'yyyy')#">


<cftry>

	
<cfset period = month & ' ' & year>
	
	
<cfquery name="getCompany" datasource="Corporate">
	SELECT DISTINCT
		Company,
		Company_id
	FROM 
		CompanyList
	WHERE
		Company NOT IN ('LouisvilleKY','Columbia','CoPak','DigitalHighPoint','VirginiaBeach')
	ORDER BY 
		Company_id ASC;
</cfquery>
	
<cfquery name="getPeriods" datasource="Corporate">
	SELECT DISTINCT
		Month + ' ' + Year as period,
		YearMonthNo,
		Created
	FROM 
		OPS_Monthly
	ORDER BY Created
</cfquery>
	
<cfquery name="getReportMonths" datasource="Corporate">
	SELECT DISTINCT
		Month,
		Created
	FROM 
		OPS_Monthly
	ORDER BY Created
</cfquery>
	
<cfquery name="getReportYears" datasource="Corporate">
	SELECT DISTINCT
		Year
	FROM 
		OPS_Monthly
	ORDER BY Year
</cfquery>




<!doctype html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Overview | <cfoutput>#plant#</cfoutput></title>
	
	
<link href="/css/bootstrap/bootstrap_3_3_6/bootstrap.css" rel="stylesheet">
<link href="/css/fontawesome-550/css/all.min.css" rel="stylesheet">
<link href="/WebServices/all_includes/lightslider/css/lightslider.css" rel="stylesheet">
<style>
	
		
	button:focus {outline:0;}
	
	body {
		background-color: #eee !important;
	}
	
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
	
	/*FONTS*/
	
	@font-face {
	  font-family: OpenSemi;
	  src: url(/fonts/opensans-semibold-webfont.ttf);
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
	
	.btn.disabled, .btn[disabled], fieldset[disabled] .btn{
		filter: none !important;
		opacity: 1 !important;
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
	
	.success{
		color: #53AB58;
	}
	
	.failure{
		color: #FE1E1F;
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
	
	.dropdown-menu{
		min-width: 0px !important;
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
	
	.carousel-indicators{
		bottom: 47px !important;
	}
	
	.carousel-indicators > li{
		cursor: default !important;
	}
	
	.carousel-inner{
		margin: 0 auto; 
		text-align: center;
	}
	
	.carousel-inner > .item{
		transition: transform 1.3s ease-in-out !important;
	}
	
	
	.chart {
		min-width: 320px;
/*		height: 200px;*/
		margin: 0 auto;
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
	
	#reportBody{
		position: relative;
		z-index: 1;
	}
	
	
	#navbar-uline{
		height: 3px;
		width: 35%;
		margin: 0;
		background: skyblue;
		border: none;
		transition: .3s ease-in-out;
		margin-left: 2%;
	}
	
	#dash:hover ~ #navbar-uline{
		margin-left: 2%;
		width: 35%;
	}
	
	#goals:hover ~ #navbar-uline{
		margin-left: 40%;
		width: 24%;
	}
	
	#goals.hovered ~ #navbar-uline{
		margin-left: 40%;
		width: 24%;
	}
	
	#dataentry:hover ~ #navbar-uline{
		margin-left: 65%;
		width: 33%;
	}
	
	#dataentry.hovered ~ #navbar-uline{
		margin-left: 65%;
		width: 33%;
	}
	
	#messageCarousel{
		display: inline-block;
		width: 80%;
		align-self: center;
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
	
	
	
	#costArrow{
		transition: .1s linear;
	}
	
	#costDetailToggle{
		color: #333333 !important;
		text-decoration: none !important;
	}
	
	#costDetailToggle:hover{
		color: rgba(51,51,51,0.8) !important;
	}
	
	.nopointer{
		cursor: default !important;
	}
	
	
	
	.boxSection {
		border: 1px solid #bbb;
	}

	
	.dataTrigger{
		color: inherit !important;
	}

	
	
	.posDiff{
		color: #86c48a !important
	}
	
	.negDiff{
		color: #fe6a6b !important
	}
	
	.neutralDiff{
		color: #FEC142 !important
	}
	

	
	#helpArrow{
		opacity: 0;
		transition: 250ms ease;
		animation-delay: 250ms;
		position: absolute;
		z-index: -1;
		top: 345px;
		left: 350px;
		transform: scale(2);
	}
	
	#helpArrow > i{
		font-size: 2.5em;
	}
	
	
	#iconDiv{
		width: 10%;
		height: 100%;
		text-align: center;
		float: left;
		border-right: 1px solid #bbb;
		margin-right: 15px;
		display: table;
		background-color: #4C6A87;
/*		border-top-left-radius: 15px;*/
	}
	
	#iconDiv > i{
		font-size: 2.5em;
		display: table-cell;
		vertical-align: middle;
		color: #fefefe;
	}

	
	
	#nextButton{
		height: 100%;
		width: 10%;
		text-align: center;
		border-left: 1px solid #bbb;
		display: table;
		background-color: #E8F0FD;
		border-top-right-radius: 15px;
		border-bottom-left-radius: 0px !important;
		border-top-left-radius: 0px !important;
		top: 50%;
		transform: translateY(-50%);
		position: absolute;
		right: 0;
	}
	
	#nextButton:hover{
		background-color: #e3ebf7;
		border-color: none !important;
	}
	
	#nextButton.disabled{
		opacity: 0.5 !important;
	}
	
	#iconTainer{
		display: flex;
		align-items: center;
		justify-content: center;
	}
	
	#iconTainer > i{
		display: inline-block;
		color: #343434;
		font-size: 2em;
	}

	
	#reportHeaderContainer{
		width: inherit;
		max-width: 500px;
		margin-top: 50px;
		margin-bottom: 10px;
		position: relative;
		margin-left: 20px;
		display: inline-block;
	}	

	
	#plantBtn{
		
	}
	
	#monthBtn{
		margin-left: 3px;
		border-top-right-radius: 0 !important;
		border-bottom-right-radius: 0 !important;
		border-right: 0 !important;
	}
	
	#yearBtn{
		border-top-left-radius: 0 !important;
		border-bottom-left-radius: 0 !important;
	}

	#helpButton:hover{
		color: #333;
		background-color: #e6e6e6;
		border-color: #adadad;
	}
	
	
	#headerSection{
/*		font-stretch: condensed;*/
		font-family: 'OpenSemi', sans-serif;
	}
	
	#plantHeader{
		font-size: 45px;
	}
	
	#periodHeader{
		margin-top: 0px !important;
	}
	
	#periodMenu{
		overflow: scroll;
		height: 175px;
	}
	
	
	#selectSection{
		display: inline-flex;
	}
	
	#mainContainer{
		padding-top: 30px;
		padding-bottom: 30px;
		border-top: 1px solid #ddd;
		border-bottom: 1px solid #ddd;
		background-color: #fff;
		width: auto !important;
		height: 70vh;
	}
	
	
	#chartBox{
		border: 1px solid #ddd;
		box-shadow: 0 8px 17px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
		margin-top: -70px;
		padding: 5px;
		background-color: #fff !important;
		height: 100%;
	}
	
	#dynamicChartContainer{
		border-bottom: 1px solid #ccc;
	}
	
	
	#sliderContainer {
		position: absolute;
		left: 0;
		right: 0;
		bottom: 110px;
		margin: auto;
	}
	
	.lslide, .clone {
		text-align: center !important;
		opacity: 0.2;
		transition: 200ms ease;
	}
	
	.lslide.activeCenter, .clone.activeCenter {
		opacity: 1;
	}
	
	.lSAction > a {
		border-radius: 25px !important;
		background-color: #ccc !important;
	}
	
	.lSAction > .lSPrev {
		background-position: 1px 0 !important;
	}
	
	.lSAction > .lSNext {
		background-position: -33px 0 !important;
	}
	
	
	
	#wave{
		font-size: 1em;
		line-height: 0;
	}
	
	
	#costDetailToggle:hover .detail__dot {
	  display: inline-block;
	  animation: wave 0.6s linear;
	}
	#costDetailToggle:hover .detail__dot:nth-child(2) {
	  animation-delay: 125ms;
	}
	#costDetailToggle:hover .detail__dot:nth-child(3) {
	  animation-delay: 250ms;
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
	
	@keyframes MoveLeftRight {
	  0%, 100% {
		margin-left: 0px;
	  }
	  50% {
		margin-left: 5px;
	  }
	}
	
	@keyframes MoveUpDown {
	  0%, 100% {
		margin-top: 0px;
	  }
	  50% {
		margin-top: 5px;
	  }
	}
	
	
	
	/* MEDIA */


	@media (min-width:600px) {
		#mainContainer{
			font-size: 16px !important;
		}
		#plantHeader {
			font-size: 48px !important;
		}
		#periodHeader {
			font-size: 33px !important;
		}
		.slide > span{
			font-size: 16px;
		}

	}

	@media (min-width:800px) {
	  	#mainContainer{
			font-size: 18px !important;
		}
		#plantHeader {
			font-size: 51px !important;
		}
		#periodHeader {
			font-size: 36px !important;
		}
		
		.slideHeader{
			font-size: 50px;
		}
		.slideValue{
			font-size: 40px;
		}
		
		.slide > span{
			font-size: 20px;
		}
		
	}


	@media (min-width:1000px) {
	  	#mainContainer{
			font-size: 20px !important;
		}
		#plantHeader {
			font-size: 55px !important;
		}
		#periodHeader {
			font-size: 40px !important;
		}
		
		.slideHeader{
			font-size: 60px;
		}
		.slideValue{
			font-size: 50px;
		}
		
		.slide > span{
			font-size: 25px;
		}
	}


	
	
	
	
	@media only screen and (max-width: 576px) { 

		
		body{
			background-color: #fff !important;
		}
	
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
		
		#mainContainer{
			padding-top: 100px; 
		}

		
		.datacolumn{
			padding-left: 0px !important;
			padding-right: 0px !important;
		}
	
	}
	
	
</style>
</head>
<body>
<cfoutput>
	
	<cfquery name="thisYearMonthNo" dbtype="query">
		SELECT 
			YearMonthNo
		FROM getPeriods
		WHERE Period = <cfqueryparam value="#period#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
		
	<cfquery name="minYearMonthNo" datasource="Corporate">
		SELECT TOP 1
			YearMonthNo
		FROM OPS_Monthly
		ORDER BY
			YearMonthNo
	</cfquery>
	
	<cfset theYearMonthNo = thisYearMonthNo.YearMonthNo>
	<cfset theMinYearMonthNo = minYearMonthNo.YearMonthNo>
		
		
		
	<!--- get OPS_Monthly data --->
	<cfquery name="getRelevantMetrics" datasource="Corporate">
		SELECT OPS_Column FROM OPS_Goals WHERE Company = '#plant#'  
	</cfquery>
					  
	<cfset validMetrics = ValueList(getRelevantMetrics.OPS_Column)>
		
	
	<cftransaction isolation="READ_UNCOMMITTED">
	<cfquery name="getOps" datasource="Corporate">
		SELECT 
			Company,
			Company_ID,
			PlantType,
			Month,
			Year,
			Month + ' ' + Year as Period,
			<cfloop list="#validMetrics#" index="category">
			<cfif category neq ListLast(validMetrics)>
			#category#,
			<cfelse>
			#category#
			</cfif>
			</cfloop>
		FROM OPS_MONTHLY 
		WHERE Company = <cfqueryparam value="#plant#" cfsqltype="CF_SQL_VARCHAR">
		AND YearMonthNo in ('#thisYearMonthNo.YearMonthNo#')
	</cfquery>	
	</cftransaction>
		
		
	<cfif getOps.recordcount>
	
		
		<cfif getPeriods.recordcount gte 2>
		<cftransaction isolation="READ_UNCOMMITTED">
		<cfquery name="getLastOps" datasource="Corporate">
			SELECT 
				Company,
				Company_ID,
				PlantType,
				Month,
				Year,
				Month + ' ' + Year as Period,
				<cfloop list="#validMetrics#" index="category">
				<cfif category neq ListLast(validMetrics)>
				#category#,
				<cfelse>
				#category#
				</cfif>
				</cfloop>
			FROM OPS_MONTHLY 
			WHERE Company = <cfqueryparam value="#plant#" cfsqltype="CF_SQL_VARCHAR">
			AND YearMonthNo in (<cfif RIGHT(thisYearMonthNo.YearMonthNo,2) eq 01>'#(LEFT(thisYearMonthNo.YearMonthNo,4)-1)#12'<cfelse>'#thisYearMonthNo.YearMonthNo - 1#'</cfif>)
		</cfquery>	
		</cftransaction>
		</cfif>
		<cftransaction isolation="READ_UNCOMMITTED">
		<cfquery name="getGoals" datasource="Corporate">
			SELECT 
				OPS_Column,
				COALESCE(Goal,0) as Goal,
				catgroup,
				sortorder
			FROM OPS_GOALS
			WHERE Company = <cfqueryparam value="#plant#" cfsqltype="CF_SQL_VARCHAR">
			ORDER BY
				catgroup,
				sortorder
		</cfquery>	
		</cftransaction>
		<cfset goalsStruct = StructNew()>
		<cfset sortedKeys = ArrayNew(1)>
		
		<!--- Set spacer value to offset array --->
		<cfset sortedKeys[1] = "">
		
		<cfloop query="getGoals">
			<cfif getGoals.currentRow neq getGoals.recordcount>
			
				<cfset ArrayAppend(sortedKeys,getGoals.OPS_Column)>

				<cfset structArr = ArrayNew(1)>
				<cfset structArr[1] = getGoals.Goal>
				<cfset structArr[2] = getGoals.catgroup>
				<cfset structArr[3] = getGoals.sortorder>
				<cfset goalsStruct[getGoals.OPS_Column] = structArr>
					
			<cfelse>
				
				<!--- Make last value first in array for the slideshow --->
				<cfset sortedKeys[1] = getGoals.OPS_Column>

				<cfset structArr = ArrayNew(1)>
				<cfset structArr[1] = getGoals.Goal>
				<cfset structArr[2] = getGoals.catgroup>
				<cfset structArr[3] = getGoals.sortorder>
				<cfset goalsStruct[getGoals.OPS_Column] = structArr>
				
				
			</cfif>
		</cfloop>
				
		





		<!--- Fill in 0s on missing goals --->

	<!---
		<cfloop list="#validMetrics#" index="category">
			<cfif goalsStruct[category] = ''>
				<cfset goalsStruct[category] = 0>
			</cfif>
		</cfloop>
	--->




	<!---
		<cfmail to="tfafard@carolinacontainer.com" from="tfafard@carolinacontainer.com" subject="test" type="HTML">
			<cfdump var="#goalsStruct#">
		</cfmail>
	--->



		<cfset CategoryStruct = StructNew()>
		<cfset ChartMonthList = ''>
		<cfset ChartColors = ["##7DB4EA","##BFE287","##8184E6","##F6A563"]>
		<cfset colorIndex = 1>
		<cfset lastCatGroup = "">

		<!--- Looping the report categories to get trend line data --->
		<cfloop list="#validMetrics#" index="category">

			<cftransaction isolation="READ_UNCOMMITTED">
			<cfquery name="getLineData" datasource="Corporate">
				SELECT 
					#category# as thisCategory,
					month,
					(SELECT TOP 1 catgroup FROM OPS_Goals WHERE OPS_Column = '#category#' AND OPS_Goals.Company = OPS_Monthly.Company) AS catgroup,
					(SELECT TOP 1 sortorder FROM OPS_Goals WHERE OPS_Column = '#category#' AND OPS_Goals.Company = OPS_Monthly.Company) AS sortorder,
					(SELECT TOP 1 unit FROM OPS_Goals WHERE OPS_Column = '#category#' AND OPS_Goals.Company = OPS_Monthly.Company) AS unit
				FROM OPS_MONTHLY 
				WHERE Company = <cfqueryparam value="#plant#" cfsqltype="CF_SQL_VARCHAR">
				AND Year = <cfqueryparam value="#RIGHT(period,4)#" cfsqltype="CF_SQL_VARCHAR">
				ORDER BY RIGHT(YearMonthNo,2)
			</cfquery>	
			</cftransaction>

			<cfif getLineData.recordcount AND getLineData.thisCategory neq -1>
				
				<cfif lastCatGroup neq getLineData.catgroup>
					<cfset colorIndex = 1>
				</cfif>
					
				<cfset thisColor = ChartColors[colorIndex]>

				<cfset CategoryStruct[category] = '{"name":"' & category & '", "data":['>

				<cfloop query="getLineData">
					<cfif getLineData.currentrow eq getLineData.recordcount>
						<cfset CategoryStruct[category] &= '#getLineData.thisCategory#],"color":"#thisColor#","tooltip":{"valueSuffix": " #getLineData.unit#"}}'>
						<cfif category eq listFirst(validMetrics)>
							<cfset ChartMonthList &= '#Left(getLineData.month,3)#'>
						</cfif>
					<cfelse>
						<cfset CategoryStruct[category] &= '#getLineData.thisCategory#,'>
						<!--- if to only append to ChartMonthList once to avoid duplication --->
						<cfif category eq listFirst(validMetrics)>
							<cfset ChartMonthList &= '#Left(getLineData.month,3)#,'>
						</cfif>
					</cfif>
				</cfloop>
						
				<cfset colorIndex += 1>
				<cfset lastCatGroup = getLineData.catgroup>

			<cfelse>	

				<cfset CategoryStruct[category] = 'no data'>

			</cfif>

		</cfloop>
						

		<script type="text/javascript" language="JavaScript">
		<cfoutput> 
			var #toScript(CategoryStruct, "categoryObj")#;
			var #toScript(goalsStruct, "goalsObj")#;
			var #toScript(ListToArray(ChartMonthList), "month_array")#;
			var #toScript(Right(period,4), "thisYear")#;
			var #toScript(plant, "plant")#;
			var #toScript(period, "period")#;
			var #toScript(month, "month")#;
			var #toScript(year, "year")#;
		</cfoutput> 				
		</script>




		
		<div id="reportBody">
		<nav class="navbar navbar-default navbar-fixed-top">
		  <div class="container-fluid">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="##navbar" aria-expanded="false" aria-controls="navbar">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				</button>
		<!---		  <a class="navbar-brand" href="/Webservices/CCApps.cfm/#session.urltoken#">--->
				<img id="brand-image" alt="Brand" src="/all_images/CC/CCMenuBannerAltColor.gif" draggable="false">
		<!---		  </a>--->
			</div>

		  </div>
			<div class="navbar-collapse collapse" id="navbar">
				<ul class="nav navbar-nav" style="margin-left: 220px">

				</ul>
				<ul class="nav navbar-nav navbar-right" style="margin-right: 560px">
					<li id="nav-right" style="position: static">
						<div id="introPanel"></div>
						<div id="reportTitleDiv">
							<h1 id="reportTitle" class="noselect"><i id="titleIcon" class="fas fa-chart-line" style="opacity: 1"></i> Monitor Overview</h1>
							<div class="loader" style="position: absolute;left: 40.5%"><img src="/all_images/CC/blue_loading.png"></div>
						</div>
					</li>
				</ul>
			</div>
		</nav>




		<div id="reportHeaderContainer">	
			<div id="headerSection">
				<h1 id="plantHeader">#getOps.Company#</h1>
				<h2 id="periodHeader">#getOps.Period#</h2>
			</div>
			<div id="selectSection">
				<div id="plantSelect">
					<div class="btn-group">
						<button type="button" id="plantBtn" class="form-control btn btn-default dropdown-toggle" data-toggle="dropdown">
							<span id="selectedPlant">#getOps.Company#</span> <span class="caret"></span>
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
							<span id="selectedMonth">#getOps.Month#</span> <span class="caret"></span>
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
		</div>




		<div id="mainContainer" class="container">
			<div id="mainRow" class="row" style="height: 100%">
				
				<div class="col-sm-3"></div>
				
				
				<div class="col-sm-6" style="height: 100%">
					<div id="chartBox">
						
						<div id="dynamicChartContainer"></div>
						
					</div>
				</div>
				
				
				<div id="sliderContainer">
					<ul id="lightSlider" style="display: flex;align-items: center">
						
						<cfset lastGroup = goalsStruct[sortedKeys[1]][2]>

						<cfloop from="1" to="#ArrayLen(sortedKeys)#" index="i">

							<cfset key = sortedKeys[i]>


							<!--- data type formatting --->
							<cfquery name="getDataType" datasource="Corporate">
								SELECT DATA_TYPE 
									FROM INFORMATION_SCHEMA.COLUMNS
									WHERE 
										 TABLE_NAME = 'OPS_Monthly' AND 
										 COLUMN_NAME = '#key#'	
							</cfquery>
							<cfswitch expression="#LEFT(getDataType.DATA_TYPE,4)#">
								<cfcase value="int">
									<cfset numberFormat = ",">
									<cfset decimalPlaces = 0>
								</cfcase>
								<cfcase value="deci">
									<cfset numberFormat = ".99">
									<cfset decimalPlaces = 2>
								</cfcase>
								<cfdefaultcase>
									<cfset numberFormat = ",">
									<cfset decimalPlaces = 0>
								</cfdefaultcase>
							</cfswitch>

							<!--- decorative formatting --->
							<cfset resultDecorationBefore = ''>
							<cfif FindNoCase("dollar",key) neq 0>
								<cfset resultDecorationBefore = '$'>
							</cfif>
							<cfset resultDecorationAfter = ''>
							<cfif FindNoCase("percent",key) neq 0 OR key eq 'Web_Utilization'>
								<cfset resultDecorationAfter = '%'>
							</cfif>

							<!--- determine delta direction --->
							<cfset deltasymbol = ''>
							<cfif theYearMonthNo neq theMinYearMonthNo>
								<cfif getOps[key][1] - getLastOps[key][1] gt 0>
									<cfset lastdelta = 'positive'>
									<cfset deltasymbol = '<i class="fas fa-long-arrow-alt-up " style="transform:rotate(45deg);opacity:0.8;font-size:1.2em;"></i>'>
								<cfelseif getOps[key][1] - getLastOps[key][1] eq 0>
									<cfset lastdelta = 'neutral'>
									<cfset deltasymbol = '<i class="fas fa-minus " style="opacity:0.8;width:8px;overflow:hidden;font-size:1.2em;"></i>'>
								<cfelse>
									<cfset lastdelta = 'negative'>
									<cfset deltasymbol = '<i class="fas fa-long-arrow-alt-down " style="transform:rotate(-45deg);opacity:0.8;font-size:1.2em;"></i>'>
								</cfif>
							</cfif>

							<cfif getOps[key][1] - goalsStruct[key][1] gt 0>
								<cfset goaldelta = 'positive'>
							<cfelseif getOps[key][1] - goalsStruct[key][1] eq 0>
								<cfset goaldelta = 'neutral'>
							<cfelse>
								<cfset goaldelta = 'negative'>
							</cfif>





							<cfset idname = LCase(ReReplaceNoCase(key,"_","","all"))>
							<cfset displayname = REReplaceNoCase(REReplaceNoCase(REReplaceNoCase(REReplaceNoCase(key, chr(95), ' ', 'all'), 'Percent', '%', 'all'), 'Dollar', '$', 'all'), 'Per', '/', 'all')>

			
								<!--- Slide --->
								<li class="slide" data-category="#Lcase(key)#" data-valueDecimal="#decimalPlaces#">
									<h1 class="slideHeader">#displayname#&nbsp;#deltasymbol#</h1>
									<h2 class="slideValue">#resultDecorationBefore##lsNumberFormat(getOps[key][1],numberFormat)##resultDecorationAfter#</h2>
									<cfif theYearMonthNo neq theMinYearMonthNo>
										 <cfif lastdelta eq 'positive'>
											 <span class="posDiff"><i class="fas fa-long-arrow-alt-up"></i> &##43;#lsNumberFormat(getOps[key][1] - getLastOps[key][1],numberFormat)##resultDecorationAfter#</span>
										 <cfelseif lastdelta eq 'negative'>
											 <span class="negDiff"><i class="fas fa-long-arrow-alt-down"></i> &##45;#lsNumberFormat(Abs(getOps[key][1] - getLastOps[key][1]),numberFormat)##resultDecorationAfter#</span>
										 <cfelse>
											 <span class="neutralDiff"><i class="fas fa-minus"></i> No change</span>
										 </cfif><span style="font-style: italic"> from <strong>#LEFT(getLastOps.Month,3)#</strong></span><br>
									 </cfif>
									 <span class="goalSpan">
										<cfif goalsStruct[key][1] neq 0>
										<cfif goaldelta eq 'positive'>
											 <span class="posDiff"><i class="fas fa-long-arrow-alt-up"></i> &##43;#lsNumberFormat(getOps[key][1] - goalsStruct[key][1],numberFormat)##resultDecorationAfter#</span><span style="font-style: italic"> above <strong>Goal</strong></span>
										 <cfelseif goaldelta eq 'negative'>
											 <span class="negDiff"><i class="fas fa-long-arrow-alt-down"></i> &##45;#lsNumberFormat(Abs(getOps[key][1] - goalsStruct[key][1]),numberFormat)##resultDecorationAfter#</span><span style="font-style: italic"> under <strong>Goal</strong></span>
										 <cfelse>
											 <span class="neutralDiff">On Target!</span> <span>Goal: <strong>#lsNumberFormat(goalsStruct[key][1],numberFormat)#</strong></span>
										 </cfif>
										 <cfelse>
											 Set Goal to track progress
										 </cfif>
									</span>
								</li>



							
							<cfset lastGroup = goalsStruct[key][2]>
						</cfloop>
											
											
					</ul>
				</div>
				
				<div class="col-sm-3"></div>
					
			</div>


			</div> <!--- mainRow --->
		</div> <!--- container --->


		</div>

<cfelse>
	No data!
</cfif>

	
</cfoutput>
<script src="/WebServices/all_includes/jquery/jquery-2.2.4.min.js"></script>
<script src="/js/Bootstrap/bootstrap_3_3_6/bootstrap.min.js"></script>
<script src="/WebServices/all_includes/lightslider/js/lightslider.js"></script>
<script src="https://code.highcharts.com/highcharts.js"></script>
<script type="text/javascript">
	
	$('#introPanel').css("top",$('.navbar-fixed-top').outerHeight() + "px");
	
	$(document).ready(function(){
		
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
					setTimeout(function (){
						$('#introPanel').css({"background-color":"rgba(0,0,0,0)","z-index":"0","display":"none"});
					},900);
				},150); //fade speed
			},1000);

		},850);
		
		
		
		
		
		
		//  Convert dropdown menus to selects
		
		
		
		//  Select Plant
		$('#plantMenu a').on('click', function(){    
    		$('.dropdown-toggle > #selectedPlant').html($(this).html());
			
			var thisUrlString = '/webservices/reports/ops/opsdash_monitor.cfm?plant=' + $(this).html() + '&month=' + month + '&year=' + year;
			
			window.location = thisUrlString;
			
			//  code to reload page with selected plant's data
		});
		
		//  Select month
		$('#monthMenu a').on('click', function(){    
    		$('.dropdown-toggle > #selectedMonth').html($(this).html());
			
			var thisUrlString = '/webservices/reports/ops/opsdash_monitor.cfm?plant=' + plant + '&month=' + $(this).html() + '&year=' + year;
			
			window.location = thisUrlString;
			
			//  code to reload page with selected period's data
		});
		
		//  Select year
		$('#yearMenu a').on('click', function(){    
    		$('.dropdown-toggle > #selectedYear').html($(this).html());
			
			var thisUrlString = '/webservices/reports/ops/opsdash_monitor.cfm?plant=' + plant + '&month=' + month + '&year=' + $(this).html();
			
			window.location = thisUrlString;
			
			//  code to reload page with selected period's data
		});
		
		
		
		
		
		
		
		// Slideshow
		$("#lightSlider").lightSlider({
			slideMargin: 300,
			autoWidth: false,
			adaptiveHeight: false,
			auto: true,
			loop: true,
			speed: 800,
			pause: 10000,
			pauseOnHover: true,
			onBeforeSlide: function (el) {
			
			},
			onAfterSlide: function (el) {
				el.children('.activeCenter').removeClass('activeCenter')
				setTimeout(function() {
					var $thisLi = el.children('.active').next();
					
					// add class to set active slide
					$thisLi.addClass('activeCenter');
					
					
					// update chart
					var thisCategory = $thisLi.data('category');
					var valueDecimal = $thisLi.data('valueDecimal');
					var thisSeries = categoryObj[thisCategory];


					thisSeries = '[' + thisSeries + ']';

					thisSeries = JSON.parse(thisSeries);

					var thisGoal = goalsObj[thisCategory][0];


					var goalLine;
					if(thisGoal != 0){
						goalLine = '[{"color": "#E9B481","width": 2,"value": ' + thisGoal + ',"label": {"text": "GOAL","align":"right","style": {"color": "#E9B481"},"y": 3,"x": 38}}]';
						goalLine = JSON.parse(goalLine);
					} else {
						goalLine = null;
					}



					thisSeries[0]["name"] = thisSeries[0]["name"].replace(/_/g,' ');
					thisSeries[0]["name"] = thisSeries[0]["name"].replace(/Percent/g,'%');
					thisSeries[0]["name"] = thisSeries[0]["name"].replace(/Dollar/g,'$');
					thisSeries[0]["name"] = thisSeries[0]["name"].replace(/Per/g,'/');


					var thisMax = Math.ceil(Math.max(...thisSeries[0]["data"]));
					
					$('#dynamicChartContainer').empty();


					$('<div class="chart">')
						.appendTo('#dynamicChartContainer')
						.highcharts({

							chart: {
								scrollablePlotArea: {

								},
								marginRight: 70,
								marginLeft: 90, // Keep all charts left aligned
								spacingTop: 20,
								spacingBottom: 20,
								type: 'line',
								height: thisChartHeight
							},

							title: null,

							subtitle: null,

							lang: {
								numericSymbols: ['k', 'M', 'G', 'T', 'P', 'E']
							},

							credits: {
								enabled: false
							},
						
							legend: {
								align: 'left',
								verticalAlign: 'top',
								borderWidth: 0,
								itemStyle: {
									fontSize:'30px'
								}
							},



							xAxis: {
								categories: month_array,
								labels: {
									style: {
										fontSize:'25px'
									}
								},
								crosshair: {
									width: 1,
									color: '#cccccc'
								}
							},

							yAxis: [{
								title: {
									text: null
								},
								labels: {
									formatter: function() {
									  if ( this.value > 1000 ) return Highcharts.numberFormat( this.value/1000, 1) + "K";  // maybe only switch if > 1000
									  return Highcharts.numberFormat(this.value,valueDecimal);
									},
									style: {
										fontSize:'20px'
									}
								},
								//min: 0,
								//max: thisMax,
								showFirstLabel: false,
								plotLines: goalLine
							}],

							tooltip: {
								positioner: function () {
									return {
										x: this.chart.chartWidth - this.label.width, // right aligned
										y: -1 // align to title
									};
								},
								borderWidth: 0,
								backgroundColor: 'none',
								pointFormat: '{point.y}',
								headerFormat: '',
								shadow: false,
								style: {
									fontSize: '18px'
								},
								valueDecimals: valueDecimal //decimal places
							},

			//					tooltip: {
			//						shared: true,
			//						crosshairs: false,
			//						formatter: function() {
			//						   var s = '<strong>' + this.x +'</strong>';
			//
			//						   var sortedPoints = this.points.sort(function(a, b){
			//								 return ((a.y > b.y) ? -1 : ((a.y < b.y) ? 1 : 0));
			//							 });
			//						   $.each(sortedPoints , function(i, point) {
			//						   s += '<br/>' + '<span style="color:' + point.series.color + '">\u25CF</span> ' + point.series.name +': ' + point.y.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
			//						   });
			//
			//						   return s;
			//						}
			//					},


							plotOptions: {
								series: {
									cursor: 'pointer',
									lineWidth: 5,
									marker: {
										lineWidth: 0.5,
										radius: 7
									},
									animation: {
										duration: 1000
									}
								}
							},
							exporting: { enabled: false },

							series: thisSeries
					});
					
					
					
					
					
					
					
					
					
				},200)
			}
			
		});
		
		$("#lightSlider").children('.active').next().addClass('activeCenter');
		
		
		
		
		
		
//		var thisCatGroup = "a";
//		var valueDecimal = 0;
//		
//		var objectLength = Object.keys(categoryObj[thisCatGroup]).length;
		var thisChartHeight = ($('#chartBox').outerHeight()) - ($('#sliderContainer').outerHeight());
		thisChartHeight = thisChartHeight + "px";
//		
		//console.log(thisChartHeight)
		
			
	
		
		var thisCategory = "msf_shipped";
		var valueDecimal = 0;
		var thisSeries = categoryObj[thisCategory];
		
		console.dir(categoryObj);
		console.dir(thisSeries);

		thisSeries = '[' + thisSeries + ']';

		

		thisSeries = JSON.parse(thisSeries);

		var thisGoal = goalsObj[thisCategory][0];


		var goalLine;
		if(thisGoal != 0){
			goalLine = '[{"color": "#E9B481","width": 2,"value": ' + thisGoal + ',"label": {"text": "GOAL","align":"right","style": {"color": "#E9B481"},"y": 3,"x": 38}}]';
			goalLine = JSON.parse(goalLine);
		} else {
			goalLine = null;
		}



		thisSeries[0]["name"] = thisSeries[0]["name"].replace(/_/g,' ');
		thisSeries[0]["name"] = thisSeries[0]["name"].replace(/Percent/g,'%');
		thisSeries[0]["name"] = thisSeries[0]["name"].replace(/Dollar/g,'$');
		thisSeries[0]["name"] = thisSeries[0]["name"].replace(/Per/g,'/');


		var thisMax = Math.ceil(Math.max(...thisSeries[0]["data"]));


		$('<div class="chart">')
			.appendTo('#dynamicChartContainer')
			.highcharts({

				chart: {
					scrollablePlotArea: {

					},
					marginRight: 70,
					marginLeft: 90, // Keep all charts left aligned
					spacingTop: 20,
					spacingBottom: 20,
					type: 'line',
					height: thisChartHeight
				},

				title: null,

				subtitle: null,

				lang: {
					numericSymbols: ['k', 'M', 'G', 'T', 'P', 'E']
				},

				credits: {
					enabled: false
				},
				legend: {
					align: 'left',
					verticalAlign: 'top',
					borderWidth: 0,
					itemStyle: {
						fontSize:'30px'
					},
					margin: 30
				},


				xAxis: {
					categories: month_array,
					labels: {
						style: {
							fontSize:'25px'
						}
					},
					crosshair: {
						width: 1,
						color: '#cccccc'
					}
				},

				yAxis: [{
					title: {
						text: null
					},
					labels: {
						formatter: function() {
						  if ( this.value > 1000 ) return Highcharts.numberFormat( this.value/1000, 1) + "K";  // maybe only switch if > 1000
						  return Highcharts.numberFormat(this.value,valueDecimal);
						},
						style: {
							fontSize:'20px'
						}
					},
					//min: 0,
					//max: thisMax,
					showFirstLabel: false,
					plotLines: goalLine
				}],

				tooltip: {
					positioner: function () {
						return {
							x: this.chart.chartWidth - this.label.width, // right aligned
							y: -1 // align to title
						};
					},
					borderWidth: 0,
					backgroundColor: 'none',
					pointFormat: '{point.y}',
					headerFormat: '',
					shadow: false,
					style: {
						fontSize: '18px'
					},
					valueDecimals: valueDecimal //decimal places
				},



//					tooltip: {
//						shared: true,
//						crosshairs: false,
//						formatter: function() {
//						   var s = '<strong>' + this.x +'</strong>';
//
//						   var sortedPoints = this.points.sort(function(a, b){
//								 return ((a.y > b.y) ? -1 : ((a.y < b.y) ? 1 : 0));
//							 });
//						   $.each(sortedPoints , function(i, point) {
//						   s += '<br/>' + '<span style="color:' + point.series.color + '">\u25CF</span> ' + point.series.name +': ' + point.y.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
//						   });
//
//						   return s;
//						}
//					},


				plotOptions: {
					series: {
						cursor: 'pointer',
						lineWidth: 5,
						marker: {
							lineWidth: 0.5,
							radius: 7
						},
						animation: {
							duration: 1000
						}
					}
				},
				exporting: { enabled: false },

				series: thisSeries
		});


//			var containerWidth = $('#chartBox').outerWidth();
//			var containerHeight = $('#chartBox').outerHeight();

			//thisChart.setSize(containerWidth-10, containerHeight-10);
			

		
		
		
		
		
		
		
	});
		
</script>
</body>
</html>
												
	
<cfcatch>
	<cfmail to="tfafard@carolinacontainer.com" from="tfafard@carolinacontainer.com" subject="Failed: Operations Monitor" type="HTML">
		<cfdump var="#cfcatch#">
	</cfmail>
</cfcatch>
</cftry>												

