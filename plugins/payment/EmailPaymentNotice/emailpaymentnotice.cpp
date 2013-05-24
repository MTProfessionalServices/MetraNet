/**************************************************************************
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
 *
 * $Date: 9/11/2002 9:45:33 AM$
 * $Author: Alon Becker$
 * $Revision: 10$
 ***************************************************************************/

#include <time.h>

#include <mtprogids.h>
#include <PlugInSkeleton.h>
#include <ConfigDir.h>
#include <mtglobal_msg.h>
#include <MTDec.h>
#include <string>

#include <stdio.h>
#import <MTConfigLib.tlb>
#import <MTEnumConfigLib.tlb> 

// import the email tlb ...
#import <Email.tlb>
using namespace EMAILLib;

// import the email message tlb ...
#import <EmailMessage.tlb>
using namespace EMAILMESSAGELib;

// generate using uuidgen
CLSID CLSID_EmailPaymentNoticePlugIn = { /* 3c3312f0-040c-11d4-a707-00c04f58c76e */
    0x3c3312f0,
    0x040c,
    0x11d4,
    {0xa7, 0x07, 0x00, 0xc0, 0x4f, 0x58, 0xc7, 0x6e}
  };

class ATL_NO_VTABLE MTEmailPaymentNoticePlugIn
	: public MTPipelinePlugIn<MTEmailPaymentNoticePlugIn, &CLSID_EmailPaymentNoticePlugIn>
{
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

  //
  // config data
  //
  _bstr_t mTemplateFileName;
  _bstr_t mTemplateName_CC;
  _bstr_t mTemplateName_ACH;
  _bstr_t mTemplateLanguage;

  //
  // Session property ids
  //
  long mCustomerName;
  long mRetCode;
  long mEmail;
  long mAmount;
  long mLastFourDigits;
  long mCreditCardType;
  long mBankAccountType;
  long mConfirmRequested;
  long mApprovalCode;
  long mPurchaseId;

	MTPipelineLib::IMTLogPtr mLogger;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
};

PLUGIN_INFO(CLSID_EmailPaymentNoticePlugIn,
            MTEmailPaymentNoticePlugIn,
						"MetraPipeline.EmailPaymentNoticePlugIn.1",
            "MetraPipeline.EmailPaymentNoticePlugIn",
            "Free")

HRESULT
MTEmailPaymentNoticePlugIn::PlugInConfigure(
                              MTPipelineLib::IMTLogPtr aLogger,
															MTPipelineLib::IMTConfigPropSetPtr aPropSet,
															MTPipelineLib::IMTNameIDPtr aNameID,
															MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  HRESULT hr = S_OK;

  try
  {
    mLogger = aLogger;
  
    // look up the property IDs of the props we need
    MTPipelineLib::IMTNameIDPtr idlookup(aSysContext);

    // figure out which property we're going to take as input
    _bstr_t RetCode             = aPropSet->NextStringWithName("retcode");
    _bstr_t CustomerName        = aPropSet->NextStringWithName("customername");
    _bstr_t Email               = aPropSet->NextStringWithName("email");
    _bstr_t Amount              = aPropSet->NextStringWithName("amount");
    _bstr_t LastFourDigits      = aPropSet->NextStringWithName("lastfourdigits");
    _bstr_t CreditCardType      = aPropSet->NextStringWithName("creditcardtype");
	_bstr_t BankAccountType		= aPropSet->NextStringWithName("bankaccounttype");
	_bstr_t ConfirmRequested	= aPropSet->NextStringWithName("confirmrequested");
    _bstr_t ApprovalCode        = aPropSet->NextStringWithName("approvalcode");
    _bstr_t PurchaseId          = aPropSet->NextStringWithName("purchaseid");

    mCustomerName               = idlookup->GetNameID(CustomerName);
    mRetCode                    = idlookup->GetNameID(RetCode);
    mEmail                      = idlookup->GetNameID(Email);
    mAmount                     = idlookup->GetNameID(Amount);
    mLastFourDigits             = idlookup->GetNameID(LastFourDigits);
    mCreditCardType             = idlookup->GetNameID(CreditCardType);
	mBankAccountType			= idlookup->GetNameID(BankAccountType);
	mConfirmRequested			= idlookup->GetNameID(ConfirmRequested);
    mApprovalCode               = idlookup->GetNameID(ApprovalCode);
    mPurchaseId                 = idlookup->GetNameID(PurchaseId);

    // 
    // plugin config data
    //
    _bstr_t mRelativeTemplateFileName    = aPropSet->NextStringWithName("templatefilename");
    mTemplateName_CC                     = aPropSet->NextStringWithName("templatename_cc");
	mTemplateName_ACH                    = aPropSet->NextStringWithName("templatename_ach");
    mTemplateLanguage                    = aPropSet->NextStringWithName("templatelanguage");

    //
    // read everything from the plugin configuration file, now read the dynamic
    // configuration information
    //

    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

    std::string sConfigDir;
    if (!GetExtensionsDir(sConfigDir))
    {
		aLogger->LogString(
        MTPipelineLib::PLUGIN_LOG_ERROR,
        "psaccountmgmt::PlugInConfigure: unable to get configuration directory from registry");
  
		_bstr_t errormsg = "unable to get configuration directory from registry";
		return Error((char*)errormsg);
    }

	mTemplateFileName = sConfigDir.c_str();	
    mTemplateFileName += "\\paymentsvr\\config\\EMailTemplate\\";
    mTemplateFileName += mRelativeTemplateFileName; 
  
	mEnumConfig = aSysContext->GetEnumConfig();
  
  }
 
 
  catch (_com_error & err)
  {
    // mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, );
    hr = ReturnComError(err);
  }

	return hr;
}

HRESULT
MTEmailPaymentNoticePlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr = S_OK;
	BOOL    blnErrorInSessionData = TRUE;

	try
	{
		long retcode = CREDITCARDACCOUNT_SUCCESS;
		_bstr_t name;
		_bstr_t email;
		
#ifdef DECIMAL_PLUGINS
		MTDecimal amount;
#else
		double amount;     
#endif
		_bstr_t last4;
		long cctype = 0L;
		long batype = 0L;
		_bstr_t confirmrequested = "0"; 

		_bstr_t approvalcode;
		_bstr_t purchaseid;
		
		if(aSession->PropertyExists(mRetCode, MTPipelineLib::SESS_PROP_TYPE_LONG)) 
			retcode = aSession->GetLongProperty(mRetCode);

		if(aSession->PropertyExists(mCustomerName, MTPipelineLib::SESS_PROP_TYPE_STRING)) 
			name = aSession->GetStringProperty(mCustomerName);
		
		//CR 4680 related changes: Check if email is in session first
		if(aSession->PropertyExists(mEmail, MTPipelineLib::SESS_PROP_TYPE_STRING)) 
			email = aSession->GetStringProperty(mEmail);
		
#ifdef DECIMAL_PLUGINS
		amount = aSession->GetDecimalProperty(mAmount);
#else
		amount = aSession->GetDoubleProperty(mAmount);
#endif
		
		if(aSession->PropertyExists(mLastFourDigits, MTPipelineLib::SESS_PROP_TYPE_STRING)) 
			last4 = aSession->GetStringProperty(mLastFourDigits);
		
		// TODO: if other pipelines set this as long type then look for long type as well
		if(aSession->PropertyExists(mCreditCardType, MTPipelineLib::SESS_PROP_TYPE_ENUM)) 
			cctype = aSession->GetEnumProperty(mCreditCardType);

		if(aSession->PropertyExists(mBankAccountType, MTPipelineLib::SESS_PROP_TYPE_ENUM)) 
			batype = aSession->GetEnumProperty(mBankAccountType);
		
		if(aSession->PropertyExists(mConfirmRequested, MTPipelineLib::SESS_PROP_TYPE_STRING)) 
			confirmrequested = aSession->GetStringProperty(mConfirmRequested);

		if(aSession->PropertyExists(mApprovalCode, MTPipelineLib::SESS_PROP_TYPE_STRING)) 
			approvalcode = aSession->GetStringProperty(mApprovalCode);

		if(aSession->PropertyExists(mPurchaseId, MTPipelineLib::SESS_PROP_TYPE_STRING)) 
			purchaseid = aSession->GetStringProperty(mPurchaseId);

		//
		// If we get this far, no errors in session data.
		//
		blnErrorInSessionData = FALSE;

		// user does not require confirmation e-mail
		if (confirmrequested == _bstr_t("0"))
			return S_OK;

		if (CREDITCARDACCOUNT_SUCCESS != retcode)
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Error was detected earlier in the pipeline, e-mail won't be sent");
			return S_OK;
		}

		if (email.length() == 0)
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "E-mail addresss not specified, e-mail won't be sent");
			return S_OK;
		}

		if (amount <= 0.0)
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Amount less or equal to 0, e-mail won't be sent");
			return S_OK;
		}

    EMAILLib::IMTEmailPtr iEmail;
    EMAILMESSAGELib::IMTEmailMessagePtr iEmailMessage;

    //
    // Initialize MTEmail stuff
    //

    hr = iEmail.CreateInstance("Email.MTEmail.1") ;
    if (!SUCCEEDED(hr))
    {
	  	char * buffer = "Unable to create instance of email object";
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
		  return S_FALSE;
	  }

    hr = iEmailMessage.CreateInstance("EmailMessage.MTEmailMessage.1") ;
    if (!SUCCEEDED(hr))
    {
	  	char * buffer = "Unable to create instance of email message object";
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
		  return S_FALSE;
	  }
    
    if (S_OK != iEmail->init((EMAILLib::IMTEmailMessage *)iEmailMessage.GetInterfacePtr()))
    {
	  	char * buffer = "Unable to initialize email object";
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
		  return S_FALSE;
	  }


	if (cctype != 0)
		iEmail->PutTemplateName(mTemplateName_CC);
	else if (batype != 0)
		iEmail->PutTemplateName(mTemplateName_ACH);
	else
	{
		char * buffer = "Neither cc type nor bank account type is in the session!";
	  	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
		return S_FALSE;
	}
	
	iEmail->PutTemplateFileName(mTemplateFileName);
    iEmail->PutTemplateLanguage(mTemplateLanguage);
    iEmail->LoadTemplate();


    struct tm * newtime;
    time_t      long_time;

    time(&long_time);                /* Get time as long integer. */
    newtime = localtime(&long_time); /* Convert to local time. */

    char chrDate[128];
    sprintf(chrDate, "%.19s", asctime(newtime));

    iEmail->AddParam("%%ADDRESSEE%%", (BSTR)name);
    iEmail->AddParam("%%DATE%%", chrDate);

#ifdef DECIMAL_PLUGINS
    iEmail->AddParam("%%AMOUNT%%", amount.Format(2).c_str());
#else
    char chrAmount[50];   
    sprintf(chrAmount, "%.2f", amount);
    iEmail->AddParam("%%AMOUNT%%", chrAmount);
#endif

    iEmail->AddParam("%%LASTFOURDIGITS%%", last4);
    
	if(cctype)
		iEmail->AddParam("%%CREDITCARDTYPE%%", mEnumConfig->GetEnumeratorByID(cctype));
	if(batype)
		iEmail->AddParam("%%BANKACCOUNTTYPE%%", mEnumConfig->GetEnumeratorByID(batype));
    
	iEmail->AddParam("%%APPROVALCODE%%", approvalcode);
    iEmail->AddParam("%%PURCHASEID%%", purchaseid);

    iEmailMessage->PutMessageTo(email);
    iEmailMessage->PutMessageCC(_bstr_t((const char *)""));
    iEmailMessage->PutMessageBcc(_bstr_t((const char *)""));

    hr = iEmail->Send();
  }
  catch (_com_error & err)
  {
    //
    // This plugin didn't cause the error and nobody else threw
    // an error, so let this one through.
    //
    if (blnErrorInSessionData)
    {
      return S_OK;
    }

    hr = ReturnComError(err);
  }

	return hr;
}

HRESULT
MTEmailPaymentNoticePlugIn::PlugInShutdown()
{
	return S_OK;
}
