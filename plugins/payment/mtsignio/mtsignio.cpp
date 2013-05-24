/*
 * @doc SIMPLE
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
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 * Modified by: David McCowan 04/03/00
 *   Use Derek's template.
 *
 * $Date: 10/8/2002 10:36:00 AM$
 * $Author: Derek Young$
 * $Revision: 26$
 ***************************************************************************/

#include <mtcom.h>
#include <PlugInSkeleton.h>
#include <base64.h>
#include <mtparamnames.h>
#include <mtprogids.h>
#include <securestore.h>
#include <MTUtil.h>
#include <paymentserverdefs.h>
#include <mtglobal_msg.h>
#include <NTLogger.h>
#include <reservedproperties.h>
#include <ConfigDir.h>
#include <loggerconfig.h>
#include <MTDec.h>

#import <MTConfigLib.tlb>
#import <MTEnumConfigLib.tlb> 

#include <pfpro.h>

#include <vector>

using namespace std;

// import the credit card tlb file
#import <CreditCard.tlb>
using namespace CREDITCARDLib;

#define MT_SIGNIO_RESPONSE_STRING_LEN 1024

struct CreditCardField
{
public:
  _bstr_t       bstrName;
  _bstr_t       bstrSessionProp;
  long          lngSessionPropId;
  _bstr_t       bstrType;
  unsigned long lngMinLength;
  unsigned long lngMaxLength;
  bool IsRequired;
};

class SignioReturnObject
{
public:
  SignioReturnObject() : mCVV2Match("NotFound") {} 
  BOOLEAN Initialize(char * achrString);

  long        GetResult();
  _bstr_t& GetPnref();
  _bstr_t& GetResponseMessage();
  _bstr_t& GetAuthCode();
  _bstr_t& GetAvsAddr();
  _bstr_t& GetAvsZip();
  _bstr_t& GetCVV2Match();
  long        GetOriginalResult();
  _bstr_t& GetStatus();

private:

  long mlngResult;
  _bstr_t msPnref;
  _bstr_t msResponseMessage;
  _bstr_t msRetCode;
  _bstr_t msAvsAddr;
  _bstr_t msAvsZip;
  _bstr_t mCVV2Match;
  long    mlngOriginalResult;
  _bstr_t msStatus;
}; 

typedef std::vector<CreditCardField> CreditCardFieldList;
bool operator==(CreditCardField a, CreditCardField b) { ASSERT(false); return false; }

struct CreditCard
{
public:
  _bstr_t             bstrCardType;
  CreditCardFieldList cflFieldList;
};

typedef std::vector<CreditCard> CreditCardList;
bool operator==(CreditCard a, CreditCard b) { ASSERT(false); return false; }

// generate using uuidgen
CLSID CLSID_mtsignio = { /* 98137040-099c-11d4-a707-00c04f58c76e */
    0x98137040,
    0x099c,
    0x11d4,
    {0xa7, 0x07, 0x00, 0xc0, 0x4f, 0x58, 0xc7, 0x6e}
  };

class ATL_NO_VTABLE mtsignio
	: public MTPipelinePlugIn<mtsignio, &CLSID_mtsignio>
{
public:
  mtsignio();

protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);
 
private:

  // transaction formats
  CreditCardList mcclCardList;

  // The problem with storing the transction formats in ordered vectors
  // is that I need to sequentially search for information. These are
  // property ids that I store off for use outside of building the
  // transaction. 
  long mlngAccountNumberPropId;
  long mlngTransactionTypePropId;
  long mlngTransactionIdPropId;
  long mlngZipPropId;
  long mlngBillingAddressPropId;
 
  // input properties - other
  long mlngTestSession;
  long mlngHitCard;
  long mlngAccountType;
  long mlngPrimary;
  long mlngEnabled;

  // output properties
  long mlngRetCode;
  long mlngResponseString;
  long mlngPnref;
  long mlngOriginalId;
  long mlngOriginalResult;
  long mlngStatus;
  long mlngCreditCardSecCode;

  //verisign session context
  int mContext;
	bool mContextInitialized;

  long            mlngExpDateFormat;
  _bstr_t         msAccountType;
  long            mlngRetAuthCode;
  _bstr_t       msResponseString;
  _bstr_t       msAnsStr;
  std::string       msReqStr;
  _bstr_t         mLoggedRequestStr;

  _bstr_t       msUsername;
  _bstr_t       msPassword;
  _bstr_t         mPartner;

  //
  // signio specific config parameters
  // read from signio.xml
  //

  _bstr_t   msHostAddress;
  long      mlngHostPort;
  long      mlngSignioTimeout;
  _bstr_t   msProxyAddress;
  long      mlngProxyPort;
  _bstr_t   msProxyLogin;
  _bstr_t   msProxyPassword;
  _bstr_t   msAvsSupportLevel;
  _bstr_t   msPostauthError;

	NTLogger mntlLogger;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

  void         mtsignio::MTGetLastErrorString(TCHAR * atchBuf, int aintError, int aintLen);

  int          mtsignio::ProcessTransaction(MTPipelineLib::IMTSessionPtr aSession);

  const char * mtsignio::InternalParseExpDate(_bstr_t       & asDate,
                                              MTExpDateFormat   amdfInFormat,
                                              MTExpDateFormat   amdfOutFormat);

  int          mtsignio::AddressVerification(MTPipelineLib::IMTSessionPtr aSession,
                                             SignioReturnObject & sroObject);
  HRESULT          mtsignio::VerifyCVV2Match(MTPipelineLib::IMTSessionPtr aSession,
                                             SignioReturnObject & sroObject);

  void         mtsignio::ClearNumber(MTPipelineLib::IMTSessionPtr aSession);

  _bstr_t      mtsignio::GetTransactionType(MTPipelineLib::IMTSessionPtr aSession);

  _bstr_t      mtsignio::GetZip(MTPipelineLib::IMTSessionPtr aSession);

  _bstr_t      mtsignio::GetBillingAddress(MTPipelineLib::IMTSessionPtr aSession);

  void         mtsignio::SetTransactionType(MTPipelineLib::IMTSessionPtr aSession,
                                            const char * aType);

  void         mtsignio::SetExpDateFormat(MTPipelineLib::IMTSessionPtr aSession,
                                          long aFormat);

  // transaction builder methods
  int mtsignio::AddStringType(MTPipelineLib::IMTSessionPtr aSession,
                              struct CreditCardField & aField);

  int mtsignio::AddNumberType(MTPipelineLib::IMTSessionPtr aSession,
                              struct CreditCardField & aField);

  int mtsignio::AddNumberStringType(MTPipelineLib::IMTSessionPtr aSession,
                                    struct CreditCardField & aField);

  int mtsignio::AddFloatType(MTPipelineLib::IMTSessionPtr aSession,
                             struct CreditCardField & aField);

  int mtsignio::AddDecimalType(MTPipelineLib::IMTSessionPtr aSession,
															 struct CreditCardField & aField);

  int mtsignio::AddAccountNumberType(MTPipelineLib::IMTSessionPtr aSession,
                                     struct CreditCardField & aField);

  int mtsignio::AddExpDateType(MTPipelineLib::IMTSessionPtr aSession,
                               struct CreditCardField & aField);

  int mtsignio::AddUsernameType(MTPipelineLib::IMTSessionPtr aSession,
                                struct CreditCardField & aField);

  int mtsignio::AddPartnerType(MTPipelineLib::IMTSessionPtr aSession,
                                struct CreditCardField & aField);

  int mtsignio::AddPasswordType(MTPipelineLib::IMTSessionPtr aSession,
                                struct CreditCardField & aField);

  int mtsignio::AddSessionUID(MTPipelineLib::IMTSessionPtr aSession,
                              struct CreditCardField & aField);

  int mtsignio::AddOptionalString(MTPipelineLib::IMTSessionPtr aSession,
                                  struct CreditCardField & aField);
};

PLUGIN_INFO(CLSID_mtsignio, mtsignio,
						"MetraPipeline.mtsignio.1", "MetraPipeline.mtsignio", "Free")

mtsignio::mtsignio()
	: mContextInitialized(false)
{
  return;
}

HRESULT mtsignio::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
							  									MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  // look up the property IDs of the props we need
  MTPipelineLib::IMTNameIDPtr idlookup(aSysContext);

  mlngTransactionTypePropId = 0; 
  mlngAccountNumberPropId = 0; 
  mlngZipPropId = 0; 
  mlngBillingAddressPropId = 0; 

  // The XML file defines the transaction string format. The set defines
  // the basic structure for specifying the format.
  //
  // An example using the format is:
  // <cardlistset>
  //   <cardset>
  //     <cardtype>AMEX</cardtype>
  //     <field>
  //       <name>transactiontype</name>
  //       <property>transactiontype</property>
  //       <type>string</type>
  //       <minlength>2</minlength>
  //       <maxlength>2</maxlength>
  //     </field>
  //     <field>
  //       <name>cardid</name>
  //       <property>customercode</property>
  //       <type>number</type>
  //       <minlength>0</minlength>
  //       <maxlength>4</maxlength>
  //     </field>
  //   </cardset>
  //
  //   <!-- format for all other cards -->
  //   <cardset>
  //     <cardtype>ELSE</cardtype>
  //     <field>
  //       <name>transactiontype</name>
  //       <property>transactiontype</property>
  //       <type>string</type>
  //       <minlength>2</minlength>
  //       <maxlength>2</maxlength>
  //     </field>
  //     <field>
  //       <name>cvv2</name>
  //       <property>cardverificationvalue</property>
  //       <type>number</type>
  //       <minlength>0</minlength>
  //       <maxlength>3</maxlength>
  //     </field>
  //   </cardset>
  // </cardlistset>

  MTPipelineLib::IMTConfigPropSetPtr cpsCardListSet;
  cpsCardListSet = aPropSet->NextSetWithName("cardlistset");

  if (NULL == cpsCardListSet)
  {
    aLogger->LogString(
      MTPipelineLib::PLUGIN_LOG_ERROR,
      "mtsignio::PlugInConfigure: cardlistset tag is missing from plugin configuration file");

    _bstr_t errormsg = "cardlistset tag is missing from plugin configuration file";
    return Error((char*)errormsg);
  }

  while (TRUE)
  {
    // read each card set
    MTPipelineLib::IMTConfigPropSetPtr cpsCardSet;

    cpsCardSet = cpsCardListSet->NextSetWithName("cardset");

    if (NULL == cpsCardSet)
    {
      // The number of cards may vary. A COM error
      // indicates that there are no more card formats
      // to read. 
      break;
    }

    CreditCard ccCard;

    // first, read the card type
    // this method throws an exceptions with an informative 
    // error message.
    ccCard.bstrCardType = cpsCardSet->NextStringWithName("cardtype");

    while (TRUE)
    {
      // then iterate through the fields this card requires
      MTPipelineLib::IMTConfigPropSetPtr cpsFieldSet;
      CreditCardField ccfField;

      cpsFieldSet = cpsCardSet->NextSetWithName("field");
  
      if (NULL == cpsFieldSet)
      {
        // The number of fields may vary. A COM error
        // indicates that there are no more fields 
        // to read. 
        break;
      }

      ccfField.bstrName         = cpsFieldSet->NextStringWithName("name");
      ccfField.bstrSessionProp  = cpsFieldSet->NextStringWithName("property");
      ccfField.lngSessionPropId = idlookup->GetNameID(ccfField.bstrSessionProp);
     	//gets required indicator for session property. If it doesn't exist, then the property is required
      //in session (old behaviour)
  		ccfField.IsRequired = true;
      if (cpsFieldSet->NextMatches(L"required", MTPipelineLib::PROP_TYPE_BOOLEAN))
			  ccfField.IsRequired = (cpsFieldSet->NextBoolWithName(L"required") == VARIANT_TRUE)
				? true : false;

      ccfField.bstrType         = cpsFieldSet->NextStringWithName("type");
      ccfField.lngMinLength     = cpsFieldSet->NextLongWithName("minlength");
      ccfField.lngMaxLength     = cpsFieldSet->NextLongWithName("maxlength");

      //ccCard.cflFieldList.insert(ccfField);
      ccCard.cflFieldList.push_back(ccfField);

      // Save off property ids that are used outside of the
      // transaction building method.
      if (!strcmp("TRXTYPE", (const char *)ccfField.bstrName)) 
        mlngTransactionTypePropId = ccfField.lngSessionPropId;

      if (!strcmp("ACCT", (const char *)ccfField.bstrName)) 
          mlngAccountNumberPropId    = ccfField.lngSessionPropId;

      if (!strcmp("ZIP", (const char *)ccfField.bstrName)) 
        mlngZipPropId = ccfField.lngSessionPropId;

      if (!strcmp("STREET", (const char *)ccfField.bstrName)) 
        mlngBillingAddressPropId = ccfField.lngSessionPropId;
    }

    mcclCardList.push_back(ccCard);
  }

  // remaining input properties
  _bstr_t bstrExpDateFormat   = aPropSet->NextStringWithName("expdateformat");
  mlngExpDateFormat           = idlookup->GetNameID(bstrExpDateFormat);

  _bstr_t bstrTestSession     = aPropSet->NextStringWithName("testsession");
  mlngTestSession             = idlookup->GetNameID(bstrTestSession);

  _bstr_t bstrHitCard         = aPropSet->NextStringWithName("hitcard");
  mlngHitCard                 = idlookup->GetNameID(bstrHitCard);

  _bstr_t bstrAccountType     = aPropSet->NextStringWithName("accounttype");
  mlngAccountType             = idlookup->GetNameID(bstrAccountType);

  // input/output properties
  _bstr_t bstrRetCode        = aPropSet->NextStringWithName("retcode");
  mlngRetCode                = idlookup->GetNameID(bstrRetCode);

  _bstr_t bstrResponseString = aPropSet->NextStringWithName("responsestring");
  mlngResponseString         = idlookup->GetNameID(bstrResponseString);

  _bstr_t bstrPnref          = aPropSet->NextStringWithName("pnref");
  mlngPnref                  = idlookup->GetNameID(bstrPnref);

  _bstr_t bstrOriginalId     = aPropSet->NextStringWithName("originalid");
  mlngOriginalId             = idlookup->GetNameID(bstrOriginalId);

  _bstr_t bstrOriginalResult = aPropSet->NextStringWithName("originalresult");
  mlngOriginalResult         = idlookup->GetNameID(bstrOriginalResult);

  _bstr_t bstrStatus         = aPropSet->NextStringWithName("status");
  mlngStatus                 = idlookup->GetNameID(bstrStatus);

  _bstr_t bstrPrimary        = aPropSet->NextStringWithName("primary");
  mlngPrimary                = idlookup->GetNameID(bstrPrimary);

  _bstr_t bstrEnabled        = aPropSet->NextStringWithName("enabled");
  mlngEnabled                = idlookup->GetNameID(bstrEnabled);

  _bstr_t bstrCreditCardSecCode  = aPropSet->NextStringWithName("creditcardseccode");
  mlngCreditCardSecCode          = idlookup->GetNameID(bstrCreditCardSecCode);

  //
  // read everything from the plugin configuration file, now read the dynamic
  // configuration information
  //

  MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	_bstr_t bstrConfigFilePath;
  _bstr_t bstrConfigFile;

  std::string rsExtensionir;
  if (!GetExtensionsDir(rsExtensionir))
  {
    aLogger->LogString(
      MTPipelineLib::PLUGIN_LOG_ERROR,
      "mtsignio::PlugInConfigure: unable to get configuration directory from registry");

    _bstr_t errormsg = "unable to get configuration directory from registry";
    return Error((char*)errormsg);
  }

  bstrConfigFilePath = rsExtensionir.c_str();
	bstrConfigFilePath += DIR_SEP;
	bstrConfigFilePath += aSysContext->GetExtensionName();
	bstrConfigFilePath += "\\config";
  bstrConfigFilePath += "\\PaymentServer";

	bstrConfigFile = bstrConfigFilePath;
	bstrConfigFile += "\\signio.xml";


  VARIANT_BOOL flag;

  MTConfigLib::IMTConfigPropSetPtr propset = config->ReadConfiguration(bstrConfigFile, &flag);

  msHostAddress             = propset->NextStringWithName("hostaddress");
  
  mlngHostPort               = propset->NextLongWithName("hostport");

  mlngSignioTimeout          = propset->NextLongWithName("timeout");

  msProxyAddress             = propset->NextStringWithName("proxyaddress");
  
  mlngProxyPort              = propset->NextLongWithName("proxyport");

  msProxyLogin               = propset->NextStringWithName("proxylogin");
  
  msProxyPassword            = propset->NextStringWithName("proxypassword");
  
  msAvsSupportLevel          = propset->NextStringWithName("avssupportlevel");

  msPostauthError            = propset->NextStringWithName("postautherror");
  
  //
  // retrieve the username and password from secure storage 
  //

  SecureStore ssUsername("Pipeline");
	_bstr_t aSignioLoginFile = bstrConfigFilePath;
	aSignioLoginFile += "\\signiologin.xml";
  msUsername = ssUsername.GetValue(aSignioLoginFile,
                                     _bstr_t("username")).c_str();

  if (msUsername.length() == 0) 
  {
    aLogger->LogString(
      MTPipelineLib::PLUGIN_LOG_ERROR,
      "mtsignio::PlugInConfigure: unable to get username");

    _bstr_t errormsg = "unable to get username";
    return Error((char*)errormsg);
  }

  SecureStore ssPassword("Pipeline");
  msPassword = ssPassword.GetValue(aSignioLoginFile,
                                     _bstr_t("password")).c_str();

  if (msPassword.length() == 0)
  {
    aLogger->LogString(
      MTPipelineLib::PLUGIN_LOG_ERROR,
      "mtsignio::PlugInConfigure: unable to get password");

    _bstr_t errormsg = "unable to get password";
    return Error((char*)errormsg);
  }

  SecureStore ssPartner("Pipeline");
  mPartner = ssPartner.GetValue(aSignioLoginFile,
                                     _bstr_t("partner")).c_str();

  if (mPartner.length() == 0)
  {
    aLogger->LogString(
      MTPipelineLib::PLUGIN_LOG_ERROR,
      "mtsignio::PlugInConfigure: unable to get \"partner\" key");
    return Error(L"unable to get \"partner\" key");
  }




  //
  // Verify that the characters in the username and password are printable ASCII
  // characters. If the VeriSign username and password have not been configured,
  // which means they are their default plaintext strings, then at this point
  // secure store decrypted the plaintext resulting in garbage. 
  //
  // Only inspect the first 10 characters. Any problem should present itself
  // in this time. This check prevents cases where the length of the garbage
  // may be excessively long cause access violations.
  //

  char * p;

  p = (char*)msUsername;
  for (unsigned int i=0; i<msUsername.length() && i<10; i++)
  {
    if (((long)*p < 0x20) || ((long)*p > 0x7e))
    {
      aLogger->LogString(
        MTPipelineLib::PLUGIN_LOG_ERROR,
        "mtsignio::PlugInConfigure: VeriSign username has not been configured");
      _bstr_t errormsg = "VeriSign username has not beed configured";
      return Error((char*)errormsg);
    }
  }

  p = (char *)msPassword;

  for (i=0; i<msPassword.length() && i<10; i++)
  {
    if (((long)*p < 0x20) || ((long)*p > 0x7e))
    {
      aLogger->LogString(
        MTPipelineLib::PLUGIN_LOG_ERROR,
        "mtsignio::PlugInConfigure: VeriSign password has not been configured");

      _bstr_t errormsg = "VeriSign password has not beed configured";
      return Error((char*)errormsg);
    }
  }

  //
  // initialize the signio client DLL
  //
  pfproInit();
  
  //create versisign session context and fold on to it
  mContext = 0;
  int ret = pfproCreateContext
    (&mContext, 
    (char*)msHostAddress, 
    mlngHostPort, 
    mlngSignioTimeout, 
    (char*)msProxyAddress, 
    mlngProxyPort, 
    (char*)msProxyLogin,
    (char*)msProxyPassword);

	mContextInitialized = true;

  LoggerConfigReader lcrConfigReader;
  mntlLogger.Init(lcrConfigReader.ReadConfiguration("logging"), (const char *)"mtsignio");

  //store enum config pointer from system context
  mEnumConfig = aSysContext->GetEnumConfig();
  _ASSERTE(mEnumConfig != NULL);

	return S_OK;
}

HRESULT mtsignio::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = S_OK;

  try
  {
    // Check if this is a pass through session. The write product view needs
    // to do something with this session, may as well put this into the
    // failure product view.
    long lngTestSession = aSession->GetLongProperty(mlngTestSession); 
    if (CREDITCARDACCOUNT_ERR_TEST_SESSION == lngTestSession)
    {
      aSession->SetStringProperty(mlngResponseString, (const char *)"This is a test session");
      aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_ERR_TEST_SESSION);
      ClearNumber(aSession);
      return S_OK;
    }

    long lngEnabled = aSession->GetLongProperty(mlngEnabled);
    if (0 == lngEnabled)
    {
      aSession->SetStringProperty(mlngResponseString, (const char *)"This account is not enabled");
      aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_OBJECT_NOT_INITIALIZED);
      ClearNumber(aSession);
      return S_OK;
    }

    // Is this a known account? 
    long lngRetCode = aSession->GetLongProperty(mlngRetCode);
    if (CREDITCARDACCOUNT_ERR_ACCOUNT_NOT_FOUND == lngRetCode)
    {
      aSession->SetStringProperty(mlngResponseString, (const char *)"Account does not exist");
      return S_OK;
    }

    // The pipeline is a sequential processing concept. There is no way
    // to cease processing in the middle of the pipeline. Stages/plugins
    // earlier in the pipeline use this property to indicate whether 
    // this plugin should process this session.
    //
    // There are non-error situations where this property indicates not to
    // process this session. One situation is support for threshold accounts.
    // An earlier plugin may determine that the limit has not been exceeded
    // which means the card should be be hit.
    long lngHitCard = aSession->GetLongProperty(mlngHitCard); 
    if (!lngHitCard)
    {
      // May not always hit the card, ie. threshold. 
      aSession->SetStringProperty(mlngResponseString, (const char *)"000000");
      aSession->SetLongProperty(mlngRetCode, CREDITCARDACCOUNT_SUCCESS);
      ClearNumber(aSession);
      return S_OK;
    }

    int intRet;

    if (CREDITCARDACCOUNT_SUCCESS != (intRet = ProcessTransaction(aSession)))
    {
      mntlLogger.LogVarArgs(
        LOG_WARNING,
        "mtsignio::ProcessTransaction: 0x%x: %s",
        intRet,
        (const char *)msResponseString);

      _bstr_t rsType = GetTransactionType(aSession);

      //
      // Always generate pipeline errors if the error is NOT
      // one of the following.
      //
      // Errors outside of this set will typically occur during initial setup.
      // The point is that the CSR will not see these errors on a regular
      // basis which may cause problems when trying to distinguish between 
      // fundamental pipeline issues and authorization failures. (see next
      // conditional statement) Examples includes: missing sessions, 
      // configuration errors. 
      //
      if ((CREDITCARDACCOUNT_INVALID_CREDIT_CARD_TYPE       != intRet) &&
          (CREDITCARDACCOUNT_ERR_DECLINED                   != intRet) &&
		      (CREDITCARDACCOUNT_ERR_REFERRAL                   != intRet) &&
		      (CREDITCARDACCOUNT_ERR_TRANSACTION_ID_NOT_FOUND   != intRet) &&  	
          (CREDITCARDACCOUNT_ERR_INVALID_CREDIT_CARD_NUMBER != intRet) &&
          (CREDITCARDACCOUNT_ERR_INVALID_EXPIRATION_DATE    != intRet) &&
          (CREDITCARDACCOUNT_ERR_INSUFFICIENT_FUNDS         != intRet) &&
          (CREDITCARDACCOUNT_ERR_FAILED_AVS                 != intRet) &&
          (CREDITCARDACCOUNT_ERR_EXCEED_SALES_CAP           != intRet) &&
          (CREDITCARDACCOUNT_ERR_INVALID_AMOUNT             != intRet) &&
          (CREDITCARDACCOUNT_ERR_PROCESSOR_UNAVAILABLE      != intRet) && 
          //CR 8690: treat CVV2 errors the same as others.
          (CREDITCARDACCOUNT_ERR_CVV2_MISMATCH              != intRet) && 
          (CREDITCARDACCOUNT_ERR_CVV2_NOT_SUPPORTED         != intRet)
          )
      {
        Error((const char *)msResponseString);
        hr = mlngRetAuthCode;
        ClearNumber(aSession);
        return hr;
      }
 
      //
      // generate pipeline errors for errors that a CSR
      // may need to act upon. 
      // Transactions that require CSR intervention:
      //   credit
      //   sale
      //   delayed capture 
      // Transactions that a CSR does not act on:
      //   void
      //   authorization (preauth and validatecard)
      //
      if ( (stricmp("PipelineError", (char*)msPostauthError) == 0) &&
          ((stricmp("S", (char*)rsType) == 0) || (stricmp("D", (char*)rsType) == 0) || (stricmp("C", (char*)rsType) == 0)))
      {
        Error((const char *)msResponseString);
        hr = mlngRetAuthCode;
        ClearNumber(aSession);
        return hr;
      }
    }

    // for all others, write to the product view
    aSession->SetStringProperty(mlngResponseString, (const char *)msResponseString);
    aSession->SetLongProperty(mlngRetCode, mlngRetAuthCode);

    // be sure not to accidentally return the credit card
    // number to the client
    ClearNumber(aSession);
  }
  catch (HRESULT hr)
  {
    ClearNumber(aSession);
    return hr;
  }
  catch (_com_error err)
  {
    ClearNumber(aSession);
    hr = ReturnComError(err);
  }

  return hr;
}


HRESULT mtsignio::PlugInShutdown()
{
  //
  // cleanup the signio client DLL
  //
	if (mContextInitialized)
	{
		pfproDestroyContext(mContext);
		pfproCleanup();
	}

	return S_OK;
}

int
mtsignio::ProcessTransaction(MTPipelineLib::IMTSessionPtr aSession)
{
  int intRet = CREDITCARDACCOUNT_ERR_ANY_ERROR;
  SignioReturnObject sroObject;
  std::string sTemp;

  // build the transaction string

  msReqStr = "";
  msAnsStr = "";
  mLoggedRequestStr = "";

  for (unsigned int i=0; i<mcclCardList.size(); i++)
  {
    // DJM: add some card validation

    _variant_t vtValue;
    _bstr_t    bstrAccountType;

    bstrAccountType = mEnumConfig->GetEnumeratorByID(aSession->GetLongProperty(mlngAccountType));

    // search for the proper transaction string format
    // if cardtype does not match AND the configured cardtype is not ELSE
    // then continue
    if (strcmp((const char *)mcclCardList[i].bstrCardType, 
               (const char *)bstrAccountType)
        &&
        strcmp((const char *)mcclCardList[i].bstrCardType, 
               (const char *)"ELSE"))
      continue;

    // we've got the right card, now build the transaction string
    for (unsigned int j=0; j<mcclCardList[i].cflFieldList.size(); j++)
    {
      if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                  (const char *)"string"))
      {
        intRet = AddStringType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"number"))
      {
        intRet = AddNumberType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"numberstring"))
      {
        intRet = AddNumberStringType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"float"))
      {
        intRet = AddFloatType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"decimal"))
      {
        intRet = AddDecimalType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"accountnumber"))
      {
        intRet = AddAccountNumberType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"expdate"))
      {
        intRet = AddExpDateType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"username"))
      {
        intRet = AddUsernameType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"partner"))
      {
        intRet = AddPartnerType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"password"))
      {
        intRet = AddPasswordType(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"sessionuid"))
      {
        intRet = AddSessionUID(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else if (!strcmp((const char *)mcclCardList[i].cflFieldList[j].bstrType,
                       (const char *)"optionalstring"))
      {
        intRet = AddOptionalString(aSession, mcclCardList[i].cflFieldList[j]);
      }
      else
      {
        intRet = CREDITCARDACCOUNT_ERR_ANY_ERROR;
        msAnsStr =  (const char *) "Type ";
        msAnsStr += (const char *) mcclCardList[i].cflFieldList[j].bstrType;
        msAnsStr += (const char *) " is not supported for name "; 
        msAnsStr += (const char *) mcclCardList[i].cflFieldList[j].bstrName;
      }

      if (CREDITCARDACCOUNT_SUCCESS != intRet)
      {
        goto Done;
      }
    }

    break;
  }
  
  if (i >= mcclCardList.size())
  {
    intRet = CREDITCARDACCOUNT_INVALID_CREDIT_CARD_TYPE;
    msAnsStr = (const char *) "This credit card type is not supported at this time";
    goto Done;
  }

  // remove the trailing comma. 
  msReqStr.resize(msReqStr.length() - 1);
  // g. cieplik 01/09/08 MAESTRO CC changes, stipping off the last two characters of message, should only strip off one 
  // msReqStr.resize(msReqStr.length() - 1);

  //char chrSignioResponse[MT_SIGNIO_RESPONSE_STRING_LEN];
  char* chrSignioResponse;

  //BP: use new verisign API
  ASSERT(mContext != 0);
  intRet = pfproSubmitTransaction(mContext, (char*)msReqStr.c_str(), msReqStr.length(), &chrSignioResponse);

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    std::string log = mLoggedRequestStr;
    log.resize(log.length() - 1);
    mntlLogger.LogVarArgs(LOG_DEBUG, "REQUEST STRING: %s",log.c_str());

    mntlLogger.LogVarArgs(LOG_DEBUG,
      "RESPONSE STRING: %s",
      (const char *)chrSignioResponse);
  }

  //
  // parse results
  //
  if (FALSE == sroObject.Initialize(chrSignioResponse))
  {
    char chrBuf[512];

    sprintf(chrBuf, "Error intepreting response string: %s", chrSignioResponse);

    msAnsStr = chrBuf; 

    // TODO: DJM generate pipeline error
    intRet = CREDITCARDACCOUNT_ERR_ANY_ERROR;

    goto Done;
  }

  //
  // check for error 
  //

  if (0 != intRet)
  {
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_ANY_ERROR;
    goto Done;
  }

  //
  // check authorization errors 
  //

  switch (sroObject.GetResult())
  {
  case 0:
    intRet = CREDITCARDACCOUNT_SUCCESS;
    break;
    
  case 4: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_INVALID_AMOUNT;
    goto Done;
    
  case 12: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_DECLINED;
    goto Done;
    
  case 13:
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_REFERRAL;
    goto Done;
    
  case 19:
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_TRANSACTION_ID_NOT_FOUND;
    goto Done;
    
  case 22:
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_INVALID_ROUTING_NUMBER;
    goto Done;
    
  case 23: 
    sTemp = sroObject.GetResponseMessage();
    if (sTemp.size() > 4)
    {
      //sTemp.remove(0, 1);
      sTemp = sTemp.substr((sTemp.size() - 4), sTemp.size());
    }
    msAnsStr =  (const char *)"Invalid credit card number: "; 
    msAnsStr += sTemp.c_str(); 
    intRet = CREDITCARDACCOUNT_ERR_INVALID_CREDIT_CARD_NUMBER;
    goto Done;
    
  case 24: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_INVALID_EXPIRATION_DATE;
    goto Done;
    
  case 50: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_INSUFFICIENT_FUNDS;
    goto Done;
    
  case 104: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_PROCESSOR_UNAVAILABLE;
    goto Done;
    
  case 112: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_FAILED_AVS;
    goto Done;
    
  case 113: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_EXCEED_SALES_CAP;
    goto Done;
    
  case 114: 
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_CVV2_MISMATCH;
    goto Done;
    
  default:
    msAnsStr = sroObject.GetResponseMessage();
    intRet = CREDITCARDACCOUNT_ERR_ANY_ERROR;
    goto Done;
  }

  //
  // perform AVS check
  //

  if (CREDITCARDACCOUNT_SUCCESS != AddressVerification(aSession, sroObject))
  {
    // rely on this routine to set the answer string.
    intRet = CREDITCARDACCOUNT_ERR_FAILED_AVS;
  }
  else
  {
    if (sroObject.GetAuthCode().length() > 0)
      msAnsStr = sroObject.GetAuthCode();
    else
      msAnsStr = sroObject.GetResponseMessage();

    //verify CVV2 Match if AVS succeeded
    HRESULT hr;
    hr = VerifyCVV2Match(aSession, sroObject);
    if(FAILED(hr))
      //return hr;
    intRet = (int)hr;
  }

  
  if (CREDITCARDACCOUNT_ERR_ANY_ERROR != sroObject.GetOriginalResult())
    aSession->SetLongProperty(mlngOriginalResult, sroObject.GetOriginalResult());

  if (sroObject.GetStatus().length() > 0)
    aSession->SetStringProperty(mlngStatus, (const char *)sroObject.GetStatus());

Done:

   if (sroObject.GetPnref().length() > 0)
     aSession->SetStringProperty(mlngPnref, (const char *)sroObject.GetPnref());

  mlngRetAuthCode = (long)intRet;
  msResponseString = msAnsStr;

  //BP: free transaction resources
  pfproCompleteTransaction(chrSignioResponse); 


  return(intRet);
}

//
// This routine is a generic date parser. I took a stab at possible date 
// formats.  
//
const char *
mtsignio::InternalParseExpDate(_bstr_t       & asDate,
                               MTExpDateFormat   amdfInFormat,
                               MTExpDateFormat   amdfOutFormat)
{
  static char chrDateBuf[MT_STD_MEMBER_LEN];
  char chrMonth[10];  // longest month plus terminating null
  int  intMonthLen;
  char chrYear[6];    // 5 digit year (Y10K) plus terminatin null 
  int  intYearLen;
  char * chrP = NULL;
  int  intInLen;

  strcpy(chrDateBuf, (const char *)asDate);

  intInLen = strlen((const char *)chrDateBuf);

  switch (amdfInFormat)
  {
    case CREDITCARDLib::MT_YYMM:

      if (4 != intInLen) 
          goto Done;

      intYearLen = 2;
      chrYear[0] = chrDateBuf[0];
      chrYear[1] = chrDateBuf[1];
      chrYear[2] = '\0';
 
      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[2];
      chrMonth[1] = chrDateBuf[3];
      chrMonth[2] = '\0'; 

      break;

    case CREDITCARDLib::MT_MMYY:

      if (4 != intInLen) 
          goto Done;

      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[0];
      chrMonth[1] = chrDateBuf[1];
      chrMonth[2] = '\0'; 

      intYearLen = 2;
      chrYear[0] = chrDateBuf[2];
      chrYear[1] = chrDateBuf[3];
      chrYear[2] = '\0';
 
      break;

    case CREDITCARDLib::MT_YYYYMM:

      if (6 != intInLen) 
          goto Done;

      intYearLen = 4;
      chrYear[0] = chrDateBuf[0];
      chrYear[1] = chrDateBuf[1];
      chrYear[2] = chrDateBuf[2];
      chrYear[3] = chrDateBuf[3];
      chrYear[4] = '\0';
 
      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[4];
      chrMonth[1] = chrDateBuf[5];
      chrMonth[2] = '\0'; 

      break;

    case CREDITCARDLib::MT_MMYYYY:

      if (6 != intInLen) 
          goto Done;

      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[0];
      chrMonth[1] = chrDateBuf[1];
      chrMonth[2] = '\0'; 

      intYearLen = 4;
      chrYear[0] = chrDateBuf[2];
      chrYear[1] = chrDateBuf[3];
      chrYear[2] = chrDateBuf[4];
      chrYear[3] = chrDateBuf[5];
      chrYear[4] = '\0'; 
 
      break;

    case CREDITCARDLib::MT_MM_slash_YY:

      if (5 != intInLen)
          goto Done;

      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[0];
      chrMonth[1] = chrDateBuf[1];
      chrMonth[2] = '\0'; 

      intYearLen = 2;
      chrYear[0] = chrDateBuf[3];
      chrYear[1] = chrDateBuf[4];
      chrYear[2] = '\0';
 
      break;

    case CREDITCARDLib::MT_YY_slash_MM:

      if (5 != intInLen) 
          goto Done;

      intYearLen = 2;
      chrYear[0] = chrDateBuf[0];
      chrYear[1] = chrDateBuf[1];
      chrYear[2] = '\0'; 

      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[3];
      chrMonth[1] = chrDateBuf[4];
      chrMonth[2] = '\0'; 
 
      break;

    case CREDITCARDLib::MT_MM_slash_YYYY:

      if (7 != intInLen) 
          goto Done;

      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[0];
      chrMonth[1] = chrDateBuf[1];
      chrMonth[2] = '\0'; 

      intYearLen = 4;
      chrYear[0] = chrDateBuf[3];
      chrYear[1] = chrDateBuf[4];
      chrYear[2] = chrDateBuf[5];
      chrYear[3] = chrDateBuf[6];
      chrYear[4] = '\0'; 
 
      break;

    case CREDITCARDLib::MT_YYYY_slash_MM:

      if (7 != intInLen) 
          goto Done;

      intYearLen = 4;
      chrYear[0] = chrDateBuf[0];
      chrYear[1] = chrDateBuf[1];
      chrYear[2] = chrDateBuf[2];
      chrYear[3] = chrDateBuf[3];
      chrYear[4] = '\0'; 

      intMonthLen = 2;
      chrMonth[0] = chrDateBuf[5];
      chrMonth[1] = chrDateBuf[6];
      chrMonth[2] = '\0'; 
 
      break;

    default:
      // format not supported
      goto Done;
  }

  switch (amdfOutFormat)
  {
    case CREDITCARDLib::MT_YYMM:

      chrDateBuf[0] = (intYearLen == 2) ? chrYear[0] : chrYear[2]; 
      chrDateBuf[1] = (intYearLen == 2) ? chrYear[1] : chrYear[3]; 
      chrDateBuf[2] = chrMonth[0];
      chrDateBuf[3] = chrMonth[1];
      chrDateBuf[4] = '\0';

      break;

    case CREDITCARDLib::MT_MMYY:

      chrDateBuf[0] = chrMonth[0];
      chrDateBuf[1] = chrMonth[1];
      chrDateBuf[2] = (intYearLen == 2) ? chrYear[0] : chrYear[2]; 
      chrDateBuf[3] = (intYearLen == 2) ? chrYear[1] : chrYear[3]; 
      chrDateBuf[4] = '\0';

      break;

    case CREDITCARDLib::MT_YYYYMM:

      if (intYearLen != 4)
        goto Done;

      chrDateBuf[0] = chrYear[0]; 
      chrDateBuf[1] = chrYear[1]; 
      chrDateBuf[2] = chrYear[2]; 
      chrDateBuf[3] = chrYear[3]; 
      chrDateBuf[4] = chrMonth[0];
      chrDateBuf[5] = chrMonth[1];
      chrDateBuf[6] = '\0';

      break;

    case CREDITCARDLib::MT_MMYYYY:

      if (intYearLen != 4)
        goto Done;

      chrDateBuf[0] = chrMonth[0];
      chrDateBuf[1] = chrMonth[1];
      chrDateBuf[2] = chrYear[0]; 
      chrDateBuf[3] = chrYear[1]; 
      chrDateBuf[4] = chrYear[2]; 
      chrDateBuf[5] = chrYear[3]; 
      chrDateBuf[6] = '\0';

      break;

    case CREDITCARDLib::MT_MM_slash_YY:

      chrDateBuf[0] = chrMonth[0];
      chrDateBuf[1] = chrMonth[1];
      chrDateBuf[2] = '/';
      chrDateBuf[3] = (intYearLen == 2) ? chrYear[0] : chrYear[2]; 
      chrDateBuf[4] = (intYearLen == 2) ? chrYear[1] : chrYear[3]; 
      chrDateBuf[5] = '\0';

      break;

    case CREDITCARDLib::MT_YY_slash_MM:
 
      chrDateBuf[0] = (intYearLen == 2) ? chrYear[0] : chrYear[2]; 
      chrDateBuf[1] = (intYearLen == 2) ? chrYear[1] : chrYear[3]; 
      chrDateBuf[2] = '/';
      chrDateBuf[3] = chrMonth[0];
      chrDateBuf[4] = chrMonth[1];
      chrDateBuf[5] = '\0';

      break;

    case CREDITCARDLib::MT_MM_slash_YYYY:

      if (intYearLen != 4)
        goto Done;

      chrDateBuf[0] = chrMonth[0];
      chrDateBuf[1] = chrMonth[1];
      chrDateBuf[2] = '/';
      chrDateBuf[3] = chrYear[0]; 
      chrDateBuf[4] = chrYear[1]; 
      chrDateBuf[5] = chrYear[2]; 
      chrDateBuf[6] = chrYear[3]; 
      chrDateBuf[7] = '\0';

      break;

    case CREDITCARDLib::MT_YYYY_slash_MM:

      if (intYearLen != 4)
        goto Done;

      chrDateBuf[0] = chrYear[0]; 
      chrDateBuf[1] = chrYear[1]; 
      chrDateBuf[2] = chrYear[2]; 
      chrDateBuf[3] = chrYear[3]; 
      chrDateBuf[4] = '/';
      chrDateBuf[5] = chrMonth[0];
      chrDateBuf[6] = chrMonth[1];
      chrDateBuf[7] = '\0';

      break;

    default:
      // format not supported
      goto Done;
  }

  chrP = chrDateBuf;

Done:
 
  return(chrP);
}

void
mtsignio::MTGetLastErrorString(TCHAR * atchBuf, int aintError, int aintLen)
{

  FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    NULL,
    aintError,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    (LPTSTR) atchBuf,
    aintLen,
    0);

  return;
}

int
mtsignio::AddressVerification(MTPipelineLib::IMTSessionPtr aSession, 
                              SignioReturnObject & asroObject)
{
  // AVS not configured or does not apply to this transaction
  if ((stricmp("none", (char*)msAvsSupportLevel) == 0) || 
      (asroObject.GetAvsAddr().length() == 0 &&
       asroObject.GetAvsZip().length() == 0)) 
    return CREDITCARDACCOUNT_SUCCESS;

  _bstr_t rsType = GetTransactionType(aSession);

  // no need for AVS for void sale and credit
  if ((stricmp("V", (char*)rsType) == 0) || // void sale
      (stricmp("C", (char*)rsType) == 0))   // credit
  {
    return CREDITCARDACCOUNT_SUCCESS;
  }

  // knock the case where AVS is configured, but there is no
  // address info present. this condition is high in the 
  // list because these transactions do not contain an AVS code. 
  _bstr_t rsZip = GetZip(aSession);
  _bstr_t rsBillingAddress = GetBillingAddress(aSession);
  if ((rsZip.length() == 0) && 
      (rsBillingAddress.length() == 0) )
  {
    char chrBuf[512];

    sprintf(chrBuf, "Address and zip not provided.");

    msAnsStr = chrBuf; 

    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  // check for zip and address

  // this is probably the most common configuration option 
  if ((stricmp("zipandaddress", (char*)msAvsSupportLevel) == 0))
  {
    if (stricmp("N", (char*)asroObject.GetAvsAddr()) > 0 && 
        stricmp("N", (char*)asroObject.GetAvsZip()) > 0)
      return CREDITCARDACCOUNT_SUCCESS;
    else
    {
      char chrBuf[512];

      sprintf(
        chrBuf,
        "AVS code does not match zip code (%s) and address (%s)",
        (char*)asroObject.GetAvsZip(),
        (char*)asroObject.GetAvsAddr());
 
      msAnsStr = chrBuf; 

      return CREDITCARDACCOUNT_ERR_ANY_ERROR;
    }
  }

  // now check for address only
  if ((stricmp("address", (char*)msAvsSupportLevel) == 0))
  {
    if ( stricmp("N", (char*)asroObject.GetAvsAddr()) > 0)
      return CREDITCARDACCOUNT_SUCCESS;
    else
    {
      char chrBuf[512];

      sprintf(
        chrBuf,
        "AVS code does not match address (%s)",
        (char*)asroObject.GetAvsAddr());
 
      msAnsStr = chrBuf; 

      return CREDITCARDACCOUNT_ERR_ANY_ERROR;
    }
  }

  // now check for zip only

  if ((stricmp("zip", (char*)msAvsSupportLevel) == 0))
  {
    if (stricmp("N", (char*)asroObject.GetAvsZip()) > 0)
      return CREDITCARDACCOUNT_SUCCESS;
    else
    {
      char chrBuf[512];

      sprintf(
        chrBuf,
        "AVS code does not match zip (%s)",
        (char*)asroObject.GetAvsZip());
 
      msAnsStr = chrBuf; 

      return CREDITCARDACCOUNT_ERR_ANY_ERROR;
    }
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

HRESULT
mtsignio::VerifyCVV2Match(MTPipelineLib::IMTSessionPtr aSession, 
                              SignioReturnObject & asroObject)
{
  HRESULT hr(S_OK);
  if(aSession->PropertyExists(mlngCreditCardSecCode, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
    return hr;
  if(stricmp((char*)asroObject.GetCVV2Match(), "N") == 0)
    hr = CREDITCARDACCOUNT_ERR_CVV2_MISMATCH;
  else if (stricmp((char*)asroObject.GetCVV2Match(), "X") == 0)
    hr = CREDITCARDACCOUNT_ERR_CVV2_NOT_SUPPORTED;
	//BP: below lines needed to be commented out, because in case of AmEx credit card
	//CVV2 (CID) processing is a little different. Credit Card processor does not send CVV2MATCH
	//field back. In case of invalid CID code transaction will fail with "Generaic Processor Error", 
	//code 1000
	/*
	else if (stricmp((char*)asroObject.GetCVV2Match(), "NotFound") == 0)
    hr = CREDITCARDACCOUNT_ERR_CVV2MATCH_NOT_FOUND;
	*/
  return hr;
}


void
mtsignio::ClearNumber(MTPipelineLib::IMTSessionPtr aSession)
{
  if (0 != mlngAccountNumberPropId)
    aSession->SetStringProperty(mlngAccountNumberPropId, L"");

  return;
}

_bstr_t
mtsignio::GetTransactionType(MTPipelineLib::IMTSessionPtr aSession)
{
  if (0 == mlngTransactionTypePropId)
    return _bstr_t((const char *)"");
  else
    return aSession->GetStringProperty(mlngTransactionTypePropId);
}

_bstr_t
mtsignio::GetZip(MTPipelineLib::IMTSessionPtr aSession)
{
  if (0 == mlngZipPropId)
    return _bstr_t((const char *)"");
  else
    return aSession->GetStringProperty(mlngZipPropId);
}

_bstr_t
mtsignio::GetBillingAddress(MTPipelineLib::IMTSessionPtr aSession)
{
  if (0 == mlngBillingAddressPropId)
    return _bstr_t((const char *)"");
  else
    return aSession->GetStringProperty(mlngBillingAddressPropId);
}

void
mtsignio::SetTransactionType(MTPipelineLib::IMTSessionPtr aSession, const char * aType)
{
  if (0 == mlngTransactionTypePropId)
    aSession->SetStringProperty(mlngTransactionTypePropId, (const char *)"");
  else
    aSession->SetStringProperty(mlngTransactionTypePropId, aType);

  return;
}

void
mtsignio::SetExpDateFormat(MTPipelineLib::IMTSessionPtr aSession, long alngFormat)
{
  aSession->SetLongProperty(mlngExpDateFormat, alngFormat);
  return;
}

int
mtsignio::AddStringType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  _bstr_t rsInput;
  //if a property is not required and doesn't exist, just return
  if( aField.IsRequired == false && 
      aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;

  rsInput = aSession->GetStringProperty(aField.lngSessionPropId);

  if ((rsInput.length() < aField.lngMinLength) ||
      (rsInput.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid ";
    msAnsStr += (const char *)rsInput;
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  //
  // Must specify the string length if the string contains the special
  // characters & and =
  //

  char chrLength[128];
  sprintf(chrLength, "%d", rsInput.length());

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "[";
  msReqStr += chrLength;
  msReqStr += "]";
  msReqStr += "=";
  msReqStr += rsInput;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "[";
    mLoggedRequestStr += chrLength;
    mLoggedRequestStr += "]";
    mLoggedRequestStr += "=";
    mLoggedRequestStr += _bstr_t(rsInput);
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddNumberType(MTPipelineLib::IMTSessionPtr aSession,
                        struct CreditCardField & aField)
{
  _bstr_t rsInput;
  long      lngInput;
  
  //if a property is not required and doesn't exist, just return
  if( aField.IsRequired == false && 
      aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;

  lngInput = aSession->GetLongProperty(aField.lngSessionPropId);

  char chrBuf[128];
  sprintf(chrBuf, "%d", lngInput);
  rsInput = chrBuf;

  if ((rsInput.length() < aField.lngMinLength) ||
      (rsInput.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid ";
    msAnsStr += (const char *)rsInput;
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += rsInput;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "=";
    mLoggedRequestStr += _bstr_t(rsInput);
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddNumberStringType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  _bstr_t rsInput;

  //if a property is not required and doesn't exist, just return
  if( aField.IsRequired == false && 
      aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;

  rsInput = aSession->GetStringProperty(aField.lngSessionPropId);

  // DJM: validate that each character is a digit

  if ((rsInput.length() < aField.lngMinLength) ||
      (rsInput.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Length of Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is outside specified range ";
    msAnsStr += (const char *)rsInput;
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += rsInput;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "=";
    mLoggedRequestStr += rsInput;
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddFloatType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  std::string rsInput;
  double    dblInput;

  //if a property is not required and doesn't exist, just return
  if( aField.IsRequired == false && 
      aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_DOUBLE) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;


  dblInput = aSession->GetDoubleProperty(aField.lngSessionPropId);

  char chrBuf[128];
  sprintf(chrBuf, "%.2f", dblInput);
  rsInput = chrBuf;

  if ((rsInput.length() < aField.lngMinLength) ||
      (rsInput.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid ";
    msAnsStr += rsInput.c_str();
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += rsInput;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "=";
    mLoggedRequestStr += rsInput.c_str();
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

int mtsignio::AddDecimalType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  std::string rsInput;
  MTDecimal    decInput;

  //if a property is not required and doesn't exist, just return
  if( aField.IsRequired == false && 
      aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;


  decInput = aSession->GetDecimalProperty(aField.lngSessionPropId);

	//same as %.2f
  rsInput = decInput.Format(2).c_str();

  if ((rsInput.length() < aField.lngMinLength) ||
      (rsInput.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid ";
    msAnsStr += rsInput.c_str();
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += rsInput;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "=";
    mLoggedRequestStr += rsInput.c_str();
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}



int
mtsignio::AddAccountNumberType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  std::string rsInput;
  _bstr_t bstrPrefix;

  //if a property is not required and doesn't exist, just return
  if( aField.IsRequired == false && 
      aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;


  _bstr_t rsOrigId = aSession->GetStringProperty(mlngOriginalId);

  if (stricmp("NotSpecified", (char*)rsOrigId) == 0)
  {
    rsInput = aSession->GetStringProperty(aField.lngSessionPropId);

    if ((rsInput.length() < aField.lngMinLength) ||
        (rsInput.length() > aField.lngMaxLength))
    {
      msAnsStr =  (const char *)"Property ";
      msAnsStr += (const char *)aField.bstrSessionProp;
      msAnsStr += (const char *)" is invalid ";
      if (rsInput.length() > 4)
      {
        rsInput = rsInput.substr((rsInput.size() - 4), rsInput.size());
      }
      msAnsStr += rsInput.c_str();
      return CREDITCARDACCOUNT_ERR_INVALID_CREDIT_CARD_NUMBER;
    }

    // DJM: validate the credit card number 
    // verify that number matches type
    // verify that proper number of digits
    // verify that all digits
  
    bstrPrefix = aField.bstrName;
    msReqStr += bstrPrefix;
    msReqStr += "=";
    msReqStr += rsInput;
    msReqStr += "&";

    if (mntlLogger.IsOkToLog(LOG_DEBUG))
    {
      //leave only last 4 digits of account number
      mLoggedRequestStr += bstrPrefix;
      mLoggedRequestStr += "=";
      mLoggedRequestStr += _bstr_t("******");
      mLoggedRequestStr += rsInput.substr((rsInput.size() - 4), rsInput.size()).c_str();
      mLoggedRequestStr += "&";
    }
  }
  else
  {
    //
    // This is a delayed capture call so include the origid instead of the
    // account number. 
    //

    bstrPrefix = "ORIGID";
    msReqStr += bstrPrefix;
    msReqStr += "=";
    msReqStr += rsOrigId;
    msReqStr += "&";

    if (mntlLogger.IsOkToLog(LOG_DEBUG))
    {
      mLoggedRequestStr += bstrPrefix;
      mLoggedRequestStr += "=";
      mLoggedRequestStr += rsOrigId;
      mLoggedRequestStr += "&";
    }
  }
  
  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddExpDateType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  //if a property is not required and doesn't exist, just return
  if( aField.IsRequired == false && 
      aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;

  _bstr_t rsInput         = aSession->GetStringProperty(aField.lngSessionPropId);
  long      lngExpDateFormat = aSession->GetLongProperty(mlngExpDateFormat);

  if ((rsInput.length() < aField.lngMinLength) ||
      (rsInput.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid ";
    msAnsStr += (const char *)rsInput;
    return CREDITCARDACCOUNT_ERR_INVALID_EXPIRATION_DATE;
  }

  const char * p;
  p = InternalParseExpDate(rsInput, (MTExpDateFormat)lngExpDateFormat, CREDITCARDLib::MT_MMYY);
  if (NULL == p)
  {
    char buf[512];

    sprintf(
      buf,
      "Unsupported expiration date (%s)",
      (char*)rsInput);
 
    msAnsStr = buf; 

    return CREDITCARDACCOUNT_ERR_INVALID_EXPIRATION_DATE;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += p;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "=";
    mLoggedRequestStr += p;
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddUsernameType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  if ((msUsername.length() < aField.lngMinLength) ||
      (msUsername.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid.";
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += msUsername;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "=";
    mLoggedRequestStr += msUsername;
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddPartnerType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  if ((mPartner.length() < aField.lngMinLength) ||
      (mPartner.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid.";
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += mPartner;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "=";
    mLoggedRequestStr += mPartner;
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}


int
mtsignio::AddPasswordType(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  if ((msPassword.length() < aField.lngMinLength) ||
      (msPassword.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid.";
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "=";
  msReqStr += msPassword;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
     mLoggedRequestStr += (const char *)aField.bstrName;
     mLoggedRequestStr += "=";
     mLoggedRequestStr += _bstr_t("******");
     mLoggedRequestStr += "&";
  }
  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddSessionUID(MTPipelineLib::IMTSessionPtr aSession, struct CreditCardField & aField)
{
  _bstr_t rsInput = aSession->GetUIDAsString();

  //
  // Must specify the string length if the string contains the special
  // characters & and =
  //

  char chrLength[128];
  sprintf(chrLength, "%d", rsInput.length());

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "[";
  msReqStr += chrLength;
  msReqStr += "]";
  msReqStr += "=";
  msReqStr += rsInput;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "[";
    mLoggedRequestStr += chrLength;
    mLoggedRequestStr += "]";
    mLoggedRequestStr += "=";
    mLoggedRequestStr += rsInput;
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

int
mtsignio::AddOptionalString(MTPipelineLib::IMTSessionPtr aSession,
                            struct CreditCardField & aField)
{
   if(aSession->PropertyExists(aField.lngSessionPropId, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
      return CREDITCARDACCOUNT_SUCCESS;

   _bstr_t rsInput = aSession->GetStringProperty(aField.lngSessionPropId);
  
  if ((rsInput.length() < aField.lngMinLength) ||
      (rsInput.length() > aField.lngMaxLength))
  {
    msAnsStr =  (const char *)"Property ";
    msAnsStr += (const char *)aField.bstrSessionProp;
    msAnsStr += (const char *)" is invalid ";
    msAnsStr += rsInput;
    return CREDITCARDACCOUNT_ERR_ANY_ERROR;
  }

  //
  // Must specify the string length if the string contains the special
  // characters & and =
  //

  char chrLength[128];
  sprintf(chrLength, "%d", rsInput.length());

  msReqStr += (const char *)aField.bstrName;
  msReqStr += "[";
  msReqStr += chrLength;
  msReqStr += "]";
  msReqStr += "=";
  msReqStr += rsInput;
  msReqStr += "&";

  if (mntlLogger.IsOkToLog(LOG_DEBUG))
  {
    mLoggedRequestStr += (const char *)aField.bstrName;
    mLoggedRequestStr += "[";
    mLoggedRequestStr += chrLength;
    mLoggedRequestStr += "]";
    mLoggedRequestStr += "=";
    mLoggedRequestStr += rsInput;
    mLoggedRequestStr += "&";
  }

  return CREDITCARDACCOUNT_SUCCESS;
}

BOOLEAN SignioReturnObject::Initialize(char * achrString)
{
  char * p1;
  char * p2;
  char   chrBuf[MT_SIGNIO_RESPONSE_STRING_LEN];

  mlngResult          = CREDITCARDACCOUNT_ERR_ANY_ERROR;
  msResponseMessage = (const char *)"";
  msPnref           = (const char *)"";
  msRetCode         = (const char *)"";
  msAvsAddr         = (const char *)"";
  msAvsZip          = (const char *)"";
  mlngOriginalResult  = CREDITCARDACCOUNT_ERR_ANY_ERROR; 
  msStatus          = (const char *)"";

  //
  // Check for return code
  // All signio responses must at least have this field
  //

  if (p1 = strstr(achrString, "RESULT"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';
  
    sscanf(chrBuf, "%d", &mlngResult);
  }
  else
  {
    return FALSE;
  }

  //
  // Check for response message
  //

  if (p1 = strstr(achrString, "RESPMSG"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    msResponseMessage = chrBuf;
  }

  //
  // Check for transaction identifier
  //

  if (p1 = strstr(achrString, "PNREF"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    msPnref = chrBuf;
  }

  //
  // Check for authcode
  //

  if (p1 = strstr(achrString, "AUTHCODE"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    msRetCode = chrBuf;
  }

  //
  // Check for avs address check
  //

  if (p1 = strstr(achrString, "AVSADDR"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    msAvsAddr = chrBuf;
  }

  //
  // Check for avs zip check
  //

  if (p1 = strstr(achrString, "AVSZIP"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    msAvsZip = chrBuf;
  }

  //check for CVV2 match
  if (p1 = strstr(achrString, "CVV2MATCH"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    mCVV2Match = chrBuf;
  }


  //
  // Check for original result. ach inquiries
  //

  if (p1 = strstr(achrString, "ORIGRESULT"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    sscanf(chrBuf, "%d", &mlngOriginalResult);
  }

  //
  // Check for status. ach inquiries
  //

  if (p1 = strstr(achrString, "STATUS"))
  {
    p1 = strchr(p1, '=');
    
    p2 = ++p1;
    while ((*p2 != '&') && (*p2 != '\0'))
      p2++;

    strncpy(chrBuf, p1, p2-p1);
    chrBuf[p2-p1] = '\0';

    msStatus = chrBuf;
  }

  return TRUE;
}

long SignioReturnObject::GetResult()
{
  return mlngResult;
}

_bstr_t & SignioReturnObject::GetPnref()
{
  return msPnref;
}

_bstr_t & SignioReturnObject::GetResponseMessage()
{
  return msResponseMessage;
}

_bstr_t & SignioReturnObject::GetAuthCode()
{
  return msRetCode;
}

_bstr_t & SignioReturnObject::GetAvsAddr()
{
  return msAvsAddr;
}

_bstr_t & SignioReturnObject::GetAvsZip()
{
  return msAvsZip;
}

_bstr_t& SignioReturnObject::GetCVV2Match()
{
  return mCVV2Match;
}


long SignioReturnObject::GetOriginalResult()
{
  return mlngOriginalResult;
}

_bstr_t & SignioReturnObject::GetStatus()
{
  return msStatus;
}
