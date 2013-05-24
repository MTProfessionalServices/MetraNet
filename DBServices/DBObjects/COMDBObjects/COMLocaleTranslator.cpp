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
* Created by: Kevin Fitzgerald
* $Header$
* 
***************************************************************************/
// COMLocaleTranslator.cpp : Implementation of CCOMLocaleTranslator
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMLocaleTranslator.h"
#include <DBLocale.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <SetIterate.h>
#include <DBInMemRowset.h>
#include <DBConstants.h>
#include <mtprogids.h>
#include <mtcomerr.h>

// import the query adapter tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 

#import <COMDBObjects.tlb> rename ("EOF", "DBEOF" )

// import the enum config tlb
#import <MTEnumConfigLib.tlb>
using namespace MTENUMCONFIGLib;

// import the name id tlb
#import <MTNameIDLib.tlb>
using namespace MTNAMEIDLib;

// definition for the colors properties
FIELD_DEFINITION LOCALIZED_ENUM_STRINGS[] = 
{
  { DB_LOCALIZED_STRING_NAME, DB_STRING_TYPE },
  { DB_STRING_VALUE, DB_STRING_TYPE },
	{ DB_STRING_ENUMERATOR, DB_STRING_TYPE }
};

/////////////////////////////////////////////////////////////////////////////
// CCOMLocaleTranslator

CCOMLocaleTranslator::CCOMLocaleTranslator()
: mpLocale(NULL)
{
}

CCOMLocaleTranslator::~CCOMLocaleTranslator()
{
  if (mpLocale != NULL)
  {
    mpLocale->ReleaseInstance() ;
    mpLocale = NULL ;
  }
}

STDMETHODIMP CCOMLocaleTranslator::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMLocaleTranslator,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	Init
// Arguments:     aLangCode - the language code
// Return Value:  
// Errors Raised: 0xE1500008L - Unable to initialize the locale translator.
// Description:   The Init method initializes the locale translator with the
//  specified language code.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::Init(BSTR aLangCode)
{
  // local variables
  HRESULT nRetVal=S_OK ;
	
  // get a pointer to the Locale description ...
  if (mpLocale == NULL)
  {
    mpLocale = DBLocale::GetInstance() ;
    if (mpLocale == NULL)
    {
      nRetVal = DB_ERR_NO_INSTANCE ;
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to initialize locale translator. Error = %x", nRetVal) ;
      return Error ("Unable to initialize the locale translator.", 
        IID_ICOMLocaleTranslator, nRetVal) ;
    }
    else
    {
      mLangCode = aLangCode ;
    }
  }
	
  return (nRetVal) ;
}

// ----------------------------------------------------------------
// Name:     	GetPropertyDescription
// Arguments:     aViewID - the view id
//                aName - the name of the property 
//                pDesc - the localized property name
// Return Value:  the localized property name
// Errors Raised: 0xE1500008L - Locale translator not initialized.
// Description:   The GetPropertyDescription method gets the localized
//  property description for the specified view id and property name.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetPropertyDescription(long aViewID, BSTR aName, BSTR * pDesc)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  std::wstring wstrDesc ;
	
  if (mpLocale == NULL)
  {
    nRetVal = DB_ERR_NO_INSTANCE ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Locale translator not initialized. Error = %x", nRetVal) ;
    return Error ("Locale translator not initialized.", 
			IID_ICOMLocaleTranslator, nRetVal) ;
  }
  else
  {
	  wstrDesc = mpLocale->GetLocalePropertyDesc (aViewID, (const std::wstring)aName, (const std::wstring) mLangCode) ;
    
    *pDesc = ::SysAllocString (wstrDesc.c_str()) ;
  }
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	GetDescription
// Arguments:     aDescID - the description id
//                pDesc - the localized name
// Return Value:  the localized name
// Errors Raised: 0xE1500008L - Locale translator not initialized.
// Description:   The GetDescription method gets the localized
//  description for the description id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetDescription(long aDescID, BSTR * pDesc)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  std::wstring wstrDesc ;
	
  if (mpLocale == NULL)
  {
    nRetVal = DB_ERR_NO_INSTANCE ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Locale translator not initialized. Error = %x", nRetVal) ;
    return Error ("Locale translator not initialized.", 
			IID_ICOMLocaleTranslator, nRetVal) ;
  }
  else
  {  
	  wstrDesc = mpLocale->GetLocaleDesc (aDescID, (const std::wstring) mLangCode) ;
    
    *pDesc = ::SysAllocString (wstrDesc.c_str()) ;
  }
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	GetLocalizedString
// Arguments:     aFQN - the fully qualified name
//                pDesc - the localized name
// Return Value:  the localized name
// Errors Raised: 0xE1500008L - Locale translator not initialized.
// Description:   The GetLocalizedString method gets the localized
//  string for the fully qualified name.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetLocalizedString(BSTR aName, BSTR * pDesc)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  std::wstring wstrDesc ;
  std::wstring wstrFQN ;
  long nDescID=-1 ;
	
  if (mpLocale == NULL)
  {
    nRetVal = DB_ERR_NO_INSTANCE ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Locale translator not initialized. Error = %x", nRetVal) ;
    return Error ("Locale translator not initialized.", 
			IID_ICOMLocaleTranslator, nRetVal) ;
  }
  else
  {
    // get the localized description
    wstrFQN = aName ;
    wstrDesc = mpLocale->GetLocaleDesc (wstrFQN, (const std::wstring) mLangCode) ;
    
    *pDesc = ::SysAllocString (wstrDesc.c_str()) ;
  }
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	    GetLocalizedMonth
// Arguments:     aMonth - the month as a string (i.e., "May")
// Return Value:  pDesc - the localized month
// Errors Raised: 
// Description:   The this method gets the localized string for the
//                month specified.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetLocalizedMonth(BSTR aMonth, BSTR * pDesc)
{
  _bstr_t strFQN("Global/MonthOfTheYear/");
	strFQN += aMonth;
	return GetLocalizedString(strFQN, pDesc);
}

// ----------------------------------------------------------------
// Name:     	    GetLocalizedWeekday
// Arguments:     aWeekday - the week day as a string (i.e., "Monday")
// Return Value:  pDesc - the localized week day
// Errors Raised:
// Description:   The this method gets the localized string for the
//                month specified.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetLocalizedWeekday(BSTR aWeekday, BSTR * pDesc)
{
  _bstr_t strFQN("Global/DayOfTheWeek/");
	strFQN += aWeekday;
	return GetLocalizedString(strFQN, pDesc);
}

// ----------------------------------------------------------------
// Name:     	GetCurrency
// Arguments:     aAmount - the amount
//                aUOM - the currency code
//                pCurrency - the localized currency
// Return Value:  the localized currency
// Errors Raised: 0xE1500008L - Locale translator not initialized.
// Description:   The GetCurrency method gets the localized
//  currency for the specified amount and currency code.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetCurrency(VARIANT aAmount, BSTR aUOM, BSTR * pCurrency)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  std::wstring wstrDesc ;
	
  if (mpLocale == NULL)
  {
    nRetVal = DB_ERR_NO_INSTANCE ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Locale translator not initialized. Error = %x", nRetVal) ;
    return Error ("Locale translator not initialized.", 
			IID_ICOMLocaleTranslator, nRetVal) ;
  }
  else
  {
		_variant_t amount(aAmount);
    wstrDesc = mpLocale->GetLocaleCurrency ((DECIMAL) amount, aUOM) ;
    
    *pCurrency = ::SysAllocString (wstrDesc.c_str()) ;
  }
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	GetEuroCurrency
// Arguments:     aAmount - the amount
//                aUOM - the currency code
//                pCurrency - the localized currency
// Return Value:  the localized currency
// Errors Raised: 0xE1500008L - Locale translator not initialized.
// Description:   The GetEuroCurrency method gets the localized
//  currency in Euro for the specified amount and currency code.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetEuroCurrency(VARIANT aAmount, BSTR aUOM, BSTR * pCurrency)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  std::wstring wstrDesc ;
	
  if (mpLocale == NULL)
  {
    nRetVal = DB_ERR_NO_INSTANCE ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Locale translator not initialized. Error = %x", nRetVal) ;
    return Error ("Locale translator not initialized.", 
			IID_ICOMLocaleTranslator, nRetVal) ;
  }
  else
  {
		_variant_t amount(aAmount);
    wstrDesc = mpLocale->GetEuroCurrency ((DECIMAL) amount, aUOM) ;
    
    *pCurrency = ::SysAllocString (wstrDesc.c_str()) ;
  }
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	GetViewDescription
// Arguments:     aViewID - the view id
//                pDesc - the localized name
// Return Value:  the localized name
// Errors Raised: 0xE1500008L - Locale translator not initialized.
// Description:   The GetViewDescription method gets the localized
//  description for the view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetViewDescription(long aViewID, BSTR * apDesc)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  std::wstring wstrDesc ;
	
  if (mpLocale == NULL)
  {
    nRetVal = DB_ERR_NO_INSTANCE ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Locale translator not initialized. Error = %x", nRetVal) ;
    return Error ("Locale translator not initialized.", 
			IID_ICOMLocaleTranslator, nRetVal) ;
  }
  else
  {
	  wstrDesc = mpLocale->GetLocaleViewDesc (aViewID, (const std::wstring) mLangCode) ;
    
    *apDesc = ::SysAllocString (wstrDesc.c_str()) ;
  }
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	LanguageCode
// Arguments:     pVal - the language code
// Return Value:  the language code
// Errors Raised: 
// Description:   The LanguageCode property gets the language code.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::get_LanguageCode(BSTR * pVal)
{
	// local variables
  HRESULT nRetVal=S_OK ;
	
  *pVal = mLangCode.copy() ;
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	LanguageCode
// Arguments:     pVal - the language code
// Return Value:  
// Errors Raised: 
// Description:   The LanguageCode property sets the language code.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::put_LanguageCode(BSTR newVal)
{
	// local variables
  HRESULT nRetVal=S_OK ;
	
  mLangCode = newVal ;
	
  return nRetVal ;
}


// ----------------------------------------------------------------
// Name:     	GetDateTime
// Arguments:     aInputDateTime - the date time to convert
//                aMTZoneCode - the timezone code
//                aDayLightSavingFlag - the day light savings flag
//                apLocaleDatTime - the converted date time
// Return Value:  the converted date time
// Errors Raised: 0xE1500008L - Locale translator not initialized.
//                0x80020009L - Error getting localDateTime
// Description:   The GetDateTime method converts the specified date time
//  to a date time by using the specified timezone and daylight savings flag.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetDateTime(VARIANT aInputDateTime, 
																							 long aMTZoneCode, 
																							 VARIANT_BOOL aDayLightSavingFlag, 
																							 VARIANT *apLocalDateTime)
{
	// local variables
  HRESULT nRetVal=S_OK ;
	
  if (mpLocale == NULL)
  {
    nRetVal = DB_ERR_NO_INSTANCE ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Locale translator not initialized. Error = %x", nRetVal) ;
    return Error ("Locale translator not initialized.", 
			IID_ICOMLocaleTranslator, nRetVal) ;
  }
  else
  {
		if (apLocalDateTime == NULL)
		{
			mLogger->LogVarArgs (LOG_ERROR, "Invalid output pointer value") ;
			return E_POINTER;
		}
		
    if (!mpLocale->GetDateTime (aInputDateTime, aMTZoneCode, 
			aDayLightSavingFlag, apLocalDateTime))
    {
			mLogger->LogVarArgs (LOG_ERROR, "Error getting localDateTime") ;
			return Error("Error getting localDateTime");
		}
		
  }
	
  return nRetVal ;
}

// ----------------------------------------------------------------
// Name:     	GetLocaleListForgTypes
// Arguments:     aLangCode - the language code
//                aEnumSpace - the enumeration namespace
//                aEnumTypeName - the enumeration name
//                pInterface - the locale list for the enum type
// Return Value:  the locale list for the enum type
// Errors Raised: ??? - Unable to create name ID object
//                ??? - Unable to create enumerator collection object
//                ??? - Unable to create enum type object
//                ??? - Unable to create enum config object
//                ??? - Unable to initialize enum config object
//                ??? - Unable to get enum type object
//                ??? - Unable to get enumerator collection object
//                ??? - Unable to get ID for FQN
// Description:   The GetLocaleListForEnumTypes method gets the localized string
//  list for the specified language code, enumeration space and enumeration name.
// ----------------------------------------------------------------
STDMETHODIMP 
CCOMLocaleTranslator::GetLocaleListForEnumTypes(BSTR aLangCode, 
																								BSTR aEnumSpace, 
																								BSTR aEnumTypeName,
																								LPDISPATCH* pInterface)	
{
	std::string buffer;
	HRESULT hr = S_OK;
  ROWSETLib::IMTInMemRowsetPtr pRowset ;
	pRowset = 0;
	
	// convert the language code to lower case first
	std::wstring wstrLangCode = _bstr_t(aLangCode);
	_wcslwr((wchar_t *)wstrLangCode.c_str());
	
	// read the site.xml file here and parse it
	try
	{
		// create an instance of the rowset object ...
		hr = pRowset.CreateInstance (MTPROGID_INMEMROWSET);
		if (!SUCCEEDED(hr))
		{
		    buffer = "Unable to instantiate Rowset object";
				mLogger->LogThis(LOG_ERROR, buffer.c_str());
				return (E_FAIL);	
		}
		
		// initialize the rowset ...
		pRowset->Init();
		
		int nNumFields = (sizeof(LOCALIZED_ENUM_STRINGS)/sizeof(FIELD_DEFINITION));
    
		for (int i = 0; i < nNumFields; i++)
		{
		    // add the field definition
		    pRowset->AddColumnDefinition(LOCALIZED_ENUM_STRINGS[i].FieldName, 
					LOCALIZED_ENUM_STRINGS[i].FieldType);
		}
		
		// ---------------------------------------------------------------
		// create the MTNameID object
		MTNAMEIDLib::IMTNameIDPtr mtnameidptr;
		hr = mtnameidptr.CreateInstance("MetraPipeline.MTNameID.1");
		if (!SUCCEEDED(hr))
		{
		    buffer = "Unable to create name ID object";
				mLogger->LogThis (LOG_ERROR, buffer.c_str());
				return Error(buffer.c_str(), IID_ICOMLocaleTranslator, hr);
		}
		
		MTENUMCONFIGLib::IEnumConfigPtr enumconfigptr = NULL;
		MTENUMCONFIGLib::IMTEnumeratorCollectionPtr enumeratorcollptr = NULL;
		MTENUMCONFIGLib::IMTEnumTypePtr enumtypeptr = NULL;
		
		
		// ---------------------------------------------------------------
		// create the MTEnumConfig object
		
		hr = enumconfigptr.CreateInstance("Metratech.MTEnumConfig.1");
		if (!SUCCEEDED(hr))
		{
		    buffer = "Unable to create enum config object";
				mLogger->LogThis (LOG_ERROR, buffer.c_str());
				return Error(buffer.c_str(), IID_ICOMLocaleTranslator, hr);
		}
		
		// initialize mtenumconfig object
		enumconfigptr->Initialize();
		// get fqn
		hr = enumconfigptr->raw_GetEnumType(aEnumSpace, aEnumTypeName, &enumtypeptr);
		
		if (hr == S_FALSE)
		{
			char buf[1024];
			sprintf(buf, "Unable to get enum type object, is %s/%s defined?",
				(const char*)_bstr_t(aEnumSpace), (const char*)_bstr_t(aEnumTypeName)) ;
			mLogger->LogThis (LOG_ERROR, buf);
			return Error(buf, IID_ICOMLocaleTranslator, E_FAIL);
		}
		
		// get the collection
		enumeratorcollptr = enumtypeptr->GetEnumerators();
		
		// iterate over the collection
		long count = 0;
		enumeratorcollptr->get_Count(&count);
		
		if (count > 0)
		{
			SetIterator<IMTEnumeratorCollectionPtr, IMTEnumeratorPtr> it;
			HRESULT hr = it.Init(enumeratorcollptr);
			if (FAILED(hr))
				return hr;
			
			while (TRUE)
			{
				IMTEnumeratorPtr enumptr = it.GetNext();
				if (enumptr == NULL)
					break;
				
				// perform the operation
				_bstr_t fqn, enumerator;
				fqn = enumptr->GetFQN();
				enumerator = enumptr->Getname();
				mLogger->LogVarArgs (LOG_DEBUG, "FQN = <%s>", (const char*) fqn);
				
				long id = -99;
				id = mtnameidptr->GetNameID(fqn);
				if (id == -99)
				{
					buffer = "Unable to get name ID";
					mLogger->LogVarArgs (LOG_ERROR, "Unable to get ID for FQN <%s>", (const char*) fqn);
					return Error(buffer.c_str(), IID_ICOMLocaleTranslator, hr);
				}
				
				_bstr_t value;
				if (enumptr->NumValues() > 0)
					value = enumptr->ElementAt(0);
				else 
				{
					buffer = "Value not found";
					mLogger->LogVarArgs (LOG_INFO, "Value not found for FQN <%s>, assigning enumerator", (const char*)fqn);
					value = enumerator;
				}
				
				// get the description string
				
				std::wstring localedesc = mpLocale->GetLocaleDesc(id, wstrLangCode);  
				
				// add the row to the rowset
				pRowset->AddRow();
				
				// add the column to the rowset
				pRowset->AddColumnData(DB_LOCALIZED_STRING_NAME, (_variant_t)localedesc.c_str());
				
				// add the column to the rowset
				pRowset->AddColumnData(DB_STRING_VALUE, value);
				
				// add the column to the rowset
				pRowset->AddColumnData(DB_STRING_ENUMERATOR, enumerator);
				
			}
		}
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	
	*pInterface = pRowset.Detach();
	
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	LanguageID
// Arguments:     pVal - the language id
// Return Value:  the language id
// Errors Raised: 
// Description:   The LanguageID property gets the language id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::get_LanguageID(long * pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = 0;

	int langID = mpLocale->GetLanguageID((const wchar_t *)mLangCode);
	if (langID == -1) 
	{
		wchar_t buf [128];
		wsprintf(buf, L"Failed to find language id from language code '%s'", (const wchar_t *)mLangCode);
		return Error(buf);
	}
	*pVal = langID;

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	GetLocalizedDescription
// Arguments:     aDescriptionID - the identifier of the localized string
//                pDesc - the returned description string.  Empty string if none found
// Return Value:  The locale specific description
// Errors Raised: 
// Description:   Gets the localized version of a description relative to the current locale
// ----------------------------------------------------------------
STDMETHODIMP CCOMLocaleTranslator::GetLocalizedDescription(long aDescriptionID, BSTR * pDesc)
{
	if (!pDesc)
		return E_POINTER;
	else
		*pDesc = 0;

	try
	{
		COMDBOBJECTSLib::ICOMLocaleTranslatorPtr This(this);
		*pDesc = _bstr_t(mpLocale->GetLocaleDesc((int)aDescriptionID, (int) This->LanguageID).c_str()).copy();
	}
	catch(_com_error & e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

