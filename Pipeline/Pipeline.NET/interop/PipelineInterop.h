/**************************************************************************
 * @doc PIPELINEINTEROP
 *
 * @module |
 *
 *
 * Copyright 2002 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | PIPELINEINTEROP
 ***************************************************************************/

#ifndef _PIPELINEINTEROP_H
#define _PIPELINEINTEROP_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#using "System.dll"

#include <metralite.h>
#include <errobj.h>
#import "MTConfigLib.tlb"

#include <pipelineconfig.h>
#include <mtcryptoapi.h>

using System::String;
using System::Collections::ArrayList;

namespace MetraTech
{
namespace PipelineInterop
{
	// identify which queue we are
	[System::Runtime::InteropServices::ComVisible(false)]
	public enum class PipelineQueueType
	{
		ErrorQueue,
		AuditQueue,
		FailedAuditQueue,
		ResubmitQueue,
		RoutingQueue,
	};

	// all info about each pipeline queue in the system
	[System::Runtime::InteropServices::ComVisible(false)]
	public ref class PipelineQueue
	{
	private:
		String ^ mName;
		String ^ mMachineName;
		PipelineQueueType mType;
	public:
		PipelineQueue(String ^ machine, String ^ name,
					  PipelineQueueType type);

		property String ^ Name
		{
			String ^ get() { return mName; }
		}

		property String ^ MachineName
		{
			String ^ get() { return mMachineName; }
		}

		property PipelineQueueType Type
		{
			PipelineQueueType get() { return mType; }
			void set(PipelineQueueType value ) {
				mType = value;
			}
		}
	};


	// pipeline configuration
	
	[System::Runtime::InteropServices::ComVisible(false)]
	public ref class PipelineConfig
	{
	public:
		PipelineConfig();
		virtual ~PipelineConfig();

		//property ArrayList^ PipelineQueues;
		//property bool UsePrivateQueues;
		//property bool IsDBQueue;
		property bool IsDBQueue
		{
			bool get()
			{
				ReadConfig();
				const std::wstring dbname =  mpPipelineInfo->GetRoutingDatabase();
				return dbname.size() > 0 ? true : false;
			}
		}

		property bool UsePrivateQueues
		{
			virtual bool get()
			{
				ReadConfig();
				return mpPipelineInfo->UsePrivateQueues() ? true : false;
			}
		}

		property ArrayList^ PipelineQueues
		{
			virtual ArrayList^ get()
				{
				ReadConfig();

				ArrayList ^ queues = gcnew ArrayList;
				AddQueue(queues,
								 mpPipelineInfo->GetErrorQueueMachine(), mpPipelineInfo->GetErrorQueueName(),
								 PipelineQueueType::ErrorQueue);

				AddQueue(queues,
								 mpPipelineInfo->GetAuditQueueMachine(), mpPipelineInfo->GetAuditQueueName(),
								 PipelineQueueType::AuditQueue);

				AddQueue(queues,
								 mpPipelineInfo->GetFailedAuditQueueMachine(), mpPipelineInfo->GetFailedAuditQueueName(),
								 PipelineQueueType::FailedAuditQueue);

				AddQueue(queues,
								 mpPipelineInfo->GetResubmitQueueMachine(), mpPipelineInfo->GetResubmitQueueName(),
								 PipelineQueueType::ResubmitQueue);

				AddQueue(queues,
								 mpPipelineInfo->GetOneRoutingQueueMachine(), mpPipelineInfo->GetOneRoutingQueueName(),
								 PipelineQueueType::RoutingQueue);

				return queues;
			}
		}


		 //const HarnessType GetHarnessType() const
  //{ return mRoutingDatabase.size() > 0 ? PERSISTENT_DATABASE_QUEUE : PERSISTENT_MSMQ; }

	private:
		void ReadConfig();

		void AddQueue(ArrayList ^ queues,
					  const wstring & machineName, const wstring & queueName,
					  PipelineQueueType type);

	private:
		PipelineInfo * mpPipelineInfo;
	//public  enum HarnessType
		//{
		//	PERSISTENT_DATABASE_QUEUE,
		//	PERSISTENT_MSMQ
		//};
	};

	[System::Runtime::InteropServices::ComVisible(false)]
	public ref class MSIXUtils
	{
	public:
		static String ^ CreateUID();
	};

	[System::Runtime::InteropServices::ComVisible(false)]
	public ref class DataUtils : public System::IDisposable
	{
	public:
		DataUtils();
		~DataUtils();

		cli::array<System::Byte>^ Encrypt(cli::array<System::Byte>^ clearText);
		void Decrypt(cli::array<System::Byte>^ cipherText,
					 [System::Runtime::InteropServices::Out] int % clearTextLength);

		cli::array<System::Byte>^ Compress(cli::array<System::Byte>^, 
			         [System::Runtime::InteropServices::Out] int % compressedLen);

		cli::array<System::Byte>^ Decompress(cli::array<System::Byte>^,
			                      [System::Runtime::InteropServices::Out] int % originalLength);

	private:
		void InitializeCrypto();

	private:
		CMTCryptoAPI * mpCrypto;
	};

// close the namespaces
}
}

#endif /* _PIPELINEINTEROP_H */
