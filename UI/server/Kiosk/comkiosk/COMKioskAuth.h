	
// COMKioskAuth.h : Declaration of the CCOMKioskAuth

#ifndef __COMKIOSKAUTH_H_
#define __COMKIOSKAUTH_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <KioskAuth.h>
#include <ComKioskLogging.h>
#include <autologger.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMKioskAuth
class ATL_NO_VTABLE CCOMKioskAuth : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMKioskAuth, &CLSID_COMKioskAuth>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMKioskAuth, &IID_ICOMKioskAuth, &LIBID_COMKIOSKLib>
{
public:

	// Default constructor
	CCOMKioskAuth();

	// Destructor
	virtual ~CCOMKioskAuth();

DECLARE_REGISTRY_RESOURCEID(IDR_COMKIOSKAUTH)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMKioskAuth)
	COM_INTERFACE_ENTRY(ICOMKioskAuth)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMKioskAuth
public:
	STDMETHOD(Initialize)();
	STDMETHOD(AddUser)(/*[in]*/ BSTR login, BSTR pwd, BSTR name_space, LPDISPATCH pRowset);
	STDMETHOD(IsAuthentic)(LPDISPATCH pCredentials, VARIANT_BOOL* authValue);
  STDMETHOD(HashString)(BSTR StringToBeHashed, BSTR* HashedString);


private:
	// pointer to site config object
	CKioskAuth mKioskAuth;

	// Boolean value to indicate if the object has valid user credentials
	BOOL mbAuthValue;

	// member to check at any time if the object initialised itself
	// properly
	BOOL mIsInitialized;

	MTAutoInstance<MTAutoLoggerImpl<szComKioskAuth,szComKioskLoggingDir> >	mLogger;

private:

};

#endif //__COMKIOSKAUTH_H_
