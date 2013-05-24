// HierarchyReportLevel.h : Declaration of the CHierarchyReportLevel

#ifndef __HIERARCHYREPORTLEVEL_H_
#define __HIERARCHYREPORTLEVEL_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <MTObjectCollection.h>
#include <vector>
#include <autoinstance.h>
#include <DBUsageCycle.h>
#include <NTLogger.h>

#import <MTHierarchyReports.tlb> rename("EOF", "HR_EOF")
#import "msxml4.dll"        //msxml 4.0 parser
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 
#import <MetraTech.DataAccess.MaterializedViews.tlb>

/////////////////////////////////////////////////////////////////////////////
// CHierarchyReportLevel
class ATL_NO_VTABLE CHierarchyReportLevel : 
	public CComObjectRootEx<CComSingleThreadModel>,
  public ISupportErrorInfo,
	public CComCoClass<CHierarchyReportLevel, &CLSID_HierarchyReportLevel>,
	public IDispatchImpl<IHierarchyReportLevel, &IID_IHierarchyReportLevel, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CHierarchyReportLevel();
	~CHierarchyReportLevel();
	

DECLARE_REGISTRY_RESOURCEID(IDR_HIERARCHYREPORTLEVEL)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CHierarchyReportLevel)
	COM_INTERFACE_ENTRY(IHierarchyReportLevel)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IHierarchyReportLevel
public:
	STDMETHOD(get_ExternalID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ExternalID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_NumChildren)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_NumProperties)(/*[out, retval]*/ long *pVal);
	STDMETHOD(GetReportLevelAsXML)(/*[in]*/ VARIANT_BOOL bRecurse, /*[out, retval]*/ BSTR *pVal);
	STDMETHOD(GetChildLevel)(/*[in]*/ int intIndex, /*[out, retval]*/ IHierarchyReportLevel **pChildLevel);
	STDMETHOD(GetPropertyValue)(/*[in]*/ VARIANT strPropName, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(GetPropertyName)(/*[in]*/ int intIndex, /*[out, retval]*/ VARIANT *pval);
	STDMETHOD(InitByFolderReport)(/*[in]*/ int intAccountId, /*[in]*/ int intPayerId, /*[in]*/ IDateRangeSlice *apAccountEffDate, /*[in]*/ ITimeSlice *apTimeSlice, /*[in]*/ int intLanguageCode, /*[in]*/ VARIANT_BOOL bPayerReport, /*[in]*/ VARIANT_BOOL bSecondPass);
	STDMETHOD(InitByProductReport)(/*[in]*/ int intPayerId, /*[in]*/ ITimeSlice *apTimeSlice, /*[in]*/ int intLanguageCode, /*[in]*/ VARIANT_BOOL bPayerReport, /*[in]*/ VARIANT_BOOL bSecondPass);
	STDMETHOD(Init)(/*[in]*/ IMPSRenderInfo* pRenderInfo, /*[in]*/ IMPSReportInfo* pReportInfo);
  /*STDMETHOD(InitByFolderServiceEndpointReport)(int intAccountId,
																							 int intServiceEndpointId,
																							 int intPayerId, 
																							 ITimeSlice * apTimeSlice, 
																							 int intLanguageCode,
																							 VARIANT_BOOL bPayerReport,
																							 VARIANT_BOOL bSecondPass);*/
private:

	HRESULT GetCorporateAccount(long aAccountId, _variant_t aDate, long* aCorporateId);
	HRESULT GetLeastCommonAncestorOfPayees(long aAccountId, _variant_t aStartDate, _variant_t aEndDate, MTHIERARCHYREPORTSLib::ITimeSlicePtr apTimeSlice, long* aCorporateId);
	HRESULT GetAccountSummaryPanel(long intAccountId, 
																 long intPayerId,
																 MTHIERARCHYREPORTSLib::IDateRangeSlicePtr apAccountEffDate,
																 MSXML2::IXMLDOMDocument2Ptr apXMLDoc,
																 MSXML2::IXMLDOMElementPtr apLevelElement,
																 MSXML2::IXMLDOMElementPtr apChildrenElement);

	/*HRESULT GetServiceEndpointSummaryPanel(long intAccountId, 
																				 long intPayerId,
																				 MSXML2::IXMLDOMDocument2Ptr apXMLDoc,
																				 MSXML2::IXMLDOMElementPtr apChildrenElement);*/

	/*HRESULT GetProductSummaryForServiceEndpointPanel(long intAccountId,
																									 long intPayerId,
																									 MSXML2::IXMLDOMDocument2Ptr apXMLDoc,
																									 MSXML2::IXMLDOMElementPtr apChargesElement);*/

	HRESULT ConvertProductSummaryRowsetToXml(ROWSETLib::IMTSQLRowsetPtr rowset,
																					 MSXML2::IXMLDOMDocument2Ptr apXMLDoc,
																					 MSXML2::IXMLDOMElementPtr apChargesElement);
	NTLogger mLogger;

	_bstr_t mstrReportXML;
	MTObjectCollection<IHierarchyReportLevel> mLevels;
	MTObjectCollection<IDateRangeSlice> mLevelEffDates;
	bool mHydrated;
	std::vector<long> mChildIds;
	//std::vector<long> mServiceEndpointIds;
	VARIANT_BOOL mPayerReport;
	// Do we select the first or second pass of aggregate usage?
	VARIANT_BOOL mSecondPass;
	// In case this is a payer report, who is the payer.
	int mPayerId;
  
  //External is used by consumers of the report level objects
  _bstr_t mstrExternalID;

	// I am consciously not storing an MPSRenderInfo, since I don't
	// want to require a security context to use this object.  This
	// may not be such a great idea in the long run...
	MTHIERARCHYREPORTSLib::ITimeSlicePtr mTimeSlice;
	int mLanguageCode;

  // Is materialized view framework enabled?
  bool mMVMEnabled;

private:
  void CreateAdjustmentTags
  ( 
    ROWSETLib::IMTSQLRowsetPtr& pRowset, 
    MSXML2::IXMLDOMDocument2Ptr& pXMLDoc, 
    MSXML2::IXMLDOMElementPtr& pLevelElement
   );
};

#endif //__HIERARCHYREPORTLEVEL_H_
