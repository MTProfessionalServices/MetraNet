/**************************************************************************
 * @doc MTSESSION
 *
 * Copyright 1998 by MetraTech Corporation
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/
#include "StdAfx.h"
#include "SessServer.h"
#include "MTSessionDef.h"
#include "MTSessionServerDef.h"
#include "MTObjectOwnerDef.h"
#include "MTExceptionMacros.h"

#include <metra.h>
#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <MTSingleton.h>
#include <propids.h>
#include <MSIX.h>
#include <errobj.h>

/******************************************* error interface ***/
STDMETHODIMP CMTSessionServer::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSessionServer,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

//----- Construction/destruction.
CMTSessionServer::CMTSessionServer()
	:	mpSessionServerBase(NULL)
{
	/* Do nothing here */
}

HRESULT CMTSessionServer::FinalConstruct()
{
	ASSERT(!mpSessionServerBase);
	if (!mpSessionServerBase)
		mpSessionServerBase = CMTSessionServerBase::CreateInstance();
	return mpSessionServerBase ? S_OK : E_POINTER;
}

void CMTSessionServer::FinalRelease()
{
	ASSERT(mpSessionServerBase);
	if(mpSessionServerBase)
	{
		mpSessionServerBase->Release();
		mpSessionServerBase = NULL;
	}
}

// ----------------------------------------------------------------
// Description: Initialize the shared memory used to hold session state.
// Arguments: filename - name of memory mapped file to hold session state.
//            sharename - name of file mapping to use when accessing shared memory.
//            totalSize - total size (in bytes) of the shared memory file.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::Init(BSTR filename, BSTR sharename, long totalSize)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionServerBase->Init(filename, sharename, totalSize);
	MT_END_TRY_BLOCK(IID_IMTSessionServer);
}

// ----------------------------------------------------------------
// Description: Return the current percent used of the shared memory file.
//              Percent used is defined as the max percent full of all
//              the shared memory pools.
// Return Value: the current capacity of the pipeline
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::get_PercentUsed(/*[out, retval]*/ double * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpSessionServerBase->get_PercentUsed();
	MT_END_TRY_BLOCK(IID_IMTSessionServer);
}

// ----------------------------------------------------------------
// Description: depracated - use PercentUsed instead
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::get_CurrentCapacity(/*[out, retval]*/ double * pVal)
{
	return get_PercentUsed(pVal);
}

/******************************************* object creation ***/

// ----------------------------------------------------------------
// Description: Create a new session, given a Unique ID (UID) and service ID.
//              INTERNAL use only
// Arguments:   uid - UID of session (not encoded)
//              serviceID - service ID of session
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::CreateSession(unsigned char * uid,
											 long serviceId,
											 IMTSession * * session)
{
	return CreateChildSession(uid, serviceId, NULL, session);
}

// ----------------------------------------------------------------
// Description: Create a new session that links to an existing parent.
//              INTERNAL use only
// Arguments:   uid - UID of session (not encoded)
//              serviceID - service ID of session
//              parentUid - UID of parent session (not encoded)
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::CreateChildSession(unsigned char * uid,
												  long serviceId,
												  unsigned char * parentUid,
												  IMTSession * * session)
{
	if (!session)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionBase> pSessionBase(mpSessionServerBase->CreateChildSession(uid, serviceId, parentUid));
	if (!pSessionBase.get())
		return E_FAIL;

	//----- Create the new session COM object
	CComObject<CMTSession>* sessObj;
	HRESULT hr = CComObject<CMTSession>::CreateInstance(&sessObj);
	if (hr != S_OK || sessObj == NULL)
	{
		*session = NULL;
		return (sessObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Increase reference count for the pointer returned
	sessObj->AddRef();
	sessObj->SetSession(pSessionBase.release());
	*session = sessObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *session);
}

// ----------------------------------------------------------------
// Description: Create a "test" session that has no unique ID.
//              DO NOT USE.
// Arguments:   serviceID - service ID of the new session.
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::CreateTestSession(long serviceId,
												 IMTSession * * session)
{
	return CreateChildTestSession(serviceId, -1, session);
}

// ----------------------------------------------------------------
// Description: Create a "test" session that links to an existing parent.
//              DO NOT USE.
// Arguments:   serviceId - service ID of new session
//              aParent - session ID of parent session.
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::CreateChildTestSession(long serviceId, long aParent,
													  IMTSession * * session)
{
	if (!session)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionBase> pSessionBase(mpSessionServerBase->CreateChildTestSession(serviceId, aParent));
	if (!pSessionBase.get())
		return E_FAIL;

	//----- Create the new session COM object
	CComObject<CMTSession>* sessObj;
	HRESULT hr = CComObject<CMTSession>::CreateInstance(&sessObj);
	if (hr != S_OK)
	{
		*session = NULL;
		return (sessObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	hr = sessObj->QueryInterface(IID_IMTSession, (void**) session);
	if (FAILED(hr))
	{
		*session = NULL;
		sessObj->Release();
		return hr;
	}

	//----- Set the base object into the COM wrapper.
	sessObj->SetSession(pSessionBase.release());

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *session);
}

// ----------------------------------------------------------------
// Description: Return a session set, given the session set's ID.
// Return Value: a pointer to the new session set.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::CreateSessionSet(IMTSessionSet** apSet)
{
	if (!apSet)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionSetBase> pSessionSetBase(mpSessionServerBase->CreateSessionSet());
	if (!pSessionSetBase.get())
		return E_FAIL;

	//----- Create the new set COM object
	CComObject<CMTSessionSet>* setObj;
	HRESULT hr = CComObject<CMTSessionSet>::CreateInstance(&setObj);
	if (hr != S_OK)
	{
		//----- Must release the shared object
		*apSet = NULL;
		return (setObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Increase reference count for the pointer returned
	setObj->AddRef();
	setObj->SetSessionSet(pSessionSetBase.release());
	*apSet = setObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *apSet);
}

// ----------------------------------------------------------------
// Description: Create a new object owner.
// Return Value: a pointer to the object owner.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::CreateObjectOwner(IMTObjectOwner** objectOwner)
{
	if (!objectOwner)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	std::auto_ptr<CMTObjectOwnerBase> pObjectOwnerBase(mpSessionServerBase->CreateObjectOwner());
	if (!pObjectOwnerBase.get())
		return E_FAIL;

	CComObject<CMTObjectOwner> * ownerObj;
	HRESULT hr = CComObject<CMTObjectOwner>::CreateInstance(&ownerObj);
	if (FAILED(hr) || ownerObj == NULL)
	{
		*objectOwner = NULL;
		return hr;
	}

	//----- Set the object owner into the COM wrapper.
	ownerObj->AddRef();
	ownerObj->SetObjectOwner(pObjectOwnerBase.release());
	*objectOwner = ownerObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *objectOwner);
}

// ----------------------------------------------------------------
// Description: Delete an object owner.
// Return Value: a pointer to the object owner.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::DeleteObjectOwner(long aID)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionServerBase->DeleteObjectOwner(aID);
	MT_END_TRY_BLOCK(IID_IMTSessionServer);
}

/****************************************** object retrieval ***/

// ----------------------------------------------------------------
// Description: Return a given object owner, given the session ID.
// Arguments:   sessionId - ID of object owner to retrieve
// Return Value: a pointer to the object owner.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::GetObjectOwner(long ownerId,
											  IMTObjectOwner** objectOwner)
{
	if (!objectOwner)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTObjectOwnerBase> pObjectOwnerBase(mpSessionServerBase->GetObjectOwner(ownerId));
	if (!pObjectOwnerBase.get())
		return E_FAIL;

	//----- Create the new COM object
	CComObject<CMTObjectOwner>* ownerObj;
	HRESULT hr = CComObject<CMTObjectOwner>::CreateInstance(&ownerObj);
	if (FAILED(hr) || ownerObj == NULL)
	{
		*objectOwner = NULL;
		return hr;
	}

	//----- Increase reference count for the pointer returned
	ownerObj->AddRef();
	ownerObj->SetObjectOwner(pObjectOwnerBase.release());
	*objectOwner = ownerObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *objectOwner);
}

// ----------------------------------------------------------------
// Description: Return a given session, given the session ID.
// Arguments:   sessionId - ID of session to retrieve
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::GetSession(long sessionId,
										  IMTSession** session)
{
	if (!session)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionBase> pSessionBase(mpSessionServerBase->GetSession(sessionId));
	if (!pSessionBase.get())
		return E_FAIL;

	//----- Create the new session COM wrapper.
	CComObject<CMTSession> * sessObj;
	HRESULT hr = CComObject<CMTSession>::CreateInstance(&sessObj);
	if (FAILED(hr))
	{
		*session = NULL;
		return (sessObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Increase reference count for the pointer returned
	//----- Set the session object into COM wrapper.
	sessObj->AddRef();
	sessObj->SetSession(pSessionBase.release());
	*session = sessObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *session);
}

// ----------------------------------------------------------------
// Description: Return the session with the given Unique ID (UID).
// Arguments:   uid - unique ID of session to find.
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::GetSessionWithUID(unsigned char uid[],
												 IMTSession** session)
{
	if (!session)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionBase> pSessionBase(mpSessionServerBase->GetSessionWithUID(uid));
	if (!pSessionBase.get())
		return E_FAIL;

	//----- Create the new session COM wrapper.
	CComObject<CMTSession>* sessObj;
	HRESULT hr = CComObject<CMTSession>::CreateInstance(&sessObj);
	if (hr != S_OK)
	{
		*session = NULL;
		return (sessObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Increase reference count for the pointer returned
	//----- Set the session object into COM wrapper.
	sessObj->AddRef();
	sessObj->SetSession(pSessionBase.release());
	*session = sessObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *session);
}

// ----------------------------------------------------------------
// Description: Return a session set, given the session set's ID.
// Arguments:   setId - set ID to find.
// Return Value: a pointer to the set retrieved.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::GetSessionSet(long setId,
											 IMTSessionSet** apSet)
{
	if (!apSet)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionSetBase> pSessionSetBase(mpSessionServerBase->GetSessionSet(setId));
	if (!pSessionSetBase.get())
		return E_FAIL;

	CComObject<CMTSessionSet> * setObj;
	HRESULT hr = CComObject<CMTSessionSet>::CreateInstance(&setObj);
	if (hr != S_OK)
	{
		*apSet = NULL;
		return (setObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Set the session set object into COM wrapper.
	setObj->AddRef();
	setObj->SetSessionSet(pSessionSetBase.release());
	*apSet = setObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *apSet);
}

// ----------------------------------------------------------------
// Description: Return all session currently marked as ROLLEDBACK.
//              INTERNAL use only.
// Arguments:   apSet - session set to populate
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::FailedSessions(IMTSessionSet** apSet)
{
	if (!apSet)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionSetBase> pSessionSetBase(mpSessionServerBase->FailedSessions());
	if (!pSessionSetBase.get())
		return E_FAIL;

	CComObject<CMTSessionSet>* setObj;
	HRESULT hr = CComObject<CMTSessionSet>::CreateInstance(&setObj);
	if (hr != S_OK)
	{
		*apSet = NULL;
		return (setObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Set the session set object into COM wrapper.
	setObj->AddRef();
	setObj->SetSessionSet(pSessionSetBase.release());
	*apSet = setObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *apSet);
}

// ----------------------------------------------------------------
// Description: Return all sessions currently marked as IN_PROCESS by a given stage.
//              INTERNAL use only.
// Arguments:   apSet - session set to populate
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::SessionsInProcessBy(int aStageID, IMTSessionSet** apSet)
{
	if (!apSet)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTSessionSetBase> pSessionSetBase(mpSessionServerBase->SessionsInProcessBy(aStageID));
	if (!pSessionSetBase.get())
		return E_FAIL;

	CComObject<CMTSessionSet>* setObj;
	HRESULT hr = CComObject<CMTSessionSet>::CreateInstance(&setObj);
	if (hr != S_OK)
	{
		*apSet = NULL;
		return (setObj == NULL) ? PIPE_ERR_SHARED_OBJECT_FAILURE : hr;
	}

	//----- Set the session set object into COM wrapper.
	setObj->AddRef();
	setObj->SetSessionSet(pSessionSetBase.release());
	*apSet = setObj;

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionServer, *apSet);
}

// ----------------------------------------------------------------
// Description: Delete all sessions that are being processed by a given stage.
//              INTERNAL use only.
// Arguments:   aStageID - ID of stage for which session should be deleted.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionServer::DeleteSessionsInProcessBy(int aStageID)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionServerBase->DeleteSessionsInProcessBy(aStageID);
	MT_END_TRY_BLOCK(IID_IMTSessionServer);
}

STDMETHODIMP CMTSessionServer::GetInternalServerHandle(long * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = (long) mpSessionServerBase;
	return S_OK;
}

//-- EOF --
