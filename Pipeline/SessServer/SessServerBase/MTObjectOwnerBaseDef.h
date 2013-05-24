/**************************************************************************
 * @doc MTOBJECTOWNERBASE
 *
 * @module |
 *
 * Copyright 2004 by MetraTech Corporation
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
 *
 * @index | MTOBJECTOWNERBASE
 ***************************************************************************/

#ifndef _MTOBJECTOWNERBASE_H
#define _MTOBJECTOWNERBASE_H

//----- System headers
#include <string>

//-----
#import <MTPipelineLib.tlb> rename("EOF", "RowsetEOF")
#import <MTPipelineLibExt.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#if defined(SESSION_SERVER_BASE_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

//----- Forward declarations.
class SharedObjectOwner;
class SharedSessionHeader;

//----- CMTObjectOwnerBase class declaration.
class CMTObjectOwnerBase
{
	public:

		//------ Constructor/destructor pair.
		DllExport CMTObjectOwnerBase();
		DllExport ~CMTObjectOwnerBase();

	public:
		DllExport long get_ID();

		DllExport long get_TotalCount();

		DllExport long get_StageID();
		DllExport long get_SessionSetID();

		DllExport bool get_NotifyStage();
		DllExport bool get_CompleteProcessing();
		DllExport bool get_SendFeedback();

		DllExport long get_WaitingCount();

		DllExport bool get_IsComplete();
		
		DllExport bool DecrementWaitingCount();

		DllExport void InitForNotifyStage(int aTotalCount, int aOwnerStage);
		DllExport void InitForSendFeedback(int aTotalCount, int aSessionSetID);
		DllExport void InitForCompleteProcessing(int aTotalCount, int aSessionSetID);

		DllExport void FlagError();
		DllExport bool get_ErrorFlag();

		DllExport long get_NextObjectOwnerID();
		DllExport void put_NextObjectOwnerID(long val);

		DllExport long IncreaseSharedRefCount();
		DllExport long DecreaseSharedRefCount();

		DllExport MTPipelineLib::IMTTransaction* get_Transaction();
		DllExport void put_Transaction(MTPipelineLib::IMTTransaction* pTrx);

		DllExport const char* get_TransactionID();
		DllExport void put_TransactionID(const char* pszVal);

		DllExport const wchar_t* get_SerializedSessionContext();
		DllExport void put_SerializedSessionContext(const wchar_t* pszVal);

		DllExport const char* get_SessionContextUserName();
		DllExport void put_SessionContextUserName(const char* pszVal);

		DllExport const char* get_SessionContextPassword();
		DllExport void put_SessionContextPassword(const char* pszVal);

		DllExport const char* get_SessionContextNamespace();
		DllExport void put_SessionContextNamespace(const char* pszVal);

		DllExport MTPipelineLibExt::IMTSessionContext* get_SessionContext();
		DllExport void put_SessionContext(MTPipelineLibExt::IMTSessionContext* pCtx);

		DllExport IUnknown* get_RSIDCache();
		DllExport void put_RSIDCache(/*[in]*/ IUnknown * apCache);

		//-----
		DllExport void SetSharedInfo(SharedSessionHeader * apHeader, SharedObjectOwner * apObjectOwner);

    //----
		DllExport void InitLock();
		DllExport void Lock();
		DllExport void Unlock();

	private:

		//----- Do not allow Copy constructor.
		CMTObjectOwnerBase(const CMTObjectOwnerBase& other)
        { /* Do nothing here */ }

		//----- Do not allow Assignment operator.
		void operator=(const CMTObjectOwnerBase& rSrc)
		{ /* Do nothing here */ }

	private:  // DATA

		//----- The pointer to the real object in shared memory
		SharedObjectOwner * mpObjectOwner;

		//----- Header of the shared memory area
		SharedSessionHeader * mpHeader;
};

#endif /* _MTOBJECTOWNERBASE_H */
