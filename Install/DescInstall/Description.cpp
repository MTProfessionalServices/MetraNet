// Description.cpp: implementation of the Description class.
//
//////////////////////////////////////////////////////////////////////

#include "Description.h"
#include <ConfigDir.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcConnection.h>
#include <OdbcConnMan.h>
#include <autoptr.h>

#import <MTLocaleConfig.tlb>
#import <MTNameIDLib.tlb>
using namespace MTNAMEIDLib;
#include <mtprogids.h>
#include <LanguageList.h>
#include <autoinstance.h>
#include <OdbcException.h>
#include <stdutils.h>
#include <set>

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
Description::Description()
{
}

Description::~Description()
{
}

BOOL 
Description::Init()
{
  HRESULT nRetVal=S_OK ;
	const char* procName = "Description::Init";

  // initialize the logger ...
  LoggerConfigReader configReader;
  mLogger.Init(configReader.ReadConfiguration("DescInstall"), "[DescInstall]");

	try
	{
		// create the MTSQLRowset ...
    mpRowset.CreateInstance("MTSQLRowset.MTSQLRowset.1") ;

    // initialize the rowset ...
    mpRowset->Init ("\\Queries\\Localization") ;
	}
	catch(_com_error& e)
	{
		mLogger.LogVarArgs(LOG_ERROR, 
											 "%s() failed. Unable to initialize. Error = %x. Description: %s", 
											 procName, e.Error(), (char*)e.Description()) ;
    return FALSE ;
	}

	return TRUE;
}


BOOL 
Description::TruncateDescriptionTable()
{
	const char* procName = "Description::TruncateDescriptionTable";

	try
	{
		mpRowset->SetQueryTag("__DELETE_ENUM_DESCRIPTIONS__") ;
		mpRowset->Execute() ;
	}
	catch (_com_error&)
	{
		mLogger.LogVarArgs(LOG_ERROR, 
											 "Error calling TruncateDescriptionTable(): %s", procName) ;
	}

	return TRUE;
}

BOOL 
Description::LoadDescription()
{
	const char* procName = "Description::LoadDescription";

	// truncate the table first
	if (!TruncateDescriptionTable())
	{
		mLogger.LogThis(LOG_ERROR, "Truncation of t_description table failed") ;
		return FALSE;
	}


	try {
		
		string aConfigDir;
		GetMTConfigDir(aConfigDir);

		LangDescription LangDesc;
	
		// step 2: iniitalize the langdesc object
		if (!LangDesc.Init())
		{
			mLogger.LogVarArgs(LOG_ERROR, "Error calling LangDesc.Init(): %s", procName) ;
			return FALSE;
		}

		// step 3: create a mtlocalconfig object
		MTLOCALECONFIGLib::ILocaleConfigPtr aLocalConfig("Metratech.LocaleConfig.1");

		aLocalConfig->Initialize("",_bstr_t(""));
		aLocalConfig->LoadLanguage("");

		//step 3b: inserts a special blank description with id 0 used
		//for optional enum type properties (CR4434)
		LangDesc.LoadBlankDescription();

		// step 5: get an instance of the collection
		MTLOCALECONFIGLib::IMTLocalizedCollectionPtr aCollection = aLocalConfig->GetLocalizedCollection();
		IMTNameIDPtr pNameId(MTPROGID_NAMEID);

		
		COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
		MTautoptr<COdbcConnection> odbcConnection = new COdbcConnection(info);
		MTautoptr<COdbcPreparedArrayStatement> arrayStatement = 
			odbcConnection->PrepareInsertStatement(
			"t_description",aCollection->GetSize());

		MTAutoSingleton<CLanguageList> langList;
		const ReverseLanguageList& alist = langList->GetReverseLanguageList();
		std::set<std::string> unknownLanguageCodes;

		arrayStatement->BeginBatch();

		// step 6: iterate through the collection
		aCollection->Begin();
		while( !aCollection->End() ) {

			string aTempVal = (const char*)aCollection->GetLanguageCode();
			StrToLower(aTempVal);
			ReverseLanguageListIterator iter = alist.find(_bstr_t((aTempVal).c_str()));

			if(iter == alist.end())
			{
				if(unknownLanguageCodes.find(aTempVal) == unknownLanguageCodes.end())
				{
					unknownLanguageCodes.insert(aTempVal);
					cout << "Unknown language code: [" <<  aTempVal.c_str() << "]. Skipping all localization files with this language code" << endl;
				}
				aCollection->Next();
				continue;
			}

			//id_desc
			arrayStatement->SetInteger(1,pNameId->GetNameID(aCollection->GetFQN()));
			
			//id_lang_code
			arrayStatement->SetInteger(2,(*iter).second);

			//tx_desc
			arrayStatement->SetWideString(3,(const wchar_t*)aCollection->GetLocalizedString());
/*
      switch(info.GetDatabaseType()) {
			case COdbcConnectionInfo::DBTYPE_SQL_SERVER:
			case COdbcConnectionInfo::DBTYPE_ORACLE:
				arrayStatement->SetWideString(3,(const char*)aCollection->GetLocalizedString()); break;
			default:
				ASSERT(!"Did someone introduce a new database type and not tell me?");
			}
      */
			// this isn't really null

			//tx_URL_desc
			arrayStatement->SetWideString(4,L"");
			arrayStatement->AddBatch();

			aCollection->Next();
		}
		// write to DB!!
		arrayStatement->ExecuteBatch();

	}
	catch(_com_error& e)
	{
		mLogger.LogVarArgs(LOG_FATAL,"Failed to load description table: Error %s",(const char*)(e.Description()));
		cout << "Failed to load description table: Error " << ((const char*)e.Description()) << endl;
		return FALSE;
	}
	catch(COdbcException& odbjException) {
		mLogger.LogVarArgs(LOG_FATAL,"Failed to load description table: Error %s",(const char*)(odbjException.getMessage().c_str()));
		cout << "Failed to load description table: Error " << ((const char*)odbjException.getMessage().c_str()) << endl;
		return FALSE;
	}

	return TRUE;
}

