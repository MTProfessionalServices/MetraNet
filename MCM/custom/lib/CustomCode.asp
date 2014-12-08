<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2000 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME        : CustomCode.asp
' DESCRIPTION : The goal of this to store all the MCM default function that has to be customized...
' DATE        : Oct/29/2001
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

PUBLIC FUNCTION CustomFunction()
    CustomFunction=1
END FUNCTION


'mcm_GetCustomRateScheduleSummaryInformationForQuery
'When displaying a list of rate schedules, this function returns the data necessary for displaying summary information for the particular rate schedule
'By default, a count of the number of rules is returned
'When customizing for your particular parameter table, remember to set/return:
'  outQuerySummaryProperty: the property name or calculated value to use for the summary value
'  outQuerySummaryJoin: the SQL for any joins neccessary; can be set to ""; refer to the %%SUMMARY_JOIN%% param of the __FIND_RATE_SCHEDULES_FOR_PL_MAPPING_WITH_SUMMARY_INFORMATION__ or the __FIND_RATE_SCHEDULES_FOR_PARAM_TBL_PL_WITH_SUMMARY_INFORMATION__ queries
'  outReturnedSummaryCaptionName: display name for the summary value column header; if this is returned as "" then no summary column will be displayed for this type of parameter table
'  outShowSummaryAsFormattedCurrency: boolean value that indicates if the returned value should be formatted as a currency value for the appropriate currency
'Please refer to mcm_GetRateSchedulesForPricelistAsRowsetWithSummaryInformation and mcm_GetRateSchedulesForPricelistMappingAsRowsetWithSummaryInformation for more information about how these values are used
PRIVATE FUNCTION mcm_GetCustomRateScheduleSummaryInformationForQuery(objParameterTable,outQuerySummaryProperty, outQuerySummaryJoin, outReturnedSummaryCaptionName, outShowSummaryAsFormattedCurrency)

  dim querysnippet
  set querysnippet = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  querysnippet.Init "queries\ParameterTableSummaryDisplay"

  outShowSummaryAsFormattedCurrency = false
  select case objParameterTable.Name
    '//Recurring Charge -- Show just the single Rate
    case "metratech.com/flatrecurringcharge"
      outQuerySummaryProperty = "pt.c_RCAmount"
      
	  querysnippet.SetQueryTag("__PARAMTABLE_SUMMARY_JOIN_FLAT_CHARGE__")
  	  querysnippet.AddParam "%%PARAMTABLEDBNAME%%", objParameterTable.DBTableName
	  
      'outQuerySummaryJoin = " LEFT JOIN " & objParameterTable.DBTableName & " pt on t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%% "
	  outQuerySummaryJoin = querysnippet.GetQueryString()
	  
      outReturnedSummaryCaptionName = "Rate"
      outShowSummaryAsFormattedCurrency = true
      
    'Non Recurring Charge -- Show just the single rate
    case "metratech.com/nonrecurringcharge"
      outQuerySummaryProperty = "pt.c_NRCAmount"

	  querysnippet.SetQueryTag("__PARAMTABLE_SUMMARY_JOIN_FLAT_CHARGE__")
  	  querysnippet.AddParam "%%PARAMTABLEDBNAME%%", objParameterTable.DBTableName
	  
      'outQuerySummaryJoin = " LEFT JOIN " & objParameterTable.DBTableName & " pt on t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%% "
	  outQuerySummaryJoin = querysnippet.GetQueryString()

      outReturnedSummaryCaptionName = "Rate"
      outShowSummaryAsFormattedCurrency = true
      
    'Calendar Mapping -- Show the name of the calendar that is mapped to
    case "metratech.com/calendar"
      outQuerySummaryProperty = "bp1.nm_name"

 	  querysnippet.SetQueryTag("__PARAMTABLE_SUMMARY_JOIN_CALENDAR_NAME__")
  	  querysnippet.AddParam "%%PARAMTABLEDBNAME%%", objParameterTable.DBTableName
	  
      'outQuerySummaryJoin = " LEFT JOIN " & objParameterTable.DBTableName & " pt on t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%% "
      'outQuerySummaryJoin = outQuerySummaryJoin & "LEFT JOIN t_vw_base_props bp1 on bp1.id_prop = pt.c_calendar_id and bp1.id_lang_code = 840 "
	  outQuerySummaryJoin = querysnippet.GetQueryString()


      outReturnedSummaryCaptionName = "Shared Calendar Being Used"

    'Unconditional Flat Discount -- Show just the single rate
    case "metratech.com/flatdiscount_nocond"
      outQuerySummaryProperty = "pt.c_FlatUncondDiscountAmount"

	  querysnippet.SetQueryTag("__PARAMTABLE_SUMMARY_JOIN_FLAT_CHARGE__")
  	  querysnippet.AddParam "%%PARAMTABLEDBNAME%%", objParameterTable.DBTableName
	  
      'outQuerySummaryJoin = " LEFT JOIN " & objParameterTable.DBTableName & " pt on t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%% "
	  outQuerySummaryJoin = querysnippet.GetQueryString()

      outReturnedSummaryCaptionName = "Discount (Amount)"
      outShowSummaryAsFormattedCurrency = true
      
    'Unconditional Percent Discount -- Show just the percent value of the discount (only one value)
    case "metratech.com/percentdiscount_nocond"
      outQuerySummaryProperty = "pt.c_DiscountPercent"

	  querysnippet.SetQueryTag("__PARAMTABLE_SUMMARY_JOIN_FLAT_CHARGE__")
  	  querysnippet.AddParam "%%PARAMTABLEDBNAME%%", objParameterTable.DBTableName
	  
      'outQuerySummaryJoin = " LEFT JOIN " & objParameterTable.DBTableName & " pt on t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%% "
	  outQuerySummaryJoin = querysnippet.GetQueryString()

      outReturnedSummaryCaptionName = "Discount(%)"
              
    'Everything else
	case else
	  'For everything else, we'll just return the number of rows in the ruleset
	  'We don't need a Join, we can do the count as the 'property'
	  querysnippet.SetQueryTag("__PARAMTABLE_SUMMARY_RULE_COUNT__")
  	  querysnippet.AddParam "%%PARAMTABLEDBNAME%%", objParameterTable.DBTableName
	  
      'outQuerySummaryProperty = ", convert(varchar(15),(select count(*) from " & objParameterTable.DBTableName & " pt where t_rsched.id_sched = pt.id_sched AND pt.tt_start<=%%%SYSTEMDATE%%% AND pt.tt_end>%%%SYSTEMDATE%%%)) + ' Rules'"
	  outQuerySummaryProperty = querysnippet.GetQueryString()
	  
      outQuerySummaryJoin = ""
      outReturnedSummaryCaptionName = FrameWork.GetDictionary("TEXT_SUMMARY")
  end select
  
END FUNCTION


%>
