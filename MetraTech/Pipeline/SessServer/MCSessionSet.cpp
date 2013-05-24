/**************************************************************************
 * @doc MCSESSIONSET
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

// Managed header includes.
#include "MCSession.h"
#include "MCSessionSet.h"

//
namespace MetraTech
{
	namespace Pipeline
	{
		// Managed Session Server namespace.
		SessionSet::SessionSet()
			:	mpUnmanagedSessionSet(nullptr),
				mpUnmanagedSessionEnum(nullptr),
				mbInitialState(true),
				mbDisposed(false)
		{
			// Need to allocate this long as nogc to pass to unmanaged
			// First and Next enum methods.
			mplPos = new long;
			*mplPos = 0;
		}

		SessionSet::SessionSet(MetraTech::Interop::MTPipelineLib::IMTSessionSet^ pSessionSet)
			:	mpUnmanagedSessionSet(nullptr),
				mpUnmanagedSessionEnum(nullptr),
				mbInitialState(true),
				mbDisposed(false)
		{
			ASSERT(pSessionSet);
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSessionSet = new CMTSessionSetBase(pSessionSet->GetInternalSetHandle());
			END_TRY_UNMANAGED_BLOCK()

			// Need to allocate this long as nogc to pass to unmanaged
			// First and Next enum methods.
			mplPos = new long;
			*mplPos = 0;
		}

		void SessionSet::SetServer(CMTSessionServerBase* apServerBase)
		{
			ASSERT(mpUnmanagedSessionSet);
			BEGIN_TRY_UNMANAGED_BLOCK()
			if (mpUnmanagedSessionSet)
				mpUnmanagedSessionSet->SetServer(apServerBase);
			END_TRY_UNMANAGED_BLOCK()
		}

		void SessionSet::SetSessionSet(CMTSessionSetBase* apSessionSetBase)
		{
			if (mpUnmanagedSessionSet)
				delete mpUnmanagedSessionSet;
				
			mpUnmanagedSessionSet = apSessionSetBase;
		}

		void SessionSet::AddSession(int aSessionId, int aServiceId)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSessionSet->AddSession(aSessionId, aServiceId);
			END_TRY_UNMANAGED_BLOCK()
		}

		// Use this method with caution
		int SessionSet::IncreaseSharedRefCount()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSessionSet->IncreaseSharedRefCount();
			END_TRY_UNMANAGED_BLOCK()
		}

		// Use this method with caution
		int SessionSet::DecreaseSharedRefCount()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedSessionSet->DecreaseSharedRefCount();
			END_TRY_UNMANAGED_BLOCK()
		}

		// IEnemerable implementation.
		IEnumerator^ SessionSet::GetEnumerator()
		{
			if (mpUnmanagedSessionEnum)
				delete mpUnmanagedSessionEnum;

			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedSessionEnum = mpUnmanagedSessionSet->get__NewEnum();
			END_TRY_UNMANAGED_BLOCK()
			return this;
		}

		// IEnumerator implementation.
		bool SessionSet::MoveNext()
		{
			ASSERT(mpUnmanagedSessionEnum);

			// Get the next Session object.
			BEGIN_TRY_UNMANAGED_BLOCK()
			if (mbInitialState)
			{
				mbInitialState = false;
				return mpUnmanagedSessionEnum->First(*mplPos);
			}
			else
				return mpUnmanagedSessionEnum->Next(*mplPos);
			END_TRY_UNMANAGED_BLOCK()
		}

		System::Object^ SessionSet::getSession()
		{
			CMTSessionBase* pCurrentSession;
				BEGIN_TRY_UNMANAGED_BLOCK()
				pCurrentSession = mpUnmanagedSessionEnum->GetAt(*mplPos);
				END_TRY_UNMANAGED_BLOCK()
				if (!pCurrentSession)
					return nullptr;

				ISession^ pSession = Session::Create(pCurrentSession);
				return (System::Object^) pSession;
		}

		void SessionSet::Reset()
		{
			*mplPos = 0;
			mbInitialState = true;
		}

		MetraTech::Interop::MTPipelineLib::IMTSQLRowset^ SessionSet::GetRowset(System::String^ strConfigFile)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			std::auto_ptr<CMTVariantSessionEnumBase> pUnmanagedSessionEnum(mpUnmanagedSessionSet->get__NewEnum());

			long lPos = NULL;
			CMTSessionBase* pSessionBase = nullptr;
			if (pUnmanagedSessionEnum->First(lPos, &pSessionBase))
			{
				std::auto_ptr<CMTSessionBase> tmpSession(pSessionBase);
				const wchar_t* pszString = MTGetUnmanagedString(strConfigFile);
				_bstr_t bstrValue(pszString);
				ROWSETLib::IMTSQLRowsetPtr pSQLRowset(tmpSession->GetRowset(bstrValue), false);
				Marshal::FreeHGlobal(static_cast<IntPtr>(const_cast<void*>(static_cast<const void*>(pszString))));
				pszString = 0;
				if (pSQLRowset)
				{
					IUnknown * ifacePtr = pSQLRowset.GetInterfacePtr();
					System::IntPtr iPtr = (System::IntPtr) ifacePtr;
					return safe_cast<MetraTech::Interop::MTPipelineLib::IMTSQLRowset^>(Marshal::GetObjectForIUnknown(iPtr));
				}
			}
			return nullptr;
			END_TRY_UNMANAGED_BLOCK()
		}
	};
};

//-- EOF --