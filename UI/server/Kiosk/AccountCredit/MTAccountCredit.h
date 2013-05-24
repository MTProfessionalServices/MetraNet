// MTAccountCredit.h : Declaration of the CMTAccountCredit

#ifndef __MTACCOUNTCREDIT_H_
#define __MTACCOUNTCREDIT_H_


#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <loggerconfig.h>
#include <KioskDefs.h>
#include <SetIterate.h>
#include <MTUtil.h>
#include <mtsdk.h>
#include <mtglobal_msg.h>
#include <MTDec.h>

#define DEFAULT_SERVICE_NAME "MetraTech.com/AccountCredit"
#define DEFAULT_HTTP_TIMEOUT 90
#define DEFAULT_HTTP_RETRIES 3
#define DEFAULT_CURRENCY_CODE "USD"


/////////////////////////////////////////////////////////////////////////////
// CMTAccountCredit
class ATL_NO_VTABLE CMTAccountCredit : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAccountCredit, &CLSID_MTAccountCredit>,
	public IDispatchImpl<IMTAccountCredit, &IID_IMTAccountCredit, &LIBID_ACCOUNTCREDITLib>,
	public ObjectWithError
{
public:

CMTAccountCredit();
DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTCREDIT)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountCredit)
	COM_INTERFACE_ENTRY(IMTAccountCredit)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTAccountCredit
public:
	STDMETHOD(get_AutoCredit)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_AutoCredit)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Status)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Status)(/*[in]*/ BSTR newVal);
	STDMETHOD(Submit)();
	STDMETHOD(Initialize)();
	STDMETHOD(get_AccountingCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_AccountingCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_InternalComment)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_InternalComment)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_InvoiceComment)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_InvoiceComment)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Other)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Other)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Reason)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Reason)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Issuer)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Issuer)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EmailText)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EmailText)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EmailAddress)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EmailAddress)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EmailNotification)(/*[out, retval]*/ BOOL *pVal);
	STDMETHOD(put_EmailNotification)(/*[in]*/ BOOL newVal);
	STDMETHOD(get__Currency)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put__Currency)(/*[in]*/ BSTR newVal);
	STDMETHOD(get__Amount)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put__Amount)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get__AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put__AccountID)(/*[in]*/ long newVal);
	STDMETHOD(get_ContentionSessionID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ContentionSessionID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_RequestID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_RequestID)(/*[in]*/ long newVal);
	STDMETHOD(get_RequestAmount)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_RequestAmount)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_CreditAmount)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_CreditAmount)(/*[in]*/ VARIANT newVal);


private:
	_bstr_t mStatus;
	void PrintError(const string& prefix, 
							   const MTMeterError * err);
	DATE	mCreditTime;
	long	mRequestID;
	_bstr_t mContentionSessionID;
	long	m_AccountID;
	MTDecimal m_Amount;
	_bstr_t m_Currency;
	BOOL mEmailNotification;
	_bstr_t mbstrEmailNotification;
	_bstr_t mEmailAddress;
	_bstr_t mEmailText;
	_bstr_t mIssuer;
	_bstr_t mReason;
	_bstr_t mOther;
	_bstr_t mInvoiceComment;
	_bstr_t mInternalComment;
	_bstr_t	mAccountingCode;
	_bstr_t	mAutoCredit;
	MTDecimal mRequestAmount;
	MTDecimal mCreditAmount;

	/*SDK stuff*/
	BOOL mIsInitialized;
	MTMeterHTTPConfig mConfigAccountCreditServer;
	MTMeter mMeterAccountCreditServer;
	string mAccountCreditServer;
  int mAccountCreditServerPort;
  int mAccountCreditServerSecure;

	NTLogger mLogger;


};

#endif //__MTACCOUNTCREDIT_H_
