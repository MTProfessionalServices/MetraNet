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
#include <RTS.h>
#include <PlugInSkeleton.h>
#include <string>

using namespace std;


// import Rowset tlb file
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

#import <MTEnumConfigLib.tlb> 
#import <Email.tlb>
#import <EmailMessage.tlb>


CLSID CLSID_RetrieveTransactionStatus = {  /*f397cd10-a9dc-11d4-95dc-00b0d025b121*/
  /*ee6ba560-affe-11d4-95dc-00b0d025b121*/
  0xee6ba560,
    0xaffe,
    0x11d4,
		{ 0x95, 0xdc, 0x00, 0xb0, 0xd0, 0x25, 0xb1, 0x21 }
};


class ATL_NO_VTABLE RetrieveTransactionStatus : 
public MTPipelinePlugIn<RetrieveTransactionStatus, &CLSID_RetrieveTransactionStatus >
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
   HRESULT InitRowset();
   HRESULT GetACHRecordList(ACHRecordList& aList, const wchar_t* aTag);
   HRESULT GetACHRecord(ACHRecord* aRecord, const wchar_t* aTag, const wchar_t*	aTransactionID);
   HRESULT UpdateACHOrSchedulerProductView(ACHRecord& aRecord, const wchar_t* aTag);
   BOOL Inquire(ACHRecord& aRecord);
   HRESULT SendPrenoteEmailMessage(ACHRecord* aRecord, PaymentServer::PaymentStatus aStatus);
   
   RetrieveTransactionStatus::RetrieveTransactionStatus():
   mMeterServer(mMeterServerConfig)
   {}
   
private: // data
  MTPipelineLib::IMTLogPtr mLogger;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  MTMeterHTTPConfig mMeterServerConfig;
  ROWSETLib::IMTSQLRowsetPtr mpRowset;
  MTMeter mMeterServer;
  _bstr_t mExtensionsDir;
  long mTrID;
  ACHRecordList mRecordList;
  
  _bstr_t mTemplateFileName;
  _bstr_t mTemplateName_Success;                
  _bstr_t mTemplateName_Failure;                
  _bstr_t mTemplateLanguage;                    
};


PLUGIN_INFO(CLSID_RetrieveTransactionStatus, RetrieveTransactionStatus,
            "MetraPipeline.RetrieveTransactionStatus.1",
            "MetraPipeline.RetrieveTransactionStatus", "Free")
            
            /////////////////////////////////////////////////////////////////////////////
            //PlugInConfigure
            /////////////////////////////////////////////////////////////////////////////
            HRESULT RetrieveTransactionStatus::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
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
  
  _bstr_t RelativeTemplateFileName     = aPropSet->NextStringWithName("templatefilename");
  mTemplateName_Success                = aPropSet->NextStringWithName("templatename_success");
  mTemplateName_Failure                = aPropSet->NextStringWithName("templatename_failure");
  mTemplateLanguage                    = aPropSet->NextStringWithName("templatelanguage");
  
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
  mTemplateFileName += RelativeTemplateFileName; 
  
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
  hr = InitRowset();
  if(FAILED(hr))
    return hr;
  return InitMeterServer();
}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT RetrieveTransactionStatus::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr(S_OK);
  wchar_t buf[512];
  vector<ACHRecord*>::iterator it;
  _bstr_t sPSTranID;
  mRecordList.clear();
  
  //first try and get PaymentServiceTransactionID from session
  //if this property is not in session, then retrieve status for all 
  //transactions for ACH credit and debit product views
  // and if it is in session, try and get status for only this transaction
  try
  {
    sPSTranID = aSession->GetBSTRProperty(mTrID);
    ACHRecord* pachr = NULL;
    //try debits first, if not found (S_FALSE), then try credits
    if (GetACHRecord(pachr, GET_ACH_PRENOTE_RECORD_TAG, sPSTranID) == S_FALSE)
      if (GetACHRecord(pachr, GET_ACH_DEBIT_RECORD_TAG, sPSTranID) == S_FALSE)
        if (GetACHRecord(pachr, GET_ACH_CREDIT_RECORD_TAG, sPSTranID) == S_FALSE)
        {
          wsprintf(buf, L"Transaction with id of <%s> not found in ACH product views",(const wchar_t*)sPSTranID);
          return Error(buf);
        }
        if (pachr != NULL)
          mRecordList.push_back(pachr);
  }
  catch(_com_error&)
  {
    
    try
    {
      if(SUCCEEDED(GetACHRecordList(mRecordList, GET_ACH_PRENOTE_RECORDS_TAG)))
        if(SUCCEEDED(GetACHRecordList(mRecordList, GET_ACH_DEBIT_RECORDS_TAG)))
          if(SUCCEEDED(GetACHRecordList(mRecordList, GET_ACH_CREDIT_RECORDS_TAG)))
          {
            ;//do something?
          }
    }
    catch(_com_error& err)
    {
      return ReturnComError(err);
    }
  }
  
  //OK, we got ACH record list to retrieve status for
  //Now get new status for all these records one by one.
  if(mRecordList.size() == 0)
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, "RetrieveTransactionStatus: No ACH records retrieved");
    return S_OK;
  }
  
  try
  {
    
    for (it = mRecordList.begin(); it != mRecordList.end(); ++it)
    {
      if(!Inquire(**it))
      {
        //Bug 4617 fix:
        //Metering to ach_inquiry can fail for different reasons:
        // This particular inquiry instance related as well as Verisign related 
        //(Connection down etc.)
        //We probably still want to try and submit all subsequent payments
        //even this one fails
        //So just proceed to next for iteration
        //return Error("Failed metering ACH Inguiry field");
        continue;
      }
      if ((**it).GetTransactionType() == ACH_DEBIT)
      {
        UpdateACHOrSchedulerProductView(**it,UPDATE_ACH_DEBIT_RECORD_TAG);
      }
      else if ((**it).GetTransactionType() == ACH_CREDIT)
      {
        UpdateACHOrSchedulerProductView(**it,UPDATE_ACH_CREDIT_RECORD_TAG);
      }
      else //prenote
      {
        //in case of prenote do nothing with scheduler PV, just update prenote and go to next for iteration
        //if status was settled (returned as P01), then update t_ps_ach record to have nm_validated to '1'
        if ((*it)->GetNewStatus() == PS_SETTLED)
        {
          UpdateACHOrSchedulerProductView(**it,UPDATE_ACH_PRENOTE_RECORD_TAG);
          SendPrenoteEmailMessage(*it, PS_SETTLED);
        }
        else if((*it)->GetNewStatus() == PS_FAILED)
          SendPrenoteEmailMessage(*it, PS_FAILED);		
        
        continue;
      }
      
      UpdateACHOrSchedulerProductView(**it,UPDATE_PAYMENT_SCHEDULER_RECORD_TAG);
      
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
  return hr;
}

HRESULT RetrieveTransactionStatus::InitMeterServer()
{
  HRESULT hr;
  _bstr_t buffer;
  
  MTSERVERACCESSLib::IMTServerAccessDataSetPtr mtdataset;
  hr = mtdataset.CreateInstance("MTServerAccess.MTServerAccessDataSet.1");
  if (!SUCCEEDED(hr))
  {
    buffer = "Unable to create instance of MTServerAccessDataSet object"; 
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
    return Error((wchar_t*)buffer);
  }
  
  try {
    mtdataset->Initialize();
    MTSERVERACCESSLib::IMTServerAccessDataPtr data = mtdataset->FindAndReturnObject("paymentserver");
    
    if (!mMeterServer.Startup())
    {
      buffer = "Could not initialize the SDK";
      //MTMeterError* err = mMeterServer.GetLastErrorObject();
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
      hr = Error((wchar_t*)buffer);
    }
    else {
      
      mMeterServerConfig.AddServer(
        data->GetPriority(),       // priority (highest)
        data->GetServerName(),    // hostname
        data->GetPortNumber(),		 // port
        data->GetSecure(),
        data->GetUserName(),			 // username
        data->GetPassword());			 // password
    }
  }
  catch(_com_error& e) {
    buffer = "Error in RetrieveTransactionStatus::InitMeterServer(), Description:" + 
      e.Description();
    
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
    hr =  Error((wchar_t*)buffer);
  }
  
  return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT 
RetrieveTransactionStatus::PlugInShutdown()
{
  ACHRecordList::iterator it;
  for (it=mRecordList.begin(); it != mRecordList.end(); ++it)
  {
    delete (*it);
    (*it) = NULL;
  }
  return S_OK;
}

HRESULT RetrieveTransactionStatus::InitRowset()
{
  HRESULT hr(S_OK);
  char buf[255];
  
  hr = mpRowset.CreateInstance(MTPROGID_SQLROWSET);
  
  if(FAILED(hr))
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Faile to create MTPROGID_SQLROWSET object");
    return hr;
  }
  
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

HRESULT RetrieveTransactionStatus::GetACHRecordList(ACHRecordList& aList, const wchar_t* aTag)
{
  HRESULT hr(S_OK);
  ACHRecord* achr;
  _variant_t vValue;
  long	lCurrentStatus;
  long enumVal;
  PaymentServer::PaymentStatus ePaymentStatus;
  
  TransactionType ttype;
  
  if(_wcsicmp(aTag, GET_ACH_DEBIT_RECORDS_TAG) == 0)
    ttype = ACH_DEBIT;
  else if (_wcsicmp(aTag, GET_ACH_CREDIT_RECORDS_TAG) == 0)
    ttype = ACH_CREDIT;
  else
    ttype = ACH_PRENOTE;
  
  ASSERT(mEnumConfig != NULL);
  
  //step 2: initialize Rowset with the query and execute it
  try
  {
    mpRowset->Clear();
    mpRowset->SetQueryTag(aTag);
    mpRowset->Execute();
    
    while (mpRowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      
      //Processing is slightly different for records in prenote PV
      //If this record is prenote, then just set PSTRID
      
      if(ttype != ACH_PRENOTE)
      {
        lCurrentStatus = (long)mpRowset->GetValue(_variant_t(CURRENT_STATUS_COLUMN));
        
        
        wstring value = mEnumConfig->GetEnumeratorValueByID(lCurrentStatus);
        BOOL ret = ConvertToLong(value, &enumVal);
        ASSERT(ret);
        ePaymentStatus = (PaymentServer::PaymentStatus) enumVal;
        
        switch(ePaymentStatus)
        {
        case PS_SENT:
          {
            achr = new ACHRecord();
            achr->SetTransactionType(ttype);
            vValue = mpRowset->GetValue(_variant_t(PAYMENT_SERVER_TRANSACTION_ID_COLUMN));
            achr->SetPSTransactionID((const wchar_t*)MTMiscUtil::GetString(vValue));
            aList.push_back(achr);
            break;
          }
        }
      }
      else
      {
        achr = new ACHRecord();
        achr->SetTransactionType(ttype);
        vValue = mpRowset->GetValue(_variant_t(PAYMENT_SERVER_TRANSACTION_ID_COLUMN));
        achr->SetPSTransactionID((const wchar_t*)MTMiscUtil::GetString(vValue));
        vValue = mpRowset->GetValue(_variant_t(DB_EMAIL));
        achr->SetEmailAddress((const wchar_t*)MTMiscUtil::GetString(vValue));
        vValue = mpRowset->GetValue(_variant_t(DB_ACCOUNTTYPE));
        achr->SetBankAccountType(vValue.lVal);	
        vValue = mpRowset->GetValue(_variant_t(DB_LASTFOURDIGITS));
        achr->SetLastFourDigits((const wchar_t*)MTMiscUtil::GetString(vValue));	
        aList.push_back(achr);
      }
      
      mpRowset->MoveNext();
    }
    
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return hr;
}

HRESULT RetrieveTransactionStatus::GetACHRecord(ACHRecord* apRecord, 
                                                const wchar_t* aTag,
                                                const wchar_t*	aTransactionID
                                                )
{
  HRESULT hr(S_OK);
  _variant_t vValue;
  long	lCurrentStatus;
  long enumVal;
  PaymentServer::PaymentStatus ePaymentStatus;
  _variant_t vTranID(aTransactionID);
  wchar_t buf[512];
		TransactionType ttype;
    
    if(_wcsicmp(aTag, GET_ACH_DEBIT_RECORD_TAG) == 0)
      ttype = ACH_DEBIT;
    else if(_wcsicmp(aTag, GET_ACH_DEBIT_RECORD_TAG) == 0)
      ttype = ACH_CREDIT;
    else
      ttype = ACH_PRENOTE;
    
    ASSERT(mEnumConfig != NULL);
    
    try
    {
      mpRowset->Clear();
      mpRowset->SetQueryTag(aTag);
      mpRowset->AddParam(MTPARAM_PS_TRANSACTION_ID, vTranID);
      
      mpRowset->Execute();
      
      if (mpRowset->GetRecordCount() == 0)
      {
        wsprintf(buf, L"ACH record with given id of <%s> could not be retrieved from <%s> query", aTransactionID, aTag);
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);
        return S_FALSE;
      }
      
      if (mpRowset->GetRecordCount() > 1)
      {
        wsprintf(buf, L"More then one ACH record with given id of <%s> was retrieved from <%s> query", aTransactionID, aTag);
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
        return Error(buf);
      }
      //Processing is slightly different for records in prenote PV
      //If this record is prenote, then just set PSTRID
      
      if(ttype != ACH_PRENOTE)
      {
        
        lCurrentStatus = (long)mpRowset->GetValue(_variant_t(CURRENT_STATUS_COLUMN));
        wstring value = mEnumConfig->GetEnumeratorValueByID(lCurrentStatus);
        BOOL ret = ConvertToLong(value, &enumVal);
        ASSERT(ret);
        ePaymentStatus = (PaymentServer::PaymentStatus) enumVal;
        
        switch(ePaymentStatus)
        {
        case PS_SENT:
          {
            apRecord = new ACHRecord;
            apRecord->SetTransactionType(ttype);
            vValue = mpRowset->GetValue(_variant_t(PAYMENT_SERVER_TRANSACTION_ID_COLUMN));
            apRecord->SetPSTransactionID((const wchar_t*)MTMiscUtil::GetString(vValue));
            break;
          }
        }
      }
      else
      {
        apRecord = new ACHRecord;
        apRecord->SetTransactionType(ttype);
        vValue = mpRowset->GetValue(_variant_t(PAYMENT_SERVER_TRANSACTION_ID_COLUMN));
        apRecord->SetPSTransactionID((const wchar_t*)MTMiscUtil::GetString(vValue));
        vValue = mpRowset->GetValue(_variant_t(DB_EMAIL));
        apRecord->SetEmailAddress((const wchar_t*)MTMiscUtil::GetString(vValue));
        vValue = mpRowset->GetValue(_variant_t(DB_ACCOUNTTYPE));
        apRecord->SetBankAccountType(vValue.lVal);	
        vValue = mpRowset->GetValue(_variant_t(DB_LASTFOURDIGITS));
        apRecord->SetLastFourDigits((const wchar_t*)MTMiscUtil::GetString(vValue));	
      }
      
      mpRowset->MoveNext();
    }
    catch(_com_error& e)
    {
      return ReturnComError(e);
    }
    return hr;
}


HRESULT RetrieveTransactionStatus::UpdateACHOrSchedulerProductView(ACHRecord& aRecord, const wchar_t* aTag)
{
  HRESULT hr(S_OK);
  _variant_t vValue;
  
  long lPaymentStatusDescValue;
  _bstr_t bstrEnumValue;
  wchar_t value[128];
  
  //convert enum value into description id
  bstrEnumValue = _ltow((long)aRecord.GetNewStatus(), value, 10);
  lPaymentStatusDescValue = mEnumConfig->GetID(PAYMENT_SERVER_ENUM_SPACE, PAYMENT_STATUS_ENUM_TYPE, bstrEnumValue);
  ASSERT(mEnumConfig != NULL);
  try
  {
    mpRowset->Clear();
    mpRowset->SetQueryTag(aTag);
    mpRowset->AddParam(MTPARAM_PS_TRANSACTION_ID, _variant_t(aRecord.GetPSTransactionID().c_str()));
    
    
    if(aRecord.GetTransactionType() != ACH_PRENOTE)
    {
      mpRowset->AddParam(MTPARAM_PS_PAYMENT_STATUS_ID, _variant_t(lPaymentStatusDescValue));
      if(_wcsicmp(aTag, UPDATE_PAYMENT_SCHEDULER_RECORD_TAG) == 0)
      {
        mpRowset->AddParam(MTPARAM_RESP_STRING_PARAM, _variant_t(aRecord.GetResponseString().c_str()));
        mpRowset->AddParam(MTPARAM_PAYMENT_PROVIDER_CODE_PARAM, _variant_t(aRecord.GetResponseCode()));
      }
    }
    
    
    
    mpRowset->Execute();
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return hr;
}


BOOL RetrieveTransactionStatus::Inquire(ACHRecord& aRecord)
{
  BOOL ret(FALSE);
  MTMeterSession* session = mMeterServer.CreateSession(ACH_INQUIRY_SERVICE);
  
  if (!session->InitProperty("paymentservicetransactionid", aRecord.GetPSTransactionID().c_str()) || 
    !session->InitProperty("testsession", "0")
    )
  {
    int size = 255;
    char*	buf = new char[size];
    char logbuff[512];
    MTMeterError * err = session->GetLastErrorObject();
    err->GetErrorMessage(buf, size);
    sprintf(logbuff, "Could not initialize the session property: <%s>", buf);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, logbuff);
    delete[] buf;
    return FALSE;
  }
		
  // set mode to synchronous
  session->SetResultRequestFlag();
  
  // send the session to the server
  if (!session->Close())
  {
    int size = 255;
    char*	buf = new char[size];
    char logbuff[512];
    MTMeterError * err = session->GetLastErrorObject();
    err->GetErrorMessage(buf, size);
    sprintf(logbuff, "Could not Meter ach_inquiry Session for record with pnref <%s>: <%s>", ascii(aRecord.GetPSTransactionID()).c_str(), buf);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, logbuff);
    delete[] buf;
    return FALSE;
  }
  
  MTMeterSession* results = session->GetSessionResults();
  ASSERT(results);
  int RetCode;
  wstring status, response;
  const wchar_t* statusbuf = status.c_str();
  const wchar_t* respbuf	=	response.c_str();
  results->GetProperty("status", &statusbuf);
  results->GetProperty("respstring", &respbuf);
  results->GetProperty("retcode", RetCode);
  
  if(RetCode == CREDITCARDACCOUNT_SUCCESS)
  {
    aRecord.SetNewStatus(ConvertStatusStringToEnum(statusbuf));
    aRecord.SetResponseString(respbuf);
    aRecord.SetResponseCode(RetCode);
  }
  else
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "ACH inquiry failed");
    return FALSE;
  }
  delete session;
  return TRUE;
  
}

HRESULT RetrieveTransactionStatus::SendPrenoteEmailMessage(ACHRecord* aRecord, PaymentServer::PaymentStatus aStatus)
{
  HRESULT hr = S_OK;
  
  EMAILLib::IMTEmailPtr iEmail;
  EMAILMESSAGELib::IMTEmailMessagePtr iEmailMessage;
  
  //check for e-mail address om the record. If its empty, just return
  if(!aRecord->GetEmailAddress().length())
    return hr;
  
  try 
  {
    hr = iEmail.CreateInstance("Email.MTEmail.1") ;
    if (FAILED(hr))
    {
      char * buffer = "Unable to create instance of email object";
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
      return hr;
    }
    
    hr = iEmailMessage.CreateInstance("EmailMessage.MTEmailMessage.1") ;
    if (FAILED(hr))
    {
      char * buffer = "Unable to create instance of email message object";
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
      return hr;
    }
    
    hr = iEmail->init((EMAILLib::IMTEmailMessage *)iEmailMessage.GetInterfacePtr());
    if (FAILED(hr))
    {
      char * buffer = "Unable to initialize email object";
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
      return hr;
    }
    
    if (aStatus == PS_FAILED)
      iEmail->PutTemplateName(mTemplateName_Failure);
    else if (aStatus == PS_SETTLED)
      iEmail->PutTemplateName(mTemplateName_Success);
    
    iEmail->PutTemplateFileName(mTemplateFileName);
    iEmail->PutTemplateLanguage(mTemplateLanguage);
    iEmail->LoadTemplate();
    
    iEmail->AddParam("%%LASTFOURDIGITS%%", aRecord->GetLastFourDigits().c_str());
    iEmail->AddParam("%%BANKACCOUNTTYPE%%", mEnumConfig->GetEnumeratorByID(aRecord->GetBankAccountType()));
    
    iEmailMessage->PutMessageTo(aRecord->GetEmailAddress().c_str());
    iEmailMessage->PutMessageCC(_bstr_t((const char *)""));
    iEmailMessage->PutMessageBcc(_bstr_t((const char *)""));
    hr = iEmail->Send();
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
  return hr;
}
