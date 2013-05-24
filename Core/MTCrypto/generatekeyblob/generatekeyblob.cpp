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
* Created by: 
* $Header$
* 
***************************************************************************/

// ----------------------------------------------------------------
// Name:        generatekeyblob 
//
// Usage:       generatekeyblob -encryptionkey 
//                              [-encryptiontype RC2|RC4|DES|3DES|AES]
//                              -inputpublickeyblob filename 
//                              -outputsessionkeyblob filename
//                              [-createkeypair]
//                              [-login username -password password -domain domainname] 
//
// Arguments:   
//   -encryptionkey        - Plaintext key material used to genenerate the session key. 
//   -encryptiontype       - Type of session key to generate.  The options are
//                           RC2, RC4, DES, 3DES, and AES.  The default is 3DES.
//   -inputpublickeyblob   - File that stores the public key blob. Assumes that the file
//                           is in the config\ServerAccess directory. 
//   -outputsessionkeyblob - File that stores the session key after the session key has
//                           been encrypted with the public key. 
//   -createkeypair        - Generate a permanent key-pair with container name "pipeline"
//   -login                - Used in multi-instance deployments. 
//   -password             - Used in multi-instance deployments. 
//   -domain               - Used in multi-instance deployments. 
//
// Description: 
//   The purpose of this tool is to encrypt the key used to protect the credit card
//   numbers while this key is stored on disk. This tool must be run for each
//   participant in the encryption process. For example, the Listener encrypts the
//   credit card number and the payment server pipelines decrypt the credit card
//   number prior to submitting a transaction to the credit card processor. Therefore,
//   this tool must be run twice. 
// ----------------------------------------------------------------
//

// crypto.cpp : Defines the entry point for the console application.

#include "StdAfx.h"
#include <windows.h>
#include <stdio.h>

#include <metra.h>
#include <mtcom.h>
#include <mtprogids.h>
#include <MTUtil.h>
#include <multi.h>
#include <errutils.h>
#include <ConfigDir.h>
#include <mtcryptoapi.h>

#include <iostream>
using namespace std;

#import "MTConfigLib.tlb"

static ComInitialize sComInitialize;

void         MTGetLastErrorString(TCHAR * atchBuf, int aintError, int aintLen);
int          main(int argc, char **argv);
void         DisplayError(const char * chrErrorString);

static int usage()
{
    printf("Usage: generatekeyblob -encryptionkey key\n");
    printf("                       [-encryptiontype RC2|RC4|DES|3DES|AES]\n");
    printf("                       -inputpublickeyblob filename\n");
    printf("                       -outputsessionkeyblob filename\n");
    printf("                       [-createkeypair] \n");
    printf("                       [-login username -password password -domain domainname]\n");
    printf("\n");
    printf("-encryptionkey        - Plaintext key material used to genenerate\n");
    printf("                        the session key.\n"); 
		printf("-encryptiontype       - Type of session key to generate.  The options are\n");
    printf("                        RC2, RC4, DES, 3DES, and AES.  The default is AES.\n");
    printf("-inputpublickeyblob   - File that stores the public key blob. Assumes\n");
    printf("                        that the file is in the config\\ServerAccess\n");
    printf("                        directory.\n"); 
    printf("-outputsessionkeyblob - File that stores the session key after the\n");
    printf("                        session key has been encrypted with the \n");
    printf("                        public key. Assumes that the file is in the\n");
    printf("                        config\\ServerAccess directory.\n");
    printf("-createkeypair        - Generate a permanent key-pair with container name \"pipeline\".\n");
    printf("-login                - Used in multi-instance deployments.\n");
    printf("-password             - Used in multi-instance deployments.\n");
    printf("-domain               - Used in multi-instance deployments.\n"); 
    return(1);
}

#define TEMP_CONTAINER_NAME "generatekeyblob"

//
// global vars
//
string grwcConfigDir;

int main(int argc, char * argv[])
{

	CMTCryptoProvider provider;
	CMTCryptoPublicKey publicKey(&provider);
	CMTCryptoSessionKey sessionKey(&provider);

	string          containerName      = "";
	int             result             = 0;

	FILE          * hPublicKeyBlob     = NULL;
	DWORD           dwPublicKeyBlobLen = 0;
	BYTE          * pbPublicKeyBlob    = NULL;

  unsigned long   ulngVersion        = 0;
  unsigned long   keylen             = 0;

  DWORD           dwSessionBlobLen   = 0;

  FILE          * hSimpleBlobFile    = NULL; 
  unsigned long   ulngNumWritten     = 0;

 	//
	// parse command line args
	//
	const char * login                = NULL;
	const char * password             = NULL;
	const char * domain               = NULL;
	string    rwcInputPublicKeyblob;
	string    rwcOutputSessionKeyblob;

	string       sEncryptionKey;
	string       sEncryptionType;
	string       sBlob;

	bool createKeyPair = false;

	// Use AES as the default encryption
	sEncryptionType = "AES";

	// negative means test forever
	int i = 1;
	while (i < argc)
	{
		if (0 == strcmp(argv[i], "-encryptiontype"))
		{
			i++;
			if (i >= argc)
			{
				cout << "algorithm type required after -encryptiontype" << endl;
				return usage();
			}
			sEncryptionType = argv[i];
		}
		else if (0 == strcmp(argv[i], "-createkeypair"))
		{
			createKeyPair = true;
		}
		else if (0 == strcmp(argv[i], "-login"))
		{
			i++;
			if (i >= argc)
			{
				cout << "login name required after -login" << endl;
				return usage();
			}
			login = argv[i];
		}
		else if (0 == strcmp(argv[i], "-password"))
		{
			i++;
			if (i >= argc)
			{
				cout << "password required after -password" << endl;
				return usage();
			}
			password = argv[i];
		}
		else if (0 == strcmp(argv[i], "-domain"))
		{
			i++;
			if (i >= argc)
			{
				cout << "domain required after -domain" << endl;
				return usage();
			}
			domain = argv[i];
		}
		else if (0 == strcmp(argv[i], "-encryptionkey"))
		{
			i++;
			if (i >= argc)
			{
				cout << "key required after -encryptionkey" << endl;
				return usage();
			}
			sEncryptionKey = argv[i];
		}
		else if (0 == strcmp(argv[i], "-inputpublickeyblob"))
		{
			i++;
			if (i >= argc)
			{
				cout << 
          "filename containing the public keyblob required after -inputpublickeyblob" << 
          endl;
				return usage();
			}
			rwcInputPublicKeyblob = argv[i];
		}
		else if (0 == strcmp(argv[i], "-outputsessionkeyblob"))
		{
			i++;
			if (i >= argc)
			{
				cout << 
          "destination filename containing the session key " <<
          "required after -outputsessionkeyblob" << endl;
				return usage();
			}
			rwcOutputSessionKeyblob = argv[i];
		}
		else
		{
			cout << "argument not understood: " << argv[i] << endl;
			return usage();
		}

		i++;
	}

	if (rwcOutputSessionKeyblob.size() == 0 ||
			rwcInputPublicKeyblob.size() == 0 ||
			sEncryptionKey.size() == 0)
	{
		return usage();
	}

	MultiInstanceSetup multiSetup;
	if (!multiSetup.SetupMultiInstance(login, password, domain))
	{
		string buffer;
		StringFromError(buffer, "Multi-instance setup failed", multiSetup.GetLastError());
		cout << buffer.c_str() << endl;
		return -1;
	}

  if (!GetMTConfigDir(grwcConfigDir))
  {
    cout << "Unable to read config directory from the registry" << endl;
    return NULL;
  }

  //
  // prepend the pathname to the filenames
  //
  rwcInputPublicKeyblob.insert(0, "serveraccess\\");
  rwcInputPublicKeyblob.insert(0, grwcConfigDir);
  rwcOutputSessionKeyblob.insert(0, "serveraccess\\");
  rwcOutputSessionKeyblob.insert(0, grwcConfigDir);

	if (createKeyPair)
	{
		CMTCryptoAPI create;
		if (0 != (result=create.CreateKeys("metratechpipeline", true, "pipeline")))
		{
			cout << "Failed to create keys: " << create.GetCryptoApiErrorString() <<  endl;
			goto Done;
		}
	}

	//
  // Get a handle to the key container (generate a new temporary one if necessary) 
	//

	if (0 != (result = provider.Initialize(TEMP_CONTAINER_NAME, false, true)))
	{
		cout << provider.GetCryptoApiErrorString() << endl;
		goto Done;
	}


	//
  // Import the public key
	//

	// Open source file.
	if(!(hPublicKeyBlob = fopen((const char *)rwcInputPublicKeyblob.c_str(), "rb"))) 
  {
    DisplayError("Unable to get size of key blob");
    goto Done;
  }

	fread(&dwPublicKeyBlobLen, sizeof(DWORD), 1, hPublicKeyBlob); 
	if(ferror(hPublicKeyBlob) || feof(hPublicKeyBlob))
  {
    DisplayError("Unable to read session key blob");
    goto Done;
  }

  if(!(pbPublicKeyBlob = (BYTE *)malloc(dwPublicKeyBlobLen)))
  {
    DisplayError("can't allocate memory");
    goto Done;
  }

  fread(pbPublicKeyBlob, 1, dwPublicKeyBlobLen, hPublicKeyBlob); 
  if(ferror(hPublicKeyBlob) || feof(hPublicKeyBlob))
  {
    DisplayError("unable to read key blob");
    goto Done;
  }

	// Deserialize the public key object
	sBlob.assign((char *)pbPublicKeyBlob, dwPublicKeyBlobLen);
	if (0 != (result = provider.ImportKey(sBlob, &publicKey)))
	{
		cout << provider.GetCryptoApiErrorString() << endl;
		goto Done;
	}

	cout << "generating a new " << sEncryptionType.c_str() << " session" << endl;

	//
	// Generate a key based on user supplied data that is used to
	// protect the key blobs.
	//

	if (0 != (result = sessionKey.Initialize(sEncryptionType, sEncryptionKey)))
	{
		cout << sessionKey.GetCryptoApiErrorString() << endl;
		goto Done;
	}

  //
  // verify provider attributes
  //

	if (0 != (result = provider.GetContainerName(containerName)))
	{
		cout << provider.GetCryptoApiErrorString() << endl;
		goto Done;
	}

	ASSERT(containerName == TEMP_CONTAINER_NAME);
	if (0 != (result = provider.GetProviderVersion(ulngVersion)))
	{
		cout << provider.GetCryptoApiErrorString() << endl;
		goto Done;
	}


  printf("Version is 0x%x\n", ulngVersion);

  //
  // verify RSA key parameters
  //
	
	if (0 != (result = publicKey.GetKeyLength(keylen)))
	{
		cout << publicKey.GetCryptoApiErrorString() << endl;
		goto Done;
	}

	printf("RSA key strength in bits is %d\n", keylen);

  //
  // verify session key parameters
  //

	if (0 != (result = sessionKey.GetKeyLength(keylen)))
	{
		cout << sessionKey.GetCryptoApiErrorString() << endl;
		goto Done;
	}

	cout << sEncryptionType.c_str() << " session key strength in bits is " << keylen << endl;

  //
  // wrap the session key in the public and export the session key to file
  //

	if (0 != (result = publicKey.Wrap(&sessionKey, sBlob)))
	{
		cout << publicKey.GetCryptoApiErrorString() << endl;
		goto Done;
	}


  //
  // write blob to file
  // 

  hSimpleBlobFile = fopen((const char *)rwcOutputSessionKeyblob.c_str(), "wb+");
 
  if (!hSimpleBlobFile) 
  { 
    char chrBuf[1024];
    sprintf(chrBuf,
            "Could not open file: %s",
            (const char *)rwcOutputSessionKeyblob.c_str());
    DisplayError(chrBuf);
    goto Done;
  } 
  
	dwSessionBlobLen = sBlob.size();
  ulngNumWritten = fwrite((const void *)&dwSessionBlobLen,
                          sizeof(DWORD),
                          1,
                          hSimpleBlobFile); 

  if (ulngNumWritten < 1)
  { 
    char chrBuf[1024];
    sprintf(chrBuf,
            "Could not write blob length to file: %s",
            (const char *)rwcOutputSessionKeyblob.c_str());
    DisplayError(chrBuf);
    goto Done;
  } 

  ulngNumWritten = fwrite(sBlob.data(), 1, sBlob.size(), hSimpleBlobFile); 

  if (ulngNumWritten < sBlob.size())
  { 
    char chrBuf[1024];
    sprintf(chrBuf,
            "Could not write to file: %s",
            (const char *)rwcOutputSessionKeyblob.c_str());
    DisplayError(chrBuf);
    goto Done;
  } 

  printf("simple blob size %d\n", sBlob.size());

Done:

  if(pbPublicKeyBlob)
    free(pbPublicKeyBlob);
  
	if (hPublicKeyBlob)
    fclose(hPublicKeyBlob);

  if (hSimpleBlobFile)
    fclose(hSimpleBlobFile);

  return(0);
}

void
MTGetLastErrorString(TCHAR * atchBuf, int aintError, int aintLen)
{

  FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    NULL,
    aintError,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    (LPTSTR) atchBuf,
    aintLen,
    0);

  return;
}

void
DisplayError(const char * chrErrorString)
{
  TCHAR tchErrBuf[1024];

  MTGetLastErrorString(tchErrBuf, GetLastError(), 128);
  printf("Error message: %s: %S\n", chrErrorString, tchErrBuf);
  return;
}


