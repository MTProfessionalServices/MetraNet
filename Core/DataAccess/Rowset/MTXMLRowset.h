// MTXMLRowset.h : Declaration of the MTXMLRowset

#ifndef __MTXMLROWSET_H_
#define __MTXMLROWSET_H_

#include "resource.h"       // main symbols
#include <RowSetExecute.h>


/////////////////////////////////////////////////////////////////////////////
// MTXMLRowset
class ATL_NO_VTABLE MTXMLRowset : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public ISupportErrorInfo,
	public MTRowSetExecute<IMTXMLRowset,MTXMLRowset,&CLSID_MTXMLRowset,&IID_IMTXMLRowset, &LIBID_ROWSETLib>
{
public:
	MTXMLRowset() : mHostname(""), mUserName(""), mPassword(""), 
		mConnectionType(HTTP), mPortNum(-1), mOverRideString(""), mTimeout(-1)
	{
	}

	virtual ~MTXMLRowset();

DECLARE_REGISTRY_RESOURCEID(IDR_MTXMLROWSET)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(MTXMLRowset)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY(IMTRowSetExecute)
	COM_INTERFACE_ENTRY(IMTXMLRowset)
	COM_INTERFACE_ENTRY2(IDispatch,IMTXMLRowset)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTXMLRowset
public:
	STDMETHOD(HydrateFromString)(BSTR xmlStr);
	STDMETHOD(HydrateFromFile)(BSTR filename);
	STDMETHOD(HydrateFromXML)(IDispatch* pDisp);

	STDMETHOD(get_HostName)(BSTR* pHostName);
	STDMETHOD(put_HostName)(BSTR HostName);
	STDMETHOD(get_UserName)(BSTR* pUserName);
	STDMETHOD(put_UserName)(BSTR UserName);
	STDMETHOD(get_Password)(BSTR* pPassword);
	STDMETHOD(put_Password)(BSTR Password);
  STDMETHOD(put_Timeout)(long Timeout);
  STDMETHOD(get_Timeout)(long* pTimeout);

	STDMETHOD(get_ConnectionType)(XMLRowSet_ConnectionEnum* aType);
	STDMETHOD(put_ConnectionType)(XMLRowSet_ConnectionEnum aType);

	STDMETHOD(get_PortNumber)(long* pPort);
	STDMETHOD(put_PortNumber)(long aPort);
	STDMETHOD(get_OverRideConnectionString)(BSTR* pOverRide);
	STDMETHOD(put_OverRideConnectionString)(BSTR OverRide);
	
	STDMETHOD(Execute)();
protected: // methods
  void HydrateFromXMLInternal(MSXML2::IXMLDOMDocumentPtr doc);


protected: // data
	_bstr_t mHostname,mUserName,mPassword;
	XMLRowSet_ConnectionEnum mConnectionType;
	_bstr_t mOverRideString;
	long mPortNum;
  long mTimeout;
private:
	MTAutoInstance<MTAutoLoggerImpl<szMTXmlRowSetTag,szDbObjectsDir> >	mLogger; 

};

#endif //__MTXMLROWSET_H_
