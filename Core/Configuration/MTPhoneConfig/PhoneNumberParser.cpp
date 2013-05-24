// PhoneNumberParser.cpp : Implementation of CPhoneNumberParser
#include "StdAfx.h"
#include <comdef.h>

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#import	<MTConfigLib.tlb> 
using namespace MTConfigLib;

#include "PhoneLookup.h"
#include "PhoneNumberParser.h"
#include <loggerconfig.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <string.h>
#include <mtcomerr.h>

#include <ConfigDir.h>

/////////////////////////////////////////////////////////////////////////////
// CPhoneNumberParser
CPhoneNumberParser::CPhoneNumberParser()
				: mpDeviceTable(NULL), mpCountriesTable(NULL)
{
	// initialize the logger
	LoggerConfigReader configReader;
	mLogger.Init (configReader.ReadConfiguration("Core"), CORE_TAG);
  
  mLoadFromDatabase = false; //
  
  // Initialize arrays
  for (int i=0; i<LargestExchangeCode; i++)
  {
    mpExchangeCodeHashTable[i] = NULL;
  }
  for (int i=0; i<LargestCountryCode; i++)
  {
    mpCountryCodeHashTable[i] = NULL;
  }
  for (int i=0; i<LargestCountryCode; i++)
  {
    mpRegionCodeHashTable[i] = NULL;
  }
}

CPhoneNumberParser::~CPhoneNumberParser()	

{
	if (mpDeviceTable)
		mpDeviceTable->Release();
			
	for (int i=0; i < LargestCountryCode; i++)
	{
		if (mpCountryCodeHashTable[i]) 
		{
			long L = mpCountryCodeHashTable[i]->Release();
			ASSERT (L = 1);
		}

		if (mpRegionCodeHashTable[i])
		{
			ClearRegionsHashTable (mpRegionCodeHashTable[i]);
			delete mpRegionCodeHashTable[i];
		}
	}
	
	if (mpCountriesTable)
		mpCountriesTable->Release();
};


STDMETHODIMP CPhoneNumberParser::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IPhoneNumberParser,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CPhoneNumberParser::get_OriginatorCountryName(BSTR * pVal)
{
	*pVal = mOriginatorCountryName.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::put_OriginatorCountryName(BSTR newVal)
{
	long lPos;
	IMTCountry * pCountry;
	HRESULT hr;

	// Find and Validate the country code
	hr = mpCountriesTable->FindByCountryName (newVal, &lPos);
	if (FAILED(hr))
	{
		_bstr_t msg = "Unable to locate country information for ";
		msg += newVal;
		Error ((char*)msg);
		return E_INVALIDARG;
	}

	// Get the definition
	hr = mpCountriesTable->get_Item (lPos, (IDispatch **)&pCountry);
	if (FAILED(hr))
		return hr;
	
	// set the country name
	mOriginatorCountryName = newVal;

	// set the country code
	BSTR bstrTemp;
	hr = pCountry->get_CountryCode(&bstrTemp);
	if (FAILED(hr))
		return hr;
	mOriginatorCountryCode = bstrTemp;
	::SysFreeString(bstrTemp);

	// set the international access code for this country
	hr = pCountry->get_InternationalAccessCode(&bstrTemp);
	if (FAILED(hr))
		return hr;
	mOriginatorInternationalAccessCode = bstrTemp;
	::SysFreeString(bstrTemp);
	
	// set the national access code for this country
	hr = pCountry->get_NationalAccessCode(&bstrTemp);
	if (FAILED(hr))
		return hr;
	mOriginatorNationalAccessCode = bstrTemp;
	::SysFreeString(bstrTemp);
	
	// Does this country own the country code
	BOOL bVal;
	hr = pCountry->get_Primary(&bVal);
	if (FAILED(hr))
		return hr;
	mPrimaryCountry = bVal;

	pCountry->Release();

	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_OriginatorLineAccessCode(BSTR * pVal)
{
	*pVal = mOriginatorLineAccessCode.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::put_OriginatorLineAccessCode(BSTR newVal)
{	
	mOriginatorLineAccessCode = newVal;
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_OriginatorNationalCode(BSTR * pVal)
{
	*pVal = mOriginatorNationalCode.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::put_OriginatorNationalCode(BSTR newVal)
{
	mOriginatorNationalCode = newVal;
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_DialedNumber(BSTR * pVal)
{
	*pVal = mDialedNumber.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::put_DialedNumber(BSTR newVal)
{
	mDialedNumber = newVal;

	// init the output properties in case it doesn't work
	mCountryCode = L"";
	mNationalCode = L"";
	mLocalNumber = L"";
	mCountryName = L"";
	mRegionDescription = L"";
	mLocalityDescription = L"";
	mLocalityCode = L"";
	mInternational = FALSE;
	mTollFree = FALSE;

	return ParseNumber();
}

STDMETHODIMP CPhoneNumberParser::get_CountryCode(BSTR * pVal)
{
	*pVal = mCountryCode.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_NationalCode(BSTR * pVal)
{
	*pVal = mNationalCode.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_LocalNumber(BSTR * pVal)
{
	*pVal = mLocalNumber.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_CountryName(BSTR * pVal)
{

	*pVal = mCountryName.copy();
	return S_OK;
}


STDMETHODIMP CPhoneNumberParser::get_RegionDescription(BSTR * pVal)
{
	*pVal = mRegionDescription.copy();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_LocalityDescription(BSTR * pVal)
{
	*pVal = mLocalityDescription.copy();
	return S_OK;
}


STDMETHODIMP CPhoneNumberParser::get_CanonicalFormat(BSTR * pVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CPhoneNumberParser::get_Proximity(Proximity * pVal)
{
	*pVal = mProximity;
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::BuildCountryHashTable(IMTEnumCountries * pCountries)

{
	// Init the table
	for (int i=0; i < LargestCountryCode; i++)
	{
		mpCountryCodeHashTable[i] = 0;
		mpRegionCodeHashTable[i] = 0;
	}

	// Stuff all the country objects in the table
	long Count;
	HRESULT hr;
	hr = pCountries->get_Count (&Count);
  mLogger.LogVarArgs (LOG_DEBUG, "BuildCountryHashTable for <%d> countries",Count);
	for (i=1 ; i <= Count ; i++)
	{
		IDispatch * pDisp = NULL;
		IMTCountry * pCountry = NULL;
		hr = pCountries->get_Item (i, &pDisp);
		if (FAILED(hr))
    {
      mLogger.LogVarArgs (LOG_ERROR, "BuildCountryHashTable: Unable to get country item <%d>",i);
			return hr;
    }
		BSTR bstrTemp;
		pCountry = (IMTCountry *)pDisp;

		BOOL bVal;
		hr = pCountry->get_Primary(&bVal);
		if (FAILED(hr))
			return hr;
				
		// skip non-primary countries
		// ie they don't own the country code (Canada..etc)
		if (!bVal)
		{
			pCountry->Release();
			continue;
		}

		hr = pCountry->get_CountryCode(&bstrTemp);
		if (FAILED(hr))
			return hr;
		bstr_t bstrCode =  bstrTemp;
		::SysFreeString(bstrTemp);
			
		char * szCode = bstrCode;
		long lCode = atoi (szCode);
		if (lCode > 0 && lCode < LargestCountryCode)
			mpCountryCodeHashTable[lCode] = pCountry;
		else
			mLogger.LogVarArgs (LOG_WARNING, L"Country code <%d> is too large for table", lCode);

    mLogger.LogVarArgs (LOG_DEBUG, "BuildCountryHashTable: Done reading country code <%s>",(char*)bstrCode);

	}

  mLogger.LogVarArgs (LOG_DEBUG, "BuildCountryHashTable: Done");
 
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::BuildRegionHashTable(IMTEnumRegions * pRegions, RegionCodeHashTable * pTable)

{
	// Init the table
	for (int i=0; i < LargestRegionCode; i++)
		pTable->Regions[i] = 0;

	// Stuff in all the region objects
	long Count;
	HRESULT hr;
	hr = pRegions->get_Count (&Count);
	for (i=1 ; i <= Count ; i++)
	{
		IMTRegion * pRegion;
		hr = pRegions->get_Item (i, (IDispatch**)&pRegion);
		if (FAILED(hr))
			return hr;
		BSTR bstrTemp;
		hr = pRegion->get_DestinationCode(&bstrTemp);
		if (FAILED(hr))
			return hr;
		
		bstr_t bstrCode =  bstrTemp;	
		::SysFreeString(bstrTemp);

		char * szCode = bstrCode;
		long lCode = atoi (szCode);

		if (lCode > 0 && lCode < LargestRegionCode)
			pTable->Regions[lCode] = pRegion;
		else
			mLogger.LogVarArgs (LOG_WARNING, L"Region code <%d> is too large for table", lCode);
	}

	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::ParseNumber()
{
	HRESULT hr;
	mInternational = FALSE;
	mTollFree = FALSE;

	// convert to a more convenient format
	_bstr_t bstrDialedNumber = mDialedNumber;

	// check for blank number
	if (!bstrDialedNumber.length())
	{
		Error ("Phone number is blank");
		return E_INVALIDARG; 
	}
		
	char * szDialedNumber = bstrDialedNumber;
	std::string cstrDialedNumber = szDialedNumber;


	// strip off the control characters
	RemoveControlChars(cstrDialedNumber);

	int sLen = cstrDialedNumber.length();
	for (int i=0 ; i < sLen; i++)
		if (!isdigit(cstrDialedNumber[i]))
			return Error("Phone number contains invalid digit(s)",
									 IID_IPhoneNumberParser, E_INVALIDARG);


	const char * szTemp = cstrDialedNumber.c_str();

	// Remove any line access codes
	// support a sequence just to be nice
	_bstr_t bstrLineAccess = mOriginatorLineAccessCode;
	char * szLineAccess = bstrLineAccess;
	std::string cstrLineAccess = szLineAccess;
	if (cstrLineAccess.compare(cstrDialedNumber.substr(0, min(cstrDialedNumber.length(), cstrLineAccess.length()))) == 0)
		cstrDialedNumber.erase (0, cstrLineAccess.length());

	// determine proximity of call
	mProximity = Proximity_Unknown;
	
	// Look for the international prefix
	_bstr_t bstrIntPrefix = mOriginatorInternationalAccessCode;
	char * szIntPrefix = bstrIntPrefix;
	std::string cstrIntPrefix = szIntPrefix;
	//if (cstrDialedNumber(0, min(cstrDialedNumber.length(),cstrIntPrefix.length())) == cstrIntPrefix)
	if (cstrIntPrefix.compare(cstrDialedNumber.substr(0, min(cstrDialedNumber.length(), cstrIntPrefix.length()))) == 0)
	{
		cstrDialedNumber.erase (0, cstrIntPrefix.length());
		mProximity = Proximity_International;
	}

	// number is in canonical format
	//if (cstrDialedNumber(0, min(cstrDialedNumber.length(),1)) == "+")
	if (cstrDialedNumber.substr(0, min(cstrDialedNumber.length(), 1)).compare("+") == 0)
	{
		cstrDialedNumber.erase (0, 1);
		mProximity = Proximity_International;
	}

	// determine the country
	IMTCountry * pCountry = NULL;
	if (mProximity == Proximity_International)
	{
		int Digits = min (MaxCountryDigits, cstrDialedNumber.length()); 
		for (int j=1; j <= Digits; j++)
		{
			std::string cstrTest = cstrDialedNumber.substr(0,j);
			const char * szCode = cstrTest.c_str();
			long lCode = atoi (szCode);
			if (NULL != (pCountry = mpCountryCodeHashTable[lCode]))
			{
				cstrDialedNumber.erase (0, j);
				break;
			}
		}	
		// ToDo:
		// handle missing country codes better
		if (pCountry == NULL)
		{
			Error ("Unable to determine country");
			return E_FAIL;
		}

		// set the ouput name and country code
		BSTR bstrName;
		hr = pCountry->get_Name(&bstrName); 
		mCountryName = bstrName;
		::SysFreeString(bstrName);

		BSTR bstrCountryCode;
		hr = pCountry->get_CountryCode(&bstrCountryCode); 
		mCountryCode = bstrCountryCode;
		::SysFreeString(bstrCountryCode);

	}
	else
	{	// same as we are dialing from
		mCountryName = mOriginatorCountryName;
		mCountryCode = mOriginatorCountryCode;
	}

	
	mNationalNumber = cstrDialedNumber.c_str();
			
	// Look for the national access code 
	// international calls won't have one
	if (mProximity != Proximity_International)
	{
		_bstr_t bstrNatPrefix = mOriginatorNationalAccessCode;
		char * szNatPrefix = bstrNatPrefix;
		std::string cstrNatPrefix = szNatPrefix;
		//if (cstrDialedNumber(0, min(cstrDialedNumber.length(), cstrNatPrefix.length())) == cstrNatPrefix)
		if(0 == cstrNatPrefix.compare(cstrDialedNumber.substr(0, min(cstrDialedNumber.length(), cstrNatPrefix.length()))))
		{
			cstrDialedNumber.erase (0, cstrNatPrefix.length());
			mProximity = Proximity_National;
			mNationalNumber = cstrDialedNumber.c_str();
		}
	}
	
	// Load and Determine the region	.
	IMTEnumRegions * pRegions = NULL;
	IMTRegion * pRegion = NULL;

	int Digits = min (MaxRegionDigits, cstrDialedNumber.length()); 
	for (int j=1; j <= Digits; j++)
	{
		std::string cstrTest = cstrDialedNumber.substr(0,j);
		if (NULL != (pRegion = GetCountryRegion (mCountryCode, (char*)cstrTest.c_str())))
		{
			cstrDialedNumber.erase (0, j);
			mProximity = Proximity_National;
			break;
		}
	}		

	// check if just a local call
	if (mProximity == Proximity_Unknown)
	{
		// Default to local region
		_bstr_t bstrTemp = mOriginatorNationalCode;
		const char * szCode = bstrTemp;
		pRegion = GetCountryRegion (mCountryCode, (char*)szCode);
		mNationalCode = bstrTemp;
//		mNationalNumber = bstrTemp + cstrDialedNumber;
	}

	IMTExchange *pExchange = NULL;
	IMTEnumExchanges * pExchanges = NULL;

	// It's acceptable not to have a region
	if (pRegion != NULL)		
	{
		BSTR bstrName;
		hr = pRegion->get_CountryName(&bstrName); 
		mCountryName = bstrName;
		::SysFreeString(bstrName);

		
		BSTR bstrDesc;
		hr = pRegion->get_Description(&bstrDesc); 
		mRegionDescription = bstrDesc;
		::SysFreeString(bstrDesc);

		BSTR bstrRegionCode;
		hr = pRegion->get_DestinationCode(&bstrRegionCode); 
		mNationalCode = bstrRegionCode;
		::SysFreeString(bstrRegionCode);

		// this bVal should override the mInternational only in the
		// affirmative
		BOOL bVal;
		hr = pRegion->get_International(&bVal);

		// If we're a non-primary country we need to invert
		// the international flag
		if (!mPrimaryCountry)
		{
			bVal = !bVal;
		}

		// set the international flag
//		if (bVal)
//		  mInternational = TRUE;
		hr = pRegion->get_TollFree(&mTollFree);

		hr = GetExchangesForRegion (pRegion, (LPDISPATCH*)&pExchanges);
		if (SUCCEEDED(hr))
		{
			BuildExchangeHashTable(pExchanges);
				int Digits = min (MaxExchangeDigits, cstrDialedNumber.length()); 
			for (int j=1; j <= Digits; j++)
			{
				std::string cstrTest = cstrDialedNumber.substr(0,j);
				const char * szCode = cstrTest.c_str();
				long lCode = atoi (szCode);
				if (NULL != (pExchange = mpExchangeCodeHashTable[lCode]))
				{
					cstrDialedNumber.erase (0, j);
					break;
				}
			}		
		}
	}
	else // no region
	{
		// Missing regions belong to the country code owner
		if (!mPrimaryCountry)
		{
			IMTCountry * pOwner = NULL;
			//mInternational = TRUE;
			hr = mpCountriesTable->GetCountryCodeOwner (mCountryCode, &pOwner);
			BSTR bstrTemp;
			hr = pOwner->get_Name (&bstrTemp);
			mCountryName = bstrTemp;
			::SysFreeString(bstrTemp);

			if (pOwner)
				pOwner->Release();
		}
	}

	if (pExchange != NULL)
	{
		BSTR bstrTemp;
		pExchange->get_Description (&bstrTemp);
		mLocalityDescription = bstrTemp;
		::SysFreeString(bstrTemp);
	}
	

//	if (pRegions)
//	{
//		ClearRegionsHashTable();
//		pRegions->Release();
//	}

	if (pExchanges)
	{
		ClearExchangesHashTable();
		pExchanges->Release();
	}

	mInternational = (_bstr_t)mOriginatorCountryName != (_bstr_t)mCountryName;
	return PostProcess();
}

STDMETHODIMP CPhoneNumberParser::Initialize(BSTR bstrDeviceFile, BSTR bstrCountryFile)
{
	return E_NOTIMPL;
}

STDMETHODIMP CPhoneNumberParser::get_Bridges(IDispatch ** pVal)
{
	*pVal = mpDeviceTable;
	(*pVal)->AddRef();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::put_Bridges(IDispatch * newVal)
{
	if (mpDeviceTable)
		mpDeviceTable->Release();

	mpDeviceTable = (IMTEnumPhoneDevices*)newVal;
	mpDeviceTable->AddRef();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_Countries(LPDISPATCH * pVal)
{
	*pVal = mpCountriesTable;
	(*pVal)->AddRef();
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::put_Countries(LPDISPATCH newVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP CPhoneNumberParser::GetRegionsByCountryName(BSTR bstrCountryName, LPDISPATCH * pRegions)
{
	long Idx;
	IMTEnumRegions * pEnumRegions;

	*pRegions = NULL;

	HRESULT hr = CoCreateInstance (CLSID_MTEnumRegions, NULL, 
									CLSCTX_SERVER, IID_IMTEnumRegions, (void **)pRegions);
	if (FAILED(hr))
	{
		ErrorObject Err (hr, ERROR_MODULE, ERROR_LINE, 
				"PhoneNumberParser::GetRegionsByCountryName");
		mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		mLogger.LogThis (LOG_ERROR, L"Could not create EnumRegions object");
		return hr;
	}

  if (!mLoadFromDatabase)
  {
	  hr = mpCountriesTable->FindByCountryName (bstrCountryName, &Idx);
	  if (Idx)
	  {	
		  IMTCountry * pCountry;
		  LPDISPATCH pDispatch;

		  hr = mpCountriesTable->get_Item(Idx, &pDispatch);
		  if (FAILED(hr))
			  return hr;

		  pCountry = (IMTCountry *)pDispatch;
  	
		  BSTR bRegionFile;
		  hr = pCountry->get_NationalCodeTable(&bRegionFile);
		  pEnumRegions = (IMTEnumRegions *)*pRegions;
  	
		  pCountry->Release();

		  _bstr_t RelativePath = mPath;
		  _bstr_t bstrRegionFile(bRegionFile,false);
		  RelativePath += bstrRegionFile;
		  if ((_bstr_t)bstrRegionFile != (_bstr_t)"")
		  {
			  try 
			  {
				  hr = pEnumRegions->Read (mHostName, RelativePath);
				  if (FAILED(hr))
				  return hr;
			  }
			  catch (_com_error Error)
			  {
				  ErrorObject Err (CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
						  "PhoneNumberParser::Get RegionsByCountry");
				  mLogger.LogErrorObject(LOG_ERROR, &Err) ;
				  mLogger.LogVarArgs (LOG_ERROR, "Unable to read configuration file <%s> from host <%s>.", 
					  (char*)RelativePath, (char*)(_bstr_t)mHostName);
				  return Error.Error();	
			  }
		  }
    }
	}
  else
  {
    try 
	  {
 		  pEnumRegions = (IMTEnumRegions *)*pRegions;
		  mLogger.LogVarArgs (LOG_DEBUG, "About to read regions configuration from database for country <%s>", (char*)(_bstr_t)bstrCountryName);
		  hr = pEnumRegions->ReadFromDatabase(bstrCountryName);
		  if (FAILED(hr))
		  return hr;
 		  mLogger.LogVarArgs (LOG_DEBUG, "Done reading regions configuration from database for country <%s>", (char*)(_bstr_t)bstrCountryName);

	  }
	  catch (_com_error Error)
	  {
		  ErrorObject Err (CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
				  "PhoneNumberParser::Get RegionsByCountry");
		  mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		  mLogger.LogVarArgs (LOG_ERROR, "Unable to read configuration from database for country <%s>.", 
			  (char*)(_bstr_t)bstrCountryName);
		  return Error.Error();	
	  }

  }
	
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::Read(BSTR bstrHostName, BSTR bstrPath, BSTR bstrFileName)
{
	IMTConfigPtr pConfig;
	IMTConfigPropSetPtr pProp;
	VARIANT_BOOL bChkSum=false;
	VARIANT_BOOL bSecure=false;
	HRESULT hr;
	std::string cstrTemp;

  //Quick hack to use hostname as way to set underlying object to load from database
  //If hostname is 'DB' then use the database for loading some of the configuration... then consider hostname to be the same as ""
	if (_bstr_t(bstrHostName) == (_bstr_t)"DB")
  {
    mLoadFromDatabase = true;
    bstrHostName = _bstr_t("");
  }

	mHostName = bstrHostName;
	
	mPath = "";
	if (mHostName == (_bstr_t)"")
		if (GetMTConfigDir (cstrTemp))
			mPath = (char *)cstrTemp.c_str();
	mPath += bstrPath;
	mPath += L"\\";

	_bstr_t RelativePath;
	RelativePath = mPath;
	RelativePath += bstrFileName;
	_bstr_t bstrDeviceTable;
	_bstr_t	bstrCountryTable;

	mLogger.LogVarArgs (LOG_INFO, "Reading configuration file <%s> from host <%s>.", 
						(char*)RelativePath, (char *)(_bstr_t)bstrHostName);
	try 
	{
		pConfig.CreateInstance("MetraTech.MTConfig.1", NULL, CLSCTX_INPROC_SERVER);

		if (mHostName != (_bstr_t)"")
			pProp = pConfig->ReadConfigurationFromHost (bstrHostName, RelativePath, bSecure, &bChkSum);
		else
			pProp = pConfig->ReadConfiguration (RelativePath, &bChkSum);


		IMTConfigPropSetPtr Tables = pProp->NextSetWithName(OLESTR("tables"));

		// Get the table names
		bstrDeviceTable  = Tables->NextStringWithName("devices");
		bstrCountryTable = Tables->NextStringWithName("countries");
	}
	catch (_com_error Error)
	{
		HRESULT nRetVal = CORE_ERR_NO_PROP_SET ; 
		ErrorObject Err (CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
				"PhoneNumberParser::Read");
		mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		mLogger.LogVarArgs (LOG_ERROR, "Unable to read configuration file <%s> from host <%s>.", 
					(char*)RelativePath, (char*)(_bstr_t)bstrHostName);
		throw Error;	
	}

	
	hr = CoCreateInstance (CLSID_MTEnumPhoneDevices, NULL, 
									CLSCTX_SERVER, IID_IMTEnumPhoneDevices, (void **)&mpDeviceTable);
	if (FAILED(hr))
	{
		ErrorObject Err (hr, ERROR_MODULE, ERROR_LINE, 
				"PhoneNumberParser::Read");
		mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		mLogger.LogThis (LOG_ERROR, L"Could not create EnumPhoneDevice object");
		return hr;
	}

  if (!mLoadFromDatabase)
  {
	  RelativePath = mPath;
	  RelativePath += bstrDeviceTable;
	  hr = mpDeviceTable->Read (bstrHostName, RelativePath);
	  if (FAILED(hr))
		  return hr;
  }
  else
  {
    mLogger.LogVarArgs (LOG_DEBUG, "About to read device table configuration from database");
    hr = mpDeviceTable->ReadFromDatabase();
    mLogger.LogVarArgs (LOG_DEBUG, "Done reading device table configuration from database");
	  if (FAILED(hr))
		  return hr;
  }


	hr = CoCreateInstance (CLSID_MTEnumCountries, NULL, 
									CLSCTX_SERVER, IID_IMTEnumCountries, (void **)&mpCountriesTable);
	if (FAILED(hr))
	{
		ErrorObject Err (hr, ERROR_MODULE, ERROR_LINE, 
				"PhoneNumberParser::Read");
		mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		mLogger.LogThis (LOG_ERROR, L"Could not create EnumCountries object");
		return hr;
	}

  if (!mLoadFromDatabase)
  {
	  RelativePath = mPath;
	  RelativePath += bstrCountryTable;
    mLogger.LogVarArgs (LOG_DEBUG, "About to read country configuration from file");
	  hr = mpCountriesTable->Read (bstrHostName, RelativePath);
    mLogger.LogVarArgs (LOG_DEBUG, "Done reading country table configuration from file");
	  if (FAILED(hr))
	  {
		  ErrorObject Err (hr, ERROR_MODULE, ERROR_LINE, 
				  "PhoneNumberParser::Read");
		  mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		  mLogger.LogThis (LOG_ERROR, L"Could not read countries");
		  return hr;
	  }
  }
  else
  {
    mLogger.LogVarArgs (LOG_DEBUG, "Done reading country table configuration from database");
    hr = mpCountriesTable->ReadFromDatabase();
    mLogger.LogVarArgs (LOG_DEBUG, "Done reading country table configuration from database");
	  if (FAILED(hr))
	  {
		  ErrorObject Err (hr, ERROR_MODULE, ERROR_LINE, 
				  "PhoneNumberParser::Read");
		  mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		  mLogger.LogThis (LOG_ERROR, L"Could not read countries from database");
		  return hr;
	  }
  }

	BuildCountryHashTable (mpCountriesTable);	

	return hr;
}

STDMETHODIMP CPhoneNumberParser::Write()
{
	// For now the only thing you can save is the device table
	HRESULT hr = mpDeviceTable->Write();
	return hr;
}

void CPhoneNumberParser::RemoveControlChars(std::string & cstrDialedNumber)
{
	std::string cstrTemp;

	cstrTemp = cstrDialedNumber;
	cstrDialedNumber = "";
	int sLen = cstrTemp.length();
	for (int i=0 ; i < sLen; i++)
		//if (cstrControlChars.index(cstrTemp(i)) == RW_NPOS)
		if(strchr(cstrControlChars.c_str(), cstrTemp[i]) == NULL)
			cstrDialedNumber += cstrTemp[i];

}

STDMETHODIMP CPhoneNumberParser::get_International(VARIANT_BOOL * pVal)
{
	*pVal = mInternational;
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_TollFree(BOOL * pVal)
{
	*pVal = mTollFree;
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::SetEffectiveDevice(BSTR bstrDeviceName)
{
	// Reusing the same bridge
	if (mDeviceName == (_bstr_t)bstrDeviceName && mDeviceName != (_bstr_t)L"")
		return S_OK;

	// Set all the properties based on this device
	IMTPhoneDevice * pDevice = NULL;
	HRESULT hr = mpDeviceTable->FindDeviceByName (bstrDeviceName, (IDispatch **)&pDevice);
	if (FAILED(hr))
	{
		//ErrorObject Err (hr, ERROR_MODULE, ERROR_LINE, 
		//		"PhoneNumberParser::SetEffectiveDevice");
		//mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		char LogBuf[512];
		_bstr_t DeviceName = bstrDeviceName;
		sprintf(LogBuf, "Could not locate device %s", (const char *)DeviceName);
		mLogger.LogVarArgs (LOG_ERROR, LogBuf);
		return Error(LogBuf, IID_IPhoneNumberParser, hr);
	}

	// set the country name
	BSTR bstrTemp;
	hr = pDevice->get_CountryName (&bstrTemp);
	if (FAILED(hr))
		return hr;

	// only have to do this if it's changed
	if (mOriginatorCountryName != (_bstr_t)bstrTemp)
	{
		hr = put_OriginatorCountryName (bstrTemp);	
		if (FAILED(hr))
			return hr;	
	}

	::SysFreeString(bstrTemp);

	// set the line access code
	hr = pDevice->get_LineAccessCode (&bstrTemp);
	if (FAILED(hr))
		return hr;
	hr = put_OriginatorLineAccessCode (bstrTemp);	
	if (FAILED(hr))
		return hr;

	::SysFreeString(bstrTemp);

	// set area code
	hr = pDevice->get_NationalDestinationCode (&bstrTemp);
	if (FAILED(hr))
		return hr;
	hr = put_OriginatorNationalCode (bstrTemp);	
	if (FAILED(hr))
		return hr;

	::SysFreeString(bstrTemp);

	pDevice->Release();

	// Save the device name
	mDeviceName = bstrDeviceName;
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::ClearRegionsHashTable(RegionCodeHashTable * pTable)
{
	// Clear the table
	for (int i=0; i < LargestRegionCode; i++)
		if (pTable->Regions[i])
			pTable->Regions[i]->Release();

	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::ClearExchangesHashTable()
{
	// Clear the table
	for (int i=0; i < LargestExchangeCode; i++)
		if (mpExchangeCodeHashTable[i])
			mpExchangeCodeHashTable[i]->Release();

	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::BuildExchangeHashTable(IMTEnumExchanges * pExchanges)
{

	// Init the table
	for (int i=0; i < LargestExchangeCode; i++)
		mpExchangeCodeHashTable[i] = 0;

	// Stuff in all the region objects
	long Count;
	HRESULT hr;
	hr = pExchanges->get_Count (&Count);
	for (i=1 ; i <= Count ; i++)
	{
		IMTExchange * pExchange;
		hr = pExchanges->get_Item (i, (IDispatch**)&pExchange);
		if (FAILED(hr))
			return hr;
		BSTR bstrTemp;
		hr = pExchange->get_Code(&bstrTemp);
		if (FAILED(hr))
			return hr;
		
		bstr_t bstrCode(bstrTemp,false); // take ownership	
		char * szCode = bstrCode;
		long lCode = atoi (szCode);

		if (lCode > 0 && lCode < LargestRegionCode)
			mpExchangeCodeHashTable[lCode] = pExchange;
		// ToDO:handle region code overflow
		else
			mLogger.LogVarArgs (LOG_WARNING, L"Exchange <%d> is too large for table", lCode);

	}

	return S_OK;

}

STDMETHODIMP CPhoneNumberParser::GetExchangesForRegion(IMTRegion * pRegion, LPDISPATCH * pExchanges)
{
	IMTEnumExchanges * pEnumExchanges;

	*pExchanges = NULL;

	HRESULT hr = CoCreateInstance (CLSID_MTEnumExchanges, NULL, 
									CLSCTX_SERVER, IID_IMTEnumExchanges, (void **)pExchanges);
	if (FAILED(hr))
	{
		ErrorObject Err (hr, ERROR_MODULE, ERROR_LINE, 
				"PhoneNumberParser::GetExchangesForRegion");
		mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		mLogger.LogThis (LOG_ERROR, L"Could not create MTEnumExchanges object");
		return hr;
	}
	
	
	BSTR bstrExchangeFile;
	hr = pRegion->get_LocalCodeTable(&bstrExchangeFile);
	if (FAILED(hr))
		return hr;
	_bstr_t aBstrLocalCodeTable(bstrExchangeFile,false);
	
	pEnumExchanges = (IMTEnumExchanges *)*pExchanges;
	
	_bstr_t RelativePath = mPath;
	RelativePath += aBstrLocalCodeTable;
	if (aBstrLocalCodeTable != (_bstr_t)"")
	{
		try
		{
			hr = pEnumExchanges->Read (mHostName, RelativePath);
			if (FAILED(hr))
				return hr;	
		}
		catch (_com_error Error)
		{
			ErrorObject Err (CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
					"PhoneNumberParser::GetExchangesForRegion");
			mLogger.LogErrorObject(LOG_ERROR, &Err) ;
			mLogger.LogVarArgs (LOG_ERROR, "Unable to read configuration file <%s> from host <%s>.", 
					(char*)RelativePath, (char*)(_bstr_t)mHostName);
			return Error.Error();	
		}
	}

	
	return S_OK;
}

STDMETHODIMP CPhoneNumberParser::get_LocalityCode(BSTR *pVal)
{
	*pVal = mLocalityCode.copy();	
	return S_OK;
}

HRESULT CPhoneNumberParser::PostProcess()
{
	std::wstring wstrNationalNumber, wstrTemp;

	_bstr_t	bstrTemp;
	
	wstrNationalNumber = mNationalNumber;

	// process fixed format national numbers
	// we should probably generalize this but the current
	// requirement is for US parsing only
	if (mCountryCode == (_bstr_t)"1")
	{
		if (wstrNationalNumber.length() < 7)
			return Error("Invalid NANPA phone number");

		if (wstrNationalNumber.length() >= 3)
		{
			wstrTemp = wstrNationalNumber.substr(0,3);
			mNationalCode = wstrTemp.c_str();
		}
		if (wstrNationalNumber.length() >= 6)
		{
			wstrTemp = wstrNationalNumber.substr(3,3);
			mLocalityCode = wstrTemp.c_str();
		}
	}

	return S_OK;
}

IMTRegion *	CPhoneNumberParser::GetCountryRegion (char * szCountryCode, char * szRegionCode)

{

	char * szCode = szCountryCode;
	long lCode = atoi (szCode);
	RegionCodeHashTable * pRegionTable;
	IMTRegion * pRegion;
	
	if (lCode < 0 || lCode > LargestCountryCode)
		return NULL;	
	
	if (NULL == (pRegionTable = mpRegionCodeHashTable[lCode]))
	{
		IMTEnumRegions * pRegions;
		HRESULT hr = GetRegionsByCountryName (mCountryName, (LPDISPATCH *)&pRegions);
		if (FAILED(hr))
			return NULL;

		pRegionTable = new RegionCodeHashTable;
		mpRegionCodeHashTable[lCode] = pRegionTable; 
		BuildRegionHashTable (pRegions, mpRegionCodeHashTable[lCode]);
		pRegions->Release();
	}	

	szCode = szRegionCode;
	lCode = atoi (szCode);

	if (lCode < 0 || lCode > LargestRegionCode)
		return NULL;

	pRegion = pRegionTable->Regions[lCode];
	return pRegion;
}

