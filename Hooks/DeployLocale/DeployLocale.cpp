/**************************************************************************
 * @doc SIMPLE
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
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <Description.h>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <NTLogger.h>
#include <DBSQLRowset.h>
#include <DBInMemRowset.h>
#include <DBAccess.h>
#include <DBConstants.h>
#include <ConfigChange.h>
#include <stdutils.h>

//#include <MTEnumConfig.h>

using namespace std;
#include <vector>


#define DEPLOYLOCALE_STR "DeployLocale"
#define DEPLOYLOCALE_TAG "[DeployLocale]"

#define DB_CONFIG_PATH	"\\Queries\\Database"

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

#import <MTEnumConfigLib.tlb>
#import <MTLocaleConfig.tlb>


const char* gModule = "DeployLocale";

// generate using uuidgen
CLSID CLSID_DeployLocale = {
													//939545e0-17ab-11d4-95ad-00b0d025b121
    0x939545e0,
    0x17ab,
    0x11d4,
    {0x95,0xad,0x00,0xb0,0xd0,0x25,0xb1,0x21}
  };

class ATL_NO_VTABLE DeployLocale :
  public MTHookSkeleton<DeployLocale,&CLSID_DeployLocale>

{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);
 DeployLocale();
 virtual ~DeployLocale();
 HRESULT DeployLocale::GetLanguageCodes(vector<_bstr_t>&);
private:
	IMTQueryAdapter* mpQueryAdapter;
	NTLogger mLogger;

	//Enum Type objects
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
	MTENUMCONFIGLib::IMTEnumSpaceCollectionPtr mEnumSpaceColl;
	MTENUMCONFIGLib::IMTEnumSpacePtr mEnumSpace;
	MTENUMCONFIGLib::IMTEnumTypeCollectionPtr mEnumTypeColl;
	MTENUMCONFIGLib::IMTEnumTypePtr mEnumType;
	MTENUMCONFIGLib::IMTEnumeratorCollectionPtr mEnumeratorColl;
	MTENUMCONFIGLib::IMTEnumeratorPtr mEnumerator;

	//localization objects
	MTLOCALECONFIGLib::ILocaleConfigPtr mLocaleConfig;
	MTLOCALECONFIGLib::ILocaleConfigPtr mNewLocaleConfig;
	MTLOCALECONFIGLib::IMTLocalizedCollectionPtr mColl;
};

HOOK_INFO(CLSID_DeployLocale, 
		  DeployLocale,
		  "MetraHook.DeployLocale.1", 
		  "MetraHook.DeployLocale", 
		  "free")


DeployLocale::DeployLocale()
{
  LoggerConfigReader cfgRdr;
 	mLogger.Init(	cfgRdr.ReadConfiguration(DEPLOYLOCALE_STR), 
								DEPLOYLOCALE_TAG	);
}

DeployLocale::~DeployLocale(){}


/////////////////////////////////////////////////////////////////////////////
// Function name	: DeployProductView::ExecuteHook
// Description	    : 
// Return type		: HRESULT 
// Argument         : 
// Argument         : 
/////////////////////////////////////////////////////////////////////////////

HRESULT DeployLocale::ExecuteHook(VARIANT var, long* pVal)
{
	HRESULT hr = S_OK;
	const char* procName = "DeployLocale::ExecuteHook";
	_bstr_t bstrExtension;
	_variant_t disp;
	
	mLogger.LogVarArgs(LOG_DEBUG, "Entered %s", procName);
	
  //Create Enum Type and Localization objects
	try
	{
		if(FAILED(mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG)))
		{
			mLogger.LogThis(LOG_ERROR, "Failed to create MTPROGID_ENUM_CONFIG object");
			return E_FAIL;
		}
		if(FAILED(mLocaleConfig.CreateInstance(MTPROGID_LOCALE_CONFIG)))
		{
			mLogger.LogThis(LOG_ERROR, "Failed to create MTPROGID_LOCALE_CONFIG object");
			return E_FAIL;
		}
		if(FAILED(mNewLocaleConfig.CreateInstance(MTPROGID_LOCALE_CONFIG)))
		{
			mLogger.LogThis(LOG_ERROR, "Failed to create MTPROGID_LOCALE_CONFIG object");
			return E_FAIL;
		}
		
	}
	
	catch(_com_error err)
	{
		mLogger.LogThis(LOG_ERROR, "Failed to create one of the EnumConfig or LocaleConfig objects");
		return E_FAIL;
	}
	
	if(FAILED(hr))
		return hr;
	
	
	vector<_bstr_t> lang_codes;
	
	if(FAILED(GetLanguageCodes(lang_codes)))
	{
		mLogger.LogThis(LOG_ERROR, "Failed to get language codes");
		return E_FAIL;
	}
	
	//1. Load all languages at once
	mLogger.LogThis(LOG_DEBUG, "IMTLocaleConfig: Loading All languages");
	mLocaleConfig->LoadLanguage("");
	mLogger.LogThis(LOG_DEBUG, "Done.");
	
	int size = lang_codes.size();
	mLogger.LogVarArgs(LOG_DEBUG, "Got %i language codes from database", size);
	_bstr_t locale_entry;
	
	int count = 0;
	mLogger.LogVarArgs(LOG_DEBUG, "Searching for not localized enum types");
	mLogger.LogVarArgs(LOG_DEBUG, "Enumerations FQN collection size is %i elements", mEnumConfig->FQNCount());
	
	//create description loader object
	Description desc;
	LangDescription LangDesc;
		
	mLogger.LogThis(LOG_DEBUG, "Initializing description loader");
	if (!desc.Init())
	{
		mLogger.LogThis(LOG_ERROR, "Failed initializing description loader!");
		return E_FAIL;
	}
	mLogger.LogThis(LOG_DEBUG, "Creating description table");
	if (!desc.TruncateDescriptionTable())
	{
		mLogger.LogThis(LOG_ERROR, "Failed creating description table!");
		return E_FAIL;
	}
	mLogger.LogThis(LOG_DEBUG, "Initializing language description object");
	if (!LangDesc.Init())
	{
		mLogger.LogThis(LOG_ERROR, "Failed initializing language description object!");
		return E_FAIL;
	}
			
	try
	{
		//set iterator to begin of map
		//mEnumConfig->EnumerateFQN();
		mEnumSpaceColl = mEnumConfig->GetEnumSpaces();
		
		for (int i = 1; i <= mEnumSpaceColl->GetCount(); i++)
		{
			disp = mEnumSpaceColl->GetItem(i);
			(disp.pdispVal)->QueryInterface(__uuidof(MTENUMCONFIGLib::IMTEnumSpace), (void**)&mEnumSpace);
			bstrExtension = mEnumSpace->GetExtension();
			mEnumTypeColl = mEnumSpace->GetEnumTypes();
			ASSERT(mEnumTypeColl != NULL);
			
			for (int j = 1; j <= mEnumTypeColl->GetCount(); j++)
			{
				disp = mEnumTypeColl->GetItem(j);
				(disp.pdispVal)->QueryInterface(__uuidof(MTENUMCONFIGLib::IMTEnumType), (void**)&mEnumType);
				mEnumeratorColl = mEnumType->GetEnumerators();
				ASSERT(mEnumeratorColl != NULL);
				
				for (int k = 1; k <= mEnumeratorColl->GetCount(); k++)
				{
					mEnumerator = mEnumeratorColl->GetItem(k);
					_bstr_t fqn = mEnumerator->GetFQN();
					LangDesc.RemoveDescriptions(fqn);
					//Iterate thru all languages defined in t_language
					for (int l=0;l < size;l++)
					{
						_bstr_t lang = lang_codes.at(l);
						
						locale_entry = mLocaleConfig->GetLocalizedString(fqn, lang);
						
						if(locale_entry.length() == 0)
						{
							mLogger.LogVarArgs(LOG_WARNING, "%s Enumerator for <%s> language not localized, adding default!",
								(const char*)fqn, (const char*) lang);
							
							//Need to keep mNewLocaleConfig to only write the difference out to files
							// and not the entire thing
							
							//pass empty string for enum_space, first token before slash
							//will be inserted as locale_space
							mNewLocaleConfig->Localize(mEnumSpace->Getname(), lang, fqn, fqn, bstrExtension);
							count++;
						}
					}
				}
			}
		}
		
		mLogger.LogThis(LOG_DEBUG, "Done.");
		if (count > 0)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Total of %i enumerators were not localized, localizing to files...", count);
			mNewLocaleConfig->Write();
		}
		else
		{
			mLogger.LogVarArgs(LOG_DEBUG, "All enumerators are localized, nothing to add");
		}
		
		//write the difference (default localized strings) out to files
		
		}
		catch(_com_error err)
		{
			return ReturnComError(err);
		}
		
		
		
		//Load Localized collection into database...
		
		try
		{
			//Iterate Through  collection and insert entries into t_description table
			MTLOCALECONFIGLib::ILocaleConfigPtr coll(MTPROGID_LOCALE_CONFIG);
			coll->LoadLanguage("");
			mColl = coll->GetLocalizedCollection();
			mColl->Begin();
			mLogger.LogVarArgs(LOG_DEBUG, "About to write %i localized entries to database", (int)mColl->GetCount());
			
			while( !mColl->End() ) 
			{
				if(!LangDesc.LoadNameAndValue(mColl->GetFQN(),mColl->GetLocalizedString(),mColl->GetLanguageCode())) 
				{
					mLogger.LogThis(LOG_WARNING, "Failed to insert an entry into table, possible duplicate entry, proceeding.");
				}
				mColl->Next();
			}

			// load blank description here.  descload does it, but not this 
			mLogger.LogThis(LOG_DEBUG, "About to load blank description");
			if(!LangDesc.LoadBlankDescription())
			{
				mLogger.LogThis(LOG_WARNING, "Failed to load blank description.");
				return E_FAIL;
			}
			
			mLogger.LogThis(LOG_DEBUG, "Done.");
			mLogger.LogThis(LOG_DEBUG,"Signalling dblocale object to refresh.");

			ConfigChangeEvent event;
			event.Init("DbLocaleChangeEvent");
			event.Signal();
		}
		catch (_com_error err)
		{
			mLogger.LogVarArgs(LOG_ERROR, "Error returned: <%s>", err.Description());
			return (E_FAIL);
		}
		return hr;
		
}

HRESULT DeployLocale::GetLanguageCodes(vector<_bstr_t>& lang_codes)
{
	_bstr_t queryString ;
	wstring wstrCmd;
	HRESULT hr = S_OK;
	//initialize query adapter
	IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
	
	// initialize the queryadapter ...
	
	queryAdapter->Init(DB_CONFIG_PATH) ;
	
	// extract and detach the interface ptr ...
	mpQueryAdapter = queryAdapter.Detach() ;
	
	try
	{
		_bstr_t queryTag ;
		
		// set the query tag and initialize the parameter list ...
		mpQueryAdapter->ClearQuery() ;
		
		queryTag = "__GET_LANGUAGE_CODES__" ;
		mpQueryAdapter->SetQueryTag (queryTag) ;
		
		// get the query ...
		_bstr_t queryString ;    
		queryString = mpQueryAdapter->GetQuery() ;
		wstrCmd = (wchar_t*) queryString;
		
	}
	catch (_com_error e)
	{
		mLogger.LogThis(LOG_ERROR, "Failed creating description table!");
		return E_FAIL;
	}
	// initialize the access to the database ...
	DBAccess myDBAccess ;
	DBSQLRowset myRowset ;

	if (!myDBAccess.Init((wchar_t*)_bstr_t(DB_CONFIG_PATH)))
	{
		mLogger.LogThis (LOG_ERROR, "Failed to initialize DBAccess") ;
		return E_FAIL;
	}
	else
	{
		// issue a query to get the items for the product ...
		if (!myDBAccess.Execute (wstrCmd, myRowset) )
		{
			mLogger.LogThis (LOG_ERROR, "Failed to execute Query") ;
			return E_FAIL;
		}
	}
	
	// iterate thru the rowset and populate the lang code collection ...
	wstring rwwLangCode ;
  BOOL bRetCode=TRUE ;
	while ((!myRowset.AtEOF()) && (bRetCode == TRUE))
	{
		// get the language code and lang id ...
		//myRowset.GetIntValue (_variant_t (DB_LANG_ID), nLangCode) ;
		myRowset.GetWCharValue (_variant_t (DB_LANG_CODE), rwwLangCode) ;
		StrToLower(rwwLangCode) ;
		
		// insert the values into the collection ...
		lang_codes.push_back(_bstr_t(rwwLangCode.c_str()));
		
		// move to the next record ...
		bRetCode = myRowset.MoveNext() ;
	}

	return hr;
}

