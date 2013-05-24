// LangDescription.cpp: implementation of the LangDescription class.
//
//////////////////////////////////////////////////////////////////////

#include "LangDescription.h"
#include "mtprogids.h"

#include <vector>
using namespace std;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

LangDescription::LangDescription()
{
	pNameId.CreateInstance(MTPROGID_NAMEID);
}

LangDescription::~LangDescription()
{
}


#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LangDescription::Init()"
BOOL LangDescription::Init()
{
	try
	{
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration("DescInstall"), "[DescInstall]");

		// create the immemrowset ...
    ROWSETLib::IMTSQLRowsetPtr rowset("MTSQLRowset.MTSQLRowset.1") ;

    // initialize the rowset ...
    HRESULT nRetVal = rowset->Init ("\\Queries\\Localization") ;
    if (!SUCCEEDED(nRetVal))
    {
			mLogger.LogVarArgs(LOG_ERROR, "Error calling Rowset Init(): %s", PROCEDURE) ;
      return FALSE ;
    }

		mpRowset = rowset;

	}
	catch(_com_error e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Caught _com_error. Error = %x: %s", e.Error(), PROCEDURE) ;
    return FALSE ;
	}

	return TRUE;
}


#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LangDescription::GetLanguageId()"
long LangDescription::GetLanguageId(BSTR aCountryCode)
{
	_bstr_t countryCode(aCountryCode);
	long languageId = 0;
	
	try
	{
		mpRowset->SetQueryTag("__SELECT_LANGUAGE_CODE__") ;

		mpRowset->AddParam ("%%COUNTRYCODE_STRING%%", countryCode) ;

		mpRowset->Execute() ;

		languageId = mpRowset->GetValue ("LangID") ;
		
	}
	catch (_com_error e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Caught _com_error. Error = %x: %s", e.Error(), PROCEDURE) ;
	}

	return languageId;
}

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LangDescription::RemoveDescriptions()"
BOOL LangDescription::RemoveDescriptions(BSTR FQN)
{
	int idDesc;

	try {
		idDesc = pNameId->GetNameID(FQN);
	}
	catch(_com_error&) {
		mLogger.LogVarArgs (LOG_WARNING, "Unable to get code lookup id for string = %s.",
			(const char*)_bstr_t(FQN));
		return FALSE;
	}
	try
	{
		mpRowset->SetQueryTag ("__REMOVE_DESCRIPTIONS__") ;
		mpRowset->AddParam ("%%DESC_ID%%", ((_variant_t) (long)idDesc)) ;
		mpRowset->Execute();
	}
	catch (_com_error e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Caught _com_error. Error = %x: %s", e.Error(), PROCEDURE) ;
		return FALSE;
	}
	return TRUE; 
}

BOOL LangDescription::LoadNameAndValue(BSTR FQN,BSTR value,BSTR CountryCode)
{
	int idDesc;
//	long idLang;

//	idLang = GetLanguageId(CountryCode);

	try {
		idDesc = pNameId->GetNameID(FQN);
	}
	catch(_com_error&) {
    mLogger.LogVarArgs (LOG_WARNING, "Unable to get code lookup id for string = %s.",
      (const char*)_bstr_t(FQN));
		return FALSE;
	}
	
	try
	{
		mpRowset->SetQueryTag ("__INSERT_DESC_STRING__") ;
		mpRowset->AddParam ("%%DESC_ID%%", ((_variant_t) (long)idDesc)) ;
		mpRowset->AddParam ("%%COUNTRYCODE_STRING%%", CountryCode) ;
		mpRowset->AddParam ("%%TX_DESC%%", value) ;
		mpRowset->Execute();
	}
	catch (_com_error e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Caught _com_error. Error = %x: %s", e.Error(), PROCEDURE) ;
	}

	return TRUE;

}


//This method creates a special row per language code in t_description
//with the id of 0 and a blank localization. This is used for
//optional enum types that were not in session for the product view.
//See CR4434 for more info.
BOOL LangDescription::LoadBlankDescription()
{
	try
	{
		mpRowset->SetQueryTag("_POPULATE_BLANK_ROWS__");
		mpRowset->Execute();
		
	}
	catch (_com_error e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Could not insert blank description! Error = %x: %s", e.Error(), PROCEDURE) ;
		return FALSE;
	}

	return TRUE;
}



#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LangDescription::LoadSubTable()"
BOOL LangDescription::LoadSubTable(BSTR aFilename)
{
	/*
	_bstr_t filename(aFilename);
  IMTConfigPropSetPtr set ;
  IMTConfigPtr config ;

	try
	{
		HRESULT nRetVal = config.CreateInstance("MetraTech.MTConfig.1");
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs(LOG_ERROR, "Unable to create propset. Error = %x", nRetVal);
      return FALSE ;
    }

		VARIANT_BOOL flag;

		set = config->ReadConfiguration(filename, &flag);
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs(LOG_ERROR, "Unable to read configuration file. Error = %x", e.Error());
	mLogger.LogVarArgs(LOG_ERROR, "Failed on <%s>",(const char*)filename);
    mLogger.LogVarArgs(LOG_ERROR, "%s failed. Error Description = %s.", PROCEDURE, (char*)e.Description());
    return FALSE ;
  }

  CCodeLookup *pCodeLookup = NULL ;
  try
  {
    // get the code lookup object ...
    pCodeLookup = CCodeLookup::GetInstance() ;
    if (pCodeLookup == NULL)
    {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to create code lookup singleton.") ;
      return FALSE ;
    }

		_bstr_t countryCode = set->NextStringWithName("language_code");

		int idDesc;
		long idLang;
		_bstr_t txDesc;
    _bstr_t txFQN;

		idLang = GetLanguageId(countryCode);
		IMTConfigPropSetPtr LocaleSpaceSet = set->NextSetWithName("locale_space");
		IMTConfigPropSetPtr descSet;// = LocaleSpaceSet->NextSetWithName("locale_entry");

		while((descSet = LocaleSpaceSet->NextSetWithName("locale_entry")) != NULL)
		{
			txFQN = descSet->NextStringWithName("name");

			txDesc = descSet->NextStringWithName("value");

      // get the id for the FQN ...
      if (!pCodeLookup->GetEnumDataCode(txFQN, idDesc))
      {
        mLogger.LogVarArgs (LOG_WARNING, "Unable to get code lookup id for string = %s.",
          (char*)txFQN) ;
        pCodeLookup->ReleaseInstance() ;
        return FALSE ;
      }
      
			// write to the database ... set query tag ... add param ... execute ...
			mpRowset->SetQueryTag ("__INSERT_DESC_STRING__") ;

			mpRowset->AddParam ("%%DESC_ID%%", ((_variant_t) (long)idDesc)) ;

			mpRowset->AddParam ("%%LANG_CODE%%", idLang) ;

			mpRowset->AddParam ("%%TX_DESC%%", txDesc) ;

			mpRowset->Execute() ;

//			descSet = set->NextSetWithName("desc_set");
			//descSet = set->NextSetWithName("locale_entry");
		}
	}
	catch (_com_error e)
  {
		mLogger.LogVarArgs(LOG_ERROR, "Unable to parse configuration file. Error = %x", e.Error());
    mLogger.LogVarArgs(LOG_ERROR, "%s failed. Error Description = %s.", PROCEDURE, (char*)e.Description());
    pCodeLookup->ReleaseInstance() ;
    return FALSE ;
  }

  pCodeLookup->ReleaseInstance() ;
*/
	return TRUE;
}

