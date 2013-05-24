// Batch.cpp : Implementation of CSession
#include "StdAfx.h"
#include "COMMeter.h"
#include "Session.h"
#include "SessionSet.h"
#include "Batch.h"
#include "mtsdk.h"
#include "mtdefs.h"
#include <MTUtil.h>
#include "MTDecimalVal.h"
#include <MTDec.h>

// #import <COMMeter.tlb>

#define Debugger() __asm { __asm int 3 }

////
//// CBatch
////

CBatch::CBatch()
{
	// Generated Code
}

CBatch::~CBatch()
{
   if (m_Batch)
		delete m_Batch;
}

void CBatch::SetSDKBatch(MTMeterBatch * batch)
{
  m_Batch = batch;
}

STDMETHODIMP CBatch::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = { &IID_IBatch };
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CBatch::get_UID(BSTR *pVal)
{
	_bstr_t batchuid = m_Batch->GetUID();
	*pVal = batchuid.copy();
	return S_OK;
}

STDMETHODIMP CBatch::get_Name(BSTR *pVal)
{
	_bstr_t name = m_Batch->GetName();
	*pVal = name.copy();
	return S_OK;
}

STDMETHODIMP CBatch::put_Name(BSTR newVal)
{
	_bstr_t name = newVal;
	m_Batch->SetName(name);
	return S_OK;
}

STDMETHODIMP CBatch::get_NameSpace(BSTR *pVal)
{
	_bstr_t nspace = m_Batch->GetNameSpace();
	*pVal = nspace.copy();
	return S_OK;
}

STDMETHODIMP CBatch::put_NameSpace(BSTR newVal)
{
	_bstr_t nspace = newVal;
	m_Batch->SetNameSpace(nspace);
	return S_OK;
}  

STDMETHODIMP CBatch::get_Status(BSTR *pVal)
{
	_bstr_t status = m_Batch->GetStatus();
	*pVal = status.copy();
	return S_OK;
}

STDMETHODIMP CBatch::get_CreationDate(DATE *pVal)
{
	time_t convDate = m_Batch->GetCreationDate();
	OleDateFromTimet(pVal, convDate);
	return S_OK;
}

STDMETHODIMP CBatch::get_CompletionDate(DATE *pVal)
{
	time_t convDate = m_Batch->GetCompletionDate();
	OleDateFromTimet(pVal, convDate);
	return S_OK;
}

STDMETHODIMP CBatch::get_Source(BSTR *pVal)
{
	_bstr_t source = m_Batch->GetSource();
	*pVal = source.copy();
	return S_OK;
}

STDMETHODIMP CBatch::put_Source(BSTR newVal)
{
	_bstr_t source = newVal;
	m_Batch->SetSource(source);
	return S_OK;
}  

STDMETHODIMP CBatch::get_SourceCreationDate(DATE *pVal)
{
	time_t convDate = m_Batch->GetSourceCreationDate();
	OleDateFromTimet(pVal, convDate);
	return S_OK;
}

STDMETHODIMP CBatch::put_SourceCreationDate(DATE newVal)
{
	time_t convertedTime;
	TimetFromOleDate(&convertedTime, newVal);
	m_Batch->SetSourceCreationDate(convertedTime);
	return S_OK;
}  

STDMETHODIMP CBatch::get_CompletedCount(long *pVal)
{
	*pVal = m_Batch->GetCompletedCount();
	return S_OK;
}

STDMETHODIMP CBatch::get_SequenceNumber(BSTR *pVal)
{
	_bstr_t sq = m_Batch->GetSequenceNumber();
	*pVal = sq.copy();
	return S_OK;
}

STDMETHODIMP CBatch::put_SequenceNumber(BSTR newVal)
{
	_bstr_t sn = newVal;
	m_Batch->SetSequenceNumber(sn);
	return S_OK;
}  

STDMETHODIMP CBatch::get_ExpectedCount(long *pVal)
{
	*pVal = m_Batch->GetExpectedCount();
	return S_OK;
}

STDMETHODIMP CBatch::put_ExpectedCount(long newVal)
{
	m_Batch->SetExpectedCount(newVal);
	return S_OK;
}

STDMETHODIMP CBatch::get_FailureCount(long *pVal)
{
	*pVal = m_Batch->GetFailureCount();
	return S_OK;
}

STDMETHODIMP CBatch::get_Comment(BSTR *pVal)
{
	_bstr_t comment = m_Batch->GetComment();
	*pVal = comment.copy();
	return S_OK;
}

STDMETHODIMP CBatch::put_Comment(BSTR newVal)
{	
	_bstr_t comment = newVal;
	m_Batch->SetComment(comment);
	return S_OK;
}  

STDMETHODIMP CBatch::get_MeteredCount(long *pVal)
{
	*pVal = m_Batch->GetMeteredCount();
	return S_OK;
}

STDMETHODIMP CBatch::put_MeteredCount(long newVal)
{
	m_Batch->SetMeteredCount(newVal);
	return S_OK;
}

STDMETHODIMP CBatch::MarkAsActive(BSTR Comment)
{
	m_Batch->SetComment(_bstr_t(Comment));
	if (!m_Batch->MarkAsActive())
		return ProcessExceptions();
	return S_OK;
}

STDMETHODIMP CBatch::MarkAsBackout(BSTR Comment)
{
	m_Batch->SetComment(_bstr_t(Comment));
	if (!m_Batch->MarkAsBackout())
		return ProcessExceptions();
	return S_OK;
}

STDMETHODIMP CBatch::MarkAsFailed(BSTR Comment)
{
	m_Batch->SetComment(_bstr_t(Comment));
	if (!m_Batch->MarkAsFailed())
		return ProcessExceptions();

	return S_OK;
}

STDMETHODIMP CBatch::MarkAsDismissed(BSTR Comment)
{
	m_Batch->SetComment(_bstr_t(Comment));
	if (!m_Batch->MarkAsDismissed())
		return ProcessExceptions();
	return S_OK;
}

STDMETHODIMP CBatch::MarkAsCompleted(BSTR Comment)
{
	m_Batch->SetComment(_bstr_t(Comment));
	if (!m_Batch->MarkAsCompleted())
		return ProcessExceptions();
	return S_OK;
}

STDMETHODIMP CBatch::UpdateMeteredCount()
{
	if (!m_Batch->UpdateMeteredCount())
		return ProcessExceptions();
	return S_OK;
}

STDMETHODIMP CBatch::CreateSessionSet(ISessionSet ** pNewSessionSet)
{
  HRESULT retval;
  ISessionSet * newCOMSessionSet = NULL;
  CComObject<CSessionSet> * newSessionSet;
  MTMeterSessionSet * sdk_sessionset;
  
  sdk_sessionset = m_Batch->CreateSessionSet();

  if (!sdk_sessionset)
    return E_FAIL;

  retval = CComObject<CSessionSet>::CreateInstance(&newSessionSet);

  if (FAILED(retval)) 
    return retval;

  newSessionSet->SetSDKSessionSet(sdk_sessionset);

  retval =  newSessionSet->QueryInterface(IID_ISessionSet, (void **)&newCOMSessionSet);

  if (!SUCCEEDED(retval)) 
    {
      Error("Could not get SessionSet interface");
      retval = E_NOINTERFACE;
    }

  *pNewSessionSet = newCOMSessionSet;
  
  // Here we will need to create a new ISessionSet object and return a pointer to it.
  return S_OK;
}

STDMETHODIMP CBatch::CreateSession(BSTR servicename, ISession ** pNewSession)
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
		newSDKSession = m_Batch->CreateSession((const char *) sn); // MTMeterSession
      
		// Make sure we could create the Session object.
		if (!newSDKSession)
		{
			return E_FAIL; //HandleMeterError();
		}
		// We don't need an else, but I will leave it here for clarity
		else
		{
			// Convert MTMeterSession into CSession
			com_session->SetSDKSession(newSDKSession);
			com_session->SetSessionName(servicename);
			*pNewSession = i_session; 
		}
	}
  else
	{
		// QueryInterface failed. Return retval.
		return retval;
	}
 
	return S_OK;
}


STDMETHODIMP CBatch::Refresh()
{
	m_Batch->Refresh(); 

	/*COMMeterLib::IBatchPtr thisPtr = this;

	thisPtr->PutName(m_Batch->GetName());
	thisPtr->PutNameSpace(m_Batch->GetNameSpace());
	thisPtr->PutSource(m_Batch->GetSource());
	thisPtr->PutSourceCreationDate(m_Batch->GetSourceCreationDate());
	thisPtr->PutSequenceNumber(m_Batch->GetSequenceNumber());
	thisPtr->PutExpectedCount(m_Batch->GetExpectedCount());
	thisPtr->PutComment(m_Batch->GetComment());
	thisPtr->PutMeteredCount(m_Batch->GetMeteredCount());*/

	return S_OK;
}  

STDMETHODIMP CBatch::Save()
{
	if (!m_Batch->Save())
		return ProcessExceptions();

	return S_OK;
}  

STDMETHODIMP CBatch::ProcessExceptions()
{
	HRESULT hr = E_FAIL;

	MTMeterError *err = m_Batch->GetLastErrorObject();

	if (err)
	{
  	// Create buffer to store error message in
  	TCHAR errorBuf[1024];
  	int errorBufSize = sizeof(errorBuf);

  	// Get Error Info from SDK
  	err->GetErrorMessageEx(errorBuf, errorBufSize);
  	if (wcslen(errorBuf) == 0)
    {
     	errorBufSize = sizeof(errorBuf);
     	err->GetErrorMessage(errorBuf, errorBufSize);
    }
	  
	 	Error(errorBuf, 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
	 	hr = HRESULT_FROM_WIN32(err->GetErrorCode());
	 	delete err;
	}

	return hr;
}
