	
// COMAccount.h : Declaration of the CCOMAccount

#ifndef __COMACCOUNT_H_
#define __COMACCOUNT_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <Account.h>
#include <ComKioskLogging.h>
#include <autologger.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMAccount
class ATL_NO_VTABLE CCOMAccount : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMAccount, &CLSID_COMAccount>,
	public ISupportErrorInfo,
	public IDispatchImpl<ICOMAccount, &IID_ICOMAccount, &LIBID_COMKIOSKLib>
{
public:
    // Default constructor 
	CCOMAccount();

    // Destructor 
	virtual ~CCOMAccount();
  

DECLARE_REGISTRY_RESOURCEID(IDR_COMACCOUNT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CCOMAccount)
	COM_INTERFACE_ENTRY(ICOMAccount)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMAccount
public:
	STDMETHOD(GetAccountInfo)(/*[in]*/ BSTR Login, /*[in]*/ BSTR Name_Space);
	STDMETHOD(get_TimezoneOffset)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put_TimezoneOffset)(/*[in]*/ double newVal);
	STDMETHOD(get_TimezoneID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TimezoneID)(/*[in]*/ long newVal);
	STDMETHOD(get_TaxExempt)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_TaxExempt)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_GeoCode)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_GeoCode)(/*[in]*/ long newVal);
	STDMETHOD(get_TariffName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_TariffName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(get_PaymentMethod)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PaymentMethod)(/*[in]*/ long newVal);
	STDMETHOD(get_StartDate)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_StartDate)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_EndDate)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_EndDate)(/*[in]*/ VARIANT newVal);
	
	STDMETHOD(get_TariffID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TariffID)(/*[in]*/ long newVal);
	STDMETHOD(get_Currency)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Currency)(/*[in]*/ BSTR newVal);
	STDMETHOD(Initialize)();
	STDMETHOD(Add)(long aAccountStatus, LPDISPATCH pRowset, long* iAccID);
	STDMETHOD(GetAccountInfoForAccountID)(/*[in]*/ long AccountID);
	STDMETHOD(IsActiveAccount)(/*[out, retval]*/int* active_flag);
	STDMETHOD(Update)(BSTR Login, BSTR Namespace, VARIANT AccountEndDate, long alAccountStatus);
	STDMETHOD(get_AccountCycleID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountCycleID)(/*[in]*/ long newVal);

private:

  // pointer to c++ account object
  CAccount mAccount;
  
  // member to check if the object initialized itself
  // properly
  BOOL mIsInitialized;

  // member to check if the object initialized itself
  // properly
  BOOL mIsAccountInfoAvailable;
  
	MTAutoInstance<MTAutoLoggerImpl<szComKioskAccount,szComKioskLoggingDir> >	mLogger;
  long mAccountID;
  _bstr_t mTariffName;
  long mGeoCode;
  _bstr_t mTaxExempt;
  long mTimezoneID;
  double mTimezoneOffset;
  long mPaymentMethod;
  _variant_t mStartDate;
  _variant_t mEndDate;
  long mTariffID;
  
  _bstr_t mCurrency;
  long mAccountCycleID;
};

#endif //__COMACCOUNT_H_
