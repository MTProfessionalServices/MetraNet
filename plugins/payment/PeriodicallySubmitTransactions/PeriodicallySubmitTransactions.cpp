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
#include <PST.h>
#include <PlugInSkeleton.h>

// import Rowset tlb file
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

#import <MTEnumConfigLib.tlb> 

CLSID CLSID_PeriodicallySubmitTransactions = {  /*f397cd10-a9dc-11d4-95dc-00b0d025b121*/
  0xf397cd10,
    0xa9dc,
    0x11d4,
		{ 0x95, 0xdc, 0x00, 0xb0, 0xd0, 0x25, 0xb1, 0x21 }
};


class ATL_NO_VTABLE PeriodicallySubmitTransactions : 
public MTPipelinePlugIn<PeriodicallySubmitTransactions, &CLSID_PeriodicallySubmitTransactions >
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
  
	 HRESULT InitMeterServer();
   
   PeriodicallySubmitTransactions::PeriodicallySubmitTransactions():
   mMeterServer(mMeterServerConfig)
   {}
   
private: // data
  MTPipelineLib::IMTLogPtr mLogger;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  TransactionsToSubmit mTranList;
  MTMeterHTTPConfig mMeterServerConfig;
  MTMeter mMeterServer;
  _bstr_t mServerName;
  int mServerPort;
  int mServerSecure;
  _bstr_t mExtensionsDir;
  long mTrID;
  SchedulerEvaluator mSE;
  _bstr_t mUserName,mPassword;
  
  
};


PLUGIN_INFO(CLSID_PeriodicallySubmitTransactions, PeriodicallySubmitTransactions,
            "MetraPipeline.PeriodicallySubmitTransactions.1",
            "MetraPipeline.PeriodicallySubmitTransactions", "Free")
            
            /////////////////////////////////////////////////////////////////////////////
            //PlugInConfigure
            /////////////////////////////////////////////////////////////////////////////
            HRESULT PeriodicallySubmitTransactions::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
            MTPipelineLib::IMTConfigPropSetPtr aPropSet,
            MTPipelineLib::IMTNameIDPtr aNameID,
            MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  HRESULT hr(S_OK);
  _bstr_t buffer;
  
  std::string aExtDir;
  GetExtensionsDir(aExtDir);
  
  mExtensionsDir = aExtDir.c_str();
  
  
  // grab an instance of the logger so we can use it in process sessions if
  // we need to 
  mLogger = aLogger;
  
  // Declare the list of properties we will read from the XML configuration
  // When ProcessProperties is called, it loads the property Ids into the
  // variable that was passed 
  DECLARE_PROPNAME_MAP(inputs)
    
    DECLARE_PROPNAME("TransactionID",&mTrID)
    
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
  
  if(!mSE.Init(mExtensionsDir, mEnumConfig))
    return Error("Failed to initialize SchedulerEvaluator object");
  
  return InitMeterServer();
}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT PeriodicallySubmitTransactions::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr(S_OK);
  TransactionsToSubmit::iterator it;
  char buf[1024];
  _bstr_t sPSTranID;
  
  //first try and get PaymentServiceTransactionID from session
  //if this property is not in session, then get all payments from PaymentScheduler PV
  // and if it is in session, process payment for this transaction id
  try
  {
    sPSTranID = aSession->GetBSTRProperty(mTrID);
    PaymentTransaction pt;
    if(!mSE.GetTransaction((wchar_t*)sPSTranID, pt))
      return Error("Failed to get transaction from SchedulerEvaluator");
    mTranList.clear();
    mTranList.push_back(&pt);
  }
  catch(_com_error&)
  {
    if(!mSE.GetTransactionList(mTranList))
      return Error("Failed to get transaction list from SchedulerEvaluator");
  }
  
  if(mTranList.size() == 0)
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "No payments qualified to be submitted now, exiting.");
    return hr;
  }
  
  sprintf(buf, "Total of <%d> transactions will be submitted now", mTranList.size());
  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);
  
  for(it=mTranList.begin(); it != mTranList.end(); ++it)
  {
    PaymentTransactionResult ptr;
    PaymentTransaction* pt = (*it);
    
    //If either AuthReceived or PrenoteValidated flags are not set and this is ACH transaction, then
    //update status to INCOMPLETE_ACCOUNT_INFO, do not process this payment, just update PaymentScheduler product view
    if((pt->GetPaymentType() == PS_ACH) && (!pt->GetAuthReceived() || !pt->GetPrenoteValidated())) 
    {
      pt->SetPaymentStatus(PS_INCOMPLETE_ACCOUNT_INFO);
      sprintf(buf, 
        "Did not submit transaction with session id <%d> because either authorization wasn't received or pre-notification was not completed",
        pt->GetSessionID());
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
    }
    else if(!pt->Submit(ptr, &mMeterServer))
    {
      sprintf(buf,"Failed to submit transaction with id <%s> ", (const char*)_bstr_t(pt->GetPaymentServiceTransactionID().c_str()));
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
      return Error(buf);
    }
    if(!pt->UpdateStatus(ptr, mSE))
    {
      sprintf(buf,"Failed to update status for transaction with id <%s> ", (const char*)_bstr_t(pt->GetPaymentServiceTransactionID().c_str()));
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
      return Error(buf);
    }
    
  }
  
  return hr;
}

HRESULT PeriodicallySubmitTransactions::InitMeterServer()
{
  HRESULT hr;
  _bstr_t buffer;
  
  try
  {
    MTSERVERACCESSLib::IMTServerAccessDataSetPtr mtdataset;
    hr = mtdataset.CreateInstance("MTServerAccess.MTServerAccessDataSet.1");
    if (!SUCCEEDED(hr))
    {
      buffer = "Unable to create instance of MTServerAccessDataSet object"; 
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
      return Error((wchar_t*)buffer);
    }
    
    hr = mtdataset->Initialize();
    if (!SUCCEEDED(hr))
    {
      buffer = "Initialize method failed on MTServerAccessDataSet object"; 
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
      return Error((wchar_t*)buffer);
    }
    
    // if this fails, it will throw an exception
    MTSERVERACCESSLib::IMTServerAccessDataPtr data = mtdataset->FindAndReturnObject("paymentserver");
    mServerName = data->GetServerName();
    mServerPort = data->GetPortNumber();
    mServerSecure = data->GetSecure();
    mUserName = data->GetUserName();
    mPassword = data->GetPassword();
    
  }
  catch (_com_error& e)
  {
    buffer = "Error in PeriodicallySubmitTransactions::InitMeterServer(), Description:" + 
      e.Description();
    
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
    return Error((wchar_t*)buffer);
  }
  
  if (!mMeterServer.Startup())
  {
    buffer = "Could not initialize the SDK";
    //MTMeterError* err = mMeterServer.GetLastErrorObject();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
    return Error((wchar_t*)buffer);
  }
  
		mMeterServerConfig.AddServer(
      0,                      // priority (highest)
      mServerName,    // hostname
      mServerPort,				// port
      (BOOLEAN)mServerSecure,
      mUserName,	// username
      mPassword);	// password
    // set the mIsInitialized value to TRUE
    return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT 
PeriodicallySubmitTransactions::PlugInShutdown()
{
  TransactionsToSubmit::iterator it;
  for (it=mTranList.begin(); it != mTranList.end(); ++it)
  {
    delete (*it);
    (*it) = NULL;
  }
  return S_OK;
}
