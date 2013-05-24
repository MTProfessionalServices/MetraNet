/**************************************************************************
* MCSESSIONSERVER
*
* Copyright 2004 by MetraTech Corp.
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
* Created by: Boris Boruchovich
*
* $Date$
* $Author$
* $Revision$
***************************************************************************/

#include "StdAfx.h"
#include "MCSessServer.h"

//----- String helper functions.
const wchar_t* MTGetUnmanagedString(System::String^ s)
{
	const wchar_t* lstr = 0;
	try
	{
		lstr = static_cast<const wchar_t*>(const_cast<void*>(static_cast<const void*>(System::Runtime::InteropServices::Marshal::StringToHGlobalAuto(s))));
	}
	catch(System::ArgumentException^ e)
	{
		// handle the exception
		e;
	}
	catch (System::OutOfMemoryException^ e)
	{
		// handle the exception
		e;
	}
	return lstr;
}

System::Object^ VariantToObject(const VARIANT & v)
{
	using System::Runtime::InteropServices::Marshal;
	return Marshal::GetObjectForNativeVariant(System::IntPtr((void*)&v));
}

//----- Managed Session Server namespace.
namespace MetraTech
{
	namespace Pipeline
	{
		//----- Construction/destruction.
		SessionServer::SessionServer()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSessionServer = CMTSessionServerBase::CreateInstance();
			END_TRY_UNMANAGED_BLOCK()
		}
		SessionServer::SessionServer(MetraTech::Interop::PipelineControl::IMTSessionServer^ pSessionServer)
		{
			ASSERT(pSessionServer);
			BEGIN_TRY_UNMANAGED_BLOCK()

			mpUnmanagedSessionServer = CMTSessionServerBase::CreateInstance(pSessionServer->GetInternalServerHandle());
			END_TRY_UNMANAGED_BLOCK()
		}
		SessionServer::~SessionServer()
		{
			if (mpUnmanagedSessionServer)
			{
				BEGIN_TRY_UNMANAGED_BLOCK()
				mpUnmanagedSessionServer->Release();
				mpUnmanagedSessionServer = nullptr;
				END_TRY_UNMANAGED_BLOCK()
			}
		}

		// ----------------------------------------------------------------
		// Description: Initialize the shared memory used to hold session state.
		// Arguments: filename - name of memory mapped file to hold session state.
		//            sharename - name of file mapping to use when accessing shared memory.
		//            totalSize - total size (in bytes) of the shared memory file.
		// ----------------------------------------------------------------
		void SessionServer::Init(String^ filename, String^ sharename, int totalSize)
		{
			const wchar_t* pszFilename = MTGetUnmanagedString(filename);
			const wchar_t* pszSharename = MTGetUnmanagedString(sharename);
			_bstr_t bstrFilename(pszFilename);
			_bstr_t bstrSharename(pszSharename);
			
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSessionServer->Init(bstrFilename, bstrSharename, totalSize);
			END_TRY_UNMANAGED_BLOCK()

			Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszFilename))));
			pszFilename = 0;
			Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszSharename))));
			pszSharename = 0;
		}

		/******************************************* object creation ***/

		// ----------------------------------------------------------------
		// Description: Create a new session, given a Unique ID (UID) and service ID.
		//              INTERNAL use only
		// Arguments:   uid - UID of session (not encoded)
		//              serviceID - service ID of session
		// Return Value: a pointer to the new session.
		// ----------------------------------------------------------------
		ISession^ SessionServer::CreateSession(cli::array<byte>^ uid, int serviceId)
		{
			pin_ptr<Byte> umUid = &uid[0];

			BEGIN_TRY_UNMANAGED_BLOCK()
			return Session::Create(mpUnmanagedSessionServer->CreateSession(umUid, serviceId));
			END_TRY_UNMANAGED_BLOCK()
		}

		// ----------------------------------------------------------------
		// Description: Create a new session that links to an existing parent.
		//              INTERNAL use only
		// Arguments:   uid - UID of session (not encoded)
		//              serviceID - service ID of session
		//              parentUid - UID of parent session (not encoded)
		// Return Value: a pointer to the new session.
		// ----------------------------------------------------------------
		ISession^ SessionServer::CreateChildSession(cli::array<byte>^ uid, int serviceId, cli::array<byte>^ parentUid)
		{
			pin_ptr<Byte> umUid = &uid[0];
			pin_ptr<Byte> umParentUid = &parentUid[0];

			CMTSessionBase* pSessionBase = nullptr;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pSessionBase = mpUnmanagedSessionServer->CreateChildSession(umUid, serviceId, umParentUid);
			END_TRY_UNMANAGED_BLOCK()
			if (!pSessionBase)
				return nullptr;

			//----- Create managed Session object
			return Session::Create(pSessionBase);
		}

		// ----------------------------------------------------------------
		// Description: Create a "test" session that has no unique ID.
		//              DO NOT USE.
		// Arguments:   serviceID - service ID of the new session.
		// Return Value: a pointer to the new session.
		// ----------------------------------------------------------------
		ISession^ SessionServer::CreateTestSession(int serviceId)
		{
			return CreateChildTestSession(serviceId, -1);
		}

		// ----------------------------------------------------------------
		// Description: Create a "test" session that links to an existing parent.
		//              DO NOT USE.
		// Arguments:   serviceId - service ID of new session
		//              aParent - session ID of parent session.
		// Return Value: a pointer to the new session.
		// ----------------------------------------------------------------
		ISession^ SessionServer::CreateChildTestSession(int serviceId, int aParent)
		{
			CMTSessionBase* pSessionBase;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pSessionBase = mpUnmanagedSessionServer->CreateChildTestSession(serviceId, aParent);
			END_TRY_UNMANAGED_BLOCK()
			if (!pSessionBase)
				return nullptr;

			//----- Create managed Session object
			return Session::Create(pSessionBase);
		}

		// ----------------------------------------------------------------
		// Description: Return a session set, given the session set's ID.
		// Return Value: a pointer to the new session set.
		// ----------------------------------------------------------------
		ISessionSet^ SessionServer::CreateSessionSet()
		{
			CMTSessionSetBase* pUnmanagedSessionSet;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pUnmanagedSessionSet = mpUnmanagedSessionServer->CreateSessionSet();
			END_TRY_UNMANAGED_BLOCK()
			if (!pUnmanagedSessionSet)
				return nullptr;

			return SessionSet::Create(pUnmanagedSessionSet);
		}

		// ----------------------------------------------------------------
		// Description: Create a new object owner.
		// Return Value: a pointer to the object owner.
		// ----------------------------------------------------------------
		IObjectOwner^ SessionServer::CreateObjectOwner()
		{
			CMTObjectOwnerBase* pUnmanagedObjectOwner;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pUnmanagedObjectOwner = mpUnmanagedSessionServer->CreateObjectOwner();
			END_TRY_UNMANAGED_BLOCK()
			if (!pUnmanagedObjectOwner)
				return nullptr;

			return ObjectOwner::Create(pUnmanagedObjectOwner);
		}

		// ----------------------------------------------------------------
		// Description: Delete an object owner.
		// Return Value: a pointer to the object owner.
		// ----------------------------------------------------------------
		void SessionServer::DeleteObjectOwner(int aID)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSessionServer->DeleteObjectOwner(aID);
			END_TRY_UNMANAGED_BLOCK()
		}

		// ----------------------------------------------------------------
		// Description: Return a given object owner, given the session ID.
		// Arguments:   sessionId - ID of object owner to retrieve
		// Return Value: a pointer to the object owner.
		// ----------------------------------------------------------------
		IObjectOwner^ SessionServer::GetObjectOwner(int ownerId)
		{
			CMTObjectOwnerBase* pUnmanagedObjectOwner;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pUnmanagedObjectOwner = mpUnmanagedSessionServer->GetObjectOwner(ownerId);
			END_TRY_UNMANAGED_BLOCK()
			if (!pUnmanagedObjectOwner)
				return nullptr;

			return ObjectOwner::Create(pUnmanagedObjectOwner);
		}

		// ----------------------------------------------------------------
		// Description: Return a given session, given the session ID.
		// Arguments:   sessionId - ID of session to retrieve
		// Return Value: a pointer to the new session.
		// ----------------------------------------------------------------
		ISession^ SessionServer::GetSession(int sessionId)
		{
			CMTSessionBase* pSessionBase;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pSessionBase = mpUnmanagedSessionServer->GetSession(sessionId);
			END_TRY_UNMANAGED_BLOCK()
			if (!pSessionBase)
				return nullptr;

			//----- Create managed Session object
			return Session::Create(pSessionBase);
		}

		// ----------------------------------------------------------------
		// Description: Return the session with the given Unique ID (UID).
		// Arguments:   uid - unique ID of session to find.
		// Return Value: a pointer to the new session.
		// ----------------------------------------------------------------
		ISession^ SessionServer::GetSession(cli::array<byte>^ uid)
		{
			pin_ptr<Byte> umUid = &uid[0];
			CMTSessionBase* pSessionBase;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pSessionBase = mpUnmanagedSessionServer->GetSessionWithUID(umUid);
			END_TRY_UNMANAGED_BLOCK()
			if (!pSessionBase)
				return nullptr;

			//----- Create managed Session Set object
			return Session::Create(pSessionBase);
		}

		// ----------------------------------------------------------------
		// Description: Return a session set, given the session set's ID.
		// Arguments:   setId - set ID to find.
		// Return Value: a pointer to the set retrieved.
		// ----------------------------------------------------------------
		ISessionSet^ SessionServer::GetSessionSet(int setId)
		{
			CMTSessionSetBase* pSessionSetBase;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pSessionSetBase = mpUnmanagedSessionServer->GetSessionSet(setId);
			END_TRY_UNMANAGED_BLOCK()
			if (!pSessionSetBase)
				return nullptr;

			//----- Create managed Session Set object
			return SessionSet::Create(pSessionSetBase);
		}

		// ----------------------------------------------------------------
		// Description: Return all session currently marked as ROLLEDBACK.
		//              INTERNAL use only.
		// Arguments:   apSet - session set to populate
		// ----------------------------------------------------------------
		ISessionSet^ SessionServer::FailedSessions()
		{
			CMTSessionSetBase* pSessionSetBase;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pSessionSetBase = mpUnmanagedSessionServer->FailedSessions();
			END_TRY_UNMANAGED_BLOCK()
			if (!pSessionSetBase)
				return nullptr;

			//----- Create managed Session Set object
			return SessionSet::Create(pSessionSetBase);
		}

		// ----------------------------------------------------------------
		// Description: Return all sessions currently marked as IN_PROCESS by a given stage.
		//              INTERNAL use only.
		// Arguments:   apSet - session set to populate
		// ----------------------------------------------------------------
		ISessionSet^ SessionServer::SessionsInProcessBy(int aStageID)
		{
			CMTSessionSetBase* pSessionSetBase;
			BEGIN_TRY_UNMANAGED_BLOCK()
			pSessionSetBase = mpUnmanagedSessionServer->SessionsInProcessBy(aStageID);
			END_TRY_UNMANAGED_BLOCK()
			if (!pSessionSetBase)
				return nullptr;

			//----- Create managed Session Set object
			return SessionSet::Create(pSessionSetBase);
		}

		// ----------------------------------------------------------------
		// Description: Delete all sessions that are being processed by a given stage.
		//              INTERNAL use only.
		// Arguments:   aStageID - ID of stage for which session should be deleted.
		// ----------------------------------------------------------------
		void SessionServer::DeleteSessionsInProcessBy(int aStageID)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSessionServer->DeleteSessionsInProcessBy(aStageID);
			END_TRY_UNMANAGED_BLOCK()
		}
	};
};

//-- EOF --