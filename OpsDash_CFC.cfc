<cfcomponent>

	<cfsetting requesttimeout="10000">
		
		
	<cffunction name="generateOpsCSV" access="remote" output="yes">
		<cfargument name="period" required="yes">
		<cfargument name="emailTo" required="no" default="dev@tomfafard.com">
		<cfargument name="ccemailTo" required="no" default="">
		<cfargument name="fromUtility" required="no" default="false">
			
		<cfset passFail = 'pass'>
		<cfset reason = ''>
			
		<cftry>
			
			
		<cfquery name="getPlants" datasource="cfweb">
			SELECT DISTINCT
				Company,
				DefaultSort
			FROM 
				CompanyList
			WHERE
				Company NOT IN ('LouisvilleKY','Columbia','CoPak','DigitalHighPoint','VirginiaBeach')
			ORDER BY
				DefaultSort
		</cfquery>
			
		<cfquery name="getYearMonthNo" datasource="cfweb">
			SELECT TOP 1
				YearMonthNo,
				Month
			FROM 
				OPS_Monthly
			WHERE
				Month + Year = <cfqueryparam value="#arguments.period#" cfsqltype="CF_SQL_VARCHAR" maxlength="15">
		</cfquery>
		
		<cfset thisYearMonthNo = getYearMonthNo.YearMonthNo>
		<cfset lastSix = '#thisYearMonthNo#,'>
		<cfloop from="0" to="5" index="i" step="1">
			<cfif RIGHT(thisYearMonthNo,2) eq 01>
				<cfset thisYearMonthNo = '#(LEFT(thisYearMonthNo,4)-1)#12'>
			<cfelse>
				<cfset thisYearMonthNo -= 1>
			</cfif>
			<cfset lastSix &= '#thisYearMonthNo#,'>
		</cfloop>
				
		<cfset lastSix = LEFT(lastSix,Len(lastSix)-1)>
			
<!---
			<cfmail to="dev@tomfafard.com" from="dev@tomfafard.com" subject="test" type="HTML">
				<cfdump var="#lastSix#">	
				</cfmail>
--->
		
		<cfquery name="getMonths" datasource="cfweb">
			SELECT DISTINCT
				Month + Year as Period,
				YearMonthNo
			FROM 
				OPS_Monthly
			WHERE
				YearMonthNo in (#ListQualify(lastSix,"'",",")#)
			ORDER BY YearMonthNo
		</cfquery>
			
		
		<cfset PlantList = ValueList(getPlants.Company)>
		<cfset MonthList = ValueList(getMonths.Period)>
		<cfset thisOpsYear = LEFT(ListFirst(lastSix),4)>
			
		<!--- Reverse MonthList to display in ascending order --->
		<cfset NewMonthList = ''>
		<cfloop list="#MonthList#" index="month">
			<cfset NewMonthList &= '#month#,'>
		</cfloop>
			
		<cfset NewMonthList = Left(NewMonthList,Len(NewMonthList)-1)>
		<cfset MonthList = NewMonthList>


		<!--- Create new spreadsheet --->
		<cfset opSheet = SpreadsheetNew()>


		<!--- Create header row --->
		<cfset SpreadsheetAddRow(opSheet, (",GOALS,#thisOpsYear# YTD Avg," & MonthList))>

		<cfset headerFormat=StructNew()>
		<cfset headerFormat.bold="true">
		<cfset headerFormat.alignment="left">
			
		<cfset wholeFormat=StructNew()>
		<cfset wholeFormat.dataformat="##,####0">

		<cfset decimalFormat=StructNew()>
		<cfset decimalFormat.dataformat="0.00">
		
			
		<cfset wholeFormatGoal=StructNew()>
		<cfset wholeFormatGoal.dataformat="##,####0">
		<cfset wholeFormatGoal.color="pale_blue">
		<cfset wholeFormatGoal.bold="true">
<!---
		<cfset wholeFormatGoal.fgcolor="lemon_chiffon">
		<cfset wholeFormatGoal.leftborder="thin">
		<cfset wholeFormatGoal.rightborder="thin">
		<cfset wholeFormatGoal.topborder="thin">
		<cfset wholeFormatGoal.bottomborder="thin">
		<cfset wholeFormatGoal.leftbordercolor="grey_25_percent">
		<cfset wholeFormatGoal.rightbordercolor="grey_25_percent">
		<cfset wholeFormatGoal.topbordercolor="grey_25_percent">
		<cfset wholeFormatGoal.bottombordercolor="grey_25_percent">
--->

		<cfset decimalFormatGoal=StructNew()>
		<cfset decimalFormatGoal.dataformat="0.00">
		<cfset decimalFormatGoal.color="pale_blue">
		<cfset decimalFormatGoal.bold="true">
<!---
		<cfset decimalFormatGoal.fgcolor="lemon_chiffon">
		<cfset decimalFormatGoal.leftborder="thin">
		<cfset decimalFormatGoal.rightborder="thin">
		<cfset decimalFormatGoal.topborder="thin">
		<cfset decimalFormatGoal.bottomborder="thin">
		<cfset decimalFormatGoal.leftbordercolor="grey_25_percent">
		<cfset decimalFormatGoal.rightbordercolor="grey_25_percent">
		<cfset decimalFormatGoal.topbordercolor="grey_25_percent">
		<cfset decimalFormatGoal.bottombordercolor="grey_25_percent">
--->

			
		<cfset wholeFormatYTD=StructNew()>
		<cfset wholeFormatYTD.dataformat="##,####0">
		<cfset wholeFormatYTD.color="coral">
		<cfset wholeFormatYTD.bold="true">
<!---
		<cfset wholeFormatYTD.fgcolor="pale_blue">
		<cfset wholeFormatYTD.leftborder="thin">
		<cfset wholeFormatYTD.rightborder="thin">
		<cfset wholeFormatYTD.topborder="thin">
		<cfset wholeFormatYTD.bottomborder="thin">
		<cfset wholeFormatYTD.leftbordercolor="grey_25_percent">
		<cfset wholeFormatYTD.rightbordercolor="grey_25_percent">
		<cfset wholeFormatYTD.topbordercolor="grey_25_percent">
		<cfset wholeFormatYTD.bottombordercolor="grey_25_percent">
--->

		<cfset decimalFormatYTD=StructNew()>
		<cfset decimalFormatYTD.dataformat="0.00">
		<cfset decimalFormatYTD.color="coral">
		<cfset decimalFormatYTD.bold="true">
<!---
		<cfset decimalFormatYTD.fgcolor="pale_blue">
		<cfset decimalFormatYTD.leftborder="thin">
		<cfset decimalFormatYTD.rightborder="thin">
		<cfset decimalFormatYTD.topborder="thin">
		<cfset decimalFormatYTD.bottomborder="thin">
		<cfset decimalFormatYTD.leftbordercolor="grey_25_percent">
		<cfset decimalFormatYTD.rightbordercolor="grey_25_percent">
		<cfset decimalFormatYTD.topbordercolor="grey_25_percent">
		<cfset decimalFormatYTD.bottombordercolor="grey_25_percent">
--->


<!---
		<cfset roundFormat=StructNew()>
		<cfset roundFormat.dataformat="0.00%">
--->

		<cfset SpreadsheetFormatRow(opSheet, headerFormat, 1)>

		<!--- thisRow = 3 because we are starting insert on 3rd row --->
		<cfset thisRow = 3>
		<cfloop list="#plantList#" index="plant">

			<cfquery name="getRelevantMetrics" datasource="cfweb">
				SELECT OPS_Column FROM OPS_Goals WHERE Company = '#plant#'  
			</cfquery>

			<cfset validMetrics = ValueList(getRelevantMetrics.OPS_Column)>

			<!--- Add the plant name to current row, column 1 --->
			<cfset SpreadsheetAddRow(opSheet, "#plant#", #thisRow#, 1)>
			<cfset SpreadsheetFormatRow(opSheet, headerFormat, #thisRow#)>


			<!--- Increment row to prepare for category insertion --->
			<cfset thisRow += 1>

			<cfloop list="#validMetrics#" index="category">
				
				<cfquery name="getDataType" datasource="cfweb">
					SELECT DATA_TYPE 
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE 
							 TABLE_NAME = 'OPS_Monthly' AND 
							 COLUMN_NAME = '#category#'	
				</cfquery>
				

				<!--- Format the category for display --->
				<cfset displayCategory = REReplaceNoCase(REReplaceNoCase(REReplaceNoCase(REReplaceNoCase(category, chr(95), ' ', 'all'), 'Percent', '%', 'all'), 'Dollar', '$', 'all'), 'Per', '/', 'all')>

				<!--- Add the category name to current row, column 1 --->
				<cfset SpreadsheetAddRow(opSheet, "#displayCategory#", #thisRow#, 1)>

				<cftransaction isolation="READ_UNCOMMITTED">
				<cfquery name="getGoal" datasource="cfweb">
					SELECT 
						Goal
					FROM OPS_Goals 
					WHERE Company = '#plant#' 
					and OPS_Column = '#category#'
				</cfquery>
				</cftransaction>
				<cftransaction isolation="READ_UNCOMMITTED">
				<cfquery name="getYTDAvg" datasource="cfweb">
					SELECT 
						AVG(#category#) as AVG_currentCat 
					FROM OPS_MONTHLY 
					WHERE Company = '#plant#' 
					and Year = '#DateFormat(now(),"yyyy")#'
				</cfquery>
				</cftransaction>
				<cftransaction isolation="READ_UNCOMMITTED">
				<cfquery name="getRowData" datasource="cfweb">
					SELECT 
						#category# as currentCat
					FROM OPS_MONTHLY
					WHERE Company = '#plant#'
					AND (Month + Year) in (#listQualify(MonthList,"'",",")#)
					ORDER BY YearMonthNo
				</cfquery>	
				</cftransaction>
					
<!---
				<cfmail to="dev@tomfafard.com" from="dev@tomfafard.com" subject="test" type="HTML">
					<cfdump var="#getYTDAvg#">
				</cfmail>
--->

					
				<!--- Add Goal --->
				<cfset SpreadsheetAddColumn(opSheet, "#getGoal.Goal#",#thisRow#,2,false)>
					
				<!--- Add YTD Avg --->
				<cfset SpreadsheetAddColumn(opSheet, "#getYTDAvg.AVG_currentCat#",#thisRow#,3,false)>
					
				<!--- Format Goal and YTD --->
				<cfswitch expression="#LEFT(getDataType.DATA_TYPE,4)#">
					<cfcase value="int">
						<cfset SpreadsheetFormatCell(opSheet, wholeFormatGoal, #thisRow#, 2)>
						<cfset SpreadsheetFormatCell(opSheet, wholeFormatYTD, #thisRow#, 3)>
					</cfcase>	

					<cfcase value="deci">
						<cfset SpreadsheetFormatCell(opSheet, decimalFormatGoal, #thisRow#, 2)>
						<cfset SpreadsheetFormatCell(opSheet, decimalFormatYTD, #thisRow#, 3)>
					</cfcase>	
				</cfswitch>
				
				<!--- Loop getRowData to add category data --->
				<cfloop query="getRowData">
					<cfset thisColumn = 3 + getRowData.currentRow>
					<cfset SpreadsheetAddColumn(opSheet, "#getRowData.currentCat#",#thisRow#,#thisColumn#,false)>
						
					<cfswitch expression="#LEFT(getDataType.DATA_TYPE,4)#">
						<cfcase value="int">
							<cfset SpreadsheetFormatCell(opSheet, wholeFormat, #thisRow#, #thisColumn#)>
						</cfcase>	

						<cfcase value="deci">
							<cfset SpreadsheetFormatCell(opSheet, decimalFormat, #thisRow#, #thisColumn#)>
						</cfcase>	
					</cfswitch>
				</cfloop>


				<!--- Increment row to prepare for next category --->
				<cfset thisRow += 1>
			</cfloop>


			<!--- Increment row to prepare for next plant --->
			<cfset thisRow += 1>

		</cfloop>





		<!--- Add orders from query --->
		<!---<cfset SpreadsheetAddRows(opSheet, getData)>--->

		<!--- Figure out row for formula, 2 after data --->
		<!---
		<cfset rowDataStart=2>
		<cfset rowDataEnd=getData.recordCount+1>
		<cfset rowTotal=rowDataEnd+2>
		<cfset totalFormula="SUM(D#rowDataStart#:D#rowDataEnd#)">
		--->

		<!--- Add total formula --->
		<!---
		<cfset SpreadsheetSetCellValue(opSheet, "TOTAL:", rowTotal, 3)>
		<cfset spreadsheetSetCellFormula(opSheet, totalFormula, rowTotal, 4)>
		--->

		<!--- Format amount column as currency ---> 
		<!---<cfset SpreadsheetFormatColumn(opSheet, {dataformat="$00000.00"}, 4)>--->



		<cfset CSVFileName =  '#thisOpsYear#OperationsReport.xls' > 

		<cfset messageSubject =  'Plant Operations: #getYearMonthNo.Month# #thisOpsYear#' >

		<cfset CSVFileName =  GetDirectoryFromPath(ExpandPath("*.*")) & 'Files\' & CSVFileName> 

		<!--- Save it --->
		<cfspreadsheet action="write"
		name="opSheet"
		filename="#CSVFileName#"
		overwrite="true">

			
		<cfif fileexists(CSVFileName)>
		<cftry>
		  <cfmail to="#emailTo#" cc="#ccemailTo#" bcc="dev@tomfafard.com" from="dev@tomfafard.com" subject="#messageSubject#" type="HTML">
			<cfmailparam file="#CSVFileName#">
			<cfif arguments.fromUtility eq 'true'>
				
			Please find attached the Monthly Operations report as of #getYearMonthNo.Month# #thisOpsYear#.<br><br>
				
			Visit the <a href="https://tomfafard.com/ops/opsdash.cfm">Dashboard</a> to view goals and more details.
			<br><br>

			( Do not reply directly to this automated email )
				
			<cfelse>
			To Open this file:<br> 
			First, save this attachment to your hard drive.<br> 
			Next, open a tool that can parse this csv file<br> 
			( comma separated values ) such as Microsoft Excel.<br> 
			From 'within' this program, choose open from the <br> 
			file menu and point it to the just saved file.<br><br> 

			Please do not reply to this automated email.
			</cfif>
			</cfmail>
		  <cfcatch type="any">
			Error. File Could not me mailed.. See tech support.
		  </cfcatch>
		  File has been sent.
		  </cftry>
		</cfif>
			
			
		<cfset thisResult = '{"result":"#passFail#","reason":"#reason#"}'>
			
		<cfoutput>#thisResult#</cfoutput>
			
			
		<cfcatch>
			<cfmail to="dev@tomfafard.com" from="dev@tomfafard.com" subject="Error: Ops Spreadsheet" type="HTML">
				<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>
		</cftry>
		
	</cffunction>
			
			
			
			
			
			
			
	<cffunction name="setValue" access="remote" output="yes">
		<cfargument name="value">
		<cfargument name="column">
		<cfargument name="plant">
		<cfargument name="period">
		<cfargument name="table">
			
		<cfset passFail = 'pass'>
		<cfset reason = ''>
			
		<cftry>
			
		<cfif arguments.table eq 'OPS_Monthly' OR arguments.table eq 'OPS_DataEntry_Staging'>
			<cfquery name="getDataType" datasource="cfweb">
				SELECT DATA_TYPE 
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE 
					 TABLE_NAME = 'OPS_Monthly' AND 
					 COLUMN_NAME = <cfqueryparam value="#arguments.column#" cfsqltype="CF_SQL_VARCHAR">	
			</cfquery>

			<cfset thisDataType = ''>
			<cfswitch expression="#LEFT(getDataType.DATA_TYPE,4)#">
				<cfcase value="int">
					<cfset thisDataType = 'CF_SQL_INTEGER'>
					<cfset scale = 0>
				</cfcase>	

				<cfcase value="deci">
					<cfset thisDataType = 'CF_SQL_DECIMAL'>
					<cfset scale = 4>
				</cfcase>	

				<cfcase value="varc">
					<cfset thisDataType = 'CF_SQL_VARCHAR'>
					<cfset scale = 0>
				</cfcase>

				<cfcase value="date">
					<cfset thisDataType = 'CF_SQL_DATE'>
					<cfset scale = 0>
				</cfcase>
			</cfswitch>
		<cfelseif arguments.table eq 'OPS_Goals'>
			<cfset thisDataType = 'CF_SQL_DECIMAL'>
			<cfset scale = 4>
		</cfif>
				
<!---
				<cfmail to="dev@tomfafard.com" from="dev@tomfafard.com" subject="test" type="HTML">
					<cfdump var="#arguments.value#">
				</cfmail>
--->
			
			
		<cftry>
		<cfif arguments.table eq 'OPS_Monthly'>
			<cfquery name="updateColumn" datasource="cfweb">
				UPDATE #arguments.table#
					SET #arguments.column# = <cfqueryparam value="#arguments.value#" cfsqltype="#thisDataType#" scale="#scale#">
				WHERE
					Company = <cfqueryparam value="#arguments.plant#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
				AND
					Month + ' ' + Year = <cfqueryparam value="#arguments.period#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
			</cfquery>
		</cfif>
				
		
		<cfif arguments.table eq 'OPS_DataEntry_Staging'>
			<cfquery name="updateColumn" datasource="cfweb">
				INSERT INTO #arguments.table#
					(OPS_Column,
					 Value,
					 Month,
					 Year,
					 Company,
					 DateSubmitted,
					 SubmittedBy) VALUES
					('#arguments.column#',
					 <cfqueryparam value="#arguments.value#" cfsqltype="#thisDataType#" scale="#scale#">,
					 '#ListToArray(arguments.period,' ')[1]#',
					 '#ListToArray(arguments.period,' ')[2]#',
					 '#arguments.plant#',
					  getDate(),
					 'Admin'
					)
			</cfquery>
		</cfif>
				
				
		<cfif arguments.table eq 'OPS_Goals'>
			
			<cfquery name="checkValue" datasource="cfweb">
				SELECT Goal FROM OPS_Goals 
				WHERE 
					OPS_Column = <cfqueryparam value="#arguments.column#" cfsqltype="CF_SQL_VARCHAR"> 
				AND 
					Company = <cfqueryparam value="#arguments.plant#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
			</cfquery>
				
			<cfif checkValue.recordCount>
				<cfquery name="updateColumn" datasource="cfweb">
					UPDATE #arguments.table#
						SET Goal = <cfqueryparam value="#arguments.value#" cfsqltype="#thisDataType#" scale="#scale#">,
							datemodified = getDate(),
							modifiedby = 'Admin'
					WHERE
						Company = <cfqueryparam value="#arguments.plant#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">
					AND
						OPS_Column = <cfqueryparam value="#arguments.column#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
<!--- Don't insert rows here... these should be predetermined
			<cfelse>
				<cfquery name="updateColumn" datasource="cfweb">
					INSERT INTO #arguments.table# 
					(
					 OPS_Column,
					 Goal,
					 Company,
					 datemodified,
					 modifiedby
					) VALUES (
						      <cfqueryparam value="#arguments.column#" cfsqltype="CF_SQL_VARCHAR">,
						      <cfqueryparam value="#arguments.value#" cfsqltype="#thisDataType#" scale="#scale#">,
						      <cfqueryparam value="#arguments.plant#" cfsqltype="CF_SQL_VARCHAR" maxlength="20">,
							  getDate(),
							  'Admin'
					         )
				</cfquery>
--->
			</cfif>
		</cfif>

		<cfcatch>
			<cfset passFail = 'fail'>
			<cfmail to="dev@tomfafard.com" from="dev@tomfafard.com" subject="Error: SetValue UpdateColumn Failed" type="HTML">
				<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>
		</cftry>	
			
			
			
		<cfset thisResult = '{"result":"#passFail#","reason":"#reason#"}'>
			
		<cfoutput>#thisResult#</cfoutput>
			
			
		<cfcatch>
			<cfmail to="dev@tomfafard.com" from="dev@tomfafard.com" subject="Error: Ops SetValue" type="HTML">
				<cfdump var="#cfcatch#">
			</cfmail>
		</cfcatch>
		</cftry>	
	</cffunction>
		
		



			
		

	<cffunction name="GetDateByWeek" access="private" returntype="date" output="false">
		<cfargument name="Year" type="numeric" required="true">
		<cfargument name="Week" type="numeric" required="true">


		<!---
			Get the first day of the year. This one is
			easy, we know it will always be January 1st
			of the given year.
		--->
		<cfset FirstDayOfYear = CreateDate(arguments.Year, 1, 1)>

		<!---
			Based on the first day of the year, let's
			get the first day of that week. This will be
			the first day of the calendar year.
		--->
		<cfset FirstDayOfCalendarYear = ( FirstDayOfYear - DayOfWeek( FirstDayOfYear ) + 1 )>

		<!---
			Now that we know the first calendar day of
			the year, all we need to do is add the
			appropriate amount of weeks. Weeks are always
			going to be seven days.
		--->
		<cfset FirstDayOfWeek = ( FirstDayOfCalendarYear + ( (arguments.Week - 1) * 7 ) )>


		<!---
			Return the first day of the week for the
			given year/week combination. Make sure to
			format the date so that it is not returned
			as a numeric date (this will just confuse
			too many people).
		--->
		<cfreturn DateFormat(FirstDayOfWeek, "yyyy-mm-dd")>
	</cffunction>
				
								
</cfcomponent>