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
 * Modified by: David McCowan 8/16/99
 *   Started with the simpleplugin template.
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>

#include <NTLogger.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <ConfigDir.h>
#include <mtglobal_msg.h>
#include <MTUtil.h>

// import the row set tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace 
#import <MTConfigLib.tlb>

#include <PlugInSkeleton.h>
 
#include <paymentserverdefs.h>

// generate using uuidgen
CLSID CLSID_PreauthLookup = { /* 11e79f00-1486-11d4-a709-00c04f58c76e */
    0x11e79f00,
    0x1486,
    0x11d4,
    {0xa7, 0x09, 0x00, 0xc0, 0x4f, 0x58, 0xc7, 0x6e}
  };

class ATL_NO_VTABLE PreauthLookup
	: public MTPipelinePlugIn<PreauthLookup, &CLSID_PreauthLookup>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.

	PreauthLookup() : mmqcQueryCache(NULL) {}

	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

private:

  long mAccountID;
  long mOriginalId;
  long mInternalTransactionId;
  long mAction;
  long mlngCreditCardType;
  long mlngLastFourDigits;

  _bstr_t mbstrConfigFilePath;
  

	IMTQueryCache * mmqcQueryCache;

	// interface to the logging system
	NTLogger mntlLogger;
};

PLUGIN_INFO(CLSID_PreauthLookup, PreauthLookup,
						"MetraPipeline.PreauthLookup.1", "MetraPipeline.PreauthLookup", "Free")

HRESULT PreauthLookup::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
																				MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  try
  {
    // look up the property IDs of the props we need
    MTPipelineLib::IMTNameIDPtr idlookup(aSysContext);

    // input properties
    _bstr_t AccountID             = aPropSet->NextStringWithName("accountid");
    mAccountID                    = idlookup->GetNameID(AccountID);

    _bstr_t OriginalId            = aPropSet->NextStringWithName("originalid");
    mOriginalId                   = idlookup->GetNameID(OriginalId);

    _bstr_t InternalTransactionId = aPropSet->NextStringWithName("internaltransactionid");
    mInternalTransactionId        = idlookup->GetNameID(InternalTransactionId);

    _bstr_t LastFourDigits        = aPropSet->NextStringWithName("lastfourdigits");
    mlngLastFourDigits            = idlookup->GetNameID(LastFourDigits);

    _bstr_t CreditCardType        = aPropSet->NextStringWithName("creditcardtype");
    mlngCreditCardType            = idlookup->GetNameID(CreditCardType);

    _bstr_t Action                = aPropSet->NextStringWithName("action");
    mAction                       = idlookup->GetNameID(Action);

    // create a query cache object ...
    IMTQueryCachePtr queryCache(MTPROGID_QUERYCACHE);

    mmqcQueryCache = queryCache.Detach();

    std::string sExtensionir;
    if (!GetExtensionsDir(sExtensionir))
    {
      aLogger->LogString(
        MTPipelineLib::PLUGIN_LOG_ERROR,
        "preauthlookup::PlugInConfigure: unable to get configuration directory from registry");
  
      _bstr_t errormsg = "unable to get configuration directory from registry";
      return Error((char*)errormsg);
    }

    mbstrConfigFilePath = sExtensionir.c_str();
	  mbstrConfigFilePath += DIR_SEP;
	  mbstrConfigFilePath += aSysContext->GetExtensionName();
	  mbstrConfigFilePath += "\\config";
    mbstrConfigFilePath += "\\PaymentServer";
  
    // initialize the queryadapter ...
    mmqcQueryCache->Init(mbstrConfigFilePath);

    LoggerConfigReader lcrConfigReader;
    mntlLogger.Init(lcrConfigReader.ReadConfiguration("logging"),
                    (const char *)"PreauthLookup");

  }
  catch (_com_error err)
  {
    return err.Error();
  }

  return S_OK;
}

//
// The purpose of this routine is to be as efficient as possible with respect 
// to processing preauths and postauths. Failures here should be logged (and
// may be the symptom of a larger problem), but they should not abort pipeline
// processing. The worse that can happen is that the credit limit on one's card
// is reduced more than necessary, but this does not mean one is actually
// charged more than appropriate. 
//

HRESULT PreauthLookup::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr = S_OK;
  _variant_t vtParam;

  try
  {
    long action = aSession->GetLongProperty(mAction); 

    //
    // This plugin is used in the preauth and postauth stages. Preauth
    // writes the payment network reference (PNref) to this table.
    // Postauth runs this plugin twice: before and after hitting the card.
    // Postauth retrieves the PNref prior to hitting the card and then
    // deletes the entry upon a successful delayed capture. 
    //

    if (action == PREAUTH_UNKNOWN_ACTION)
      return S_OK;

    // create the queryadapter ...
    ROWSETLib::IMTSQLRowsetPtr rowset;
  
    // create the rowset object and begin the transaction ...
    hr = rowset.CreateInstance(MTPROGID_SQLROWSET) ;
    if (!SUCCEEDED(hr))
    {
      mntlLogger.LogVarArgs(LOG_DEBUG, "Unable to create instance of SQL Rowset object");
      return S_OK;
    }

    rowset->Init(mbstrConfigFilePath);

    if (!SUCCEEDED(hr))
    {
      mntlLogger.LogVarArgs(LOG_DEBUG, "Unable to initialize SQL Rowset object");
      return S_OK;
    }

    if (PREAUTH_INSERT == action)
    {
      //
      // Must be running in the preauth pipeline.
      // Store this PNref.
      //

      long    lngAcctid          = aSession->GetLongProperty(mAccountID); 
      _bstr_t bstrLastFourDigits = aSession->GetStringProperty(mlngLastFourDigits); 
      long    lngCCType          = aSession->GetLongProperty(mlngCreditCardType);
      _bstr_t bstrOriginalid     = aSession->GetStringProperty(mOriginalId); 
      _bstr_t bstrIntxactionid   = aSession->GetStringProperty(mInternalTransactionId); 

      // set the query tag ...
      _bstr_t queryTag = "__INSERT_TO_PREAUTHORIZATIONLIST__" ;
      rowset->SetQueryTag (queryTag) ;
  
      // add the parameters ...
      vtParam = (long) lngAcctid;
      rowset->AddParam ("%%ACCOUNT_ID%%", vtParam) ;
        
      vtParam = bstrLastFourDigits;
      rowset->AddParam ("%%LAST_FOUR_DIGITS%%", vtParam) ;
          
      vtParam = (long) lngCCType;
      rowset->AddParam ("%%CREDIT_CARD_TYPE%%", vtParam) ;
          
      vtParam = bstrOriginalid;
      rowset->AddParam ("%%XACTION_ID%%", vtParam) ;
          
      vtParam = bstrIntxactionid;
      rowset->AddParam ("%%INT_XACTION_ID%%", vtParam) ;
  
      // add new row to table 
      if (S_OK != rowset->Execute())
      {
        mntlLogger.LogVarArgs(LOG_ERROR, "PreauthLookup: insert query execution failed");
        return S_OK;
      }
    }
    else
    {
      //
      // Must be running in the postauth pipeline
      //

      if (PREAUTH_SELECT == action)
      {
        //
        // Read PNref from the database.
        //
				

        long acctid          = aSession->GetLongProperty(mAccountID); 
        _bstr_t intxactionid = aSession->GetStringProperty(mInternalTransactionId); 

				mntlLogger.LogVarArgs(LOG_DEBUG, "Looking up preauth record by accountid  <%d> and internalid <%s>", acctid, (const char*)intxactionid);

        // set the query tag ...
        _bstr_t queryTag = "__GET_XACTION_ID__" ;
        rowset->SetQueryTag (queryTag) ;

        // add the parameters ...
        vtParam = (long) acctid;
        rowset->AddParam("%%ACCOUNT_ID%%", vtParam) ;
      
        vtParam = intxactionid;
        rowset->AddParam("%%INT_XACTION_ID%%", vtParam) ;
      
        // execute the query ...
        if (S_OK != rowset->Execute())
        {
          mntlLogger.LogVarArgs(
            LOG_ERROR,
            "PreauthLookup: select query execution failed");
          return S_OK;
        }

        if (rowset->GetRowsetEOF())
        {
          // TODO: The call to Error is not returning the details to the stage. Once this is fixed,
          //       then the logvarargs call can be removed. 

          char chrBuf[1024];
          sprintf(chrBuf, "%s: %s: 0x%x", 
                  "preauthlookup",
                  "Cannot find matching preauthorization transaction in t_preauthorizationlist",
                  CREDITCARDACCOUNT_ERR_PRE_AUTH_FAILED);

          mntlLogger.LogVarArgs(LOG_ERROR, chrBuf); 

          return Error("Cannot find matching preauthorization transaction in t_preauthorizationlist", 
                       IID_IMTPipelinePlugIn,
                       CREDITCARDACCOUNT_ERR_PRE_AUTH_FAILED);
        }

				//BP TODO: Do we need to check for multiple records back and mark it as error condition?

        // 
        // must have found something
				
        _variant_t vtValue = rowset->GetValue("nm_xactionid");
        _bstr_t    bstrValue = MTMiscUtil::GetString(vtValue);
				mntlLogger.LogVarArgs(LOG_DEBUG, "Found preauth record, pnref is <%s>", (const char*)bstrValue);
        aSession->SetStringProperty(mOriginalId, bstrValue);

        vtValue = rowset->GetValue("nm_lastfourdigits");
        bstrValue = MTMiscUtil::GetString(vtValue);
        aSession->SetStringProperty(mlngLastFourDigits, bstrValue);

        vtValue = rowset->GetValue("id_creditcardtype");
        aSession->SetEnumProperty(mlngCreditCardType, vtValue);
 
      }
      else
      {
        //
        // Remove this PNref from the database.
        //
        _bstr_t xactionid;
       
        //BP TODO: Use PropertyExists() instead of catching exception
				try
        {
          xactionid = aSession->GetStringProperty(mOriginalId); 
        }
        catch (_com_error&)
        {
          //
          // No PNref in the session, so nothing to delete.
          //
          return S_OK;
        }

        // set the query tag ...
        _bstr_t queryTag = "__DELETE_PREAUTHORIZATIONLIST_BY_XACTIONID__" ;
        rowset->SetQueryTag (queryTag) ;

        // add the parameters ...
        vtParam = xactionid;
        rowset->AddParam ("%%XACTION_ID%%", vtParam);

        // delete credit card info 
        return rowset->Execute();
      }
    }
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}


HRESULT PreauthLookup::PlugInShutdown()
{
	if (mmqcQueryCache)
	{
    mmqcQueryCache->Release();
    mmqcQueryCache = NULL;
  }

  return S_OK;
}
