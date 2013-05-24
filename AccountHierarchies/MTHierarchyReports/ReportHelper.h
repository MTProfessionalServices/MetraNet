// ReportHelper.h : Declaration of the CReportHelper

#ifndef __REPORTHELPER_H_
#define __REPORTHELPER_H_


#include "resource.h"       // main symbols

#include <MTObjectCollection.h>

//Collection
#import "GenericCollection.tlb"

//MSXML4
#import <msxml4.dll>

//HierarchyReports
#import <MTHierarchyReports.tlb> rename("EOF", "HR_EOF")
// Rowset
#import <rowsetinterfaceslib.tlb> rename("EOF", "RowsetEOF")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )



//MTYAAC
#import <MTYAAC.tlb> rename ("EOF", "RowsetEOF")
/////////////////////////////////////////////////////////////////////////////
// CReportHelper
class ATL_NO_VTABLE CReportHelper : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CReportHelper, &CLSID_ReportHelper>,
	public ISupportErrorInfo,
	public IDispatchImpl<IReportHelper, &IID_IReportHelper, &LIBID_MTHIERARCHYREPORTSLib>
{
    /*
    	long mlngLanguageID;
  long mlngReportCount;
  long mlngCurrentReport;
  long mlngAccountID;
  
  long mlngOverrideDefaultIntervalID;
  DATE mdateOverrideDefaultStartDate;
  DATE mdateOverrideDefaultEndDate;
  
  long mlngDefaultIntervalID;
  DATE mdateDefaultStartDate;
  DATE mdateDefaultEndDate;
  
  short msCurrentViewType;
  short msReportType;
  
  VARIANT_BOOL mbEstimate;
  VARIANT_BOOL mbShowSecondPass;

  VARIANT_BOOL mbInitialized;*/
public:
  CReportHelper() :
      mlngLanguageID(-1),
      mlngReportCount(-1),
      mlngCurrentReport(-1),
      mlngAccountID(-1),
      mlngOverrideDefaultIntervalID(-1),
      mdateOverrideDefaultStartDate(0),
      mdateOverrideDefaultEndDate(0),
      mlngDefaultIntervalID(-1),
      mdateDefaultStartDate(0),
      mdateDefaultEndDate(0),
      msCurrentViewType(0),
      msReportType(0),
      mbEstimate(VARIANT_FALSE),
      mbShowSecondPass(VARIANT_FALSE),
      mbInitialized(VARIANT_FALSE)
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_REPORTHELPER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CReportHelper)
	COM_INTERFACE_ENTRY(IReportHelper)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
    mInlineAdjustments = false;
    mInteractiveReport = false;
		
    return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IReportHelper
public:
	STDMETHOD(get_DefaultEndDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_DefaultStartDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_DefaultIntervalID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_ShowSecondPass)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_IsEstimate)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(GetReportLevelAsXML)(/*[in]*/ BSTR strLevel, /*[out,retval]*/ BSTR *pstrXML);
  STDMETHOD(GetReportAsXML)(/*[out,retval]*/ BSTR *pstrXML);
	STDMETHOD(ClearUsageDetailCache)();
  STDMETHOD(GetUsageDetail)(/*[in]*/ ISingleProductSlice *pProductSlice, /*[in]*/ IViewSlice *pViewSlice, /*[in]*/ IAccountSlice *pAccountSlice, /*[in]*/ ITimeSlice *pTimeSlice, /*[in]*/ BSTR aExtension, /*[out, retval]*/ IMTSQLRowset **pRowset);
  STDMETHOD(GetUsageDetail2)(/*[in]*/ IQueryParams *pQueryParams, /*[out, retval]*/ IMTSQLRowset **pRowset);
	STDMETHOD(GetTransactionDetail)(/*[in]*/ ISingleProductSlice *pProductSlice, /*[in]*/ IViewSlice *pViewSlice, /*[in]*/ IAccountSlice *pAccountSlice, /*[in]*/ ITimeSlice *pTimeSlice, /*[in]*/ BSTR aExtension, /*[out, retval]*/ IMTSQLRowset **pRowset);
	STDMETHOD(GetTransactionDetail2)(/*[in]*/ ISingleProductSlice *pProductSlice, /*[in]*/ IViewSlice *pViewSlice, /*[in]*/ IAccountSlice *pAccountSlice, /*[in]*/ ITimeSlice *pTimeSlice, /*[in]*/ BSTR aExtension, /*[out, retval]*/ IMTSQLRowset **pRowset);
  STDMETHOD(GetAdjustmentDetail)(/*[in]*/ ISingleProductSlice *pProductSlice, /*[in]*/ IViewSlice *pViewSlice, /*[in]*/ IAccountSlice *pAccountSlice, /*[in]*/ ITimeSlice *pTimeSlice, /*[in]*/ BSTR aExtension, /*[out, retval]*/ IMTSQLRowset **pRowset);
  STDMETHOD(GetBaseAdjustmentDetail)(/*[in]*/ IViewSlice *pViewSlice, /*[in]*/ IAccountSlice *pAccountSlice, /*[in]*/ ITimeSlice *pTimeSlice, /*[in]*/ BSTR aExtension, /*[in]*/ VARIANT_BOOL aIsPostbill, /*[out, retval]*/ IMTSQLRowset **pRowset);
  STDMETHOD(GetUsageSummary)(/*[in]*/ IViewSlice *pViewSlice, /*[in]*/ IAccountSlice *pAccountSlice, /*[in]*/ ITimeSlice *pTimeSlice, /*[out, retval]*/ IMTSQLRowset **pRowset);
 	STDMETHOD(GetUsageSummary2)(/*[in]*/ IViewSlice *pViewSlice, /*[in]*/ IAccountSlice *pAccountSlice, /*[in]*/ ITimeSlice *pTimeSlice, /*[in]*/ VARIANT_BOOL bUseDatamart, /*[out, retval]*/ IMTSQLRowset **pRowset);
	STDMETHOD(GetCombinedTimeSlice)(/*[in]*/ ITimeSlice *pTimeSliceIn, /*[out, retval]*/ ITimeSlice **pTimeSliceOut);
	STDMETHOD(GetReportWithIndex)(/*[in]*/long lngReportIndex, /*[out, retval]*/ IMPSReportInfo **pReport);
	STDMETHOD(get_ReportInfo)(/*[out, retval]*/ IMPSReportInfo * *pVal);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_TimeSlice)(/*[out, retval]*/ ITimeSlice **pVal);
	STDMETHOD(HideReportLevel)(BSTR strLevelID);
	STDMETHOD(ShowReportLevel)(/*[in]*/ BSTR strLevelID);
	STDMETHOD(get_ViewType)(/*[out, retval]*/ short *pVal);
	STDMETHOD(get_ReportIndex)(/*[out, retval]*/ long *pVal);
  STDMETHOD(put_ReportIndex)(/*[in]*/ long lngIndex);
	STDMETHOD(GetCacheXML)(/*[out,retval]*/ BSTR *pstrXML);
	STDMETHOD(InitializeReport)(/*[in]*/ ITimeSlice *pTimeSlice,/*[in]*/ short sViewType, /*in*/ VARIANT_BOOL bShowSecondPass, /*in*/ VARIANT_BOOL bEstimate);
	STDMETHOD(GetDateRangeTimeSliceFromInterval)(/*[in]*/ long lngIntervalID, /*[out, retval]*/ ITimeSlice **pTimeSlice);
  STDMETHOD(GetDateRangeTimeSlice)(/*[in]*/ DATE dateStart, /*[in]*/ DATE dateEnd, /*[out, retval]*/ ITimeSlice **pTimeSlice);
	STDMETHOD(GetIntervalTimeSlice)(/*[in]*/ long lngIntervalID,/*out, retval*/ ITimeSlice **pTimeSlice);
	STDMETHOD(GetAvailableReports)(/*[in]*/ short sReportType, /*[out, retval]*/ IMTCollection **collAvailableReports);
  STDMETHOD(Initialize)(/*[in]*/IMTYAAC *pYAAC, /*[in]*/long lngLanguageID, /*[in]*/ IMTCollection *pAvailableReports);
	STDMETHOD(get_HasAggregateCharges)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(GetPostBillAdjustmentDetail)(/*[in]*/ long intervalid, /*[in]*/ long accountid, /*[out, retval]*/ IMTSQLRowset **pRowset);
  STDMETHOD(GetPreBillAdjustmentDetail)(/*[in]*/ long intervalid, /*[in]*/ long accountid, /*[out, retval]*/ IMTSQLRowset **pRowset);
  STDMETHOD(CreateDetailSlice)(/*[in]*/ IMTSQLRowset * pRowset, /*[out, retval]*/ IViewSlice* *pVal);

  STDMETHOD(put_InlineAdjustments)(/*[out, retval]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_InlineAdjustments)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(put_InteractiveReport)(/*[out, retval]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_InteractiveReport)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(get_InlineVATTaxes)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_InlineVATTaxes)(/*[in]*/ VARIANT_BOOL newVal);

private:
  HRESULT CReportHelper::CopyReportInfo(MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spSrc, MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spDest);
  
  //Default Interval Functions
  HRESULT GetUserDefaultIntervalData();
  HRESULT GetOverrideDefaultIntervalData();

  //Cache Functions
  HRESULT CacheInitialize();
  HRESULT CacheLoadReportTopLevel(MTHIERARCHYREPORTSLib::IMPSRenderInfoPtr spRenderInfo);
  HRESULT CacheLoadReportLevel(BSTR strLevelID);
  HRESULT CacheAddReportLevel(BSTR strReportID, MSXML2::IXMLDOMNode *pReportNode);
  HRESULT CacheShowReportLevel(BSTR strReportID);
  HRESULT CacheHideReportLevel(BSTR strReportID);

  //Cache Utility Functions
  HRESULT CacheDetermineParent(BSTR strLevelID, BSTR *pstrParentID);
  HRESULT CacheDetermineChildNumber(BSTR strLevelID, long *lngChildNumber);

private:
	long mlngLanguageID;
  long mlngReportCount;
  long mlngCurrentReport;
  long mlngAccountID;
  
  long mlngOverrideDefaultIntervalID;
  DATE mdateOverrideDefaultStartDate;
  DATE mdateOverrideDefaultEndDate;
  
  long mlngDefaultIntervalID;
  DATE mdateDefaultStartDate;
  DATE mdateDefaultEndDate;
  
  short msCurrentViewType;
  short msReportType;
  
  VARIANT_BOOL mbEstimate;
  VARIANT_BOOL mbShowSecondPass;

  VARIANT_BOOL mbInitialized;

  MTYAACLib::IMTYAACPtr mYAAC;
  MTObjectCollection<MTHIERARCHYREPORTSLib::IMPSReportInfo> mcollAvailableReports;
  MTObjectCollection<MTHIERARCHYREPORTSLib::IHierarchyReportLevel> mcollReportLevels;
  MTHIERARCHYREPORTSLib::IMPSReportInfoPtr mspReportInfo;
  MSXML2::IXMLDOMDocumentPtr mspCacheXML;
  MSXML2::IXMLDOMDocumentPtr mspCacheTempXML;
  MTHIERARCHYREPORTSLib::ITimeSlicePtr mspTimeSlice;

  bool mInlineAdjustments;
  bool mInteractiveReport;
  VARIANT_BOOL mbInlineVATTaxes;

	// Cache of rowset
	// We implement a single element cache of rowsets for 
	// each of the detail and summary rowsets.
	class QueryParameters
	{
	private:
		MTHIERARCHYREPORTSLib::IViewSlicePtr mTimeSlice;
		MTHIERARCHYREPORTSLib::IViewSlicePtr mProductSlice;
		MTHIERARCHYREPORTSLib::IViewSlicePtr mSessionSlice;
		MTHIERARCHYREPORTSLib::IViewSlicePtr mAccountSlice;
		_bstr_t mExtension;
		long mLanguage;
    long mTopRows;

		// Don't allow copy
		QueryParameters(const QueryParameters& );

	public:

		// Create an empty set of parameters
		QueryParameters();

		// Create a parameter set for a detail query
		QueryParameters(MTHIERARCHYREPORTSLib::ITimeSlicePtr aTimeSlice,
										MTHIERARCHYREPORTSLib::ISingleProductSlicePtr aProductSlice,
										MTHIERARCHYREPORTSLib::IViewSlicePtr aSessionSlice,
										MTHIERARCHYREPORTSLib::IAccountSlicePtr aAccountSlice,
										_bstr_t aExtension,
										long aLanguage,
                    long aTopRows = 0);
		
		// Create a parameter set for a summary query
		QueryParameters(MTHIERARCHYREPORTSLib::ITimeSlicePtr aTimeSlice,
										MTHIERARCHYREPORTSLib::IViewSlicePtr aSessionSlice,
										MTHIERARCHYREPORTSLib::IAccountSlicePtr aAccountSlice,
										long aLanguage);

		bool Equals(const QueryParameters& aParameters);

		const QueryParameters& operator= (const QueryParameters& aParameters);
	};

	QueryParameters mCurrentSummaryParameters;
	ROWSETLib::IMTSQLRowsetPtr mCurrentSummaryRowset;
	QueryParameters mCurrentDetailParameters;
	ROWSETLib::IMTSQLRowsetPtr mCurrentDetailRowset;
  QueryParameters mCurrentAdjustmentDetailParameters;
	ROWSETLib::IMTSQLRowsetPtr mCurrentAdjustmentDetailRowset;
  QueryParameters mCurrentPrebillAdjustmentDetailParameters;
	ROWSETLib::IMTSQLRowsetPtr mCurrentPrebillAdjustmentDetailRowset;
  QueryParameters mCurrentPostbillAdjustmentDetailParameters;
	ROWSETLib::IMTSQLRowsetPtr mCurrentPostbillAdjustmentDetailRowset;
};

	

#endif //__REPORTHELPER_H_
