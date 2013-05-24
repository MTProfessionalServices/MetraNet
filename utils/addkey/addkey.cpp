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
// Name:        addkey 
//
// Usage:       addkey -filename name -name property -value plaintext
//                     -sharedsecret encryptionkey 
//                     [-encryptiontype RC2|RC4|DES|3DES|AES]
//                     [-login username -password password -domain domainname] 
//
// Arguments:   
//   -filename     - Name of the file storing encrypted properties. The format of 
//                   this parameter is a pathname relative to the MetraTech config 
//                   directory. For example, ServerAccess\protectedpropertylist.xml. 
//   -name         - Name of the property to encrypt.
//   -value        - Value requiring protection. 
//   -sharedsecret - The encryption key used to encrypt the data specified to
//                   the value option.
//   -encryptiontype 
//                 - Type of session key to generate.  The options are
//                   RC2, RC4, DES, 3DES and AES.  The default is 3DES.
//   -login        - Used in multi-instance deployments. 
//   -password     - Used in multi-instance deployments. 
//   -domain       - Used in multi-instance deployments. 
//
// Description: The purpose of this tool is to encryption sensitive
//              data while stored on disk. 
// ----------------------------------------------------------------

#include <mtcom.h>
#include <mtprogids.h>
#include <MTUtil.h>
#include <ConfigDir.h>
#include <base64.h>
#include <wincrypt.h>
#include <multi.h>
#include <errutils.h>
#include <mtcryptoapi.h>

#include <iostream>
using namespace std;

#import	<MTConfigLib.tlb> 
using namespace MTConfigLib;

static ComInitialize sComInitialize;

int          main(int argc, char **argv);
BOOL         EncryptKey(string & asEncryptionType, string & asData, string & asKey);

#define TEMP_CONTAINER_NAME "addkey"

static int usage()
{
	printf("Usage: addkey -filename name -name property -value plaintext\n");
	printf("              -sharedsecret encryptionkey\n");
	printf("              [-encryptiontype RC2|RC4|DES|3DES|AES]\n");
	printf("              [-login username -password password -domain domainname]\n");
	printf("\n");
	printf("-filename       - Name of the file storing encrypted properties. The filename\n");
	printf("                  should be an absolute pathname.\n");
	printf("-name           - Name of the property to encrypt.\n");
	printf("-value          - Plaintext value. \n");
	printf("-sharedsecret   - The encryption key used to encrypt the data specified to\n");
	printf("                  the value option.\n");
	printf("-encryptiontype - Encryption algorithm to use to encrypt data.  The options are\n");
	printf("                  RC2, RC4, DES, 3DES and AES.  The default is AES.\n");
	printf("-login          - Used in multi-instance deployments.\n");
	printf("-password       - Used in multi-instance deployments.\n");
	printf("-domain         - Used in multi-instance deployments.\n"); 
	return(1);
}

int main(int argc, char * argv[])
{
  if ((9 != argc) && (11 != argc) && (15 != argc) && (17 != argc))
  {
		return usage();
  }

 	//
	// parse command line args
	//
	const char * login                = NULL;
	const char * password             = NULL;
	const char * domain               = NULL;
	string       sFilename;
	string       sName;
	string       sValue;
	string       sSharedSecret;
	string       sEncryptionType;

	// 
	// Helpers to check correctness of command line
	//
	static const unsigned char CL_FILENAME   = 0x01;
	static const unsigned char CL_NAME       = 0x02;
	static const unsigned char CL_VALUE      = 0x04;
	static const unsigned char CL_SECRET     = 0x08;
	static const unsigned char CL_ENCRYPTION = 0x10;
	static const unsigned char CL_LOGIN      = 0x20;
	static const unsigned char CL_PASSWORD   = 0x40;
	static const unsigned char CL_DOMAIN     = 0x80;
	// helpful masks to use...
	static const unsigned char CL_REQUIRED   = CL_FILENAME | CL_NAME | CL_VALUE | CL_SECRET;
	static const unsigned char CL_MULTI      = CL_LOGIN | CL_PASSWORD | CL_DOMAIN;

	unsigned char clArgs                     = 0x00;

	// Default encryption is AES
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
				return 1;
			}
			sEncryptionType = argv[i];
			clArgs |= CL_ENCRYPTION;
		}
		else if (0 == strcmp(argv[i], "-login"))
		{
			i++;
			if (i >= argc)
			{
				cout << "login name required after -login" << endl;
				return 1;
			}
			login = argv[i];
			clArgs |= CL_LOGIN;
		}
		else if (0 == strcmp(argv[i], "-password"))
		{
			i++;
			if (i >= argc)
			{
				cout << "password required after -password" << endl;
				return 1;
			}
			password = argv[i];
			clArgs |= CL_PASSWORD;
		}
		else if (0 == strcmp(argv[i], "-domain"))
		{
			i++;
			if (i >= argc)
			{
				cout << "domain required after -domain" << endl;
				return 1;
			}
			domain = argv[i];
			clArgs |= CL_DOMAIN;
		}
		else if (0 == strcmp(argv[i], "-filename"))
		{
			i++;
			if (i >= argc)
			{
				cout << "filename required after -filename" << endl;
				return 1;
			}
			sFilename = argv[i];
			clArgs |= CL_FILENAME;
		}
		else if (0 == strcmp(argv[i], "-name"))
		{
			i++;
			if (i >= argc)
			{
				cout << "property name required after -name" << endl;
				return 1;
			}
			sName = argv[i];
			clArgs |= CL_NAME;
		}
		else if (0 == strcmp(argv[i], "-value"))
		{
			i++;
			if (i >= argc)
			{
				cout << "property contents required after -value" << endl;
				return 1;
			}
			sValue = argv[i];
			clArgs |= CL_VALUE;
		}
		else if (0 == strcmp(argv[i], "-sharedsecret"))
		{
			i++;
			if (i >= argc)
			{
				cout  
          << "same password used by the listener and pipeline required after -sharedsecret"
          << endl;
				return 1;
			}
			sSharedSecret = argv[i];
			clArgs |= CL_SECRET;
		}
		else
		{
			cout << "argument not understood: " << argv[i] << endl;
			return 1;
		}

		i++;
	}

	// Make sure that all required args are present and that either all or
	// none of the optional multi instance args are present.
	if (CL_REQUIRED != (clArgs & CL_REQUIRED) ||
			(CL_MULTI != (clArgs & CL_MULTI) && 0 != (clArgs & CL_MULTI)))
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

  try
  {
    //
    // prepare to read the key file
    //

    _bstr_t bstrConfigFile;

    bstrConfigFile = sFilename.c_str(); 

    //
    // Initialize the input propset.
    //
    MTConfigLib::IMTConfigPtr inputConfig(MTPROGID_CONFIG);
    VARIANT_BOOL flag;

    MTConfigLib::IMTConfigPropSetPtr
      inputPropSet = inputConfig->ReadConfiguration(bstrConfigFile, &flag);

    // get the config data ...
    MTConfigLib::IMTConfigPropSetPtr inputDataSet;

    //
    // Initialize the output propset.
    //

    IMTConfigPtr outputConfig("MetraTech.MTConfig.1");
    IMTConfigPropSetPtr outputPropSet;
    IMTConfigPropSetPtr outputDataSet;

    //
    // Now we've got the key and handles to config sets, so
    // let's do it.
    //

    outputPropSet = outputConfig->NewConfiguration("xmlconfig");

    BOOL blnNewKeyAdded = FALSE;

    while (NULL != (inputDataSet = inputPropSet->NextSetWithName("dataset")))
    {
      _bstr_t     bstrName        = inputDataSet->NextStringWithName("name");
      PropValType type;
      _variant_t  vtValue         = inputDataSet->NextVariantWithName("value", &type);
      _bstr_t     bstrInitialized = inputDataSet->NextStringWithName("initialized");

      outputDataSet = outputPropSet->InsertSet("dataset");

      if (_bstr_t(sName.c_str()) == bstrName)
      {
        //
        // this is the one
        //

        if (!EncryptKey(sEncryptionType, sValue, sSharedSecret))
          // error logged in routine
          return 1;

        outputDataSet->InsertProp("name",
                                  MTConfigLib::PROP_TYPE_STRING,
                                  sName.c_str());
        outputDataSet->InsertProp("value",
                                  MTConfigLib::PROP_TYPE_STRING,
                                  sValue.c_str());
        outputDataSet->InsertProp("initialized",
                                  MTConfigLib::PROP_TYPE_STRING,
                                  "true");
        blnNewKeyAdded = TRUE;
      }
      else
      {
        //
        // Not interested in this one, so write back out to file
        //
        outputDataSet->InsertProp("name", MTConfigLib::PROP_TYPE_STRING, bstrName);
        outputDataSet->InsertProp("value", type, vtValue);
        outputDataSet->InsertProp("initialized", MTConfigLib::PROP_TYPE_STRING, bstrInitialized);
      }
    }

    if (!blnNewKeyAdded)
    {
      //
      // The new key was not in the file, so add it now
      //
      if (!EncryptKey(sEncryptionType, sValue, sSharedSecret))
        // error logged in routine
        return 1;

      outputDataSet = outputPropSet->InsertSet("dataset");
      outputDataSet->InsertProp("name",
                                MTConfigLib::PROP_TYPE_STRING,
                                sName.c_str());
      outputDataSet->InsertProp("value",
                                MTConfigLib::PROP_TYPE_STRING,
                                sValue.c_str());
      outputDataSet->InsertProp("initialized",
                                MTConfigLib::PROP_TYPE_STRING,
                                "true");
    }

    outputPropSet->Write((const char *)bstrConfigFile);
	}
	catch (_com_error & err)
	{
		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
		return -1;
	}

  return 0;
}

BOOL
EncryptKey(string & asEncryptionType, string & asData, string & asSecret)
{
	int result;
	string text(asData);

	// Set up the crypto provider and let it allocate a new (temporary)
	// container for this application.
	CMTCryptoProvider provider;
	if (0 != (result = provider.Initialize(TEMP_CONTAINER_NAME, false, true)))
	{
		printf(provider.GetCryptoApiErrorString());
		return FALSE;
	}
	unsigned long ulngVersion;
	if (0 != (result = provider.GetProviderVersion(ulngVersion)))
	{
		printf(provider.GetCryptoApiErrorString());
		return FALSE;
	}
  printf("Version is 0x%x\n", ulngVersion);

	// Create a new session key from the password key material
	CMTCryptoSessionKey sessionKey(&provider);
	if (0 != (result = sessionKey.Initialize(asEncryptionType, asSecret)))
	{
		printf(sessionKey.GetCryptoApiErrorString());
		return FALSE;
	}
	unsigned long keylen;
	if (0 != (result = sessionKey.GetKeyLength(keylen)))
	{
		printf(sessionKey.GetCryptoApiErrorString());
		return FALSE;
	}
  printf("Session key strength in bits is %d\n", keylen);

	// Encrypt and uuencode
	if (0 != (result = sessionKey.Encrypt(text)))
	{
		printf(sessionKey.GetCryptoApiErrorString());
		return FALSE;
	}

	asData = text;

  return TRUE;
}
