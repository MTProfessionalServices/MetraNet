// Session.cpp : Implementation of CSession
#include "StdAfx.h"
#include "COMMeter.h"
#include "Session.h"
#include "SessionSet.h"
#include "mtsdk.h"
#include "mtsdkex.h"
#include "mtdefs.h"
#include "mtcomerr.h"
#include <MTUtil.h>
#include "MTDecimalVal.h"
#include <MTDec.h>
#include <MTObjectCollection.h>


#define Debugger() __asm { __asm int 3 }

////
//// CSession
////

CSessionSet::CSessionSet()
{
  // MeteringSessionSetImp * MSIXNetMeterAPI::CreateSessionSet()
  // m_SessionSet = (MTMeterSessionSet*) CreateSessionSet();
  
}

CSessionSet::~CSessionSet()
{
  if (m_SessionSet)
		delete m_SessionSet;

	long sess_count;
	mSessionsHold.Count( &sess_count);
	for (long i = 1; i<=sess_count; i++)
	{
		ISession *sess_pointer;		
		mSessionsHold.Item(i, &sess_pointer);
		CSession *pCSess;
		pCSess = static_cast<CSession *>(sess_pointer);
		pCSess->SetSDKSession(NULL);
      pCSess->Release();
	}
}

void CSessionSet::SetSDKSessionSet(MTMeterSessionSet * set)
{
  m_SessionSet = set;
}


// ----------------------------------------------------------------
// Description: This method creates and returns a session, and also
// adds it to this sessionset object, so they can all be sent at once 
// later on when close is called. 
// ----------------------------------------------------------------

STDMETHODIMP CSessionSet::CreateSession (BSTR servicename, /*[out, retval]*/ ISession** new_session)
{
  MTMeterSession * newSDKSession;
  CComObject<CSession> * com_session;
  ISession * i_session;
  HRESULT retval = S_OK;
  bstr_t	sn;

  // Try to instantiate the COM object
  retval = CComObject<CSession>::CreateInstance(&com_session);
  if (FAILED(retval)) 
    return retval;
  
  sn = servicename;
  
  // Grab the session COM interface
  retval = com_session->QueryInterface(IID_ISession, (void**) &i_session);
  
  if (SUCCEEDED(retval))
	{
		newSDKSession = m_SessionSet->CreateSession((const char *) sn); // MTMeterSession
      
		// Make sure we could create the Session object.
		if (!newSDKSession)
		{
			return HandleMeterError();
		}
		// We don't need an else, but I will leave it here for clarity
		else
		{
			// Convert MTMeterSession into CSession
			com_session->SetSDKSession(newSDKSession);
			com_session->SetSessionName(servicename);
			AddSession(com_session);
			*new_session = i_session; 
		}
	}
  else
	{
		// QueryInterface failed. Return retval.
		return retval;
	}
   
  return S_OK;
}


// ----------------------------------------------------------------
// Description: This method will send the set with all sessions
// associated to it to the server.
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::Close()
{
  // VALIDATE_SESSION() // Do we need something like this for the batched sessions?
   if (!m_SessionSet->Close())
   {
      return HandleMeterError();
   }
  
   return S_OK;
}

// ----------------------------------------------------------------
// Description: This method will convert the session set into
// its XML representation.
// Return Value: MSIX/XML representation of the session set
// ----------------------------------------------------------------
HRESULT CSessionSet::ToXML(/*[out, retval]*/ BSTR *pVal)
{
	int bufferSize = 0;
	(void) m_SessionSet->ToXML(NULL, bufferSize);
	char * buffer = new char[bufferSize];
	(void) m_SessionSet->ToXML(buffer, bufferSize);

	// NOTE: we have to construct the BSTR manually.  if we rely
	// on the _bstr_t constructor and pass in a large string the
	// program will crash with a stach exception.
	// See CMTConfigPropSet::WriteToBuffer for more info
	USES_CONVERSION;
	*pVal = A2BSTR(buffer);
	return S_OK;
}

HRESULT CSessionSet::GetSessionSetXmlStream(/*[out, retval]*/ BSTR *xml)
{
  string str = ((MeteringSessionSetImp*)m_SessionSet)->GetBuffer();

  USES_CONVERSION;
	
	/*const char *data;
	int length;
	stringWrite.GetData(&data, length);*/
	*xml = A2BSTR(str.c_str());

  return S_OK;
}

// ----------------------------------------------------------------
// Description: Obtains the SessionSetID.
// Return Value: Session ID: base64 encoded Unique ID (UID)
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::get_SessionSetID(BSTR *pVal)
{
  char lSessionSetID[SESSION_ID_LEN];
  
  m_SessionSet->GetSessionSetID(lSessionSetID);
  m_SessionSetID = lSessionSetID;

  *pVal = m_SessionSetID.copy();  
  return S_OK;
}

// ----------------------------------------------------------------
// Description: Returns the collection of the Sessions held by the Session set
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::GetSessions(IMTCollection** col)
{
  mSessionsHold.CopyTo( col );
  return S_OK;
}


// ----------------------------------------------------------------
// Description: Sets the TransactionID, a base64 encoded string
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::put_TransactionID(BSTR TransactionID)
{
	_bstr_t txnID(TransactionID);
	m_SessionSet->SetTransactionID((const char *) txnID);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets the ListenerTransactionID, a base64 encoded string
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::put_ListenerTransactionID(BSTR TransactionID)
{
	_bstr_t txnID(TransactionID);
	m_SessionSet->SetListenerTransactionID((const char *) txnID);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets the Session Context
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::put_SessionContext(BSTR SessionContext)
{
	_bstr_t sessionctx(SessionContext);
	m_SessionSet->SetSessionContext((const char *) sessionctx);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets the SessionContextUserName
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::put_SessionContextUserName(BSTR UserName)
{
	_bstr_t username(UserName);
	m_SessionSet->SetSessionContextUserName((const char *) username);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets the Password
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::put_SessionContextPassword(BSTR Password)
{
	_bstr_t password(Password);
	m_SessionSet->SetSessionContextPassword((const char *) password);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets the Namespace
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::put_SessionContextNamespace(BSTR Namespace)
{
	_bstr_t mtnamespace(Namespace);
	m_SessionSet->SetSessionContextNamespace((const char *) mtnamespace);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Sets the Namespace
// ----------------------------------------------------------------
STDMETHODIMP CSessionSet::SetProperties(/*[in]*/ BSTR listenerTransactionID, 
                                        /*[in]*/ BSTR transactionID,
                                        /*[in]*/ BSTR sessionContext,
                                        /*[in]*/ BSTR sessionContextUserName,
                                        /*[in]*/ BSTR sessionContextPassword,
                                        /*[in]*/ BSTR sessionContextNamespace)
{
   if (listenerTransactionID != NULL) 
   {
      put_ListenerTransactionID(listenerTransactionID);
   }

   if (transactionID != NULL) 
   {
      put_TransactionID(transactionID);
   }

   if (sessionContext != NULL) 
   {
      put_SessionContext(sessionContext);
      return S_OK;
   }

   if (sessionContextUserName == NULL || 
       sessionContextPassword == NULL || 
       sessionContextNamespace == NULL) 
   {
      Error("Need UserName/Password/Namespace or SessionContext.");
		return E_INVALIDARG;
   }

   put_SessionContextUserName(sessionContextUserName);
   put_SessionContextPassword(sessionContextPassword);
   put_SessionContextNamespace(sessionContextNamespace);

   return S_OK;
}


STDMETHODIMP CSessionSet::put__SetID(/*[in]*/ BSTR newVal)
{
	try
	{
		MTSetSessionSetIDEx(m_SessionSet, _bstr_t(newVal));
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}


// What is this for???
STDMETHODIMP CSessionSet::InterfaceSupportsErrorInfo(REFIID riid)
{
static const IID* arr[] = { &IID_ISessionSet };
for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
 return S_FALSE;
}

// ----------------------------------------------------------------
// Description: Adds the session to the MTObjectCollection
// ----------------------------------------------------------------
void CSessionSet::AddSession(ISession *pSession)
{
	mSessionsHold.Add( pSession );
}


//
// Called only on error -- converts and returns an HRESULT
//
HRESULT CSessionSet::HandleMeterError()
{
	MTMeterError *err = m_SessionSet->GetLastErrorObject();
	if (err)
	{
		// Create buffer to store error message in
		TCHAR errorBuf[ERROR_BUFFER_LEN];
		int errorBufSize = sizeof(errorBuf);

		// Get Error Info from SDK
		err->GetErrorMessageEx(errorBuf, errorBufSize);
		if (wcslen(errorBuf) == 0)
			err->GetErrorMessage(errorBuf, errorBufSize);

		DWORD hrcode = err->GetErrorCode();
		if (!FAILED(hrcode))
			hrcode = HRESULT_FROM_WIN32(hrcode);

		Error(errorBuf, 0, NULL, GUID_NULL, hrcode);
		delete err;
    return hrcode;
	}

	return E_FAIL;
}