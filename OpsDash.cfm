<cfparam name="plant" default="HighPoint">
<!---<cfparam name="period" default="#MonthAsString(Month(DateAdd('m',-1,now())))# #DateFormat(now(),'yyyy')#">--->
<cfparam name="month" default="#MonthAsString(Month(DateAdd('m',-1,now())))#">
<cfparam name="year" default="#DateFormat(DateAdd('m',-1,now()),'yyyy')#">
	
<cftry>	
	
	
<cfset period = month & ' ' & year>
	

<cfquery name="getCompany" datasource="cfweb">
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
	
<cfquery name="getPeriods" datasource="cfweb">
	SELECT DISTINCT
		Month + ' ' + Year as period,
		YearMonthNo,
		Created
	FROM 
		OPS_Monthly
	ORDER BY Created
</cfquery>
	
<cfquery name="getReportMonths" datasource="cfweb">
	SELECT DISTINCT
		Month,
		Created
	FROM 
		OPS_Monthly
	ORDER BY Created
</cfquery>
	
<cfquery name="getReportYears" datasource="cfweb">
	SELECT DISTINCT
		Year
	FROM 
		OPS_Monthly
	ORDER BY Year
</cfquery>
	

<!--- if user selects invalid period, set to latest available--->
<cfset periodList = ValueList(getPeriods.period)>
<cfif ListContains(periodList,period) eq 0>
	<cfset period = ListLast(periodList)>
</cfif>


	
<!---
<cfquery name="getLastUpdate" datasource="cfweb">
	SELECT TOP 1 created FROM Sales_Inventory_Snap
</cfquery>
--->
	
	

<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OpsDash Demo | tomfafard.com</title>
	

<link href="OpsDash.css" rel="stylesheet">

<link href="/includes/plugins/bootstrap3/css/bootstrap.min.css" rel="stylesheet">
<link href="/includes/plugins/basicTypeahead/jquery.typeahead.min.css" rel="stylesheet">
<link href="/includes/plugins/fontawesome/css/all.min.css" rel="stylesheet">
<link href="/includes/plugins/datetimepicker/jquery.datetimepicker.css" rel="stylesheet">
<link href="/includes/plugins/webui-popover/dist/jquery.webui-popover.css" rel="stylesheet">
<link href="/includes/plugins/DataTables/datatables.min.css" rel="stylesheet">
<link href="/includes/plugins/timelinejs/timeline.min.css" rel="stylesheet">
</head>
<body>
<cfoutput>

	
	<cfquery name="thisYearMonthNo" dbtype="query">
		SELECT 
			YearMonthNo
		FROM getPeriods
		WHERE Period = <cfqueryparam value="#period#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
		
	<cfquery name="minYearMonthNo" datasource="cfweb">
		SELECT TOP 1
			YearMonthNo
		FROM OPS_Monthly
		ORDER BY
			YearMonthNo
	</cfquery>
	
	<cfset theYearMonthNo = thisYearMonthNo.YearMonthNo>
	<cfset theMinYearMonthNo = minYearMonthNo.YearMonthNo>
		
		
		
	<!--- get OPS_Monthly data --->
	<cfquery name="getRelevantMetrics" datasource="cfweb">
		SELECT OPS_Column FROM OPS_Goals WHERE Company = '#plant#'  
	</cfquery>
					  
	<cfset validMetrics = ValueList(getRelevantMetrics.OPS_Column)>
		
	
	<cftransaction isolation="READ_UNCOMMITTED">
	<cfquery name="getOps" datasource="cfweb">
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
		<cfquery name="getLastOps" datasource="cfweb">
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
		<cfquery name="getGoals" datasource="cfweb">
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
		<cfloop query="getGoals">
			<cfset ArrayAppend(sortedKeys,getGoals.OPS_Column)>

			<cfset structArr = ArrayNew(1)>
			<cfset structArr[1] = getGoals.Goal>
			<cfset structArr[2] = getGoals.catgroup>
			<cfset structArr[3] = getGoals.sortorder>
			<cfset goalsStruct[getGoals.OPS_Column] = structArr>
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
			<cfquery name="getLineData" datasource="cfweb">
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

				<cfset CategoryStruct[getLineData.catgroup][getLineData.sortorder][category] = '{"name":"' & category & '", "data":['>

				<cfloop query="getLineData">
					<cfif getLineData.currentrow eq getLineData.recordcount>
						<cfset CategoryStruct[getLineData.catgroup][getLineData.sortorder][category] &= '#getLineData.thisCategory#],"color":"#thisColor#","tooltip":{"valueSuffix": " #getLineData.unit#"}}'>
	<!---
						<cfif FindNoCase(getLineData.month,period) neq 0>
							<cfset CategoryStruct[category] &= '{ "marker": {"fillColor": "##3679B5","lineWidth": 3,"lineColor": "##3679B5"},"y":#getLineData.thisCategory#}]}'>
						<cfelse>
							<cfset CategoryStruct[category] &= '#getLineData.thisCategory#]}'>
						</cfif>
	--->
						<cfif category eq listFirst(validMetrics)>
							<cfset ChartMonthList &= '#Left(getLineData.month,3)#'>
						</cfif>
					<cfelse>
						<cfset CategoryStruct[getLineData.catgroup][getLineData.sortorder][category] &= '#getLineData.thisCategory#,'>
	<!---
						<cfif FindNoCase(getLineData.month,period) neq 0>
							<cfset CategoryStruct[category] &= '{ "marker": {"fillColor": "##3679B5","lineWidth": 3,"lineColor": "##3679B5"},"y":#getLineData.thisCategory#},'>
						<cfelse>
							<cfset CategoryStruct[category] &= '#getLineData.thisCategory#,'>
						</cfif>
	--->
						<!--- if to only append to ChartMonthList once to avoid duplication --->
						<cfif category eq listFirst(validMetrics)>
							<cfset ChartMonthList &= '#Left(getLineData.month,3)#,'>
						</cfif>
					</cfif>
				</cfloop>
						
				<cfset colorIndex += 1>
				<cfset lastCatGroup = getLineData.catgroup>

			<cfelse>	

				<cfset CategoryStruct[getLineData.catgroup][getLineData.sortorder][category] = 'no data'>

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




		<div id="spotlight" class="spotlight"></div>
		<div id="fauxMouse"><i class="fas fa-mouse-pointer"></i></div>
		<div id="helpArrow"><i class="fas fa-arrow-alt-circle-right"></i></div>
		<div id="tutorialBox" class="tutorialBox">
			<div id="iconDiv"><i class="far fa-question-circle"></i></div>

			<div id="messageCarousel" class="carousel slide" data-ride="carousel" data-interval="false">
			  <!-- Wrapper for slides -->
			  <div class="carousel-inner">
				<div class="item active" id="message1">
				  <div class="tutorialMessage">
					  <p>Hover over a data point to see progress</p>
				  </div>
				</div>

				<div class="item" id="message2">
				  <div class="tutorialMessage">
					  <p>Click on data to show its Trend Line</p>
				  </div>
				</div>

				<div class="item" id="message3">
				  <div class="tutorialMessage">
					  <p>Performance goals are updated here</p>
				  </div>
				</div>

				<div class="item" id="message4">
				  <div class="tutorialMessage">
					  <p>Data that is entered in manually can be viewed here</p>
				  </div>
				</div>

				<div class="item" id="message5">
				  <div class="tutorialMessage">
					  <p>This button emails a spreadsheet of the data</p>
				  </div>
				</div>
			  </div>
			  <!-- Indicators -->
			  <ol class="carousel-indicators">
				<li class="active"></li>
				<li ></li>
				<li ></li>
				<li ></li>
				<li ></li>
			  </ol>
			</div>

			<button id="nextButton" class="btn"><div id="iconTainer"><i class="far fa-arrow-alt-circle-right"></i></div></button>
		</div>
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
			<a href="https://tomfafard.com">
				<img id="brand-image" alt="Brand" src="/includes/images/projects/shared/logo.png" draggable="false">
			</a>
			</div>

		  </div>
			<div class="navbar-collapse collapse" id="navbar">
				<ul class="nav navbar-nav" style="margin-left: 220px">
					<li class="classic-menu-dropdown active" id="dash">
						<a href="OpsDash.cfm?Plant=#plant#&Period=#period#"><i class="fas fa-chart-line"></i> Dashboard <span class="selected"></span></a>
					</li>

					<li class="classic-menu-dropdown " id="goals">
						<a href="Ops_Goals.cfm?plant=#plant#&Period=#period#"><i class="fas fa-bullseye"></i> Goals  </a>
					</li>

					<li class="classic-menu-dropdown " id="dataentry">
						<a href="Ops_UserEntry.cfm?Plant=#plant#&Period=#period#"><i class="far fa-edit"></i></i> Data Entry </a>
					</li>
					<hr id="navbar-uline">
				</ul>
				<ul class="nav navbar-nav navbar-right" style="margin-right: 560px">
					<li id="nav-right" style="position: static">
						<div id="introPanel"></div>
						<div id="reportTitleDiv">
							<h1 id="reportTitle" class="noselect"><i id="titleIcon" class="fas fa-chart-line" style="opacity: 1"></i> Plant Operations</h1>
							<div class="loader" style="position: absolute;left: 40.5%"><img src="/includes/images/projects/shared/blue_loading.png"></div>
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
			<div id="reportCSVContainer">
				<button id="csvButton" class="btn"><i class="far fa-envelope"></i><span id="csvLabel">Email Spreadsheet</span></button>	
			</div>
		</div>


		<div id="helpContainer">
			<button id="helpButton" class="btn"><i class="fas fa-question"></i></button>	
		</div>



		<cfset flag = '#getOps.PlantType#'>


		<div id="mainContainer" class="container">
			<div id="mainRow" class="row" style="height: 100%">
				
				
				<div class="col-sm-4 col-sm-push-4" style="height: 100%">
					<div id="chartBox">
						<div id="dynamicChartContainer"></div>
					</div>
				</div>


				<div class="col-sm-4 col-sm-pull-4">
					<div id="miscbox1Container">

						<cfset lastGroup = goalsStruct[sortedKeys[1]][2]>
						<cfset columnClass = 'miscbox1'>
						<cfset lmv = 'Left'>
						<cfset pushClass = ''>
						<cfset pullClass = ''>

						<cfloop from="1" to="#ArrayLen(sortedKeys)#" index="i">

							<cfset key = sortedKeys[i]>


							<!--- data type formatting --->
							<cfquery name="getDataType" datasource="cfweb">
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

							<!--- determine delta directions --->
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

							<cfif lastGroup neq goalsStruct[key][2]>
								<!--- Different group --->
								<cfif Compare("d",goalsStruct[key][2]) eq -1>
									<cfif columnClass neq 'miscbox2'>
										<!--- Current group gt "d", start righthand column --->
											</div> <!--- misc box 1 container --->				
										</div><!--- end col --->
										<div class="col-sm-4"> <!--- begin righthand col --->
											<div id="miscbox2Container">

										<cfset columnClass = 'miscbox2'>
										<cfset lmv = 'Right'>
										<cfset pushClass = 'col-sm-push-6'>
										<cfset pullClass = 'col-sm-pull-6'>
									<cfelse>
										<div class="row">
											<div class="col-sm-12">
												&nbsp;
											</div>
										</div>
									</cfif>
								<cfelse>
									<!--- Current group lt "d", stay in left column but add spacer --->
									<div class="row">
										<div class="col-sm-12">
											&nbsp;
										</div>
									</div>
								</cfif>	
							</cfif>


							<div class="row" id="#idname#Section">


								<div class="col-sm-6 datacolumn #pushClass#" style="padding: 0px">
									<div id="#idname#Header" class="#columnClass#Header">
										<span id="#idname#Label">
											<cfif columnClass eq 'miscbox2'>
											#deltasymbol#&nbsp;
											</cfif>
											#displayname#
											<cfif columnClass eq 'miscbox1'>
											&nbsp;#deltasymbol#
											</cfif>
											&nbsp;
										</span>
									</div>
								</div>
	

								<div class="col-sm-6 datacolumn #pullClass#" style="padding: 0px">
									<div id="#idname#Detail" class="#columnClass#Detail">
										<a href="##" class="dataTrigger"><span id="#idname#Value" data-category="#LCase(key)#" data-catgroup="#goalsStruct[key][2]#" data-valueDecimal="#decimalPlaces#">#resultDecorationBefore##lsNumberFormat(getOps[key][1],numberFormat)##resultDecorationAfter#
										 <span id="#idname#Last" class="lastMonthValue#lmv#">
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
										</span></span></span></a>
									</div>
								</div>

							</div>

					<cfset lastGroup = goalsStruct[key][2]>
				</cfloop>
				</div> <!--- misc box 2 container --->
			</div>


			</div> <!--- mainRow --->
		</div> <!--- container --->


		</div>

<cfelse>
	No data!
</cfif>
	
	
	
<!---
	<div id="sdmsfBox" class="container box">
						<div id="sdmsfBoxContent" class="row">
							<div class="col-sm-6">
								<div id="sdmsfSection" class="boxSection">
									<div id="sdmsfHeader" class="boxHeader">
										<span id="sdmsfLabel">Sales$ / MSF</span>
									</div>
									<div id="sdmsfDetail" class="boxDetail">
										<span id="sdmsfValue">I'm SD/MSF!</span>
									</div>
								</div>
							</div>
							<div class="col-sm-6">
								<div id="purchmsfSection" class="boxSection">
									<div id="purchmsfHeader" class="boxHeader">
										<span id="purchmsfLabel">Purchased$ / MSF</span>
									</div>
									<div id="purchmsfDetail" class="boxDetail">
										<span id="purchmsfValue">I'm PD/MSF!</span>
									</div>
								</div>
							</div>
						</div>
					</div>
--->
	
	
	
	

	
</cfoutput>	
<script src="/includes/plugins/jquery_2.2.4/jquery-2.2.4.min.js"></script>
<script src="/includes/plugins/bootstrap3/js/bootstrap.min.js"></script>
<script src="/includes/plugins/basicTypeahead/jquery.typeahead.min.js"></script>
<script src="/includes/plugins/datetimepicker/jquery.datetimepicker.full.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/includes/plugins/webui-popover/dist/jquery.webui-popover.js" type="text/javascript"></script>
<script src="/includes/plugins/DataTables/datatables.min.js" type="text/javascript"></script>
<script src="/includes/plugins/DataTables/dataTables.buttons.min.js" type="text/javascript"></script>
<script src="/includes/plugins/DataTables/buttons.html5.min.js" type="text/javascript"></script>
<script src="/includes/plugins/DataTables/buttons.flash.min.js" type="text/javascript"></script>
<!---<script src="/WebServices/all_includes/DataTables/dynamicHeight/dataTables.pageResize.min.js" type="text/javascript"></script>--->
<!---<script src="/WebServices/all_includes/timelinejs/timeline.min.js" type="text/javascript"></script>--->

<!--- Highcharts --->
<script src="https://code.highcharts.com/highcharts.js"></script>
<!---
<script src="/WebServices/all_includes/Highcharts-6/code/highcharts.js"></script>
<script src="/WebServices/all_includes/Highcharts-6/code/modules/series-label.js"></script>
<script src="/WebServices/all_includes/Highcharts-6/code/modules/exporting.js"></script>
<script src="/WebServices/all_includes/Highcharts-6/code/modules/export-data.js"></script>
--->
<!--- Additional files for the Highslide popup effect --->
<!---
<script src="https://www.highcharts.com/media/com_demo/js/highslide-full.min.js"></script>
<script src="https://www.highcharts.com/media/com_demo/js/highslide.config.js" charset="utf-8"></script>
<link rel="stylesheet" type="text/css" href="https://www.highcharts.com/media/com_demo/css/highslide.css" />
--->
<script type="text/javascript">
	
	$('#introPanel').css("top",$('.navbar-fixed-top').outerHeight() + "px");
	
	$(document).ready(function(){
		
		var areweready = 1;
		
//		var firstRunItem = 1;
//		var firstRunTicket = 1;

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
		
		
		
		//  Convert dropdown menus to selects
		
		
		
		//  Select Plant
		$('#plantMenu a').on('click', function(){    
    		$('.dropdown-toggle > #selectedPlant').html($(this).html());
			
			var thisUrlString = '/coldfusion/ops/opsdash.cfm?plant=' + $(this).html() + '&month=' + month + '&year=' + year;
			
			window.location = thisUrlString;
			
			//  code to reload page with selected plant's data
		});
		
		//  Select month
		$('#monthMenu a').on('click', function(){    
    		$('.dropdown-toggle > #selectedMonth').html($(this).html());
			
			var thisUrlString = '/coldfusion/ops/opsdash.cfm?plant=' + plant + '&month=' + $(this).html() + '&year=' + year;
			
			window.location = thisUrlString;
			
			//  code to reload page with selected period's data
		});
		
		//  Select year
		$('#yearMenu a').on('click', function(){    
    		$('.dropdown-toggle > #selectedYear').html($(this).html());
			
			var thisUrlString = '/coldfusion/ops/opsdash.cfm?plant=' + plant + '&month=' + month + '&year=' + $(this).html();
			
			window.location = thisUrlString;
			
			//  code to reload page with selected period's data
		});
		
		
		
		
		
		
		
		 /**
		 * In order to synchronize tooltips and crosshairs, override the
		 * built-in events with handlers defined on the parent element.
		 */
		$('#dynamicChartContainer').bind('mousemove touchmove touchstart', function (e) {
			var chart,
				point,
				i,
				event;

			for (i = 0; i < Highcharts.charts.length; i = i + 1) {
				chart = Highcharts.charts[i];
				event = chart.pointer.normalize(e.originalEvent); // Find coordinates within the chart
				point = chart.series[0].searchPoint(event, true); // Get the hovered point

				if (point) {
					point.highlight(e);
				}
			}
		});
		/**
		 * Override the reset function, we don't need to hide the tooltips and crosshairs.
		 */
		Highcharts.Pointer.prototype.reset = function () {
			return undefined;
		};

		/**
		 * Highlight a point by showing tooltip, setting hover state and draw crosshair
		 */
		Highcharts.Point.prototype.highlight = function (event) {
			this.onMouseOver(); // Show the hover marker
			this.series.chart.tooltip.refresh(this); // Show the tooltip
			this.series.chart.xAxis[0].drawCrosshair(event, this); // Show the crosshair
		};
		
		
		
		
		
		
		
		//  Trend Line
		var thisCatGroup = "a";
		var valueDecimal = 0;
		
		var objectLength = Object.keys(categoryObj[thisCatGroup]).length;
		var thisChartHeight = ($('#chartBox').outerHeight() - 20) / objectLength;
		thisChartHeight = thisChartHeight + "px";
		
		//console.log(thisChartHeight) 
		
		$.each(categoryObj[thisCatGroup], (key, value) => {
			
			var thisCategory = Object.keys(value)[0];
			var thisSeries = Object.values(value)[0];
			
			var htmlEle = $(".datacolumn").find("[data-category='" + thisCategory + "']");
			valueDecimal = htmlEle.data("valueDecimal");
			
			
			
			
			thisSeries = '[' + thisSeries + ']';

			//console.dir(thisSeries);

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
						marginRight: 50,
						marginLeft: 50, // Keep all charts left aligned
                        spacingTop: 20,
                        spacingBottom: 20,
						type: 'line',
						height: thisChartHeight
					},

					title: {
						text: thisSeries[0]["name"],
						style: {
							fontSize:'20px'
						},
						align: 'left',
                        margin: 0,
                        x: 40
					},

					subtitle: null,
				
					lang: {
						numericSymbols: ['k', 'M', 'G', 'T', 'P', 'E']
					},
				
					credits: {
                        enabled: false
                    },
                    legend: {
                        enabled: false
                    },


					xAxis: {
						categories: month_array,
						labels: {
							style: {
								fontSize:'15px'
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
							  return Highcharts.numberFormat(this.value,0);
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


//					legend: {
//						align: 'left',
//						verticalAlign: 'top',
//						borderWidth: 0
//					},

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
							lineWidth: 3,
							marker: {
								lineWidth: 0.5,
								radius: 5
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
			
		
			
		
		
		
		//  Trend line "on-click"
		$('.dataTrigger').on('click',function(){
			
			$('#dynamicChartContainer').empty();
			thisCatGroup = $(this).children().data('catgroup');
			
			objectLength = Object.keys(categoryObj[thisCatGroup]).length;
			thisChartHeight = ($('#chartBox').outerHeight() - 20) / objectLength;
			thisChartHeight = thisChartHeight + "px";
			
			$.each(categoryObj[thisCatGroup], (key, value) => {

				thisCategory = Object.keys(value)[0];
				thisSeries = Object.values(value)[0];
				
				
				var htmlEle = $(".datacolumn").find("[data-category='" + thisCategory + "']");
				valueDecimal = htmlEle.data("valueDecimal");
				
				thisSeries = '[' + thisSeries + ']';

				thisSeries = JSON.parse(thisSeries);

				thisGoal = goalsObj[thisCategory][0];

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

				thisMax = Math.ceil(Math.max(...thisSeries[0]["data"]));

				$('<div class="chart">')
					.appendTo('#dynamicChartContainer')
					.highcharts({

						chart: {
							scrollablePlotArea: {

							},
							marginRight: 50,
							marginLeft: 50, // Keep all charts left aligned
							spacingTop: 20,
							spacingBottom: 20,
							type: 'line',
							height: thisChartHeight
						},

						title: {
							text: thisSeries[0]["name"],
							style: {
								fontSize:'20px'
							},
							align: 'left',
							margin: 0,
							x: 40
						},

						subtitle: null,

						credits: {
							enabled: false
						},
						legend: {
							enabled: false
						},


						xAxis: {
							categories: month_array,
							labels: {
								style: {
									fontSize:'15px'
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
								  return this.value;
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


	//					legend: {
	//						align: 'left',
	//						verticalAlign: 'top',
	//						borderWidth: 0
	//					},

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
								lineWidth: 3,
								marker: {
									lineWidth: 0.5,
									radius: 5
								},
								animation: {
									duration: 1000
								}
							}
						},
						exporting: { enabled: false },

						series: thisSeries
				});

//				thisChart = chart;
//
//				containerWidth = $('#chartBox').outerWidth();
//				containerHeight = $('#chartBox').outerHeight();
//
//				thisChart.setSize(containerWidth-10, containerHeight-10);


			});
		});
		
		
		
//		
//		$(window).resize(function() {    
//			containerWidth = $('#chartBox').outerWidth();
//			containerHeight = $('#chartBox').outerHeight();
//		
//			thisChart.setSize(containerWidth-10, containerHeight-10);
//		});
			
		
		
		
		
		
		//  Generate CSV
		$('#csvButton').on('click',function(){
			
			$('#csvButton').prop('disabled','true');
			$('#csvButton > i').removeClass("far fa-envelope").addClass("far fa-spinner spinner");
			
			
			$('#csvLabel').html('Generating...');
			
			var csvPeriod = period.replace(/\s/g,'');
			$.ajax({
				type: "get",
				url: "OpsDash_CFC.cfc?method=generateOpsCSV",
				dataType: "text",
				data: {
					period: csvPeriod
				},
				cache: false,
				success: function( data ){
					var json = data.trim();
					obj = JSON.parse(json);
					if (obj.result == 'pass') {
						
						$('#csvButton > i').removeClass("far fa-spinner spinner").addClass("far fa-check success");
						
						$('#csvLabel').html('Sent to your email');
						
						setTimeout(function(){
							$('#csvButton > i').removeClass("far fa-check success").addClass("far fa-envelope");
							$('#csvButton').prop('disabled',false);
							$('#csvLabel').html('Email Spreadsheet');
						},2500);

					} else {
						$('#csvButton > i').removeClass("far fa-spinner spinner").addClass("far fa-times failure");
						
						$('#csvLabel').html('Failed. IT notified');
						
						setTimeout(function(){
							$('#csvButton > i').removeClass("far fa-check success").addClass("far fa-envelope");
							$('#csvButton').prop('disabled',false);
							$('#csvLabel').html('Email Spreadsheet');
						},2500);
					}
				}
			});
			
			
		});
		
		
		//  Window resize bug fix
		var resizeFlag = 0;
		$(window).resize(function() {
			if($(window).width() < 576) {
		 		resizeFlag = 1;
		 	}
			if($(window).width() > 576) {
		 		if(resizeFlag == 1){
					$('.lastMonthValueLeft').css('display','inline-table');
					$('.lastMonthValueRight').css('display','inline-table');
					setTimeout(function(){
						$('.lastMonthValueLeft').css('display','initial');
						$('.lastMonthValueRight').css('display','initial');
					},100);
					resizeFlag = 0;
				}
		 	}
		});
		
		
		
		
		
		
		//  Help
		
		$('#helpButton').on('click', function(){
			
			//update tutorial
			//$('.tutorialBox > #tutorialMessage > p').html("Hover over a data point to see progress");
			
			//disable next button
			$('#nextButton').prop('disabled',true).addClass('disabled');
			$('#nextButton > #iconTainer > i').css("animation","none");
			
			//show tutorial
			$('.tutorialBox').show().css("display","flex");
			setTimeout(function(){
				$('.tutorialBox').css({"z-index":"100","opacity":"1"});
				$('.tutorialBox').css("bottom","0");
			},100);
			
			
			
			setTimeout(function(){
				
				//turn on spotlight
				$('#spotlight').attr('style', calculateArea($('#msfshippedDetail')));
				
				//get pointer coords
				var pointerCoords = getPointerCoords($('#msfshippedValue'));
				
				//update faux mouse
				$('#fauxMouse').css({"z-index":"9","opacity":"1","transform":"translate(" + pointerCoords + ")"});
				
				setTimeout(function(){
					//show hover value
					$('#msfshippedSection').addClass('hovered');
					
					//reenabled next button
					setTimeout(function(){
						$('#nextButton').prop('disabled',false).removeClass('disabled');
						$('#nextButton > #iconTainer > i').css("animation","MoveLeftRight 750ms linear infinite");
					},500);
				},1500);
				
			},100);
			
			$('#nextButton').on('click',function(){
				$('#nextButton').off('click');
				//disable next button
				$('#nextButton').prop('disabled',true).addClass('disabled');
				$('#nextButton > #iconTainer > i').css("animation","none");
				
				//update tutorial
				//$('.tutorialBox > #tutorialMessage > p').html("Click on data to show its trend line");
				
				$('#messageCarousel').carousel('next');
				
				//update faux mouse to pointer
				$('#fauxMouse > i').removeClass("fas fa-mouse-pointer").addClass("fas fa-hand-pointer");
				
				//$('#msfproducedValue').css({"text-shadow":"0px -3px 12px #68AEE7"});
				
				//update spotlight
				$('#spotlight').attr('style', calculateArea($('#msfshippedValue')));
				
				//timeout show data click
				setTimeout(function(){
					
					//update spotlight
					$('#spotlight').attr('style', calculateArea($('#chartBox')));
					
					//set help arrow
					$('#helpArrow').css({"z-index":"9","opacity":"1","animation":"MoveLeftRight 750ms linear infinite"});
					
					//data click
					setTimeout(function(){
						$('#msfshippedValue').click();
						
						//reenabled next button
						setTimeout(function(){
							$('#nextButton').prop('disabled',false).removeClass('disabled');
							$('#nextButton > #iconTainer > i').css("animation","MoveLeftRight 750ms linear infinite");
						},500);
					},1000);
					
				},1850);
				
				
				
				$('#nextButton').on('click',function(){
					$('#nextButton').off('click');
					//disable next button
					$('#nextButton').prop('disabled',true).addClass('disabled');
					$('#nextButton > #iconTainer > i').css("animation","none");
					
					//hide help arrow
					$('#helpArrow').css("opacity","0");
					setTimeout(function(){
						$('#helpArrow').css("z-index","-1");
					},501);

					//update tutorial
					//$('.tutorialBox > #tutorialMessage > p').html("Performance goals are updated here");
					$('#messageCarousel').carousel('next');
					
					//get pointer coords
					var pointerCoords = getPointerCoords($('#goals'));
					
					//update faux pointer to mouse
					$('#fauxMouse > i').removeClass("fas fa-hand-pointer").addClass("fas fa-mouse-pointer");
					
					//remove data hover
					$('#msfshippedSection').removeClass('hovered');

					//update faux mouse
					$('#fauxMouse').css({"transform":"translate(" + pointerCoords + ")"});
					
					//update spotlight
					$('#spotlight').attr('style', calculateArea($('#goals')));

					setTimeout(function(){
						//update faux mouse to pointer
						$('#fauxMouse > i').removeClass("fas fa-mouse-pointer").addClass("fas fa-hand-pointer");
						
						//hover goals
						$('#goals').addClass('hovered');
						
						//reenabled next button
						setTimeout(function(){
							$('#nextButton').prop('disabled',false).removeClass('disabled');
							$('#nextButton > #iconTainer > i').css("animation","MoveLeftRight 750ms linear infinite");
						},500);
					},1500);
					
					$('#nextButton').on('click',function(){
						$('#nextButton').off('click');
						//disable next button
						$('#nextButton').prop('disabled',true).addClass('disabled');
						$('#nextButton > #iconTainer > i').css("animation","none");

						//update tutorial
						//$('.tutorialBox > #tutorialMessage > p').html("Data that is entered in manually can be viewed here");
						$('#messageCarousel').carousel('next');
						
						//get pointer coords
						var pointerCoords = getPointerCoords($('#dataentry'));

						//update faux mouse
						$('#fauxMouse').css({"transform":"translate(" + pointerCoords + ")"});

						setTimeout(function(){
							//update spotlight
							$('#spotlight').attr('style', calculateArea($('#dataentry')));
							//remove goals hover
							$('#goals').removeClass('hovered');
							//hover data entry
							$('#dataentry').addClass('hovered');
							
							//reenabled next button
							setTimeout(function(){
								$('#nextButton').prop('disabled',false).removeClass('disabled');
								$('#nextButton > #iconTainer > i').css("animation","MoveLeftRight 750ms linear infinite");
							},500);
						},750);
						
						$('#nextButton').on('click',function(){
							$('#nextButton').off('click');
							//disable next button
							$('#nextButton').prop('disabled',true).addClass('disabled');
							$('#nextButton > #iconTainer > i').css("animation","none");
							
							//remove data entry hover
							$('#dataentry').removeClass('hovered');

							//update tutorial
							//$('.tutorialBox > #tutorialMessage > p').html("This button emails a spreadsheet of the data");
							$('#messageCarousel').carousel('next');
							
							//get pointer coords
							var pointerCoords = getPointerCoords($('#reportCSVContainer'));

							//update faux pointer to mouse
							$('#fauxMouse > i').removeClass("fas fa-hand-pointer").addClass("fas fa-mouse-pointer");

							//update faux mouse
							$('#fauxMouse').css({"transform":"translate(" + pointerCoords + ")"});
							
							//update spotlight
							$('#spotlight').attr('style', calculateArea($('#reportCSVContainer')));


							setTimeout(function(){
								//update faux mouse to pointer
								$('#fauxMouse > i').removeClass("fas fa-mouse-pointer").addClass("fas fa-hand-pointer");
								
								//hover csv button
								$('#csvButton').addClass("hovered");
								
								//reenabled next button
								setTimeout(function(){
									$('#nextButton').prop('disabled',false).removeClass('disabled');
									$('#nextButton > #iconTainer > i').css("animation","MoveLeftRight 750ms linear infinite");
								},500);
							},1400);
							
							$('#nextButton').on('click',function(){
								$('#nextButton').off('click');
								
								//remove csv hover
								$('#csvButton').removeClass("hovered");
								
								//hide mouse
								$('#fauxMouse').css({"opacity":"0","transform":"translate(0,0)"});
								
								//hide tutorial
								$('.tutorialBox').css("bottom","-80px");
								
								//turn off spotlight
								$('#spotlight').css("opacity","0");
								
								setTimeout(function(){
									//hide everything
									$('.tutorialBox').css({"z-index":"-1","opacity":"0"});
									$('.tutorialBox').hide();
									$('#spotlight').css("z-index","-1");
									$('#fauxMouse').css("z-index","-1");
									//$('#nextButton > #iconTainer > i').removeClass("far fa-thumbs-up").addClass("far fa-arrow-alt-circle-right");
									
									//update faux pointer to mouse
									$('#fauxMouse > i').removeClass("fas fa-hand-pointer").addClass("fas fa-mouse-pointer");
									
									//reset carousel
									$('#messageCarousel').carousel('next');
								},649);
								
							});
							
						});

					});


				});
				
				
			});
				
			
		});
		
		
		function getPointerCoords(ele){
			var elementX = ele.offset().left;
			var elementY = ele.offset().top;
			var elementWidth = ele.outerWidth();
			var elementHeight = ele.outerHeight();
				
			var pointerCoords = elementX+(elementWidth/2) + "px," + (elementY + (elementHeight/2 + 5)) + "px";
			
			return pointerCoords;
		}
		

		var calculateArea = function (ele)
		{
			var offset = $(ele).offset();
			var height = $(ele).height();
			var width = $(ele).width();
			return prefix((height * 1.5), height, (offset.left + width / 2), (offset.top + height / 2), (width / 2 + 15), (width / 2 + 30));
		}

		var prefix = function (stop1, stop2, stop3, stop4, colorStop1, colorStop2)
		{
		  var background;

			background = "z-index: 10;opacity: 1;"
			background += "background: radial-gradient(" + stop1 + "px " + stop2 + "px at " + stop3 + "px " + stop4 + "px, transparent 0, transparent " + colorStop1 + "px, rgba(0, 0, 0, 0.5) " + colorStop2 + "px);";
			background += "background: -moz-radial-gradient(" + stop1 + "px " + stop2 + "px at " + stop3 + "px " + stop4 + "px, transparent 0, transparent " + colorStop1 + "px, rgba(0, 0, 0, 0.5) " + colorStop2 + "px);";
			background += "background: -webkit-radial-gradient(" + stop3 + "px " + stop4 + "px, " + stop1 + "px " + stop2 + "px, transparent 0, transparent " + colorStop1 + "px, rgba(0, 0, 0, 0.5) " + colorStop2 + "px);";
			background += "background: -o-radial-gradient(" + stop3 + "px " + stop4 + "px, " + stop1 + "px " + stop2 + "px, transparent 0, transparent " + colorStop1 + "px, rgba(0, 0, 0, 0.5) " + colorStop2 + "px);";

			return background;
		}
		
	});

		
		
	
</script>
</body>
</html>
	
	
<cfcatch>
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
