/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Boris Partensky
* 
***************************************************************************/

#include <metralite.h>
#include <stdio.h>
#include <string>
#include <vector>
#include <mtglobal_msg.h>
#include <DBAccess.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <mtprogids.h>

#include <PlugInSkeleton.h>

const wchar_t RELATIVE_PATH_TO_QUERIES[] = L"\\paymentsvr\\config\\PaymentServer";

// import Rowset tlb file
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")
using namespace ROWSETLib;

// generate using uuidgen
CLSID CLSID_UPDATEPAYMENTSCHEDULERWITHCONFIRM = { 
/*01d2cd50-bf37-11d4-af01-00c04f54fe3b*/
  0x01d2cd50,
  0xbf37,
  0x11d4,
  {0xaf, 0x01, 0x00, 0xc0, 0x4f, 0x54, 0xfe, 0x3b}
};

class ATL_NO_VTABLE UpdatePaymentSchedulerWithConfirm : 
	public MTPipelinePlugIn<UpdatePaymentSchedulerWithConfirm, &CLSID_UPDATEPAYMENTSCHEDULERWITHCONFIRM>
{
protected:

   // Initialize the processor, looking up any necessary property IDs.
   // The processor can also use this time to do any other necessary 
   // initialization.
   virtual HRESULT PlugInConfigure(
	 MTPipelineLib::IMTLogPtr aLogger,
	 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
	 MTPipelineLib::IMTNameIDPtr aNameID,
	 MTPipelineLib::IMTSystemContextPtr aSysContext);

   virtual HRESULT PlugInShutdown();

   virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

	 
	 HRESULT InitRowset();
	 HRESULT UpdatePaymentSchedulerProductViewWithConfirm(
	   const long& aAccountID,
	   const long& aIntervalID);

private: // data
  	MTPipelineLib::IMTLogPtr mLogger;

	IMTSQLRowsetPtr mpRowset;
	_bstr_t mExtensionsDir;
	long mIntervalID;
	long mAccountID;
	long mAmount;
};


PLUGIN_INFO(CLSID_UPDATEPAYMENTSCHEDULERWITHCONFIRM, 
			UpdatePaymentSchedulerWithConfirm,
			"MetraPipeline.UpdatePaymentSchedulerWithConfirm.1",
			"MetraPipeline.UpdatePaymentSchedulerWithConfirm", "Both")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////
HRESULT UpdatePaymentSchedulerWithConfirm::PlugInConfigure(
  MTPipelineLib::IMTLogPtr aLogger,
  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
  MTPipelineLib::IMTNameIDPtr aNameID,
  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
    HRESULT hr(S_OK);
	_bstr_t buffer;

	string aExtDir;
	GetExtensionsDir(aExtDir);

	mExtensionsDir = aExtDir.c_str();
	
    // grab an instance of the logger so we can use it in process sessions if
    // we need to 
	mLogger = aLogger;

	// Declare the list of properties we will read from the XML configuration
	// When ProcessProperties is called, it loads the property Ids into the
	// variable that was passed 
  	DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME("_IntervalID",&mIntervalID)
		DECLARE_PROPNAME("_AccountID",&mAccountID)
		DECLARE_PROPNAME("_Amount",&mAmount)
	END_PROPNAME_MAP

	hr = ProcessProperties(inputs, aPropSet, aNameID, mLogger,NULL);
	if (!SUCCEEDED(hr))
	  return hr;

	return InitRowset();
}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT UpdatePaymentSchedulerWithConfirm::PlugInProcessSession(
  MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr(S_OK);
	long lIntervalID;
	long lAccountID;

	try
	{
	    //step 1: Get interval id an account id and from session
		lIntervalID = aSession->GetLongProperty(mIntervalID);
		lAccountID = aSession->GetLongProperty(mAccountID);

		
		//step2: Update payment scheduler record
		hr = UpdatePaymentSchedulerProductViewWithConfirm(lAccountID, lIntervalID);
		if (FAILED(hr))
			return hr;
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return hr;
}

//
//
//
HRESULT UpdatePaymentSchedulerWithConfirm::InitRowset()
{
	HRESULT hr(S_OK);
	char buf[255];

	hr = mpRowset.CreateInstance(MTPROGID_SQLROWSET);
	
	if(FAILED(hr))
	{
		 mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, 
							"Failed to create Rowset object");
		return hr;
	}

	try
	{
		mpRowset->Init(mExtensionsDir + RELATIVE_PATH_TO_QUERIES);
	}
	catch(_com_error& e)
	{
		sprintf(buf, "Failed to initialize Rowset object <%s>", (const char*)e.Description());
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
		return ReturnComError(e);
	}
	return hr;
}


//
//
//
HRESULT
UpdatePaymentSchedulerWithConfirm::UpdatePaymentSchedulerProductViewWithConfirm(
  const long& aAccountID,
  const long& aIntervalID)
{
	HRESULT hr(S_OK);
	_variant_t vValue;
	_bstr_t bstrEnumValue;
	try
	{
		mpRowset->Clear();
		mpRowset->SetQueryTag(L"__UPDATE_SCHEDULED_PAYMENT_STATUS_WITH_CONFIRM__");
		mpRowset->AddParam(MTPARAM_ACCOUNTID, _variant_t(aAccountID));
		mpRowset->AddParam(MTPARAM_INTERVALID, _variant_t(aIntervalID));
		mpRowset->AddParam(MTPARAM_PS_PAYMENT_STATUS_ID, _variant_t("1"));
		mpRowset->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT 
UpdatePaymentSchedulerWithConfirm::PlugInShutdown()
{
	return S_OK;
}

