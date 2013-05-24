	
// TimerManager.h : Declaration of the CTimerManager

#ifndef __TIMERMANAGER_H_
#define __TIMERMANAGER_H_

#include "resource.h"       // main symbols

//MSXML4
#import <msxml4.dll>
using namespace MSXML2;

//RCD
#import <RCD.tlb>


/////////////////////////////////////////////////////////////////////////////
// CTimerManager
class ATL_NO_VTABLE CTimerManager : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CTimerManager, &CLSID_TimerManager>,
	public ISupportErrorInfo,
	public IDispatchImpl<ITimerManager, &IID_ITimerManager, &LIBID_MTUIPERFMONLib>
{

public:
  CTimerManager()
  {
    m_pUnkMarshaler = NULL;
    mpXMLDoc.CreateInstance("MSXML2.DOMDocument.4.0");
    mpXMLDoc->async = false;
  }

DECLARE_REGISTRY_RESOURCEID(IDR_TIMERMANAGER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CTimerManager)
	COM_INTERFACE_ENTRY(ITimerManager)
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

// ITimerManager
public:
	STDMETHOD(WriteOutputXMLFile)();
  STDMETHOD(StoreTimerXML)(/*[in]*/ BSTR strXML);
  STDMETHOD(InitializeTimerXML)(/*[in]*/ BSTR strSessionID, /*[out, retval]*/ BSTR *strXML);
	STDMETHOD(Initialize)(/*[in]*/ BSTR strAppID, /*[in]*/ BSTR strDate);

private:
  MSXML2::IXMLDOMDocumentPtr mpXMLDoc;
  _bstr_t mstrReportPath;
};

#endif //__TIMERMANAGER_H_
