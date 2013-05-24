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

#ifndef _MCSESSIONSET_H
#define _MCSESSIONSET_H

// Required headers
#include "MCCommon.h"

// Unmanaged SessionServer definitions
#pragma unmanaged

#include "MTSessionServerBaseDef.h"
#include "MTSessionSetBaseDef.h"
#include "MTSessionBaseDef.h"
#include "MTVariantSessionEnumBase.h"

#using <MTPipelineLib.interop.dll>
#using <MTPipelineLibExt.interop.dll>
#using <System.Enterpriseservices.dll>
#pragma managed

#include <msclr\marshal.h>
//
using namespace System;
using namespace System::Collections;
using namespace System::Runtime::InteropServices;

// Managed Session Server namespace.
namespace MetraTech
{
	namespace Pipeline
	{
		// Managerd Session Set interface.
		public interface class ISessionSet
			:	public System::Collections::IEnumerable,
				public System::Collections::IEnumerator,
				public System::IDisposable
		{
			property int InternalID { int get(); }
			property System::String^ UIDEncoded { System::String^ get(); }
			property MetraTech::Interop::MTPipelineLibExt::IMTSessionContext^ SessionContext
				{ MetraTech::Interop::MTPipelineLibExt::IMTSessionContext^ get(); }
			property bool HasSessionContext { bool get(); }

			property System::EnterpriseServices::ITransaction^ Transaction
				{ System::EnterpriseServices::ITransaction^ get();  }
			
			System::EnterpriseServices::ITransaction^ GetTransaction(bool bCreate);
			MetraTech::Interop::MTPipelineLib::IMTSQLRowset^ GetRowset(System::String^ strConfigFile);
		};

		//
		public ref class SessionSet : public ISessionSet
		{
			public:
				static ISessionSet^ Create(MetraTech::Interop::MTPipelineLib::IMTSessionSet^ pSessionSet)
				{
					return gcnew SessionSet(pSessionSet);
				}
				static ISessionSet^ Create(CMTSessionSetBase* apSessionSetBase)
				{
					SessionSet^ pManagedSessionSet = gcnew SessionSet;
					pManagedSessionSet->mpUnmanagedSessionSet = apSessionSetBase;
					return pManagedSessionSet;
				}

			private:
				SessionSet();
				SessionSet(MetraTech::Interop::MTPipelineLib::IMTSessionSet^ pSessionSet);
				~SessionSet() 
					{ this->!SessionSet(); }
				
			public:

				// The Finalizer for this reference Class
				!SessionSet()
				{
					// Check to see if Dispose has already been called.
					if (!this->mbDisposed)
					{
						// Dispose unmanaged resources here.
						if (mpUnmanagedSessionSet)
						{
							delete mpUnmanagedSessionSet;
							mpUnmanagedSessionSet = nullptr;
						}

						if (mpUnmanagedSessionEnum)
						{
							delete mpUnmanagedSessionEnum;
							mpUnmanagedSessionEnum = nullptr;
						}

						if (mplPos)
						{
							delete mplPos;
							mplPos = nullptr;
						}

						mbDisposed = true;
					}
				}

				System::Object^ getSession();
				//
				void SetServer(CMTSessionServerBase* apServerBase);
				void SetSessionSet(CMTSessionSetBase* apSessionSetBase);

			public:

				void AddSession(int aSessionId, int aServiceId);

				property System::EnterpriseServices::ITransaction^ Transaction
				{
					virtual System::EnterpriseServices::ITransaction^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						std::auto_ptr<CMTVariantSessionEnumBase> pUnmanagedSessionEnum(mpUnmanagedSessionSet->get__NewEnum());
						long lPos = NULL;
						CMTSessionBase* pSessionBase = nullptr;
						if (pUnmanagedSessionEnum->First(lPos, &pSessionBase))
						{
							std::auto_ptr<CMTSessionBase> tmp(pSessionBase);
							MTPipelineLib::IMTTransactionPtr pITransaction(pSessionBase->GetTransaction(false), false);
							if (pITransaction)
							{
							  // Yes
							  IUnknownPtr pTransUnk(pITransaction->GetTransaction(), false);
							  if (pTransUnk)
							  {
								  IUnknown * ifacePtr = pTransUnk.GetInterfacePtr();
								  System::IntPtr iPtr = (System::IntPtr) ifacePtr;							  
					              return safe_cast<System::EnterpriseServices::ITransaction^>(Marshal::GetObjectForIUnknown(iPtr));						  
							  }
							  else
								return nullptr;
							}

							//
							// Is the transaction ID set in the session?  If so we're working on
							// an external transaction.
							//
							_bstr_t txnID = pSessionBase->GetTransactionID();
							if (txnID.length() > 0)
							{
								// Join the transaction
								pITransaction.Attach(pSessionBase->GetTransaction(true), false);
  								if (pITransaction)
								{
									IUnknownPtr pTransUnk(pITransaction->GetTransaction(), false);
									if (pTransUnk)
									{
										IUnknown * ifacePtr = pTransUnk.GetInterfacePtr();
										System::IntPtr iPtr = (System::IntPtr) ifacePtr;
								        return safe_cast<System::EnterpriseServices::ITransaction^>(Marshal::GetObjectForIUnknown(iPtr));						  
									}
								}
							}
						}
					

						return nullptr;
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property MetraTech::Interop::MTPipelineLibExt::IMTSessionContext^ SessionContext
				{
					virtual MetraTech::Interop::MTPipelineLibExt::IMTSessionContext^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						std::auto_ptr<CMTVariantSessionEnumBase> pUnmanagedSessionEnum(mpUnmanagedSessionSet->get__NewEnum());
						long lPos = NULL;
						CMTSessionBase* pSessionBase = nullptr;
						if (pUnmanagedSessionEnum->First(lPos, &pSessionBase))
						{
							std::auto_ptr<CMTSessionBase> tmp(pSessionBase);
							MTPipelineLibExt::IMTSessionContextPtr pISessionContext(pSessionBase->get_SessionContext(), false);
							if (pISessionContext)
							{

								IUnknown * ifacePtr = pISessionContext.GetInterfacePtr();
								System::IntPtr iPtr = (System::IntPtr) ifacePtr;
								return safe_cast<MetraTech::Interop::MTPipelineLibExt::IMTSessionContext^>(Marshal::GetObjectForIUnknown(iPtr));
							}
						}
						return nullptr;
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property bool HasSessionContext
				{
					virtual bool get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						std::auto_ptr<CMTVariantSessionEnumBase> pUnmanagedSessionEnum(mpUnmanagedSessionSet->get__NewEnum());
						long lPos = NULL;
						CMTSessionBase* pSessionBase = nullptr;
						if (pUnmanagedSessionEnum->First(lPos, &pSessionBase))
						{
							std::auto_ptr<CMTSessionBase> tmp(pSessionBase);
							return pSessionBase->get_HoldsSessionContext();
						}
						return false;
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property int InternalID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSessionSet->get_ID();
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				// Use this method with caution
				int IncreaseSharedRefCount();

				// Use this method with caution
				int DecreaseSharedRefCount();

				property cli::array<byte>^ UID
				{
					virtual cli::array<byte>^ get()
					{
						unsigned char uid[UID_SIZE];
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedSessionSet->get_UID(uid);
						END_TRY_UNMANAGED_BLOCK()

						cli::array<byte>^ maUid = gcnew cli::array<byte>(UID_SIZE);
						for (int i=0; i < UID_SIZE; i++)
							maUid[i] = uid[i];

						return maUid;
					}

					virtual void set(cli::array<byte>^ value)
					{
						// pin ptr to 1st element in array.
						pin_ptr<byte> umUid = &value[0];
						byte* np = umUid;
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedSessionSet->SetUID(np);
						END_TRY_UNMANAGED_BLOCK()
					}
				}
				property System::String^ UIDEncoded
				{
					virtual System::String^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						std::string strUID = mpUnmanagedSessionSet->get_UIDAsString();
						System::String^ sUID = gcnew System::String(strUID.c_str());
						return sUID;
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				virtual System::EnterpriseServices::ITransaction^ GetTransaction(bool bCreate)
				{
					BEGIN_TRY_UNMANAGED_BLOCK()
					std::auto_ptr<CMTVariantSessionEnumBase> pUnmanagedSessionEnum(mpUnmanagedSessionSet->get__NewEnum());

					long lPos = NULL;
					CMTSessionBase* pSessionBase = NULL;
					if (pUnmanagedSessionEnum->First(lPos, &pSessionBase))
					{
						std::auto_ptr<CMTSessionBase> tmp(pSessionBase);
						MTPipelineLib::IMTTransactionPtr pITransaction(pSessionBase->GetTransaction(bCreate), false);
						if (pITransaction)
				        {
						    // Yes
							IUnknownPtr pTransUnk(pITransaction->GetTransaction(), false);
				            if (pTransUnk)
							{
								IUnknown * ifacePtr = pTransUnk.GetInterfacePtr();
								System::IntPtr iPtr = (System::IntPtr) ifacePtr;
								return safe_cast<System::EnterpriseServices::ITransaction^>(Marshal::GetObjectForIUnknown(iPtr));
							}
						}
					}
					return nullptr;
					END_TRY_UNMANAGED_BLOCK()
				}

				virtual MetraTech::Interop::MTPipelineLib::IMTSQLRowset^ GetRowset(System::String^ strConfigFile);			

				// IEnumerable definition.
				virtual IEnumerator^ GetEnumerator();
				// IEnemerator definition.
				virtual bool MoveNext();
				virtual void Reset();
				virtual property System::Object^ Current
				{
					virtual System::Object^ get()
					{
						return getSession();
					}
				}

			private: // Functions

			private: // Data
				CMTSessionSetBase* mpUnmanagedSessionSet;

				// Used for enumeration
				bool mbInitialState;
				long* mplPos;
				CMTVariantSessionEnumBase* mpUnmanagedSessionEnum;

				// Track whether Dispose has been called.
				bool mbDisposed;
		};
	};
};

#endif //_MCSESSIONSET_H

// EOF