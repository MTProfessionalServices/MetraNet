// AuditEvent.cpp : Implementation of CAuditEvent
#include "StdAfx.h"
#include "MTAuditEvents.h"
#include "AuditEvent.h"

/////////////////////////////////////////////////////////////////////////////
// CAuditEvent

HRESULT CAuditEvent::FinalConstruct()
{
	mSuccess = VARIANT_TRUE;

	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


STDMETHODIMP CAuditEvent::get_UserId(long *pVal)
{
	*pVal = mUserId; 

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_UserId(long newVal)
{
	mUserId = newVal;

	return S_OK;
}


STDMETHODIMP CAuditEvent::get_EventId(long *pVal)
{
	*pVal = mEventId;

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_EventId(long newVal)
{
	mEventId = newVal;

	return S_OK;
}

STDMETHODIMP CAuditEvent::get_EntityTypeId(long *pVal)
{
	*pVal = mEntityTypeId;

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_EntityTypeId(long newVal)
{
	mEntityTypeId = newVal;
	
	return S_OK;
}

STDMETHODIMP CAuditEvent::get_EntityId(long *pVal)
{
	*pVal = mEntityId;

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_EntityId(long newVal)
{
	mEntityId = newVal;

	return S_OK;
}

STDMETHODIMP CAuditEvent::get_Details(BSTR *pVal)
{
	*pVal = mDetails.copy();

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_Details(BSTR newVal)
{
	_bstr_t anewVal(newVal);
	if (anewVal.length() >= 2000) //length does not include the terminating char
	{
		char tmpstr[2000];
		strncpy(tmpstr, (const char*)anewVal, size_t(1999));
		tmpstr[1999] = '\0';
		mDetails = tmpstr;
	}
	else
		mDetails=newVal;

	return S_OK;
}

STDMETHODIMP CAuditEvent::get_LoggedInAs(BSTR *pVal)
{
	*pVal = mLoggedInAs.copy();

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_LoggedInAs(BSTR newVal)
{
	mLoggedInAs = newVal;

	return S_OK;
}

STDMETHODIMP CAuditEvent::get_ApplicationName(BSTR *pVal)
{
	*pVal = mApplicationName.copy();

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_ApplicationName(BSTR newVal)
{
	mApplicationName = newVal;

	return S_OK;
}


STDMETHODIMP CAuditEvent::get_Success(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mSuccess;
	return S_OK;
}

STDMETHODIMP CAuditEvent::put_Success(/*[in]*/ VARIANT_BOOL newVal)
{
	mSuccess = newVal;
	return S_OK;
}

//Audit Id is the internal database id for the audit event after it is written to the database
STDMETHODIMP CAuditEvent::get_AuditId(long *pVal)
{
	*pVal = mAuditId; 

	return S_OK;
}

STDMETHODIMP CAuditEvent::put_AuditId(long newVal)
{
	mAuditId = newVal;

	return S_OK;
}
