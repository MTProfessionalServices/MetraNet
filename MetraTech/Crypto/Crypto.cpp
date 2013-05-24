/**************************************************************************
* MTSQLINTEROP
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
* Created by: Boris Partensky
*
* $Date$
* $Author$
* $Revision$
***************************************************************************/

#pragma managed

#include <Crypto.h>


namespace MetraTech
{
    namespace Crypto
    {
	  void Decryptor::Initialize()
      {
        if (!mInitialized)
        {
				  mpCrypto = new CMTCryptoAPI();
				  int result = mpCrypto->CreateKeys("metratechpipeline", true, "pipeline");
				  if (result != 0)
					  throw gcnew CryptoException(mpCrypto);
				  result = mpCrypto->Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword,
					                            "metratechpipeline", TRUE, "pipeline");
				  if (result != 0)
					  throw gcnew CryptoException(mpCrypto);
        }
				
			}

      void Decryptor::InitializeForMtPipeline()
      {
        if (!mInitialized)
        {
          mpCrypto = new CMTCryptoAPI();
		  mpCrypto->Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, 
							   "metratechpipeline", true, "pipeline");
          mInitialized = true;
        }

      }

      System::String^ Decryptor::Decrypt(System::String^ aEncrypted)
      {
				System::IntPtr ptr = Marshal::StringToHGlobalAnsi(aEncrypted);
				string chars = (const char*) ptr.ToPointer();
				int res = mpCrypto->Decrypt(chars);
				if (res != 0)
					throw gcnew CryptoException(mpCrypto);
			
				System::String^ outStr = gcnew System::String(chars.c_str());

				Marshal::FreeHGlobal(ptr);

				return outStr;
      }

      System::String^ Decryptor::Encrypt(System::String^ aUnEncrypted)
      {
				System::IntPtr ptr = Marshal::StringToHGlobalAnsi(aUnEncrypted);
				string chars = (const char*)ptr.ToPointer();
				int res = mpCrypto->Encrypt(chars);
				if (res != 0)
					throw gcnew CryptoException(mpCrypto);

				System::String^ outStr = gcnew System::String(chars.c_str());

				Marshal::FreeHGlobal(ptr);

				return outStr;
      }


	  System::String^ Decryptor::Base64EncodeAndDecrypt(System::String^ aEncrypted)
      {
			return Decrypt(Encode(aEncrypted));
      }

	  System::String^ Decryptor::Encode(System::String^ aEncrypted)
	  {	
		  System::IntPtr ptr = Marshal::StringToHGlobalAnsi(aEncrypted);
		  char* temp = (char*)ptr.ToPointer();
		  BYTE* byte = NULL;
		  byte = (BYTE*)temp;
		  ULONG len = strlen(temp);
		  std::string dest;
		  BOOL ok = rfc1421encode_nonewlines(byte, len, dest);
		  if (!ok)
			  throw gcnew CryptoException("Failed to encode the buffer");

		  System::String^ outStr = gcnew System::String(temp);

		  return outStr;
    	}

        System::String^ Decryptor::ConvertStringToMD5(System::String^ aUnEncrypted)
		{
		
			const wchar_t* chars = (const wchar_t*)(Marshal::StringToHGlobalUni(aUnEncrypted)).ToPointer();
        
            string passwordToBeHashed;
            WideStringToUTF8(chars, passwordToBeHashed);

            std::string temp;
			BOOL result = MTMiscUtil::ConvertStringToMD5(passwordToBeHashed.c_str(), temp);
			if (result != TRUE)
				throw gcnew System::ApplicationException("Encryption failed.");
			
			System::String^ output = gcnew System::String(temp.c_str());
				
			Marshal::FreeHGlobal(System::IntPtr((void*)chars));

			return output;
    	}

		Decryptor::~Decryptor(void)
		{
			delete mpCrypto;
		}

		Decryptor::Decryptor()
        {
			mInitialized = false;
		}
		
		}
}
