/**************************************************************************
 * @doc MTSESSIONBASE
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
 * Created by:  Boris Boruchovich
 *				Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTSESSIONBASE_H_
#define __MTSESSIONBASE_H_

#include "resource.h"       // main symbols

#include <list>
using std::list;

#include <sharedsess.h>
//#include <MTSessionPropType.h>
#include <MTUtil.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
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
class CMTSessionSetBase;
class CMTSessionPropBase;
class CMTSessionServerBase;

//----- Function prototypes.
DllExport bool ConvertPropertyType(SharedPropVal::Type type, MTPipelineLib::MTSessionPropType* pSessionPropType);

//----- CMTSessionBase declaration.
class CMTSessionBase
{
	public:
		DllExport CMTSessionBase();
		DllExport ~CMTSessionBase();

		//----- Enumerate through properties
		DllExport void GetProps(const SharedPropVal * * apFirst,
                            int * apHashBucket) const
		{
			mpSharedSession->GetProps(mpHeader, apFirst, apHashBucket);
		}
		DllExport void GetNextProp(const SharedPropVal * * apProp,
                               int * apHashBucket) const
		{
			mpSharedSession->GetNextProp(mpHeader, apProp, apHashBucket);
		}

	public:

		//----- Session methods.
		DllExport long get_SessionID();
		DllExport const unsigned char* get_UID();
		DllExport string get_UIDAsString();
    DllExport string get_ParentUIDAsString();

		DllExport long get_ServiceID();
		DllExport long get_ParentID();

		DllExport long get_DatabaseID();
		DllExport void put_DatabaseID(long aVal);

		DllExport bool get_IsParent();

		DllExport bool get_CompoundMarkedAsFailed();

		DllExport int get_ObjectOwnerID();
		DllExport void put_ObjectOwnerID(long id);

		//----- Property methods.
		DllExport long GetLongProperty(long propid);
		DllExport void SetLongProperty(long propid, long propval);

		DllExport double GetDoubleProperty(long aPropId);
		DllExport void SetDoubleProperty(long aPropId, double aValue);

		DllExport bool GetBoolProperty(long propid);
		DllExport void SetBoolProperty(long aPropId, bool aVal);

		DllExport BSTR GetStringProperty(long aPropId);
		DllExport void SetStringProperty(long aPropId, const wchar_t* str);

		DllExport DATE GetOLEDateProperty(long aPropId);
		DllExport void SetOLEDateProperty(long aPropId, DATE aValue);

		DllExport time_t GetDateTimeProperty(long aPropId);
		DllExport void SetDateTimeProperty(long aPropId, time_t aValue);

		DllExport long GetTimeProperty(long aPropId);
		DllExport void SetTimeProperty(long aPropId, long aValue);

		DllExport long GetEnumProperty(long propid);
		DllExport void SetEnumProperty(long propid, long propval);

		DllExport DECIMAL GetDecimalProperty(long aPropId);
		DllExport void SetDecimalProperty(long aPropId, DECIMAL aValue);
		DllExport void SetDecimalProperty(long aPropId, const DECIMAL * aValue);

		DllExport VARIANT GetObjectProperty(long propid);
		DllExport void SetObjectProperty(long propid, VARIANT propval);

		DllExport __int64 GetLongLongProperty(long propid);
		DllExport void SetLongLongProperty(long propid, __int64 propval);

		DllExport bool PropertyExists(long aPropId, MTPipelineLib::MTSessionPropType type);

		// DTC Support
		DllExport MTPipelineLib::IMTTransaction* GetTransaction(bool aCreate);
		DllExport ROWSETLib::IMTSQLRowset* GetRowset(BSTR ConfigFile);
		DllExport void FinalizeTransaction();
		DllExport BSTR GetTransactionID();
		
		DllExport BSTR DecryptEncryptedProp(long aPropID);
    DllExport void EncryptStringProp(long aPropID, const wchar_t* str);

		DllExport void CommitPendingTransaction();

		DllExport void MarkAsFailed(BSTR aErrorMessage, long aErrorCode = E_FAIL);

		DllExport MTPipelineLibExt::IMTSessionContext* get_SessionContext();

		DllExport bool get_HoldsSessionContext();

		DllExport CMTSessionSetBase* SessionChildren();
		DllExport void AddSessionChildren(CMTSessionSetBase* apSet);
		DllExport void AddSessionDescendants(CMTSessionSetBase* apSet);

		// NOTE: use this method with caution
		DllExport bool MarkComplete();

		// NOTE: use this method with caution
		DllExport long IncreaseSharedRefCount();

		// NOTE: use this method with caution
		DllExport long DecreaseSharedRefCount();

		// NOTE: use this method with caution
		DllExport void DeleteForcefully();

		DllExport void MarkCompoundAsFailed();

		DllExport void put_InTransitTo(long id);
		DllExport void put_InProcessBy(long id);

		DllExport void AddEvents(int events);
		DllExport int get_Events();

		//----- Set session information in this class
		DllExport void SetSharedInfo(MappedViewHandle * apHandle,
						   SharedSessionHeader * apHeader,
						   SharedSession * apSession);

		//----- DTC Support
		DllExport void InternalSetTransaction(MTPipelineLib::IMTTransactionPtr apTxn);
		DllExport void InternalClearRowset();

    DllExport BSTR GetLongLongPropertyAsString(long propid);

	private:

		//-----
		typedef list<SharedSession *> SessionList;
		struct ChildScanInfo
		{
			long mParentId;
			SessionList * mpList;
			BOOL mAllDescendants;
		};

		static BOOL DescendantScan(void * apArg, SharedSessionHeader * apHeader,
									SharedSession * apSession);

		static void CollectChildren(SharedSessionHeader * apHeader,
									SharedSession * apSession,
									SessionList & arList);

		static void CollectDescendants(SharedSessionHeader * apHeader,
										SharedSession * apSession,
										SessionList & arList);

	private:
		SharedPropVal * GetOrCreateSharedProp(long aPropId);

		static void OleDateToTimet(SharedPropVal * apProp);

		static void TimetToOleDate(SharedPropVal * apProp);

		const SharedPropVal * GetSharedProp(long aNameId) const;

		SharedPropVal * AddSharedProp(long aNameId);

		long AllocateWideString(const wchar_t * apStr);

		long AllocateString(const char * apStr);

		void FreeWideString(long aRef);

		void FreeString(long aRef);

		long GetTransactionObjectAddress(BSTR name);

		const wchar_t* GetWideString(long aRef);

		const char* GetString(long aRef);

		//----- Final destruction.
		void FinalRelease();

		//----- Throw property error.
		void PropertyError(HRESULT aError, long aPropId);

		//-----
		void DumpSession();
		void ClearProperty(SharedPropVal * apProp);

		//----- Do not Alloaw Copy constructor
		CMTSessionBase(const CMTSessionBase& other)
        { /* Do nothing here */	}

		//----- Do not Allow Assignment operator.
		void operator=(const CMTSessionBase& rSrc)
        { /* Do nothing here */	}

	private: // DATA

		//----- The shared object - we addref and release it
		SharedSession* mpSharedSession;

		//----- Header of the shared memory area
		SharedSessionHeader* mpHeader;

		//----- Handle to shared memory area
		MappedViewHandle* mpMappedView;
};

#endif //__MTSESSIONBASE_H_

//-- EOF --
