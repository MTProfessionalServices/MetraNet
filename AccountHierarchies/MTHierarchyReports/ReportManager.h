	
// ReportManager.h : Declaration of the CReportManager

#ifndef __REPORTMANAGER_H_
#define __REPORTMANAGER_H_

#include "resource.h"       // main symbols
#include <MTObjectCollection.h>

#import "GenericCollection.tlb"

#import <MTHierarchyReports.tlb> rename("EOF", "HR_EOF")

#import <msxml4.dll>

/////////////////////////////////////////////////////////////////////////////
// CReportManager
class ATL_NO_VTABLE CReportManager : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CReportManager, &CLSID_ReportManager>,
	public ISupportErrorInfo,
	public IDispatchImpl<IReportManager, &IID_IReportManager, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CReportManager()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_REPORTMANAGER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CReportManager)
	COM_INTERFACE_ENTRY(IReportManager)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
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


// IReportManager
public:
	STDMETHOD(GetReportHelper)(/*[in]*/ IMTYAAC *pYAAC, /*[in]*/ long lngLanguageID, /*[out,retval]*/ IReportHelper **pReportHelper);
	STDMETHOD(Initialize)(/*[in]*/ BSTR strReportConfigPath);
	STDMETHOD(GetAvailableReportList)(/*[in]*/ IMTYAAC *pYAAC, /*[out, retval]*/  IMTCollection **collReports);
	STDMETHOD(GetReportAsXML)(/*[in]*/ long lngReportIndex, /*[in]*/ IMPSRenderInfo *pRenderInfo, /*[out, retval]*/ BSTR *strXML);
  STDMETHOD(GetReportTopLevel)(/*[in]*/ long lngReportIndex, /*[in]*/ IMPSRenderInfo *pRenderInfo, /*[out, retval]*/ IHierarchyReportLevel **pReportTopLevel);
private:
	bool CheckBillable(IMTYAAC *pYAAC);
  bool CheckFolderOwner(IMTYAAC *pYAAC);
  bool CheckFolderAccount(IMTYAAC *pYAAC);
  bool CheckIndependentAccount(IMTYAAC *pYAAC);
  bool CheckReportAvailability(IMTYAAC *pYAAC, MTHIERARCHYREPORTSLib::IMPSReportInfoPtr spReportInfo);
  HRESULT AddReportToCollection(MSXML2::IXMLDOMNode *pReportNode, MPS_REPORT_TYPE eReportType, long lngIndex);
  HRESULT CopyReportInfo(MTHIERARCHYREPORTSLib::IMPSReportInfoPtr pSrc, MTHIERARCHYREPORTSLib::IMPSReportInfoPtr pDest);
  
  MTObjectCollection<IMPSReportInfo> mcollReportInfo;
};

#endif //__REPORTMANAGER_H_
