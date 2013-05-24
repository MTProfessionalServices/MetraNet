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

#ifndef _MCSESSIONSERVER_H
#define _MCSESSIONSERVER_H

//------ Unmanaged SessionServer definitions
#pragma unmanaged
#include "MTSessionBaseDef.h"

#using <PipelineControl.interop.dll>
#pragma managed

//----- Managed headers
#include "MCSession.h"
#include "MCSessionSet.h"
#include "MCObjectOwner.h"

//----- Managed Session Server namespace.
namespace MetraTech
{
	namespace Pipeline
	{
		//----- Managed Session Server interface.
		public interface class ISessionServer
		{
			/// <summary>
			/// Return session using session ID
			/// </summary>
			ISession^ GetSession(int sessionId);

			/// <summary>
			/// Return session using UID
			/// </summary>
			ISession^ GetSession(cli::array<byte>^ uid);

			/// <summary>
			/// Return session set using set ID
			/// </summary>
			ISessionSet^ GetSessionSet(int setId);
		};

		//----- Managed SessionServer object declaration.
		public ref class SessionServer : public ISessionServer
		{
			public:

				//----- Class factory method.  Create managed object and 
				//----- set the object into COM wrapper.
				static ISessionServer^ Create()
				{
					MetraTech::Interop::PipelineControl::MTPipeline^ pPipeline = 
						gcnew MetraTech::Interop::PipelineControl::MTPipelineClass;
					return gcnew SessionServer(pPipeline->SessionServer);
				}

			private:

				//----- Constructor/destructor pair.
				SessionServer();
				SessionServer(MetraTech::Interop::PipelineControl::IMTSessionServer^ pSessionServer);
				~SessionServer();

			public:

				//-----
				ISessionSet^ CreateSessionSet();

				//-----
				ISession^ CreateSession(cli::array<byte>^ uid, int serviceId);

				//-----
				void Init(String^ filename, String^ sharename, int totalSize);

				//-----
				ISession^ CreateChildSession(cli::array<byte> ^ uid , int serviceId, cli::array<byte>^ parentUid);

				//-----
				ISession^ CreateTestSession(int serviceId);
				ISession^ CreateChildTestSession(int serviceId, int parentId);

				//-----
				ISessionSet^ FailedSessions();
				virtual ISession^ GetSession(int sessionId);
				virtual ISession^ GetSession(cli::array<byte>^ uid);
				virtual ISessionSet^ GetSessionSet(int setId);

				//-----
				ISessionSet^ SessionsInProcessBy(int aStageID);
				void DeleteSessionsInProcessBy(int aStageID);

				// ----------------------------------------------------------------
				// Description: Return the current percent used of the shared memory file.
				//              Percent used is defined as the max percent full of all
				//              the shared memory pools.
				// Return Value: the current capacity of the pipeline
				// ----------------------------------------------------------------
				double get_PercentUsed()
				{
					BEGIN_TRY_UNMANAGED_BLOCK()
					return mpUnmanagedSessionServer->get_PercentUsed();
					END_TRY_UNMANAGED_BLOCK()
				}

				//----- 
				IObjectOwner^ GetObjectOwner(int ownerId);
				IObjectOwner^ CreateObjectOwner();

				//-----
				void DeleteObjectOwner(int ownerId);
				
			private:
				//----- Pointer to single instance of unmanaged session server object.
				CMTSessionServerBase* mpUnmanagedSessionServer;
		};
	};
};

#endif	// _MCSESSIONSERVER_H

//-- EOF --