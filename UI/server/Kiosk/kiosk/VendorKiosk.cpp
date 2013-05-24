/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * Created by: Raju Matta
 * $Header$
 * 
 * 	VendorKiosk.cpp : 
 *	------------------
 *	This is the implementation of the VendorKiosk class.
 *	This class expands on the functionality provided by the class 
 *	CCOMVendorKiosk.
 ***************************************************************************/

// All the includes
// ADO includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>

// Local includes
#include <VendorKiosk.h>
#include <loggerconfig.h>
#include <mtparamnames.h>
#include <ConfigDir.h>

// import the configloader tlb file
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

// static definition ...

// definition for the colors properties
FIELD_DEFINITION COLORS_FIELDS[] = 
{
  { DB_COLOR_NAME, DB_STRING_TYPE }
};

// definition for the language collection
FIELD_DEFINITION LANGUAGE_FIELDS[] = 
{
  { DB_LANGUAGE_CODE, DB_STRING_TYPE },
  { DB_LANGUAGE_STRING, DB_STRING_TYPE },
};

// definition for the timezone properties
FIELD_DEFINITION TIMEZONE_FIELDS[] = 
{
  { DB_TIMEZONE_ID, DB_INTEGER_TYPE },
  { DB_TIMEZONE_NAME, DB_STRING_TYPE },
  { DB_TIMEZONE_INFO, DB_STRING_TYPE },
  { DB_TX_DLST, DB_STRING_TYPE },
  { DB_GMT_OFFSET, DB_FLOAT_TYPE },
  { DB_TIMEZONE_VALUE, DB_STRING_TYPE },
};


// All the constants

// @mfunc CVendorKiosk default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// VendorKiosk class
DLL_EXPORT 
CVendorKiosk::CVendorKiosk() 
: mAccMapper(W_NULL_STR), mAuthMethod(W_NULL_STR)
{
}


// @mfunc CVendorKiosk copy constructor
// @parm CVendorKiosk& 
// @rdesc This implementations is for the copy constructor of the 
// VendorKiosk class
DLL_EXPORT 
CVendorKiosk::CVendorKiosk(const CVendorKiosk &c) 
{
	*this = c;
}

// @mfunc CVendorKiosk assignment operator
// @parm 
// @rdesc This implementations is for the assignment operator of the 
// VendorKiosk class
DLL_EXPORT const CVendorKiosk& 
CVendorKiosk::operator=(const CVendorKiosk& rhs)
{	
 	return ( *this );
}


// @mfunc CVendorKiosk destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// VendorKiosk class
DLL_EXPORT 
CVendorKiosk::~CVendorKiosk()
{
}

// @mfunc Initialize
// @parm Web URL 
// @rdesc This method is responsible for getting the corresponding values 
// for the input parameters from the database.   It creates the language
// request and does the connect to the database and executes the query.
// Returns true or false depending on whether the method succeeded
// or not.  
DLL_EXPORT BOOL
CVendorKiosk::Initialize(const wstring &arProviderName)
{
  _bstr_t authMethod;
  _bstr_t accMapper;
  string strConfigDir;

  // set the provider data member ...
  mProviderName = arProviderName;

  // start the try ...
  try
  {
    // initialize the _com_ptr_t ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);

		string aExtensionDir;
		GetExtensionsDir(aExtensionDir);
		_bstr_t aSiteConfigDir = (const char*)aExtensionDir.c_str();
		aSiteConfigDir += DIR_SEP;
		aSiteConfigDir += (const wchar_t*)arProviderName.c_str();
		aSiteConfigDir += NEW_MPSSITECONFIG_DIR;
		//aSiteConfigDir += (const wchar_t*)arProviderName;


    // initialize the configLoader ...
    configLoader->InitWithPath(aSiteConfigDir);
    
    // open the config file ...
    CONFIGLOADERLib::IMTConfigPropSetPtr confSet = 
      configLoader->GetEffectiveFile("", SITE_CONFIG);

	// check for the null existence of the object
	if (confSet == NULL)
	{
	  mLogger->LogVarArgs (LOG_ERROR, 
						  "Unable to create configuration set for provider <%s>", 
						  _bstr_t(arProviderName.c_str()));
	  mLogger->LogThis (LOG_ERROR, "GetEffectiveFile on site.xml file failed");
	  mLogger->LogThis (LOG_ERROR, "Could be because the effective date is ahead of the current GMT time");
	  return (FALSE);
	}
    
    // get the config data ...
    CONFIGLOADERLib::IMTConfigPropSetPtr subset;
    subset = confSet->NextSetWithName("site_config");

    // get the auth method and account mapper ...
    authMethod = subset->NextStringWithName("auth_method");
    mAuthNamespace = subset->NextStringWithName("auth_namespace");
    accMapper = subset->NextStringWithName("acc_mapper");

    // copy to data members ...
    mAuthMethod = authMethod;
    mAccMapper = accMapper;
  }
  catch (_com_error& e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "CVendorKiosk::Initialize");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    return (FALSE);
  }

  return (TRUE);
}

//	@mfunc Get the colors for the initial setup of the Kiosk UI
//  @parm
//  @rdesc 
//  Returns the record set pointer.  This contains the data from the
//	database.  If no rows returned, throw an exception and in case of 
//	exception that is caught from ADO, return null pointer
DLL_EXPORT ROWSETLib::IMTSQLRowsetPtr
CVendorKiosk::GetLanguageCollection(const wstring &arLangCode)
{
	// local variables
	BOOL bOK = TRUE;
	HRESULT hOK = S_OK;
	const char* procName = "CVendorKiosk::GetLanguageCollection()";

	ROWSETLib::IMTSQLRowsetPtr rowset;
  
  // read the site.xml file here and parse it
  try
  {
    // create and initialize a SQL rowset ...
    hOK = rowset.CreateInstance (MTPROGID_SQLROWSET);
    if (!SUCCEEDED(hOK))
    {
		    mLogger->LogVarArgs (LOG_ERROR,
          "Unable to instantiate Rowset object. Error = <%d>", hOK);
        return (NULL);	
    }
    // initialize the rowset ...
    hOK = rowset->Init("\\Queries\\PresServer");
    if (!SUCCEEDED(hOK))
    {
		    mLogger->LogVarArgs (LOG_ERROR,
          "Unable to initialize Rowset object. Error = <%d>", hOK);
        return (NULL);	
    }

    // set the query tag ...
    _bstr_t queryTag = L"__GET_LOCALIZED_LANGUAGE_CODES__";
    rowset->SetQueryTag(queryTag);

    // add the parameters ...
    _variant_t vtValue = arLangCode.c_str();
    rowset->AddParam (MTPARAM_LANGCODE, vtValue);

    // execute the query ...
    rowset->Execute();
  }
  catch (_com_error e)
  {
    SetError (e.Error(), 
				  ERROR_MODULE, 
          ERROR_LINE, 
          "Unable to get language collection." );
    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
    mLogger->LogVarArgs (LOG_ERROR, "GetLanguageCollection() failed. Error description = %s.",
      (char*)e.Description());
    return (NULL);
  }
  
  return (rowset);
}
#if 0
//	@mfunc Get the colors for the initial setup of the Kiosk UI
//  @parm
//  @rdesc 
//  Returns the record set pointer.  This contains the data from the
//	database.  If no rows returned, throw an exception and in case of 
//	exception that is caught from ADO, return null pointer
DLL_EXPORT ROWSETLib::IMTInMemRowsetPtr
CVendorKiosk::GetColors()
{
	// local variables
	BOOL bOK = TRUE;
	HRESULT hOK = S_OK;
	const char* procName = "CVendorKiosk::GetColors()";

	ROWSETLib::IMTInMemRowsetPtr rowset;

	// read the colors.xml file here and parse it
	try
	{
    // create an instance of the rowset object ...
    hOK = rowset.CreateInstance (MTPROGID_INMEMROWSET);
    if (!SUCCEEDED(hOK))
    {
		    mLogger->LogVarArgs (LOG_ERROR,
          "Unable to instantiate Rowset object. Error = <%d>", hOK);
        return (NULL);	
    }
    // initialize the rowset ...
    hOK = rowset->Init();
    if (!SUCCEEDED(hOK))
    {
		    mLogger->LogVarArgs (LOG_ERROR,
          "Unable to initialize Rowset object. Error = <%d>", hOK);
        return (NULL);	
    }
		int nNumFields = (sizeof(COLORS_FIELDS)/sizeof(FIELD_DEFINITION));

		for (int i = 0; i < nNumFields; i++)
		{
		    // add the field definition
		    hOK = rowset->AddColumnDefinition (COLORS_FIELDS[i].FieldName, 
											   COLORS_FIELDS[i].FieldType);
			if (!SUCCEEDED(hOK))
			{
			    DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to create a row set. Error <%d>", 
									nError);
			}
		}

    // initialize the _com_ptr_t ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);
    
    // initialize the configLoader ...
    configLoader->Init();
      
		
		// read the colors.xml file
		IMTConfigPropSetPtr confSetPtr = configLoader->GetEffectiveFile(
		                                            PRES_SERVER_CONFIG_PATH,
													COLORS_XML_FILE);
		
		// read the color_set
		IMTConfigPropSetPtr colorSet;
		colorSet = confSetPtr->NextSetWithName(COLOR_STR);

		while (colorSet != NULL)
		{
			_bstr_t colorname;
			colorname = colorSet->NextStringWithName(COLOR_NAME_STR);

			// add the rows to the rowset
			hOK = rowset->AddRow();
			if (!SUCCEEDED(hOK))
			{
			    DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to add row. Error <%d>", nError);
			}

			
			_variant_t vtValue;
			vtValue = colorname;
			hOK = rowset->AddColumnData(DB_COLOR_NAME, vtValue);
			if (!SUCCEEDED(hOK))
			{
			    DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to add field data. Error <%d>", nError);
			}

			colorSet = confSetPtr->NextSetWithName(COLOR_STR);
		}
	}
	catch (_com_error e)
	{
	    SetError (e.Error(), 
				  ERROR_MODULE, 
				  ERROR_LINE, 
				  "ConfigLoader threw a COM exception" );
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return (NULL);
	}

	return (rowset);
}
#endif
//	@mfunc Get the timezone data for the initial setup of the Kiosk UI
//  @parm
//  @rdesc 
//  Returns the record set pointer.  This contains the data from the
//	database.  If no rows returned, throw an exception and in case of 
//	exception that is caught from ADO, return null pointer
//	@mfunc Get the timezone data for the initial setup of the Kiosk UI
//  @parm
//  @rdesc 
//  Returns the record set pointer.  This contains the data from the
//	database.  If no rows returned, throw an exception and in case of 
//	exception that is caught from ADO, return null pointer
DLL_EXPORT ROWSETLib::IMTInMemRowsetPtr
CVendorKiosk::GetTimezone(const wstring &arLangCode)
{
	// local variables
	const char* procName = "CVendorKiosk::GetTimezone()";
	BOOL bOK = TRUE;
  HRESULT hOK = S_OK;
  _variant_t timezoneid;
  _variant_t timezonename;
  _variant_t timezonetext;
  _variant_t DLSTtext;
  _variant_t GMToffset;
  _variant_t vtValue;
  _bstr_t descID;
  wstring wstrDesc;
  
	ROWSETLib::IMTInMemRowsetPtr rowset;


	// read the timezone.xml file here and parse it
	try
	{
    // create an instance of the rowset object ...
    hOK = rowset.CreateInstance (MTPROGID_INMEMROWSET);
    if (!SUCCEEDED(hOK))
    {
		    mLogger->LogVarArgs (LOG_ERROR,
          "Unable to instantiate Rowset object. Error = <%d>", hOK);
        return (NULL);	
    }
    // initialize the rowset ...
    hOK = rowset->Init();
    if (!SUCCEEDED(hOK))
    {
		    mLogger->LogVarArgs (LOG_ERROR,
          "Unable to initialize Rowset object. Error = <%d>", hOK);
        return (NULL);	
    }

		int nNumFields = (sizeof(TIMEZONE_FIELDS)/sizeof(FIELD_DEFINITION));

		for (int i = 0; i < nNumFields; i++)
		{
		    // add the field definition
		    hOK = rowset->AddColumnDefinition (TIMEZONE_FIELDS[i].FieldName, 
											   TIMEZONE_FIELDS[i].FieldType);
			if (!SUCCEEDED(hOK))
			{
			    DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to create a row set. Error <%d>", 
									nError);
        return (NULL);
			}
		}

    // initialize the _com_ptr_t ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);
    
    // initialize the configLoader ...
    configLoader->Init();
      
		// read the colors.xml file
		IMTConfigPropSetPtr confSetPtr = configLoader->GetEffectiveFile(
		                                            PRES_SERVER_CONFIG_PATH,
													TIMEZONE_XML_FILE);
		
		// read the color_set
		IMTConfigPropSetPtr timezoneSet;

		while ((timezoneSet = confSetPtr->NextSetWithName(TIMEZONE_STR))!= NULL)
		{
      timezoneid = timezoneSet->NextLongWithName(ID_TIMEZONE_STR);
      timezonename = timezoneSet->NextStringWithName(NM_TIMEZONE_STR);
      timezonetext = timezoneSet->NextStringWithName(TX_TIMEZONE_INFO_STR);
      DLSTtext = timezoneSet->NextStringWithName(TX_DLST_STR);
      GMToffset = timezoneSet->NextDoubleWithName(QN_GMT_OFFSET_STR);

      // get the color description id ...
      descID = timezoneSet->NextStringWithName(DESCID_STR);
      
      // add the rows to the rowset
      hOK = rowset->AddRow();
			if (!SUCCEEDED(hOK))
			{
        DWORD nError = ERROR_INVALID_PARAMETER;
        SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
        mLogger->LogVarArgs (LOG_ERROR, 
          "Unable to add row. Error <%d>", nError);
        return (NULL);
			}

			hOK = rowset->AddColumnData(DB_TIMEZONE_ID, timezoneid);
			if (!SUCCEEDED(hOK))
			{
			  DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to add field data. Error <%d>", nError);
        return (NULL);
			}

			hOK = rowset->AddColumnData(DB_TIMEZONE_NAME, timezonename);
			if (!SUCCEEDED(hOK))
			{
		    DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to add field data. Error <%d>", nError);
        return (NULL);
			}

			hOK = rowset->AddColumnData(DB_TIMEZONE_INFO, timezonetext);
			if (!SUCCEEDED(hOK))
			{
  	    DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to add field data. Error <%d>", nError);
        return (NULL);
			}

			hOK = rowset->AddColumnData(DB_TX_DLST, DLSTtext);
			if (!SUCCEEDED(hOK))
			{
			  DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to add field data. Error <%d>", nError);
        return (NULL);
			}

			hOK = rowset->AddColumnData(DB_GMT_OFFSET, GMToffset);
			if (!SUCCEEDED(hOK))
			{
		    DWORD nError = ERROR_INVALID_PARAMETER;
				SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
				mLogger->LogVarArgs (LOG_ERROR, 
									"Unable to add field data. Error <%d>", nError);
        return (NULL);
			}

			//CR 4951
			//This is a quick fix, don't use localized ids that are in the TimeZone.xml file (they
			//are obsolete and unused)
			//What should prabably happen is that we should use TimzoneID enumeration instead of
			//Timezone.xml file and pull out localized strings for enum types

      // convert the description id to an integer ...
      //nDescID = atoi ((char*) descID);
      
      // get the localized value for the color ...
      //wstrDesc = pLocale->GetLocaleDesc(nDescID, arLangCode);
      
      // assign the value to the color value ...
      //vtValue = wstrDesc;
			vtValue = L" ";
      hOK = rowset->AddColumnData(DB_TIMEZONE_VALUE, vtValue);
      if (!SUCCEEDED(hOK))
      {
        DWORD nError = ERROR_INVALID_PARAMETER;
        SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
        mLogger->LogVarArgs (LOG_ERROR, 
          "Unable to add field data. Error <%d>", nError);
        return (NULL);
      }
		}
	}
	catch (_com_error e)
  {
    SetError (e.Error(), 
				  ERROR_MODULE, 
          ERROR_LINE, 
          "ConfigLoader threw a COM exception" );
    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
    return (NULL);
	}

	return (rowset);
}
