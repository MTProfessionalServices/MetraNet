// MTAccountCreditRequest.cpp : Implementation of CMTAccountCreditRequest
#include "StdAfx.h"
#include "AccountCreditRequest.h"
#include "MTAccountCreditRequest.h"
#include <SharedDefs.h>


#define INIT_MESSAGE L"Object not initialized, initializing..."


// import the serveraccess tlb file
#import <MTServerAccess.tlb>
using namespace MTSERVERACCESSLib;
/////////////////////////////////////////////////////////////////////////////
// CMTAccountCreditRequest

CMTAccountCreditRequest::CMTAccountCreditRequest() : 
													mConfigAccountCRServer(NULL), mMeterAccountCRServer(mConfigAccountCRServer)
													
{
// initialize the logger
  LoggerConfigReader configReader;
  mLogger.Init(configReader.ReadConfiguration(KIOSK_STR), "[MTAccountCreditRequest]");

	mAccountID = 0;
	mSubscriberAccountID = 0;
	m_Amount = 0.0;
	mCreditAmount = 0.0;
  m_Currency = _bstr_t("");
	mReason = _bstr_t("");
	mOther = _bstr_t("");
  mNeedNotification = FALSE;
	mbstrNeedNotification = _bstr_t("");
	mEmailAddress = _bstr_t("");
	mDescription = _bstr_t("");
	mStatus = _bstr_t("PENDING");
	mContentionID = _bstr_t("");
	mSessionID = _bstr_t("");
	mIsInitialized = FALSE;

}

STDMETHODIMP CMTAccountCreditRequest::Initialize()
{
	HRESULT hr = S_OK;
  const char* procName = "MTAccountCreditRequest::Initialize";
	string buffer;
	
  try
  {
    MTSERVERACCESSLib::IMTServerAccessDataSetPtr mtdataset;
    hr = mtdataset.CreateInstance("MTServerAccess.MTServerAccessDataSet.1");
    if (!SUCCEEDED(hr))
    {
      buffer = "Unable to create instance of MTServerAccessDataSet object"; 
      mLogger.LogThis(LOG_ERROR, buffer.c_str()); 
      return Error(buffer.c_str(), IID_IMTAccountCreditRequest, hr);
    }
		
    hr = mtdataset->Initialize();
    if (!SUCCEEDED(hr))
    {
      buffer = "Initialize method failed on MTServerAccessDataSet object"; 
      mLogger.LogThis(LOG_ERROR, buffer.c_str()); 
      return Error(buffer.c_str(), IID_IMTAccountCreditRequest, hr);
    }
		
    long count = 0;
    mtdataset->get_Count(&count);
    if (count == 0)
    {
      buffer = "No records found in the MTServerAccessDataSet object"; 
      mLogger.LogThis(LOG_ERROR, buffer.c_str());  
      return Error(buffer.c_str(), IID_IMTAccountCreditRequest, hr);
    }
		
    SetIterator<MTSERVERACCESSLib::IMTServerAccessDataSetPtr, 
			MTSERVERACCESSLib::IMTServerAccessDataPtr> it;
    HRESULT hr = it.Init(mtdataset);
    if (FAILED(hr))
      return hr;
		
    MTSERVERACCESSLib::IMTServerAccessDataPtr data;
		string servertype;
    string servername;
		
		for(;data = it.GetNext();)
		{
			if (data == NULL) break;
	  	else if (stricmp(data->GetServerType(), "accountcreditrequestserver") == 0) break;
		}
		mAccountCRServer = data->GetServerName();
		mAccountCRServerPort = data->GetPortNumber();
		mAccountCRServerSecure = data->GetSecure();
		
  }
  catch (_com_error e)
  {
    SetError (e.Error(), 
			ERROR_MODULE, 
			ERROR_LINE, 
			"Exception in Initialize method of MTAccountCreditRequest object" );
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (E_FAIL);
  }
	
  // set the mIsInitialized value to TRUE
  mIsInitialized = TRUE;
	
	// Initialize the SDK for communication with account credit request.
	
	if (!mMeterAccountCRServer.Startup())
	{
		MTMeterError* err = mMeterAccountCRServer.GetLastErrorObject();
		mLogger.LogThis(LOG_ERROR, "Could not initialize the SDK");
		PrintError (buffer, err);
		hr = ACCOUNTCREDITREQUEST_ERR_SDK_STARTUP_FAILED;
		return Error(buffer.c_str(), IID_IMTAccountCreditRequest, hr);
	}
	
	mConfigAccountCRServer.AddServer(
		0,                      // priority (highest)
		mAccountCRServer.c_str(),    // hostname
		mAccountCRServerPort,				// port
		(BOOLEAN)mAccountCRServerSecure,
		"Account Credit Request",	// username
		"Account Credit Request");	// password
 	return hr;
}

/////////////////////////////////////////////////////////////////
//		BEGIN PROPERTIES
//////////////////////////////////////////////////////////////////

STDMETHODIMP CMTAccountCreditRequest::get__AccountID(long *pVal)
{
	(*pVal) = mAccountID;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put__AccountID(long newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }

	mAccountID = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get__Amount(double *pVal)
{
	*pVal = m_Amount;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put__Amount(double newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	m_Amount = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get_CreditAmount(double *pVal)
{
	*pVal = mCreditAmount;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_CreditAmount(double newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mCreditAmount = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get__Currency(BSTR *pVal)
{
	*pVal = m_Currency.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put__Currency(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	m_Currency = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get_EmailNotification(BOOL *pVal)
{
	*pVal = mNeedNotification;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_EmailNotification(BOOL newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mNeedNotification = newVal;
	//init _bstr value, MSIX doesn't support bool
	if (mNeedNotification)
		mbstrNeedNotification = "Y";
	else
		mbstrNeedNotification = "N";
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get_EmailAddress(BSTR *pVal)
{
	*pVal = mEmailAddress.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_EmailAddress(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mEmailAddress = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get_Reason(BSTR *pVal)
{
	*pVal = mReason.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_Reason(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mReason = newVal;
	return S_OK;
}
STDMETHODIMP CMTAccountCreditRequest::get_Other(BSTR *pVal)
{
	*pVal = mOther.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_Other(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mOther = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get_Description(BSTR *pVal)
{
	*pVal = mDescription.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_Description(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mDescription = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get_Status(BSTR *pVal)
{
	*pVal = mStatus.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_Status(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mStatus = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::get_ContentionID(BSTR *pVal)
{
	*pVal = mContentionID.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_ContentionID(BSTR newVal)
{
	HRESULT hr = S_OK;
	if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }
	mContentionID = newVal;
	return S_OK;
}

/////////////////////////////////////////////////////////////////
//		END PROPERTIES
//////////////////////////////////////////////////////////////////
STDMETHODIMP CMTAccountCreditRequest::Submit()
{
	HRESULT hr = S_OK;
  string buffer;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }

	mLogger.LogVarArgs(LOG_DEBUG, "Account ID is <%d>", mAccountID);
	mLogger.LogVarArgs(LOG_DEBUG, "Amount is <%f>", (float)m_Amount);
	mLogger.LogVarArgs(LOG_DEBUG, "Currency is <%s>", (char*)m_Currency);
	
	//see if all the properties are initialized
	if(	mAccountID == 0		||
		//	m_Amount == 0.0	||
			m_Currency == _bstr_t("") ||
			(mNeedNotification && (mEmailAddress == _bstr_t("")))
		)
	{
		hr = ACCOUNTCREDITREQUEST_NOT_ALL_NEEDED_PROPERTIES_INITIALIZED;
		mLogger.LogVarArgs(LOG_ERROR, "Not all needed properties initialized, exiting");
		return hr;
	}

	MTMeterSession* session = mMeterAccountCRServer.CreateSession(DEFAULT_SERVICE_NAME);
	
  if (!session->InitProperty("_AccountID", (int)mAccountID) || 
      !session->InitProperty("SubscriberAccountID", (int)mSubscriberAccountID) || 
      !session->InitProperty("_Amount", (double)m_Amount) ||
      !session->InitProperty("CreditAmount", (double)mCreditAmount) ||
      !session->InitProperty("_Currency", (const char*)m_Currency) || 
      !session->InitProperty("Reason", (const char*)mReason) ||
      !session->InitProperty("Other", (const char*)mOther) ||
      !session->InitProperty("EmailNotification", (const char*)mbstrNeedNotification) || 
      !session->InitProperty("EmailAddress", (const char*)mEmailAddress) || 
      !session->InitProperty("Description", (const char*)mDescription)	||
      // need to initialize all the properties, although below 
      // can only be set by the pipeline
      !session->InitProperty("ContentionSessionID", (const char*)mContentionID) ||
      !session->InitProperty("Status", (const char*)mStatus))
	{
    		MTMeterError * err = session->GetLastErrorObject();
		mLogger.LogThis(LOG_ERROR, "Could not initialize the property on the session");
		PrintError (buffer.c_str(), err);
		hr = ACCOUNTCREDITREQUEST_ERR_SESS_INIT_PROPERTY_FAILED;
		delete session;
		 return Error(buffer.c_str(), IID_IMTAccountCreditRequest, hr);
  }

	//Meter session asynchronously
	
	// set mode to asynchronous
  session->SetResultRequestFlag(FALSE);
  
  // send the session to the server
  if (!session->Close())
  {
    MTMeterError * err = session->GetLastErrorObject();
    mLogger.LogThis(LOG_ERROR, "Could not meter/close the session");
    PrintError (buffer, err);
    hr = E_FAIL;
    delete session;
    return Error(buffer.c_str(), IID_IMTAccountCreditRequest, hr);
  }


	return hr;
}

void 
CMTAccountCreditRequest::PrintError(const string& prefix, 
							   const MTMeterError * err)
{
  _bstr_t buffer = prefix.c_str();
	if (err)
	{
	  int size = 0;
		err->GetErrorMessage((char*) NULL, size);
		char* buf = new char[size];
		err->GetErrorMessage(buf, size);

		buffer += _bstr_t("SDK Error: ") + _bstr_t(buf);
		mLogger.LogThis(LOG_ERROR, (char*)buffer);
	}
	else
	{
	  buffer = "*UNKNOWN ERROR*";
		mLogger.LogThis(LOG_ERROR, (char*)buffer);
	}

	return;
}







STDMETHODIMP CMTAccountCreditRequest::get_SubscriberAccountID(long *pVal)
{
	(*pVal) = mSubscriberAccountID;
	return S_OK;
}

STDMETHODIMP CMTAccountCreditRequest::put_SubscriberAccountID(long newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    hr = ACCOUNTCREDITREQUEST_OBJECT_NOT_INITIALIZED;
    mLogger.LogVarArgs (LOG_DEBUG, INIT_MESSAGE);
    Initialize();
  }

	mSubscriberAccountID = newVal;
	return S_OK;
}
