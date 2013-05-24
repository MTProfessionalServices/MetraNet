// MTAccountCredit.cpp : Implementation of CMTAccountCredit
#include "StdAfx.h"
#include "AccountCredit.h"
#include "MTAccountCredit.h"
#include <SharedDefs.h>
#include <MTUtil.h>
#include <mttime.h>


// import the serveraccess tlb file
#import <MTServerAccess.tlb>
using namespace MTSERVERACCESSLib;

/////////////////////////////////////////////////////////////////////////////
// CMTAccountCredit
CMTAccountCredit::CMTAccountCredit() : 
													mConfigAccountCreditServer(NULL), 
													mMeterAccountCreditServer(mConfigAccountCreditServer)
													
{
// initialize the logger
  LoggerConfigReader configReader;
  mLogger.Init(configReader.ReadConfiguration(KIOSK_STR), "[MTAccountCredit]");

	//mCreditTime = 0.0;
	mIsInitialized = FALSE;
	mAutoCredit = _bstr_t("N");
	mRequestID = 0;
	mContentionSessionID = _bstr_t("");
	m_AccountID = 0;
	m_Currency = _bstr_t("");
	mRequestID = 0;
	mEmailNotification = FALSE;
	mbstrEmailNotification = _bstr_t("");
	mEmailAddress = _bstr_t("");
	mEmailText = _bstr_t("");
	mIssuer = _bstr_t("");
	mReason = _bstr_t("");
	mOther = _bstr_t("");
	mInvoiceComment = _bstr_t("");
	mInternalComment = _bstr_t("");
	mAccountingCode = _bstr_t("");
	mStatus = _bstr_t("");

}
STDMETHODIMP CMTAccountCredit::Initialize()
{
	HRESULT hr = S_OK;
  const char* procName = "MTAccountCredit::Initialize";
	string buffer;

	if (mIsInitialized) return hr;
	
  try
  {
    MTSERVERACCESSLib::IMTServerAccessDataSetPtr mtdataset;
    hr = mtdataset.CreateInstance("MTServerAccess.MTServerAccessDataSet.1");
    if (!SUCCEEDED(hr))
    {
      buffer = "Unable to create instance of MTServerAccessDataSet object"; 
      mLogger.LogThis(LOG_ERROR, buffer.c_str()); 
      return Error(buffer.c_str(), IID_IMTAccountCredit, hr);
    }
		
    hr = mtdataset->Initialize();
    if (!SUCCEEDED(hr))
    {
      buffer = "Initialize method failed on MTServerAccessDataSet object"; 
      mLogger.LogThis(LOG_ERROR, buffer.c_str()); 
      return Error(buffer.c_str(), IID_IMTAccountCredit, hr);
    }
		
    long count = 0;
    mtdataset->get_Count(&count);
    if (count == 0)
    {
      buffer = "No records found in the MTServerAccessDataSet object"; 
      mLogger.LogThis(LOG_ERROR, buffer.c_str());  
      return Error(buffer.c_str(), IID_IMTAccountCredit, hr);
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
			else if (stricmp(data->GetServerType(), "accountcreditserver") == 0) break;
		}
		mAccountCreditServer = data->GetServerName();
		mAccountCreditServerPort = data->GetPortNumber();
		mAccountCreditServerSecure = data->GetSecure();
		
  }
  catch (_com_error e)
  {
    SetError (e.Error(), 
			ERROR_MODULE, 
			ERROR_LINE, 
			"Exception in Initialize method of MTAccountCredit object" );
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (NULL);
  }
	
  // set the mIsInitialized value to TRUE
  mIsInitialized = TRUE;
	
	// Initialize the SDK for communication with account credit.
	
	if (!mMeterAccountCreditServer.Startup())
	{
		MTMeterError* err = mMeterAccountCreditServer.GetLastErrorObject();
		mLogger.LogThis(LOG_ERROR, "Could not initialize the SDK");
		PrintError (buffer, err);
		hr = E_FAIL;
		return Error(buffer.c_str(), IID_IMTAccountCredit, hr);
	}
	
	mConfigAccountCreditServer.AddServer(
		0,                      // priority (highest)
		mAccountCreditServer.c_str(),    // hostname
		mAccountCreditServerPort,				// port
		(BOOLEAN)mAccountCreditServerSecure,
		"Account Credit",	// username
		"Account Credit");	// password
 	return hr;
}

STDMETHODIMP CMTAccountCredit::get_RequestID(long *pVal)
{
	*pVal = mRequestID;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_RequestID(long newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mRequestID = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_ContentionSessionID(BSTR *pVal)
{
	*pVal = mContentionSessionID.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_ContentionSessionID(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mContentionSessionID = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get__AccountID(long *pVal)
{
	*pVal = m_AccountID;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put__AccountID(long newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	m_AccountID = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get__Amount(VARIANT *pVal)
{
	_variant_t var(m_Amount);
	*pVal = var;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put__Amount(VARIANT newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	
	
	//gets the decimal out of the variant
	if ((newVal.vt == (VT_VARIANT | VT_BYREF)) &&     //handles VBScript variables
			((newVal.pvarVal)->vt == VT_DECIMAL))
		m_Amount = *((newVal.pvarVal)->pdecVal);
	else if (newVal.vt == (VT_DECIMAL | VT_BYREF))    //handles VB variables
		m_Amount = *newVal.pdecVal;
	else if (newVal.vt == VT_DECIMAL)
		m_Amount = newVal.decVal;
		else
		return E_INVALIDARG;

	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get__Currency(BSTR *pVal)
{
	*pVal = m_Currency.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put__Currency(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	m_Currency = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_EmailNotification(BOOL *pVal)
{
	*pVal = mEmailNotification;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_EmailNotification(BOOL newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mEmailNotification = newVal;
	mbstrEmailNotification = (mEmailNotification)?"Y":"N";
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_EmailAddress(BSTR *pVal)
{
	*pVal = mEmailAddress.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_EmailAddress(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mEmailAddress = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_EmailText(BSTR *pVal)
{
	*pVal = mEmailText.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_EmailText(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mEmailText = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_Issuer(BSTR *pVal)
{
	*pVal = mIssuer.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_Issuer(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mIssuer = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_Reason(BSTR *pVal)
{
	*pVal = mReason.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_Reason(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mReason = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_Other(BSTR *pVal)
{
	*pVal = mOther.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_Other(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mOther = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_InvoiceComment(BSTR *pVal)
{
	*pVal = mInvoiceComment.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_InvoiceComment(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mInvoiceComment = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_InternalComment(BSTR *pVal)
{
	*pVal = mInternalComment.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_InternalComment(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mInternalComment = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_AccountingCode(BSTR *pVal)
{
	*pVal = mAccountingCode.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_AccountingCode(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mAccountingCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::Submit()
{
	HRESULT hr = S_OK;
  string buffer;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	
	mLogger.LogVarArgs(LOG_DEBUG, "Account ID is <%d>", m_AccountID);
	mLogger.LogVarArgs(LOG_DEBUG, "Amount is <%s>", m_Amount.Format().c_str());
	mLogger.LogVarArgs(LOG_DEBUG, "Currency is <%s>", (char*)m_Currency);
	mLogger.LogVarArgs(LOG_DEBUG, "Request ID is <%d>", mRequestID);
	//see if all the properties are initialized
	if(	m_AccountID == 0		||
			//m_Amount <= 0	|| wanted to meter negative amount as well
			m_Currency == _bstr_t("")
			)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Not all needed properties initialized, exiting");
		return E_FAIL;
	}

	MTMeterSession* session = mMeterAccountCreditServer.CreateSession(DEFAULT_SERVICE_NAME);
	time_t credit_time = GetMTTime();
	//TimetFromOleDate(&credit_time, mCreditTime);
	//char* time_str = ctime(&credit_time);
	//_variant_t vtCreditTime(mCreditTime, VT_DATE);

	//allocate the MTDecimalValue objects
	MTDecimalValue * pDecAmount = MTDecimalValue::Create();
	MTDecimalValue * pDecRequestAmount = MTDecimalValue::Create();
	MTDecimalValue * pDecCreditAmount = MTDecimalValue::Create();
	if (!pDecAmount || !pDecRequestAmount || !pDecCreditAmount) {
		mLogger.LogVarArgs(LOG_ERROR, "Could not create MTDecimalValue objects");
		return E_FAIL;
	}
		
	//sets their values
	pDecAmount->SetValue(m_Amount.Format().c_str());
	pDecRequestAmount->SetValue(mRequestAmount.Format().c_str());
	pDecCreditAmount->SetValue(mCreditAmount.Format().c_str());
			
  if (!session->InitProperty("Auto", (const char*)mAutoCredit) || 
			!session->InitProperty("CreditTime", credit_time, MTMeterSession::SDK_PROPTYPE_DATETIME)		|| 
			!session->InitProperty("Status", (const char*)mStatus)	|| 
			!session->InitProperty("RequestID",		(int)mRequestID)	|| 
			!session->InitProperty("ContentionSessionID", (const char*)mContentionSessionID) || 
			!session->InitProperty("_AccountID", (int)m_AccountID) || 
			!session->InitProperty("_Amount", pDecAmount) || 
			!session->InitProperty("_Currency", (const char*)m_Currency) || 
			!session->InitProperty("EmailNotification", (const char*)mbstrEmailNotification) || 
			!session->InitProperty("EmailAddress", (const char*)mEmailAddress) || 
			!session->InitProperty("EmailText", (const char*)mEmailText) || 
			!session->InitProperty("Issuer", (const char*)mIssuer) || 
      !session->InitProperty("Reason", (const char*)mReason) ||   
			!session->InitProperty("Other", (const char*)mOther)	||
			!session->InitProperty("InvoiceComment", (const char*)mInvoiceComment) ||
			!session->InitProperty("InternalComment", (const char*)mInternalComment) ||
			!session->InitProperty("AccountingCode", (const char*)mAccountingCode)	||
			!session->InitProperty("RequestAmount", pDecRequestAmount)	||
			!session->InitProperty("CreditAmount", pDecCreditAmount)	||
			!session->InitProperty("ReturnCode", 0))
	{
    MTMeterError * err = session->GetLastErrorObject();
		mLogger.LogThis(LOG_ERROR, "Could not initialize the session property");
		PrintError (buffer.c_str(), err);
		hr = E_FAIL;
		delete session;

		//cleans up the decimal values
		delete pDecAmount;
		delete pDecRequestAmount;
		delete pDecCreditAmount;

		return Error(buffer.c_str(), IID_IMTAccountCredit, hr);
  }

	//cleans up the decimal values
	delete pDecAmount;
	delete pDecRequestAmount;
	delete pDecCreditAmount;
	

	//Meter session synchronously
	
	// set mode to synchronous
  session->SetResultRequestFlag();
  
  // send the session to the server
  if (!session->Close())
  {
    MTMeterError * err = session->GetLastErrorObject();
    mLogger.LogThis(LOG_ERROR, "Could not meter/close the session");
    PrintError (buffer, err);
    hr = E_FAIL;
		delete session;
		return Error(buffer.c_str(), IID_IMTAccountCredit, hr);
  }

	// get the results back -- this will contain the account ID
    MTMeterSession* creditresults = session->GetSessionResults();
    ASSERT(creditresults);
    int nRetCode = 0;
    creditresults->GetProperty("ReturnCode", nRetCode);
		delete session;
		return nRetCode<0 ? E_FAIL : S_OK;
}

void 
CMTAccountCredit::PrintError(const string& prefix, 
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


STDMETHODIMP CMTAccountCredit::get_Status(BSTR *pVal)
{
	*pVal = mStatus.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_Status(BSTR newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mStatus = newVal;
	return hr;
}

STDMETHODIMP CMTAccountCredit::get_AutoCredit(BSTR *pVal)
{
	*pVal = mAutoCredit.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_AutoCredit(BSTR newVal)
{
	
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }
	mAutoCredit = newVal;
	return hr;
}

STDMETHODIMP CMTAccountCredit::get_RequestAmount(VARIANT *pVal)
{
	_variant_t var(mRequestAmount);
	*pVal = var;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_RequestAmount(VARIANT newVal)
{
	HRESULT hr = S_OK;

	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }

	//gets the decimal out of the variant
	if ((newVal.vt == (VT_VARIANT | VT_BYREF)) &&     //handles VBScript variables
			((newVal.pvarVal)->vt == VT_DECIMAL))
		mRequestAmount = *((newVal.pvarVal)->pdecVal);
	else if (newVal.vt == (VT_DECIMAL | VT_BYREF))    //handles VB variables
		mRequestAmount = *newVal.pdecVal;
	else if (newVal.vt == VT_DECIMAL)
		mRequestAmount = newVal.decVal;
	
	else
		return E_INVALIDARG;

	return S_OK;
}

STDMETHODIMP CMTAccountCredit::get_CreditAmount(VARIANT *pVal)
{

	_variant_t var(mCreditAmount);
	*pVal = var;
	return S_OK;
}

STDMETHODIMP CMTAccountCredit::put_CreditAmount(VARIANT newVal)
{
	HRESULT hr = S_OK;
	// check if object is initialized or not
  if (!mIsInitialized)
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Object not initialized, initializing...");
    Initialize();
  }

	//gets the decimal out of the variant
	if ((newVal.vt == (VT_VARIANT | VT_BYREF)) &&     //handles VBScript variables
			((newVal.pvarVal)->vt == VT_DECIMAL))
		mCreditAmount = *((newVal.pvarVal)->pdecVal);
	else if (newVal.vt == (VT_DECIMAL | VT_BYREF))    //handles VB variables
		mCreditAmount = *newVal.pdecVal;
	else if (newVal.vt == VT_DECIMAL)
		mCreditAmount = newVal.decVal;
	else
		return E_INVALIDARG;

	return S_OK;
}
