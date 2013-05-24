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

#include <StdAfx.h>
#include <stdio.h>
#include <string>
#include <vector>
#include <Enums.h>
#include <mtglobal_msg.h>
#include <DBAccess.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <mtprogids.h>

#define RETURN_IF_FAILED(x) if(FAILED(x)) return x


#include <PlugInSkeleton.h>

#define UPDATE_PAYMENT_SCHEDULER_STATUS_TAG						L"__UPDATE_SCHEDULED_PAYMENT_STATUS__"
#define	RELATIVE_PATH_TO_QUERIES							L"\\paymentsvr\\config\\PaymentServer"


// import Rowset tlb file
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
using namespace ROWSETLib;


#import <MTEnumConfigLib.tlb> 

CLSID CLSID_UpdatePaymentScheduler = {  
	/*ee6ba560-affe-11d4-95dc-00b0d025b121*/
	  0x9fed8680,
		0xd453,
		0x11d4,
		{ 0x95, 0xdc, 0x00, 0xb0, 0xd0, 0x25, 0xb1, 0x21 }
};


class ATL_NO_VTABLE UpdatePaymentScheduler : 
	public MTPipelinePlugIn<UpdatePaymentScheduler, &CLSID_UpdatePaymentScheduler >
{
protected:
   // Initialize the processor, looking up any necessary property IDs.
   // The processor can also use this time to do any other necessary initialization.
   virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
									MTPipelineLib::IMTConfigPropSetPtr aPropSet,
									MTPipelineLib::IMTNameIDPtr aNameID,
									MTPipelineLib::IMTSystemContextPtr aSysContext);

   virtual HRESULT PlugInShutdown();

   virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

	 
	 HRESULT InitRowset();
	 HRESULT UpdateSchedulerProductView(const long& aNewStatus, const wchar_t* aPSTRID);
	
private: // data
  MTPipelineLib::IMTLogPtr mLogger;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	IMTSQLRowsetPtr mpRowset;
	_bstr_t mExtensionsDir;
	long mTrID;
	long mIntervalID;
	long mAccountID;
	long mNewPaymentStatus;
	
	
};


PLUGIN_INFO(CLSID_UpdatePaymentScheduler, UpdatePaymentScheduler,
			"MetraPipeline.UpdatePaymentScheduler.1",
			"MetraPipeline.UpdatePaymentScheduler", "Both")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////
HRESULT UpdatePaymentScheduler::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
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
		DECLARE_PROPNAME("PaymentServiceTransactionID",&mTrID)
		DECLARE_PROPNAME("IntervalID",&mIntervalID)
		DECLARE_PROPNAME("AccountID",&mAccountID)
		DECLARE_PROPNAME("Status",&mNewPaymentStatus)
	END_PROPNAME_MAP

	hr = ProcessProperties(inputs, aPropSet, aNameID, mLogger,/*PROCEDURE*/NULL);
	if (!SUCCEEDED(hr))
	  return hr;

 	try
	{
		//get enum config pointer from system context
		mEnumConfig = aSysContext->GetEnumConfig();
		_ASSERTE(mEnumConfig != NULL);
	}
	catch(_com_error& e)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Failed to get EnumConfig Interface pointer from SysContext");
		return ReturnComError(e);
	}

	//if(!mSE.Init(mExtensionsDir, mEnumConfig))
	//	return Error("Failed to initialize SchedulerEvaluator object");
	return InitRowset();
}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT UpdatePaymentScheduler::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr(S_OK);
	_bstr_t sPSTranID;
	long lIntervalID, lAccountID;
	long lNewStatus;


	//step 1: Get interval id and paymentservicetransacation id properties from session
	try
	{
		lIntervalID = aSession->GetLongProperty(mIntervalID);
		lAccountID = aSession->GetLongProperty(mAccountID);
		lNewStatus = aSession->GetEnumProperty(mNewPaymentStatus);
		sPSTranID = aSession->GetBSTRProperty(mTrID);
	}
	catch(_com_error& e)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Failed getting IntervalID, AccountID or PaymentServiceTransactionID properties from session!");
		return ReturnComError(e);
	}


	//step3: Update payment scheduler record
	try
	{
		hr = UpdateSchedulerProductView(lNewStatus, (const wchar_t*)sPSTranID);
		RETURN_IF_FAILED(hr);
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
UpdatePaymentScheduler::PlugInShutdown()
{
	return S_OK;
}

HRESULT UpdatePaymentScheduler::InitRowset()
{
	HRESULT hr(S_OK);
	char buf[255];

	hr = mpRowset.CreateInstance(MTPROGID_SQLROWSET);
	RETURN_IF_FAILED(hr);

	try
	{
		mpRowset->Init(mExtensionsDir + RELATIVE_PATH_TO_QUERIES);
	}
	catch(_com_error& e)
	{
		sprintf(buf, "Failed to initialize MTPROGID_SQLROWSET instance,  <%s>", (const char*)e.Description());
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
		return ReturnComError(e);
	}
	return hr;
}




HRESULT UpdatePaymentScheduler::UpdateSchedulerProductView(const long& aNewStatus, const wchar_t* aPSTRID)
{
	HRESULT hr(S_OK);
	_variant_t vValue;
	_bstr_t bstrEnumValue;
	ASSERT(mEnumConfig != NULL);
	try
	{
		mpRowset->Clear();
		mpRowset->SetQueryTag(UPDATE_PAYMENT_SCHEDULER_STATUS_TAG);
		mpRowset->AddParam(MTPARAM_PS_PAYMENT_STATUS_ID, _variant_t(aNewStatus));
		mpRowset->AddParam(MTPARAM_PS_TRANSACTION_ID, _variant_t(aPSTRID));
		mpRowset->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	return hr;
}


