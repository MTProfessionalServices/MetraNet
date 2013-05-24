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
 * $Date: 04/03/2002 12:00:41 PM$
 * $Author: Ralf Boeck$
 * $Revision: 7$
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include <mtprogids.h>
#include <vector>
#include <MTDec.h>
#include <corecapabilities.h>
#include <autherr.h>


CLSID CLSID_MTAuthCheck = { 0x80c804eb, 0xa57d, 0x411d, { 0xba, 0x2a, 0x2a, 0x29, 0xc7, 0xe6, 0x10, 0x7a } };

/////////////////////////////////////////////////////////////////////////////
// MTAuthCheck
/////////////////////////////////////////////////////////////////////////////


class ATL_NO_VTABLE MTAuthCheck
  : public MTPipelinePlugIn<MTAuthCheck, &CLSID_MTAuthCheck>
{
protected:
  virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                  MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

  // Shutdown the processor.  The processor can release any resources
  // it no longer needs.
  virtual HRESULT PlugInShutdown();

  virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: 

private: // data
  MTPipelineLib::IMTLogPtr mLogger;
  
  
  //IEnumConfig interface belongs to MTPipelineLib library
  //MTENUMCONFIGLib::IEnumConfigPtr enumType;
  MTPipelineLib::IEnumConfigPtr mEnumConfig;

  MTPipelineLib::IMTNameIDPtr mNameID;
  MTPipelineLib::IMTSecurityPtr security;
  long mAmountPropID;
  long mCapPropID;
  long mCurrencyPropID;
  long mAccountID;
  long mFailurePropID;

  _bstr_t bstrCapName;
  bool mbThrowErrorOnFailure;
  _bstr_t mbstrPropName;

};


PLUGIN_INFO(CLSID_MTAuthCheck, MTAuthCheck,
            "MTPipeline.MTAuthCheck.1", "MTPipeline.MTAuthCheck", "Free")

/////////////////////////////////////////////////////////////////////////a////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSubStr::PlugInConfigure"
HRESULT MTAuthCheck::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                        MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                        MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  
  mLogger = aLogger;
  //HRESULT hr;
  char buffer[1024];
  mNameID = aNameID;
  // Initialize enumtype object.

  try
  {
    mEnumConfig = aSysContext->GetEnumConfig();
  }
  catch(_com_error e)
  {
    sprintf(buffer, "AuthCheck plugin: unable to get IEnumConfig pointer from IMTSystemContext");
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(buffer));
    return ReturnComError(e);
  }

  _bstr_t tag("enumitem");
  
  try 
  {
    MTPipelineLib::IMTConfigPropSetPtr aPropSetPtr;
    MTPipelineLib::IMTConfigPropPtr aProp;

    //aProp = aPropSet->NextSetWithName(tag);

    aPropSetPtr = aPropSet->NextSetWithName("on_failure");

    if(aPropSetPtr != NULL) {
      //Check the action to take on failure
      _bstr_t bstrAction;
      
      bstrAction = aPropSetPtr->NextStringWithName("action");
      
      if(stricmp(bstrAction, "SetProp") == 0) {
        mbstrPropName = aPropSetPtr->NextStringWithName("prop_name");
        mbThrowErrorOnFailure = false;
      } else {
        mbThrowErrorOnFailure = true;
      }
    } else {
      mbThrowErrorOnFailure = true;
    }


  }
  catch (_com_error err)
  {
      const char *errmsg = "Fail to build list of demanded capabilities";
      return Error(errmsg);
  }
  mAmountPropID = aNameID->GetNameID("AmountToAuthorize");
  mCapPropID = aNameID->GetNameID("CapabilityName");
  mCurrencyPropID = aNameID->GetNameID("_currency");
  mAccountID = aNameID->GetNameID("_accountID");

  if(!mbThrowErrorOnFailure)
    mFailurePropID = aNameID->GetNameID(mbstrPropName);
  else
    mFailurePropID = -1;
  
  return security.CreateInstance(MTPROGID_MTSECURITY);
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTAuthCheck::PlugInProcessSession"
HRESULT MTAuthCheck::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr(S_OK);
  _variant_t vAmount;
  _bstr_t vCurrency;
  bool bChecking = false;

  if (aSession->PropertyExists(mCapPropID,
                                MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
  {
      bstrCapName =
        aSession->GetStringProperty(mCapPropID);
  }
  else
  {
    char buf[512];
    sprintf(buf, "Property CapabilityName has to be set in session!");
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
    return Error(buf);
  }

  vAmount = aSession->GetDecimalProperty(mAmountPropID);
  vCurrency = aSession->GetStringProperty(mCurrencyPropID);
  

  MTDecimal decAmount(vAmount);
  MTDecimal absAmount = decAmount.Abs();



  //TODO: Create demanded capabilities that were initialized from plugin
  //configuration file. For now just construct one.
  MTPipelineLib::IMTCompositeCapabilityPtr demandedCap;
  

  AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;

  if (stricmp(bstrCapName, ISSUE_CREDITS_CAP) == 0)
    deniedEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_CREDIT_DENIED;

  MTPipelineLib::IMTSecurityContextPtr ctx = aSession->GetSessionContext()->SecurityContext;
  try
  {
    //demandedCap = security->GetCapabilityTypeByName(bstrCapName)->CreateInstance();
    demandedCap = security->GetCapabilityTypeByName(bstrCapName)->CreateInstance();
    //set decimal atomic capability
    demandedCap->GetAtomicDecimalCapability()->SetParameter(absAmount, MTPipelineLib::OPERATOR_TYPE_EQUAL);
    demandedCap->GetAtomicEnumCapability()->SetParameter(vCurrency);

    bChecking = true;
    ctx->CheckAccess(demandedCap);
    bChecking = false;
  }
  catch(_com_error& e)
  {
    long accountID = aSession->GetLongProperty(mAccountID);

    AuditAuthFailures(e, deniedEvent, ctx->AccountID, 
                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                      accountID);

    //If the error was the result of the auth check then see if an error should be returned
    if(bChecking &&  !mbThrowErrorOnFailure) {
      //Set the property
      aSession->SetBoolProperty(mFailurePropID, VARIANT_TRUE);
      return S_OK;
    }

    return ReturnComError(e);
  }
    return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT MTAuthCheck::PlugInShutdown()
{
  
  return S_OK;
}
