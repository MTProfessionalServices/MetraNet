/**************************************************************************
 * @doc MCSESSION
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
 ***************************************************************************/

#include "StdAfx.h"

#pragma unmanaged
#include <mtprogids.h>
#include <accessgrant.h>
#pragma managed

// Managed headers
#include "MCSessServer.h"
#include "MCSession.h"

// Managed Session Server namespace.
namespace MetraTech
{
	namespace Pipeline
	{
		// Constructor/destructor pair.
		Session::Session()
			:	mpUnmanagedSession(nullptr),
				mpPropertyList(nullptr),
				mbDisposed(false)
		{
		}
	
	// Unpublished methods.

		// Set session information in this class
		void Session::SetSession(CMTSessionBase* pSessionBase)
		{
			if (mpUnmanagedSession)
				delete mpUnmanagedSession;
				
			mpUnmanagedSession = pSessionBase;
		}


	// Published methods.
	
		int Session::GetIntegerProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->GetLongProperty(aPropId);
			END_TRY_UNMANAGED_BLOCK()
		}
		void Session::SetIntegerProperty(int aPropId, int lValue)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->SetLongProperty(aPropId, lValue);
			END_TRY_UNMANAGED_BLOCK()
		}

		double Session::GetDoubleProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->GetDoubleProperty(aPropId);
			END_TRY_UNMANAGED_BLOCK()
		}
		void Session::SetDoubleProperty(int aPropId, double dValue)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->SetDoubleProperty(aPropId, dValue);
			END_TRY_UNMANAGED_BLOCK()
		}

		bool Session::GetBooleanProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->GetBoolProperty(aPropId);
			END_TRY_UNMANAGED_BLOCK()
		}
		void Session::SetBooleanProperty(int aPropId, bool bValue)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->SetBoolProperty(aPropId, bValue);
			END_TRY_UNMANAGED_BLOCK()
		}

		System::String^ Session::GetStringProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			BSTR bstrVal = mpUnmanagedSession->GetStringProperty(aPropId);
			_bstr_t aTempStr(bstrVal, false);
      /*ESR-4509 plug-in Input string does not preserve international characters - change char to wchar_t */
			return gcnew System::String((wchar_t *)aTempStr);
			END_TRY_UNMANAGED_BLOCK()
		}
		void Session::SetStringProperty(int aPropId, System::String^ aString)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			const wchar_t* pszString = MTGetUnmanagedString(aString);
			_bstr_t bstrValue(pszString);
			mpUnmanagedSession->SetStringProperty(aPropId, bstrValue);
			Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
			pszString = 0;
			END_TRY_UNMANAGED_BLOCK()
		}

		System::DateTime Session::GetDateTimeProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			System::DateTime dt(1970,1,1,0,0,0);
			__int64 lDateTimeSecs = mpUnmanagedSession->GetDateTimeProperty(aPropId);
			return dt.AddMilliseconds((double)(lDateTimeSecs * 1000));
			END_TRY_UNMANAGED_BLOCK()
		}
		void Session::SetDateTimeProperty(int aPropId, System::DateTime dtValue)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			System::DateTime dt(1970,1,1,0,0,0);
			__int64 nTicksDelta = dtValue.Ticks  - (__int64) dt.Ticks;
			int lDateTime = (int) (nTicksDelta / TimeSpan::TicksPerSecond);
			mpUnmanagedSession->SetDateTimeProperty(aPropId, lDateTime);
			END_TRY_UNMANAGED_BLOCK()
		}

		int Session::GetEnumProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->GetEnumProperty(aPropId);
			END_TRY_UNMANAGED_BLOCK()
		}
		void Session::SetEnumProperty(int aPropId, int lValue)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->SetEnumProperty(aPropId, lValue);
			END_TRY_UNMANAGED_BLOCK()
		}

		System::Decimal Session::GetDecimalProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			DECIMAL decValue = mpUnmanagedSession->GetDecimalProperty(aPropId);
			return System::Decimal(decValue.Lo32, decValue.Mid32, decValue.Hi32, 
						   decValue.sign == 0 ? false : true, decValue.scale);
			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::SetDecimalProperty(int aPropId, System::Decimal aValue)
		{
			// Convert to DECIMAL
			array<int>^ bits = System::Decimal::GetBits(aValue);
			DECIMAL decValue;
			decValue.wReserved = 0;
			decValue.signscale = (bits[3]) >> 16;
			decValue.Hi32 = bits[2];
			decValue.Mid32 = bits[1];
			decValue.Lo32 = bits[0];

			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->SetDecimalProperty(aPropId, decValue);
			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::SetObjectProperty(int aPropId, System::Object^ pObj)
		{
			IntPtr ptrVariant = Marshal::AllocCoTaskMem(16);
			Marshal::GetNativeVariantForObject(pObj, ptrVariant);
			VARIANT* var = (VARIANT*) ptrVariant.ToPointer();

			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->SetObjectProperty(aPropId, *var);
			END_TRY_UNMANAGED_BLOCK()
		}
		System::Object^ Session::GetObjectProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return VariantToObject(mpUnmanagedSession->GetObjectProperty(aPropId));
			END_TRY_UNMANAGED_BLOCK()
		}
		__int64 Session::GetLongProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->GetLongLongProperty(aPropId);
			END_TRY_UNMANAGED_BLOCK()
		}
		void Session::SetLongProperty(int aPropId, __int64 lValue)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->SetLongLongProperty(aPropId, lValue);
			END_TRY_UNMANAGED_BLOCK()
		}

		bool Session::PropertyExists(int aPropId, ISession::PropertyType type)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->PropertyExists(aPropId, (MTPipelineLib::MTSessionPropType) type);
			END_TRY_UNMANAGED_BLOCK()
		}

		// DTC Support
		System::EnterpriseServices::ITransaction^ Session::GetTransaction(bool bCreate)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			MTPipelineLib::IMTTransactionPtr pITransaction(mpUnmanagedSession->GetTransaction(bCreate), false);
			if (pITransaction)
			{
				IUnknownPtr pTransUnk(pITransaction->GetTransaction());
				if (pTransUnk)
				{
					IUnknown * ifacePtr = pTransUnk.GetInterfacePtr();
					System::IntPtr iPtr = (System::IntPtr) ifacePtr;
								
					return safe_cast<System::EnterpriseServices::ITransaction^>(Marshal::GetObjectForIUnknown(iPtr));
				}
			}
			return nullptr;
			END_TRY_UNMANAGED_BLOCK()
		}
		
		MetraTech::Interop::MTPipelineLib::IMTSQLRowset^ Session::GetRowset(System::String^ strConfigFile)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			const wchar_t* pszString = MTGetUnmanagedString(strConfigFile);
			_bstr_t bstrValue(pszString);
			ROWSETLib::IMTSQLRowsetPtr pSQLRowset(mpUnmanagedSession->GetRowset(bstrValue), false);
			Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
			pszString = 0;
			if (pSQLRowset)
			{
				IUnknown * ifacePtr = pSQLRowset.GetInterfacePtr();
				System::IntPtr iPtr = (System::IntPtr) ifacePtr;
				return safe_cast<MetraTech::Interop::MTPipelineLib::IMTSQLRowset^>(Marshal::GetObjectForIUnknown(iPtr));
			}
			return nullptr;
			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::FinalizeTransaction()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->FinalizeTransaction();
			END_TRY_UNMANAGED_BLOCK()
		}

		System::String^ Session::GetTransactionID()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			BSTR bstrVal = mpUnmanagedSession->GetTransactionID();
			_bstr_t aTempStr(bstrVal, false);
			return gcnew System::String((char *)aTempStr);
			END_TRY_UNMANAGED_BLOCK()
		}

		System::String^ Session::GetEncryptedStringProperty(int aPropId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			BSTR bstrVal = mpUnmanagedSession->DecryptEncryptedProp(aPropId);
			_bstr_t aTempStr(bstrVal, false);
			return gcnew System::String((char *)aTempStr);
			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::SetEncryptedStringProperty(int aPropId, System::String^ aString)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			
			// Set and ecrypt the string property.
			const wchar_t* pszString = MTGetUnmanagedString(aString);
			_bstr_t bstrValue(pszString);
			mpUnmanagedSession->EncryptStringProp(aPropId, bstrValue);
			Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
			pszString = 0;

			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::CommitPendingTransaction()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->CommitPendingTransaction();
			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::MarkAsFailed(System::String^ strErrorMessage, int aErrorCode)
		{
			const wchar_t* pszString = MTGetUnmanagedString(strErrorMessage);
			_bstr_t bstrValue(pszString);
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->MarkAsFailed(bstrValue, aErrorCode);
			END_TRY_UNMANAGED_BLOCK()
			Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
			pszString = 0;
		}

 		void Session::MarkAsFailed(System::String^ strErrorMessage)
		{
			MarkAsFailed(strErrorMessage, -2147467259 /* E_FAIL */);
		}

		void Session::AddSessionChildren(ISessionSet^ apSet)
		{
			CMTSessionServerBase* pServer = CMTSessionServerBase::CreateInstance();
			int lSetID = apSet->InternalID;

			BEGIN_TRY_UNMANAGED_BLOCK()
			std::auto_ptr<CMTSessionSetBase> pSessionSetBaseTmp(pServer->GetSessionSet(lSetID));
			pServer->Release();
			if (pSessionSetBaseTmp.get())
				mpUnmanagedSession->AddSessionChildren(pSessionSetBaseTmp.get());
			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::AddSessionDescendants(ISessionSet^ apSet)
		{
			CMTSessionServerBase* pServer = CMTSessionServerBase::CreateInstance();
			int lSetID = apSet->InternalID;

			BEGIN_TRY_UNMANAGED_BLOCK()
			std::auto_ptr<CMTSessionSetBase> pSessionSetBaseTmp(pServer->GetSessionSet(lSetID));
			pServer->Release();
			if (pSessionSetBaseTmp.get())
				mpUnmanagedSession->AddSessionDescendants(pSessionSetBaseTmp.get());
			END_TRY_UNMANAGED_BLOCK()
		}

		// Use this method with caution
		bool Session::MarkComplete()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->MarkComplete();
			END_TRY_UNMANAGED_BLOCK()
		}

		// Use this method with caution
		int Session::IncreaseSharedRefCount()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->IncreaseSharedRefCount();
			END_TRY_UNMANAGED_BLOCK()
		}

		// Use this method with caution
		int Session::DecreaseSharedRefCount()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSession->DecreaseSharedRefCount();
			END_TRY_UNMANAGED_BLOCK()
		}

		// Use this method with caution
		void Session::DeleteForcefully()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->DeleteForcefully();
			END_TRY_UNMANAGED_BLOCK()
		}

		void Session::MarkCompoundAsFailed()
		{

			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->MarkCompoundAsFailed();
			END_TRY_UNMANAGED_BLOCK()
		}

		// IEnemerable implementation.
		IEnumerator^ Session::GetEnumerator()
		{
			MT_LOCK_ACCESS()

			// Allocate property array if we don't have one.
			if (!mpPropertyList)
				mpPropertyList = gcnew System::Collections::ArrayList;
			else if (mpPropertyList->Count > 0)
				mpPropertyList->Clear();

			// Populate porperties list.
			const SharedPropVal* propVal = NULL;
			int hashBucket = -1;
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSession->GetProps(&propVal, &hashBucket);
			END_TRY_UNMANAGED_BLOCK()
			while (propVal)
			{
				// Initialize property				
				MTPipelineLib::MTSessionPropType sessionPropType;
				if (!ConvertPropertyType(propVal->GetType(), &sessionPropType))
					return nullptr;
				
				// Have to do a reverse lookup on the ID to get the name
				MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
				int nameID = propVal->GetNameID();

				// Create managed property.
				ISessionProperty^ pProperty = SessionProperty::Create((ISession::PropertyType) sessionPropType, 
																	  nameid->GetName(nameID),
																	  nameID);

				// Add to list.
				mpPropertyList->Add(pProperty);

				// Get next prop.
				mpUnmanagedSession->GetNextProp(&propVal, &hashBucket);
			}

			return mpPropertyList->GetEnumerator();
		}
	};
};

//-- EOF --
