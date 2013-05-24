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

#ifndef _MCSESSION_H
#define _MCSESSION_H

//- Unmanaged SessionServer definitions
#pragma unmanaged
#include "MTSessionBaseDef.h"
#include "MTSessionSetBaseDef.h"
#include "MTSessionServerBaseDef.h"

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTPipelineLibExt.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#pragma managed

// Managed headers
#include "MCSessionSet.h"

// Include marshaling component namespace.
using System::Runtime::InteropServices::Marshal;

// Managed Session Server namespace.
namespace MetraTech
{
	namespace Pipeline
	{
	

		// Managerd Session interface.
		public interface class ISession
			:	public System::Collections::IEnumerable,
				public System::IDisposable
		{
			
					//
			// Type of session property.
			// This code is duplicating MTSessionPropType enum.
			// It is critical that the values set for each type in MTSessionPropType
			// equal the values for each matching PropertyType.
			//
			enum class PropertyType 
			{
				DateTime = 1,
				// Time = 2,   // Not used in managed world
				String = 3,
				Int = 4,       // Maps to LONG property type in 32 bit world
				Double = 5,
				Bool = 6,
				Enum = 7,
				Decimal = 8,
				Object = 9,
				Long = 10      // Maps to LONGLONG property type in 32 bit world
			};

		    //
			int GetIntegerProperty(int aPropId);
			void SetIntegerProperty(int aPropId, int lValue);

			__int64 GetLongProperty(int aPropId);
			void SetLongProperty(int aPropId, __int64 lValue);

			double GetDoubleProperty(int aPropId);
			void SetDoubleProperty(int aPropId, double dValue);

			bool GetBooleanProperty(int aPropId);
			void SetBooleanProperty(int aPropId, bool bValue);

			System::String^ GetStringProperty(int aPropId);
			void SetStringProperty(int aPropId, System::String^ aString);

 			System::String^ GetEncryptedStringProperty(int aPropId);
			void SetEncryptedStringProperty(int aPropId, System::String^);

			System::DateTime GetDateTimeProperty(int aPropId);
			void SetDateTimeProperty(int aPropId, System::DateTime dtValue);

			int GetEnumProperty(int aPropId);
			void SetEnumProperty(int aPropId, int lValue);

			System::Decimal GetDecimalProperty(int aPropId);
			void SetDecimalProperty(int aPropId, System::Decimal aValue);

			bool PropertyExists(int aPropId, ISession::PropertyType type);

			MetraTech::Interop::MTPipelineLib::IMTSQLRowset^ GetRowset(System::String^ strConfigFile);

			void MarkAsFailed(System::String^ strErrorMessage, int aErrorCode);
			void MarkAsFailed(System::String^ strErrorMessage);
	
			property ISessionSet^ SessionChildren { ISessionSet^ get(); }
			property cli::array<byte>^ UID { cli::array<byte>^ get(); }
			property int InternalID { int get(); }
			property int InternalParentID { int get(); }
			property int ServiceDefinitionID { int get(); }
			property System::String^ UIDEncoded { System::String^ get(); }
			property bool IsParent { bool get(); }
		};

		// Managerd Session property interface.
		public interface class ISessionProperty
		{
			property System::String^ Name { System::String^ get(); void set(System::String^); }
			property int NameID { int get(); void set(int); }
			property ISession::PropertyType Type { ISession::PropertyType get(); void set(ISession::PropertyType); }
		};

		// Managed Session property
		public ref class SessionProperty : public ISessionProperty
		{
			public:
				static ISessionProperty^ Create(ISession::PropertyType aType, BSTR aName, int aNameID)
				{
					SessionProperty^ pManagedSessionProperty = gcnew SessionProperty;
					pManagedSessionProperty->SetPropInfo(aType, aName, aNameID);
					return pManagedSessionProperty;
				}

			private:
				SessionProperty()
				{ /* Do nothing here */	}

				~SessionProperty()
					{ /* Do nothing here */ }

			public:
 
				property System::String^ Name
				{
					virtual System::String^ get() { return mName; }
					virtual void set(System::String^ value) { mName = value; }
				}
					
				property int NameID
				{
					virtual int get() { return mNameID; }
					virtual void set(int value) { mNameID = value; }
				}

			    property ISession::PropertyType Type
				{
					virtual ISession::PropertyType get() { return mType; }
					virtual void set(ISession::PropertyType value) { mType = value; }
				}

			private:
				void SetPropInfo(ISession::PropertyType aType, BSTR aName, int aNameID)
				{
					mType = aType;
					mName = gcnew String(aName);
					mNameID = aNameID;
				}

			// DATA MEMBERS:
				ISession::PropertyType mType;
				System::String^ mName;
				int mNameID;
		};

		// Managed Session object wrapper.
		public ref class Session
			:	public ISession
		{
			public:
				static ISession^ Create(CMTSessionBase* pUnmanagedSession)
				{
					Session^ pManagedSession = gcnew Session;
					pManagedSession->SetSession(pUnmanagedSession);
					return pManagedSession;
				}

      private:

				// Constructor/destructor pair.
				Session();
				~Session()
					{ this->!Session(); }					

			public:
			
				// The Finalizer for this reference Class
				!Session()
				{
					// Check to see if Dispose has already been called.
					if (!this->mbDisposed)
					{
						if (mpUnmanagedSession)
						{
							BEGIN_TRY_UNMANAGED_BLOCK()
							delete mpUnmanagedSession;
							END_TRY_UNMANAGED_BLOCK()
							mpUnmanagedSession = nullptr;
						}

						if (mpPropertyList)
						{
							BEGIN_TRY_UNMANAGED_BLOCK()
							delete mpPropertyList;
							END_TRY_UNMANAGED_BLOCK()
							mpPropertyList = nullptr;
						}

						mbDisposed = true;
					}
				}
				virtual void SetSession(CMTSessionBase* pSessionBase);

				property int InternalID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSession->get_SessionID();
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property System::String^ UIDEncoded
				{
					virtual System::String^ get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return gcnew System::String(mpUnmanagedSession->get_UIDAsString().c_str());
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property int ServiceDefinitionID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSession->get_ServiceID();
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property int InternalParentID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSession->get_ParentID();
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property int DatabaseID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSession->get_DatabaseID();
						END_TRY_UNMANAGED_BLOCK()
					}

					virtual void set(int value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedSession->put_DatabaseID(value);
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				property cli::array<byte>^ UID
				{
					virtual cli::array<byte>^ get()
					{
						const unsigned char* uid;
						BEGIN_TRY_UNMANAGED_BLOCK()
						uid = mpUnmanagedSession->get_UID();
						END_TRY_UNMANAGED_BLOCK()
						if (!uid)
							return nullptr;
	
						cli::array<byte>^ maUid = gcnew cli::array<byte>(UID_SIZE);
						for (int i=0; i < UID_SIZE; i++)
							maUid[i] = uid[i];
						return maUid;
					}
				}

				property bool IsParent
				{
					virtual bool get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSession->get_IsParent();
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				bool get_CompoundMarkedAsFailed()
				{
					BEGIN_TRY_UNMANAGED_BLOCK()
					return mpUnmanagedSession->get_CompoundMarkedAsFailed();
					END_TRY_UNMANAGED_BLOCK()
				}

				property int ObjectOwnerID
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSession->get_ObjectOwnerID();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(int value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						mpUnmanagedSession->put_ObjectOwnerID(value);
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				// Published methods.
			public:

				virtual int GetIntegerProperty(int aPropId);
				virtual void SetIntegerProperty(int aPropId, int lValue);

				virtual double GetDoubleProperty(int aPropId);
				virtual void SetDoubleProperty(int aPropId, double dValue);

				virtual bool GetBooleanProperty(int aPropId);
				virtual void SetBooleanProperty(int aPropId, bool bValue);

				virtual System::String^ GetStringProperty(int aPropId);
				virtual void SetStringProperty(int aPropId, System::String^ aString);

 				virtual System::String^ GetEncryptedStringProperty(int aPropId);
				virtual void SetEncryptedStringProperty(int aPropId, System::String^);

				virtual System::DateTime GetDateTimeProperty(int aPropId);
				virtual void SetDateTimeProperty(int aPropId, System::DateTime dtValue);

				virtual int GetEnumProperty(int aPropId);
				virtual void SetEnumProperty(int aPropId, int lValue);

				virtual System::Decimal GetDecimalProperty(int aPropId);
				virtual void SetDecimalProperty(int aPropId, System::Decimal aValue);

				void SetObjectProperty(int aPropId, System::Object^ pObj);
				System::Object^ GetObjectProperty(int aPropId);

				virtual __int64 GetLongProperty(int aPropId);
				virtual void SetLongProperty(int aPropId, __int64 lValue);

				virtual bool PropertyExists(int aPropId, ISession::PropertyType type);

				// DTC Support
				System::EnterpriseServices::ITransaction^ GetTransaction(bool bCreate);
			
				virtual MetraTech::Interop::MTPipelineLib::IMTSQLRowset^ GetRowset(System::String^ strConfigFile);

				void FinalizeTransaction();

				System::String^ GetTransactionID();

				void CommitPendingTransaction();

				virtual void MarkAsFailed(System::String^ strErrorMessage, int aErrorCode);
				virtual void MarkAsFailed(System::String^ strErrorMessage);

				MTPipelineLibExt::IMTSessionContext* get_SessionContext()
				{
					BEGIN_TRY_UNMANAGED_BLOCK()
					return mpUnmanagedSession->get_SessionContext();
					END_TRY_UNMANAGED_BLOCK()
				}

				bool get_HoldsSessionContext()
				{
					BEGIN_TRY_UNMANAGED_BLOCK()
					return mpUnmanagedSession->get_HoldsSessionContext();
					END_TRY_UNMANAGED_BLOCK()
				}

			public:
				property ISessionSet^ SessionChildren
				{
					virtual ISessionSet^ get()
					{
						// Create the new MC++ session set wrapper and 
						// set the unmanaged session set into it.
						BEGIN_TRY_UNMANAGED_BLOCK()
						return SessionSet::Create(mpUnmanagedSession->SessionChildren());
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				void AddSessionChildren(ISessionSet^ apSet);
				void AddSessionDescendants(ISessionSet^ apSet);

				// Use this method with caution
				bool MarkComplete();

				// Use this method with caution
				int IncreaseSharedRefCount();

				// Use this method with caution
				int DecreaseSharedRefCount();

				// Use this method with caution
				void DeleteForcefully();

				void MarkCompoundAsFailed();

				void set_InTransitTo(int id)
				{
					BEGIN_TRY_UNMANAGED_BLOCK()
					mpUnmanagedSession->put_InTransitTo(id);
					END_TRY_UNMANAGED_BLOCK()
				}

				void set_InProcessBy(int id)
				{
					BEGIN_TRY_UNMANAGED_BLOCK()
					mpUnmanagedSession->put_InProcessBy(id);
					END_TRY_UNMANAGED_BLOCK()
				}
				property int Events
				{
					virtual int get()
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						return mpUnmanagedSession->get_Events();
						END_TRY_UNMANAGED_BLOCK()
					}
					virtual void set(int value)
					{
						BEGIN_TRY_UNMANAGED_BLOCK()
						 mpUnmanagedSession->AddEvents(value);
						END_TRY_UNMANAGED_BLOCK()
					}
				}

				// IEnemerable definition.
				virtual IEnumerator^ GetEnumerator();

			private: // Functions

				// List used for iteration over session properties
				System::Collections::ArrayList^ mpPropertyList;
				bool mbInitialState;

			private: // Data
				CMTSessionBase* mpUnmanagedSession;

				// Track whether Dispose has been called.
				bool mbDisposed;
		};
	};
};

#endif //_MCSESSION_H
