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
 * Created by:	Boris Boruchovich
 *				Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/
#ifndef __MTSESSIONSERVERBASE_H_
#define __MTSESSIONSERVERBASE_H_

//----- Manadatory includes.
#include "resource.h"		     // main symbols
#include <sharedsess.h>

#if defined(SESSION_SERVER_BASE_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

//----- Forward declarations.
class CMTObjectOwnerBase;
class CMTSessionBase;
class CMTSessionSetBase;

//----- Class declaration.
class CMTSessionServerBase
{
	public:

		//----- Create instance of this class.
		DllExport static CMTSessionServerBase* CreateInstance()
		{
			CMTSessionServerBase* pTmp = new CMTSessionServerBase;
			pTmp->AddRef();
			return pTmp;
		}
		DllExport static CMTSessionServerBase* CreateInstance(long lServerHandle);

		//----- Increment Reference counter.
		DllExport long AddRef()
		{
			return ::InterlockedIncrement(&mRefCount);
		}

		//----- Release this object
		DllExport int Release()
		{
			ASSERT(mRefCount > 0);
			long count = ::InterlockedDecrement(&mRefCount);
			if (mRefCount == 0)
				delete this;
			return count;
		}

		//----- Use with caution.
		DllExport void SetSharedHeader(SharedSessionHeader* pHeader);

		//----- Use with caution.
		DllExport SharedSessionHeader*  GetSharedHeader();

	public:

		//----- Create a session set C++ wrapper object.
		DllExport CMTSessionSetBase* CreateSessionSet();

		//----- Create a sesson C++ wrapper object.
		DllExport CMTSessionBase* CreateSession(const unsigned char uid[],
                                            long serviceId);
		//-----
		DllExport CMTSessionBase* CreateChildSession(const unsigned char uid[],
                                                 long serviceId,
                                                 const unsigned char parentUid[16]);

		//-----
		DllExport CMTSessionBase* CreateTestSession(long serviceId);
		DllExport CMTSessionBase* CreateChildTestSession(long serviceId, long parentId);

		//-----
		DllExport CMTSessionBase* GetSession(long sessionId);
		DllExport CMTSessionSetBase* GetSessionSet(long setId);

		//-----
		DllExport void Init(BSTR filename, BSTR sharename, long totalSize);

		//-----
		DllExport CMTSessionSetBase* SessionsInProcessBy(int aStageID);

		//-----
		DllExport void DeleteSessionsInProcessBy(int aStageID);

		//----- Return a set of failed sessions.
		DllExport CMTSessionSetBase* FailedSessions();

		//-----
		DllExport CMTSessionBase* GetSessionWithUID(unsigned char uid[]);

		//-----
		DllExport double get_PercentUsed();

		//-----
		DllExport CMTObjectOwnerBase* GetObjectOwner(long ownerId);
		DllExport CMTObjectOwnerBase* CreateObjectOwner();
		DllExport void DeleteObjectOwner(long ownerId);

	private:

		//-----
		struct InProcessScanInfo
		{
			long mStageId;
			CMTSessionSetBase * mpList;
			enum Action
			{
				DELETE_SESSION,
				ADD_SESSION,
			} mAction;
		};

		//----- Callback methods.
		static BOOL InProcessScan(void* apArg, SharedSessionHeader* apHeader, SharedSession* apSession);
		static BOOL FailedScan(void* apArg, SharedSessionHeader* apHeader, SharedSession* apSession);

		//----- Do not allow Copy constructor
		CMTSessionServerBase(const CMTSessionServerBase& other)
        { /* Do nothing here */ }

		//----- Do not allow Assignment operator.
		void operator=(const CMTSessionServerBase& rSrc)
		{ /* Do nothing here */ }

	private:  // DATA

		SharedSessionMappedViewHandle* mpMappedView;
		static SharedSessionHeader* mpHeader;

	private:
		
		//----- Class constructor, use create instance instead.
		DllExport CMTSessionServerBase();

		//----- Destructor, use release method instead.
		DllExport ~CMTSessionServerBase();

		//----- Used for reference counting.
		long mRefCount;
};

#endif //__MTSESSIONSERVERBASE_H_

//-- EOF --
