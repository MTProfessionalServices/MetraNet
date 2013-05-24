// MTAccountCreditRequest.h : Declaration of the CMTAccountCreditRequest

#ifndef __MTACCOUNTCREDITREQUEST_H_
#define __MTACCOUNTCREDITREQUEST_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <loggerconfig.h>
#include <KioskDefs.h>
#include <SetIterate.h>
#include <MTUtil.h>
#include <mtsdk.h>
#include <mtglobal_msg.h>

#define DEFAULT_SERVICE_NAME "MetraTech.com/AccountCreditRequest"
#define DEFAULT_HTTP_TIMEOUT 90
#define DEFAULT_HTTP_RETRIES 3
#define DEFAULT_CURRENCY_CODE "USD"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountCreditRequest
class ATL_NO_VTABLE CMTAccountCreditRequest : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAccountCreditRequest, &CLSID_MTAccountCreditRequest>,
	public IDispatchImpl<IMTAccountCreditRequest, &IID_IMTAccountCreditRequest, &LIBID_ACCOUNTCREDITREQUESTLib>,
	public ObjectWithError
{
public:
	CMTAccountCreditRequest();

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTCREDITREQUEST)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountCreditRequest)
	COM_INTERFACE_ENTRY(IMTAccountCreditRequest)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTAccountCreditRequest
public:
	STDMETHOD(get_SubscriberAccountID)(/*[out, retval]*/long *pVal);
	STDMETHOD(put_SubscriberAccountID)(/*[in]*/ long newVal);
	STDMETHOD(get_Other)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Other)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ContentionID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ContentionID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Status)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Status)(/*[in]*/ BSTR newVal);
	STDMETHOD(get__AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put__AccountID)(/*[in]*/ long newVal);
	STDMETHOD(Initialize)();
	STDMETHOD(Submit)();
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Reason)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Reason)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EmailAddress)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EmailAddress)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EmailNotification)(/*[out, retval]*/ BOOL *pVal);
	STDMETHOD(put_EmailNotification)(/*[in]*/ BOOL newVal);
	STDMETHOD(get__Currency)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put__Currency)(/*[in]*/ BSTR newVal);
	STDMETHOD(get__Amount)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put__Amount)(/*[in]*/ double newVal);
	STDMETHOD(get_CreditAmount)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put_CreditAmount)(/*[in]*/ double newVal);
private:
	void PrintError(const string& prefix, 
							   const MTMeterError * err);
	MTMeterHTTPConfig mConfigAccountCRServer;
	MTMeter mMeterAccountCRServer; /*CR for credit request*/
	BOOL mIsInitialized;
	NTLogger mLogger;

  //mandatory properties, won't meter without them
	long mAccountID, mSubscriberAccountID;
	double m_Amount, mCreditAmount;
  _bstr_t m_Currency;
  BOOL mNeedNotification;
	_bstr_t mbstrNeedNotification;
	_bstr_t mEmailAddress;
	//it's OK not to have description?
	_bstr_t mDescription;
	//optional property (in future we may want to
	//automatically credit account)
	//right now it will be set by the plugin to PENDING
	_bstr_t mStatus;

	_bstr_t mReason;
	_bstr_t mOther;
	_bstr_t mContentionID;
	_bstr_t mSessionID;

	string mAccountCRServer;
  int mAccountCRServerPort;
  int mAccountCRServerSecure;

};

#endif //__MTACCOUNTCREDITREQUEST_H_
