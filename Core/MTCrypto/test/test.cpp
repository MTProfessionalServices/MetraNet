/**************************************************************************
* Copyright 1997-2000 by MetraTech Corp.
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
* 
* Created by: David Blair
* $Header: test.cpp, 3, 9/11/2002 9:50:14 AM, Alon Becker$
* 
***************************************************************************/

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif

#include <windows.h>
#include <metra.h>
#include <mtcom.h>
#include <mtprogids.h>
#include <MTUtil.h>
#include <multi.h>
#include <errutils.h>
#include <ConfigDir.h>
#include <mtcryptoapi.h>
#include <base64.h>
#include <iostream>
#include <ACLAPI.H>

static ComInitialize sComInitialize;

#define TEMP_CONTAINER_NAME "testcontainer"
#define DUP_CONTAINER_NAME "dupcontainer"

int getExchangeKey(bool create, std::string& publickeyblob)
{
	CMTCryptoProvider provider;
	int result;
	result = provider.Initialize(DUP_CONTAINER_NAME, false, create);
	ASSERT(result == 0);
	
	// Validate that we got a good key set
	std::string text;
	result = provider.GetContainerName(text);
	ASSERT(result == 0);
	ASSERT(text == DUP_CONTAINER_NAME);

	CMTCryptoPublicKey exchangeKey(&provider);
	result = provider.GetExchangeKey(&exchangeKey);
	ASSERT(result == 0);

	result = exchangeKey.ExportKey(publickeyblob);
	ASSERT(result == 0);
	return result;
}

// This test validates that the same container name may be 
// used by different users (provided they are not machine keys).
int testContainerReuse()
{
	std::string publickeyblob;
	int result;
	result = getExchangeKey(true, publickeyblob);
	ASSERT(result == 0);

	std::string publickeyblobcopy;
	rfc1421encode((const unsigned char *) publickeyblob.c_str(), publickeyblob.size(), publickeyblobcopy);

	std::cout << "Public key for container " << DUP_CONTAINER_NAME << ": " << publickeyblobcopy.c_str() << std::endl;

	result = getExchangeKey(false, publickeyblobcopy);
	ASSERT(result == 0);
	ASSERT(publickeyblob == publickeyblobcopy);

	return result;
}

int testCrypto(bool bMachineKey)
{
	int result;
	CMTCryptoProvider provider;
	unsigned long ul;
	std::string text;
	std::vector<unsigned char> ciphertext;

	result = provider.Initialize(TEMP_CONTAINER_NAME, bMachineKey, true);
	result = provider.GetProviderVersion(ul);
	ASSERT(ul == 0x00000200);
	result = provider.GetContainerName(text);
	ASSERT(text == TEMP_CONTAINER_NAME);

	// Test granting EVERYONE access
	provider.GrantAccess("EVERYONE");

	CMTCryptoSessionKey bogusSessionKey(&provider);
	result = bogusSessionKey.Initialize("DSF", "sdfsdfsdf");
	ASSERT(result != 0);
	std::cout << bogusSessionKey.GetCryptoApiErrorString() << " (ignored)" << std::endl;

	text.assign("qwerqwer");
	CMTCryptoSessionKey rc4SessionKey(&provider);
	result = rc4SessionKey.Initialize("RC4", "asdfasdf");
	ASSERT(result == 0);
	result = rc4SessionKey.GetBlockLength(ul);
	ASSERT(result == 0);
	ASSERT(ul == 0);
	result = rc4SessionKey.GetKeyLength(ul);
	ASSERT(result == 0);
	ASSERT(ul == 128); // True for enhanced provider!  Should be 40 for base provider.
	result = rc4SessionKey.Encrypt(text);
	ASSERT(result == 0);
	ASSERT(text != "qwerqwer");
	result = rc4SessionKey.Decrypt(text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

	result = rc4SessionKey.Encrypt(text, ciphertext);
	ASSERT(result == 0);
	result = rc4SessionKey.Decrypt(ciphertext, text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

	CMTCryptoSessionKey rc2SessionKey(&provider);
	result = rc2SessionKey.Initialize("RC2", "asdfasdf");
	ASSERT(result == 0);
	result = rc2SessionKey.GetBlockLength(ul);
	ASSERT(result == 0);
	result = rc2SessionKey.GetKeyLength(ul);
	ASSERT(result == 0);
	result = rc2SessionKey.Encrypt(text);
	ASSERT(result == 0);
	result = rc2SessionKey.Decrypt(text);
	ASSERT(result == 0);

	result = rc2SessionKey.Encrypt(text, ciphertext);
	ASSERT(result == 0);
	result = rc2SessionKey.Decrypt(ciphertext, text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

/*
	CMTCryptoSessionKey rc5SessionKey(&provider);
	result = rc5SessionKey.Initialize("RC5", "asdfasdf");
	result = rc5SessionKey.GetBlockLength(ul);
	result = rc5SessionKey.GetKeyLength(ul);
	result = rc5SessionKey.Encrypt(text);
	result = rc5SessionKey.Decrypt(text);
*/

	CMTCryptoSessionKey desSessionKey(&provider);
	result = desSessionKey.Initialize("DES", "asdfasdf");
	ASSERT(result == 0);
	result = desSessionKey.GetBlockLength(ul);
	ASSERT(result == 0);
	result = desSessionKey.GetKeyLength(ul);
	ASSERT(result == 0);
	result = desSessionKey.Encrypt(text);
	ASSERT(result == 0);
	result = desSessionKey.Decrypt(text);
	ASSERT(result == 0);

	result = desSessionKey.Encrypt(text, ciphertext);
	ASSERT(result == 0);
	result = desSessionKey.Decrypt(ciphertext, text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

	CMTCryptoSessionKey tripleSessionKey(&provider);
	result = tripleSessionKey.Initialize("3DES", "asdfasdf");
	ASSERT(result == 0);
	result = tripleSessionKey.GetBlockLength(ul);
	ASSERT(result == 0);
	ASSERT(ul == 64);
	result = tripleSessionKey.GetKeyLength(ul);
	ASSERT(result == 0);
	ASSERT(ul == 192);
	result = tripleSessionKey.Encrypt(text);
	ASSERT(result == 0);
	ASSERT(text != "qwerqwer");
	result = tripleSessionKey.Decrypt(text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

	result = tripleSessionKey.Encrypt(text, ciphertext);
	ASSERT(result == 0);
	result = tripleSessionKey.Decrypt(ciphertext, text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

  CMTCryptoSessionKey aesSessionKey(&provider);
	result = aesSessionKey.Initialize("AES", "asdfasdf");
	ASSERT(result == 0);
	result = aesSessionKey.GetBlockLength(ul);
	ASSERT(result == 0);
	ASSERT(ul == 128);
	result = aesSessionKey.GetKeyLength(ul);
	ASSERT(result == 0);
	ASSERT(ul == 256);
	result = aesSessionKey.Encrypt(text);
	ASSERT(result == 0);
	ASSERT(text != "qwerqwer");
	result = aesSessionKey.Decrypt(text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

	result = aesSessionKey.Encrypt(text, ciphertext);
	ASSERT(result == 0);
	result = aesSessionKey.Decrypt(ciphertext, text);
	ASSERT(result == 0);
	ASSERT(text == "qwerqwer");

	result = provider.Delete();
	ASSERT(result == 0);

	// Verify really deleted by trying to open without create
	result = provider.Initialize(TEMP_CONTAINER_NAME, bMachineKey, false);
	ASSERT(result != 0);

	std::cout << "testCrypto succeeded" << std::endl;

	return 0;
}

int testCryptoAPI()
{
	// Create a source container (non-machine key) and have it create keys
	int result;
	CMTCryptoProvider provider;
	unsigned long ul;
	string text;
	result = provider.Initialize("unitTestSource", false, true);
	ASSERT(result == 0);
	result = provider.GetProviderVersion(ul);
	ASSERT(result == 0);
	ASSERT(ul == 0x00000200);
	result = provider.GetContainerName(text);
	ASSERT(result == 0);
	
	// Grab public/private key pairs.  
	CMTCryptoPublicKey exchangeKey(&provider);
	CMTCryptoPublicKey signatureKey(&provider);
	result = provider.GetExchangeKey(&exchangeKey);
	ASSERT(result == 0);
	result = provider.GetSignatureKey(&signatureKey);
	ASSERT(result == 0);

	// Export the exchange public key 
	std::string publicKeyBlob;
	result = exchangeKey.ExportKey(publicKeyBlob);
	ASSERT(result == 0);

	// Create a temporary provider
	CMTCryptoProvider provider2;
	result = provider2.Initialize("unitTest", false, true);
	ASSERT(result == 0);
	
	// Generate a session key in the temp provider
	CMTCryptoSessionKey sessionKey(&provider2);
	result = sessionKey.Initialize("AES", "wdfsdf");
	ASSERT(result == 0);

	// Encrypt some data with the session key
	text.assign("sdfjas;fweoru");
	result = sessionKey.Encrypt(text);
	ASSERT(result == 0);
	ASSERT(text != "sdfjas;fweoru");

	// Import the exchange key from the source into the temp provider
	CMTCryptoPublicKey exchangeCopy(&provider2);
	result = provider2.ImportKey(publicKeyBlob, &exchangeCopy);
	ASSERT(result == 0);
	result = exchangeCopy.GetKeyLength(ul);
	ASSERT(result == 0);

	// Wrap the session key with the public exchange key
	std::string sessionKeyBlob;
	result = exchangeCopy.Wrap(&sessionKey, sessionKeyBlob);
	ASSERT(result == 0);

	// Unwrap the session key with the exchange key pair
	// in the original provider (which has the RSA private key).
	CMTCryptoSessionKey sessionCopy(&provider);
	result = exchangeKey.Unwrap(sessionKeyBlob, &sessionCopy);
	ASSERT(result == 0);

	// Decrypt the data with the unwrapped session key
	result = sessionCopy.Decrypt(text);
	ASSERT(result == 0);
	ASSERT(text == "sdfjas;fweoru");

	// Try to wrap the key with the original provider
	result = exchangeKey.Wrap(&sessionCopy, sessionKeyBlob);
	ASSERT(result == 0);

	// Clean up
	provider.Delete();
	provider2.Delete();

	std::cout << "testCryptoAPI succeeded" << std::endl;

	return 0;
}

int testContainerReuseAsUser()
{
	// Despite the fact that I believe it is appropriate to do LOGON32_LOGON_BATCH,
	// the default account doesn't seem to have those permissions.
	// Perhaps the choice between batch and interactive should be configurable
	// Also, it'd be really great to be report accurately about whether the user supports
	// batch logon or not.
	HANDLE hToken=NULL;
	if(FALSE==::LogonUser(L"TestCrypto", L"QABLACK", L"NachoMan1", LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, &hToken))
	{	
		DWORD err = ::GetLastError();

		if (ERROR_LOGON_TYPE_NOT_GRANTED == err)
		{
			std::cout << "Logon of user sample failed because interactive logon not granted: " << err << std::endl;
		}
		else if (ERROR_PRIVILEGE_NOT_HELD == err)
		{
			std::cout << "Logon of user sample failed because calling process does not have privilege: " << err << std::endl;
		}
		else
		{
			std::cout << "Logon of user sample failed: " << err << std::endl;
		}
		return -1;
	}

	if(FALSE == ::ImpersonateLoggedOnUser(hToken))
	{
		DWORD err = ::GetLastError();
		std::cout << "Failed to impersonate sample user: " << err << std::endl;
		::CloseHandle(hToken);
		return -1;
	}
	
  int result = testContainerReuse();

	if(FALSE == ::RevertToSelf())
	{
		DWORD err = ::GetLastError();

		std::cout << "Revert to self failed: " << err << std::endl;
		
		result = -1;
	}

	::CloseHandle(hToken);

	return result;
}


BOOL TakeOwnership() 
{
  BOOL bRetval = FALSE;

  HANDLE hToken = NULL; 
  PSID pSIDAdmin = NULL;
  PSID pSIDEveryone = NULL;
  PACL pACL = NULL;
  SID_IDENTIFIER_AUTHORITY SIDAuthWorld = SECURITY_WORLD_SID_AUTHORITY;
  SID_IDENTIFIER_AUTHORITY SIDAuthNT = SECURITY_NT_AUTHORITY;
  const int NUM_ACES  = 2;
  EXPLICIT_ACCESS ea[NUM_ACES];

  // Specify the DACL to use.
  // Create a SID for the Everyone group.
  if (!AllocateAndInitializeSid(&SIDAuthWorld, 1,
                    SECURITY_WORLD_RID,
                    0,
                    0, 0, 0, 0, 0, 0,
                    &pSIDEveryone)) 
  {
      printf("AllocateAndInitializeSid (Everyone) error %u\n", GetLastError());
      goto Cleanup;
  }

  // Create a SID for the BUILTIN\Administrators group.
  if (!AllocateAndInitializeSid(&SIDAuthNT, 2,
                    SECURITY_BUILTIN_DOMAIN_RID,
                    DOMAIN_ALIAS_RID_ADMINS,
                    0, 0, 0, 0, 0, 0,
                    &pSIDAdmin)) 
  {
      printf("AllocateAndInitializeSid (Admin) error %u\n", GetLastError());
      goto Cleanup;
  }

  ZeroMemory(&ea, NUM_ACES * sizeof(EXPLICIT_ACCESS));

#if 0
  DWORD dwRes;

  // Set read access for Everyone.
  ea[0].grfAccessPermissions = GENERIC_READ;
  ea[0].grfAccessMode = SET_ACCESS;
  ea[0].grfInheritance = NO_INHERITANCE;
  ea[0].Trustee.TrusteeForm = TRUSTEE_IS_SID;
  ea[0].Trustee.TrusteeType = TRUSTEE_IS_WELL_KNOWN_GROUP;
  ea[0].Trustee.ptstrName = (LPTSTR) pSIDEveryone;

  // Set full control for Administrators.
  ea[1].grfAccessPermissions = GENERIC_ALL;
  ea[1].grfAccessMode = SET_ACCESS;
  ea[1].grfInheritance = NO_INHERITANCE;
  ea[1].Trustee.TrusteeForm = TRUSTEE_IS_SID;
  ea[1].Trustee.TrusteeType = TRUSTEE_IS_GROUP;
  ea[1].Trustee.ptstrName = (LPTSTR) pSIDAdmin;

  if (ERROR_SUCCESS != SetEntriesInAcl(NUM_ACES,
                                        ea,
                                        NULL,
                                        &pACL))
  {
      printf("Failed SetEntriesInAcl\n");
      goto Cleanup;
  }

  // Try to modify the object's DACL.
  dwRes = SetNamedSecurityInfo(
      lpszOwnFile,                 // name of the object
      SE_FILE_OBJECT,              // type of object
      DACL_SECURITY_INFORMATION,   // change only the object's DACL
      NULL, NULL,                  // do not change owner or group
      pACL,                        // DACL specified
      NULL);                       // do not change SACL

  if (ERROR_SUCCESS == dwRes) 
  {
      printf("Successfully changed DACL\n");
      bRetval = TRUE;
      // No more processing needed.
      goto Cleanup;
  }
  if (dwRes != ERROR_ACCESS_DENIED)
  {
      printf("First SetNamedSecurityInfo call failed: %u\n", dwRes); 
      goto Cleanup;
  }

  // If the preceding call failed because access was denied, 
  // enable the SE_TAKE_OWNERSHIP_NAME privilege, create a SID for 
  // the Administrators group, take ownership of the object, and 
  // disable the privilege. Then try again to set the object's DACL.

  // Open a handle to the access token for the calling process.
  if (!OpenProcessToken(GetCurrentProcess(), 
                        TOKEN_ADJUST_PRIVILEGES, 
                        &hToken)) 
      {
        printf("OpenProcessToken failed: %u\n", GetLastError()); 
        goto Cleanup; 
      } 

  // Enable the SE_TAKE_OWNERSHIP_NAME privilege.
  if (!SetPrivilege(hToken, SE_TAKE_OWNERSHIP_NAME, TRUE)) 
  {
      printf("You must be logged on as Administrator.\n");
      goto Cleanup; 
  }

  // Set the owner in the object's security descriptor.
  dwRes = SetNamedSecurityInfo(
      lpszOwnFile,                 // name of the object
      SE_FILE_OBJECT,              // type of object
      OWNER_SECURITY_INFORMATION,  // change only the object's owner
      pSIDAdmin,                   // SID of Administrator group
      NULL,
      NULL,
      NULL); 

  if (dwRes != ERROR_SUCCESS) 
  {
      printf("Could not set owner. Error: %u\n", dwRes); 
      goto Cleanup;
  }
      
  // Disable the SE_TAKE_OWNERSHIP_NAME privilege.
  if (!SetPrivilege(hToken, SE_TAKE_OWNERSHIP_NAME, FALSE)) 
  {
      printf("Failed SetPrivilege call unexpectedly.\n");
      goto Cleanup;
  }

  // Try again to modify the object's DACL, now that we are the owner.
  dwRes = SetNamedSecurityInfo(
      lpszOwnFile,                 // name of the object
      SE_FILE_OBJECT,              // type of object
      DACL_SECURITY_INFORMATION,   // change only the object's DACL
      NULL, NULL,                  // do not change owner or group
      pACL,                        // DACL specified
      NULL);                       // do not change SACL

  if (dwRes == ERROR_SUCCESS)
  {
      printf("Successfully changed DACL\n");
      bRetval = TRUE; 
  }
  else
  {
      printf("Second SetNamedSecurityInfo call failed: %u\n", dwRes); 
  }

#endif

	Cleanup:
  if (pSIDAdmin)
      FreeSid(pSIDAdmin); 
  if (pSIDEveryone)
      FreeSid(pSIDEveryone); 
  if (pACL)
      LocalFree(pACL);
  if (hToken)
      CloseHandle(hToken);

  return bRetval;
}


int main()
{
	// Test once as non-machine key and once as machine key
	int result = testCrypto(false);
	if(0 != result) return result;

	result = testCrypto(true);
	if(0 != result) return result;

	result = testCryptoAPI();
	if(0 != result) return result;

	result = testContainerReuse();
	if(0 != result) return result;

/*
	//BOOL bVal = TakeOwnership();
	//if(TRUE != bVal) return -1;

	//result = testContainerReuseAsUser();
	//if(0 != result) return result;
*/

	// Temporary test of the upgrade process.
	CMTCryptoAPI crypto;
	result = crypto.CreateKeysAndUpgrade("MetraNet", "metratechlistener", "listener");
	if(0 != result) return result;	

	return result;
}
