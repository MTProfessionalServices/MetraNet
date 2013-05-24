/**************************************************************************
 * PIPELINEINTEROP
 *
 * Copyright 1997-2002 by MetraTech Corp.
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
 * $Date: 10/9/2002 5:19:26 PM$
 * $Author: Derek Young$
 * $Revision: 3$
 ***************************************************************************/

#include "PipelineInterop.h"

#include <pipeconfigutils.h>
#include <ConfigDir.h>
#include <mtprogids.h>
#include <mtzlib.h>

#pragma unmanaged
#include <MSIX.h>
#pragma managed

#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

namespace MetraTech
{
	namespace PipelineInterop
	{

	PipelineQueue::PipelineQueue(String ^ machine, String ^ name,
							 PipelineQueueType type)
		: mName(name), mMachineName(machine), mType(type)
	{

	}
	
	PipelineConfig::PipelineConfig()
		: mpPipelineInfo(nullptr)
	{

	}

	
	PipelineConfig::~PipelineConfig()
	{
		if (mpPipelineInfo)
		{
			//delete mpPipelineInfo;
			mpPipelineInfo = nullptr;
		}
	}

	
	
void PipelineConfig::AddQueue(ArrayList ^ queues,
							  const wstring & machineName, const wstring & queueName,
							  PipelineQueueType type)
{
	String ^ strMachine;
	if (machineName.length() == 0)
		strMachine =  nullptr;
	else
		strMachine = gcnew String(machineName.c_str());

	String ^ strQueue = gcnew String(queueName.c_str());

	PipelineQueue ^ queueInfo = gcnew PipelineQueue(strMachine, strQueue, type);
	queues->Add(queueInfo);
}

void PipelineConfig::ReadConfig()
{
	if (mpPipelineInfo)
		return;

	std::string configDir;
	if (!GetMTConfigDir(configDir))
		// TODO: throw!
		ASSERT(0);
//		return Error("Configuration directory not specified!");


	PipelineInfoReader pipelineReader;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	mpPipelineInfo = new PipelineInfo;
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), *mpPipelineInfo))
	{
		// TODO: throw
		///SetError(pipelineReader.GetLastError());
		//mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		//return FALSE;
		ASSERT(0);
	}

}

String ^ MSIXUtils::CreateUID()
{
	string uidStr;
	MSIXUidGenerator::Generate(uidStr);
	return gcnew String(uidStr.c_str());
}


cli::array<System::Byte>^ DataUtils::Encrypt(cli::array<System::Byte>^ clearText) 
{
	InitializeCrypto();

	int payloadLen = clearText->Length;
	pin_ptr<System::Byte> payload = &clearText[0];

	int cleartextLen = payloadLen;
	long encryptedLen = cleartextLen;

	// figure out what the length of the encrypted data will be
	int result = mpCrypto->Encrypt(NULL, &encryptedLen, cleartextLen);
	if (result != 0)
	{
		std::string s = mpCrypto->GetCryptoApiErrorString();
		throw gcnew System::ApplicationException(gcnew String(s.c_str()));
	}

	cli::array<System::Byte>^ outputBuffer = gcnew cli::array<System::Byte>(encryptedLen);
	pin_ptr<System::Byte> buffer = &outputBuffer[0];

	// the encryption API encrypts in place - copy the data into the buffer before
	// encrypting
	memcpy(buffer, payload, payloadLen);

	long dataLen = cleartextLen;
	result = mpCrypto->Encrypt((char *) buffer, &dataLen, encryptedLen);

	ASSERT(dataLen == encryptedLen);

	if (result != 0)
	{
		std::string s = mpCrypto->GetCryptoApiErrorString();
		throw gcnew System::ApplicationException(gcnew String(s.c_str()));
	}

	payloadLen = encryptedLen;

	return outputBuffer;
}

void DataUtils::Decrypt(cli::array<System::Byte>^ cipherText,
					   [System::Runtime::InteropServices::Out] int % clearTextLength)
{
	InitializeCrypto();

	// the batch can be decrypted in place so we don't need to allocate a new
	// buffer
	long dataLen = cipherText->Length;
	pin_ptr<System::Byte> data = &cipherText[0];

	long decryptedLen = dataLen;
	int result = mpCrypto->Decrypt((char *) data, &decryptedLen);
	pin_ptr<int> pinnedLength = &clearTextLength;
	
	*pinnedLength = decryptedLen;
	if (result != 0)
	{
		std::string s = mpCrypto->GetCryptoApiErrorString();
		throw gcnew System::ApplicationException(gcnew String(s.c_str()));
	}
}

cli::array<System::Byte>^ DataUtils::Compress(cli::array<System::Byte>^ original,
				          [System::Runtime::InteropServices::Out] int % compressedLen)
{
	int uncompressedLen = original->Length;
	pin_ptr<System::Byte> uncompressed = &original[0];

	// memory for the uncompressed data
	unsigned long estimatedCompressedLen = MTZLib::RecommendCompressedBufferSize(uncompressedLen);

	cli::array<System::Byte> ^ outputBuffer = gcnew cli::array<System::Byte>(estimatedCompressedLen);
	pin_ptr<System::Byte> buffer = &outputBuffer[0];

	int ret = MTZLib::Compress(buffer, &estimatedCompressedLen, uncompressed, uncompressedLen);

	if (ret != Z_OK)
		throw gcnew System::ApplicationException("Unable to compress data");

	pin_ptr<int> pinnedLength = &compressedLen;
	*pinnedLength = estimatedCompressedLen;

	return outputBuffer;
}

cli::array<System::Byte>^ DataUtils::Decompress(cli::array<System::Byte>^ compressed,
				/*[System::Runtime::InteropServices::Out]*/ int % originalLength)
{
	int compressedLen = compressed->Length;
	pin_ptr<System::Byte> compressedBuffer = &compressed[0];

	pin_ptr<int> pinnedLength = &originalLength;

	cli::array<System::Byte>^ outputBuffer = gcnew cli::array<System::Byte>(*pinnedLength);
	pin_ptr<System::Byte> buffer = &outputBuffer[0];

	unsigned long destLen = *pinnedLength;
	int ret = MTZLib::Uncompress(buffer, &destLen, compressedBuffer, compressedLen);
	if (ret != Z_OK)
		throw gcnew System::ApplicationException("Unable to uncompress data");

	*pinnedLength = destLen;
	
	return outputBuffer;
}

void DataUtils::InitializeCrypto()
{
	const char * functionName = "PipelineMessageUtils::InitializeCrypto";

	if (mpCrypto)
		return;

	mpCrypto = new CMTCryptoAPI;

	int result = mpCrypto->CreateKeys("metratechpipeline", true,"pipeline");
	if (result == 0)
		result = mpCrypto->Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, "metratechpipeline", true, "pipeline");

	if (result != 0)
	{
//		mLogger.LogVarArgs(LOG_ERROR,
//											 "Unable to initialize crypto functions: %x: %s",
//											 result,
//											 CMTCryptoAPI::GetCryptoApiErrorString());
		// NOTE: this "result" code is not very useful so override it
		// with the crypto specific code
		std::string s = mpCrypto->GetCryptoApiErrorString();
		throw gcnew System::ApplicationException(gcnew String(s.c_str()));
	}
}

DataUtils::DataUtils()
	: mpCrypto(nullptr)
{ }

DataUtils::~DataUtils()
{

}


// close the namespaces
}
}


