/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* $Header: GetProtectedProperty.cpp, 11, 9/11/2002 9:31:01 AM, Alon Becker$
* 
***************************************************************************/

// GetProtectedProperty.cpp : Implementation of CGetProtectedProperty
#include "StdAfx.h"
#include <comdef.h>
#include "COMSecureStore.h"
#include "GetProtectedProperty.h"
#include <MTUtil.h>
#include <time.h>
#include <mtdes.h>
#include <base64.h>
#include <string>
#include <securestore.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CGetProtectedProperty

STDMETHODIMP CGetProtectedProperty::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IGetProtectedProperty
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:          Initialize	
// Arguments:     sEntity   - A system resource using encryption. 
//                            For example, since the TicketAgent runs within 
//                            the context of IIS, this value is listener.
//                sFilename - Name of the configuration file. The format of 
//                            this parameter is a pathname relative to the MetraTech 
//                            config directory. For example, 
//                            ServerAccess\protectedpropertylist.xml.
//                sName     - The property to retrieve.
// Return Value:  None 
// Errors Raised: None 
// Description:   The purpose of this object is to retrieve an encrypted 
//                property stored in a configuration file on disk. The
//                implementation limits each instance of this object to
//                retrieving a single property.
//
//                Below is an example that demonstrates the format of the
//                configuration file. The file may contain multiple 
//                data sets. 
//               
//                The addkey command line tool inserts base64 encoded data 
//                into the value tag for a property specified in the name tag. 
//
//                <xmlconfig>
//                  <dataset>
//                    <name>ticketagent</name>
//                    <value>ticketagent</value>
//                  </dataset>
//                </xmlconfig>
//
//                The securestore getvalue method performs initialization and
//                protected property retrieval. An explicit initialize method
//                is provided here to support future changes to securestore
//                to separate out the initialization.
//
// ----------------------------------------------------------------


STDMETHODIMP CGetProtectedProperty::Initialize(BSTR sEntity, BSTR sFilename, BSTR sName)
{
	mbstrEntity   = _bstr_t(sEntity);
	mbstrFilename = _bstr_t(sFilename);
	mbstrName     = _bstr_t(sName);

  SecureStore ssObject((const char *)mbstrEntity);

  std::string rwcKey = ssObject.GetValue(mbstrFilename, mbstrName);

 if (rwcKey.length() == 0) 	
  {
	 std::wstring errormsg;
    errormsg =  L"A value for ";
    errormsg += mbstrName;
    errormsg += L" in file ";
    errormsg += mbstrFilename;
    errormsg += L" has not been set.";
    return Error(errormsg.c_str());
  }

  mbstrValue = rwcKey.c_str();

  return S_OK;
}

STDMETHODIMP CGetProtectedProperty::InitializeWithContainer(BSTR sContainer, BSTR sEntity, BSTR sFilename, BSTR sName)
{
	_bstr_t bstrContainer   = _bstr_t(sContainer);
	mbstrEntity   = _bstr_t(sEntity);
	mbstrFilename = _bstr_t(sFilename);
	mbstrName     = _bstr_t(sName);

  SecureStore ssObject((const char *)bstrContainer, (const char *)mbstrEntity);

  std::string rwcKey = ssObject.GetValue(mbstrFilename, mbstrName);

 if (rwcKey.length() == 0) 	
  {
	 std::wstring errormsg;
    errormsg =  L"A value for ";
    errormsg += mbstrName;
    errormsg += L" in file ";
    errormsg += mbstrFilename;
    errormsg += L" has not been set.";
    return Error(errormsg.c_str());
  }

  mbstrValue = rwcKey.c_str();

  return S_OK;
}

// ----------------------------------------------------------------
// Name:          GetValue	
// Arguments:     None 
// Return Value:  This method returns the plaintext as a _bstr_t
//                to the caller. 
// Errors Raised: None 
// Description:   This method returns the plaintext to the caller.
// ----------------------------------------------------------------
STDMETHODIMP CGetProtectedProperty::GetValue(BSTR * pValue)
{
  *pValue = mbstrValue.copy();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:          EncryptString	
// Arguments:     src, destination 
// S_OK on success
// Errors Raised: None 
// Description:   encrypts the value with the password protection key
// ----------------------------------------------------------------

STDMETHODIMP CGetProtectedProperty::EncryptString(BSTR src,BSTR* pVal)
{
	ASSERT(src && pVal);
	if(!(src && pVal)) return E_POINTER;

	//  XXX
	//	This method is a complete hack for V1.3 to encrypt passwords.
	//  XXxX
	//
	//	It should be removed post V1.3.

	if(SafeInitCrypto() == 0)
    {
		// encrypt the string and stuff in the output buffer
		std::string aStr = (const char*)_bstr_t(src);

		if(aCrypto->Encrypt(aStr) == 0) {
			_bstr_t aTemp = aStr.c_str();
			*pVal = aTemp.copy();

			if(aCrypto->Decrypt(aStr) == 0) {
				return S_OK;
			}

			return S_OK;
		}
		else {
			const char * errStr = aCrypto->GetCryptoApiErrorString();
			return Error(errStr);
		}
    }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:          DecryptString	
// Arguments:     src, destination 
// S_OK on success
// Errors Raised: None 
// Description:   decrypts the value with the password protection key
// ----------------------------------------------------------------

STDMETHODIMP CGetProtectedProperty::DecryptString(BSTR src,BSTR* pVal)
{
	ASSERT(src && pVal);
	if(!(src && pVal)) return E_POINTER;

  if(SafeInitCrypto() == 0)
  {
		// decrypt the string and stuff in the output buffer
		std::string aStr = (const char*)_bstr_t(src);

		if(aCrypto->Decrypt(aStr) == 0) {
			_bstr_t aTemp = aStr.c_str();
			*pVal = aTemp.copy();

			if(aCrypto->Encrypt(aStr) == 0) {
				return S_OK;
			}
      
			return S_OK;
		}
		else {
			const char * errStr = aCrypto->GetCryptoApiErrorString();
			return Error(errStr);
		}
	}

  return S_OK;
}

int CGetProtectedProperty::SafeInitCrypto()
{
  int result = 0;

  if(aCrypto == NULL)
  {
    aCrypto = new CMTCryptoAPI();

    result = aCrypto->CreateKeys("mt_dbaccess", TRUE, "dbaccess");
	  if (result == 0) {
		  result = aCrypto->Initialize(MetraTech_Security_Crypto::CryptKeyClass_Ticketing, "mt_dbaccess", TRUE, "dbaccess");

      if(result != 0)
      {
			  const char * errStr = aCrypto->GetCryptoApiErrorString();
			  return Error(errStr);
		  }
	  }
	  else {
		  const char * errStr = aCrypto->GetCryptoApiErrorString();
		  return Error(errStr);
	  }
  }

  return result;
}