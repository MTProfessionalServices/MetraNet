/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
***************************************************************************/

#include "StdAfx.h"
#include "MTHierarchyReports.h"
#include "ReportHelper.h"

#include <formatdbvalue.h>
#include <mtprogids.h>
#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CReportHelper

STDMETHODIMP CReportHelper::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IReportHelper
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
/////////////////////////////////////////////////////////////////////////////
//  Function    : Initialize(pYAAC, lngLangaugeID, pAvailableReports)      //
//  Description : Initialize the reports helper object.                    //
//  Inputs      : pYAAC -- YAAC for the logged-in user.                    //
//              : lngLanguageID -- Language ID for the logged-in user.     //
//              : pAvailableReports -- List of reports available for the   //
//              :                      logged in user.                     //
//  Outputs     : none                                                     //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::Initialize(IMTYAAC *pYAAC, long lngLanguageID, IMTCollection *pAvailableReports)
{
  long lngCount = 0;
  HRESULT hr;

  try 
  {
    //Store member variables
    mlngLanguageID = lngLanguageID;
    mYAAC = pYAAC;
    mcollAvailableReports = pAvailableReports;
    
    //Set the report count
    hr = mcollAvailableReports.Count(&lngCount);

    if(FAILED(hr)) {
      mlngReportCount = 0;
      return(returnHierarchyReportError(CLSID_ReportHelper, IID_IReportHelper, "CReportHelper", "Initialize()", "No reports are available.", LOG_DEBUG));
    } else {
      mlngReportCount = lngCount;
    }

    //Setup the default intervals for the user
    hr = GetUserDefaultIntervalData();

    if(FAILED(hr)) {
      mlngReportCount = 0;
      return(returnHierarchyReportError(CLSID_ReportHelper, IID_IReportHelper, "CReportHelper", "Initialzie()", "Unable to get default intervals for the user.", LOG_DEBUG));
    }
  }

  catch(_com_error &err) {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
//  Function    : GetAvailableReports(eReportType)                         //
//  Description : Return a collection of available reports of a certain    //
//              : type.                                                    //
//  Inputs      : eReportType -- Type of report to print.                  //
//  Outputs     : Collection of reports.                                   //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetAvailableReports(short sReportType, IMTCollection **collAvailableReports)
{
	MTObjectCollection<IMPSReportInfo> collTempAvailableReports;            //Reports to return
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spTempReportInfo;          //Report info smart pointer
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spNewReportInfo;           //Report info smart pointer
  MTHIERARCHYREPORTSLib::IMPSReportInfo *pReportInfo;                 //Report info pointer
  HRESULT hr;

  long i = 0;

  //Loop through list of reports, and return the matching items
  try {

    for(i = 1; i <= mlngReportCount; i++)
    {
      //Get the item
      hr = mcollAvailableReports.Item(i, &pReportInfo);
    
      if(FAILED(hr)) {
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetAvailableReports()", "Unable to get size of collection of available reports.", LOG_ERROR));
      }
    
      //Use smart pointer
      spTempReportInfo = pReportInfo;
			pReportInfo->Release();
			pReportInfo = 0;

      //If the report is the correct type, add to the collection
      if(spTempReportInfo->Type == sReportType) {

        //Create the report info
        hr = spNewReportInfo.CreateInstance("MTHierarchyReports.MPSReportInfo.1");

        if(FAILED(hr))
          return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetAvailableReports()", "Unable to create ReportInfo object to add to collection.", LOG_ERROR));

        CopyReportInfo(spTempReportInfo, spNewReportInfo);

        //Add the item to the output collection
        collTempAvailableReports.Add((IMPSReportInfo *)spNewReportInfo.GetInterfacePtr());
      }
    }

    //Copy the output collection to the output
    collTempAvailableReports.CopyTo(collAvailableReports);

  }

  catch(_com_error &err) {
    return(returnHierarchyReportError(err));
  }


	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function      : CopyReportInfo(spSrc, spDest)                           //
//  Description   : Copy the properties of one ReportInfo object to another //
//  Inputs        : spSrc   -- Report Info to copy from                     //
//                : spDest  -- Report Info to copy to                       //
//  Outputs       : HRESULT                                                 //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CopyReportInfo(MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spSrc, MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spDest)
{
  try {
    spDest->Index                           = spSrc->Index;
    spDest->Name                            = spSrc->Name;
    spDest->Description                     = spSrc->Description;
    spDest->Type                            = spSrc->Type;
    spDest->ViewType                        = spSrc->ViewType;
    spDest->Restricted                      = spSrc->Restricted;
    spDest->RestrictionBillable             = spSrc->RestrictionBillable;
    spDest->RestrictionFolderAccount        = spSrc->RestrictionFolderAccount;
    spDest->RestrictionOwnedFolders         = spSrc->RestrictionOwnedFolders;
    spDest->RestrictionBillableOwnedFolders = spSrc->RestrictionBillableOwnedFolders;
    spDest->RestrictionIndependentAccount   = spSrc->RestrictionIndependentAccount;
    spDest->DisplayMethod                   = spSrc->DisplayMethod;
    spDest->DisplayData                     = spSrc->DisplayData;
    spDest->AccountIDOverride               = spSrc->AccountIDOverride;
		spDest->InlineAdjustments               = spSrc->InlineAdjustments;
		spDest->InteractiveReport               = spSrc->InteractiveReport;
		spDest->InlineVATTaxes									= spSrc->InlineVATTaxes;
  }
  catch(_com_error & err)
  {
    return(returnHierarchyReportError(err));
  }

  return(S_OK);

}
/////////////////////////////////////////////////////////////////////////////
//  Function    : GetIntervalTimeSlice(lngIntervalID)                      //
//  Description : Return an ITimeSlie that can be used to get report data. //
//  Inputs      : lngIntervalID -- ID of the interval
//  Outputs     : ITimeSlice                                                //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetIntervalTimeSlice(long lngIntervalID, ITimeSlice **pTimeSlice)
{
  MTHIERARCHYREPORTSLib::IUsageIntervalSlicePtr spSlice("MTHierarchyReports.UsageIntervalSlice.1");
  
  try
  {
    //Set the range
    spSlice->IntervalID = lngIntervalID;

    *pTimeSlice = reinterpret_cast<ITimeSlice *>(spSlice.Detach());
  }
  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetDateRangeTimeSliceFromInterval(lngIntervalID)          //
//  Description : Return a date range time slice, but one based on a usage  //
//              : interval.                                                 //
//  Inputs      : lngIntervalID -- ID of the usage interval to use for the  //
//              :                  date range slice.                        //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetDateRangeTimeSliceFromInterval(long lngIntervalID, ITimeSlice **pTimeSlice)
{
  MTHIERARCHYREPORTSLib::IDateRangeSlicePtr spSlice("MTHierarchyReports.DateRangeSlice.1");

  try
  {
    if(lngIntervalID > 0) {
      spSlice->IntervalID = lngIntervalID;
      *pTimeSlice = reinterpret_cast<ITimeSlice *>(spSlice.Detach());    
    } else {
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetDateRangeTimeSliceFromInterval()", "Attempt to get a timeslice for a usage interval <= 0.", LOG_ERROR));
    }
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;

}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetDateRangeTimeSlice(dateStart, dateEnd)                 //
//  Description : Get a time slice for the specified date range.            //
//  Inputs      : dateStart -- Start of the date range                      //
//  Outputs     : dateEnd   -- End of the date range                        //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetDateRangeTimeSlice(DATE dateStart, DATE dateEnd, ITimeSlice **pTimeSlice)
{
  MTHIERARCHYREPORTSLib::IDateRangeSlicePtr spSlice("MTHierarchyReports.DateRangeSlice.1");

  try
  {
    //Set the range
    spSlice->Begin = dateStart;
    spSlice->End = dateEnd;

    *pTimeSlice = reinterpret_cast<ITimeSlice *>(spSlice.Detach());
  }
  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : InitializeReport(pTimeSlice, lngReportIndex, sViewType)   //
//  Description : Initialize a report...clear cache, call load report       //
//              : top level.                                                //
//  Inputs      : pTimeSlice      -- Time slice for the report.             //
//              : lngReportIndex  -- Index of the report                    //
//              : sViewType       -- View type for the report.              //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::InitializeReport(ITimeSlice *pTimeSlice, short sViewType, VARIANT_BOOL bShowSecondPass, VARIANT_BOOL bEstimate)
{
  MTHIERARCHYREPORTSLib::IMPSRenderInfoPtr spRenderInfo("MTHierarchyReports.MPSRenderInfo.1");
  HRESULT hr;
  
  msCurrentViewType = sViewType;
  mspTimeSlice = pTimeSlice;
  mbEstimate = bEstimate;
  mbShowSecondPass = bShowSecondPass;

  spRenderInfo->AccountID = mlngAccountID;

  spRenderInfo->ViewType = static_cast<MTHIERARCHYREPORTSLib::MPS_VIEW_TYPE>(sViewType);

  spRenderInfo->TimeSlice = (MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice;

  spRenderInfo->LanguageCode = mlngLanguageID;

  //Identify whether or not to show second pass PV data
	//Note that you can't just || two VARIANT_BOOL together, so the
	//goofy ?: is actually needed to calculate the logical OR.
  spRenderInfo->Estimate = (VARIANT_TRUE == mbShowSecondPass ? mbShowSecondPass : mbEstimate);

  //Clear the QueryParameters
  QueryParameters params;
  mCurrentSummaryParameters = params;
  mCurrentDetailParameters = params;
  
  
  //Clear the cache
  if(FAILED(hr = CacheInitialize()))
    return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "InitializeReport()", "Unable to initialize report cache.", LOG_ERROR));

  //Load the top level of the report into the cache
  if(FAILED(hr = CacheLoadReportTopLevel(spRenderInfo)))
    return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "InitializeReport()", "Unable to load the top level of the report.", LOG_ERROR));

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetCacheXML()                                             //
//  Description : Return the XML stored in the cache.                       //
//  Inputs      : none                                                      //
//  Outputs     : String containing cache value.                            //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetCacheXML(BSTR *pstrXML)
{
	_bstr_t strCacheXML;

  strCacheXML = mspCacheXML->xml;

  *pstrXML = strCacheXML.copy();

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : ShowReportLevel(strLevelID)                               //
//  Description : Make the desired level visible (loading if necessary)     //
//  Inputs      : strLevelID -- ID of the level to show.                    //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::ShowReportLevel(BSTR strLevelID)
{
	HRESULT hr;

  try
  {
    if(FAILED(hr = CacheShowReportLevel(strLevelID)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "ShowReportLevel()", "Unable to load and show report level.", LOG_ERROR));
  }

  catch(_com_error &err) 
  {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : HideReportLevel(strLevelID)                               //
//  Description : Make the desired level invisible                          //
//  Inputs      : strLevelID -- ID of the level to hide.                    //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::HideReportLevel(BSTR strLevelID)
{
	HRESULT hr;

  try
  {
    if(FAILED(hr = CacheHideReportLevel(strLevelID)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "HideReportLevel()", "Unable to hide report level.", LOG_ERROR));
  }

  catch(_com_error &err) 
  {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetReportWithIndex(lngReportIndex)                        //
//  Description : Get the report info object with the specified index.      //
//  Inputs      : lngReportIndex -- The index of the report.                //
//  Outputs     : pointer to the reportinfo object.                         //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetReportWithIndex(long lngReportIndex, IMPSReportInfo **pReport)
{
  MTHIERARCHYREPORTSLib::IMPSReportInfo *pReportInfo;
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spReportInfo;
  bool bFound = false;
  long i = 0;
  HRESULT hr;


  try
  {
    for(i = 1; i <= mlngReportCount; i++) {
  
      if(FAILED(hr = mcollAvailableReports.Item(i, &pReportInfo)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportWithIndex()", "Unable to get an item from the collection of available reports.", LOG_ERROR));

      spReportInfo = pReportInfo;
			pReportInfo->Release();
			pReportInfo = 0;

      if(spReportInfo->Index == lngReportIndex) {
        bFound = true;
        i = mlngReportCount + 1;
      }
    }

    if(!bFound)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportWithIndex()", "Unable to find report with specified index.", LOG_ERROR));

    *pReport = (IMPSReportInfo *)spReportInfo.Detach();

  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetCombinedTimeSlice(pTimeSliceIn)                        //
//  Description : Create a timeslice representing the AND of the argument   //
//              : with the current timeslice.                               //
//  Inputs      : pTimeSliceIn -- Slice to AND                              //
//  Outputs     : Result of ANDing                                          //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetCombinedTimeSlice(ITimeSlice *pTimeSliceIn, ITimeSlice **pTimeSliceOut)
{
   
  try
  {
    if(pTimeSliceIn != NULL)
    {
      MTHIERARCHYREPORTSLib::IIntersectionTimeSlicePtr spCompositeSlice("MTHierarchyReports.IntersectionTimeSlice.1");
      
      spCompositeSlice->LHS = (MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSliceIn;
      spCompositeSlice->RHS = mspTimeSlice;

      *pTimeSliceOut = (ITimeSlice *)spCompositeSlice.Detach();
    
    } else {

      MTHIERARCHYREPORTSLib::ITimeSlicePtr spTimeSlice = mspTimeSlice;

      *pTimeSliceOut = (ITimeSlice *)spTimeSlice.Detach();
    }
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetUsageSummary(pViewSlice, pAccountSlice, pTimeSlice)    //
//  Description : Get the usage summary from a product view.                //
//  Inputs      : pViewSlice -- Products to get                             //
//              : pAccountSlice -- Accounts predicate to apply              //
//              : pTimeSlice -- Time predicate to apply                     //
//              : bUseDatamart -- Use Materialized Views if enabled         //
//  Outputs     : MTSQLRowset with the data.                                //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetUsageSummary(IViewSlice *pViewSlice,
                                            IAccountSlice *pAccountSlice,
                                            ITimeSlice *pTimeSlice,
                                            IMTSQLRowset **pRowset)
{
  return GetUsageSummary2(pViewSlice, pAccountSlice, pTimeSlice, VARIANT_TRUE, pRowset);
}

STDMETHODIMP CReportHelper::GetUsageSummary2(IViewSlice *pViewSlice,
                                             IAccountSlice *pAccountSlice,
                                             ITimeSlice *pTimeSlice,
                                             VARIANT_BOOL bUseDatamart,
                                             IMTSQLRowset **pRowset)
{
  try
  {
		// First check the cache
    QueryParameters params(                                      
			(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
			(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
			(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
			mlngLanguageID);

		if (!mCurrentSummaryParameters.Equals(params))
		{
			MTHIERARCHYREPORTSLib::IUsageSummaryQueryPtr spUSQ("MTHierarchyReports.UsageSummaryQuery.1");
      MTHIERARCHYREPORTSLib::IReportHelperPtr ThisPtr = this;
      spUSQ->InlineAdjustments = ThisPtr->InlineAdjustments;
      spUSQ->InteractiveReport = ThisPtr->InteractiveReport;
			spUSQ->InlineVATTaxes = ThisPtr->ReportInfo->InlineVATTaxes;

			_bstr_t strQuery;

			strQuery = spUSQ->GenerateQueryString(mlngLanguageID,
																						(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
																						(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
																						(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
                                            bUseDatamart);


			mCurrentSummaryRowset.CreateInstance(MTPROGID_SQLROWSET);

			mCurrentSummaryRowset->Init("Queries\\PresServer");

			mCurrentSummaryRowset->SetQueryString(strQuery);

			mCurrentSummaryRowset->ExecuteDisconnected();

			long initialPage = mCurrentSummaryRowset->CurrentPage;

			mCurrentSummaryParameters = params;
		}
		else
		{
			if(mCurrentSummaryRowset->RecordCount > 0) 
			{
				mCurrentSummaryRowset->MoveFirst();
				mCurrentSummaryRowset->CurrentPage = 1;
			}
		}

		ROWSETLib::IMTSQLRowsetPtr spRowset = mCurrentSummaryRowset;
    *pRowset = (IMTSQLRowset *)spRowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : ClearUsageDetailCache                                     //
//  Description : explicitly clear cached usage detail rowset               //
//  Inputs      :                                                           //
//  Output      :                                                           //
//////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CReportHelper::ClearUsageDetailCache()
{
  //Clear the QueryParameters
  QueryParameters params;
  mCurrentSummaryParameters = params;
  mCurrentDetailParameters = params;
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetUsageDetail(pProductSlice, pViewSlice, pAccountSlice   //
//              :                 pTimeSlice, lngTopRows                    //
//  Description : Get usage detail for an item in a product view            //
//  Inputs      : pProductSlice -- Products to select                       //
//              : pViewSlice    -- Sessions to select                       //
//              : pAcountSlice  -- Accounts predicate to apply              //
//              : pTimeSlice    -- Time predicate to apply                  //
//              : vQueryParams  -- QueryParams object                       //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetUsageDetail(ISingleProductSlice *pProductSlice,
                                           IViewSlice *pViewSlice,
                                           IAccountSlice *pAccountSlice,
                                           ITimeSlice *pTimeSlice,
                                           BSTR aExtension,
                                           IMTSQLRowset **pRowset)
{
   // Old hard-coded value found in original query.
  #define MAX_ROWS_TO_RETURN_FROM_QUERY  1001

  try
  {
		// First check the cache
    QueryParameters params(                                      
			(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
			(MTHIERARCHYREPORTSLib::ISingleProductSlice *)pProductSlice, 
			(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
			(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
			_bstr_t(aExtension),
			mlngLanguageID,
      MAX_ROWS_TO_RETURN_FROM_QUERY);

		if (!mCurrentDetailParameters.Equals(params))
		{
			MTHIERARCHYREPORTSLib::IUsageDetailQueryPtr spUDQ("MTHierarchyReports.UsageDetailQuery.1");
      MTHIERARCHYREPORTSLib::IReportHelperPtr ThisPtr = this;
      spUDQ->InlineAdjustments = ThisPtr->InlineAdjustments;
      spUDQ->InteractiveReport = ThisPtr->InteractiveReport;
			spUDQ->InlineVATTaxes = ThisPtr->ReportInfo->InlineVATTaxes;

      // Populate query params.
      MTHIERARCHYREPORTSLib::IQueryParamsPtr spQueryParams("MTHierarchyReports.QueryParams");
      spQueryParams->put_TimeSlice(reinterpret_cast<MTHIERARCHYREPORTSLib::ITimeSlice *>(pTimeSlice));
      spQueryParams->put_SingleProductSlice(reinterpret_cast<MTHIERARCHYREPORTSLib::ISingleProductSlice *>(pProductSlice));
      spQueryParams->put_SessionSlice(reinterpret_cast<MTHIERARCHYREPORTSLib::IViewSlice *>(pViewSlice));
      spQueryParams->put_AccountSlice(reinterpret_cast<MTHIERARCHYREPORTSLib::IAccountSlice *>(pAccountSlice));
      spQueryParams->put_Extension(aExtension);
      spQueryParams->put_TopRows(MAX_ROWS_TO_RETURN_FROM_QUERY);

			_bstr_t strQuery = spUDQ->GenerateQueryString(mlngLanguageID, spQueryParams);

			mCurrentDetailRowset.CreateInstance(MTPROGID_SQLROWSET);

			mCurrentDetailRowset->Init("Queries\\PresServer");

			mCurrentDetailRowset->SetQueryString(strQuery);

			mCurrentDetailRowset->ExecuteDisconnected();

			long initialPage = mCurrentDetailRowset->CurrentPage;

			mCurrentDetailParameters = params;
		}
		else
		{
			if(mCurrentDetailRowset->RecordCount > 0) 
			{
				mCurrentDetailRowset->MoveFirst();
				mCurrentDetailRowset->CurrentPage = 1;
			}
		}

		ROWSETLib::IMTSQLRowsetPtr spRowset = mCurrentDetailRowset;
    *pRowset = (IMTSQLRowset *)spRowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetUsageDetail2(pQueryParams)                             //
//  Description : Get usage detail for an item in a product view            //
//  Inputs      : pQueryParams -- Object that contains all the query params //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetUsageDetail2(IQueryParams *pQueryParams,
                                            IMTSQLRowset **pRowset)
{
  try
  {
    MTHIERARCHYREPORTSLib::ITimeSlicePtr pTimeSlice;
    HRESULT hr = pQueryParams->get_TimeSlice((ITimeSlice **) &pTimeSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pTimeSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: TimeSlice");

    MTHIERARCHYREPORTSLib::IAccountSlicePtr pAccountSlice;
    hr = pQueryParams->get_AccountSlice((IAccountSlice**) &pAccountSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pAccountSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: AccountSlice");

    MTHIERARCHYREPORTSLib::ISingleProductSlicePtr pProductSlice;
    hr = pQueryParams->get_SingleProductSlice((ISingleProductSlice**) &pProductSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pProductSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: SingleProductSlice");

    MTHIERARCHYREPORTSLib::IViewSlicePtr pSessionSlice;
    hr = pQueryParams->get_SessionSlice((IViewSlice**) &pSessionSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pSessionSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: SessionSlice");

    BSTR aExtension;
    hr = pQueryParams->get_Extension(&aExtension);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);

    long lTopRows;
    hr = pQueryParams->get_TopRows(&lTopRows);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);

		// First check the cache
    QueryParameters params(pTimeSlice, pProductSlice, pSessionSlice, pAccountSlice,
                           _bstr_t(aExtension), mlngLanguageID, lTopRows);

		if (!mCurrentDetailParameters.Equals(params))
		{
			MTHIERARCHYREPORTSLib::IUsageDetailQueryPtr spUDQ("MTHierarchyReports.UsageDetailQuery.1");
      MTHIERARCHYREPORTSLib::IReportHelperPtr ThisPtr = this;
      spUDQ->InlineAdjustments = ThisPtr->InlineAdjustments;
      spUDQ->InteractiveReport = ThisPtr->InteractiveReport;
			spUDQ->InlineVATTaxes = ThisPtr->ReportInfo->InlineVATTaxes;

			_bstr_t strQuery = spUDQ->GenerateQueryString(mlngLanguageID,
                                                    reinterpret_cast<MTHIERARCHYREPORTSLib::IQueryParams *>(pQueryParams));

			mCurrentDetailRowset.CreateInstance(MTPROGID_SQLROWSET);

			mCurrentDetailRowset->Init("Queries\\PresServer");

			mCurrentDetailRowset->SetQueryString(strQuery);

			mCurrentDetailRowset->ExecuteDisconnected();

			long initialPage = mCurrentDetailRowset->CurrentPage;

			mCurrentDetailParameters = params;
		}
		else
		{
			if(mCurrentDetailRowset->RecordCount > 0) 
			{
				mCurrentDetailRowset->MoveFirst();
				mCurrentDetailRowset->CurrentPage = 1;
			}
		}

		ROWSETLib::IMTSQLRowsetPtr spRowset = mCurrentDetailRowset;
    *pRowset = (IMTSQLRowset *)spRowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetTransactionDetail(pProductSlice, pViewSlice,           // 
//              :                      pAccountSlice, pTimeSlice)           //
//  Description : Get transaction detail for an item in a product view      //
//  Inputs      : pProductSlice -- Products to select                       //
//              : pViewSlice    -- Sessions to select                       //
//              : pAcountSlice  -- Accounts predicate to apply              //
//              : pTimeSlice    -- Time predicate to apply                  //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetTransactionDetail(ISingleProductSlice *pProductSlice, IViewSlice *pViewSlice, IAccountSlice *pAccountSlice, ITimeSlice *pTimeSlice, BSTR aExtension, IMTSQLRowset **pRowset)
{
  try
  {
		// First check the cache
    QueryParameters params(                                      
			(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
			(MTHIERARCHYREPORTSLib::ISingleProductSlice *)pProductSlice, 
			(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
			(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
			_bstr_t(aExtension),
			mlngLanguageID);

    if (!mCurrentDetailParameters.Equals(params))
		{
			MTHIERARCHYREPORTSLib::IUsageDetailQueryPtr spUDQ("MTHierarchyReports.UsageDetailQuery.1");
      MTHIERARCHYREPORTSLib::IReportHelperPtr ThisPtr = this;
      spUDQ->InlineAdjustments = ThisPtr->InlineAdjustments;
      spUDQ->InteractiveReport = ThisPtr->InteractiveReport;
			spUDQ->InlineVATTaxes = ThisPtr->ReportInfo->InlineVATTaxes;

			_bstr_t strQuery;

			strQuery = spUDQ->GenerateQueryStringFinder(mlngLanguageID,
																						(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
																						(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
																						(MTHIERARCHYREPORTSLib::ISingleProductSlice *)pProductSlice, 
																						(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
																						_bstr_t(aExtension));

			mCurrentDetailRowset.CreateInstance(MTPROGID_SQLROWSET);

			mCurrentDetailRowset->Init("Queries\\PresServer");

			mCurrentDetailRowset->SetQueryString(strQuery);

			mCurrentDetailRowset->ExecuteDisconnected();

			long initialPage = mCurrentDetailRowset->CurrentPage;

			mCurrentDetailParameters = params;
		}
		else
		{
			if(mCurrentDetailRowset->RecordCount > 0) 
			{
				mCurrentDetailRowset->MoveFirst();
				mCurrentDetailRowset->CurrentPage = 1;
			}
		}

		ROWSETLib::IMTSQLRowsetPtr spRowset = mCurrentDetailRowset;
    *pRowset = (IMTSQLRowset *)spRowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetTransactionDetail2(pProductSlice, pViewSlice,          // 
//              :                      pAccountSlice, pTimeSlice)           //
//  Description : Get transaction detail for an item in a product view      //
//              : TOP 1000 ONLY                                             //  
//  Inputs      : pProductSlice -- Products to select                       //
//              : pViewSlice    -- Sessions to select                       //
//              : pAcountSlice  -- Accounts predicate to apply              //
//              : pTimeSlice    -- Time predicate to apply                  //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetTransactionDetail2(ISingleProductSlice *pProductSlice, IViewSlice *pViewSlice, IAccountSlice *pAccountSlice, ITimeSlice *pTimeSlice, BSTR aExtension, IMTSQLRowset **pRowset)
{
  try
  {
    #define MAX_ROWS_TO_RETURN_FROM_QUERY  1001

    // First check the cache
    QueryParameters params(                                      
			(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
			(MTHIERARCHYREPORTSLib::ISingleProductSlice *)pProductSlice, 
			(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
			(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
			_bstr_t(aExtension),
			mlngLanguageID,
      MAX_ROWS_TO_RETURN_FROM_QUERY);

		if (!mCurrentDetailParameters.Equals(params))
		{
			MTHIERARCHYREPORTSLib::IUsageDetailQueryPtr spUDQ("MTHierarchyReports.UsageDetailQuery.1");
      MTHIERARCHYREPORTSLib::IReportHelperPtr ThisPtr = this;
      spUDQ->InlineAdjustments = ThisPtr->InlineAdjustments;
      spUDQ->InteractiveReport = ThisPtr->InteractiveReport;
			spUDQ->InlineVATTaxes = ThisPtr->ReportInfo->InlineVATTaxes;

			_bstr_t strQuery;

			strQuery = spUDQ->GenerateQueryStringFinder(mlngLanguageID,
																						(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
																						(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
																						(MTHIERARCHYREPORTSLib::ISingleProductSlice *)pProductSlice, 
																						(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
																						_bstr_t(aExtension));

			mCurrentDetailRowset.CreateInstance(MTPROGID_SQLROWSET);

			mCurrentDetailRowset->Init("Queries\\PresServer");

			mCurrentDetailRowset->SetQueryString(strQuery);

			mCurrentDetailRowset->ExecuteDisconnected();

			long initialPage = mCurrentDetailRowset->CurrentPage;

			mCurrentDetailParameters = params;
		}
		else
		{
			if(mCurrentDetailRowset->RecordCount > 0) 
			{
				mCurrentDetailRowset->MoveFirst();
				mCurrentDetailRowset->CurrentPage = 1;
			}
		}

		ROWSETLib::IMTSQLRowsetPtr spRowset = mCurrentDetailRowset;
    *pRowset = (IMTSQLRowset *)spRowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetAdjustmentDetail(pProductSlice, pViewSlice, pAccountSlice   //
//              :                pTimeSlice)                                //
//  Description : Get adjustment detail for an item in a product view            //
//  Inputs      : pProductSlice -- Products to select                       //
//              : pViewSlice    -- Sessions to select                       //
//              : pAcountSlice  -- Accounts predicate to apply              //
//              : pTimeSlice    -- Time predicate to apply                  //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetAdjustmentDetail(ISingleProductSlice *pProductSlice, IViewSlice *pViewSlice, IAccountSlice *pAccountSlice, ITimeSlice *pTimeSlice, BSTR aExtension, IMTSQLRowset **pRowset)
{
  try
  {
		// First check the cache
    QueryParameters params(                                      
			(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
			(MTHIERARCHYREPORTSLib::ISingleProductSlice *)pProductSlice, 
			(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
			(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
			_bstr_t(aExtension),
			mlngLanguageID);

		if (!mCurrentAdjustmentDetailParameters.Equals(params))
		{
			MTHIERARCHYREPORTSLib::IUsageDetailQueryPtr spUDQ("MTHierarchyReports.UsageDetailQuery.1");
			_bstr_t strQuery;

			strQuery = spUDQ->GenerateAdjustmentQueryString(mlngLanguageID,
																						(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
																						(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
																						(MTHIERARCHYREPORTSLib::ISingleProductSlice *)pProductSlice, 
																						(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
																						_bstr_t(aExtension));

			mCurrentAdjustmentDetailRowset.CreateInstance(MTPROGID_SQLROWSET);

			mCurrentAdjustmentDetailRowset->Init("Queries\\PresServer");

			mCurrentAdjustmentDetailRowset->SetQueryString(strQuery);

			mCurrentAdjustmentDetailRowset->ExecuteDisconnected();

			long initialPage = mCurrentAdjustmentDetailRowset->CurrentPage;

			mCurrentAdjustmentDetailParameters = params;
		}
		else
		{
			if(mCurrentAdjustmentDetailRowset->RecordCount > 0) 
			{
				mCurrentAdjustmentDetailRowset->MoveFirst();
				mCurrentAdjustmentDetailRowset->CurrentPage = 1;
			}
		}

		ROWSETLib::IMTSQLRowsetPtr spRowset = mCurrentAdjustmentDetailRowset;
    *pRowset = (IMTSQLRowset *)spRowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetBaseAdjustmentDetail(pViewSlice, pAccountSlice         //
//              :                pTimeSlice, aIsPostbill)                   //
//  Description : Get adjustment details in common for all products         //
//  Inputs      : pViewSlice    -- Sessions to select                       //
//              : pAcountSlice  -- Accounts predicate to apply              //
//              : pTimeSlice    -- Time predicate to apply                  //
//              : aIsPostbill    -- Do you want prebill or postbill adjs?   //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetBaseAdjustmentDetail(IViewSlice *pViewSlice, IAccountSlice *pAccountSlice, ITimeSlice *pTimeSlice, BSTR aExtension, VARIANT_BOOL aIsPostbill, IMTSQLRowset **pRowset)
{
  try
  {
		// First check the cache.  We have a separate one for prebill and postbill.
    QueryParameters params(                                      
			(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
			NULL, 
			(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
			(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
			_bstr_t(aExtension),
			mlngLanguageID);

		QueryParameters& currentBaseAdjustmentDetailParameters((VARIANT_TRUE == aIsPostbill) ? mCurrentPostbillAdjustmentDetailParameters : mCurrentPrebillAdjustmentDetailParameters);
		ROWSETLib::IMTSQLRowsetPtr& currentBaseAdjustmentDetailRowset((VARIANT_TRUE == aIsPostbill) ? mCurrentPostbillAdjustmentDetailRowset : mCurrentPrebillAdjustmentDetailRowset);

		if (!currentBaseAdjustmentDetailParameters.Equals(params))
		{
			MTHIERARCHYREPORTSLib::IUsageDetailQueryPtr spUDQ("MTHierarchyReports.UsageDetailQuery.1");
			_bstr_t strQuery;

			strQuery = spUDQ->GenerateBaseAdjustmentQueryString(mlngLanguageID,
																						(MTHIERARCHYREPORTSLib::ITimeSlice *)pTimeSlice, 
																						(MTHIERARCHYREPORTSLib::IAccountSlice *)pAccountSlice, 
																						(MTHIERARCHYREPORTSLib::IViewSlice *)pViewSlice,
																						_bstr_t(aExtension),
																						aIsPostbill);

			currentBaseAdjustmentDetailRowset.CreateInstance(MTPROGID_SQLROWSET);

			currentBaseAdjustmentDetailRowset->Init("Queries\\PresServer");

			currentBaseAdjustmentDetailRowset->SetQueryString(strQuery);

			currentBaseAdjustmentDetailRowset->ExecuteDisconnected();

			long initialPage = currentBaseAdjustmentDetailRowset->CurrentPage;

			currentBaseAdjustmentDetailParameters = params;
		}
		else
		{
			if(currentBaseAdjustmentDetailRowset->RecordCount > 0) 
			{
				currentBaseAdjustmentDetailRowset->MoveFirst();
				currentBaseAdjustmentDetailRowset->CurrentPage = 1;
			}
		}

		ROWSETLib::IMTSQLRowsetPtr spRowset = currentBaseAdjustmentDetailRowset;
    *pRowset = (IMTSQLRowset *)spRowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetPostBillAdjustmentDetail(pTimeSlice)                   //
//  Description : Get usage detail for an item in a product view            //
//  Inputs      : pProductSlice -- Products to select                       //
//              : pViewSlice    -- Sessions to select                       //
//              : pAcountSlice  -- Accounts predicate to apply              //
//              : pTimeSlice    -- Time predicate to apply                  //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetPostBillAdjustmentDetail(long intervalid, long accountid, IMTSQLRowset **pRowset)
{
  try
  {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

		rowset->Init("Queries\\PresServer");
		rowset->SetQueryTag("__GET_POST_BILL_ADJUSTMENT_DETAIL__");
		rowset->AddParam("%%ID_INTERVAL%%", intervalid);
		rowset->AddParam("%%ID_ACC%%", accountid);
		rowset->AddParam("%%LANG_CODE%%", mlngLanguageID);
		rowset->ExecuteDisconnected();

    *pRowset = (IMTSQLRowset *)rowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetPostBillAdjustmentDetail(pTimeSlice)                   //
//  Description : Get usage detail for an item in a product view            //
//  Inputs      : pProductSlice -- Products to select                       //
//              : pViewSlice    -- Sessions to select                       //
//              : pAcountSlice  -- Accounts predicate to apply              //
//              : pTimeSlice    -- Time predicate to apply                  //
//  Output      : MTSQLRowset with the data                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetPreBillAdjustmentDetail(long intervalid, long accountid, IMTSQLRowset **pRowset)
{
  try
  {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

		rowset->Init("Queries\\PresServer");
		rowset->SetQueryTag("__GET_PRE_BILL_ADJUSTMENT_DETAIL__");
		rowset->AddParam("%%ID_INTERVAL%%", intervalid);
		rowset->AddParam("%%ID_ACC%%", accountid);
		rowset->ExecuteDisconnected();

    *pRowset = (IMTSQLRowset *)rowset.Detach();
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : CreateDetailSlice                                         //
//  Description : Create a SessionSlice describing the current row          //
//  Inputs      : pRowset -- Rowset pointing to the session                 //
//  Output      : IViewSlice specifying the session                         //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::CreateDetailSlice(IMTSQLRowset * pRowset, IViewSlice* *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	try
	{
    MTHIERARCHYREPORTSLib::ISessionSlicePtr ptr(__uuidof(MTHIERARCHYREPORTSLib::SessionSlice));
    ROWSETLib::IMTSQLRowsetPtr rowset(pRowset);
    ptr->SessionID = __int64(rowset->GetValue(L"SessionID"));
    *pVal = reinterpret_cast<IViewSlice *>(ptr.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
  
}

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetReportLevelAsXML(strLevel, pstrXML)                    //
//  Description : Return the data for one XML report level.                 //
//  Inputs      : strLevel -- Level to get data for                         //
//  Outputs     : XML for the report level.                                 //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetReportLevelAsXML(BSTR strLevel, BSTR *pstrXML)
{
  MSXML2::IXMLDOMNodePtr spNode = NULL;
  _bstr_t strQuery;

  HRESULT hr;
  try
  {
    if(FAILED(hr = ShowReportLevel(strLevel)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportLevelAsXML()", "Unable to load XML level.", LOG_ERROR));
    
    //Now get the node in the hierarchy
    strQuery = _bstr_t(L"//level[@cacheID = '") + _bstr_t(strLevel) + _bstr_t(L"']");

    spNode = mspCacheXML->selectSingleNode(strQuery);

    if(spNode == NULL)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportLevelAsXML()", "Unable to find report level.", LOG_ERROR));

    *pstrXML = spNode->xml;
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetReportAsXML()                                          //
//  Description : Get the entire report in XML format.                      //
//  Inputs      : none                                                      //
//  Outputs     : XML for the report.                                       //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::GetReportAsXML(BSTR *pstrXML)
{
  MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr spReportLevel;
  MTHIERARCHYREPORTSLib::IHierarchyReportLevel *pReportLevel;
  MSXML2::IXMLDOMDocumentPtr spXML("MSXML2.DOMDocument.4.0");
  MSXML2::IXMLDOMParseErrorPtr spParseError = NULL;
  MSXML2::IXMLDOMNodeListPtr spNodeList;
  MSXML2::IXMLDOMNode *pNode;
  MSXML2::IXMLDOMNodePtr spNode;
  MSXML2::IXMLDOMAttributePtr spAttr;
  
  HRESULT hr;

  _bstr_t strXML;

  bool bFound = false;

  long lngErrorCode = 0;
  long lngCount = 0;
  long i = 0;

  try
  {
    //First, check if the level has already been cached.  If it has, do nothing
    if(FAILED(hr = mcollReportLevels.Count(&lngCount)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportAsXML()", "Unable to get count of cached report levels.", LOG_ERROR));

    //Get the root level
    for(i = 1; i <= lngCount; i++)
    {
      //Get the item from the collection
      if(FAILED(hr = mcollReportLevels.Item(i, &pReportLevel)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportAsXML()", "Unable to get a ReportInfo object from the collection.", LOG_ERROR));

      //Check if this is the item we want
      spReportLevel = pReportLevel;
			pReportLevel->Release();
			pReportLevel = 0;
      
      if(_bstr_t(spReportLevel->ExternalID) == _bstr_t("0"))
      {
        bFound = true;
        i = lngCount + 1;
      }
    }

    
    if(!bFound)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportAsXML()", "Unable to find the report with the specified index.", LOG_ERROR));
    
    //Load the XML to generate id's
    strXML = spReportLevel->GetReportLevelAsXML(true);

    if(strXML.length() == 0)
      return S_OK;

    //check for parse error
    if(!spXML->loadXML(strXML))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportAsXML()", "Unable to load report level XML.", LOG_ERROR));

    spParseError = spXML->parseError;

    lngErrorCode = spParseError->errorCode;

    if(lngErrorCode != 0)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportAsXML()", "An error occurred while parsing the XML for the level.", LOG_ERROR));

    //Append a cacheID to each node...this ID can be used by the consumer to
    //uniquely identify each level.
    spNodeList = spXML->selectNodes("//level");

    for(i = 0; i < spNodeList->length; i++)
    {
      if(FAILED(hr = spNodeList->get_item(i, &pNode)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "GetReportAsXML()", "Unable to get a Node from the NodeList.", LOG_ERROR));

      spNode = pNode;
			pNode->Release();
			pNode = 0;

      spAttr = spXML->createAttribute("unique_id");
      spAttr->value = i;

      spNode->attributes->setNamedItem(spAttr);
    }

    //Now output the XML
    *pstrXML = spXML->xml;
  }
  
  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//  Property    : ReportIndex                                               //
//  Description : Return the index of the current report.                   //
//  Inputs      : none                                                      //
//  Outputs     : index of the current report.                              //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_ReportIndex(long *pVal)
{
	*pVal = mlngCurrentReport;

	return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::put_ReportIndex(long lngIndex)
{
  MTHIERARCHYREPORTSLib::IMPSReportInfo *pReportInfo;
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spReportInfo;
  long i = 0;
  HRESULT hr;
  bool bFound = false;

  //Set initialized to false
  mbInitialized = VARIANT_FALSE;

  //Make sure reports are available    
  if(mlngReportCount == 0)
    return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "put_ReportIndex()", "Attempt to initialize report when none are available.", LOG_ERROR));


  //Check report index
  if(lngIndex < 1) {
    return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "put_ReportIndex()", "Attempt to initialize report with index < 1.  Index should be >= 1 and less than ReportCount.", LOG_ERROR));
  } else {
    //Don't change anything about the report if nothing changed
    if(lngIndex != mlngCurrentReport) {
      mlngCurrentReport = lngIndex;
  
      //Attempt to find the report
      for(i = 1; i <= mlngReportCount; i++) {
  
        if(FAILED(hr = mcollAvailableReports.Item(i, &pReportInfo)))
          return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "put_ReportIndex()", "Unable to get ReportInfo object from the collection.", LOG_ERROR));

        spReportInfo = pReportInfo;
				pReportInfo->Release();
				pReportInfo = 0;


        if(spReportInfo->Index == mlngCurrentReport) {
          bFound = true;
          i = mlngReportCount + 1;
        }
      }

      //Error if the report couldn't be found
      if(!bFound)
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "put_ReportIndex()", "Unable to find report with specified index.", LOG_ERROR));

      //Store the report info object
      mspReportInfo = spReportInfo;

      //Now initialize the default intervals for the report and set the AccountID
      if(spReportInfo->AccountIDOverride > 0) {
        mlngAccountID = spReportInfo->AccountIDOverride;

        if(FAILED(hr = GetOverrideDefaultIntervalData()))
          return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "put_ReportIndex()", "Unable to get default interval data for the override account.", LOG_ERROR));
  
      } else {
        mlngAccountID = mYAAC->AccountID;
      }
    }
  }

  mbInitialized = VARIANT_TRUE;

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Property    : ViewType                                                  //
//  Description : Return the view type for the current report.              //
//  Inputs      : none                                                      //
//  Outputs     : View type of the selected report.                         //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_ViewType(short *pVal)
{
	*pVal = msCurrentViewType;

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Property    : TimeSlice()                                               //
//  Description : Return the currently utilized time slice.                 //
//  Inputs      : none                                                      //
//  Outputs     : current time slice                                        //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_TimeSlice(ITimeSlice **pVal)
{
  MTHIERARCHYREPORTSLib::ITimeSlicePtr spTimeSlice;

  spTimeSlice = mspTimeSlice;

  *pVal = (ITimeSlice *)spTimeSlice.Detach();

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Property    : AccountID()                                               //
//  Description : Return the account ID for the current report.             //
//  Inputs      : none                                                      //
//  Outputs     : Account ID for current report.                            //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_AccountID(long *pVal)
{
  *pVal = mlngAccountID;

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Property    : ReportInfo()                                              //
//  Description : Return the current report info.                           //
//  Inputs      : none                                                      //
//  Outputs     : Current report info.                                      //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_ReportInfo(IMPSReportInfo **pVal)
{
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spReportInfo;

  spReportInfo = mspReportInfo;

  *pVal = (IMPSReportInfo *)spReportInfo.Detach();

	return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
//  Property    : IsEstimate()                                             //
//  Description : Indicates whether or not the data represents an estimate //
//              : or not.                                                  //
//  Inputs      : none                                                     //
//  Outputs     : Boolean indicating whether or not an estimate is         //
//              : represented.                                             //
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CReportHelper::get_IsEstimate(VARIANT_BOOL *pVal)
{
	*pVal = mbEstimate;

	return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
//  Property    : ShowSecondPass                                           //
//              : Indicates whether or not the data is showing second-pass //
//              : PV data or not.                                          //
//  Inputs      : none                                                     //
//  Outputs     : Boolean indicating whether or not second-pass data is    //
//              : being shown.                                             //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_ShowSecondPass(VARIANT_BOOL *pVal)
{
	*pVal = mbShowSecondPass;

	return S_OK;
}
////////////////////////////////////////////////////////////////////////////
//  Property    : DefaultIntervalID                                       //
//  Description : Get the ID of the default interval for the current      //
//              : report.                                                 //
//  Inputs      : none                                                    //
//  Outputs     : ID of the default interval.                             //
////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_DefaultIntervalID(long *pVal)
{
  try {
    if(mbInitialized == VARIANT_TRUE) {
      if(mspReportInfo->AccountIDOverride > 0)
        *pVal = mlngOverrideDefaultIntervalID;
      else
        *pVal = mlngDefaultIntervalID;
    } else {
      *pVal = mlngDefaultIntervalID;
    }
  } catch(_com_error & e) {
    return returnHierarchyReportError(e);
  }

	return S_OK;
}
////////////////////////////////////////////////////////////////////////////
//  Property    : DefaultStartDate                                        //
//  Description : Get the default start date for the report.              //
//  Inputs      : none                                                    //
//  Outputs     : Default start date for the report.                      //
////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_DefaultStartDate(DATE *pVal)
{
  try {
    if(mbInitialized == VARIANT_TRUE) {
      if(mspReportInfo->AccountIDOverride > 0)
        *pVal = mdateOverrideDefaultStartDate;
      else
        *pVal = mdateDefaultStartDate;
    } else {
      *pVal = mdateDefaultStartDate;
    }
  } catch(_com_error & e) {
    return returnHierarchyReportError(e);
  }

	return S_OK;
}
////////////////////////////////////////////////////////////////////////////
//  Property    : DefaultEndDate                                          //
//  Description : Get the default end date for the report.                //
//  Inputs      : none                                                    //
//  Outputs     : Default end date for the report.                        //
////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_DefaultEndDate(DATE *pVal)
{
  try {
    if(mbInitialized == VARIANT_TRUE) {
    	if(mspReportInfo->AccountIDOverride > 0)
        *pVal = mdateOverrideDefaultEndDate;
      else
        *pVal = mdateDefaultEndDate;
    } else {
      *pVal = mdateDefaultEndDate;
    }
  } catch(_com_error & e) {
    return returnHierarchyReportError(e);
  }
	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : get_HasAggregateCharges                                   //
//  Description : Read only property indicating whether the report          //
//                has aggregate rated charges on it.                        //
//  Inputs      : none                                                      //
//  Outputs     : True if there are aggregate rated charges.                //
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CReportHelper::get_HasAggregateCharges(VARIANT_BOOL *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = VARIANT_FALSE;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\PresServer");
		if(mspReportInfo->Type == REPORT_TYPE_BILL)
		{
			rowset->SetQueryTag(L"__GET_HASAGGREGATECHARGESFORPAYER__");
			rowset->AddParam(L"%%ID_PAYER%%", mlngAccountID);
		}
		else
		{
			rowset->SetQueryTag(L"__GET_HASAGGREGATECHARGES__");
			rowset->AddParam(L"%%ID_ACC%%", mlngAccountID);
			DATE dtBegin, dtEnd;
			mspTimeSlice->GetTimeSpan(&dtBegin, &dtEnd);
			std::wstring buffer;
			BOOL bSuccess = FormatValueForDB(_variant_t(dtBegin, VT_DATE), FALSE, buffer);
			if (bSuccess == FALSE)
			{
				return Error("Failure formatting DATE for database write");
			}
			rowset->AddParam(L"%%DT_BEGIN%%", buffer.c_str(), VARIANT_TRUE);
			bSuccess = FormatValueForDB(_variant_t(dtEnd, VT_DATE), FALSE, buffer);
			if (bSuccess == FALSE)
			{
				return Error("Failure formatting DATE for database write");
			}
			rowset->AddParam(L"%%DT_END%%", buffer.c_str(), VARIANT_TRUE);			
		}
		rowset->AddParam(L"%%TIME_PREDICATE%%", mspTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);

		rowset->Execute();
		ASSERT(rowset->RecordCount == 1);
		_bstr_t result = _bstr_t(rowset->GetValue(L"HasAggregate"));
		*pVal = (result == _bstr_t(L"Y")) ? VARIANT_TRUE : VARIANT_FALSE;
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//                         DEFAULT INTERVAL FUNCTIONS                       //
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//  Function    : GetUserDefaultIntervalData()                              //
//  Description : Set the default interval ID, start date, and end date for //
//              : the users interval.                                       //
//  Inputs      : none                                                      //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::GetUserDefaultIntervalData()
{
  COMDBOBJECTSLib::ICOMDataAccessorPtr spDataAccessor("ComDataAccessor.ComDataAccessor.1");
  ROWSETLib::IMTSQLRowsetPtr spRowset;
  
  try {
    if(mYAAC == NULL)
      return S_OK;
    spDataAccessor->AccountID = mYAAC->AccountID;

    spRowset = spDataAccessor->GetUsageInterval();

    //Attempt to get the first item
    if((bool)spRowset->RowsetEOF == false) {
      spRowset->MoveFirst();

      mlngDefaultIntervalID = spRowset->GetValue(L"intervalID");
      mdateDefaultStartDate = spRowset->GetValue(L"StartDate");
      mdateDefaultEndDate   = spRowset->GetValue(L"EndDate");
    }
  } catch(_com_error &e) {
   return returnHierarchyReportError(e);
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : GetOverrideDefaultIntervalData()                          //
//  Description : Set the default interval ID, start date, and end date for //
//              : the override account in the report info object.           //
//  Inputs      : none                                                      //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::GetOverrideDefaultIntervalData()
{
  COMDBOBJECTSLib::ICOMDataAccessorPtr spDataAccessor("ComDataAccessor.ComDataAccessor.1");
  ROWSETLib::IMTSQLRowsetPtr spRowset;

  try {
    if(mspReportInfo->AccountIDOverride > 0) {
      spDataAccessor->AccountID = mspReportInfo->AccountIDOverride;

      spRowset = spDataAccessor->GetUsageInterval();

      //Attempt to get the first item
      if((bool)spRowset->RowsetEOF == false) {
        spRowset->MoveFirst();

        mlngOverrideDefaultIntervalID = spRowset->GetValue(L"intervalID");
        mdateOverrideDefaultStartDate = spRowset->GetValue(L"StartDate");
        mdateOverrideDefaultEndDate = spRowset->GetValue(L"EndDate");
      }
    }

  } catch(_com_error &e) {
    return returnHierarchyReportError(e);
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//                            XML CACHING FUNCTIONS                         //
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//  Function    : Initialize()                                              //
//  Description : Prepare the cache for action                              //
//  Inputs      : none                                                      //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheInitialize()
{
  MSXML2::IXMLDOMParseErrorPtr pParseError = NULL;
  long lngErrorCode = 0;
  HRESULT hr;

  try
  {
    //Init the cache XML
    if(FAILED(hr = mspCacheXML.CreateInstance("MSXML2.DOMDocument.4.0")))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "Unable to create an instance of a DOMDocument.", LOG_ERROR));

    mspCacheXML->async = false;
    mspCacheXML->validateOnParse = false;
    mspCacheXML->resolveExternals = false;

    //Init the temp XML used for loading level XML
    if(FAILED(hr = mspCacheTempXML.CreateInstance("MSXML2.DOMDocument.4.0")))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "Unable to create an instance of a DOMDocument.", LOG_ERROR));

    mspCacheTempXML->async = false;
    mspCacheTempXML->validateOnParse = false;
    mspCacheTempXML->resolveExternals = false;

    
    
    //Load the cache document
    if(!mspCacheXML->loadXML(L"<mt_charge_data />"))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "Unable to load document tag.", LOG_ERROR));

    //Check for parse error
    pParseError = mspCacheXML->parseError;

    lngErrorCode = pParseError->errorCode;

    if(lngErrorCode != 0) 
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "A parse error occurred while loading the cache document XML.", LOG_ERROR));

    //Clear the colleciton of report levels
    mcollReportLevels.Clear();
  }
  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }
  

  return(S_OK);
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : CacheLoadReportTopLevel(...)                              //
//  Description : Return the top level HierarchyReportLevel object for the  //
//              : selected report into the cache.                           //
//  Inputs      : spRenderInfo -- Render info object, with report           //
//              :                information.                               //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheLoadReportTopLevel(MTHIERARCHYREPORTSLib::IMPSRenderInfoPtr spRenderInfo)
{
	HRESULT hr;
  
  MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr spReportLevel("MTHierarchyReports.HierarchyReportLevel.1");
  
  MSXML2::IXMLDOMParseErrorPtr pParseError = NULL;

  _bstr_t strXML;

  long lngErrorCode = 0;
  

  try
  {

    if(FAILED(hr = spReportLevel->Init(spRenderInfo, mspReportInfo)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "Initialize report level failed.", LOG_ERROR));

    //Get the XML
    strXML = spReportLevel->GetReportLevelAsXML(false);

    if(strXML.length() < 1)
      return(S_OK);

    //XMLDoc load methods return booleans
    if(!mspCacheTempXML->loadXML(strXML))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "Unable to load XML for the report level.", LOG_ERROR));

    //Check for parse error
    pParseError = mspCacheTempXML->parseError;

    lngErrorCode = pParseError->errorCode;

    if(lngErrorCode != 0) 
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "A parse error occurred while loading the XML for the report level.", LOG_ERROR));

    //Add the XML to the cache
    if(FAILED(hr = CacheAddReportLevel(L"0", mspCacheTempXML->documentElement)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "Unable to add the report level XML to the cache.", LOG_ERROR));

    //Add the top level to the collection
    spReportLevel->ExternalID = _bstr_t(L"0");
    hr = mcollReportLevels.Add(spReportLevel.GetInterfacePtr());
    
    if(FAILED(hr))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheInitialize()", "Unable to add report level to report level cache.", LOG_ERROR));

  }
	catch(_com_error& err)
	{
		return(returnHierarchyReportError(err));
	}

	return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : CacheAddReportLevel(strLevelID, pReportNode)              //
//  Description : Take the report from the node given and add it to the     //
//              : cache.                                                    //
//  Inputs      : strLevelID -- The level ID.                               //
//  Outputs     : pReportNode -- The report node.                           //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheAddReportLevel(BSTR strLevelID, MSXML2::IXMLDOMNode *pReportNode)
{
  MSXML2::IXMLDOMNodePtr spLevelNode;
  MSXML2::IXMLDOMNodePtr spTempNode;
  MSXML2::IXMLDOMAttributePtr spAttribute;
  MSXML2::IXMLDOMNodeListPtr spNodeList;
  MSXML2::IXMLDOMNode *pNode;
  long lngCount = 0;
  long i = 0;
  HRESULT hr;

  wchar_t itoabuf[16];
  wchar_t idbuf[512];

  try
  {
    //Use a smart pointer
    spLevelNode = pReportNode;

    //Create an attribute for the node
    spAttribute = mspCacheXML->createAttribute(L"cacheID");
    
    spAttribute->value = strLevelID;

    //Append the attribute
    spLevelNode->attributes->setNamedItem(spAttribute);

    //Generate ID's for any children
    spNodeList = spLevelNode->selectNodes(L"children/level");

    lngCount = spNodeList->length;

    for(i = 0; i < lngCount; i++)
    {
      //Get the node
      hr = spNodeList->get_item(i, &pNode);

      if(FAILED(hr))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheAddReportLevel()", "Unable to Node from NodeList.", LOG_ERROR));

      //Smart Pointer Fun!
      spTempNode = pNode;
			pNode->Release();
			pNode = 0;
      spAttribute = mspCacheXML->createAttribute(L"cacheID");

      //Convert i to string
      _itow(i, itoabuf, 10);

      //Generate the level ID
      swprintf_s(idbuf, 512, L"%s_%s", strLevelID, itoabuf);

      spAttribute->value = idbuf;
      
      //Append the attribute
      spTempNode->attributes->setNamedItem(spAttribute);
    }

    //Now add the level to the cache

    //Handle top level separately
    if(strLevelID == L"0") {
      //Just add to the document element of the cache
      mspCacheXML->documentElement->appendChild(spLevelNode);
    } else {
      //Find the parent and add the element there
      BSTR strParentID;
      _bstr_t strQuery;
      MSXML2::IXMLDOMNodePtr spParentLevelNode;
      MSXML2::IXMLDOMNodePtr spChildrenNode;

      //Determine Parent ID
      if(FAILED(hr = CacheDetermineParent(strLevelID, &strParentID)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheAddReportLevel()", "Unable to determine the parent of this report level.", LOG_ERROR));

      
      //Get the parent ID node
      strQuery = _bstr_t(L"//level[@cacheID = '") + _bstr_t(strParentID) + _bstr_t(L"']");
      
      spParentLevelNode = mspCacheXML->selectSingleNode(strQuery);

      //Parent can't be found == BAD
      if(spParentLevelNode == NULL)
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheAddReportLevel()", "Unable to find parent node in cache.", LOG_ERROR));

      //Check if the parent already has this child
      strQuery = _bstr_t(L"children/level[@cacheID = '") + _bstr_t(strLevelID) + _bstr_t(L"']");

      spTempNode = spParentLevelNode->selectSingleNode(strQuery);

      //If a node with the same id exists, replace it
      if(spTempNode != NULL)
        spTempNode->parentNode->removeChild(spTempNode);

      //If the child doesn't exist, add it
      spChildrenNode = spParentLevelNode->selectSingleNode(L"children");

      //If children node doesn't exist, there is a problem since we shouldn't have
      //gotten here at all.
      if(spChildrenNode == NULL)
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheAddReportLevel()", "Found the parent of the level, but it has no children.", LOG_ERROR));
      else
        spChildrenNode->appendChild(spLevelNode);
    }
  }
  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : CacheLoadReportLevel(strLevelID)                          //
//  Description : Load the requested level into the cache.                  //
//  Inputs      : strLevelID -- ID of the level to load.                    //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheLoadReportLevel(BSTR strLevelID)
{
  MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr spParentReportLevel;
  MTHIERARCHYREPORTSLib::IHierarchyReportLevelPtr spChildReportLevel;
  MTHIERARCHYREPORTSLib::IHierarchyReportLevel *pReportLevel;
  MSXML2::IXMLDOMParseErrorPtr pParseError;
  MSXML2::IXMLDOMNodePtr spLevelNode;
  MSXML2::IXMLDOMAttributePtr spAttr;
  
  BSTR strParentIDTemp;
  
  _bstr_t strQuery;
  _bstr_t strParentID;
  _bstr_t strTempLevelID;
  
  long lngErrorCode = 0;
  long lngChildNumber;
  long lngCount = 0;
  long i = 0;

  bool bFound = false;

  HRESULT hr;



  try{
    //First, check if the level has already been cached.  If it has, do nothing
    if(FAILED(hr = mcollReportLevels.Count(&lngCount)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to get size of report level cache collection.", LOG_ERROR));
         
    for(i = 1; i <= lngCount; i++)
    {
      //Get the item from the collection
      if(FAILED(hr = mcollReportLevels.Item(i, &pReportLevel)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to get a report level from the report level cache collection.", LOG_ERROR));

      //Check if this is the item we want
      spParentReportLevel = pReportLevel;
			pReportLevel->Release();
			pReportLevel = 0;
      
      if(_bstr_t(spParentReportLevel->ExternalID) == _bstr_t(strLevelID))
        return(S_OK);
    }


    //The level was not found, so we need to get the XML
    //Determine the parent ID
    CacheDetermineParent(strLevelID, &strParentIDTemp);
    strParentID = strParentIDTemp;
    
    
    //Get the parent level from the cache

         
    for(i = 1; i <= lngCount; i++)
    {
      //Get the item from the collection
      if(FAILED(hr = mcollReportLevels.Item(i, &pReportLevel)))
        return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to get parent of level from report level cache collection.", LOG_ERROR));

      //Check if this is the item we want
      spParentReportLevel = pReportLevel;
			pReportLevel->Release();
			pReportLevel = 0;

      strTempLevelID = spParentReportLevel->ExternalID;


      if(strTempLevelID == strParentID) 
      {
        bFound = true;
        i = lngCount + 1;
      }
    }

    //If the parent wasn't found, raise an error 'cause that's no good
    if(!bFound)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to find parent level in cache.", LOG_ERROR));

    //Get the requested child
    CacheDetermineChildNumber(strLevelID, &lngChildNumber);

    //Get the requested child
    spChildReportLevel = spParentReportLevel->GetChildLevel(lngChildNumber);

    if(spChildReportLevel == NULL)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to find the specified child of the parent.", LOG_ERROR));

    
    //Load XML for the level
    if(!mspCacheTempXML->loadXML(spChildReportLevel->GetReportLevelAsXML(false)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to load XML for the report level.", LOG_ERROR));

    //Check for parse error
    pParseError = mspCacheTempXML->parseError;

    lngErrorCode = pParseError->errorCode;

    if(lngErrorCode != 0) 
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "A parse error occurred while loading the XML for the report level.", LOG_ERROR));

    //Add the XML to the cache
    if(FAILED(hr = CacheAddReportLevel(strLevelID, mspCacheTempXML->documentElement)))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to add report level XML to the cache.", LOG_ERROR));

    //Add the top level to the collection
    spChildReportLevel->ExternalID = strLevelID;
    hr = mcollReportLevels.Add(spChildReportLevel.GetInterfacePtr());
    
    if(FAILED(hr))
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheLoadReportLevel()", "Unable to add report level item to the report level cache.", LOG_ERROR));

    //GTG

  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : CacheShowReportLevel(strLevelID)                          //
//  Description : Set the visible attribute to true for the selected level. //
//  Inputs      : strLevelID -- ID of the level to show.                    //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheShowReportLevel(BSTR strLevelID)
{
  MSXML2::IXMLDOMNodePtr spLevelNode;
  MSXML2::IXMLDOMAttributePtr pAttr;
  _bstr_t strQuery;

  try 
  {
    //Make sure the level is loaded
    CacheLoadReportLevel(strLevelID);

    //Find the level node and set the visible attribute to be true
    strQuery = _bstr_t(L"//level[@cacheID = '") + _bstr_t(strLevelID) + _bstr_t(L"']");
    spLevelNode = mspCacheXML->selectSingleNode(strQuery);

    //If node wasn't found, return an error
    if(spLevelNode == NULL)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheShowReportLevel()", "Unable to find the level to be shown.", LOG_ERROR));

    //Create the attribute
    pAttr = mspCacheXML->createAttribute(L"visible");

    pAttr->value = L"true";

    //Set the attribute
    spLevelNode->attributes->setNamedItem(pAttr);
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : CacheHideReportLevel(strLevelID)                          //
//  Description : Mark a report level as being hidden.                      //
//  Inputs      : strLevelID -- ID of the level to hide.                    //
//  Outputs     : none                                                      //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheHideReportLevel(BSTR strLevelID)
{
  MSXML2::IXMLDOMNodePtr spLevelNode;
  MSXML2::IXMLDOMAttributePtr pAttr;
  
  _bstr_t strQuery;
  
  
  try
  {
    //Find the level node and set the visible attribute to be true
    strQuery = _bstr_t(L"//level[@cacheID = '") + _bstr_t(strLevelID) + _bstr_t(L"']");
    spLevelNode = mspCacheXML->selectSingleNode(strQuery);

    //If node wasn't found, return an error
    if(spLevelNode == NULL)
      return(returnHierarchyReportError(CLSID_ReportManager, IID_IReportHelper, "CReportHelper", "CacheHideReportLevel()", "Unable to find the level to be hidden.", LOG_ERROR));

    //Create the attribute
    pAttr = spLevelNode->attributes->getNamedItem("visible");

    if(pAttr != NULL)
      spLevelNode->attributes->removeNamedItem("visible");
  }

  catch(_com_error &err)
  {
    return(returnHierarchyReportError(err));
  }

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Cache Utility Functions                                                 //
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//  Function    : CacheDetermineParent(strLevelID)                          //
//  Description : Based on the passed in level ID, determine the parent of  //
//              : of the level.                                             //
//  Inputs      : strLevelID -- Level for which the parent should be        //
//              :               determined.                                 //
//  Outputs     : ID of the parent level.                                   //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheDetermineParent(BSTR strLevelID, BSTR *pstrParentID)
{
  wchar_t strSeps[] = L"_";
  wchar_t *strToken;
  
  _bstr_t strPrevToken;
  _bstr_t strParentID;
  _bstr_t strID;
  
  bool bStart = true;

  strID = strLevelID;

  //Loop and build the parent string, looking 1 token ahead to avoid
  //putting the child id in, which would be the last token
  strToken = wcstok((wchar_t *)strID, strSeps);

  while(strToken != NULL)
  {
    //Store the current token
    strPrevToken = strToken;

    //Get the next token
    strToken = wcstok(NULL, strSeps);

    //If the next token is not null, add to the id
    if(strToken != NULL) {
      if(bStart) {
        bStart = false;
        strParentID = _bstr_t(strPrevToken);
      } else {
        strParentID += (_bstr_t(L"_") + _bstr_t(strPrevToken));
      }
    }
  }

  *pstrParentID = strParentID.copy();

  return S_OK;
}
//////////////////////////////////////////////////////////////////////////////
//  Function    : CacheDetermineChildNumber(strLevelID)                     //
//  Description : Return a long with the child number.                      //
//  Inputs      : ID of the level.                                          //
//  Outputs     : Long with the child number.                               //
//////////////////////////////////////////////////////////////////////////////
HRESULT CReportHelper::CacheDetermineChildNumber(BSTR strLevelID, long *lngChildNumber)
{
  wchar_t strSeps[] = L"_";
  wchar_t *strToken;
  wchar_t *strEnd;

  _bstr_t strPrevToken;
  _bstr_t strID;

  strID = strLevelID;

  bool bPrev = false;

  //Get the last token, which is the child ID
  strToken = wcstok((wchar_t *)strID, strSeps);

  while(strToken != NULL)
  {
    //Store the current token
    strPrevToken = strToken;
    bPrev = true;

    //Get the next token
    strToken = wcstok(NULL, strSeps);
  }

  //Check if a value was set
  if(!bPrev)
    return(E_FAIL);

  //Convert the value
  *lngChildNumber = wcstol(strPrevToken, &strEnd, 10);

  return S_OK;
}


CReportHelper::QueryParameters::QueryParameters()
	:
	mTimeSlice(NULL),
	mProductSlice(NULL),
	mSessionSlice(NULL),
	mAccountSlice(NULL),
	mExtension(""),
	mLanguage(-1),
  mTopRows(0)
{
}

CReportHelper::QueryParameters::QueryParameters(MTHIERARCHYREPORTSLib::ITimeSlicePtr aTimeSlice,
										MTHIERARCHYREPORTSLib::ISingleProductSlicePtr aProductSlice,
										MTHIERARCHYREPORTSLib::IViewSlicePtr aSessionSlice,
										MTHIERARCHYREPORTSLib::IAccountSlicePtr aAccountSlice,
										_bstr_t aExtension,
										long aLanguage,
                    long aTopRows /* = 0 */)
	:
	mTimeSlice(aTimeSlice.GetInterfacePtr() == NULL ? NULL : aTimeSlice->Clone()),
	mProductSlice(aProductSlice.GetInterfacePtr() == NULL ? NULL : aProductSlice->Clone()),
	mSessionSlice(aSessionSlice.GetInterfacePtr() == NULL ? NULL : aSessionSlice->Clone()),
	mAccountSlice(aAccountSlice.GetInterfacePtr() == NULL ? NULL : aAccountSlice->Clone()),
	mExtension(aExtension),
	mLanguage(aLanguage),
  mTopRows(aTopRows)
{
}
		
CReportHelper::QueryParameters::QueryParameters(MTHIERARCHYREPORTSLib::ITimeSlicePtr aTimeSlice,
																								MTHIERARCHYREPORTSLib::IViewSlicePtr aSessionSlice,
																								MTHIERARCHYREPORTSLib::IAccountSlicePtr aAccountSlice,
																								long aLanguage)
	:
	mTimeSlice(aTimeSlice.GetInterfacePtr() == NULL ? NULL : aTimeSlice->Clone()),
	mProductSlice(NULL),
	mSessionSlice(aSessionSlice.GetInterfacePtr() == NULL ? NULL : aSessionSlice->Clone()),
	mAccountSlice(aAccountSlice.GetInterfacePtr() == NULL ? NULL : aAccountSlice->Clone()),
	mExtension(""),
	mLanguage(aLanguage),
  mTopRows(0)
{
}

bool CReportHelper::QueryParameters::Equals(const QueryParameters& aParameters)
{
	return mTopRows == aParameters.mTopRows &&
    mLanguage == aParameters.mLanguage &&
		mExtension == aParameters.mExtension &&
		((false == bool(mTimeSlice) && false == bool(aParameters.mTimeSlice)) || 
		 (bool(mTimeSlice) && bool(aParameters.mTimeSlice) && VARIANT_TRUE == mTimeSlice->Equals(aParameters.mTimeSlice))) &&
		((false == bool(mSessionSlice) && false == bool(aParameters.mSessionSlice)) || 
		 (bool(mSessionSlice) && bool(aParameters.mSessionSlice) && VARIANT_TRUE == mSessionSlice->Equals(aParameters.mSessionSlice))) &&
		((false == bool(mProductSlice) && false == bool(aParameters.mProductSlice)) || 
		 (bool(mProductSlice) && bool(aParameters.mProductSlice) && VARIANT_TRUE == mProductSlice->Equals(aParameters.mProductSlice))) &&
		((false == bool(mAccountSlice) && false == bool(aParameters.mAccountSlice)) || 
		 (bool(mAccountSlice) && bool(aParameters.mAccountSlice) && VARIANT_TRUE == mAccountSlice->Equals(aParameters.mAccountSlice)));
}

const CReportHelper::QueryParameters& CReportHelper::QueryParameters::operator=(const QueryParameters& aParameters)
{
	mTimeSlice = NULL == aParameters.mTimeSlice ? NULL : aParameters.mTimeSlice->Clone();
	mProductSlice = NULL == aParameters.mProductSlice ? NULL : aParameters.mProductSlice->Clone();
	mSessionSlice = NULL == aParameters.mSessionSlice ? NULL : aParameters.mSessionSlice->Clone();
	mAccountSlice = NULL == aParameters.mAccountSlice ? NULL : aParameters.mAccountSlice->Clone();
	mExtension = aParameters.mExtension;
	mLanguage = aParameters.mLanguage;	
	mTopRows = aParameters.mTopRows;
	return *this;
}

STDMETHODIMP CReportHelper::get_InlineAdjustments(VARIANT_BOOL* pVal)
{
  (*pVal) = mInlineAdjustments ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CReportHelper::put_InlineAdjustments(VARIANT_BOOL newVal)
{
  mInlineAdjustments =  (newVal == VARIANT_TRUE) ? true : false;

	return S_OK;
}


STDMETHODIMP CReportHelper::get_InteractiveReport(VARIANT_BOOL* pVal)
{
  (*pVal) = mInteractiveReport ? VARIANT_TRUE : VARIANT_FALSE;

	return S_OK;
}

STDMETHODIMP CReportHelper::put_InteractiveReport(VARIANT_BOOL newVal)
{
  mInteractiveReport =  (newVal == VARIANT_TRUE) ? true : false;

	return S_OK;
}


STDMETHODIMP CReportHelper::get_InlineVATTaxes(VARIANT_BOOL *pVal)
{
  *pVal = mbInlineVATTaxes;

	return S_OK;
}

STDMETHODIMP CReportHelper::put_InlineVATTaxes(VARIANT_BOOL newVal)
{
  mbInlineVATTaxes = newVal;
	return S_OK;
}

