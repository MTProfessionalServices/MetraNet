/**************************************************************************
 * @doc MCOBJECTOWNER
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
 * Created by:	Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MCOBJECTOWNER
 ***************************************************************************/

#ifndef _MCOBJECTOWNER_H
#define _MCOBJECTOWNER_H

//------ Unmanaged SessionServer definitions
#pragma unmanaged
#include "MTObjectOwnerBaseDef.h"

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTPipelineLibExt.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#pragma managed

//-----
#include "MCCommon.h"

//-----
using namespace System;
using System::Runtime::InteropServices::Marshal;

//----- Managed Session Server namespace.
namespace MetraTech
{
	namespace Pipeline
	{
		public interface class IObjectOwner
		{
//xxx TODO: Move to session Set
			property String^ SerializedSessionContext;
			property String^ SessionContextUserName;
			property String^ SessionContextPassword;
			property String^ SessionContextNamespace;
		};

		//----- Managed Object Owner
		public ref class ObjectOwner : public IObjectOwner
		{
			public:

				//----- Class factory method.  Create manage object and 
				//----- et the object owner object into COM wrapper.
				static IObjectOwner^ Create(CMTObjectOwnerBase* pUnmanagedObjectOwner)
				{
					ObjectOwner^ pManagedObjectOwner = gcnew ObjectOwner;
					pManagedObjectOwner->mpUnmanagedObjectOwner = pUnmanagedObjectOwner;
					return pManagedObjectOwner;
				}

			private:
				//----- Contructor/destructor pair.
				ObjectOwner();
				~ObjectOwner();

				//----- Set the object owner object into COM wrapper.
				void SetObjectOwner(CMTObjectOwnerBase* pObjectOwnerBase)
				{
					if (mpUnmanagedObjectOwner)
						delete mpUnmanagedObjectOwner;
						
					mpUnmanagedObjectOwner = pObjectOwnerBase;
				};

			public:
				property int ID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_ID();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(int value) { /* nop */ }
				}

				property int StageID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_StageID();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(int value) { /* nop */}
				}

				property int SessionSetID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_SessionSetID();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(int value) { /* nop */}
				}

				property bool NotifyStage
				{
					virtual bool get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_NotifyStage();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(bool value) { /* nop */}
				}

				property bool CompleteProcessing
				{
					virtual bool get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_CompleteProcessing();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(bool value) { /* nop */}
				}

				property bool SendFeedback
				{
					virtual bool get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_SendFeedback();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(bool value) { /* nop */}
				}

				property int TotalCount
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_TotalCount();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(int value) { /* nop */}
				}

				property int WaitingCount
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_WaitingCount();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(int value) { /* nop */}
				}

				property bool IsComplete
				{
					virtual bool get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_IsComplete();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(bool value) { /* nop */}
				}

				property int NextObjectOwnerID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_NextObjectOwnerID();
						END_TRY_UNMANAGED_BLOCK()
					}

					virtual void set(int value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_NextObjectOwnerID(value);
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property bool FlagError
				{
					virtual void set(bool value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->FlagError();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual bool get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_ErrorFlag();
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property String^ TransactionID
				{
					virtual String ^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return gcnew String(mpUnmanagedObjectOwner->get_TransactionID());
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(String^ value)
					{
						const wchar_t* pszString = MTGetUnmanagedString(value);
						_bstr_t bstrValue(pszString);
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_TransactionID(bstrValue);
						END_TRY_UNMANAGED_BLOCK()
						Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
						pszString = 0;
					}
				}

				property MTPipelineLib::IMTTransaction* Transaction
				{
					virtual MTPipelineLib::IMTTransaction* get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_Transaction();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(MTPipelineLib::IMTTransaction* value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_Transaction(value);
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property String^ SerializedSessionContext
				{
					virtual void set(String^ value)
					{
						const wchar_t * pszString = MTGetUnmanagedString(value);
						_bstr_t bstrValue(pszString);
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_SerializedSessionContext(bstrValue);
						END_TRY_UNMANAGED_BLOCK()
						Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
						pszString = 0;
					}
					virtual String^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return gcnew String(mpUnmanagedObjectOwner->get_SerializedSessionContext());
						END_TRY_UNMANAGED_BLOCK()
					}
				}
				property System::String^ SessionContextUserName
				{
					virtual void set(System::String^ value)
					{
						const wchar_t* pszString = MTGetUnmanagedString(value);
						_bstr_t bstrValue(pszString);
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_SessionContextUserName(bstrValue);
						END_TRY_UNMANAGED_BLOCK()
						Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
						pszString = 0;
					}
					virtual System::String^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return gcnew String(mpUnmanagedObjectOwner->get_SessionContextUserName());
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property String^ SessionContextPassword
				{
					virtual void set(String^ value)
					{
						const wchar_t* pszString = MTGetUnmanagedString(value);
						_bstr_t bstrValue(pszString);
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_SessionContextPassword(bstrValue);
						END_TRY_UNMANAGED_BLOCK()
						Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
						pszString = 0;
					}
					virtual String^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return gcnew String(mpUnmanagedObjectOwner->get_SessionContextPassword());
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property String^ SessionContextNamespace
				{
					virtual void set(String^ value)
					{
						const wchar_t* pszString = MTGetUnmanagedString(value);
						_bstr_t bstrValue(pszString);
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_SessionContextNamespace(bstrValue);
						END_TRY_UNMANAGED_BLOCK()
						Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
						pszString = 0;
					}
					virtual String^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return gcnew String(mpUnmanagedObjectOwner->get_SessionContextNamespace());
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property MTPipelineLibExt::IMTSessionContext* SessionContext
				{
					virtual MTPipelineLibExt::IMTSessionContext* get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_SessionContext();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(MTPipelineLibExt::IMTSessionContext* value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_SessionContext(value);
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property IUnknown* RSIDCache
				{
					virtual IUnknown* get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedObjectOwner->get_RSIDCache();
						END_TRY_UNMANAGED_BLOCK()
					}

					virtual void set(IUnknown* value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedObjectOwner->put_RSIDCache(value);
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				int IncreaseSharedRefCount();
				int DecreaseSharedRefCount();

				bool DecrementWaitingCount();

				void InitForNotifyStage(int aTotalCount, int aOwnerStage);
				void InitForSendFeedback(int aTotalCount, int aSessionSetID);
				void InitForCompleteProcessing(int aTotalCount, int aSessionSetID);

			private: // DATA
				CMTObjectOwnerBase* mpUnmanagedObjectOwner;
		};
	};
};

#endif /* _MCOBJECTOWNER_H */

//-- EOF --