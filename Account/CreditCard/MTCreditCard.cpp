/**************************************************************************
 * @doc SDKPUB
 *
 * @module |
 *
 * Copyright 1999 by MetraTech Corporation
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
 ***************************************************************************/

#include "StdAfx.h"
#include <mtsdk.h>
#include "CreditCard.h"
#include "MTCreditCard.h"
#include <time.h>

#include <mtprogids.h>
#import "MTConfigLib.tlb"

#import "RCD.tlb"


// Used for debugging only
#define Debugger() __asm { __asm int 3 }

/////////////////////////////////////////////////////////////////////////////
// CMTCreditCard

CMTCreditCard::CMTCreditCard()
{
	// Initialize member variables
	m_ServiceName = DEFAULT_SERVICE_NAME;
	m_MapName = "";
	m_MapNamespace = "";
	m_Action = -1;
	m_Amount = 0.0;
	m_CurrencyCode = DEFAULT_CURRENCY_CODE;
	m_NameOnCard = "";
	m_CardNumber = "";
	m_ExpirationDateMonth = 0;
	m_ExpirationDateYear = 0;
	m_CardType = 0;
	m_FirstName = "";
	m_LastName = "";
	m_Company = "";
	m_Address1 = "";
	m_Address2 = "";
	m_Address3 = "";
	m_City = "";
	m_State = "";
	m_ZipCode = "";
	m_Country = DEFAULT_CREDIT_CARD_COUNTRY;
	m_Phone = "";
	m_UseAVS = TRUE;
	m_NumServers = 0;

	m_ProxyHost = "";
	m_Retries = DEFAULT_HTTP_RETRIES;
	m_Timeout = DEFAULT_HTTP_TIMEOUT;
}

STDMETHODIMP CMTCreditCard::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCreditCard
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCreditCard::get_MapName(BSTR *pVal)
{
	*pVal = (wchar_t *)m_MapName;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_MapName(BSTR newVal)
{
	m_MapName = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_MapNamespace(BSTR *pVal)
{
	*pVal = (wchar_t *)m_MapNamespace;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_MapNamespace(BSTR newVal)
{
	m_MapNamespace = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Action(MTCreditCardAction *pVal)
{
	*pVal = (MTCreditCardAction)m_Action;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Action(MTCreditCardAction newVal)
{
	m_Action = (long)newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Amount(double *pVal)
{
	*pVal = m_Amount;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Amount(double newVal)
{
	m_Amount = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_CurrencyCode(BSTR *pVal)
{
	*pVal = (wchar_t *)m_CurrencyCode;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_CurrencyCode(BSTR newVal)
{
	m_CurrencyCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_NameOnCard(BSTR *pVal)
{
	*pVal = (wchar_t *)m_NameOnCard;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_NameOnCard(BSTR newVal)
{
	m_NameOnCard = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_CardNumber(BSTR *pVal)
{

	*pVal = (wchar_t *)m_CardNumber;
	return S_OK;
}

// This function strips any non numeric characters before storing 
STDMETHODIMP CMTCreditCard::put_CardNumber(BSTR newVal)
{
	// Strip out any non digits...
	wchar_t inBuffer[30];
	wchar_t	outBuffer[30];
	size_t outPos = 0;

	wcscpy(inBuffer, newVal);

	// Loop through string only copying numbers
	for (size_t i = 0; i < wcslen(inBuffer); i++)
	{
		if (iswdigit(inBuffer[i]) != 0)
			outBuffer[outPos++] = inBuffer[i];
	}

	// NULL terminate
	outBuffer[outPos] = _T('\0');

	// Copy to member variable
	m_CardNumber = outBuffer;

	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_ExpirationDateMonth(long *pVal)
{
	*pVal = m_ExpirationDateMonth;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_ExpirationDateMonth(long newVal)
{
	m_ExpirationDateMonth = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_ExpirationDateYear(long *pVal)
{
	*pVal = m_ExpirationDateYear;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_ExpirationDateYear(long newVal)
{
	m_ExpirationDateYear = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_CardType(MTCreditCardType *pVal)
{
	*pVal = (MTCreditCardType) m_CardType;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_CardType(MTCreditCardType newVal)
{
	m_CardType = (long)newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_FirstName(BSTR *pVal)
{
	*pVal = (wchar_t *)m_FirstName;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_FirstName(BSTR newVal)
{
	m_FirstName = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_LastName(BSTR *pVal)
{
	*pVal = (wchar_t *)m_LastName;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_LastName(BSTR newVal)
{
	m_LastName = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Company(BSTR *pVal)
{
	*pVal = (wchar_t *)m_Company;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Company(BSTR newVal)
{
	m_Company = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Address1(BSTR *pVal)
{
	*pVal = (wchar_t *)m_Address1;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Address1(BSTR newVal)
{
	m_Address1 = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Address2(BSTR *pVal)
{
	*pVal = (wchar_t *)m_Address2;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Address2(BSTR newVal)
{
	m_Address2 = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Address3(BSTR *pVal)
{
	*pVal = (wchar_t *)m_Address3;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Address3(BSTR newVal)
{
	m_Address3 = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_City(BSTR *pVal)
{
	*pVal = (wchar_t *)m_City;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_City(BSTR newVal)
{
	m_City = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_State(BSTR *pVal)
{
	*pVal = (wchar_t *)m_State;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_State(BSTR newVal)
{
	m_State = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Country(BSTR *pVal)
{
	*pVal = (wchar_t *)m_Country;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Country(BSTR newVal)
{
	m_Country = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_Phone(BSTR *pVal)
{
	*pVal = (wchar_t *)m_Phone;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_Phone(BSTR newVal)
{
	m_Phone = newVal;
	return S_OK;
}

// This function performs all possible checks that can be done without 
// going to a credit card processing agent for true validation.
STDMETHODIMP CMTCreditCard::Validate(MTCreditCardErrorMsg * success)
{
	time_t lTime;
	struct tm *today;
	MTCreditCardErrorMsg retval = MT_CC_SUCCESS;
	const char * number = m_CardNumber;

	// Steps
	// 1. Check type make sure digits correspond
	// 2. Check checksum
	// 3. Check dates
	// 4. Check AVS fields if true, if so make sure Address1, Zip, and Country are entered

	// Check that prefix matches card type, #digits matches card type
	ValidateTypeAndNumber(&retval);
	if (retval != MT_CC_SUCCESS)
	{
		*success=retval;
		return S_OK;
	}

	// Check for a valid month
	if ((m_ExpirationDateMonth < 1) || (m_ExpirationDateMonth > 12))
	{
		*success = MT_CC_ERROR_INVALID_EXP_DATE;
		return S_OK;
	}

	// Check v. current time to make sure credit card has not expired
	time(&lTime);
	today = localtime( &lTime );

	if (	((today->tm_year + 1900) > m_ExpirationDateYear) || 
			(((today->tm_year + 1900) == m_ExpirationDateYear) && ((today->tm_mon + 1) > m_ExpirationDateMonth))
		)
	{
		*success = MT_CC_ERROR_CARD_EXPIRED;
		return S_OK;
	}

	// If USE AVS is enabled we need address1, zip, and country to verify
	if (m_UseAVS)
	{
		if ((m_Address1.length() < 1) || (m_ZipCode.length() < 1) || (m_Country.length() < 1))
		{
			*success = MT_CC_ERROR_REQUIRED_AVS_FIELD_MISSING;
			return S_OK;
		}
	}

	*success=retval;
	return S_OK;
}

// This function performs all possible checks that can be done without 
// going to a credit card processing agent for true validation.
STDMETHODIMP CMTCreditCard::ValidateTypeAndNumber(MTCreditCardErrorMsg * success)
{
	MTCreditCardErrorMsg retval = MT_CC_SUCCESS;
	const char * number = m_CardNumber;

	// Steps
	// 1. Check type make sure digits correspond
	// 2. Check checksum
	// 3. Check dates
	// 4. Check AVS fields if true, if so make sure Address1, Zip, and Country are entered

	// Check that prefix matches card type, #digits matches card type
	retval = CheckCCFormat(number, m_CardType);
	if (retval != MT_CC_SUCCESS)
	{
		*success=retval;
		return S_OK;
	}

	// Make sure checksum of credit card digits is valid
	retval = CheckCCChecksum(number, strlen(number));
	
	*success=retval;
	return S_OK;
}


STDMETHODIMP CMTCreditCard::Execute(BOOL wait, MTCreditCardErrorMsg * success)
{
	MTCreditCardErrorMsg retval;
	MTMeter * meter;
	MTMeterHTTPConfig * config;
	MTMeterSession * session;

	// Run through local validation first
	Validate(&retval);
	if (retval != MT_CC_SUCCESS)
	{
		*success = retval;
		return S_OK;
	}

	// Create Config/Meter/Session etc...
	const char * mbProxyString = (const char *)m_ProxyHost;
	config = new MTMeterHTTPConfig(mbProxyString);
	config->SetConnectRetries(m_Retries);
	config->SetConnectTimeout(m_Timeout);	
	
	//Add servers to config object
	for (int curServer = 0; curServer < m_NumServers; curServer++)
	{
		// Extract _bstr_t from _variant_t fields
		bstr_t lUserName = (_bstr_t)m_Servers[curServer].UserName;
		bstr_t lPassword = (_bstr_t)m_Servers[curServer].Password;
		bstr_t lServer = (_bstr_t)m_Servers[curServer].serverName;

		// Get char * from bstr_t
		const char * un = lUserName;
		const char * p = lPassword;
		const char * s = lServer;

		// Make SDK Call
		config->AddServer(m_Servers[curServer].Priority,			
								s,
								m_Servers[curServer].PortNumber,
								m_Servers[curServer].Secure,
								un,
								p);
	}

	// Create METER
	meter = new MTMeter(*config);
	
	if (! meter)
	{
		return E_FAIL;
	}


	// Start METER
	if (!meter->Startup())
	{
		MTMeterError * err = meter->GetLastErrorObject();

		if (err)
		{
			// Create buffer to store error message in
			TCHAR errorBuf[ERROR_BUFFER_LEN];
			int errorBufSize = sizeof(errorBuf);

			// Get Error Info from SDK
			err->GetErrorMessage(errorBuf, errorBufSize);
			//Error(errorBuf, 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
			Error("Failure on Startup", 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
			delete err;
		}

		return E_FAIL;
    }


	// CREATE SESSION
	session = meter->CreateSession((const char *)m_ServiceName);

	if (! session)
	{
		return E_FAIL;
	}

	// ADD PROPERTIES
	session->InitProperty("MappingName", (const char *)m_MapName);
	session->InitProperty("MappingNamespace", (const char *)m_MapNamespace);
	session->InitProperty("Action", (int)m_Action);
	session->InitProperty("Amount", m_Amount);
	session->InitProperty("CurrencyCode", (const char *)m_CurrencyCode);
	session->InitProperty("NameOnCard", (const char *)m_NameOnCard);
	session->InitProperty("CardNumber", (const char *)m_CardNumber);
	session->InitProperty("CardType", (int)m_CardType);
	session->InitProperty("UseAVS", (int)m_UseAVS);
	session->InitProperty("FirstName", (const char *)m_FirstName);
	session->InitProperty("LastName", (const char *)m_LastName);
	session->InitProperty("Company", (const char *)m_Company);
	session->InitProperty("Address1", (const char *)m_Address1);
	session->InitProperty("Address2", (const char *)m_Address2);
	session->InitProperty("Address3", (const char *)m_Address3);
	session->InitProperty("City", (const char *)m_City);
	session->InitProperty("State", (const char *)m_State);
	session->InitProperty("Country", (const char *)m_Country);
	session->InitProperty("ZipCode", (const char *)m_ZipCode);
	session->InitProperty("Phone", (const char *)m_Phone);

	// Call Close Function (TODO: Implement the WAIT capablility to tell session to wait until record has been processed by the pipeline
	if (! session->Close())
	{
		MTMeterError * err = session->GetLastErrorObject();

		if (err)
		{
			// Create buffer to store error message in
			TCHAR errorBuf[ERROR_BUFFER_LEN];
			int errorBufSize = sizeof(errorBuf);

			// Get Error Info from SDK
			err->GetErrorMessage(errorBuf, errorBufSize);
			//Error(errorBuf, 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
			Error("Failure on Close", 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
			delete err;
		}

		return E_FAIL;
	}

		// Shutdown METER
	if (!meter->Shutdown())
	{
		MTMeterError * err = meter->GetLastErrorObject();

		if (err)
		{
			// Create buffer to store error message in
			TCHAR errorBuf[ERROR_BUFFER_LEN];
			int errorBufSize = sizeof(errorBuf);

			// Get Error Info from SDK
			err->GetErrorMessage(errorBuf, errorBufSize);
			//Error(errorBuf, 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
			Error("Failure on Shutdown", 0, NULL, GUID_NULL, HRESULT_FROM_WIN32(err->GetErrorCode()));
			delete err;
		}

		return E_FAIL;
    }

	// Free Memory
	delete(meter);
	delete(session);

	*success = MT_CC_SUCCESS;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::AddUserProperty(BSTR Name, VARIANT Value)
{
	// TODO: Add your implementation code here

	return E_NOTIMPL;
}

STDMETHODIMP CMTCreditCard::get_ServiceName(BSTR *pVal)
{
	*pVal = (wchar_t *)m_ServiceName;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_ServiceName(BSTR newVal)
{
	m_ServiceName = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_UseAVS(BOOL *pVal)
{
	*pVal = m_UseAVS;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_UseAVS(BOOL newVal)
{
	m_UseAVS = newVal;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_ZipCode(BSTR *pVal)
{
	*pVal = (wchar_t *)m_ZipCode;
	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_ZipCode(BSTR newVal)
{
	m_ZipCode = newVal;
	return S_OK;
}



MTCreditCardErrorMsg CMTCreditCard::CheckCCChecksum(const char *cpCreditCardNumber, int iCreditCardNumberLen)
{
	int iDigit = 0;
	//BP: CR 10435 fix: increase the size by one so that we can null terminate the string
	char cChar[2];
	int iSum = 0;
	int iWeight = 2;
	int i = 0;
	const char *cpIterator = NULL;
	/*
	** Loop over credit card number, starting at last digit. Take 1st
	** digit, multiply it by 1, add the resultant digits, move to next 
	** digit; multiply by 2, add the result to previous reult - move to next digit -
	** multiply by 1 again - keep going 'til end of number
	*/
	for (i = 0, cpIterator = cpCreditCardNumber + iCreditCardNumberLen - 2; i < iCreditCardNumberLen - 1; cpIterator--, i++) 
	{
		if (isdigit(*cpIterator)) 
		{
			cChar[0] = *cpIterator;
			//BP: CR 10435 fix: null terminate the string
			cChar[1] = '\0';
			iDigit = atoi(cChar);
			iSum += ((iWeight * iDigit) % 10) + ((iWeight * iDigit) / 10);
		}
		else {
			// Non-number found in digits
			return MT_CC_ERROR_NON_NUMERIC_CHARACTER;
		}
		if (iWeight == 2)
			iWeight = 1;
		else
			iWeight = 2;

	}

	/*
	** Having summed all digits - check that the check sum matches to the
	** last - it should be 10 - (calculated sum % 10)
	**
	** Get last digit
	*/
	cChar[0] = *(cpCreditCardNumber + iCreditCardNumberLen - 1);
	iDigit = atoi(cChar);


	/*
	** Perform checksum: Take (iSum + iDigit) % 10 always equals 0
	*/
	if (((iSum + iDigit) % 10) == 0) {
		return MT_CC_SUCCESS;
	}
	else {
		// Checksum doesn't match
		return MT_CC_ERROR_CHECKSUM;
	}
}


//// 
//// FOLLOWING ARE STATIC STRUCTURES USED FOR CREDIT CARD VALIDATION
////		First Field states how many digits to compare
////		Second field is a valid combination of digits
////
//
//// Make sure to set MASTERCARD_LOOKUP_ENTRY_COUNT to proper value when adding entries
//static struct _cc_lookup_map MasterCardLookupMap[MASTERCARD_LOOKUP_ENTRY_COUNT + 1] = 
//{
//    {2, "51"}, 
//    {2,	"52"},
//    {2,	"53"},	
//    {2,	"54"},
//    {2,	"55"},
//    {CC_LAST_ENTRY,	""},	
//};
//
//
//// Make sure to set VISA_LOOKUP_ENTRY_COUNT to proper value when adding entries
//static struct _cc_lookup_map VisaCardLookupMap[VISA_LOOKUP_ENTRY_COUNT + 1] = 
//{
//    {1, "4"}, 
//    {CC_LAST_ENTRY,	""},	
//};
//
//// Make sure to set AMEX_LOOKUP_ENTRY_COUNT to proper value when adding entries
//static struct _cc_lookup_map AMEXCardLookupMap[AMEX_LOOKUP_ENTRY_COUNT + 1] = 
//{
//    {2, "34"}, 
//    {2,	"37"},
//    {CC_LAST_ENTRY,	""},	
//};
//
//// Make sure to set DISCOVER_LOOKUP_ENTRY_COUNT to proper value when adding entries
//static struct _cc_lookup_map DiscoverCardLookupMap[DISCOVER_LOOKUP_ENTRY_COUNT + 1] = 
//{
//    {4, "6011"}, 
//    {CC_LAST_ENTRY,	""},	
//};
//
//// Make sure to set DINERS_LOOKUP_ENTRY_COUNT to proper value when adding entries
//static struct _cc_lookup_map DinersCardLookupMap[DINERS_LOOKUP_ENTRY_COUNT + 1] = 
//{
//  {2, "30"}, 
//  {2,	"36"},
//  {3,	"381"},
//  {3,	"382"},
//	{3,	"383"},
//	{3,	"384"},
//	{3,	"385"},
//	{3,	"386"},
//	{3,	"387"},
//	{3,	"388"},
//  {CC_LAST_ENTRY,	""},	
//};
//
//// Make sure to set OPTIMA_LOOKUP_ENTRY_COUNT to proper value when adding entries
//static struct _cc_lookup_map OptimaCardLookupMap[OPTIMA_LOOKUP_ENTRY_COUNT + 1] = 
//{
//  {4, "3707"}, 
//  {4,	"3717"},
//	{4,	"3727"},
//	{4,	"3737"},
//	{4,	"3747"},
//	{4,	"3757"},
//	{4,	"3767"},
//	{4,	"3777"},
//	{4,	"3787"},
//	{4,	"3797"},
//  {CC_LAST_ENTRY,	""},	
//};
//
//// Make sure to set JCB_LOOKUP_ENTRY_COUNT to proper value when adding entries
//static struct _cc_lookup_map JCBCardLookupMap[JCB_LOOKUP_ENTRY_COUNT + 1] = 
//{
//    {2, "18"}, 
//    {2,	"21"},
//    {CC_LAST_ENTRY,	""},	
//};

STDMETHODIMP CMTCreditCard::AddServer(long priority, BSTR serverName, long Port, BOOL Secure, VARIANT username, VARIANT password)
{
	// Local variables to extract strings from variants
	// NOTE: Only reason variants are used is to allow default arguments from VB 

	// Add to local array
	if (m_NumServers < MT_MAX_SERVERS)
    {
		m_Servers[m_NumServers].Priority = priority;
		m_Servers[m_NumServers].serverName = serverName;
		m_Servers[m_NumServers].PortNumber = Port;
		m_Servers[m_NumServers].Secure = Secure;
		m_Servers[m_NumServers].UserName.Attach(username);
		m_Servers[m_NumServers].Password.Attach(password);
    }
	else
	{
		// Change to another Error message?
		return E_FAIL;
	}

	
	// Increment Server Count
	m_NumServers++;

	return S_OK;
}

MTCreditCardErrorMsg CMTCreditCard::CheckCCFormat(const char *cpCreditCardNumber, int cctype)
{
	BOOL found = FALSE;
  VARIANT_BOOL flag;
  int ccTypeVal, numLength;
  bstr_t prefix;

  MTConfigLib::IMTConfigPtr mConfig;
  MTConfigLib::IMTConfigPropSetPtr creditCardProps, numberProps, numLengths;

  // Create the config reader;
	HRESULT hr = mConfig.CreateInstance(MTPROGID_CONFIG);
  if (SUCCEEDED(hr))
  {
    RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\PaymentServer\\CreditCardValidationRules.xml",VARIANT_TRUE);

		if(aFileList->GetCount() != 0) 
    {
      int index = 0;
      _variant_t aVariant = aFileList->Item[index];
      bstr_t fileName = aVariant;

      // read the configuration file
      MTConfigLib::IMTConfigPropSetPtr propset =
			      mConfig->ReadConfiguration(fileName, &flag);

      // iterate over the credit card type defs in the file to find a match
       while( (creditCardProps = propset->NextSetWithName("CreditCardType")) != NULL && !found )
       {
          ccTypeVal = creditCardProps->NextLongWithName("TypeId");

          if( cctype == ccTypeVal )
          {
            // Found a matching type, now iterate over the number types for the credit card type
            while( (numberProps = creditCardProps->NextSetWithName("CreditCardNumber")) != NULL && !found )
            {
              prefix = numberProps->NextStringWithName("Prefix");

              // check to see if the number has the prefix
              if( strncmp( (char*)bstr_t(prefix), cpCreditCardNumber, strlen((char*)bstr_t(prefix)) ) == 0 )
              {
                // prefix matches, so iterate over allowable number lengths to complete validation
                numLengths = numberProps->NextSetWithName("Lengths");

                if( numLengths != NULL )
                {
                  BOOL bContinue = true;
                  do
                  {
                    try
                    {
                      numLength = numLengths->NextLongWithName("NumberLength");

                      if( numLength == strlen(cpCreditCardNumber) )
                      {
                        // okay, we've found a matching type, prefix and have validated the lenghth...return success
                        found = true;
                      }
                    }
                    catch(...)
                    {
                      bContinue = false;
                    }
                  }
                  while(bContinue && !found );
                }
              }            
            }
          }
       }
    }
  }
	if (! found)
	{
		return MT_CC_ERROR_CARD_TYPE_MISMATCH;
	}

	return MT_CC_SUCCESS;
}

STDMETHODIMP CMTCreditCard::get_HTTPTimeout(long *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_HTTPTimeout(long newVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_HTTPRetries(long *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_HTTPRetries(long newVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_HTTPProxyHostname(BSTR *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_HTTPProxyHostname(BSTR newVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCreditCard::get_ExpDateFormat(MTExpDateFormat *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCreditCard::put_ExpDateFormat(MTExpDateFormat newVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}
