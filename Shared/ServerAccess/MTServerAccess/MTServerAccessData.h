	
// MTServerAccessData.h : Declaration of the CMTServerAccessData

#ifndef __MTSERVERACCESSDATA_H_
#define __MTSERVERACCESSDATA_H_

#include <comdef.h>
#include "resource.h"       // main symbols
#include <stdutils.h>

/////////////////////////////////////////////////////////////////////////////
// CMTServerAccessData
class ATL_NO_VTABLE CMTServerAccessData : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTServerAccessData, &CLSID_MTServerAccessData>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTServerAccessData, &IID_IMTServerAccessData, &LIBID_MTSERVERACCESSLib>
{
public:
	CMTServerAccessData()
	{
	}
	

DECLARE_REGISTRY_RESOURCEID(IDR_MTSERVERACCESSDATA)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTServerAccessData)
	COM_INTERFACE_ENTRY(IMTServerAccessData)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTServerAccessData
public:
	STDMETHOD(get_ServerName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ServerName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ServerType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ServerType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_NumRetries)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_NumRetries)(/*[in]*/ long newVal);
	STDMETHOD(get_Timeout)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Timeout)(/*[in]*/ long newVal);
	STDMETHOD(get_Priority)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Priority)(/*[in]*/ long newVal);
	STDMETHOD(get_Secure)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Secure)(/*[in]*/ long newVal);
	STDMETHOD(get_PortNumber)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PortNumber)(/*[in]*/ long newVal);
	STDMETHOD(get_UserName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_UserName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Password)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Password)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DTCenabled)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_DTCenabled)(/*[in]*/ long newVal);
	STDMETHOD(get_DatabaseName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DatabaseName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DatabaseType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DatabaseType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DataSource)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DataSource)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DatabaseDriver)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DatabaseDriver)(/*[in]*/ BSTR newVal);

private:
	_bstr_t mServerType;
	_bstr_t mServerName;
	long mNumRetries;
	long mTimeout;
	long mPriority;
	long mSecure;
	long mPortNumber;
	_bstr_t mUserName;
	_bstr_t mPassword;
	long mDTCenabled;
	_bstr_t mDatabaseName;
	_bstr_t mDatabaseType;
	_bstr_t mDataSource;
	_bstr_t mDatabaseDriver;
};

#endif //__MTSERVERACCESSDATA_H_
