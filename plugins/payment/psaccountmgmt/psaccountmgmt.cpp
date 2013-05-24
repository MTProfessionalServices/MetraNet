/**************************************************************************
 * @doc PSAccountMgmt
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Co:poration,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * Modified by: David McCowan 5/28/99
 *
 * $Date: 9/11/2002 9:48:59 AM$
 * $Author: Alon Becker$
 * $Revision: 42$
 ***************************************************************************/

#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>

#include <PlugInSkeleton.h>
#include <base64.h>
#include <mtcomerr.h>
#include <mtparamnames.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <mtcryptoapi.h>
#include <MTUtil.h>
#include <paymentserverdefs.h>
#include <PaymentAudit.h>
#include <mtsdk.h>
#include <reservedproperties.h>
#include <sessionerr.h>
#include <ConfigDir.h>
#include <MTDec.h>
#include <map>
#include <formatdbvalue.h>

#include <string>

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <CreditCard.tlb>
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace 
#import <MTConfigLib.tlb>
#import <MTEnumConfigLib.tlb> 
#import <MTServerAccess.tlb>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")


using namespace std;

// generate using uuidgen
CLSID CLSID_PSAccountMgmt = { /* acd95a20-8da0-11d4-a71a-00c04f58c76e */
    0xacd95a20,
    0x8da0,
    0x11d4,
    {0xa7, 0x1a, 0x00, 0xc0, 0x4f, 0x58, 0xc7, 0x6e}
  };

class ATL_NO_VTABLE MTPSAccountMgmt
	: public MTPipelinePlugIn<MTPSAccountMgmt, &CLSID_PSAccountMgmt>,
    public ObjectWithError
{
public:
  MTPSAccountMgmt::MTPSAccountMgmt() : mmhcHttpMeter(NULL), 
                                       mmtmMeter(mmhcHttpMeter), 
                                       mblnSecure(false) {}

protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr           aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr        aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

private:

  _bstr_t GetCountryName(const _bstr_t& );

  BOOLEAN           mblnSecure;
  _bstr_t           mbstrUserName;
  _bstr_t           mbstrUserPassword;
  MTMeterHTTPConfig mmhcHttpMeter;
  MTMeter           mmtmMeter;
	CREDITCARDLib::IMTCreditCardPtr mtcc;
	
  // encryption object
  CMTCryptoAPI mCrypto;
  
  // auditing object
  PaymentAudit mAudit;

  //
  // These methods represent the services supported by this plugin.
  //

  HRESULT CC_AddAccountAndPaymentMethod(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT CC_AddPaymentMethod(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT ACH_AddAccountAndPaymentMethod(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT ACH_AddPaymentMethod(MTPipelineLib::IMTSessionPtr aSession);

  HRESULT UpdateAccount(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT CC_UpdatePaymentMethod(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT CC_UpdatePrimaryIndicator(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT ACH_UpdatePaymentMethod(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT ACH_UpdatePrimaryIndicator(MTPipelineLib::IMTSessionPtr aSession);

  HRESULT CC_DeletePaymentMethod(MTPipelineLib::IMTSessionPtr aSession, long alngMode);
  HRESULT ACH_DeletePaymentMethod(MTPipelineLib::IMTSessionPtr aSession, long alngMode);

  HRESULT CC_FindUpdateByNumberDateType(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT CC_FindByAccountidLast4Type(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT CC_FindByAccountid(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT ACH_FindByAccountid(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT ACH_FindByAccountidRoutingNumberLast4Type(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT UpdateAuthorization(MTPipelineLib::IMTSessionPtr aSession);
  HRESULT GetAccountAndPrimaryPaymentMethod(MTPipelineLib::IMTSessionPtr aSession);
	HRESULT GetInternalCCType(const long& aType, CREDITCARDLib::MTCreditCardType& aInternalType);
	HRESULT GetComError(CREDITCARDLib::MTCreditCardErrorMsg& aMsg);

  //
  // Supporting methods 
  //

  HRESULT AddAccount(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);

  HRESULT CC_AddAccountAndPaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            long                         alngAddtype);
          
  HRESULT CC_AddPaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            BOOL                         ablnMarkAsPrimary);

  HRESULT ACH_AddAccountAndPaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            long                         alngAddtype);
          
  HRESULT ACH_AddPaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            BOOL                         ablnMarkAsPrimary);

  HRESULT UpdateAccountInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);
          
  HRESULT CC_UpdatePaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);
          
  HRESULT ACH_UpdatePaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);

  HRESULT UpdateACHAuthorizationInternal(MTPipelineLib::IMTSessionPtr aSession, 
																				 ROWSETLib::IMTSQLRowsetPtr   pRowset);

  HRESULT UpdateCCAuthorizationInternal(MTPipelineLib::IMTSessionPtr aSession,
																				ROWSETLib::IMTSQLRowsetPtr   pRowset);
          
#define MT_CREDITCARD 0
#define MT_ACH        1
  HRESULT UpdatePrimaryIndicator(
            MTPipelineLib::IMTSessionPtr aSession,
            long                         alngPaymentMethodType);

  HRESULT UpdatePrimaryIndicatorInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            long                         alngPaymentMethodType);
          
  HRESULT CC_UpdatePrimaryIndicatorInternal(
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            long                         lngAcctid,
            _bstr_t                      bstrLastFourDigits,
            long                         lngCreditCardType,
            BOOL                         blnPrimary);

  HRESULT ACH_UpdatePrimaryIndicatorInternal(
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            long                         lngAcctid,
            _bstr_t                      bstrRoutingNumber,
            _bstr_t                      bstrLastFourDigits,
            long                         lngAccountType,
            BOOL                         blnPrimary);

#define MT_RESTRICTED    0
#define MT_NOTRESTRICTED 1
  HRESULT CC_DeletePaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            long                         alngMode);
          
  HRESULT ACH_DeletePaymentMethodInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            long                         alngMode);

  HRESULT DeleteAccountInternal(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);
          
  HRESULT CC_DeletePreviousPaymentMethod(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset); 

  HRESULT ACH_DeletePreviousPaymentMethod(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset); 

  HRESULT GetNumPaymentMethodsOnRecord(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset, 
            long                       * alngCount);

  HRESULT GetNumCCPaymentMethodsOnRecord(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset, 
            long                       * alngCount);

  HRESULT GetNumACHPaymentMethodsOnRecord(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset, 
            long                       * alngCount);

  HRESULT CC_CheckIfPrimary(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            BOOL                       * ablnRet,
            long                         alngMode);

  HRESULT ACH_CheckIfPrimary(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            BOOL                       * ablnRet,
            long                         alngMode);

  HRESULT CC_GetPrimary(
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            long                         alngAcctid,
            BOOL                       & ablnRet,
            _bstr_t                    & abstrLastFourDigits,
            long                       & alngCctype);

  HRESULT ACH_GetPrimary(
            ROWSETLib::IMTSQLRowsetPtr   pRowset,
            long                         alngAcctid,
            BOOL                       & ablnRet,
            _bstr_t                    & bstrRoutingNumber,
            _bstr_t                    & bstrLastFourDigits,
            long                       & lngCctype);

  HRESULT GetPrimaryPaymentMethod(MTPipelineLib::IMTSessionPtr aSession);

  HRESULT CC_ValidateCreditCard(MTPipelineLib::IMTSessionPtr aSession);

  HRESULT ACH_ValidateBankInfo(MTPipelineLib::IMTSessionPtr aSession);

  HRESULT InternalLookupCCByAcctidLast4Type(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);

  HRESULT InternalLookupCCByAcctid(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);

  HRESULT InternalLookupACHByAcctidRoutingNumberLast4Type(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);

  HRESULT InternalLookupACHByAcctid(
            MTPipelineLib::IMTSessionPtr aSession,
            ROWSETLib::IMTSQLRowsetPtr   pRowset);
  
  HRESULT InternalGetAccount(
			MTPipelineLib::IMTSessionPtr aSession, 
			ROWSETLib::IMTSQLRowsetPtr	 pRowset);

  HRESULT Audit(MTPipelineLib::IMTSessionPtr aSession,
                ROWSETLib::IMTSQLRowsetPtr   pRowset,
                long                         acctid,
                const char                 * action,
                const char                 * routingnumber,
                const char                 * last4,
                const char                 * accountype,
                const char                 * bankname,
                const char                 * expdate,
                long                         expdatef,
                const char                 * subscriberid,
                const char                 * phonenumber,
                const char                 * csrip,
                const char                 * csrid,
                const char                 * notes);

  void    DecryptNumber(MTPipelineLib::IMTSessionPtr aSession, long aPropId);

  void    DecryptNumber(_bstr_t & bstrNum);

  BOOL    AddLastFourDigits(MTPipelineLib::IMTSessionPtr aSession, long aPropId);

  void    FormatCCNumber(wstring &);
  void    FormatCCNumber(_bstr_t&);

  HRESULT FormatNumber(
            _bstr_t& num,
						_bstr_t& aDecryptedNum,
            string& lastfourdigits);

  void    GetLastFourDigits(string&);

  BOOLEAN IsSuppliedExpDateNewer(
            _bstr_t SuppliedDate,
            _bstr_t StoredDate,
			CREDITCARDLib::MTExpDateFormat Format);

  _bstr_t GetEnumName(long lngCctype);

#define MT_BOTH          0 
#define MT_PAYMENTMETHOD 1
#define MT_ACCOUNT       2
  HRESULT  MTPSAccountMgmt::LogAttempt(
                              MTPipelineLib::IMTSessionPtr aSession,
                              _bstr_t                      bstrLogString,
                              _bstr_t                      bstrAction,
                              long                         lngCategory);

  HRESULT  MTPSAccountMgmt::LogAttempt(
                              MTPipelineLib::IMTSessionPtr aSession,
                              _bstr_t                      bstrLogString,
                              _bstr_t                      bstrAction);

  //
  // plugin initialization data 
  //

  // input property IDs

  // service def properties
  long mlngCustomerName;
  long mlngAddress;
  long mlngCity;
  long mlngState;
  long mlngZip;
  long mlngCountry;
  long mlngEmail;
  long mlngCreditCardType;        // credit card specific
  long mlngLastFourDigits;
  long mlngCreditCardNum;         // credit card specific
  long mlngCreditCardSecCode;         // credit card specific
  long mlngExpDate;               // credit card specific
  long mlngExpDateFormat;         // credit card specific
  long mlngStartDate;             // credit card specific
  long mlngIssuerNumber;          // credit card specific
  long mlngCardId;                // amex/purchase/credit card
  long mlngCardVerifyValue;       // credit card specific
  long mlngCustomerReferenceId;
  long mlngCustomerVatNumber;     // international purchase card
  long mlngCompanyAddress;        // international purchase card
  long mlngCompanyPostalCode;     // international purchase card
  long mlngCompanyPhone;          // international purchase card
  long mlngReserved1;
  long mlngReserved2;
  long mlngRetainCardInfo;
  long mlngRoutingNumber;         // ACH specific
  long mlngBankAccountNumber;     // ACH specific
  long mlngBankName;              
  long mlngAccountType;           // ACH specific
  long mlngPrimary;               
  long mlngEnabled;               
  long mlngValidated;               
  long mlngAccountID;
  long mlngTestSession;
  long mlngRequestMultipleDataSets;
  long mlngAuthReceived;
  long mlngRetryOnFailure;
  long mlngNumberRetries;
  long mlngConfirmRequested;
  long mlngDelay;
  long mlngBillEarly;
  long mlngPaymentType;

  // additional session properties
  long mlngActionType;
  BOOL mblnClearAccountNumber;
  long mlngIpAddress;

  // output property IDs

  long mlngRetCode;
  long mlngRespCode;
  long mlngRespString;
  long mlngPaymentServiceTransactionId;

  // config data
  BOOL   mblnValidateOnAdd;
  BOOL   mblnValidateOnUpdate;

#ifdef DECIMAL_PLUGINS
  MTDecimal mdecValidateAmount;
#else
	double mdblValidateAmount;
#endif

  BOOL   mblnAllowMultipleDataSets;
  BOOL   mblnUseExternalEmail;
  
  long mEnumCCPaymentType;
  long mEnumACHPaymentType;	

  MTPipelineLib::IMTLogPtr mLogger;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

  _bstr_t mbstrConfigPath;

	// configuration property maps 
	
  struct PaymentOption {
	
    PaymentOption() : mGlobal(false) {} 
	  
	_variant_t mValue;
	bool mGlobal;
  };

  typedef map<long, PaymentOption*> PaymentOptionMap; 
  typedef map<long, PaymentOptionMap*> PaymentOptionMapSet;

  PaymentOptionMapSet mPaymentOptionMapSet;

};


PLUGIN_INFO(CLSID_PSAccountMgmt, MTPSAccountMgmt,
						"MetraPipeline.PSAccountMgmt.1", "MetraPipeline.PSAccountMgmt", "Free")


HRESULT MTPSAccountMgmt::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
											  							   MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			   MTPipelineLib::IMTNameIDPtr aNameID,
																			   MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  HRESULT hr = S_OK;
  try
  {
    mLogger = aLogger;
  
    mLogger->LogString(
      MTPipelineLib::PLUGIN_LOG_DEBUG,
      "MTPSAccountMgmt::PlugInConfigure: entered\n");

    // look up the property IDs of the props we need
    MTPipelineLib::IMTNameIDPtr idlookup(aSysContext);

    // service definition properties
    _bstr_t CustomerName            = aPropSet->NextStringWithName("customername");
    _bstr_t Address                 = aPropSet->NextStringWithName("address");
    _bstr_t City                    = aPropSet->NextStringWithName("city");
    _bstr_t State                   = aPropSet->NextStringWithName("state");
    _bstr_t Zip                     = aPropSet->NextStringWithName("zip");
    _bstr_t Country                 = aPropSet->NextStringWithName("country");
    _bstr_t Email                   = aPropSet->NextStringWithName("email");
    _bstr_t CreditCardType          = aPropSet->NextStringWithName("creditcardtype");
    _bstr_t LastFourDigits          = aPropSet->NextStringWithName("lastfourdigits");
    _bstr_t CreditCardNum           = aPropSet->NextStringWithName("creditcardnum");
    _bstr_t CreditCardSecCode       = aPropSet->NextStringWithName("creditcardseccode");
    _bstr_t ExpDate                 = aPropSet->NextStringWithName("expdate");
    _bstr_t ExpDateFormat           = aPropSet->NextStringWithName("expdateformat");
    _bstr_t StartDate               = aPropSet->NextStringWithName("startdate");
    _bstr_t IssuerNumber            = aPropSet->NextStringWithName("issuernumber");
    _bstr_t CardId                  = aPropSet->NextStringWithName("cardid");
    _bstr_t CardVerifyValue         = aPropSet->NextStringWithName("cardverifyvalue");
    _bstr_t CustomerReferenceId     = aPropSet->NextStringWithName("customerreferenceid");
    _bstr_t CustomerVatNumber       = aPropSet->NextStringWithName("customervatnumber");
    _bstr_t CompanyAddress          = aPropSet->NextStringWithName("companyaddress");
    _bstr_t CompanyPostalCode       = aPropSet->NextStringWithName("companypostalcode");
    _bstr_t CompanyPhone            = aPropSet->NextStringWithName("companyphone");
    _bstr_t Reserved1               = aPropSet->NextStringWithName("reserved1");
    _bstr_t Reserved2               = aPropSet->NextStringWithName("reserved2");
    _bstr_t RetainCardInfo          = aPropSet->NextStringWithName("retaincardinfo");
    _bstr_t RoutingNumber           = aPropSet->NextStringWithName("routingnumber");
    _bstr_t BankAccountNumber       = aPropSet->NextStringWithName("bankaccountnumber");
    _bstr_t BankName                = aPropSet->NextStringWithName("bankname");
    _bstr_t AccountType             = aPropSet->NextStringWithName("accounttype");
    _bstr_t Primary                 = aPropSet->NextStringWithName("primary");
    _bstr_t Enabled                 = aPropSet->NextStringWithName("enabled");
    _bstr_t Validated               = aPropSet->NextStringWithName("validated");
    _bstr_t AccountID               = aPropSet->NextStringWithName("accountid");
    _bstr_t TestSession             = aPropSet->NextStringWithName("testsession");
    _bstr_t TransactionCookie       = aPropSet->NextStringWithName("transactioncookie");
    _bstr_t AuthReceived            = aPropSet->NextStringWithName("authreceived");
    _bstr_t RetryOnFailure          = aPropSet->NextStringWithName("retryonfailure");
    _bstr_t NumberRetries           = aPropSet->NextStringWithName("numberretries");
    _bstr_t ConfirmRequested        = aPropSet->NextStringWithName("confirmrequested");
    _bstr_t Delay                   = aPropSet->NextStringWithName("delay");
    _bstr_t BillEarly               = aPropSet->NextStringWithName("billearly");
		_bstr_t PaymentType				      = aPropSet->NextStringWithName("paymenttype");



    // additional properties
    _bstr_t ActionType              = aPropSet->NextStringWithName("actiontype");
    mblnClearAccountNumber          = aPropSet->NextBoolWithName("clearaccountnumber");

    // properties added to session
    _bstr_t RetCode                     = aPropSet->NextStringWithName("retcode");
    _bstr_t RespCode                    = aPropSet->NextStringWithName("respcode");
    _bstr_t RespString                  = aPropSet->NextStringWithName("respstring");
    _bstr_t PaymentServiceTransactionId = aPropSet->NextStringWithName("paymentservicetransactionid");
		_bstr_t aServerAccessEntry = aPropSet->NextStringWithName("metering_serveraccess_entry");


    // retrieve property values
    mlngCustomerName            = idlookup->GetNameID(CustomerName);
    mlngAddress                 = idlookup->GetNameID(Address);
    mlngCity                    = idlookup->GetNameID(City);
    mlngState                   = idlookup->GetNameID(State);
    mlngZip                     = idlookup->GetNameID(Zip);
    mlngCountry                 = idlookup->GetNameID(Country);
    mlngEmail                   = idlookup->GetNameID(Email);
    mlngCreditCardType          = idlookup->GetNameID(CreditCardType);
    mlngLastFourDigits          = idlookup->GetNameID(LastFourDigits);
    mlngCreditCardNum           = idlookup->GetNameID(CreditCardNum);
    mlngCreditCardSecCode       = idlookup->GetNameID(CreditCardSecCode);
    mlngExpDate                 = idlookup->GetNameID(ExpDate);
    mlngExpDateFormat           = idlookup->GetNameID(ExpDateFormat);
    mlngStartDate               = idlookup->GetNameID(StartDate);
    mlngIssuerNumber            = idlookup->GetNameID(IssuerNumber);
    mlngCardId                  = idlookup->GetNameID(CardId);
    mlngCardVerifyValue         = idlookup->GetNameID(CardVerifyValue);
    mlngCustomerReferenceId     = idlookup->GetNameID(CustomerReferenceId);
    mlngCustomerVatNumber       = idlookup->GetNameID(CustomerVatNumber);
    mlngCompanyAddress          = idlookup->GetNameID(CompanyAddress);
    mlngCompanyPostalCode       = idlookup->GetNameID(CompanyPostalCode);
    mlngCompanyPhone            = idlookup->GetNameID(CompanyPhone);
    mlngReserved1               = idlookup->GetNameID(Reserved1);
    mlngReserved2               = idlookup->GetNameID(Reserved2);
    mlngRetainCardInfo          = idlookup->GetNameID(RetainCardInfo);
    mlngRoutingNumber           = idlookup->GetNameID(RoutingNumber);
    mlngBankAccountNumber       = idlookup->GetNameID(BankAccountNumber);
    mlngBankName                = idlookup->GetNameID(BankName);
    mlngAccountType             = idlookup->GetNameID(AccountType);
    mlngRetryOnFailure          = idlookup->GetNameID(RetryOnFailure);
    mlngNumberRetries           = idlookup->GetNameID(NumberRetries);
    mlngPrimary                 = idlookup->GetNameID(Primary);
    mlngEnabled                 = idlookup->GetNameID(Enabled);
    mlngValidated               = idlookup->GetNameID(Validated);
    mlngAccountID               = idlookup->GetNameID(AccountID);
    mlngTestSession             = idlookup->GetNameID(TestSession);
    mlngAuthReceived            = idlookup->GetNameID(AuthReceived);
    mlngRetryOnFailure          = idlookup->GetNameID(RetryOnFailure);
    mlngNumberRetries           = idlookup->GetNameID(NumberRetries);
    mlngConfirmRequested        = idlookup->GetNameID(ConfirmRequested);
    mlngDelay                   = idlookup->GetNameID(Delay);
    mlngBillEarly               = idlookup->GetNameID(BillEarly);
		mlngPaymentType			      	= idlookup->GetNameID(PaymentType);

    mlngActionType              = idlookup->GetNameID(ActionType);
    mlngIpAddress               = idlookup->GetNameID("_ipaddress");

    mlngRetCode                     = idlookup->GetNameID(RetCode);
    mlngRespCode                    = idlookup->GetNameID(RespCode);
    mlngRespString                  = idlookup->GetNameID(RespString);
    mlngPaymentServiceTransactionId = idlookup->GetNameID(PaymentServiceTransactionId);
		
    //
    // read everything from the plugin configuration file, now read the dynamic
    // configuration information
    //

    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

    _bstr_t bstrConfigFile;

    std::string sConfigDir;
    if (!GetExtensionsDir(sConfigDir))
    {
      aLogger->LogString(
        MTPipelineLib::PLUGIN_LOG_ERROR,
        "psaccountmgmt::PlugInConfigure: unable to get configuration directory from registry");
  
      _bstr_t errormsg  = "unable to get configuration directory from registry";
      return Error((char*)errormsg);
    }

    mbstrConfigPath = sConfigDir.c_str();
    mbstrConfigPath += "\\paymentsvr\\config\\PaymentServer";
    bstrConfigFile = mbstrConfigPath + "\\ConfigurationOptions.xml";

    VARIANT_BOOL flag;

    MTConfigLib::IMTConfigPropSetPtr configOptions = config->ReadConfiguration(bstrConfigFile, &flag);

    mblnValidateOnAdd         = configOptions->NextBoolWithName("validateonadd");
    mblnValidateOnUpdate      = configOptions->NextBoolWithName("validateonupdate");

#ifdef DECIMAL_PLUGINS
    mdecValidateAmount        = configOptions->NextDecimalWithName("validateamount");
#else
    mdblValidateAmount        = configOptions->NextDoubleWithName("validateamount");
#endif

    mblnAllowMultipleDataSets = configOptions->NextBoolWithName("allowmultipledatasets");
    mblnUseExternalEmail      = configOptions->NextBoolWithName("useexternalemail");
	mEnumCCPaymentType		  = configOptions->NextLongWithName("CC_PaymentType");
	mEnumACHPaymentType		  = configOptions->NextLongWithName("ACH_PaymentType");	
																 
	MTConfigLib::IMTConfigPropSetPtr paymentOptions = configOptions->NextSetWithName("PaymentOptions");

	while (paymentOptions != NULL)
	{
		PaymentOptionMap * pOptionMap = new PaymentOptionMap;
		
		long lPaymentType = paymentOptions->NextLongWithName("PaymentType");
		
		// read all possible configuration options, looking for global ones	
		MTConfigLib::IMTConfigPropPtr paymentOption = paymentOptions->Next();
		
		while (paymentOption != NULL)
		{
			PaymentOption * pOption = new PaymentOption;	

			pOption->mValue = paymentOption->GetPropValue();	
			long key = idlookup->GetNameID(paymentOption->GetName());	
		
			MTConfigLib::IMTConfigAttribSetPtr atrs = paymentOption->GetAttribSet();
			
			if (atrs != NULL)
			{
				_bstr_t global = atrs->GetAttrValue(L"global");
				pOption->mGlobal = (global == _bstr_t("Y")) ? true : false;			
			}
			
			(*pOptionMap)[key] = pOption;
	
			paymentOption = paymentOptions->Next();
		}

		mPaymentOptionMapSet[lPaymentType] = pOptionMap;	
		paymentOptions = configOptions->NextSetWithName("PaymentOptions");
	}	

    int result = mCrypto.CreateKeys("metratechpipeline", true, "pipeline");
    if (result == 0)
      result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_PaymentInstrument, "metratechpipeline", TRUE, "pipeline");

    if (result != 0)
    {
      char chrBuf[1024];

      sprintf(chrBuf, 
              "Unable to initialize crypto functions: %x: %s",
              result,
              mCrypto.GetCryptoApiErrorString());

      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, chrBuf);
      return S_FALSE;
    }

    mAudit.Initialize();

    // now validate the card
    if (mblnValidateOnAdd || mblnValidateOnUpdate)
    {
      // setup for remeter
      if(!mmtmMeter.Startup())
      {
        hr = Error("Failed to Initialize Meter object");
      }
      else
      {
				// lookup server access entry
				aServerAccessEntry;

				MTSERVERACCESSLib::IMTServerAccessDataSetPtr aServerAccess(MTPROGID_SERVERACCESS);
				aServerAccess->Initialize();

				// this will throw an exception if the entry is not found
				MTSERVERACCESSLib::IMTServerAccessDataPtr aEntry = aServerAccess->FindAndReturnObject(aServerAccessEntry);
        mmhcHttpMeter.AddServer(aEntry->GetPriority(),	// priority (highest)
          aEntry->GetServerName(),				              // hostname
          aEntry->GetPortNumber(),											// port (default plaintext HTTP)
					aEntry->GetSecure(),													// secure? (no)
					aEntry->GetUserName(),												// username
					aEntry->GetPassword());												// password
      }
    }

    //store enum config pointer from system context
    mEnumConfig = aSysContext->GetEnumConfig();
    _ASSERTE(mEnumConfig != NULL);
  }
  catch (_com_error & err)
  {
    _bstr_t sErrBuf;

    sErrBuf = "MTPSAccount::PlugInConfigure: ";
    sErrBuf += "Error reading configuration file: ";
    sErrBuf += (const char *)err.Description() == NULL ? "no detailed error" : (const char*)err.Description();

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const char *)sErrBuf);

    hr = ReturnComError(err);
  }

	return mtcc.CreateInstance("MetraTechAccount.MTCreditCard.1");
	
}

HRESULT MTPSAccountMgmt::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = S_OK;
  BOOL bRes(FALSE);

  //
  // The presence of the transaction cookie determines that this session
  // is part of a distributed transaction.
  //
	
  try
  {
    long ActionType = aSession->GetLongProperty(mlngActionType);

    switch (ActionType)
    {
    case CC_ADD_ACCOUNT_AND_PAYMENT_METHOD:
      hr = CC_AddAccountAndPaymentMethod(aSession);
      if (FAILED(hr))
        return Error("CC : Addition of account and payment method failed", 
					   IID_IMTPipelinePlugIn, hr);
      //MT_THROW_COM_ERROR(hr);
      break;
      
    case CC_ADD_PAYMENT_METHOD:
      hr = CC_AddPaymentMethod(aSession);
      if (FAILED(hr))
        return Error("CC : Addition of payment method failed", 
					   IID_IMTPipelinePlugIn, hr);
      //MT_THROW_COM_ERROR(hr);
      break;
      
    case ACH_ADD_ACCOUNT_AND_PAYMENT_METHOD:
      hr = ACH_AddAccountAndPaymentMethod(aSession);
      if (FAILED(hr))
        return Error("ACH : Addition of account and payment method failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case ACH_ADD_PAYMENT_METHOD:
      hr = ACH_AddPaymentMethod(aSession);
      if (FAILED(hr))
        return Error("ACH : Addition of payment method failed",
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case UPDATE_ACCOUNT:
      hr = UpdateAccount(aSession);
      if (FAILED(hr))
        return Error("Update account failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case CC_UPDATE_PAYMENT_METHOD:
      hr = CC_UpdatePaymentMethod(aSession);
      if (FAILED(hr))
        return Error("CC : Update payment method failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case ACH_UPDATE_PAYMENT_METHOD:
      hr = ACH_UpdatePaymentMethod(aSession);
      if (FAILED(hr))
        return Error("ACH : Update payment method failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case CC_UPDATE_PRIMARY_INDICATOR:
      hr = CC_UpdatePrimaryIndicator(aSession);
      if (FAILED(hr))
        return Error("CC : Update primary indicator failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case ACH_UPDATE_PRIMARY_INDICATOR:
      hr = ACH_UpdatePrimaryIndicator(aSession);
      if (FAILED(hr))
        return Error("ACH : Update primary indicator failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case CC_DELETE_PAYMENT_METHOD:
      hr = CC_DeletePaymentMethod(aSession, MT_NOTRESTRICTED);
      if (FAILED(hr))
        return Error("CC : Deletion of payment method failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case ACH_DELETE_PAYMENT_METHOD:
      hr = ACH_DeletePaymentMethod(aSession, MT_NOTRESTRICTED);
      if (FAILED(hr))
        return Error("ACH : Deletion of payment method failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case CC_FIND_BY_ACCOUNTID_LAST4_TYPE:
      hr = CC_FindByAccountidLast4Type(aSession);
      if (FAILED(hr))
        return Error("CC : Find by account ID/last 4/type failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case CC_FIND_BY_ACCOUNTID:
      hr = CC_FindByAccountid(aSession);
      if (FAILED(hr))
        return Error("CC : Find by account ID failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case ACH_FIND_BY_ACCOUNTID:
      hr = ACH_FindByAccountid(aSession);
      if (FAILED(hr))
        return Error("ACH : Find by account ID failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case ACH_FIND_BY_ACCOUNTID_ROUTINGNUMBER_LAST4_TYPE:
      hr = ACH_FindByAccountidRoutingNumberLast4Type(aSession);
      if (FAILED(hr))
        return Error("ACH : Find by account/routing number/last 4/type failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case CC_FIND_UPDATE_BY_NUMBER_DATE_TYPE:
      hr = CC_FindUpdateByNumberDateType(aSession);
      if (FAILED(hr))
        return Error("CC : Find update by number/date/type failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    case DECRYPT_CC_NUMBER:
      DecryptNumber(aSession, mlngCreditCardNum);
      //decrypt optional security code
      if (aSession->PropertyExists(mlngCreditCardSecCode,
															 MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
        DecryptNumber(aSession, mlngCreditCardSecCode);
      break;
      
    case DECRYPT_ACH_NUMBER:
      DecryptNumber(aSession, mlngBankAccountNumber);
      AddLastFourDigits(aSession, mlngBankAccountNumber);
      break;
      
    case GET_ACCOUNT_AND_PRIMARY_PAYMENT_METHOD:
     	hr = GetAccountAndPrimaryPaymentMethod(aSession);
      if (FAILED(hr))
			{
				if (hr == CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND)
				{
					char LogBuf[1024];
					sprintf(LogBuf, 
									"Account with ID <%d> not found on payment server", 
									aSession->GetLongProperty(mlngAccountID));
					return Error(LogBuf,
											 IID_IMTPipelinePlugIn, 
											 hr);
				}
				else
					return Error("Get Account And Primary Method Failed",
											 IID_IMTPipelinePlugIn, 
											 hr);
			}
     	break;
      
    case UPDATE_AUTHORIZATION:
      hr = UpdateAuthorization(aSession);
      if (FAILED(hr))
        return Error("Update authorization failed", 
					   IID_IMTPipelinePlugIn, hr);
      break;
      
    default:
      char chrLogBuf[128];
      sprintf(chrLogBuf, "Service %d is not supported.", ActionType);
      return Error(chrLogBuf, IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_ANY_ERROR);
    }

    if (SUCCEEDED(hr))
    {
      if (TRUE == mblnClearAccountNumber)
      {
        aSession->SetStringProperty(mlngCreditCardNum, L"");
        aSession->SetStringProperty(mlngBankAccountNumber, L"");
      }
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return hr;
}

HRESULT MTPSAccountMgmt::PlugInShutdown()
{
  if (mblnValidateOnAdd || mblnValidateOnUpdate)
    mmtmMeter.Shutdown();

	for (PaymentOptionMapSet::iterator its = mPaymentOptionMapSet.begin(); its != mPaymentOptionMapSet.end(); ++its)		
	{
		PaymentOptionMap * pOptionMap  = its->second;
		
		for (PaymentOptionMap::iterator itm = pOptionMap->begin(); itm != pOptionMap->end(); ++itm)
		{
			PaymentOption * pOption = itm->second;
			delete pOption;
			pOption = NULL;
		}

		delete pOptionMap;
		pOptionMap = NULL;
	}


	return S_OK;
}

//
// Payment Server Account Management Interface methods.
//

//
// Add methods
//

HRESULT
MTPSAccountMgmt::CC_AddAccountAndPaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = CC_AddAccountAndPaymentMethodInternal(aSession, MT_BOTH); 
  return hr;
}

HRESULT
MTPSAccountMgmt::CC_AddPaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = CC_AddAccountAndPaymentMethodInternal(aSession, MT_PAYMENTMETHOD); 
  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_AddAccountAndPaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = ACH_AddAccountAndPaymentMethodInternal(aSession, MT_BOTH); 
  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_AddPaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = ACH_AddAccountAndPaymentMethodInternal(aSession, MT_PAYMENTMETHOD); 
  return hr;
}

HRESULT
MTPSAccountMgmt::AddAccount(MTPipelineLib::IMTSessionPtr aSession,
                            ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  long    lngAcctid           = aSession->GetLongProperty(mlngAccountID);
  long    lngRetainCardInfo   = aSession->GetLongProperty(mlngRetainCardInfo);
  long    lngRetryOnFailure   = aSession->GetLongProperty(mlngRetryOnFailure);
  long    lngNumberRetries    = aSession->GetLongProperty(mlngNumberRetries);
  long    lngConfirmRequested = aSession->GetLongProperty(mlngConfirmRequested);
  long    lngDelay            = aSession->GetLongProperty(mlngDelay);
  long    lngBillEarly        = aSession->GetLongProperty(mlngBillEarly);
  HRESULT hr = S_OK;

	// email address is optional
  _bstr_t bstrEmail;
	if (aSession->PropertyExists(mlngEmail,
															 MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
		bstrEmail									= aSession->GetStringProperty(mlngEmail);
	else
		bstrEmail									= "";

  _variant_t vtParam;

	try
	{
		pRowset->ClearQuery();
  		
 		// set the query tag ...
 		_bstr_t queryTag = "__INSERT_T_PS_ACCOUNT_TABLE__" ;
 		pRowset->SetQueryTag (queryTag) ;
  
  	// add the parameters ...
  	vtParam = (long) lngAcctid;
  	pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);
	
  	vtParam = bstrEmail;
  	pRowset->AddParam (MTPARAM_EMAIL, vtParam);
	
  	vtParam = (long)lngRetainCardInfo;
  	pRowset->AddParam (MTPARAM_RETAINCARDINFO, vtParam);
	
  	vtParam = lngRetryOnFailure ? (const char *)"1" : (const char *)"0";
  	pRowset->AddParam (MTPARAM_RETRYONFAILURE, vtParam);
 	
  	vtParam = (long) lngNumberRetries;
  	pRowset->AddParam (MTPARAM_NUMBERRETRIES, vtParam);
 	
  	vtParam = lngConfirmRequested ? (const char *)"1" : (const char *)"0";
  	pRowset->AddParam (MTPARAM_CONFIRMREQUESTED, vtParam);
 	
  	vtParam = (long) lngDelay;
  	pRowset->AddParam (MTPARAM_DELAY, vtParam);
 	
  	vtParam = lngBillEarly ? (const char *)"1" : (const char *)"0";
  	pRowset->AddParam (MTPARAM_BILLEARLY, vtParam);
 	
  	// add new row to table 
  	hr = pRowset->Execute();
  	if (FAILED(hr))
    	return hr;
	
  	pRowset->Clear();
	
  	hr = Audit(aSession,
             	pRowset,
             	lngAcctid,
             	(const char *)"add account",
             	(const char *)"",
             	(const char *)"",
             	(const char *)"",
             	(const char *)"",
             	(const char *)"",
             	0,
             	(const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
             	(const char *)"",                // phonenumber
             	(const char *)"",                // CSRIP
             	(const char *)"",                // CSRID
             	(const char *)"Initial insert of account data.");
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
   
  return hr;
}

HRESULT
MTPSAccountMgmt::CC_AddAccountAndPaymentMethodInternal(
                   MTPipelineLib::IMTSessionPtr aSession,
                   long                         alngCategory)
{
  _bstr_t         buffer;
  HRESULT         hr = S_OK;
  BOOL            blnMarkAsPrimary = FALSE;
  long            lngNumPaymentMethodsOnRecord = 0;

	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, 
										 "CC: Payment server add account starts");

  try
  {
    hr = LogAttempt(aSession, "CC_AddAccountAndPaymentMethodInternal", "add", alngCategory);
    if (FAILED(hr))
      return hr;

    if (mblnValidateOnAdd)
    {
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "CC: Validating Credit Card");
      hr = CC_ValidateCreditCard(aSession);
      if (FAILED(hr))
			{
				buffer = "Unable to validate credit card";
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
													 (const char*)buffer);
				return Error((const char*)buffer, IID_IMTPipelinePlugIn, hr);
	  	}
    }

    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);
 
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "CC: Deleting previous payment method");
    hr = CC_DeletePreviousPaymentMethod(aSession, pRowset);
    if (FAILED(hr))
		{
			buffer = "Unable to delete previous payment method";
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 (const char*)buffer);
			return Error((const char*)buffer, IID_IMTPipelinePlugIn, hr);
		}

    // this payment method automatically becomes the default 
    // if this is the first one for this subscriber

		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, 
											 "CC: Getting number of payment methods on record");
    hr = GetNumPaymentMethodsOnRecord(aSession, pRowset, &lngNumPaymentMethodsOnRecord);
    if (FAILED(hr))
		{
	  	buffer = "Unable to get number of payment methods on record";
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 (const char*)buffer);
			return Error((const char*)buffer, IID_IMTPipelinePlugIn, hr);
		}

    //
    // Only add to the account table if this is the very
    // first payment method.
    //
    if ((MT_BOTH == alngCategory) && (0 == lngNumPaymentMethodsOnRecord))
    {
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "CC: Adding account now");
      hr = AddAccount(aSession, pRowset);
			if (FAILED(hr))
	  	{
	  		buffer = "Payment Server :: Unable to add account";
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
													 (const char*)buffer);
				return Error((const char*)buffer, IID_IMTPipelinePlugIn, hr);
	  	}
    }

    // if no existing method on record, then this new method is the primary
    if (0 == lngNumPaymentMethodsOnRecord)
      blnMarkAsPrimary = TRUE;

		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, 
											 "CC: Adding payment method (internal)");
    hr = CC_AddPaymentMethodInternal(aSession, pRowset, blnMarkAsPrimary);
    if (FAILED(hr))
		{
			buffer = "Unable to add payment method (internal)";
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 (const char*)buffer);
			return Error((const char*)buffer, IID_IMTPipelinePlugIn, hr);
		}
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "CC: Payment server add account ends");

	return hr;
}

HRESULT
MTPSAccountMgmt::CC_AddPaymentMethodInternal(MTPipelineLib::IMTSessionPtr aSession,
                                             ROWSETLib::IMTSQLRowsetPtr   pRowset,
                                             BOOL                         ablnMarkAsPrimary)
{
	_bstr_t bstrStartdate;
	_bstr_t bstrIssuernumber;
	_bstr_t bstrCustname                = aSession->GetStringProperty(mlngCustomerName);
  _bstr_t bstrCcnum                   = aSession->GetStringProperty(mlngCreditCardNum);

  _bstr_t bstrCCSecCode;

  if (aSession->PropertyExists(mlngCreditCardSecCode, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
    bstrCCSecCode = aSession->GetStringProperty(mlngCreditCardSecCode);

  // Bakname is not required.
  _bstr_t bstrBankName;
  if (aSession->PropertyExists(mlngBankName, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
    bstrBankName = aSession->GetStringProperty(mlngBankName);

  long    lngAuthReceived             = aSession->GetLongProperty(mlngAuthReceived);
  long    lngAcctid                   = aSession->GetLongProperty(mlngAccountID);
  _bstr_t bstrAddr                    = aSession->GetStringProperty(mlngAddress);
  _bstr_t bstrCity                    = aSession->GetStringProperty(mlngCity);
  _bstr_t bstrState                   = aSession->GetStringProperty(mlngState);
  _bstr_t bstrZip                     = aSession->GetStringProperty(mlngZip);
  //country
  _bstr_t bstrCountry                 = GetCountryName(aSession->GetStringProperty(mlngCountry));
  long    lngCctype                   = aSession->GetLongProperty(mlngCreditCardType);
  _bstr_t bstrExpdate                 = aSession->GetStringProperty(mlngExpDate);
  long    lngExpdatef                 = aSession->GetLongProperty(mlngExpDateFormat);
  
	if(aSession->PropertyExists(mlngStartDate, MTPipelineLib::SESS_PROP_TYPE_STRING))
			bstrStartdate											= aSession->GetStringProperty(mlngStartDate);
		
	if(aSession->PropertyExists(mlngIssuerNumber, MTPipelineLib::SESS_PROP_TYPE_STRING))
	    bstrIssuernumber            = aSession->GetStringProperty(mlngIssuerNumber);
    
  _bstr_t bstrCardId                  = aSession->GetStringProperty(mlngCardId);
  _bstr_t bstrCardVerifyValue         = aSession->GetStringProperty(mlngCardVerifyValue);
  _bstr_t bstrCustomerReferenceId     = aSession->GetStringProperty(mlngCustomerReferenceId);
  _bstr_t bstrCustomerVatNumber       = aSession->GetStringProperty(mlngCustomerVatNumber);
  _bstr_t bstrCompanyAddress          = aSession->GetStringProperty(mlngCompanyAddress);
  _bstr_t bstrCompanyPostalCode       = aSession->GetStringProperty(mlngCompanyPostalCode);
  _bstr_t bstrCompanyPhone            = aSession->GetStringProperty(mlngCompanyPhone);
  _bstr_t bstrReserved1               = aSession->GetStringProperty(mlngReserved1);
  _bstr_t bstrReserved2               = aSession->GetStringProperty(mlngReserved2);

  string  lastfourdigits;
  HRESULT    hr = S_OK;
  _variant_t vtParam;
	_bstr_t decrypted;

  hr = FormatNumber(bstrCcnum, decrypted, lastfourdigits);
  if (FAILED(hr))
    return hr;

  // add lastfourdigits to the session for the InternalLookupCCByAcctidLast4Type() call
  aSession->SetStringProperty(mlngLastFourDigits, lastfourdigits.c_str());	

  // Perform lookup to make sure that duplicate is not inserted 	
  pRowset->ClearQuery();
  hr = InternalLookupCCByAcctidLast4Type(aSession, pRowset);
  if (FAILED(hr))
    return hr;

	int recordCount = pRowset->GetRecordCount();

	pRowset->Clear();

  if (recordCount > 0)
		return Error("Payment method already exists", IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_DUPLICATE_PAYMENT_METHOD);

  //
  // now store away the credit card specific data
  //

  pRowset->ClearQuery();

  _bstr_t queryTag = "__INSERT_T_PS_CREDITCARD_TABLE__" ;
  pRowset->SetQueryTag (queryTag) ;
      
  vtParam = bstrCustname;
  pRowset->AddParam (MTPARAM_CUSTOMERNAME, vtParam) ;

  vtParam = bstrCcnum;
  pRowset->AddParam (MTPARAM_CREDITCARDNUMBER, vtParam) ;

  std::wstring buffer;
  _variant_t vtSecCode;
  if(bstrCCSecCode.length() > 0)
    vtSecCode = bstrCCSecCode;
    
	FormatValueForDB(vtSecCode, FALSE, buffer);
  _variant_t vtFormattedSecCode = buffer.c_str();

  pRowset->AddParam (L"%%CREDIT_CARD_SECCODE%%", vtFormattedSecCode, VARIANT_TRUE);

  vtParam = bstrBankName;
  pRowset->AddParam (MTPARAM_BANKNAME, vtParam) ;

  vtParam = (TRUE == ablnMarkAsPrimary) ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;

  vtParam = (const char *)"1";
  pRowset->AddParam (MTPARAM_ENABLED, vtParam) ;

  vtParam = lngAuthReceived ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_AUTHRECEIVED, vtParam);
 
  vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;

  vtParam = bstrAddr;
  pRowset->AddParam (MTPARAM_ADDRESS, vtParam) ;

  vtParam = bstrCity;
  pRowset->AddParam (MTPARAM_CITY, vtParam) ;

  vtParam = bstrState;
  pRowset->AddParam (MTPARAM_STATE, vtParam) ;

  vtParam = bstrZip;
  pRowset->AddParam (MTPARAM_ZIP, vtParam) ;

  vtParam = bstrCountry;
  pRowset->AddParam (MTPARAM_COUNTRY, vtParam) ;

  vtParam = (long) lngCctype;
  pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
      
  vtParam = lastfourdigits.c_str();
  pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
      
  vtParam = bstrExpdate;
  pRowset->AddParam (MTPARAM_EXPDATE, vtParam) ;

  vtParam = (long) lngExpdatef;
  pRowset->AddParam (MTPARAM_EXPDATEFORMAT, vtParam) ;

  vtParam.ChangeType(VT_NULL);
	if(bstrStartdate.length() > 0)
		vtParam = bstrStartdate;
	// g. cieplik 4/17/2008 CR 15515 MTPARAM_STARTDATE is a optional field, to set these fields to a logical NULL call "AddParam" with the optional "VARIANT_TRUE" parameter and remove single quotes around this field in queries.xml
    pRowset->AddParam (MTPARAM_STARTDATE, vtParam, VARIANT_TRUE) ;

  vtParam.ChangeType(VT_NULL);
	if(bstrIssuernumber.length() > 0)
		vtParam = bstrIssuernumber;
	// g. cieplik 4/17/2008 CR 15515 MTPARAM_ISSUERNUMBER is a optional field, to set these fields to a logical NULL call "AddParam" with the optional "VARIANT_TRUE" parameter and remove single quotes around this field in queries.xml
	pRowset->AddParam (MTPARAM_ISSUERNUMBER, vtParam, VARIANT_TRUE) ;

  vtParam = bstrCardId;
  pRowset->AddParam (MTPARAM_CARDID, vtParam) ;

  vtParam = bstrCardVerifyValue;
  pRowset->AddParam (MTPARAM_CARDVERIFYVALUE, vtParam) ;

  // defined as a varchar in the database
  _bstr_t bstrPcard("0");

  _bstr_t bstrEnum = mEnumConfig->GetEnumeratorByID(lngCctype);
  char chrEnum[50];

  strcpy(chrEnum, (const char *)bstrEnum);
  // g. cieplik 12/12/07 add processing for Maestro debit cards
  if ((0 == stricmp(chrEnum, "Visa - Purchase Card"))                 ||
      (0 == stricmp(chrEnum, "MasterCard - Purchase Card"))           ||
      (0 == stricmp(chrEnum, "American Express - Purchase Card"))     ||
      (0 == stricmp(chrEnum, "Visa - Purchase card Intl"))            ||
      (0 == stricmp(chrEnum, "MasterCard - Purchase Card Intl"))      ||
      (0 == stricmp(chrEnum, "American Express - Purchase Card Intl"))	||
	  (0 == stricmp(chrEnum, "Maestro")))
  {
    bstrPcard = (const char *)"1";
  }

  vtParam = bstrPcard;
  pRowset->AddParam (MTPARAM_PCARD, vtParam) ;

  // add new row to t_ps_creditcard 
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();



  //
  // Now store away the purchase card specific data.  
  //

  pRowset->ClearQuery();

  if (_bstr_t("1") == bstrPcard)
  {
    // set the query tag ...
    _bstr_t queryTag = "__INSERT_T_PS_PCARD_TABLE__" ;
    pRowset->SetQueryTag (queryTag) ;
      
    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

    vtParam = (long) lngCctype;
    pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam);
      
    vtParam = lastfourdigits.c_str();
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
      
    vtParam = bstrCustomerReferenceId;
    pRowset->AddParam (MTPARAM_CUSTOMERREFERENCEID, vtParam) ;

    vtParam = bstrCustomerVatNumber;
    pRowset->AddParam (MTPARAM_CUSTOMERVATNUMBER, vtParam) ;

    vtParam = bstrCompanyAddress;
    pRowset->AddParam (MTPARAM_COMPANYADDRESS, vtParam) ;

    vtParam = bstrCompanyPostalCode;
    pRowset->AddParam (MTPARAM_COMPANYPOSTALCODE, vtParam) ;

    vtParam = bstrCompanyPhone;
    pRowset->AddParam (MTPARAM_COMPANYPHONE, vtParam) ;

    vtParam = bstrReserved1;
    pRowset->AddParam (MTPARAM_RESERVED1, vtParam) ;

    vtParam = bstrReserved2;
    pRowset->AddParam (MTPARAM_RESERVED2, vtParam) ;

    // add new row to table 
    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;

    pRowset->Clear();
  }

  //
  // update the payment scheduler table in case it's affected
  //

  pRowset->ClearQuery();

  pRowset->SetQueryTag ("__UPDATE_PAYMENT_SCHEDULER__") ;

  vtParam = lastfourdigits.c_str();
  pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;

  vtParam = (long) lngCctype;
  pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;

  vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;

	// add new row to table 
	hr = pRowset->Execute();
	if (FAILED(hr))
		return hr;

	pRowset->Clear();


  hr = Audit(aSession,
             pRowset,
             lngAcctid,
             (const char *)"add credit card account",
             (const char *)"",
             (const char *)lastfourdigits.c_str(),
             (const char *)GetEnumName(lngCctype),
             (const char *)"",
             (const char *)bstrExpdate,
             lngExpdatef,
             (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
             (const char *)"",                // phonenumber
             (const char *)"",                // CSRIP
             (const char *)"",                // CSRID
             (const char *)"");
          
  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_AddAccountAndPaymentMethodInternal(
                   MTPipelineLib::IMTSessionPtr aSession,
                   long                         alngCategory)
{
  
  HRESULT         hr = S_OK;
  BOOL            blnMarkAsPrimary = FALSE;
  long            lngNumPaymentMethodsOnRecord = 0;

  try
  {
    hr = LogAttempt(aSession, "ACH_AddAccountAndPaymentMethodInternal", "add", alngCategory);
    if (FAILED(hr))
      return hr;

    if (mblnValidateOnAdd)
    {
      hr = ACH_ValidateBankInfo(aSession);
      if (FAILED(hr))
        return hr;
    }

    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

    hr = ACH_DeletePreviousPaymentMethod(aSession, pRowset);
    if (FAILED(hr))
      return hr;

    // this payment method automatically becomes the default 
    // if this is the first one for this subscriber

    hr = GetNumPaymentMethodsOnRecord(aSession, pRowset, &lngNumPaymentMethodsOnRecord);
    if (FAILED(hr))
      return hr;

    //
    // Only add to the account table if this is the very
    // first payment method.
    //
    if ((MT_BOTH == alngCategory) && (0 == lngNumPaymentMethodsOnRecord))
    {
      hr = AddAccount(aSession, pRowset);
      if (FAILED(hr))
        return hr;
    }

    // if no existing method on record, then this new method is the primary
    if (0 == lngNumPaymentMethodsOnRecord)
      blnMarkAsPrimary = TRUE;

    hr = ACH_AddPaymentMethodInternal(aSession, pRowset, blnMarkAsPrimary);
    if (FAILED(hr))
      return hr;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	return hr;
}

HRESULT
MTPSAccountMgmt::ACH_AddPaymentMethodInternal(MTPipelineLib::IMTSessionPtr aSession,
                                              ROWSETLib::IMTSQLRowsetPtr   pRowset,
                                              BOOL                         ablnMarkAsPrimary)
{
  _bstr_t bstrCustname               = aSession->GetStringProperty(mlngCustomerName);
  _bstr_t bstrRoutingNumber          = aSession->GetStringProperty(mlngRoutingNumber);
  _bstr_t bstrBankAccountNumber      = aSession->GetStringProperty(mlngBankAccountNumber);
  long    lngAccountType             = aSession->GetLongProperty(mlngAccountType);
  long    lngAuthReceived            = aSession->GetLongProperty(mlngAuthReceived);
  long    lngAcctid                  = aSession->GetLongProperty(mlngAccountID);
  _bstr_t bstrAddr                   = aSession->GetStringProperty(mlngAddress);
  _bstr_t bstrCity                   = aSession->GetStringProperty(mlngCity);
  _bstr_t bstrState                  = aSession->GetStringProperty(mlngState);
  _bstr_t bstrZip                    = aSession->GetStringProperty(mlngZip);
  //country
  _bstr_t bstrCountry                = GetCountryName(aSession->GetStringProperty(mlngCountry));
  _bstr_t bstrBankName               = aSession->GetStringProperty(mlngBankName);
  _bstr_t bstrReserved1              = aSession->GetStringProperty(mlngReserved1);
  _bstr_t bstrReserved2              = aSession->GetStringProperty(mlngReserved2);

  string  lastfourdigits;
  HRESULT    hr = S_OK;
  _variant_t vtParam;
	_bstr_t decrypted;

  hr = FormatNumber(bstrBankAccountNumber, decrypted, lastfourdigits);
  if (FAILED(hr))
    return hr;
  
  // add lastfourdigits to the session for the InternalLookupACHByAcctidRoutingNumberLast4Type() call
  aSession->SetStringProperty(mlngLastFourDigits, lastfourdigits.c_str());	

  // Perform lookup to make sure that duplicate is not inserted 	
  pRowset->ClearQuery();
  hr = InternalLookupACHByAcctidRoutingNumberLast4Type(aSession, pRowset);
  if (FAILED(hr))
    return hr;

	int recordCount = pRowset->GetRecordCount();

	pRowset->Clear();

  if (recordCount > 0)
		return Error("Payment method already exists", IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_DUPLICATE_PAYMENT_METHOD);

  //
  // now store away the bank account specific data
  //

  pRowset->ClearQuery();

  // set the query tag ...
  _bstr_t queryTag = "__INSERT_T_PS_ACH_TABLE__" ;
  pRowset->SetQueryTag (queryTag) ;
        
  vtParam = bstrCustname;
  pRowset->AddParam (MTPARAM_CUSTOMERNAME, vtParam) ;
  
  vtParam = bstrRoutingNumber;
  pRowset->AddParam (MTPARAM_ROUTINGNUMBER, vtParam) ;
        
  vtParam = bstrBankAccountNumber;
  pRowset->AddParam (MTPARAM_ACCOUNTNUMBER, vtParam) ;
      
  vtParam = (long)lngAccountType;
  pRowset->AddParam (MTPARAM_ACCOUNTTYPE, vtParam) ;

  vtParam = (TRUE == ablnMarkAsPrimary) ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;

  vtParam = (const char *)"1";
  pRowset->AddParam (MTPARAM_ENABLED, vtParam) ;

  vtParam = lngAuthReceived ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_AUTHRECEIVED, vtParam);
 
  vtParam = (const char *)"0";
  pRowset->AddParam (MTPARAM_VALIDATED, vtParam);
 
  vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

  vtParam = bstrAddr;
  pRowset->AddParam (MTPARAM_ADDRESS, vtParam);
  
  vtParam = bstrCity;
  pRowset->AddParam (MTPARAM_CITY, vtParam);
  
  vtParam = bstrState;
  pRowset->AddParam (MTPARAM_STATE, vtParam);
  
  vtParam = bstrZip;
  pRowset->AddParam (MTPARAM_ZIP, vtParam);
  
  vtParam = bstrCountry;
  pRowset->AddParam (MTPARAM_COUNTRY, vtParam);

  vtParam = bstrBankName;
  pRowset->AddParam (MTPARAM_BANKNAME, vtParam);
        
  vtParam = lastfourdigits.c_str();
  pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam);
        
  vtParam = bstrReserved1;
  pRowset->AddParam (MTPARAM_RESERVED1, vtParam);

  vtParam = bstrReserved2;
  pRowset->AddParam (MTPARAM_RESERVED2, vtParam);

  // add new row to t_ps_creditcard 
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();

  hr = Audit(aSession,
             pRowset,
             lngAcctid,
             (const char *)"add ACH account",
             (const char *)bstrRoutingNumber,
             (const char *)lastfourdigits.c_str(),
             (const char *)GetEnumName(lngAccountType),
             (const char *)bstrBankName,
             (const char *)"",
             0,
             (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
             (const char *)"",                // phonenumber
             (const char *)"",                // CSRIP
             (const char *)"",                // CSRID
             (const char *)"");

  return hr;
}

//
// Update methods
//

//
// This method does not allow updating of:
//   account id 
//

HRESULT
MTPSAccountMgmt::UpdateAccount(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT   hr = S_OK;

  try
  {
    hr = LogAttempt(aSession, "UpdateAccount", "update", MT_ACCOUNT);
    if (FAILED(hr))
      return hr;

    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

    hr = UpdateAccountInternal(aSession, pRowset);
    if (FAILED(hr))
      return hr;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	return hr;
}

HRESULT
MTPSAccountMgmt::CC_UpdatePaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT   hr = S_OK;

  try
  {
    
		IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

    //
    // Retrieve the stored credit card number to use in validation. 
    //

    hr = InternalLookupCCByAcctidLast4Type(aSession, pRowset);
    if (FAILED(hr))
      return hr;
 
    if (pRowset->GetRowsetEOF())
		  return Error("Payment method does not exist.", 
                   IID_IMTPipelinePlugIn,
                   CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);

    if (mblnValidateOnUpdate)
    {
      hr = CC_ValidateCreditCard(aSession);
      if (FAILED(hr))
        return hr;
    }

    hr = LogAttempt(aSession, "CC_UpdatePaymentMethodInternal", "update", MT_PAYMENTMETHOD);
    if (FAILED(hr))
      return hr;

    hr = CC_UpdatePaymentMethodInternal(aSession, pRowset);
    if (FAILED(hr))
      return hr;
  }
  catch (_com_error & err)
  {
    _bstr_t message = err.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	return hr;
}

HRESULT
MTPSAccountMgmt::CC_UpdatePrimaryIndicator(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = UpdatePrimaryIndicator(aSession, MT_CREDITCARD);
  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_UpdatePaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT   hr = S_OK;

  try
  {
    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

    //
    // Retrieve the stored credit card number to use in validation. 
    //
    hr = InternalLookupACHByAcctidRoutingNumberLast4Type(aSession, pRowset);
    if (FAILED(hr))
      return hr;

    if (pRowset->GetRowsetEOF())
		  return Error("Payment method does not exist.", 
                   IID_IMTPipelinePlugIn,
                   CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);

    if (mblnValidateOnUpdate)
    {
      hr = ACH_ValidateBankInfo(aSession);
      if (FAILED(hr))
        return hr;
    }

    hr = LogAttempt(aSession, "ACH_UpdatePaymentMethodInternal", "update", MT_PAYMENTMETHOD);
    if (FAILED(hr))
      return hr;

    hr = ACH_UpdatePaymentMethodInternal(aSession, pRowset);
    if (FAILED(hr))
      return hr;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	return hr;
}

HRESULT
MTPSAccountMgmt::ACH_UpdatePrimaryIndicator(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = UpdatePrimaryIndicator(aSession, MT_ACH);
  return hr;
}

HRESULT 
MTPSAccountMgmt::UpdateAccountInternal(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr pRowset)
{
  long    lngAcctid           = aSession->GetLongProperty(mlngAccountID);
  long    lngRetainCardInfo   = aSession->GetLongProperty(mlngRetainCardInfo);
  long    lngRetryOnFailure   = aSession->GetLongProperty(mlngRetryOnFailure);
  long    lngNumberRetries    = aSession->GetLongProperty(mlngNumberRetries);
  long    lngConfirmRequested = aSession->GetLongProperty(mlngConfirmRequested);
  long    lngDelay            = aSession->GetLongProperty(mlngDelay);
  long    lngBillEarly        = aSession->GetLongProperty(mlngBillEarly);
  HRESULT hr = S_OK;

	// email address is optional
  _bstr_t bstrEmail;
	if (aSession->PropertyExists(mlngEmail,
															 MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
		bstrEmail									= aSession->GetStringProperty(mlngEmail);
	else
		bstrEmail									= "";



  //
  // update t_ps_account
  //

  pRowset->ClearQuery();

  _bstr_t queryTag = "__UPDATE_T_PS_ACCOUNT_TABLE__";
  pRowset->SetQueryTag (queryTag) ;
  
  //
  // properties that identify the row to update
  //
  _variant_t vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
        
  //
  // columns to update 
  //
  vtParam = bstrEmail;
  pRowset->AddParam (MTPARAM_EMAIL, vtParam) ;
  
  vtParam = (long) lngRetainCardInfo;
  pRowset->AddParam (MTPARAM_RETAINCARDINFO, vtParam) ;

  vtParam = lngRetryOnFailure ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_RETRYONFAILURE, vtParam);
 
  vtParam = (long) lngNumberRetries;
  pRowset->AddParam (MTPARAM_NUMBERRETRIES, vtParam);
 
  vtParam = lngConfirmRequested ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_CONFIRMREQUESTED, vtParam);
 
  vtParam = (long) lngDelay;
  pRowset->AddParam (MTPARAM_DELAY, vtParam);
 
  vtParam = lngBillEarly ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_BILLEARLY, vtParam);
 
  // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();

  hr = Audit(aSession,
             pRowset,
             lngAcctid,
             (const char *)"update account",
             (const char *)"",
             (const char *)"",
             (const char *)"",
             (const char *)"",
             (const char *)"",
             0,
             (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
             (const char *)"",                // phonenumber
             (const char *)"",                // CSRIP
             (const char *)"",                // CSRID
             (const char *)"");

  return hr;
}

//
// This method does not allow updating of:
//   credit card number 
//   last four digits
//   credit card type
//

HRESULT
MTPSAccountMgmt::CC_UpdatePaymentMethodInternal(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  // properties used to search and can not be updated
  _bstr_t bstrStartdate;
	_bstr_t bstrIssuernumber;
	
	long    lngAcctid               = aSession->GetLongProperty(mlngAccountID);
  _bstr_t bstrLastFourDigits      = aSession->GetStringProperty(mlngLastFourDigits);
  long    lngCctype               = aSession->GetLongProperty(mlngCreditCardType);

  // updatable properties - standard cc
  _bstr_t bstrCustname            = aSession->GetStringProperty(mlngCustomerName);
  _bstr_t bstrAddr                = aSession->GetStringProperty(mlngAddress);
  _bstr_t bstrCity                = aSession->GetStringProperty(mlngCity);
  _bstr_t bstrState               = aSession->GetStringProperty(mlngState);
  _bstr_t bstrZip                 = aSession->GetStringProperty(mlngZip);
  //country
  _bstr_t bstrCountry             = GetCountryName(aSession->GetStringProperty(mlngCountry));
  _bstr_t bstrExpdate             = aSession->GetStringProperty(mlngExpDate);
  long    lngExpdatef             = aSession->GetLongProperty(mlngExpDateFormat);
  
	if(aSession->PropertyExists(mlngStartDate, MTPipelineLib::SESS_PROP_TYPE_STRING))
			bstrStartdate											= aSession->GetStringProperty(mlngStartDate);
		
	if(aSession->PropertyExists(mlngIssuerNumber, MTPipelineLib::SESS_PROP_TYPE_STRING))
	    bstrIssuernumber            = aSession->GetStringProperty(mlngIssuerNumber);
  
	_bstr_t bstrCardId              = aSession->GetStringProperty(mlngCardId);
  _bstr_t bstrCardVerifyValue     = aSession->GetStringProperty(mlngCardVerifyValue);
  long    lngPrimary              = aSession->GetLongProperty(mlngPrimary);
  long    lngEnabled              = aSession->GetLongProperty(mlngEnabled);
  long    lngAuthReceived         = aSession->GetLongProperty(mlngAuthReceived);

  // updateable properties - purchase card
  _bstr_t bstrCustomerReferenceId = aSession->GetStringProperty(mlngCustomerReferenceId);
  _bstr_t bstrCustomerVatNumber   = aSession->GetStringProperty(mlngCustomerVatNumber);
  _bstr_t bstrCompanyAddress      = aSession->GetStringProperty(mlngCompanyAddress);
  _bstr_t bstrCompanyPostalCode   = aSession->GetStringProperty(mlngCompanyPostalCode);
  _bstr_t bstrCompanyPhone        = aSession->GetStringProperty(mlngCompanyPhone);
  _bstr_t bstrReserved1;
  if (aSession->PropertyExists(mlngReserved1, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
	bstrReserved1 = aSession->GetStringProperty(mlngReserved1);
  _bstr_t bstrReserved2;
  if (aSession->PropertyExists(mlngReserved2, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
	bstrReserved2 = aSession->GetStringProperty(mlngReserved2);

  _variant_t vtParam;
  HRESULT    hr = S_OK;

  //
  // Modifying the primary method has it's own set of rules. 
  //
  if (1 == lngPrimary)
  {
    hr = UpdatePrimaryIndicatorInternal(aSession, pRowset, 0);
    if (FAILED(hr))
      return hr;
  }

  pRowset->ClearQuery();

  _bstr_t queryTag = "__UPDATE_T_PS_CREDITCARD_TABLE__";
  pRowset->SetQueryTag (queryTag) ;

  //
  // properties that identify the row to update
  //
  vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
        
  vtParam = (long) lngCctype;
  pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
        
  vtParam = bstrLastFourDigits;
  pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
  
  //
  // columns to update 
  //

  vtParam = bstrCustname;
  pRowset->AddParam (MTPARAM_CUSTOMERNAME, vtParam) ;
  
  vtParam = bstrAddr;
  pRowset->AddParam (MTPARAM_ADDRESS, vtParam) ;
  
  vtParam = bstrCity;
  pRowset->AddParam (MTPARAM_CITY, vtParam) ;
  
  vtParam = bstrState;
  pRowset->AddParam (MTPARAM_STATE, vtParam) ;
  
  vtParam = bstrZip;
  pRowset->AddParam (MTPARAM_ZIP, vtParam) ;
  
  vtParam = bstrCountry;
  pRowset->AddParam (MTPARAM_COUNTRY, vtParam) ;
  
  vtParam = bstrExpdate;
  pRowset->AddParam (MTPARAM_EXPDATE, vtParam) ;
  
  vtParam = (long) lngExpdatef;
  pRowset->AddParam (MTPARAM_EXPDATEFORMAT, vtParam) ;
  
  vtParam.ChangeType(VT_NULL);
	if(bstrStartdate.length() > 0)
		vtParam = bstrStartdate;
  // g. cieplik 4/17/2008 CR 15515 MTPARAM_STARTDATE is a optional field, to set these fields to a logical NULL call "AddParam" with the optional "VARIANT_TRUE" parameter and remove single quotes around this field in queries.xml
  pRowset->AddParam (MTPARAM_STARTDATE, vtParam, VARIANT_TRUE) ;

  vtParam.ChangeType(VT_NULL);
	if(bstrIssuernumber.length() > 0)
		vtParam = bstrIssuernumber;
  // g. cieplik 4/17/2008 CR 15515 MTPARAM_ISSUERNUMBER is a optional field, to set these fields to a logical NULL call "AddParam" with the optional "VARIANT_TRUE" parameter and remove single quotes around this field in queries.xml
  pRowset->AddParam (MTPARAM_ISSUERNUMBER, vtParam, VARIANT_TRUE) ;
  
  vtParam = bstrCardId;
  pRowset->AddParam (MTPARAM_CARDID, vtParam) ;
  
  vtParam = bstrCardVerifyValue;
  pRowset->AddParam (MTPARAM_CARDVERIFYVALUE, vtParam) ;

  vtParam = lngEnabled ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_ENABLED, vtParam) ;

  vtParam = lngAuthReceived ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_AUTHRECEIVED, vtParam) ;

    // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();

  //
  // update  t_ps_pcard if necessary
  //

  _bstr_t bstrEnum = mEnumConfig->GetEnumeratorByID(lngCctype);
  char chrEnum[50];

  strcpy(chrEnum, (const char *)bstrEnum);
  // g. cieplik 12/12/07 add processing for Maestro debit cards
  if ((0 == stricmp(chrEnum, "Visa - Purchase Card"))                 ||
      (0 == stricmp(chrEnum, "MasterCard - Purchase Card"))           ||
      (0 == stricmp(chrEnum, "American Express - Purchase Card"))     ||
      (0 == stricmp(chrEnum, "Visa - Purchase card Intl"))            ||
      (0 == stricmp(chrEnum, "MasterCard - Purchase Card Intl"))      ||
      (0 == stricmp(chrEnum, "American Express - Purchase Card Intl")) ||
	  (0 == stricmp(chrEnum, "Maestro")))
  {
    pRowset->ClearQuery();

    queryTag = "__UPDATE_T_PS_PCARD_TABLE__";
    pRowset->SetQueryTag (queryTag) ;

    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
    vtParam = (long) lngCctype;
    pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
      
    vtParam = bstrLastFourDigits;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
      
    //
    // columns to update 
    //
    vtParam = bstrCustomerReferenceId;
    pRowset->AddParam (MTPARAM_CUSTOMERREFERENCEID, vtParam) ;
  
    vtParam = bstrCustomerVatNumber;
    pRowset->AddParam (MTPARAM_CUSTOMERVATNUMBER, vtParam) ;

    vtParam = bstrCompanyAddress;
    pRowset->AddParam (MTPARAM_COMPANYADDRESS, vtParam) ;

    vtParam = bstrCompanyPostalCode;
    pRowset->AddParam (MTPARAM_COMPANYPOSTALCODE, vtParam) ;

    vtParam = bstrCompanyPhone;
    pRowset->AddParam (MTPARAM_COMPANYPHONE, vtParam) ;

    vtParam = bstrReserved1;
    pRowset->AddParam (MTPARAM_RESERVED1, vtParam) ;

    vtParam = bstrReserved2;
    pRowset->AddParam (MTPARAM_RESERVED2, vtParam) ;

    hr = pRowset->Execute();
      return hr;

    pRowset->Clear();
  }

  hr = Audit(aSession,
             pRowset,
             lngAcctid,
             (const char *)"update payment method",
             (const char *)"",
             (const char *)bstrLastFourDigits,
             (const char *)GetEnumName(lngCctype),
             (const char *)"",
             (const char *)bstrExpdate,
             lngExpdatef,
             (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
             (const char *)"",                // phonenumber
             (const char *)"",                // CSRIP
             (const char *)"",                // CSRID
             (const char *)"credit card");

  return hr;
}

//
// This method does not allow updating of:
//   routing number 
//   bank account number 
//   last four digits
//   account type
//

HRESULT
MTPSAccountMgmt::ACH_UpdatePaymentMethodInternal(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  // properties used to search and can not be updated
  long    lngAcctid               = aSession->GetLongProperty(mlngAccountID);
  _bstr_t bstrRoutingNumber       = aSession->GetStringProperty(mlngRoutingNumber);
  _bstr_t bstrLastFourDigits      = aSession->GetStringProperty(mlngLastFourDigits);
  long    lngAccountType          = aSession->GetLongProperty(mlngAccountType);

  // updatable properties
  _bstr_t bstrCustname            = aSession->GetStringProperty(mlngCustomerName);
  _bstr_t bstrAddr                = aSession->GetStringProperty(mlngAddress);
  _bstr_t bstrCity                = aSession->GetStringProperty(mlngCity);
  _bstr_t bstrState               = aSession->GetStringProperty(mlngState);
  _bstr_t bstrZip                 = aSession->GetStringProperty(mlngZip);
  //country
  _bstr_t bstrCountry             = GetCountryName(aSession->GetStringProperty(mlngCountry));
  _bstr_t bstrBankName            = aSession->GetStringProperty(mlngBankName);
  _bstr_t bstrReserved1           = aSession->GetStringProperty(mlngReserved1);
  _bstr_t bstrReserved2           = aSession->GetStringProperty(mlngReserved2);
  long    lngPrimary              = aSession->GetLongProperty(mlngPrimary);
  long    lngEnabled              = aSession->GetLongProperty(mlngEnabled);
  long    lngValidated            = aSession->GetLongProperty(mlngValidated);
  long    lngAuthReceived         = aSession->GetLongProperty(mlngAuthReceived);

  _variant_t vtParam;
  HRESULT    hr = S_OK;

  //
  // Modifying the primary method has it's own set of rules. 
  //
  if (1 == lngPrimary)
  {
    hr = UpdatePrimaryIndicatorInternal(aSession, pRowset, 1);
    if (FAILED(hr))
      return hr;
  }

  pRowset->ClearQuery();

  _bstr_t queryTag = "__UPDATE_T_PS_ACH_TABLE__";
  pRowset->SetQueryTag (queryTag) ;

  //
  // properties that identify the row to update
  //
  vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
        
  vtParam = bstrRoutingNumber;
  pRowset->AddParam (MTPARAM_ROUTINGNUMBER, vtParam) ;

  vtParam = bstrLastFourDigits;
  pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
  
  vtParam = (long) lngAccountType;
  pRowset->AddParam (MTPARAM_ACCOUNTTYPE, vtParam) ;
        
  //
  // columns to update 
  //

  vtParam = bstrCustname;
  pRowset->AddParam (MTPARAM_CUSTOMERNAME, vtParam) ;
  
  vtParam = bstrAddr;
  pRowset->AddParam (MTPARAM_ADDRESS, vtParam) ;
  
  vtParam = bstrCity;
  pRowset->AddParam (MTPARAM_CITY, vtParam) ;
  
  vtParam = bstrState;
  pRowset->AddParam (MTPARAM_STATE, vtParam) ;
  
  vtParam = bstrZip;
  pRowset->AddParam (MTPARAM_ZIP, vtParam) ;
  
  vtParam = bstrCountry;
  pRowset->AddParam (MTPARAM_COUNTRY, vtParam) ;
  
  vtParam = bstrBankName;
  pRowset->AddParam (MTPARAM_BANKNAME, vtParam) ;
  
  vtParam = bstrReserved1;
  pRowset->AddParam (MTPARAM_RESERVED1, vtParam) ;

  vtParam = bstrReserved2;
  pRowset->AddParam (MTPARAM_RESERVED2, vtParam) ;

  vtParam = lngEnabled ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_ENABLED, vtParam) ;

  vtParam = lngValidated ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_VALIDATED, vtParam) ;

  vtParam = lngAuthReceived ? (const char *)"1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_AUTHRECEIVED, vtParam) ;

  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();

  hr = Audit(aSession,
             pRowset,
             lngAcctid,
             (const char *)"update payment method",
             (const char *)bstrRoutingNumber,
             (const char *)bstrLastFourDigits,
             (const char *)GetEnumName(lngAccountType),
             (const char *)bstrBankName,
             (const char *)"",
             0,
             (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
             (const char *)"",                // phonenumber
             (const char *)"",                // CSRIP
             (const char *)"",                // CSRID
             (const char *)"ACH");

  return hr;
}

HRESULT
MTPSAccountMgmt::UpdatePrimaryIndicator(
                   MTPipelineLib::IMTSessionPtr aSession,
                   long                         alngPaymentMethodType)
{
  HRESULT   hr = S_OK;

  try
  {
    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

    hr = LogAttempt(aSession, "UpdatePrimaryIndicator", "update");
    if (FAILED(hr))
      return hr;
    hr = UpdatePrimaryIndicatorInternal(aSession, pRowset, alngPaymentMethodType);
    if (FAILED(hr))
      return hr;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	return hr;
}

//
// This method does not allow updating of:
//   primary payment method indicator
//

HRESULT
MTPSAccountMgmt::UpdatePrimaryIndicatorInternal(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset,
                   long                         alngPaymentMethodType)
{
  // properties used to search and can not be updated
  long    lngAcctid;
  _bstr_t bstrLastFourDigits;
  _bstr_t bstrRoutingNumber;
  long    lngAccountType;
  long    lngCreditCardType;

  lngAcctid           = aSession->GetLongProperty(mlngAccountID);
  bstrLastFourDigits  = aSession->GetStringProperty(mlngLastFourDigits);

  if (MT_ACH == alngPaymentMethodType)
  {
    bstrRoutingNumber = aSession->GetStringProperty(mlngRoutingNumber);
    lngAccountType    = aSession->GetLongProperty(mlngAccountType);
  }
  else if (MT_CREDITCARD == alngPaymentMethodType)
  {
    lngCreditCardType = aSession->GetLongProperty(mlngCreditCardType);
  }
  else
  {
    // Put some error checking here.
  }

  // used to store the current primary payment method
  _bstr_t bstrCurrentLastFourDigits;
  _bstr_t bstrCurrentRoutingNumber;
  long    lngCurrentAccountType;
  long    lngCurrentCreditCardType;

  HRESULT hr = S_OK;

  //
  // Search for the payment method that is already the primary
  //

  BOOL blnPrimaryFound;

  hr = CC_GetPrimary(pRowset, lngAcctid, blnPrimaryFound, 
                     bstrCurrentLastFourDigits, lngCurrentCreditCardType);
  if (FAILED(hr))
    return hr;
 
  if (blnPrimaryFound)
  {
    // the current primary is credit card.

    hr = CC_UpdatePrimaryIndicatorInternal(pRowset,
                                           lngAcctid, 
                                           bstrCurrentLastFourDigits, 
                                           lngCurrentCreditCardType,
                                           0);  
    if (FAILED(hr))
      return hr;
  }

  hr = ACH_GetPrimary(pRowset, lngAcctid, blnPrimaryFound, bstrCurrentRoutingNumber,
                      bstrCurrentLastFourDigits, lngCurrentAccountType);
  if (FAILED(hr))
    return hr;
 
  if (blnPrimaryFound)
  {
    hr = ACH_UpdatePrimaryIndicatorInternal(pRowset,
                                            lngAcctid, 
                                            bstrCurrentRoutingNumber, 
                                            bstrCurrentLastFourDigits, 
                                            lngCurrentAccountType,
                                            0);  
  }

  if (MT_CREDITCARD == alngPaymentMethodType)
  {
    hr = CC_UpdatePrimaryIndicatorInternal(pRowset,
                                           lngAcctid, 
                                           bstrLastFourDigits, 
                                           lngCreditCardType,
                                           1);  
    if (FAILED(hr))
      return hr;

    hr = Audit(aSession,
               pRowset,
               lngAcctid,
               (const char *)"update primary indicator",
               (const char *)"",
               (const char *)bstrLastFourDigits,
               (const char *)GetEnumName(lngCreditCardType),
               (const char *)"",
               (const char *)"",
               0,
               (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
               (const char *)"",                // phonenumber
               (const char *)"",                // CSRIP
               (const char *)"",                // CSRID
               (const char *)"This payment method is now the primary.");
  }
  else
  {
    hr = ACH_UpdatePrimaryIndicatorInternal(pRowset,
                                            lngAcctid, 
                                            bstrRoutingNumber, 
                                            bstrLastFourDigits, 
                                            lngAccountType,
                                            1);  
    if (FAILED(hr))
      return hr;

    hr = Audit(aSession,
               pRowset,
               lngAcctid,
               (const char *)"update primary indicator",
               (const char *)bstrRoutingNumber,
               (const char *)bstrLastFourDigits,
               (const char *)GetEnumName(lngAccountType),
               (const char *)"",
               (const char *)"",
               0,
               (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
               (const char *)"",                // phonenumber
               (const char *)"",                // CSRIP
               (const char *)"",                // CSRID
               (const char *)"This payment method is now the primary.");
  }

  return hr;
}

HRESULT
MTPSAccountMgmt::CC_UpdatePrimaryIndicatorInternal(
                   ROWSETLib::IMTSQLRowsetPtr   pRowset,
                   long                         lngAcctid,
                   _bstr_t                      bstrLastFourDigits,
                   long                         lngCreditCardType,
                   BOOL                         blnPrimary)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  pRowset->ClearQuery();

  // set the query tag ...
  _bstr_t queryTag = "__UPDATE_PRIMARY_IN_CREDITCARD_TABLE__";
  pRowset->SetQueryTag (queryTag) ;

  // add the parameters ...
  vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
  vtParam = bstrLastFourDigits;
  pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
      
  vtParam = (long) lngCreditCardType;
  pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
      
  // add the parameters ...
  vtParam = blnPrimary ? (const char *) "1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
      
  // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();

  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_UpdatePrimaryIndicatorInternal(
                   ROWSETLib::IMTSQLRowsetPtr   pRowset,
                   long                         lngAcctid,
                   _bstr_t                      bstrRoutingNumber,
                   _bstr_t                      bstrLastFourDigits,
                   long                         lngAccountType,
                   BOOL                         blnPrimary)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  pRowset->ClearQuery();

  // set the query tag ...
  _bstr_t queryTag = "__UPDATE_PRIMARY_IN_ACH_TABLE__";
  pRowset->SetQueryTag (queryTag) ;

  // add the parameters ...
  vtParam = (long) lngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
  vtParam = bstrRoutingNumber;
  pRowset->AddParam (MTPARAM_ROUTINGNUMBER, vtParam) ;
      
  vtParam = bstrLastFourDigits;
  pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
      
  vtParam = (long) lngAccountType;
  pRowset->AddParam (MTPARAM_ACCOUNTTYPE, vtParam) ;
      
  // add the parameters ...
  vtParam = blnPrimary ? (const char *) "1" : (const char *)"0";
  pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
      
  // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();

  return hr;
}

//
// Delete methods
//

HRESULT
MTPSAccountMgmt::CC_DeletePaymentMethod(
                   MTPipelineLib::IMTSessionPtr aSession,
                   long                         alngMode)
{
  HRESULT   hr = S_OK;

  try
  {
    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

    hr = LogAttempt(aSession, "CC_DeletePaymentMethod", "delete");
    if (FAILED(hr))
      return hr;

    BOOL blnPrimary = FALSE;

    hr = CC_CheckIfPrimary(aSession, pRowset, &blnPrimary, alngMode);
    if (FAILED(hr))
      return hr;
 
    long lngNumOnRecord = 0;

    hr = GetNumPaymentMethodsOnRecord(aSession, pRowset, &lngNumOnRecord);
    if (FAILED(hr))
      return hr;

    if (FALSE == blnPrimary)
    {
      hr = CC_DeletePaymentMethodInternal(aSession, pRowset, alngMode);
      if (FAILED(hr))
        return hr;
    }
    else
    {
      if (1 == lngNumOnRecord)
      {
         // this is the only one
        hr = CC_DeletePaymentMethodInternal(aSession, pRowset, alngMode);
        if (FAILED(hr))
          return hr;

        hr = DeleteAccountInternal(aSession, pRowset);
        if (FAILED(hr))
          return hr;
      }
      else
      {
        // DJM: todo: change hresult to appropriate value.
        return Error("Cannot delete primary payment method. Multiple payment methods on record.",
                     IID_IMTPipelinePlugIn,
                     CREDITCARDACCOUNT_ERR_ANY_ERROR);
      }
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	return hr;
}

HRESULT
MTPSAccountMgmt::ACH_DeletePaymentMethod(
                 MTPipelineLib::IMTSessionPtr aSession,
                 long                         alngMode)
{
  HRESULT   hr = S_OK;

  try
  {
    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

    hr = LogAttempt(aSession, "ACH_DeletePaymentMethod", "delete");
    if (FAILED(hr))
      return hr;

    BOOL blnPrimary = FALSE;

    hr = ACH_CheckIfPrimary(aSession, pRowset, &blnPrimary, alngMode);
    if (FAILED(hr))
      return hr;
 
    long lngNumOnRecord = 0;

    hr = GetNumPaymentMethodsOnRecord(aSession, pRowset, &lngNumOnRecord);
    if (FAILED(hr))
      return hr;

    if (FALSE == blnPrimary)
    {
      hr = ACH_DeletePaymentMethodInternal(aSession, pRowset, alngMode);
      if (FAILED(hr))
        return hr;
    }
    else
    {
      if (1 == lngNumOnRecord)
      {
         // this is the only one
        hr = ACH_DeletePaymentMethodInternal(aSession, pRowset, alngMode);
        if (FAILED(hr))
          return hr;

        hr = DeleteAccountInternal(aSession, pRowset);
        if (FAILED(hr))
          return hr;
      }
      else
      {
        // DJM: todo: change hrresult to appropriate value.
        return Error("Cannot delete primary payment method. Multiple payment methods on record.",
                     IID_IMTPipelinePlugIn,
                     CREDITCARDACCOUNT_ERR_ANY_ERROR);
      }
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

	return hr;
}

HRESULT
MTPSAccountMgmt::CC_DeletePaymentMethodInternal(MTPipelineLib::IMTSessionPtr aSession,
                                                ROWSETLib::IMTSQLRowsetPtr   pRowset,
                                                long                         alngMode)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  long    lngAcctid = 0;
  long    lngCctype = 0;
  _bstr_t bstrLast4("");

  if (alngMode != MT_RESTRICTED)
  {
    lngAcctid = aSession->GetLongProperty(mlngAccountID);
    bstrLast4 = aSession->GetStringProperty(mlngLastFourDigits);
    lngCctype = aSession->GetLongProperty(mlngCreditCardType);

    //
    // First, delete from t_ps_pcard
    //

    // now that we have the cc number, go ahead and delete from t_ps_pcard
    pRowset->ClearQuery();

    _bstr_t queryTag = "__DELETE_T_PS_PCARD_TABLE__" ;
    pRowset->SetQueryTag (queryTag) ;

    _variant_t vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

    vtParam = bstrLast4;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;

    vtParam = (long) lngCctype;
    pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;

    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;

	  pRowset->Clear();

    //
    // Second, delete from t_ps_creditcard
    //

    pRowset->ClearQuery();

    queryTag = "__DELETE_T_PS_CREDITCARD_TABLE__" ;
    pRowset->SetQueryTag (queryTag) ;

    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

    vtParam = bstrLast4;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;

    vtParam = (long) lngCctype;
    pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;

    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;

	  pRowset->Clear();
  }
  else
  {
    lngAcctid = aSession->GetLongProperty(mlngAccountID);

    //
    // First, delete from t_ps_pcard
    //

    // now that we have the cc number, go ahead and delete from t_ps_pcard
    pRowset->ClearQuery();

    _bstr_t queryTag = "__DELETE_T_PS_PCARD_TABLE_BY_ID__" ;
    pRowset->SetQueryTag (queryTag) ;

    _variant_t vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;

	  pRowset->Clear();

    //
    // Second, delete from t_ps_creditcard
    //

    pRowset->ClearQuery();

    queryTag = "__DELETE_T_PS_CREDITCARD_TABLE_BY_ID__" ;
    pRowset->SetQueryTag (queryTag) ;

    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;

	  pRowset->Clear();
  }

  Audit(aSession,
        pRowset,
        lngAcctid,
        (const char *)"delete payment method",
        (const char *)"",
        (const char *)bstrLast4,
        (const char *)GetEnumName(lngCctype),
        (const char *)"",
        (const char *)"",
        0,
        (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
        (const char *)"",                // phonenumber
        (const char *)"",                // CSRIP
        (const char *)"",                // CSRID
        (const char *)"");

  return hr;
}
          
HRESULT
MTPSAccountMgmt::ACH_DeletePaymentMethodInternal(MTPipelineLib::IMTSessionPtr aSession,
                                                 ROWSETLib::IMTSQLRowsetPtr   pRowset,
                                                 long                         alngMode)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  long    lngAcctid = 0;
  _bstr_t bstrRoutingNumber("");
  _bstr_t bstrLast4("");
  long    lngAccountType = 0;

  if (MT_RESTRICTED != alngMode)
  {
    lngAcctid         = aSession->GetLongProperty(mlngAccountID);
    bstrRoutingNumber = aSession->GetStringProperty(mlngRoutingNumber);
    bstrLast4         = aSession->GetStringProperty(mlngLastFourDigits);
    lngAccountType    = aSession->GetLongProperty(mlngAccountType);

    pRowset->ClearQuery();

    _bstr_t queryTag = "__DELETE_T_PS_ACH_TABLE__" ;
    pRowset->SetQueryTag (queryTag) ;

    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

    vtParam = bstrRoutingNumber;
    pRowset->AddParam (MTPARAM_ROUTINGNUMBER, vtParam) ;

    vtParam = bstrLast4;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;

    vtParam = (long) lngAccountType;
    pRowset->AddParam (MTPARAM_ACCOUNTTYPE, vtParam) ;

    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;

	  pRowset->Clear();
  }
  else
  {
    lngAcctid = aSession->GetLongProperty(mlngAccountID);

    pRowset->ClearQuery();

    _bstr_t queryTag = "__DELETE_T_PS_ACH_TABLE_BY_ID__" ;
    pRowset->SetQueryTag (queryTag) ;

    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;

	  pRowset->Clear();
  }

  Audit(aSession,
        pRowset,
        lngAcctid,
        (const char *)"delete payment method",
        (const char *)bstrRoutingNumber,
        (const char *)bstrLast4,
        (const char *)GetEnumName(lngAccountType),
        (const char *)"",
        (const char *)"",
        0,
        (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
        (const char *)"",                // phonenumber
        (const char *)"",                // CSRIP
        (const char *)"",                // CSRID
        (const char *)"");

  return hr;
}

HRESULT
MTPSAccountMgmt::DeleteAccountInternal(MTPipelineLib::IMTSessionPtr aSession,
                                                 ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  HRESULT hr = S_OK;

  pRowset->ClearQuery();

  _bstr_t queryTag = "__DELETE_T_PS_ACCOUNT_TABLE__" ;
  pRowset->SetQueryTag (queryTag) ;

  _variant_t vtParam = (long) aSession->GetLongProperty(mlngAccountID);
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);

  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  pRowset->Clear();

  Audit(aSession,
        pRowset,
        (long)vtParam,
        (const char *)"delete account",
        (const char *)"",
        (const char *)"",
        (const char *)"",
        (const char *)"",
        (const char *)"",
        0,
        (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
        (const char *)"",                // phonenumber
        (const char *)"",                // CSRIP
        (const char *)"",                // CSRID
        (const char *)"");

  return hr;
}

HRESULT
MTPSAccountMgmt::CC_DeletePreviousPaymentMethod(MTPipelineLib::IMTSessionPtr aSession,
                                                ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  HRESULT hr = S_OK;

  if (!mblnAllowMultipleDataSets)
  {
    long lngCount = 0;

    hr = InternalLookupCCByAcctid(aSession, pRowset);
    if (FAILED(hr))
		{
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 "Internal lookup of CC by account ID failed");
      return hr;
		}

    BOOL blnEOF = pRowset->GetRowsetEOF() ? 1 : 0;

	  if (blnEOF)
      return hr;

    BOOL blnPrimary = FALSE;

    hr = CC_CheckIfPrimary(aSession, pRowset, &blnPrimary, MT_RESTRICTED);
    if (FAILED(hr))
		{
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 "Check if Primary call failed");
      return hr;
		}
 
    long lngNumOnRecord = 0;

    hr = GetNumPaymentMethodsOnRecord(aSession, pRowset, &lngNumOnRecord);
    if (FAILED(hr))
		{
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 "Getting number of payment methods on record failed");
     	return hr;
		}

    if (FALSE == blnPrimary)
    {
      hr = CC_DeletePaymentMethodInternal(aSession, pRowset, MT_RESTRICTED);
      if (FAILED(hr))
			{
	  		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 	"CC: deleting of payment method (internal) failed");
				return hr;
			}
    }
    else
    {
      if (1 == lngNumOnRecord)
      {
         // this is the only one
        hr = CC_DeletePaymentMethodInternal(aSession, pRowset, MT_RESTRICTED);
        if (FAILED(hr))
				{
	  			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 		"CC: deleting of payment method (internal) failed");
					return hr;
				}

        hr = DeleteAccountInternal(aSession, pRowset);
        if (FAILED(hr))
				{
	  			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
												 		"Deleting of account (internal) failed");
					return hr;
				}
      }
      else
      {
        // DJM: todo: change hresult to appropriate value.
        return Error("Cannot delete primary payment method. Multiple payment methods on record.",
                     IID_IMTPipelinePlugIn,
                     CREDITCARDACCOUNT_ERR_ANY_ERROR);
      }
    }
  }

  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_DeletePreviousPaymentMethod(MTPipelineLib::IMTSessionPtr aSession,
                                                 ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  HRESULT hr = S_OK;

  if (!mblnAllowMultipleDataSets)
  {
    long lngCount = 0;

    hr = InternalLookupACHByAcctid(aSession, pRowset);
    if (FAILED(hr))
      return hr;

    BOOL blnEOF = pRowset->GetRowsetEOF() ? 1 : 0;

	  if (blnEOF)
      return hr;

    BOOL blnPrimary = FALSE;

    hr = ACH_CheckIfPrimary(aSession, pRowset, &blnPrimary, MT_RESTRICTED);
    if (FAILED(hr))
      return hr;
 
    long lngNumOnRecord = 0;

    hr = GetNumPaymentMethodsOnRecord(aSession, pRowset, &lngNumOnRecord);
    if (FAILED(hr))
      return hr;

    if (FALSE == blnPrimary)
    {
      hr = ACH_DeletePaymentMethodInternal(aSession, pRowset, MT_RESTRICTED);
      if (FAILED(hr))
        return hr;
    }
    else
    {
      if (1 == lngNumOnRecord)
      {
         // this is the only one
        hr = ACH_DeletePaymentMethodInternal(aSession, pRowset, MT_RESTRICTED);
        if (FAILED(hr))
          return hr;

        hr = DeleteAccountInternal(aSession, pRowset);
        if (FAILED(hr))
          return hr;
      }
      else
      {
        // DJM: todo: change hrresult to appropriate value.
        return Error("Cannot delete primary payment method. Multiple payment methods on record.",
                     IID_IMTPipelinePlugIn,
                     CREDITCARDACCOUNT_ERR_ANY_ERROR);
      }
    }
  }

  return hr;
}

HRESULT 
MTPSAccountMgmt::CC_FindUpdateByNumberDateType(MTPipelineLib::IMTSessionPtr aSession)
{
	_bstr_t bstrCcnum            = aSession->GetStringProperty(mlngCreditCardNum);
	long    lngCctype            = aSession->GetLongProperty(mlngCreditCardType);
	_bstr_t bstrSuppliedexpdate  = aSession->GetStringProperty(mlngExpDate);
	long    lngExpdatef          = aSession->GetLongProperty(mlngExpDateFormat);

	char    LogBuf[512];
	HRESULT hr = S_OK;

	string sLastFourDigits;
	_bstr_t decrypted;

	
	try
	{
    hr = FormatNumber(bstrCcnum, decrypted, sLastFourDigits);
  	if (FAILED(hr))
	  	return hr;

		IMTSQLRowsetPtr pRowset;
		pRowset = aSession->GetRowset(mbstrConfigPath);

		_variant_t vtParam;

		// set the query tag ...
		_bstr_t queryTag = "__SELECT_BY_NUMBER_TYPE__" ;
		pRowset->SetQueryTag (queryTag) ;

		// add the parameters ...
		vtParam = bstrCcnum;
		pRowset->AddParam (MTPARAM_CREDITCARDNUMBER, vtParam) ;
      
		vtParam = (long )lngCctype;
		pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
      
		hr = pRowset->Execute();
		if (FAILED(hr))
			return hr;

		if (pRowset->GetRowsetEOF())
		{
			sprintf(
				LogBuf,
				"CC_FindUpdateByNumberDateType: not found: cctype %s, last: %s",
				(const char *)GetEnumName(lngCctype),
				 (const char*)sLastFourDigits.c_str());
  
			Audit(aSession,
				pRowset,
				0,
				(const char *)"find account",
				(const char *)"",
				(const char *)sLastFourDigits.c_str(),
				(const char *)GetEnumName(lngCctype),
				(const char *)"",
				(const char *)"",
				0,
				(const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
				(const char *)"",                // phonenumber
				(const char *)"",                // CSRIP
				(const char *)"",                // CSRID
				(const char *)LogBuf);

			//Conference Express can not handle com error; it looks for accountid=-1 in case of lookup failure.
			//return Error(LogBuf, IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);
			aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);
			aSession->SetLongProperty(mlngAccountID, -1);
			return S_OK;
		}
	
		_variant_t vtValue;

		// add to session data
		vtValue = pRowset->GetValue (DB_PSACCOUNTID);
		long lngAcctid = (long)vtValue;

		// determine if the supplied expiration date is newer than the
		// the old one.
		vtValue = pRowset->GetValue (DB_EXPDATE);
		_bstr_t bstrExpDate = vtValue.bstrVal;

		pRowset->Clear();

		if (IsSuppliedExpDateNewer(bstrSuppliedexpdate, bstrExpDate, (CREDITCARDLib::MTExpDateFormat) lngExpdatef))
		{
			// update with new expiration date
			_variant_t vtParam;

			pRowset->ClearQuery();

			// set the query tag ...
			_bstr_t queryTag = "__UPDATE_EXPDATE_T_PS_CREDITCARD_TABLE__" ;
			pRowset->SetQueryTag (queryTag) ;
 
			// add the parameters ...
			vtParam = (long) lngAcctid;
			pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
     
			vtParam = (long) lngCctype;
			pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
			
			vtParam = sLastFourDigits.c_str();
			pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
			
			vtParam = bstrSuppliedexpdate;
			pRowset->AddParam (MTPARAM_EXPDATE, vtParam) ;

			// execute the query ...
			hr = pRowset->Execute();
			if (FAILED(hr))
				return hr;
			
			pRowset->Clear();

			sprintf(
				LogBuf,
				"CC_FindUpdateByNumberDateType: update accid: %d, type: %s, last: %s",
				lngAcctid,
				(const char *)GetEnumName(lngCctype),
				(const char*)_bstr_t(sLastFourDigits.c_str()));
			
			hr = Audit(aSession,
				         pRowset,
				         lngAcctid,
				         (const char *)"update account",
				         (const char *)"",
				         (const char *)sLastFourDigits.c_str(),
				         (const char *)GetEnumName(lngCctype),
				         (const char *)"",
				         (const char *)bstrSuppliedexpdate,
				         lngExpdatef,
				         (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
				         (const char *)"",                // phonenumber
				         (const char *)"",                // CSRIP
				         (const char *)"",                // CSRID
				         (const char *)"Automatically update expiration date when searching by "
				                       "credit card number, expiration date, and type");
			if (FAILED(hr))
				return hr;
		} // if IsSuppliedExpDateNewer
	    
		aSession->SetLongProperty(mlngAccountID, lngAcctid);
	    aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

		sprintf(
			LogBuf,
			"CC_FindUpdateByNumberDateType: found: acctid %d, cctype %s, last: %s",
			lngAcctid,
			(const char *)GetEnumName(lngCctype),
			(const char *)sLastFourDigits.c_str());
  
	    hr = Audit(aSession,
			pRowset,
			lngAcctid,
			(const char *)"find account",
			(const char *)"",
			(const char *)sLastFourDigits.c_str(),
			(const char *)GetEnumName(lngCctype),
			(const char *)"",
			(const char *)"",
			0,
			(const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
			(const char *)"",                // phonenumber
			(const char *)"",                // CSRIP
			(const char *)"",                // CSRID
			(const char *)LogBuf);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

  return hr;
}

HRESULT
MTPSAccountMgmt::CC_FindByAccountidLast4Type(MTPipelineLib::IMTSessionPtr aSession)
{
  long    lngAcctid   = aSession->GetLongProperty(mlngAccountID);
  long    lngCctype   = aSession->GetLongProperty(mlngCreditCardType);
  _bstr_t bstrLast4   = aSession->GetStringProperty(mlngLastFourDigits);

  char       LogBuf[1024];
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  try
  {
    IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
    pRowset->Init(mbstrConfigPath);

    hr = InternalLookupCCByAcctidLast4Type(aSession, pRowset);
    if (FAILED(hr))
      return hr;

	  if (pRowset->GetRowsetEOF())
	  {
      sprintf(
        LogBuf,
        "CC_FindAcctidLast4Type: not found: acctid %d, cctype %s, last: %s",
        lngAcctid,
        (const char *)GetEnumName(lngCctype),
        (const char *)bstrLast4);
  
		  Audit(aSession,
            pRowset,
            lngAcctid,
            (const char *)"find account",
            (const char *)"",
            (const char *)bstrLast4,
            (const char *)GetEnumName(lngCctype),
            (const char *)"",
            (const char *)"",
            0,
            (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
            (const char *)"",                // phonenumber
            (const char *)"",                // CSRIP
            (const char *)"",                // CSRID
            (const char *)LogBuf);

			return Error(LogBuf, IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);
	  }
	
    // add to session data
    _variant_t vtValue;
    _bstr_t    bstrValue;

    vtValue = pRowset->GetValue (DB_CREDITCARDNUMBER);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCreditCardNum, bstrValue);
    DecryptNumber(aSession, mlngCreditCardNum);

    //get optional security code from rowset.
    vtValue = pRowset->GetValue ("nm_ccseccode");
    if(V_VT(&vtValue) != VT_NULL)
    {
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngCreditCardSecCode, bstrValue);
      DecryptNumber(aSession, mlngCreditCardSecCode);
    }
   
    vtValue = pRowset->GetValue (DB_BANKNAME);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngBankName, bstrValue);

    vtValue = pRowset->GetValue (DB_CUSTOMERNAME);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCustomerName, bstrValue);

    vtValue = pRowset->GetValue (DB_PRIMARY);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetLongProperty(mlngPrimary, (long)(bstrValue == _bstr_t("1")) ? 1 : 0);

    vtValue = pRowset->GetValue (DB_ENABLED);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetLongProperty(mlngEnabled, (long)(bstrValue == _bstr_t("1")) ? 1 : 0);

    vtValue = pRowset->GetValue (DB_AUTHRECEIVED);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetLongProperty(mlngAuthReceived, (long)(bstrValue == _bstr_t("1")) ? 1 : 0);

    vtValue = pRowset->GetValue (DB_ADDRESS);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngAddress, bstrValue);

    vtValue = pRowset->GetValue (DB_CITY);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCity, bstrValue);

    vtValue = pRowset->GetValue (DB_STATE);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngState, bstrValue);

    vtValue = pRowset->GetValue (DB_ZIP);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngZip, bstrValue);

    vtValue = pRowset->GetValue (DB_PSCOUNTRY);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCountry, bstrValue);

    vtValue = pRowset->GetValue (DB_EXPDATE);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngExpDate, bstrValue);

    vtValue = pRowset->GetValue (DB_EXPDATEFORMAT);
    aSession->SetLongProperty(mlngExpDateFormat, vtValue);

    vtValue = pRowset->GetValue (DB_STARTDATE);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngStartDate, bstrValue);

    vtValue = pRowset->GetValue (DB_ISSUERNUMBER);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngIssuerNumber, bstrValue);

    vtValue = pRowset->GetValue (DB_CARDID);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCardId, bstrValue);

    vtValue = pRowset->GetValue (DB_CARDVERIFYVALUE);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCardVerifyValue, bstrValue);

	vtValue = pRowset->GetValue (DB_EMAIL);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngEmail, bstrValue);

		// added here
		vtValue = pRowset->GetValue(DB_CONFIRMREQUESTED);
		bstrValue = MTMiscUtil::GetString(vtValue);
		aSession->SetStringProperty(mlngConfirmRequested, bstrValue);

    // Currently, this plugin identifies purchase cards by their type. This code
    // is here in case this indicator is included in the service definition.

    vtValue = pRowset->GetValue (DB_PCARD);
    bstrValue = vtValue.bstrVal;

    if (_bstr_t("1") == bstrValue)
    {
      vtValue = pRowset->GetValue (DB_CUSTOMERREFERENCEID);
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngCustomerReferenceId, bstrValue);
  
      vtValue = pRowset->GetValue (DB_CUSTOMERVATNUMBER);
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngCustomerVatNumber, bstrValue);

      vtValue = pRowset->GetValue (DB_COMPANYADDRESS);
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngCompanyAddress, bstrValue);

      vtValue = pRowset->GetValue (DB_COMPANYPOSTALCODE);
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngCompanyPostalCode, bstrValue);

      vtValue = pRowset->GetValue (DB_COMPANYPHONE);
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngCompanyPhone, bstrValue);

      vtValue = pRowset->GetValue (DB_RESERVED1);
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngReserved1, bstrValue);

      vtValue = pRowset->GetValue (DB_RESERVED2);
      bstrValue = MTMiscUtil::GetString(vtValue);
      aSession->SetStringProperty(mlngReserved2, bstrValue);
    }
    else
    {
      bstrValue = (const char *)""; 

      aSession->SetStringProperty(mlngCustomerReferenceId, bstrValue);
      aSession->SetStringProperty(mlngCustomerVatNumber, bstrValue);
      aSession->SetStringProperty(mlngCompanyAddress, bstrValue);
      aSession->SetStringProperty(mlngCompanyPostalCode, bstrValue);
      aSession->SetStringProperty(mlngCompanyPhone, bstrValue);
      aSession->SetStringProperty(mlngReserved1, bstrValue);
      aSession->SetStringProperty(mlngReserved2, bstrValue);
    }

    pRowset->Clear();

    sprintf(
      LogBuf,
      "CC_FindByAccountIdLast4Type: retrieved accid: %d, type: %s, last: %s",
      lngAcctid,
      (const char *)GetEnumName(lngCctype),
      (const char *)bstrLast4);
  
	  hr = Audit(aSession,
               pRowset,
               lngAcctid,
               (const char *)"find account",
               (const char *)"",
               (const char *)bstrLast4,
               (const char *)GetEnumName(lngCctype),
               (const char *)"",
               (const char *)"",
               0,
               (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
               (const char *)"",                // phonenumber
               (const char *)"",                // CSRIP
               (const char *)"",                // CSRID
               (const char *)LogBuf);
    if (FAILED(hr))
      return hr;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

  return hr;
}

HRESULT
MTPSAccountMgmt::CC_FindByAccountid(MTPipelineLib::IMTSessionPtr aSession)
{
  long lngAcctid = aSession->GetLongProperty(mlngAccountID);

  char       LogBuf[1024];
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  // store in the database

  try
  {
    IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
    pRowset->Init(mbstrConfigPath);

    hr = InternalLookupCCByAcctid(aSession, pRowset);
    if (FAILED(hr))
      return hr;

	  if (pRowset->GetRowsetEOF())
	  {
      sprintf(
        LogBuf,
        "CC_FindByAccountid: not found: account id %d",
        lngAcctid);
  
		  Audit(aSession,
            pRowset,
            lngAcctid,
            (const char *)"find account",
            (const char *)"",
            (const char *)"",
            (const char *)"",
            (const char *)"",
            (const char *)"",
            0,
            (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
            (const char *)"",                // phonenumber
            (const char *)"",                // CSRIP
            (const char *)"",                // CSRID
            (const char *)LogBuf);

		  return Error(LogBuf, IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);
	  }
	
    // add to session data
    _variant_t vtValue;
    long       lngCctype;
    _bstr_t    bstrLastFourDigits;

    vtValue = pRowset->GetValue (DB_CREDITCARDTYPE);
    lngCctype = vtValue;
    aSession->SetLongProperty(mlngCreditCardType, lngCctype);
    //CR 8385 fix, but stay backward compatibile, don're move the above line
    aSession->SetEnumProperty(mlngCreditCardType, lngCctype);

    vtValue = pRowset->GetValue (DB_LASTFOURDIGITS);
    bstrLastFourDigits = vtValue.bstrVal;
    aSession->SetStringProperty(mlngLastFourDigits, bstrLastFourDigits);

    pRowset->Clear();

    sprintf(
      LogBuf,
      "CC_FindByAccountId: retrieved account id: %d, type: %d, last: %s",
      lngAcctid,
      lngCctype,
      (const char *)bstrLastFourDigits);

	  hr = Audit(aSession,
               pRowset,
               lngAcctid,
               (const char *)"find account",
               (const char *)"",
               (const char *)bstrLastFourDigits,
               (const char *)GetEnumName(lngCctype),
               (const char *)"",
               (const char *)"",
               0,
               (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
               (const char *)"",                // phonenumber
               (const char *)"",                // CSRIP
               (const char *)"",                // CSRID
               (const char *)LogBuf);

    if (FAILED(hr))
      return hr;
  }
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_FindByAccountidRoutingNumberLast4Type(MTPipelineLib::IMTSessionPtr aSession)
{
  long    lngAcctId         = aSession->GetLongProperty(mlngAccountID);
  _bstr_t bstrRoutingNumber = aSession->GetStringProperty(mlngRoutingNumber);
  long    lngAccountType    = aSession->GetLongProperty(mlngAccountType);
  _bstr_t bstrLast4         = aSession->GetStringProperty(mlngLastFourDigits);

  _variant_t vtParam;
  char       LogBuf[1024];
  HRESULT    hr = S_OK;

  try
  {
    IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
    pRowset->Init(mbstrConfigPath);

    hr = InternalLookupACHByAcctidRoutingNumberLast4Type(aSession, pRowset);
    if (FAILED(hr))
      return hr;

	  if (pRowset->GetRowsetEOF())
	  {
      sprintf(
        LogBuf,
        "ACH_FindByAccountidRoutingNumberLast4Type: not found: acctid %d, routing number, %s: "
        "last: %s, cctype %s",
        lngAcctId,
        (const char *)bstrRoutingNumber,
        (const char *)bstrLast4,
        (const char *)GetEnumName(lngAccountType));

		  Audit(aSession,
            pRowset,
            lngAcctId,
            (const char *)"find account",
            (const char *)bstrRoutingNumber,
            (const char *)bstrLast4,
            (const char *)GetEnumName(lngAccountType),
            (const char *)"",
            (const char *)"",
            0,
            (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
            (const char *)"",                // phonenumber
            (const char *)"",                // CSRIP
            (const char *)"",                // CSRID
            (const char *)LogBuf);

      return Error(LogBuf, IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);
	  }

    // add to session data
    _variant_t vtValue;
    _bstr_t    bstrValue;

    vtValue = pRowset->GetValue (DB_ACCOUNTNUMBER);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngBankAccountNumber, bstrValue);
    DecryptNumber(aSession, mlngBankAccountNumber);
   
    vtValue = pRowset->GetValue (DB_CUSTOMERNAME);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCustomerName, bstrValue);

    vtValue = pRowset->GetValue (DB_PRIMARY);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetLongProperty(mlngPrimary, (bstrValue == _bstr_t("1")) ? 1 : 0);
  
    vtValue = pRowset->GetValue (DB_ENABLED);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetLongProperty(mlngEnabled, (bstrValue == _bstr_t("1")) ? 1 : 0);

    vtValue = pRowset->GetValue (DB_AUTHRECEIVED);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetLongProperty(mlngAuthReceived, (bstrValue == _bstr_t("1")) ? 1 : 0);

    vtValue = pRowset->GetValue (DB_VALIDATED);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetLongProperty(mlngValidated, (bstrValue == _bstr_t("1")) ? 1 : 0);

    vtValue = pRowset->GetValue (DB_ADDRESS);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngAddress, bstrValue);

    vtValue = pRowset->GetValue (DB_CITY);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCity, bstrValue);

    vtValue = pRowset->GetValue (DB_STATE);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngState, bstrValue);

    vtValue = pRowset->GetValue (DB_ZIP);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngZip, bstrValue);

    vtValue = pRowset->GetValue (DB_PSCOUNTRY);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngCountry, bstrValue);

    vtValue = pRowset->GetValue (DB_BANKNAME);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngBankName, bstrValue);

    vtValue = pRowset->GetValue (DB_RESERVED1);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngReserved1, bstrValue);

    vtValue = pRowset->GetValue (DB_RESERVED2);
    bstrValue = MTMiscUtil::GetString(vtValue);
    aSession->SetStringProperty(mlngReserved2, bstrValue);

    pRowset->Clear();

    sprintf(
      LogBuf,
      "ACH_FindByAccountIdRoutingNumberLast4Type: retrieved accid: %d, routing number: %s, "
      "last: %s, type: %s",
      lngAcctId,
      (const char *)bstrRoutingNumber,
      (const char *)bstrLast4,
      (const char *)GetEnumName(lngAccountType));
  
	  hr = Audit(aSession,
               pRowset,
               lngAcctId,
               (const char *)"find account",
               (const char *)bstrRoutingNumber,
               (const char *)bstrLast4,
               (const char *)GetEnumName(lngAccountType),
               (const char *)"",
               (const char *)"",
               0,
               (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
               (const char *)"",                // phonenumber
               (const char *)"",                // CSRIP
               (const char *)"",                // CSRID
               (const char *)LogBuf);

    if (FAILED(hr))
      return hr;
  }
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_FindByAccountid(MTPipelineLib::IMTSessionPtr aSession)
{
  long lngAcctid = aSession->GetLongProperty(mlngAccountID);

  char       LogBuf[1024];
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  // store in the database

  try
  {
    IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
    pRowset->Init(mbstrConfigPath);

    hr = InternalLookupACHByAcctid(aSession, pRowset);
    if (FAILED(hr))
      return hr;

	  if (pRowset->GetRowsetEOF())
	  {
      sprintf(LogBuf, "ACH_FindByAccountid: account %d not found", lngAcctid);
  
		  Audit(aSession,
            pRowset,
            lngAcctid,
            (const char *)"find account",
            (const char *)"",
            (const char *)"",
            (const char *)"",
            (const char *)"",
            (const char *)"",
            0,
            (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
            (const char *)"",                // phonenumber
            (const char *)"",                // CSRIP
            (const char *)"",                // CSRID
            (const char *)LogBuf);

      return Error(LogBuf, IID_IMTPipelinePlugIn, CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND);
	  }

    // add to session data
    _variant_t vtValue;
    _bstr_t    bstrRoutingNumber;
    _bstr_t    bstrLastFourDigits;
    long       lngAccountType;

    vtValue = pRowset->GetValue (DB_ROUTINGNUMBER);
    bstrRoutingNumber = vtValue.bstrVal;
    aSession->SetStringProperty(mlngRoutingNumber, bstrRoutingNumber);

    vtValue = pRowset->GetValue (DB_LASTFOURDIGITS);
    bstrLastFourDigits = vtValue.bstrVal;
    aSession->SetStringProperty(mlngLastFourDigits, bstrLastFourDigits);

    vtValue = pRowset->GetValue (DB_ACCOUNTTYPE);
    lngAccountType = (long)vtValue;
    aSession->SetEnumProperty(mlngAccountType, lngAccountType);

    pRowset->Clear();

    sprintf(
      LogBuf,
      "ACH_FindByAccountId: retrieved account id: %d, routing number: %s, last: %s, type: %s",
      lngAcctid,
      (const char *)bstrRoutingNumber,
      (const char *)bstrLastFourDigits,
      (const char *)GetEnumName(lngAccountType));

	  hr = Audit(aSession,
               pRowset,
               lngAcctid,
               (const char *)"find account",
               (const char *)bstrRoutingNumber,
               (const char *)bstrLastFourDigits,
               (const char *)GetEnumName(lngAccountType),
               (const char *)"",
               (const char *)"",
               0,
               (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
               (const char *)"",                // phonenumber
               (const char *)"",                // CSRIP
               (const char *)"",                // CSRID
               (const char *)LogBuf);

    if (FAILED(hr))
      return hr;
  }
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);

  return hr;
}

HRESULT
MTPSAccountMgmt::InternalGetAccount(MTPipelineLib::IMTSessionPtr aSession, ROWSETLib::IMTSQLRowsetPtr pRowset)
{
	HRESULT		hr = S_OK;
	long		lngAcctid = aSession->GetLongProperty(mlngAccountID);
	_variant_t	vtParam;
	
	pRowset->ClearQuery();

	// set the query tag ...
	_bstr_t queryTag = "__SELECT_ALL_T_PS_ACCOUNT_TABLE__";
	pRowset->SetQueryTag(queryTag) ;

	// add the parameters ...
	vtParam = (long)lngAcctid;
	pRowset->AddParam(MTPARAM_ACCOUNTID, vtParam);

	// execute the query ...
	hr = pRowset->Execute();
	if (FAILED(hr))
		return hr;

	return hr;
}

HRESULT
MTPSAccountMgmt::GetPrimaryPaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT    hr = S_OK;
	long	lngAcctid;
	long    lngCurrentAccountType;
	long    lngCurrentCreditCardType;
	_bstr_t bstrCurrentLastFourDigits;
	_bstr_t bstrCurrentRoutingNumber;

	lngAcctid = aSession->GetLongProperty(mlngAccountID);

	try
	{
		IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
		pRowset->Init(mbstrConfigPath);

		//
		// Search for the payment method that is already the primary
		//

	    BOOL blnPrimaryFound;
	
		hr = CC_GetPrimary(pRowset, lngAcctid, blnPrimaryFound, 
			               bstrCurrentLastFourDigits, lngCurrentCreditCardType);
		if (FAILED(hr))
			return hr;
 
		if (blnPrimaryFound)
		{
			aSession->SetEnumProperty(mlngPaymentType, mEnumCCPaymentType);
			// add credit card type and last four to the session
			aSession->SetEnumProperty(mlngCreditCardType, lngCurrentCreditCardType);
			aSession->SetStringProperty(mlngLastFourDigits, bstrCurrentLastFourDigits);
		}
		
		// TODO: do we need to query ACH for primary method as well if CC was found?
		hr = ACH_GetPrimary(pRowset, lngAcctid, blnPrimaryFound, bstrCurrentRoutingNumber,
                        bstrCurrentLastFourDigits, lngCurrentAccountType);
		if (FAILED(hr))
			return hr;
 
	    if (blnPrimaryFound)
		{
			aSession->SetEnumProperty(mlngPaymentType, mEnumACHPaymentType);
			aSession->SetEnumProperty(mlngAccountType, lngCurrentAccountType);
			aSession->SetStringProperty(mlngLastFourDigits, bstrCurrentLastFourDigits);
			aSession->SetStringProperty(mlngRoutingNumber, bstrCurrentRoutingNumber);	
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return hr;
}

HRESULT
MTPSAccountMgmt::GetAccountAndPrimaryPaymentMethod(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr = S_OK;
	long lngAcctid = aSession->GetLongProperty(mlngAccountID);
	char       LogBuf[1024];

	try
	{			
		IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
		pRowset->Init(mbstrConfigPath);

		hr = InternalGetAccount(aSession, pRowset);
		if (FAILED(hr))
			return hr;

		if (pRowset->GetRowsetEOF())
		{
			sprintf(LogBuf, "Account with ID <%d> not found on payment server", lngAcctid);
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, LogBuf);
			return CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND;
		}

		// add to session data
		_variant_t vtValue;
		_bstr_t    bstrValue;

		vtValue = pRowset->GetValue(DB_EMAIL);
		bstrValue = MTMiscUtil::GetString(vtValue);
		aSession->SetStringProperty(mlngEmail, bstrValue);

		vtValue = pRowset->GetValue(DB_RETAINCARDINFO);
		aSession->SetLongProperty(mlngRetainCardInfo , vtValue);
		
		vtValue = pRowset->GetValue(DB_RETRYONFAILURE);
		bstrValue = MTMiscUtil::GetString(vtValue);
		aSession->SetStringProperty(mlngRetryOnFailure, bstrValue);
		
		vtValue = pRowset->GetValue(DB_NUMBERRETRIES);
		aSession->SetLongProperty(mlngNumberRetries, vtValue);

		// there already
		vtValue = pRowset->GetValue(DB_CONFIRMREQUESTED);
		bstrValue = MTMiscUtil::GetString(vtValue);
		aSession->SetStringProperty(mlngConfirmRequested, bstrValue);
		
		vtValue = pRowset->GetValue(DB_DELAY);
		aSession->SetLongProperty(mlngDelay, vtValue);

		vtValue = pRowset->GetValue(DB_BILLEARLY);
		bstrValue = MTMiscUtil::GetString(vtValue);
		aSession->SetStringProperty(mlngBillEarly, bstrValue);

		// retrieve primary payment method
		hr = GetPrimaryPaymentMethod(aSession);
		if (FAILED(hr))
			// TODO: Add detailed error
			return hr;

		// set any global properties
		long lPaymentType = aSession->GetEnumProperty(mlngPaymentType);
			
		PaymentOptionMapSet::iterator its = mPaymentOptionMapSet.find(lPaymentType);
			
		if (its != mPaymentOptionMapSet.end())
		{
			PaymentOptionMap * pOptionMap = its->second;
			ASSERT(pOptionMap);
			
			for (PaymentOptionMap::iterator itm = pOptionMap->begin(); itm != pOptionMap->end(); ++itm)
			{
				PaymentOption * pOption = itm->second;
				
				if (pOption->mGlobal)
			
					switch (pOption->mValue.vt)
					{
					case VT_I4:
						aSession->SetLongProperty(itm->first, pOption->mValue.lVal);	
						break;

					case VT_I2:
						aSession->SetLongProperty(itm->first, pOption->mValue.iVal);	
						break;
					
					case VT_BSTR:
						aSession->SetStringProperty(itm->first, pOption->mValue.bstrVal);	
						break;
					}
			}
			
		}
		else
			// TODO: better error handling
			return E_FAIL;			
	
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return hr;
}



//
// Common methods
//

HRESULT
MTPSAccountMgmt::GetNumPaymentMethodsOnRecord(MTPipelineLib::IMTSessionPtr aSession,
                                              ROWSETLib::IMTSQLRowsetPtr   pRowset, 
                                              long                       * alngCount)
{
  HRESULT hr = S_OK;

  long lngCCCount = 0;
  long lngACHCount = 0;

  hr = GetNumCCPaymentMethodsOnRecord(aSession, pRowset, &lngCCCount);
  if (FAILED(hr))
	{
	  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
											 "Unable to get number of CC payment method records");
    return hr;
	}
 
  hr = GetNumACHPaymentMethodsOnRecord(aSession, pRowset, &lngACHCount);
  if (FAILED(hr))
	{
	  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
											 "Unable to get number of ACH payment method records");
    return hr;
	}
 
  *alngCount = lngCCCount + lngACHCount;

  return hr;
}

HRESULT
MTPSAccountMgmt::GetNumCCPaymentMethodsOnRecord(MTPipelineLib::IMTSessionPtr aSession,
                                                ROWSETLib::IMTSQLRowsetPtr   pRowset, 
                                                long                       * alngCount)
{
  long    lngAcctid = aSession->GetLongProperty(mlngAccountID);
  HRESULT hr = S_OK;

  _variant_t vtParam;

	try
	{
		pRowset->ClearQuery();

		// set the query tag ...
  	_bstr_t queryTag = "__SELECT_ALL_CC_BY_ID__" ;
  	pRowset->SetQueryTag (queryTag) ;

		// First, check number of credit cards

		// add the parameters ...
		vtParam = (long) lngAcctid;
  	pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
		// execute the query ...
		hr = pRowset->Execute();
		if (FAILED(hr))
			return hr;

		*alngCount = pRowset->GetRecordCount();
 
		pRowset->Clear();
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}


  return hr;
}

HRESULT
MTPSAccountMgmt::GetNumACHPaymentMethodsOnRecord(MTPipelineLib::IMTSessionPtr aSession,
                                                 ROWSETLib::IMTSQLRowsetPtr   pRowset, 
                                                 long                       * alngCount)
{
  long    lngAcctid = aSession->GetLongProperty(mlngAccountID);
  HRESULT hr = S_OK;

  _variant_t vtParam;

	try
	{
		pRowset->ClearQuery();

  	// set the query tag ...
  	_bstr_t queryTag = "__SELECT_ALL_ACH_BY_ID__" ;
  	pRowset->SetQueryTag (queryTag) ;

  	// First, check number of credit cards
	
  	// add the parameters ...
  	vtParam = (long) lngAcctid;
  	pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      	
  	// execute the query ...
  	hr = pRowset->Execute();
  	if (FAILED(hr))
    	return hr;

  	*alngCount = pRowset->GetRecordCount();
 	
  	pRowset->Clear();
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

  return hr;
}

HRESULT
MTPSAccountMgmt::CC_CheckIfPrimary(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset,
                   BOOL                       * ablnRet,
                   long                         alngMode)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  long    lngAcctid = aSession->GetLongProperty(mlngAccountID);

  pRowset->ClearQuery();

  if (MT_RESTRICTED != alngMode)
  {
    _bstr_t bstrLast4 = aSession->GetStringProperty(mlngLastFourDigits);
    long    lngCctype = aSession->GetLongProperty(mlngCreditCardType);

    // set the query tag ...
    _bstr_t queryTag = "__SELECT_PRIMARY_FROM_CREDITCARD__";
    pRowset->SetQueryTag (queryTag) ;

    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
    vtParam = bstrLast4;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
      
    vtParam = (long) lngCctype;
    pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
      
    // add the parameters ...
    vtParam = (const char *) "1";
    pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
  }
  else
  {
    // set the query tag ...
    _bstr_t queryTag = "__SELECT_PRIMARY_FROM_CREDITCARD_BY_ID__";
    pRowset->SetQueryTag (queryTag) ;

    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
    // add the parameters ...
    vtParam = (const char *) "1";
    pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
  }
      
  // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  *ablnRet = pRowset->GetRowsetEOF() ? 0 : 1;

  pRowset->Clear();

  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_CheckIfPrimary(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset,
                   BOOL                       * ablnRet,
                   long                         alngMode)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  long lngAcctid            = aSession->GetLongProperty(mlngAccountID);

  pRowset->ClearQuery();

  if (MT_RESTRICTED != alngMode)
  {
    _bstr_t bstrRoutingNumber = aSession->GetStringProperty(mlngRoutingNumber);
    _bstr_t bstrLast4         = aSession->GetStringProperty(mlngLastFourDigits);
    long lngAccountType       = aSession->GetLongProperty(mlngAccountType);

    // set the query tag ...
    _bstr_t queryTag = "__SELECT_PRIMARY_FROM_ACH__";
    pRowset->SetQueryTag (queryTag) ;

    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
    vtParam = bstrRoutingNumber;
    pRowset->AddParam (MTPARAM_ROUTINGNUMBER, vtParam) ;
      
    vtParam = bstrLast4;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
      
    vtParam = (long) lngAccountType;
    pRowset->AddParam (MTPARAM_ACCOUNTTYPE, vtParam) ;
      
    // add the parameters ...
    vtParam = (const char *) "1";
    pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
  }
  else
  {
    // set the query tag ...
    _bstr_t queryTag = "__SELECT_PRIMARY_FROM_ACH_BY_ID__";
    pRowset->SetQueryTag (queryTag) ;

    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
    // add the parameters ...
    vtParam = (const char *) "1";
    pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
  }
      
  // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  *ablnRet = pRowset->GetRowsetEOF() ? 0 : 1;

  pRowset->Clear();

  return hr;
}

HRESULT
MTPSAccountMgmt::CC_GetPrimary(
                   ROWSETLib::IMTSQLRowsetPtr   pRowset,
                   long                         alngAcctid,
                   BOOL                       & ablnRet,
                   _bstr_t                    & abstrLastFourDigits,
                   long                       & alngCctype)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  pRowset->ClearQuery();

  // set the query tag ...
  _bstr_t queryTag = "__SELECT_PRIMARY_FROM_CREDITCARD_BY_ID__";
  pRowset->SetQueryTag (queryTag) ;

  // add the parameters ...
  vtParam = (long) alngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
  // add the parameters ...
  vtParam = (const char *) "1";
  pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
      
  // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  ablnRet = pRowset->GetRowsetEOF() ? 0 : 1;

  if (ablnRet)
  {
    _variant_t vtLast4    = pRowset->GetValue(DB_LASTFOURDIGITS);
    _variant_t vtCctype   = pRowset->GetValue(DB_CREDITCARDTYPE);
        
    abstrLastFourDigits = vtLast4;
    alngCctype          = vtCctype;
  }

  pRowset->Clear();

  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_GetPrimary(
                   ROWSETLib::IMTSQLRowsetPtr   pRowset,
                   long                         alngAcctid,
                   BOOL                       & ablnRet,
                   _bstr_t                    & abstrRoutingNumber,
                   _bstr_t                    & abstrLastFourDigits,
                   long                       & alngAccountType)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  pRowset->ClearQuery();

  // set the query tag ...
  _bstr_t queryTag = "__SELECT_PRIMARY_FROM_ACH_BY_ID__";
  pRowset->SetQueryTag (queryTag) ;

  // add the parameters ...
  vtParam = (long) alngAcctid;
  pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
      
  // add the parameters ...
  vtParam = (const char *) "1";
  pRowset->AddParam (MTPARAM_PRIMARY, vtParam) ;
      
  // execute the query ...
  hr = pRowset->Execute();
  if (FAILED(hr))
    return hr;

  ablnRet = pRowset->GetRowsetEOF() ? 0 : 1;

  if (ablnRet)
  {
    _variant_t vtRoutingNumber = pRowset->GetValue(DB_ROUTINGNUMBER);
    _variant_t vtLast4         = pRowset->GetValue(DB_LASTFOURDIGITS);
    _variant_t vtAccountType   = pRowset->GetValue(DB_ACCOUNTTYPE);
        
    abstrRoutingNumber   = vtRoutingNumber;
    abstrLastFourDigits  = vtLast4;
    alngAccountType      = vtAccountType;
  }

  pRowset->Clear();

  return hr;
}

HRESULT
MTPSAccountMgmt::CC_ValidateCreditCard(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT   hr = S_OK;
	CREDITCARDLib::MTCreditCardErrorMsg retVal = CREDITCARDLib::MT_CC_SUCCESS;

  try
  {
    _bstr_t   bstrCcSecCode;
		_bstr_t		bstrStartdate;
		_bstr_t		bstrIssuernumber;
    _bstr_t   bstrCcnum = aSession->GetStringProperty(mlngCreditCardNum);
    
    if(aSession->PropertyExists(mlngCreditCardSecCode, MTPipelineLib::SESS_PROP_TYPE_STRING))
          bstrCcSecCode = aSession->GetStringProperty(mlngCreditCardSecCode);
    // the listener encrypts the credit card number once it arrives. the number
    // may contain hyphens or spaces. this code needs to decrypt, remove hyphens
    // and spaces, and encrypt before storing in the database.
    
    DecryptNumber(bstrCcnum);
    FormatCCNumber(bstrCcnum);
 
    
    _bstr_t bstrCustname                = aSession->GetStringProperty(mlngCustomerName);
    _bstr_t bstrAddr                    = aSession->GetStringProperty(mlngAddress);
    _bstr_t bstrCity                    = aSession->GetStringProperty(mlngCity);
    _bstr_t bstrState                   = aSession->GetStringProperty(mlngState);
    _bstr_t bstrZip                     = aSession->GetStringProperty(mlngZip);
    //country
    _bstr_t bstrCountry                 = GetCountryName(aSession->GetStringProperty(mlngCountry));
    long    lngCctype                   = aSession->GetLongProperty(mlngCreditCardType);
    _bstr_t bstrExpdate                 = aSession->GetStringProperty(mlngExpDate);
    long    lngExpdatef                 = aSession->GetLongProperty(mlngExpDateFormat);
		
		if(aSession->PropertyExists(mlngStartDate, MTPipelineLib::SESS_PROP_TYPE_STRING))
			bstrStartdate											= aSession->GetStringProperty(mlngStartDate);
		
		if(aSession->PropertyExists(mlngIssuerNumber, MTPipelineLib::SESS_PROP_TYPE_STRING))
	    bstrIssuernumber            = aSession->GetStringProperty(mlngIssuerNumber);
    
		long    lngAcctid                   = aSession->GetLongProperty(mlngAccountID);
    _bstr_t bstrCardId                  = aSession->GetStringProperty(mlngCardId);
    _bstr_t bstrCardVerifyValue         = aSession->GetStringProperty(mlngCardVerifyValue);
    _bstr_t bstrCustomerReferenceId     = aSession->GetStringProperty(mlngCustomerReferenceId);
    
    
    //	BP: part of CR 6075 fix. Get decrypted number here and do some basic
    //	credit card validation before shipping the request over to Verisign.
    // create the CreditCard object
    CREDITCARDLib::MTCreditCardType type;
    hr = GetInternalCCType(lngCctype, type);
    if(FAILED(hr))
      return hr;
    mtcc->PutCardType(type);
    mtcc->PutCardNumber(bstrCcnum);
    CREDITCARDLib::MTCreditCardErrorMsg result = mtcc->ValidateTypeAndNumber();
    if(result != CREDITCARDLib::MT_CC_SUCCESS)
    {
      return GetComError(result);
    }
    
    // step 1: create a session
    MTMeterSession * mtmSession = mmtmMeter.CreateSession(
      (const char *)"metratech.com/ps_cc_validatecardwithoutaccount");
    
    mtmSession->SetResultRequestFlag(TRUE);
    mtmSession->InitProperty("customername", (const wchar_t *)bstrCustname);
    mtmSession->InitProperty("address", (const wchar_t *)bstrAddr);
    mtmSession->InitProperty("city", (const wchar_t *)bstrCity);
    mtmSession->InitProperty("state", (const wchar_t *)bstrState);
    mtmSession->InitProperty("zip", (const wchar_t *)bstrZip);
    mtmSession->InitProperty("country", (const wchar_t *)bstrCountry);
    
#ifdef DECIMAL_PLUGINS
    mtmSession->InitProperty("_amount" , mdecValidateAmount.Format().c_str());
#else
    mtmSession->InitProperty("_amount" , mdblValidateAmount);
#endif
    
    mtmSession->InitProperty("_currency" , (const char *)"USD");
    mtmSession->InitProperty("creditcardtype", (const wchar_t *)GetEnumName(lngCctype));
    mtmSession->InitProperty("creditcardnum_", (const char *)bstrCcnum);
    if(bstrCcSecCode.length() > 0)
    {
      DecryptNumber(bstrCcSecCode);
      mtmSession->InitProperty("creditcardseccode_", (const char *)bstrCcSecCode);
    }
    mtmSession->InitProperty("expdate", (const char *)bstrExpdate);
    mtmSession->InitProperty("expdateformat", (int)lngExpdatef);

		if(bstrStartdate.length() > 0)
    {
     mtmSession->InitProperty("startdate", (const char *)bstrStartdate);
    }
		if(bstrIssuernumber.length() > 0)
    {
     		mtmSession->InitProperty("issuernumber", (const char *)bstrIssuernumber);
    }
    mtmSession->InitProperty("cardid", (const wchar_t *)bstrCardId);
    mtmSession->InitProperty("cardverifyvalue", (const wchar_t *)bstrCardVerifyValue);
    mtmSession->InitProperty("customerreferenceid", (const wchar_t *)bstrCustomerReferenceId);
    mtmSession->InitProperty("testsession", (int)0);
    
    if (!mtmSession->Close())
    {
      char buff[1024] = "";
      int size=1024;
      MTMeterError * err = mtmSession->GetLastErrorObject();
      delete mtmSession;
      
      err->GetErrorMessageEx(buff,size);
      
      if(strcmp(buff,"") == 0)
      {
        unsigned long aErrorCode = err->GetErrorCode();
        sprintf(
          buff,
          "CC_AddAccount: session->Close() failed with error %d",
          aErrorCode);
      }
      
      hr = err->GetErrorCode();
      return hr;
    }
    
    MTMeterSession * mtmRetSession = mtmSession->GetSessionResults();
    
    int intRetCode = CREDITCARDACCOUNT_ERR_ANY_ERROR;
    mtmRetSession->GetProperty("retcode", intRetCode);
    
    delete mtmSession;
    
    if (CREDITCARDACCOUNT_SUCCESS != intRetCode)
    {
      // intRetCode is an hresult
      hr =  intRetCode;
      return hr;
    }
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  return hr;
}

HRESULT
MTPSAccountMgmt::ACH_ValidateBankInfo(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = S_OK;

  try
  {
    _bstr_t   bstrBankAccountNumber = aSession->GetStringProperty(mlngBankAccountNumber);
    _bstr_t decrypted;
    
    // the listener encrypts the credit card number once it arrives. the number
    // may contain hyphens or spaces. this code needs to decrypt, remove hyphens
    // and spaces, and encrypt before storing in the database.
    
    DecryptNumber(bstrBankAccountNumber);
    FormatCCNumber(bstrBankAccountNumber);
    
    //
    // Perform Prenote check
    //
    // NOTE: This routine is remetering the bank account number without specifying
    //       the trailing underscore in the bankaccountnumber property name. This is ok
    //       because the bank account number has already been encrypted by the listener
    //       upon receiving this service. 
    // BP 5/28: Changed the above to actually send bankaccountnumber_. The same was done for the credit card
    // validation service definition. The reason is we may want to use these services externally too. 
    //  So let's make the listener encrypt them rather then end user
    //
    
    _bstr_t bstrCustname               = aSession->GetStringProperty(mlngCustomerName);
    _bstr_t bstrAddr                   = aSession->GetStringProperty(mlngAddress);
    _bstr_t bstrCity                   = aSession->GetStringProperty(mlngCity);
    _bstr_t bstrState                  = aSession->GetStringProperty(mlngState);
    _bstr_t bstrZip                    = aSession->GetStringProperty(mlngZip);
    //country
    _bstr_t bstrCountry                = GetCountryName(aSession->GetStringProperty(mlngCountry));
    _bstr_t bstrBankName               = aSession->GetStringProperty(mlngBankName);
    long    lngAcctid                  = aSession->GetLongProperty(mlngAccountID);
    _bstr_t bstrRoutingNumber          = aSession->GetStringProperty(mlngRoutingNumber);
    long    lngAccountType             = aSession->GetLongProperty(mlngAccountType);
    
    // step 1: create a session
    MTMeterSession * mtmSession = mmtmMeter.CreateSession(
      (const char *)"metratech.com/ps_ach_prenote");
    
    mtmSession->SetResultRequestFlag(TRUE);
    mtmSession->InitProperty("customername", (const wchar_t *)bstrCustname);
    mtmSession->InitProperty("address", (const wchar_t *)bstrAddr);
    mtmSession->InitProperty("city", (const wchar_t *)bstrCity);
    mtmSession->InitProperty("state", (const wchar_t *)bstrState);
    mtmSession->InitProperty("zip", (const wchar_t *)bstrZip);
    mtmSession->InitProperty("country", (const wchar_t *)bstrCountry);
    mtmSession->InitProperty("_amount" , 0);
    mtmSession->InitProperty("_currency" , (const char *)"USD");
    mtmSession->InitProperty("bankname", (const wchar_t *)bstrBankName);
    mtmSession->InitProperty("_accountid", (int)lngAcctid);
    mtmSession->InitProperty("routingnumber", (const wchar_t *)bstrRoutingNumber);
    mtmSession->InitProperty("bankaccountnum_", (const wchar_t *)bstrBankAccountNumber);
    mtmSession->InitProperty("bankaccounttype", (const wchar_t *)GetEnumName(lngAccountType));
    mtmSession->InitProperty("testsession", (int)0);
    
    if (!mtmSession->Close())
    {
      char buff[1024] = "";
      int size=1024;
      MTMeterError * err = mtmSession->GetLastErrorObject();
      delete mtmSession;
      
      err->GetErrorMessageEx(buff,size);
      
      if(strcmp(buff,"") == 0)
      {
        unsigned long aErrorCode = err->GetErrorCode();
        sprintf(
          buff,
          "MTPSAccountMgmt::ACH_AddAccount: session->Close() failed with error %d",
          aErrorCode);
      }
      
      hr = err->GetErrorCode();
      return hr;
    }
    
    MTMeterSession * mtmRetSession = mtmSession->GetSessionResults();
    
    int intRetCode = CREDITCARDACCOUNT_ERR_ANY_ERROR;
    mtmRetSession->GetProperty("retcode", intRetCode);
    
    const char * chrRespString;
    mtmRetSession->GetProperty("respstring", &chrRespString); 
    _bstr_t bstrRespString(chrRespString);
    
    const char * chrPaymentServiceTransactionId;
    mtmRetSession->GetProperty("paymentservicetransactionid", &chrPaymentServiceTransactionId); 
    _bstr_t bstrPaymentServiceTransactionId(chrPaymentServiceTransactionId);
    
    delete mtmSession;
    
    if (CREDITCARDACCOUNT_SUCCESS != intRetCode)
    {
      // intRetCode is an hresult
      hr = intRetCode;
      return hr;
    }
    else
    {
      aSession->SetStringProperty(mlngRespString, bstrRespString);
      aSession->SetStringProperty(mlngPaymentServiceTransactionId, 
        bstrPaymentServiceTransactionId);
    }
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  return hr;
}

//
// Current assumption is that this is only called by update.
// Therefore, generating an exception while accessing the credit 
// card when no rows returned is intentional.
//

HRESULT
MTPSAccountMgmt::InternalLookupCCByAcctidLast4Type(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;

  try
  {
    
    long    lngAcctid          = aSession->GetLongProperty(mlngAccountID);
    _bstr_t bstrLastFourDigits = aSession->GetStringProperty(mlngLastFourDigits);
    long    lngCctype          = aSession->GetLongProperty(mlngCreditCardType);
    
    pRowset->ClearQuery();
    
    // set the query tag ...
    _bstr_t queryTag = "__SELECT_BY_ID_CCTYPE_LAST4__" ;
    pRowset->SetQueryTag (queryTag) ;
    
    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    
    vtParam = bstrLastFourDigits;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
    
    vtParam = (long) lngCctype;
    pRowset->AddParam (MTPARAM_CREDITCARDTYPE, vtParam) ;
    
    // execute the query ...
    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;
    
    if (0 < pRowset->GetRecordCount())
    {
      _variant_t vtCCNum = pRowset->GetValue(DB_CREDITCARDNUMBER);
      _bstr_t    bstrCCNum(vtCCNum);
      aSession->SetStringProperty(mlngCreditCardNum, bstrCCNum);
      
      _variant_t vtSecCode = pRowset->GetValue("nm_ccseccode");

      if(V_VT(&vtSecCode) != VT_NULL)
        aSession->SetStringProperty(mlngCreditCardSecCode, (_bstr_t)vtSecCode);

			_variant_t vtStartDate = pRowset->GetValue("nm_startdate");

      if(V_VT(&vtStartDate) != VT_NULL)
        aSession->SetStringProperty(mlngStartDate, (_bstr_t)vtStartDate);

			_variant_t vtIssuerNumber = pRowset->GetValue("nm_issuernumber");

      if(V_VT(&vtIssuerNumber) != VT_NULL)
        aSession->SetStringProperty(mlngIssuerNumber, (_bstr_t)vtIssuerNumber);
    }
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  return hr;
}

HRESULT
MTPSAccountMgmt::InternalLookupCCByAcctid(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  _variant_t vtParam;
  HRESULT    hr = S_OK;
  try
  {
    
    long lngAcctid = aSession->GetLongProperty(mlngAccountID);
    
    pRowset->ClearQuery();
    
    // set the query tag ...
    _bstr_t queryTag = "__SELECT_ALL_CC_BY_ID__" ;
    pRowset->SetQueryTag (queryTag) ;
    
    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    
    // execute the query ...
    pRowset->Execute();
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  
  return hr;
}

//
// Current assumption is that this is only called by update.
// Therefore, generating an exception while accessing the credit 
// card when no rows returned is intentional.
//

HRESULT
MTPSAccountMgmt::InternalLookupACHByAcctidRoutingNumberLast4Type(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  HRESULT    hr = S_OK;

  try
  {
    long       lngAcctid          = aSession->GetLongProperty(mlngAccountID);
    _bstr_t    bstrRoutingNumber  = aSession->GetStringProperty(mlngRoutingNumber);
    _bstr_t    bstrLastFourDigits = aSession->GetStringProperty(mlngLastFourDigits);
    long       lngAccountType     = aSession->GetLongProperty(mlngAccountType);
    _variant_t vtParam;
    
    
    pRowset->ClearQuery();
    
    // set the query tag ...
    _bstr_t queryTag = "__SELECT_BY_ID_ACHTYPE_LAST4__" ;
    pRowset->SetQueryTag (queryTag) ;
    
    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    
    vtParam = bstrRoutingNumber;
    pRowset->AddParam (MTPARAM_ROUTINGNUMBER, vtParam) ;
    
    vtParam = bstrLastFourDigits;
    pRowset->AddParam (MTPARAM_LASTFOURDIGITS, vtParam) ;
    
    vtParam = (long) lngAccountType;
    pRowset->AddParam (MTPARAM_ACCOUNTTYPE, vtParam) ;
    
    // execute the query ...
    pRowset->Execute();
    
    if (0 < pRowset->GetRecordCount())
    {
      _variant_t vtAccountNum = pRowset->GetValue(DB_ACCOUNTNUMBER);
      _bstr_t    bstrBankAccountNum(vtAccountNum);
      aSession->SetStringProperty(mlngBankAccountNumber, bstrBankAccountNum);
    }
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  return hr;
}

HRESULT
MTPSAccountMgmt::UpdateAuthorization(MTPipelineLib::IMTSessionPtr aSession) {
  HRESULT   hr = S_OK;

  try
  {
    hr = LogAttempt(aSession, "UpdateAuthorization", "update", MT_ACCOUNT);
    if (FAILED(hr))
      return hr;

    IMTSQLRowsetPtr pRowset;
    pRowset = aSession->GetRowset(mbstrConfigPath);

		//determines which table (ACH or CC) to update
		long lngPaymentType = aSession->GetEnumProperty(mlngPaymentType);
		if (lngPaymentType == mEnumACHPaymentType)
			hr = UpdateACHAuthorizationInternal(aSession, pRowset);
		else if (lngPaymentType == mEnumCCPaymentType)
			hr = UpdateCCAuthorizationInternal(aSession, pRowset);
		else
			hr = E_FAIL;

    if (FAILED(hr))
      return hr;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

 
//  aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);
	return hr;
}

HRESULT
MTPSAccountMgmt::UpdateCCAuthorizationInternal(MTPipelineLib::IMTSessionPtr aSession,
                                             ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  HRESULT    hr = S_OK;
  _variant_t vtParam;

  try
  {
    
    //gets the primary keys for t_ps_creditcard table
    long    lngAcctid                   = aSession->GetLongProperty(mlngAccountID);
    long    lngCctype                   = aSession->GetLongProperty(mlngCreditCardType);
    _bstr_t bstrLastFourDigits         = aSession->GetStringProperty(mlngLastFourDigits);
    
    //sets up the query
    pRowset->ClearQuery();
    _bstr_t queryTag = "__UPDATE_AUTHRECEIVED_T_PS_CREDITCARD_TABLE__" ;
    pRowset->SetQueryTag(queryTag);
    
    vtParam = (long) lngAcctid;
    pRowset->AddParam(MTPARAM_ACCOUNTID, vtParam);
    
    vtParam = bstrLastFourDigits;
    pRowset->AddParam(MTPARAM_LASTFOURDIGITS, vtParam);
    
    vtParam = (long) lngCctype;
    pRowset->AddParam(MTPARAM_CREDITCARDTYPE, vtParam);
    
    //performs the update  
    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;
    pRowset->Clear();
    
    //audits this operation
    hr = Audit(aSession,
      pRowset,
      lngAcctid,
      (const char *)"update CC authorization",
      (const char *)"",
      (const char *)bstrLastFourDigits,
      (const char *)"",
      (const char *)"",
      (const char *)"",
      0,
      (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
      (const char *)"",                // phonenumber
      (const char *)"",                // CSRIP
      (const char *)"",                // CSRID
      (const char *)"");
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }
          
  return hr;
}

HRESULT
MTPSAccountMgmt::UpdateACHAuthorizationInternal(MTPipelineLib::IMTSessionPtr aSession,
																								ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  HRESULT    hr = S_OK;
  _variant_t vtParam;

  try
  {
    
    //gets the where criteria for t_ps_ach table
    long    lngAcctid                  = aSession->GetLongProperty(mlngAccountID);
    _bstr_t bstrRoutingNumber          = aSession->GetStringProperty(mlngRoutingNumber);
    long    lngAccountType             = aSession->GetEnumProperty(mlngAccountType);
    _bstr_t bstrLastFourDigits         = aSession->GetStringProperty(mlngLastFourDigits);
    
    
    //sets up the query
    pRowset->ClearQuery();
    _bstr_t queryTag = "__UPDATE_AUTHRECEIVED_T_PS_ACH_TABLE__" ;
    pRowset->SetQueryTag(queryTag);
    
    vtParam = (long) lngAcctid;
    pRowset->AddParam(MTPARAM_ACCOUNTID, vtParam);
    
    vtParam = bstrRoutingNumber;
    pRowset->AddParam(MTPARAM_ROUTINGNUMBER, vtParam);
    
    vtParam = lngAccountType;
    pRowset->AddParam(MTPARAM_ACCOUNTTYPE, vtParam);
    
    vtParam = bstrLastFourDigits;
    pRowset->AddParam(MTPARAM_LASTFOURDIGITS, vtParam);
    
    //performs the update  
    hr = pRowset->Execute();
    if (FAILED(hr))
      return hr;
    pRowset->Clear();
    
    //audits this operation
    hr = Audit(aSession,
      pRowset,
      lngAcctid,
      (const char *)"update ACH authorization",
      (const char *)bstrRoutingNumber,
      (const char *)bstrLastFourDigits,
      (const char *)"",
      (const char *)"",
      (const char *)"",
      0,
      (const char *)aSession->GetStringProperty(mlngIpAddress),  // subscriber ID
      (const char *)"",                // phonenumber
      (const char *)"",                // CSRIP
      (const char *)"",                // CSRID
      (const char *)"");
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }
          
  return hr;
}


HRESULT
MTPSAccountMgmt::InternalLookupACHByAcctid(
                   MTPipelineLib::IMTSessionPtr aSession,
                   ROWSETLib::IMTSQLRowsetPtr   pRowset)
{
  HRESULT hr = S_OK;

  try
  {
    long lngAcctid = aSession->GetLongProperty(mlngAccountID);
    
    _variant_t vtParam;
    
    
    pRowset->ClearQuery();
    
    // set the query tag ...
    _bstr_t queryTag = "__SELECT_ALL_ACH_BY_ID__" ;
    pRowset->SetQueryTag (queryTag) ;
    
    // add the parameters ...
    vtParam = (long) lngAcctid;
    pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    
    // execute the query ...
    pRowset->Execute();
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }
  
  return hr;
}

HRESULT
MTPSAccountMgmt::Audit(MTPipelineLib::IMTSessionPtr aSession,
                       ROWSETLib::IMTSQLRowsetPtr   pRowset,
                       long                         acctid,
                       const char                 * action,
                       const char                 * routingnumber,
                       const char                 * last4,
                       const char                 * accounttype,
                       const char                 * bankname,
                       const char                 * expdate,
                       long                         expdatef,
                       const char                 * subscriberid,
                       const char                 * phonenumber,
                       const char                 * csrip,
                       const char                 * csrid,
                       const char                 * notes)
{
  HRESULT hr = S_OK; 
  BOOL    blnRet; 

  try
  {
    
    pRowset->ClearQuery();
    
    blnRet = mAudit.Insert(pRowset,
      acctid,
      action,
      routingnumber,
      last4,
      accounttype,
      bankname,
      expdate,
      expdatef,
      subscriberid,
      phonenumber,
      csrip,
      csrid,
      notes);
    
    if (!blnRet)
    {
      char LogBuf[1024];
      
      sprintf(LogBuf,
        "Unable to audit action (%s) with notes (%s) for accid (%d) last4 (%s) and type (%s)",
        action,
        notes,
        acctid,
        last4,
        accounttype);
      
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, LogBuf);
      
    }
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  return hr;
}

void
MTPSAccountMgmt::DecryptNumber(MTPipelineLib::IMTSessionPtr aSession, long alngPropId)
{
  _bstr_t bstrEncryptedNum = aSession->GetStringProperty(alngPropId);
  DecryptNumber(bstrEncryptedNum);
  aSession->SetStringProperty(alngPropId, bstrEncryptedNum);
  return;
}

void
MTPSAccountMgmt::DecryptNumber(_bstr_t & abstrNum)
{
  // the listener encrypts the credit card number once it arrives. the number
  // may contain hyphens or spaces. this code needs to decrypt, remove hyphens
  // and spaces, and encrypt before storing in the database.

  // decrypt the credit card number from the session

  HRESULT hr(S_OK);
	string sPlainText = (char*)abstrNum;
  int result = mCrypto.Decrypt(sPlainText);
  if (result != 0)
  {
    char chrBuf[1024];

    sprintf(chrBuf, 
            "Unable to decrypt card number: %x: %s",
            result,
            mCrypto.GetCryptoApiErrorString());

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, chrBuf);
    MT_THROW_COM_ERROR(CREDITCARDACCOUNT_FAILED_TO_DECRYPT_ACCOUNT_NUMBER, result);
  }

  // got the number, now remove embedded characters

  _bstr_t formattedccnum = sPlainText.c_str();
  FormatCCNumber(formattedccnum);
  abstrNum = formattedccnum;
} 

//
// Assumes that the account number is already decrypted.
//
BOOL
MTPSAccountMgmt::AddLastFourDigits(MTPipelineLib::IMTSessionPtr aSession, long alngPropId)
{
  _bstr_t bstrAccountNum = aSession->GetStringProperty(alngPropId);

  string sLastFourDigits;
  sLastFourDigits = (char*)bstrAccountNum; 

  GetLastFourDigits(sLastFourDigits);

  aSession->SetStringProperty(mlngLastFourDigits, sLastFourDigits.c_str());

  return TRUE;
}

void
MTPSAccountMgmt::FormatCCNumber(wstring & unformatted)
{
  static basic_string <char>::size_type idx;

  // throw exception if credit card number is invalid

  while (wstring::npos != (idx = unformatted.find_first_of(L"- ")))
  {
    unformatted.erase(idx, 1);
  }
 
  return;
}

void
MTPSAccountMgmt::FormatCCNumber(_bstr_t & unformatted)
{
  wstring out = (wchar_t*)unformatted;
  FormatCCNumber(out);
	unformatted = out.c_str();
}

//
// The credit card number in the session may have embedded characters. These
// characters must be removed to provide a consistent cc number. This routine
// decrypts the cc number, reformats the string, and then encrypts. While
// we're at it, return the last four digits as well. 
//
HRESULT
MTPSAccountMgmt::FormatNumber(
  _bstr_t   & ccnum,
	_bstr_t   & aDecryptedNumber,
  string & lastfourdigits)
{
  // decrypt the credit card number from the session

  _bstr_t encryptedccnum = ccnum;
	DecryptNumber(encryptedccnum);
  
  // got the number, now remove embedded characters

  _bstr_t formattedccnum = encryptedccnum;
  FormatCCNumber(formattedccnum);

	aDecryptedNumber = formattedccnum;

  // get the trailing digits

  lastfourdigits = (char*)formattedccnum;
  GetLastFourDigits(lastfourdigits);

  // encrypt and uuencode the scrubbed cc number

  std::string  sEncryptString = (char*)formattedccnum;
  
  int result = mCrypto.Encrypt(sEncryptString);
  
  if (result != 0)
  {
    char chrBuf[1024];

    sprintf(chrBuf, 
            "Unable to re-encrypt card number: %x: %s",
            result,
            mCrypto.GetCryptoApiErrorString());
   MT_THROW_COM_ERROR(CREDITCARDACCOUNT_FAILED_TO_ENCRYPT_ACCOUNT_NUMBER, result);
  }

  ccnum = sEncryptString.c_str();

  return S_OK;
}

void
MTPSAccountMgmt::GetLastFourDigits(string & lastfourdigits)
{
  lastfourdigits.erase(0, lastfourdigits.length() - 4);

  return;
}

//
// This routine is a generic date parser. I took a stab at possible date 
// formats.  
//
BOOLEAN
MTPSAccountMgmt::IsSuppliedExpDateNewer(
  _bstr_t SuppliedDate,
  _bstr_t StoredDate,
  CREDITCARDLib::MTExpDateFormat Format)
{
  static char SuppliedDateBuf[MT_STD_MEMBER_LEN];
  static char StoredDateBuf[MT_STD_MEMBER_LEN];
  char SuppliedMonth[10];  // longest month plus terminating null
  char StoredMonth[10];  // longest month plus terminating null
  int  MonthLen;
  char SuppliedYear[6];    // 5 digit year (Y10K) plus terminatin null 
  char StoredYear[6];    // 5 digit year (Y10K) plus terminatin null 
  int  YearLen;

  if (SuppliedDate == StoredDate)
    return FALSE;

  strcpy(SuppliedDateBuf, (const char *)SuppliedDate);
  strcpy(StoredDateBuf, (const char *)StoredDate);

  int InLen = strlen((const char *)SuppliedDate);
  int StoredInLen = strlen((const char *)StoredDate);

  if (InLen != StoredInLen)
    return FALSE;

  switch (Format)
  {
    case CREDITCARDLib::MT_YYMM:

      if (4 != InLen) 
          return FALSE;

      YearLen = 2;
      SuppliedYear[0] = SuppliedDateBuf[0];
      SuppliedYear[1] = SuppliedDateBuf[1];
      SuppliedYear[2] = '\0';
      StoredYear[0]   = StoredDateBuf[0];
      StoredYear[1]   = StoredDateBuf[1];
      StoredYear[2]   = '\0';
 
      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[2];
      SuppliedMonth[1] = SuppliedDateBuf[3];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0]   = StoredDateBuf[2];
      StoredMonth[1]   = StoredDateBuf[3];
      StoredMonth[2]   = '\0'; 

      break;

    case CREDITCARDLib::MT_MMYY:

      if (4 != InLen) 
          return FALSE;

      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[0];
      SuppliedMonth[1] = SuppliedDateBuf[1];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0]   = StoredDateBuf[0];
      StoredMonth[1]   = StoredDateBuf[1];
      StoredMonth[2]   = '\0'; 

      YearLen = 2;
      SuppliedYear[0] = SuppliedDateBuf[2];
      SuppliedYear[1] = SuppliedDateBuf[3];
      SuppliedYear[2] = '\0';
      StoredYear[0]   = StoredDateBuf[2];
      StoredYear[1]   = StoredDateBuf[3];
      StoredYear[2]   = '\0';
 
      break;

    case CREDITCARDLib::MT_YYYYMM:

      if (6 != InLen) 
          return FALSE;

      YearLen = 4;
      SuppliedYear[0] = SuppliedDateBuf[0];
      SuppliedYear[1] = SuppliedDateBuf[1];
      SuppliedYear[2] = SuppliedDateBuf[2];
      SuppliedYear[3] = SuppliedDateBuf[3];
      SuppliedYear[4] = '\0';
      StoredYear[0]   = StoredDateBuf[0];
      StoredYear[1]   = StoredDateBuf[1];
      StoredYear[2]   = StoredDateBuf[2];
      StoredYear[3]   = StoredDateBuf[3];
      StoredYear[4]   = '\0';
 
      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[4];
      SuppliedMonth[1] = SuppliedDateBuf[5];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0]   = StoredDateBuf[4];
      StoredMonth[1]   = StoredDateBuf[5];
      StoredMonth[2]   = '\0'; 

      break;

    case CREDITCARDLib::MT_MMYYYY:

      if (6 != InLen) 
          return FALSE;

      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[0];
      SuppliedMonth[1] = SuppliedDateBuf[1];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0]   = StoredDateBuf[0];
      StoredMonth[1]   = StoredDateBuf[1];
      StoredMonth[2]   = '\0'; 

      YearLen = 4;
      SuppliedYear[0] = SuppliedDateBuf[2];
      SuppliedYear[1] = SuppliedDateBuf[3];
      SuppliedYear[2] = SuppliedDateBuf[4];
      SuppliedYear[3] = SuppliedDateBuf[5];
      SuppliedYear[4] = '\0'; 
      StoredYear[0]   = StoredDateBuf[2];
      StoredYear[1]   = StoredDateBuf[3];
      StoredYear[2]   = StoredDateBuf[4];
      StoredYear[3]   = StoredDateBuf[5];
      StoredYear[4]   = '\0'; 
 
      break;

    case CREDITCARDLib::MT_MM_slash_YY:

      if (5 != InLen)
          return FALSE;

      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[0];
      SuppliedMonth[1] = SuppliedDateBuf[1];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0] = StoredDateBuf[0];
      StoredMonth[1] = StoredDateBuf[1];
      StoredMonth[2] = '\0'; 

      YearLen = 2;
      SuppliedYear[0] = SuppliedDateBuf[3];
      SuppliedYear[1] = SuppliedDateBuf[4];
      SuppliedYear[2] = '\0';
      StoredYear[0]   = StoredDateBuf[3];
      StoredYear[1]   = StoredDateBuf[4];
      StoredYear[2]   = '\0';
 
      break;

    case CREDITCARDLib::MT_YY_slash_MM:

      if (5 != InLen) 
          return FALSE;

      YearLen = 2;
      SuppliedYear[0] = SuppliedDateBuf[0];
      SuppliedYear[1] = SuppliedDateBuf[1];
      SuppliedYear[2] = '\0'; 
      StoredYear[0]   = StoredDateBuf[0];
      StoredYear[1]   = StoredDateBuf[1];
      StoredYear[2]   = '\0'; 

      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[3];
      SuppliedMonth[1] = SuppliedDateBuf[4];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0]   = StoredDateBuf[3];
      StoredMonth[1]   = StoredDateBuf[4];
      StoredMonth[2]   = '\0'; 
 
      break;

    case CREDITCARDLib::MT_MM_slash_YYYY:

      if (7 != InLen) 
          return FALSE;

      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[0];
      SuppliedMonth[1] = SuppliedDateBuf[1];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0]   = StoredDateBuf[0];
      StoredMonth[1]   = StoredDateBuf[1];
      StoredMonth[2]   = '\0'; 

      YearLen = 4;
      SuppliedYear[0] = SuppliedDateBuf[3];
      SuppliedYear[1] = SuppliedDateBuf[4];
      SuppliedYear[2] = SuppliedDateBuf[5];
      SuppliedYear[3] = SuppliedDateBuf[6];
      SuppliedYear[4] = '\0'; 
      StoredYear[0]   = StoredDateBuf[3];
      StoredYear[1]   = StoredDateBuf[4];
      StoredYear[2]   = StoredDateBuf[5];
      StoredYear[3]   = StoredDateBuf[6];
      StoredYear[4]   = '\0'; 
 
      break;

    case CREDITCARDLib::MT_YYYY_slash_MM:

      if (7 != InLen) 
          return FALSE;

      YearLen = 4;
      SuppliedYear[0] = SuppliedDateBuf[0];
      SuppliedYear[1] = SuppliedDateBuf[1];
      SuppliedYear[2] = SuppliedDateBuf[2];
      SuppliedYear[3] = SuppliedDateBuf[3];
      SuppliedYear[4] = '\0'; 
      StoredYear[0]   = StoredDateBuf[0];
      StoredYear[1]   = StoredDateBuf[1];
      StoredYear[2]   = StoredDateBuf[2];
      StoredYear[3]   = StoredDateBuf[3];
      StoredYear[4]   = '\0'; 

      MonthLen = 2;
      SuppliedMonth[0] = SuppliedDateBuf[5];
      SuppliedMonth[1] = SuppliedDateBuf[6];
      SuppliedMonth[2] = '\0'; 
      StoredMonth[0]   = StoredDateBuf[5];
      StoredMonth[1]   = StoredDateBuf[6];
      StoredMonth[2]   = '\0'; 
 
      break;

    default:
      // format not supported
      return FALSE;
  }

  int iSuppliedMonth = atoi(SuppliedMonth);
  int iSuppliedYear  = atoi(SuppliedYear);
  int iStoredMonth   = atoi(StoredMonth);
  int iStoredYear    = atoi(StoredYear);

  if (iSuppliedYear < 1000)
  {
    // This app will run for 50 years.
    if (iSuppliedYear < 50)
      iSuppliedYear += 2000;
    else
      iSuppliedYear += 1900;
  }

  if (iStoredYear < 1000)
  {
    // This app will run for 50 years.
    if (iStoredYear < 50)
      iStoredYear += 2000;
    else
      iStoredYear += 1900;
  }

  // first test the years
  if (iSuppliedYear > iStoredYear)
    return TRUE; 

  if (iSuppliedYear < iStoredYear)
    return FALSE;
 
  // at this point, the supplied year must be equal to the stored year, so
  // now the months
  if (iSuppliedMonth > iStoredMonth)
    return TRUE;

  return FALSE;
}

_bstr_t
MTPSAccountMgmt::GetEnumName(long alngType)
{
  _bstr_t bstrEnum("");

  if (alngType)
    bstrEnum = mEnumConfig->GetEnumeratorByID(alngType);

  return bstrEnum; 
}

HRESULT
MTPSAccountMgmt::LogAttempt(MTPipelineLib::IMTSessionPtr aSession,
                            _bstr_t                      bstrLogString,
                            _bstr_t                      bstrAction,
                            long                         alngCategory)
{
  HRESULT hr = S_OK;
  char LogBuf[1024];

  try
  {
    
    if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
    {
      _bstr_t bstrCategory;
      
      if (MT_BOTH == alngCategory)
        bstrCategory = (const char *)"account and payment method";
      else if (MT_PAYMENTMETHOD == alngCategory)
        bstrCategory = (const char *)"payment method";
      else if (MT_ACCOUNT == alngCategory)
        bstrCategory = (const char *)"account";
      else
        bstrCategory = (const char *)"[unknown add type]";
      
      // the listener encrypts the credit card number once it arrives. the number
      // may contain hyphens or spaces. this code needs to decrypt, remove hyphens
      // and spaces, and encrypt before storing in the database.
      
      long lngAcctid = aSession->GetLongProperty(mlngAccountID);
      
      _bstr_t bstrAccountNum;
      long    lngAccountType;
      
      if (MT_ACCOUNT != alngCategory)
      {
        if(aSession->PropertyExists(mlngCreditCardNum, MTPipelineLib::SESS_PROP_TYPE_STRING))
          bstrAccountNum = aSession->GetStringProperty(mlngCreditCardNum);
        else
          bstrAccountNum = aSession->GetStringProperty(mlngBankAccountNumber);
  
        if(aSession->PropertyExists(mlngCreditCardType, MTPipelineLib::SESS_PROP_TYPE_ENUM))
          lngAccountType = aSession->GetLongProperty(mlngCreditCardType);
        else
          lngAccountType = aSession->GetLongProperty(mlngAccountType);
        
        string sLastFourDigits;
        _bstr_t decrypted;
        
        hr = FormatNumber(bstrAccountNum, decrypted, sLastFourDigits);
        if (FAILED(hr))
          return hr;
        
        sprintf(
          LogBuf,
          "%s: Attempting to %s %s payment information for "
          "account id %d type %d and last four digits %s.",
          (const char *)bstrLogString,
          (const char *)bstrAction,
          (const char *)bstrCategory,
          lngAcctid,
          lngAccountType,
          sLastFourDigits.c_str());
      }
      else
      {
        sprintf(
          LogBuf,
          "%s: Attempting to %s %s payment information for "
          "account id %d.",
          (const char *)bstrLogString,
          (const char *)bstrAction,
          (const char *)bstrCategory,
          lngAcctid);
      }
      
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, LogBuf);
    }
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  return hr;
}

HRESULT
MTPSAccountMgmt::LogAttempt(MTPipelineLib::IMTSessionPtr aSession,
                            _bstr_t                      bstrLogString,
                            _bstr_t                      bstrAction)
{
  HRESULT hr = S_OK;
  char LogBuf[1024];

  try
  {
    
    if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
    {
      long    lngAcctid          = aSession->GetLongProperty(mlngAccountID);
      _bstr_t bstrLastFourDigits = aSession->GetStringProperty(mlngLastFourDigits);
      long    lngAccountType;

      if(aSession->PropertyExists(mlngCreditCardType, MTPipelineLib::SESS_PROP_TYPE_ENUM))
        lngAccountType = aSession->GetLongProperty(mlngCreditCardType);
      else
        lngAccountType = aSession->GetLongProperty(mlngAccountType);
      
      sprintf(
        LogBuf,
        "%s: Attempting to %s payment information for "
        "account id %d type %d and last four digits %s.",
        (const char *)bstrLogString,
        (const char *)bstrAction,
        lngAcctid,
        lngAccountType,
        (const char *)bstrLastFourDigits);
      
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, LogBuf);
    }
  }
  catch(_com_error& e)
  {
    _bstr_t message = e.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    return ReturnComError(e);
  }

  return hr;
}

HRESULT
MTPSAccountMgmt::GetInternalCCType(const long& aType, CREDITCARDLib::MTCreditCardType& aInternalType)
{
	HRESULT hr(S_OK);
	_bstr_t enumerator = GetEnumName(aType);

	if(!wcsicmp((wchar_t*)enumerator, L"Visa"))
	{
		aInternalType = CREDITCARDLib::MT_VISA;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"MasterCard"))
	{
		aInternalType = CREDITCARDLib::MT_MASTERCARD;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"American Express"))
	{
		aInternalType = CREDITCARDLib::MT_AMERICAN_EXPRESS;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"Discover"))
	{
		aInternalType = CREDITCARDLib::MT_DISCOVER;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"JCB"))
	{
		aInternalType = CREDITCARDLib::MT_JCB;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"Diners Club"))
	{
		aInternalType = CREDITCARDLib::MT_DINERS;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"Visa - Purchase Card") ||
		!wcsicmp((wchar_t*)enumerator, L"Visa - Purchase Card Intl"))
	{
		aInternalType = CREDITCARDLib::MT_VISA_PCARD;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"MasterCard - Purchase Card") ||
		!wcsicmp((wchar_t*)enumerator, L"MasterCard - Purchase Card Intl"))
	{
		aInternalType = CREDITCARDLib::MT_MASTERCARD_PCARD;
		return hr;
	}
	if(!wcsicmp((wchar_t*)enumerator, L"American Express - Purchase Card") ||
		!wcsicmp((wchar_t*)enumerator, L"American Express - Purchase Card Intl"))
	{
		aInternalType = CREDITCARDLib::MT_AMERICAN_EXPRESS_PCARD;
		return hr;
	}
	// g. cieplik 12/12/07 add processing for Maestro debit cards
	if(!wcsicmp((wchar_t*)enumerator, L"Maestro"))
	{
		aInternalType = CREDITCARDLib::MT_MAESTRO;
		return hr;
	}
	char LogBuf[1024];
	sprintf(LogBuf, "Unsupported Credit Card Type: <%s> (enum file changed?)", (char*)enumerator);
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, LogBuf);
	return E_FAIL;

}
HRESULT
MTPSAccountMgmt::GetComError(CREDITCARDLib::MTCreditCardErrorMsg& aMsg)
{
	switch(aMsg)
	{
		case CREDITCARDLib::MT_CC_ERROR_INVALID_NUM_DIGITS:
			return CREDITCARDACCOUNT_ERR_INVALID_NUM_DIGITS;
		case CREDITCARDLib::MT_CC_ERROR_NON_NUMERIC_CHARACTER:
			return CREDITCARDACCOUNT_ERR_NON_NUMERIC_CHARACTER;
		case CREDITCARDLib::MT_CC_ERROR_CARD_TYPE_MISMATCH:
			return CREDITCARDACCOUNT_ERR_CARD_TYPE_MISMATCH;
		case CREDITCARDLib::MT_CC_ERROR_CHECKSUM:
			return CREDITCARDACCOUNT_ERR_CHECKSUM;
		case CREDITCARDLib::MT_CC_ERROR_INVALID_EXP_DATE:
			return CREDITCARDACCOUNT_ERR_INVALID_EXP_DATE;
		case CREDITCARDLib::MT_CC_ERROR_CARD_EXPIRED:
			return CREDITCARDACCOUNT_ERR_CARD_EXPIRED;
		case CREDITCARDLib::MT_CC_ERROR_REQUIRED_AVS_FIELD_MISSING:
			return CREDITCARDACCOUNT_ERR_REQUIRED_AVS_FIELD_MISSING;
		default:
			return CREDITCARDACCOUNT_ERR_ANY_ERROR;
	}
}

_bstr_t
MTPSAccountMgmt::GetCountryName(const _bstr_t& aEnum)
{
	long lID = mEnumConfig->GetID("Global", "CountryName", aEnum);
  return mEnumConfig->GetEnumeratorValueByID(lID);
}

