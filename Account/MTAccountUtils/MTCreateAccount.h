// MTCreateAccount.h : Declaration of the CMTCreateAccount

#ifndef __MTCREATEACCOUNT_H_
#define __MTCREATEACCOUNT_H_

#include "resource.h"       // main symbols

#import <COMKiosk.tlb>
#include <autologger.h>

namespace {
	char CreateAccountTag[] = "MTCreateAccount";
}

/////////////////////////////////////////////////////////////////////////////
// CMTCreateAccount
class ATL_NO_VTABLE CMTCreateAccount : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCreateAccount, &CLSID_MTCreateAccount>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCreateAccount, &IID_IMTCreateAccount, &LIBID_MTACCOUNTUTILSLib>
{
public:
	CMTCreateAccount() : mbInit(false)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCREATEACCOUNT)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCreateAccount)
	COM_INTERFACE_ENTRY(IMTCreateAccount)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCreateAccount
public:
	STDMETHOD(AddUser)(LPDISPATCH pCredentials,
										BSTR aLanguage, 
										long TimezoneID, 
										long AccountStatus, 
										LPDISPATCH pRowset, 
										long* AccountID);
	STDMETHOD(Initialize)();

protected: // methods
	HRESULT CheckInitStatus();
protected: // data

	bool mbInit;
	MTAutoInstance<MTAutoLoggerImpl<CreateAccountTag> >	mLogger;
	COMKIOSKLib::ICOMAccountPtr mpAccount;
	COMKIOSKLib::ICOMAccountMapperPtr mpAccountMapper;
	COMKIOSKLib::ICOMKioskAuthPtr mpKioskAuth;
	COMKIOSKLib::ICOMUserConfigPtr mpUserConfig;


	
};

#endif //__MTCREATEACCOUNT_H_
