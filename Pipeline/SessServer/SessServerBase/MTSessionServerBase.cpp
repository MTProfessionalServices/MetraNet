/**************************************************************************
 * @doc MTSESSIONSERVERBASE
 *
 * Copyright 1998-2004 by MetraTech Corporation
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
 * Created by:  Derek Young
 *				Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

#include "MTExceptionMacros.h"
#include "MTSessionBaseDef.h"
#include "MTSessionSetBaseDef.h"
#include "MTSessionServerBaseDef.h"
#include "MTObjectOwnerBaseDef.h"

#include <metra.h>
#include <mtcomerr.h>
#include <mtprogids.h>
#include <accessgrant.h>
#include <mtglobal_msg.h>
#include <MTSingleton.h>
#include <propids.h>
#include <MSIX.h>
#include <errobj.h>

#import "MTConfigLib.tlb"
#include "pipelineconfig.h"
#include "ConfigDir.h"

//----- Singleton SharedSessionMappedViewHandle.
class SharedSessionMappedViewHandleWithInit : public SharedSessionMappedViewHandle
{
	public:
		BOOL Init()
		{
			return TRUE;
		}
};

//-----
typedef MTSingleton<SharedSessionMappedViewHandleWithInit> SingletonSharedSessionMappedViewHandle;

//----- Static member initialization.
SharedSessionHeader * CMTSessionServerBase::mpHeader = NULL;

//----- Construction/destruction.
CMTSessionServerBase::CMTSessionServerBase()
	:	mRefCount(0)
{
	mpMappedView = SingletonSharedSessionMappedViewHandle::GetInstance();
}

CMTSessionServerBase::~CMTSessionServerBase()
{
	SingletonSharedSessionMappedViewHandle::ReleaseInstance();
}

//----- This is a static member function.
CMTSessionServerBase* CMTSessionServerBase::CreateInstance(long lServerHandle)
{
	CMTSessionServerBase* pTmp = (CMTSessionServerBase*) lServerHandle;
	if (!pTmp)
		throw MTException("Inavlid Session Server handle");

	//----- Initialize the header if we do not have one.
	if (!pTmp->mpHeader)
	{
    // Read the pipeline configuration file to get shared memory proportions
    std::string configDir;
    if (!GetMTConfigDir(configDir))
      throw MTException("Failed to initialize shared memory", PIPE_ERR_SHARED_MEM_INIT);
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    PipelineInfoReader pipelineReader;
    PipelineInfo pipelineInfo;
    if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
      throw MTException("Failed to initialize shared memory", PIPE_ERR_SHARED_MEM_INIT);
    
		//xxx TODO: Not sure if this is OK here.
		long spaceAvail = pTmp->mpMappedView->GetAvailableSpace() - sizeof(SharedSessionHeader);
		int sessPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionSession()) / 500);
		int propPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionProperty()) / 500);
		int setPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionSessionSet()) / 500);
		int nodePool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionNode()) / 500);
		int ownerPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionObjectOwner()) / 500);
		int stringPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionString()) / 500);
		pTmp->mpHeader = SharedSessionHeader::Initialize(*pTmp->mpMappedView,
													pTmp->mpMappedView->GetMemoryStart(),
													sessPool,	// session pool
													propPool,	// prop pool
													setPool,		// set pool
													nodePool,	// set node
													ownerPool,	// object owner pool
													stringPool, 	// string pool
													FALSE);
	}

	// TODO: report error
	if (!pTmp->mpHeader)
		throw MTException("Failed to initialize shared memory", PIPE_ERR_SHARED_MEM_INIT);


	//----- We're returning the object that was passed in, increment ref count on it. 
	pTmp->AddRef();
	return pTmp;
}

//----- Use with caution
void CMTSessionServerBase::SetSharedHeader(SharedSessionHeader* pHeader)
{
	if (!mpHeader)
		mpHeader = pHeader;
}

//----- Use with caution
SharedSessionHeader*  CMTSessionServerBase::GetSharedHeader()
{
  return mpHeader;
}

// ----------------------------------------------------------------
// Description: Initialize the shared memory used to hold session state.
// Arguments: filename - name of memory mapped file to hold session state.
//            sharename - name of file mapping to use when accessing shared memory.
//            totalSize - total size (in bytes) of the shared memory file.
// ----------------------------------------------------------------
void CMTSessionServerBase::Init(BSTR filename, BSTR sharename, long totalSize)
{
	//----- This assumes wer're not trying to change the size, filname, or
	//----- sharename
	if (mpMappedView->IsInitialized())
		return;

	//----- Prop IDs are needed by
	PipelinePropIDs::Init();

	_bstr_t filenameBstr(filename);
	_bstr_t sharenameBstr(sharename);

	DWORD err = mpMappedView->Open(filenameBstr, sharenameBstr, totalSize, FALSE);
	if (err != NO_ERROR)
  {
    // Format error message
    char msg[1024];
    char errText[2048];
    FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, NULL, err, 0, msg, sizeof(msg), NULL);
    sprintf(errText, "Failed to open mapped view: %s", msg);

    throw MTException(errText, HRESULT_FROM_WIN32(err));
  }

	//----- We've lost access to the mutex - get it back
	SharedAccess access(mpMappedView);
	if (!access())
		throw MTException("Shared access failed", HRESULT_FROM_WIN32(access.GetLastError()->GetCode()));

	long spaceAvail = mpMappedView->GetAvailableSpace() - sizeof(SharedSessionHeader);
	// TODO: figure out start of session header some other way?

  // Read the pipeline configuration file to get shared memory proportions
  std::string configDir;
  if (!GetMTConfigDir(configDir))
    throw MTException("Failed to initialize shared memory", PIPE_ERR_SHARED_MEM_INIT);
  MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
  PipelineInfoReader pipelineReader;
  PipelineInfo pipelineInfo;
  if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
    throw MTException("Failed to initialize shared memory", PIPE_ERR_SHARED_MEM_INIT);
    
  //xxx TODO: Not sure if this is OK here.
  int sessPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionSession()) / 500);
  int propPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionProperty()) / 500);
  int setPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionSessionSet()) / 500);
  int nodePool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionNode()) / 500);
  int ownerPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionObjectOwner()) / 500);
  int stringPool = (int) ((((__int64) spaceAvail) * pipelineInfo.GetProportionString()) / 500);
  mpHeader = SharedSessionHeader::Initialize(*mpMappedView,
                                             mpMappedView->GetMemoryStart(),
                                             sessPool,	// session pool
                                             propPool,	// prop pool
                                             setPool,		// set pool
                                             nodePool,	// set node
                                             ownerPool,	// object owner pool
                                             stringPool, 	// string pool
                                             FALSE);

	// TODO: report error
	if (!mpHeader)
		throw MTException("Failed to initialize shared memory", PIPE_ERR_SHARED_MEM_INIT);
}

// ----------------------------------------------------------------
// Description: Return the current percent used of the shared memory file.
//              Percent used is defined as the max percent full of all
//              the shared memory pools.
// Return Value: the current capacity of the pipeline
// ----------------------------------------------------------------
double CMTSessionServerBase::get_PercentUsed()
{
	MT_LOCK_ACCESS()

	//----- Return the percentage filled of the most filled pool
	double mostFilled = 0;
	FixedSizePoolStats stats;

	// session pool
	mpHeader->GetSessionPoolStats(stats);
	double cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// property pool
	mpHeader->GetPropPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// set pool
	mpHeader->GetSetPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// set node pool
	mpHeader->GetSetNodePoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// object owner pool
	mpHeader->GetObjectOwnerPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// small string pool
	mpHeader->GetSmallStringPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// medium string pool
	mpHeader->GetMediumStringPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// large string pool
	mpHeader->GetLargeStringPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	return mostFilled;
}

// ----------------------------------------------------------------
// Description: Create a new session, given a Unique ID (UID) and service ID.
//              INTERNAL use only
// Arguments:   uid - UID of session (not encoded)
//              serviceID - service ID of session
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
CMTSessionBase* CMTSessionServerBase::CreateSession(const unsigned char * uid, long serviceId)
{
	return CreateChildSession(uid, serviceId, NULL);
}

// ----------------------------------------------------------------
// Description: Create a new session that links to an existing parent.
//              INTERNAL use only
// Arguments:   uid - UID of session (not encoded)
//              serviceID - service ID of session
//              parentUid - UID of parent session (not encoded)
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
CMTSessionBase* CMTSessionServerBase::CreateChildSession(const unsigned char * uid,
																												 long serviceId,
																												 const unsigned char * parentUid)
{
	//----- Uninitialized
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	//----- Session is created with a reference count of 1
	long id; // not used
	SharedSession * sess = SharedSession::Create(mpHeader, id, uid, parentUid);
	if (!sess)
	{		
		// this call can fail for only two reasons - out of shared memory or
		// duplicate session.  look for a dup if it fails.
		long dupID;
		SharedSession * duplicate = SharedSession::FindWithUID(mpHeader, dupID, uid);
		if (duplicate && dupID != -1)
		{
			//----- Object already exists
			throw MTException("Duplicate session object", PIPE_ERR_DUPLICATE_SESSION);
		}

		throw MTException("Out of shared memory", PIPE_ERR_SHARED_OBJECT_FAILURE);
	}

	ASSERT(sess->UIDEquals(uid));

	//----- Create() above set the parent ID
	sess->SetServiceID(serviceId);

	//----- Create the new session C++ wrapper object.
	std::auto_ptr<CMTSessionBase> pSessionBase(new CMTSessionBase);
	if (!pSessionBase.get())
	{
		sess->Release(mpHeader);
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);
	}

	// the shared object was created with a reference count of 1.
	// SetSharedInfo does an AddRef on the session object.
	// therefore, after SetSharedInfo, we have to do a release
	// on the shared object or the ref count will be one too high.
	pSessionBase->SetSharedInfo(mpMappedView, mpHeader, sess);

	int newCount = sess->Release(mpHeader);		// release our extra reference
	return pSessionBase.release();
}

// ----------------------------------------------------------------
// Description: Create a "test" session that has no unique ID.
//              DO NOT USE.
// Arguments:   serviceID - service ID of the new session.
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
CMTSessionBase* CMTSessionServerBase::CreateTestSession(long serviceId)
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
CMTSessionBase* CMTSessionServerBase::CreateChildTestSession(long serviceId, long aParent)
{
	//----- Uninitialized?
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	// session is created with a reference count of 1
	// the UID is passed in as NULL.  Any number of sessions can have NULL
	// as the real ID, but they can't be found by UID anymore.
	// TODO: parent session not used
	long id; // not used
	SharedSession * sess = SharedSession::Create(mpHeader, id, NULL, aParent);
	if (!sess)
		throw MTException("Cannot create shared session", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Create() above set the parent ID
	sess->SetServiceID(serviceId);

	//----- Create the new session COM object
	std::auto_ptr<CMTSessionBase> pSessionBase(new CMTSessionBase);
	if (!pSessionBase.get())
	{
		sess->Release(mpHeader);
		
		//----- Only reason it wouldn't have been created
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);
	}

	// the shared object was created with a reference count of 1.
	// SetSharedInfo does an AddRef on the session object.
	// therefore, after SetSharedInfo, we have to do a release
	// on the shared object or the ref count will be one too high.
	pSessionBase->SetSharedInfo(mpMappedView, mpHeader, sess);

	//----- Release our extra reference
	sess->Release(mpHeader);
	return pSessionBase.release();
}

// ----------------------------------------------------------------
// Description: Return a session set, given the session set's ID.
// Return Value: a pointer to the new session set.
// ----------------------------------------------------------------
CMTSessionSetBase* CMTSessionServerBase::CreateSessionSet()
{
	//----- Uninitialized?
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	//----- Set is created with a reference count of 1, so we don't need to addref it
	long ref;
	SharedSet * set = SharedSet::Create(mpHeader, ref);
	if (!set)
		throw MTException("Cannot create shared set", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Create the new set COM object
	std::auto_ptr<CMTSessionSetBase> pSetBase(new CMTSessionSetBase);
	if (!pSetBase.get())
	{
		set->Release(mpHeader);
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);
	}

	//-----
	// NOTE: SetSharedInfo will addref the set,
	// so we have to do a release or the set's refcount will be one too many.
	// the set is initially created with a ref count of 1
	//-----
	pSetBase->SetSharedInfo(mpMappedView, mpHeader, set);

	//----- Release our reference now that setObj has one
	set->Release(mpHeader);

	//----- Set server object.
	pSetBase->SetServer(this);

	//----- Generate and set uid.
	string strUid;
	MSIXUidGenerator::Generate(strUid);
	unsigned char uid[16];
	MSIXUidGenerator::Decode(uid, strUid);

	pSetBase->SetUID(uid);
	return pSetBase.release();
}

// ----------------------------------------------------------------
// Description: Create a new object owner.
// Return Value: a pointer to the object owner.
// ----------------------------------------------------------------
CMTObjectOwnerBase* CMTSessionServerBase::CreateObjectOwner()
{
	//----- Uninitialized?
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	SharedObjectOwner * owner = SharedObjectOwner::Create(mpHeader);
	if (!owner)
		throw MTException("Unable to create shared owner object", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Create the new COM object
	std::auto_ptr<CMTObjectOwnerBase> ownerBase(new CMTObjectOwnerBase);
	if (!ownerBase.get())
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);

	// the shared object was created with a reference count of 1.
	// SetSharedInfo does an AddRef on the session object.
	// therefore, after SetSharedInfo, we have to do a release
	// on the shared object or the ref count will be one too high.
	ownerBase->SetSharedInfo(mpHeader, owner);

	//----- Release our extra reference
	owner->Release(mpHeader);
	return ownerBase.release();
}

// ----------------------------------------------------------------
// Description: Delete an object owner.
// Return Value: a pointer to the object owner.
// ----------------------------------------------------------------
void CMTSessionServerBase::DeleteObjectOwner(long aID)
{
	//----- Uninitialized?
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	mpHeader->DeleteObjectOwner(aID);
}

/****************************************** object retrieval ***/

// ----------------------------------------------------------------
// Description: Return a given object owner, given the session ID.
// Arguments:   sessionId - ID of object owner to retrieve
// Return Value: a pointer to the object owner.
// ----------------------------------------------------------------
CMTObjectOwnerBase* CMTSessionServerBase::GetObjectOwner(long ownerId)
{
	//----- Uninitialized?
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	SharedObjectOwner * owner = mpHeader->GetObjectOwner(ownerId);
	if (!owner)
		throw MTException("Unable to get shared owner object", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Create the new COM object
	std::auto_ptr<CMTObjectOwnerBase> ownerBase(new CMTObjectOwnerBase);
	if (!ownerBase.get())
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set shared info into object.
	ownerBase->SetSharedInfo(mpHeader, owner);
	return ownerBase.release();
}

// ----------------------------------------------------------------
// Description: Return a given session, given the session ID.
// Arguments:   sessionId - ID of session to retrieve
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
CMTSessionBase* CMTSessionServerBase::GetSession(long sessionId)
{
	//----- Uninitialized?
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	//----- Get a pointer to the session.  we still need to addref on it
	SharedSession * sess = mpHeader->GetSession(sessionId);
	if (!sess)
		throw MTException("Unable to get shared session", PIPE_ERR_INVALID_SESSION);

	//----- If this is a free slot, the session ID isn't valid
	if (sess->GetSessionInfo() == SharedSession::FREE_SESSION)
		throw MTException("Invalid session", PIPE_ERR_INVALID_SESSION);

	//----- Create the new session COM object
	std::auto_ptr<CMTSessionBase> sessBase(new CMTSessionBase);
	if (!sessBase.get())
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//-----
	sessBase->SetSharedInfo(mpMappedView, mpHeader, sess);
	return sessBase.release();
}

// ----------------------------------------------------------------
// Description: Return the session with the given Unique ID (UID).
// Arguments:   uid - unique ID of session to find.
// Return Value: a pointer to the new session.
// ----------------------------------------------------------------
CMTSessionBase* CMTSessionServerBase::GetSessionWithUID(unsigned char uid[])
{
	//----- Uninitialized
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	//----- Get a pointer to the session.  we still need to addref on it
	SharedSession * sess = NULL;
	mpHeader->FindSession(uid, &sess);
	if (!sess)
		throw MTException("Invalid session ID", PIPE_ERR_INVALID_SESSION);

	//----- If this is a free slot, the session ID isn't valid
	if (sess->GetSessionInfo() == SharedSession::FREE_SESSION)
		throw MTException("Invalid session ID", PIPE_ERR_INVALID_SESSION);

	//---- Create the new session COM object
	std::auto_ptr<CMTSessionBase> pSessionBase(new CMTSessionBase);
	if (!pSessionBase.get())
		//----- Out of memory 
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- Set shared memory information and return.
	pSessionBase->SetSharedInfo(mpMappedView, mpHeader, sess);
	return pSessionBase.release();
}

// ----------------------------------------------------------------
// Description: Return a session set, given the session set's ID.
// Arguments:   setId - set ID to find.
// Return Value: a pointer to the set retrieved.
// ----------------------------------------------------------------
CMTSessionSetBase* CMTSessionServerBase::GetSessionSet(long setId)
{
	//----- Uninitialized
	if (!mpHeader)
		throw MTException("mpHeader not initialized");

	MT_LOCK_ACCESS()

	// TODO: don't know if this set is valid or not
	SharedSet * set = mpHeader->GetSet(setId);
	if (!set)
		throw MTException("Unable to get shared set object", PIPE_ERR_SHARED_OBJECT_FAILURE);

	std::auto_ptr<CMTSessionSetBase> pSetBase(new CMTSessionSetBase);
	if (!pSetBase.get())
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- SetSharedInfo will addref the set, so we don't have to do it here
	pSetBase->SetSharedInfo(mpMappedView, mpHeader, set);
	pSetBase->SetServer(this);
	return pSetBase.release();
}

// ----------------------------------------------------------------
// Description: Return all session currently marked as ROLLEDBACK.
//              INTERNAL use only.
// Arguments:   apSet - session set to populate
// ----------------------------------------------------------------
CMTSessionSetBase* CMTSessionServerBase::FailedSessions()
{
	MT_LOCK_ACCESS()

	CMTSessionSetBase* pSetBase = CreateSessionSet();
	mpHeader->AllSessions(FailedScan, pSetBase);
	return pSetBase;
}

// ----------------------------------------------------------------
// Description: Return all sessions currently marked as IN_PROCESS by a given stage.
//              INTERNAL use only.
// Arguments:   apSet - session set to populate
// ----------------------------------------------------------------
CMTSessionSetBase* CMTSessionServerBase::SessionsInProcessBy(int aStageID)
{
	MT_LOCK_ACCESS()

	CMTSessionSetBase* pSetBase = CreateSessionSet();
	InProcessScanInfo info;
	info.mStageId = aStageID;
	info.mpList = pSetBase;
	info.mAction = InProcessScanInfo::ADD_SESSION;
	mpHeader->AllSessions(InProcessScan, &info);
	return pSetBase;
}

// ----------------------------------------------------------------
// Description: Delete all sessions that are being processed by a given stage.
//              INTERNAL use only.
// Arguments:   aStageID - ID of stage for which session should be deleted.
// ----------------------------------------------------------------
void CMTSessionServerBase::DeleteSessionsInProcessBy(int aStageID)
{
	MT_LOCK_ACCESS()
	InProcessScanInfo info;
	info.mStageId = aStageID;
	info.mpList = NULL;
	info.mAction = InProcessScanInfo::DELETE_SESSION;
	mpHeader->AllSessions(InProcessScan, &info);
}

BOOL CMTSessionServerBase::InProcessScan(void * apArg,
										 SharedSessionHeader * apHeader,
										 SharedSession * apSession)
{
	InProcessScanInfo * info = (InProcessScanInfo *) apArg;

	long stageId = info->mStageId;

	SharedSession::SessionState state = apSession->GetCurrentState();
	int owner = apSession->GetCurrentOwnerStage();
	if (state == SharedSession::PROCESSING && owner == stageId)
	{
		if (info->mAction == InProcessScanInfo::ADD_SESSION)
		{
			//----- Add the session to the set
			long id = apSession->GetSessionID(apHeader);
			long svcId = apSession->GetServiceID();
			try
			{
				info->mpList->AddSession(id, svcId);
			}
			catch(MTException Err)
			{
				ASSERT(0);
				// TODO: recover from this error
				return FALSE;
			}
		}
		else
		{
			//----- Delete the session
			apSession->DeleteForcefully(apHeader);

			//----- Reference would be invalid otherwise.
			apSession = NULL;
		}
	}

	// keep scanning
 	return TRUE;
}

BOOL CMTSessionServerBase::FailedScan(void * apArg, SharedSessionHeader * apHeader,
									  SharedSession * apSession)
{
	CMTSessionSetBase * set = (CMTSessionSetBase *) apArg;

	SharedSession::SessionState state = apSession->GetCurrentState();
	if (state == SharedSession::ROLLEDBACK)
	{
		long id = apSession->GetSessionID(apHeader);
		long svcId = apSession->GetServiceID();
			try
			{
				set->AddSession(id, svcId);
			}
			catch(MTException Err)
			{
				ASSERT(0);
				// TODO: recover from this error
				return FALSE;
			}
	}

	// keep scanning
 	return TRUE;
}

//-- EOF --
