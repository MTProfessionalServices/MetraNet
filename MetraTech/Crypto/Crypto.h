/**************************************************************************
* @doc MTSQLINTEROP
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
* Created by: Boris Partensky
*
* $Date: 10/23/2002 12:09:59 PM$
* $Author: Boris$
* $Revision: 3$
*
* @index | MTSQLINTEROP
***************************************************************************/

#ifndef _CRYPTO_H
#define _CRYPTO_H


#include <vcclr.h>

#ifdef WIN32
// only include this header one time
#pragma once
#endif


#pragma unmanaged

//very important to include this header in
//the unmanaged section
#include <mtcryptoapi.h>
#include <base64.h>
#include <mtutil.h>

#pragma managed

#include <msclr\marshal.h>

namespace MetraTech
{
    namespace Crypto
    {
	  using namespace System::Runtime::InteropServices;

	  [Guid("b3222585-2836-4141-8446-814d16954bf2")]
	  public interface class IDecryptor
      {
        void Initialize();
        System::String^ Decrypt(System::String^ aEncrypted);
				//System::String* Encode(System::String* aEncrypted);
				//System::String* Base64EncodeAndDecrypt(System::String* aEncrypted);
      };

	  [Guid("8c505902-3e68-4661-b06b-b4cf1d3ed066")]
	  [ClassInterface(ClassInterfaceType::None)]
	  public ref class Decryptor : public IDecryptor
      {
      public:
        virtual void Initialize();
        virtual System::String^ Decrypt(System::String^ aEncrypted);
		System::String^ Base64EncodeAndDecrypt(System::String^ aEncrypted);
		System::String^ Encode(System::String^ aEncrypted);
        System::String^ Encrypt(System::String^ aUnEncrypted);
		virtual ~Decryptor();
        void InitializeForMtPipeline();
        Decryptor();
        System::String^ ConvertStringToMD5(System::String^ aUnEncrypted);

      protected:
		CMTCryptoAPI * mpCrypto;
        bool mInitialized;
      };

		} 
    [System::Runtime::InteropServices::ComVisible(false)]
		public ref class CryptoException : public System::Exception
		{
		public:
			CryptoException(CMTCryptoAPI* aCrypto) 
				: System::Exception(msclr::interop::marshal_as<System::String^>(aCrypto->GetCryptoApiErrorString()))
			{
				
			}
			CryptoException(System::String^ aMsg) : System::Exception(aMsg)
			{

			}
		};
    
}

#endif /* _MTSQLINTEROP_H */

