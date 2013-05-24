	
// COMCredentials.h : Declaration of the CCOMCredentials

#ifndef __COMCREDENTIALS_H_
#define __COMCREDENTIALS_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <Credentials.h>
#include <ComKioskLogging.h>
#include <autologger.h>

#include <string> 
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CCOMCredentials
class ATL_NO_VTABLE CCOMCredentials : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMCredentials, &CLSID_COMCredentials>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMCredentials, &IID_ICOMCredentials, &LIBID_COMKIOSKLib>
{
public:

	// Default constructor
	CCOMCredentials();

	// Destructor
	virtual ~CCOMCredentials();

DECLARE_REGISTRY_RESOURCEID(IDR_COMCREDENTIALS)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMCredentials)
	COM_INTERFACE_ENTRY(ICOMCredentials)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMCredentials
public:
	STDMETHOD(get_Ticket)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Ticket)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Pwd)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Pwd)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name_Space)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name_Space)(/*[in]*/ BSTR newVal);
	// like user name
	STDMETHOD(get_LoginID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LoginID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Certificate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Certificate)(/*[in]*/ BSTR newVal);
	
	STDMETHOD(get_LoggedInAs)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LoggedInAs)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ApplicationName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ApplicationName)(/*[in]*/ BSTR newVal);
	
private:
	// pointer to credentials object
	CCredentials mCredentials;

	_bstr_t mLoggedInAs;
	_bstr_t mApplicationName;

	// member to check if the object initialized itself
	// properly
	BOOL mIsInitialized;
	MTAutoInstance<MTAutoLoggerImpl<szComKioskCred,szComKioskLoggingDir> >	mLogger;
};

#endif //__COMCREDENTIALS_H_
