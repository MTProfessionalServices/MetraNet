	
// MTLDAPAdapter.h : Declaration of the CMTLDAPAdapter

#ifndef __MTLDAPADAPTER_H_
#define __MTLDAPADAPTER_H_

#include "resource.h"       // main symbols

#include <NTLogger.h>
#include "MTAccountDefs.h"
#include <autologger.h>
#include <AccountServerLogging.h>

#import <MTEnumConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTLDAPAdapter
class ATL_NO_VTABLE CMTLDAPAdapter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTLDAPAdapter, &CLSID_MTLDAPAdapter>,
	public IDispatchImpl<::IMTAccountAdapter, &IID_IMTAccountAdapter, &LIBID_MTACCOUNTLib>,
	public ISupportErrorInfo,
	public IMTAccountAdapter2
{
public:
	CMTLDAPAdapter() : 
		mAccID(0), mFirstName(""), mLastName(""), mEmail(""), mCompany(""), mNumber("") {}

DECLARE_REGISTRY_RESOURCEID(IDR_MTLDAPADAPTER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTLDAPAdapter)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter2)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease();

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTLDAPAdapter
public:
	STDMETHOD(Uninstall)();
	STDMETHOD(Install)();
	STDMETHOD(Initialize)(BSTR AdapterName);
	STDMETHOD(AddData)(BSTR AdapterName, 
				       ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);
	STDMETHOD(UpdateData)(BSTR AdapterName, 
					      ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);
	STDMETHOD(GetData)(BSTR AdapterName, 
				       long AccountID,
					   VARIANT apRowset,
				       ::IMTAccountPropertyCollection** mtptr);
	STDMETHOD(SearchData)(BSTR AdapeterName,
  						  IMTAccountPropertyCollection* mtptr,
						  VARIANT apRowset,
  						  IMTSearchResultCollection** mtp);
	STDMETHOD(GetPropertyMetaData)(BSTR aPropertyName,
								   ::IMTPropertyMetaData** apMetaData); 
	STDMETHOD(SearchDataWithUpdLock)(BSTR AdapeterName,
		IMTAccountPropertyCollection* mtptr,
						  BOOL wUpdLock,
						  VARIANT apRowset,						  
  						  IMTSearchResultCollection** mtp);

private:
	MTAutoInstance<MTAutoLoggerImpl<aLDAPLogTile> >	mLogger;
	
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	long mAccID;
	_bstr_t mFirstName;
	_bstr_t mLastName;
	_bstr_t mEmail;
	_bstr_t mCompany;
	_bstr_t mNumber;
};

#endif //__MTLDAPADAPTER_H_
