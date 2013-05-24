 // MTAccountFinder.cpp : Implementation of CMTAccountFinder
#include "StdAfx.h"
#include "MTAccount.h"
#include "MTAccountFinder.h"
#include "MTAccountPropertyCollection.h"
#include "MTSearchResultCollection.h"
#include <mtprogids.h>

#include <mtcomerr.h>
#include <mtparamnames.h>
#include <RcdHelper.h>
#include <stdutils.h>
#include <mtglobal_msg.h>
#include <DBMiscStlUtils.h>


#define DEFAULT_NAMESPACE_TYPE "system_mps";

/////////////////////////////////////////////////////////////////////////////
// CMTAccountFinder

STDMETHODIMP CMTAccountFinder::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountFinder
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMTAccountFinder::get_MaxRows(long *pVal)
{
	*pVal = mMaxRows; 
	return S_OK;
}


STDMETHODIMP CMTAccountFinder::put_MaxRows(long newVal)
{
	mMaxRows = newVal;
	return S_OK;
}


STDMETHODIMP CMTAccountFinder::Search(IMTAccountPropertyCollection *apAPC,  IMTSearchResultCollection ** appSRC)
{
	HRESULT hr = S_OK;

	SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, MTACCOUNTLib::IMTAccountPropertyPtr> it;
	hr = it.Init(apAPC);
	if(FAILED(hr)) return E_FAIL;

	if(mpSRC) mpSRC->Clear();

	// initialize [out] parameter
	if(appSRC)
		*appSRC = 0;
	else
		return E_POINTER;

	// iterate thru input and try to match it against the property map
	while(TRUE)
	{
		MTACCOUNTLib::IMTAccountPropertyPtr pAP = it.GetNext();
		if(pAP == NULL) break;

		_bstr_t bstrName = pAP->GetName();
		string strName = (const char*)bstrName;

		// perform lookup
		CFindProp * pProp;

		FindPropMap::iterator p = mPropMap.find(strName);
		if(p != mPropMap.end())
		{
			pProp = (*p).second;
			ASSERT(pProp);

			if(pProp->strTN == "LDAP")
				mSearchType = CONTACT;
			else
				mSearchType = ACCOUNT;
		}
		else
		{
			string strMsg = "<" + strName + "> is unknown property";
			mLogger->LogVarArgs(LOG_ERROR, strMsg.c_str());
			return Error(strMsg.c_str(), IID_IMTAccountFinder, UNKNOWN_SEARCH_PARAMETER);
		}
	}

	switch(mSearchType)
	{
	case CONTACT:
		
		long lCount;
		
		hr = SearchLDAPForContactInfo(lCount, 0, apAPC);
		if(FAILED(hr))
		{
			return Error("Search on contact failed", IID_IMTAccountFinder, hr);
		}
			
		break;

	case ACCOUNT:
		
		// search for account ids based on search input
		hr = SearchForAccountIDs(apAPC);
		if(FAILED(hr))
		{
			return Error("Search on account failed", IID_IMTAccountFinder, hr);
		}

		AccMap::const_iterator p = mAccMap.begin();
		long AccIdsLeft = mAccMap.size();
		
		// for each account id query LDAP server or adapters 
		switch(mContactSrc)
		{
		case LDAP:
			
			while(p != mAccMap.end())
			{
				long lCount;

				hr = SearchLDAPForContactInfo(lCount, p->first);
				if(FAILED(hr))
				{
					return Error("Search on contact failed", IID_IMTAccountFinder, hr);
				}
				/*
				// in case there are no records in LDAP get the rest of the data from adapters anyway
				if(lCount == 0)	
				{
					hr = GetDataForAccID(p->first);
					if(FAILED(hr))
						return Error("Retrieval of account data failed", IID_IMTAccountFinder, hr);
				}
				*/
				//else
				if(lCount > 0)	
				{
					// after contacts are added to the output verify that we are still within the limit 
					AccIdsLeft--;  mpSRC->get_Count(&lCount);
					
					if((AccIdsLeft + lCount) > mMaxRows)
					{
						return Error("Search on contact failed", IID_IMTAccountFinder, TOO_MANY_ACCOUNTS);
					}						
				}
				p++;
			}	
			break;

		case SQL:

			while(p != mAccMap.end())
			{
					hr = GetDataForAccID(p->first);
					if(FAILED(hr))
						return Error("Retrieval of account data failed", IID_IMTAccountFinder, hr);
					
				p++;
			}	
		}
		break;
	}
				
	// copy results to [out] paramter 
	hr = mpSRC->QueryInterface(appSRC);
	ASSERT(SUCCEEDED(hr));

	return hr;
}


HRESULT CMTAccountFinder::FinalConstruct()
{	
	HRESULT hr = S_OK;
	_bstr_t configPath = MTACCOUNT_CONFIG_PATH;
	
	// initialize the database access layer
	if(!DBAccess::Init((wchar_t *)configPath))
	{
	    SetError(DBAccess::GetLastError());
		mLogger->LogThis(LOG_ERROR, "Database initialization failed for AccountFinder object");
		return Error("Database initialization failed for AccountFinder object", IID_IMTAccountFinder, E_FAIL);
	}
	
	// initialize query adapter server
	try
	{
		mpQueryAdapter.CreateInstance(MTPROGID_QUERYADAPTER);
		mpQueryAdapter->Init(configPath);
	}
	catch (_com_error & e)
	{
		ErrorObject * err = CreateErrorFromComError(e);
		SetError(err);
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());

		delete err;
		return ReturnComError(e);
	}
	
	// initialize enum config server
	hr = mpEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);	
	if(FAILED(hr))
		return Error("EnumConfig object creation failed for AccountFinder object", IID_IMTAccountFinder, hr);

	// create LDAP adapter server 
	hr = CComObject<CMTLDAPAdapter>::CreateInstance(&mpLDAPServer);
	if(FAILED(hr))
		return Error("LDAP Adapter object creation failed for AccountFinder object", IID_IMTAccountFinder, hr);

	// create search results server
	CComObject<CMTSearchResultCollection> * mpSRCServer;
	hr = CComObject<CMTSearchResultCollection>::CreateInstance(&mpSRCServer);
	if(FAILED(hr))
		return Error("Search results object creation failed for AccountFinder object", IID_IMTAccountFinder, hr);
	mpSRC = mpSRCServer;

	hr = InitializeAdapters();
	if(FAILED(hr))
		return hr;
				
	PopulateFindPropMap();
	
	return S_OK;
}


void CMTAccountFinder::FinalRelease()
{
	
	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
	    SetError(DBAccess::GetLastError());
	    mLogger->LogThis(LOG_ERROR, "Database disconnect failed");
	}

	delete mpLDAPServer;
	mpLDAPServer = NULL;

	// release account search collection
	mpAccountSRC.Release();

	// release adapters
	typedef AdapterMap::const_iterator ACI;
	for(ACI ap = mAdapterMap.begin(); ap != mAdapterMap.end(); ++ap)
	{
		CAdapterInfo * pAdapterInfo = ap->second;
		
		delete pAdapterInfo;
		pAdapterInfo = NULL;
	}

	// clean up property map		
	typedef FindPropMap::const_iterator PCI;
	for(PCI fp = mPropMap.begin(); fp != mPropMap.end(); ++fp)
	{
		CFindProp * pProp = fp->second;

		delete pProp;
		pProp = NULL;		
	}
	
	return;
}


HRESULT CMTAccountFinder::InitializeAdapters()
{
	VARIANT_BOOL aCheckSumMatch;
	const char* procName = "CMTAccountFinder::InitializeAdapters";
	
	_bstr_t bstrAdapterName; //(AdapterName);
	bool bDone = false;

	try
	{
		// run the Query 
		MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);

		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\account\\AccountAdapters.xml",VARIANT_TRUE);

		if(aFileList->GetCount() == 0) {
			// log error that we can't find any configuration
			const char* pErrorMsg = "CMTAccountFinder::Initialize: can not find any configuration files";
			mLogger->LogThis(LOG_ERROR,pErrorMsg);
			return Error(pErrorMsg);
		}

		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		if(FAILED(it.Init(aFileList))) return E_FAIL;

		while(!bDone) 
		{

			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0) {
				bDone = true;
				break;
			}

			MTConfigLib::IMTConfigPropSetPtr aPropSet = aConfig->ReadConfiguration(afile,&aCheckSumMatch);
			MTConfigLib::IMTConfigPropSetPtr aAdapterSet = aPropSet->NextSetWithName(ADAPTER_SET_TAG);
			while (aAdapterSet != NULL)
			{
				_bstr_t name, ProgID, ConfigFile;				
				
				name = aAdapterSet->NextStringWithName(NAME_TAG);
				ProgID = aAdapterSet->NextStringWithName(PROGID_TAG);
				ConfigFile = aAdapterSet->NextStringWithName(CONFIGFILE_TAG);
				
				// adapter has account view and therefore a table, so it should be included in the search
				if(ConfigFile.length() != 0)
				{	
					string strName = (const char*)name;
					wstring strConfig = (const wchar_t*)ConfigFile;
					
					CComObject<CMTAccountServer> * pAS;
					HRESULT hr = CComObject<CMTAccountServer>::CreateInstance(&pAS);
					ASSERT(SUCCEEDED(hr));
					
					CComPtr<IMTAccountAdapter> pAccServer = pAS;
					hr = pAccServer->Initialize(name);
					if(FAILED(hr))
					{
						_bstr_t buffer = "Failed to initialize " + name + " adapter";
						mLogger->LogThis(LOG_ERROR, (const char*)buffer);
						return Error((const char*)buffer, IID_IMTAccountFinder, hr);
					}
					
					mAdapterMap[strName] = new CAdapterInfo(strConfig, pAccServer);							
				}

				aAdapterSet = aPropSet->NextSetWithName(ADAPTER_SET_TAG);
			}
		}
	}
	catch(_com_error& e) 
	{
		_bstr_t bstrError = e.Description();
		if(bstrError.length() == 0) 
		  bstrError = "No detailed information"; 

		mLogger->LogVarArgs(LOG_ERROR, "%s : failed with error \"%s\"", procName, 
						   (const char*)bstrError);
		return ReturnComError(e);
	}

	return S_OK;
}


void CMTAccountFinder::PopulateFindPropMap()
{
	HRESULT hr;
	CMSIXDefinition * pAccDef = NULL;
	CComObject<CMTSQLAdapter> * pAccViewFinder = NULL;
	
	hr = CComObject<CMTSQLAdapter>::CreateInstance(&pAccViewFinder);		
	ASSERT(SUCCEEDED(hr));

	AdapterMap::const_iterator p;

	for(p = mAdapterMap.begin(); p != mAdapterMap.end(); ++p)
	{	
		CAdapterInfo * pAdapter;
		pAdapter = p->second;

		pAccViewFinder->FindAccountView((pAdapter->strConfigFile).c_str(), pAccDef);
		ASSERT(pAccDef);

		MSIXPropertiesList list = pAccDef->GetMSIXPropertiesList();

		string strCN, strDN;
		string strTN = ascii(pAccDef->GetTableName());
		PropType type;

		MSIXPropertiesList::iterator it;
		for (it = list.begin(); it != list.end(); ++it)
		{
			CMSIXProperties * prop = *it;
			CFindProp * pProp;

			strDN = ascii(prop->GetDN());
			strCN = ascii(prop->GetColumnName());

			// make distinguished name upper case, for case-insensitive comparisons.
			StrToUpper(strDN);
			
			type = prop->GetPropertyType();

			pProp = new CFindProp(strTN, strCN, type);

			mPropMap[strDN] = pProp;
		}
	}

	delete pAccViewFinder;
	pAccViewFinder = NULL;

	// additional searchable fields that are not mappable thru account view 
	mPropMap["USERNAME"] = new CFindProp("t_account_mapper", "nm_login", CMSIXProperties::TYPE_WIDESTRING);
	mPropMap["NAME_SPACE"] = new CFindProp("t_account_mapper", "nm_space", CMSIXProperties::TYPE_STRING);
	mPropMap["ALIAS"] = new CFindProp("t_account_mapper","nm_login", CMSIXProperties::TYPE_WIDESTRING);
	//Bug 3821: Need to search on invoice_string, and not on id_invoice
	//mPropMap["INVOICE_NUMBER"] = new CFindProp("t_invoice","id_invoice", CMSIXProperties::TYPE_INT32);
	mPropMap["INVOICE_NUMBER"] = new CFindProp("t_invoice","invoice_string", CMSIXProperties::TYPE_STRING);
	


	//if adapter with the name LDAP is not found then it does account view, so it is LDAP implementation
	p = mAdapterMap.find("LDAP");
	if(p == mAdapterMap.end())
	{
		string LDAPAttributes[] = {"FIRSTNAME","LASTNAME","EMAIL","COMPANY","PHONENUMBER",
			"FACSIMILETELEPHONENUMBER","ADDRESS1","ADDRESS2","ADDRESS3","CITY","STATE","ZIP","COUNTRY"};		
	
		for(int i = 0; i < 13; i++)
		{
			string attrib = LDAPAttributes[i];
			mPropMap[attrib] = new CFindProp("LDAP", attrib, CMSIXProperties::TYPE_STRING);
		}

		mContactSrc = LDAP;
	}
	else
		mContactSrc = SQL;

	return;
}

HRESULT CMTAccountFinder::SearchForAccountIDs(IMTAccountPropertyCollection * apAPC)
{
	HRESULT hr = S_OK;	   
	DBSQLRowset rowset;							// returned by DBAccess::Execute
	wstring langRequest;						// actual query 
	
	string strSearchCondition;					// conditions for the rows returned
	set<string> JoinedTables;					// table names to join
	string strJoinedTables;						// table names to join for FROM clause					
	BOOL bNameSpaceSpecified = FALSE;

	const char* procName = "CMTAccountFinder::SearchForAccountIDs";
	
	JoinedTables.insert("t_account_mapper");

	string strNameSpace = "";
	long Count = 0;
	bool bAliasSearch = false;
	
	CComPtr<IMTAccountPropertyCollection> pAPC(apAPC);
	hr = pAPC->get_Count(&Count);

	for(int i = 1; i <= Count; i++)
	{
		CComQIPtr<IMTAccountProperty> pAP;	
		CComVariant vtAP;
		
		hr = pAPC->get_Item(CComVariant(i), &vtAP);


		CComVariant vtValue;
		
		pAP = vtAP.pdispVal;

		BSTR bstrNameTemp;
		pAP->get_Name(&bstrNameTemp);
		// attach to the string so we don't have to free it
		_bstr_t bstrName(bstrNameTemp, false);

		pAP->get_Value(&vtValue);

		string strName = (const char*)bstrName;
		
		hr = vtValue.ChangeType(VT_BSTR);
		ASSERT(SUCCEEDED(hr));
		string strValue = (const char*)_bstr_t(vtValue.bstrVal);

		if(strName == "NAME_SPACE")
		{
			bNameSpaceSpecified = TRUE;
			strNameSpace = strValue;
		}

		if(strName == "ALIAS")
			bAliasSearch = true;
	
		// perform lookup on parameter name
		CFindProp * pProp;

		FindPropMap::iterator p = mPropMap.find(strName);
		pProp = (*p).second;
	
		string strTableSource;			// table from which to retrieve rows
		strTableSource = pProp->strTN;

		string strExpression;

		set<string>::iterator p1 = JoinedTables.find(strTableSource);
		if (p1 == JoinedTables.end())
		{
			strExpression = "t_account_mapper.id_acc=" + strTableSource + ".id_acc AND ";
			JoinedTables.insert(strTableSource);
		}


		if(	pProp->type == CMSIXProperties::TYPE_STRING || 
				pProp->type == CMSIXProperties::TYPE_WIDESTRING || 
				pProp->type == CMSIXProperties::TYPE_BOOLEAN)
		{
      // for all string based properties do a lower so we do a caseless compare ...
   		strExpression += "LOWER (" + strTableSource + "." + pProp->strCN + ")" ;

			// find all occurances of wild flag '*' and replace with SQL '%' 
			string::size_type i = 0;
			bool bWildCard = false;

			while(string::npos != (i = strValue.find('*', i)))
			{
				strValue.replace(i, 1, "%");
				bWildCard = true;
			}
      
			// call ValidateString to escape any single quotes ...
			strValue = ValidateSTLString (strValue) ;
			
			// if wild card found, build expression with LIKE
			if (pProp->type == CMSIXProperties::TYPE_WIDESTRING)
			{
				if(bWildCard)
					strExpression += " LIKE LOWER(N'" + strValue + "')"; 
				else
					strExpression += "= LOWER(N'" + strValue + "')"; 
			}
			else
			{
				if(bWildCard)
					strExpression += " LIKE LOWER('" + strValue + "')"; 
				else
					strExpression += "= LOWER('" + strValue + "')"; 
			}
		}
		else
    {
      strExpression += strTableSource + "." + pProp->strCN ;
			strExpression += '=' + strValue;
    }

		// build search condition for SELECT statement
		if(i != Count)
			strSearchCondition += strExpression + " AND ";
		else
			strSearchCondition += strExpression;

	}

	//If namespace was not specified, then join against t_namespace to get 
	//system_mps-typed namespace
	if(!bNameSpaceSpecified)
	{
		JoinedTables.insert("t_namespace");
		strSearchCondition	+=	" AND t_account_mapper.nm_space = t_namespace.nm_space ";
		strSearchCondition	+=	" AND t_namespace.tx_typ_space=N'";
		strSearchCondition	+=	DEFAULT_NAMESPACE_TYPE;
		strSearchCondition	+=	"'";
	}

	for (set<string>::iterator p = JoinedTables.begin(); p != JoinedTables.end(); ++p)
	{
		if(p != JoinedTables.begin())
			strJoinedTables += ",";

		strJoinedTables += *p;
	}

	
	try
  {
		mpQueryAdapter->ClearQuery();			
		mpQueryAdapter->SetQueryTag(L"__GET_ACCOUNT_ID__");
				
		mpQueryAdapter->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, _variant_t(strJoinedTables.c_str()));
		mpQueryAdapter->AddParam(MTPARAM_WHERE_CLAUSE, _variant_t(strSearchCondition.c_str()), VARIANT_TRUE);
		
		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error & e)
	{
		ErrorObject * err = CreateErrorFromComError(e);
		SetError(err);
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		
		delete err;
		return (_com_error::WCodeToHRESULT(e.WCode()));
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return GetLastErrorCode();
	}
	
	long count = rowset.GetRecordCount();
	
	mLogger->LogVarArgs(LOG_DEBUG, "Found %ld matching account ids", count);
	
	if(count > mMaxRows)
	{
		string buffer = "Too many account records where found";
    	SetError(TOO_MANY_ACCOUNTS, ERROR_MODULE, ERROR_LINE, procName, buffer.c_str());
		return TOO_MANY_ACCOUNTS;
	}

	BOOL bRetCode = TRUE;
	while(!rowset.AtEOF() && bRetCode)
	{
		long AccID;
		
		rowset.GetLongValue(CComVariant(0), AccID);
		if (bAliasSearch)
			mAccMap[AccID] = "";
		else
			mAccMap[AccID] = strNameSpace;

		bRetCode = rowset.MoveNext();
	}

	return S_OK;
}


HRESULT CMTAccountFinder::SearchLDAPForContactInfo(long & aCount, long aAccID /*= 0*/, IMTAccountPropertyCollection * apAPC /*= NULL*/)
{
	HRESULT	hr = S_OK;
	long lAccID = 0;							// account ID retrieved from LDAP	
	bool bNewID = false;						// indicator that Account ID has changed 
	CComPtr<IMTSearchResultCollection> pSRC;	// LDAP search results
	MTACCOUNTLib::IMTSearchResultCollection* pAdapterSearchSRCPtr = NULL;	// temp var used to get resuls from GetAdaptersData method
	MTACCOUNTLib::IMTSearchResultCollection* pAccountSearchSRCPtr = NULL;	// temp var used to get resuls from GetAccountsData method
	MTACCOUNTLib::IMTSearchResultCollectionPtr pTempSRC = NULL;
	MTACCOUNTLib::IMTSearchResultCollection* pMergedSRC = NULL;
	MTACCOUNTLib::IMTSearchResultCollection* pFinalSRC = NULL;
	const char* procName = "CMTAccountFinder::SearchLDAPForContactInfo";
	CComPtr<IMTAccountPropertyCollection> pAPC;	

	// if the search is account-based, LDAP needs an account ID to search on

	if(apAPC == NULL) //if(mSearchType == ACCOUNT) 
	{
		/*
			that means that we need to create a IMTAccountPropertyCollection collection
			and only add one property - accountid - to it
		*/
		ASSERT(aAccID);
		
		CComObject<CMTAccountPropertyCollection>* APC;		
		// create new input collection and populate it with account ID
		CComObject<CMTAccountPropertyCollection>::CreateInstance(&APC);
		pAPC = APC;
		
		CComPtr<IMTAccountProperty> pAP;
		pAPC->Add(L"_accountid", _variant_t(aAccID), &pAP);

		mpLDAPServer->SearchData(L"LDAP", pAPC, _variant_t(NULL), &pSRC);
	}
	else
		// use collection that was passed from the client
		mpLDAPServer->SearchData(L"LDAP", apAPC, _variant_t(NULL), &pSRC);

	// retrieve number of LDAP contacts retrieved
	pSRC->get_Count(&aCount);
	
	// for contact-based search check to see if we exceeded number of max records
	if(mSearchType == CONTACT && aCount > mMaxRows)
	{	
		string buffer = "Too many contact records were found in LDAP";
    	SetError(TOO_MANY_ACCOUNTS, ERROR_MODULE, ERROR_LINE, procName, buffer.c_str());
		return TOO_MANY_ACCOUNTS;
	}	

	// for contact-based search check to see if we got any records at all
	if(mSearchType == CONTACT && aCount == 0)
	{	
		string buffer = "No contact records were found in LDAP";
    	SetError(NO_CONTACT_RECORDS_FOUND, ERROR_MODULE, ERROR_LINE, procName, buffer.c_str());
		return NO_CONTACT_RECORDS_FOUND;
	}	

	//for account based search if no contact records were found
	//then we still want to search adapters and extended account info
	//at this point insert one APC collection into SRC just not to fail it.Next() and get account id from there
	if(aCount == 0)
	{	
		hr = pSRC->Add(pAPC);
	}	

	SetIterator<CComPtr<IMTSearchResultCollection>, MTACCOUNTLib::IMTAccountPropertyCollectionPtr> it;
	hr = it.Init(pSRC);
	if(FAILED(hr)) return hr;

	
	while(true)
	{
		MTACCOUNTLib::IMTAccountPropertyCollectionPtr pAPC = it.GetNext();
		if (pAPC == NULL) break;
			
		MTACCOUNTLib::IMTAccountPropertyPtr pAP = pAPC->GetItem(L"_ACCOUNTID"); 		
			
		_variant_t value = pAP->GetValue();
			
		// if new account id is different from last one then
		if(lAccID != (long)value)
		{
			lAccID = value;
			bNewID = true;
		}
		else
			bNewID = false;
	
		//Potentially the below two methods can return multiple APC objects, if there were multiple records
		//that matched the search criteria. So pAPC record could multiply by a number of APC records
		//returned from below methods in order to store all search results
		AdapterMap::iterator aItr;
		hr = GetDataFromAdapters(aItr, lAccID, bNewID, 	(IMTSearchResultCollection**)&pAdapterSearchSRCPtr);
		if(FAILED(hr))
			return hr;
		hr = GetDataFromAccount(lAccID, bNewID, 	(IMTSearchResultCollection**)&pAccountSearchSRCPtr);
		if(FAILED(hr))
			return hr;

		hr = MergeCollections((IMTSearchResultCollection*)pAdapterSearchSRCPtr, 
												(IMTSearchResultCollection*)pAccountSearchSRCPtr, 
												(IMTSearchResultCollection**)&pMergedSRC);
		if(FAILED(hr))
			return hr;

		//Create temp SRC object, add APC to it in order to call MergeCollection
		hr = pTempSRC.CreateInstance(MTPROGID_MTSEARCHRESULTCOLLECTION);
		if(FAILED(hr)) 
			return hr;

		try
		{
			pTempSRC->Add(pAPC.GetInterfacePtr());

			hr = MergeCollections((IMTSearchResultCollection*)pMergedSRC, 
													(IMTSearchResultCollection*)pTempSRC.GetInterfacePtr(), 
													(IMTSearchResultCollection**)&pFinalSRC);
			if(FAILED(hr)) return hr;
		}
		catch(_com_error& e)
		{
			return ReturnComError(e);
		}
	
	}

	
	//mpSRC.Attach((IMTSearchResultCollection *)pFinalSRC);
	mpSRC->Append((IMTSearchResultCollection *)pFinalSRC);

	pAdapterSearchSRCPtr->Release();
	pAccountSearchSRCPtr->Release();
	pMergedSRC->Release();
	pTempSRC.Release();
	pFinalSRC->Release();
	
	return S_OK;
}


HRESULT CMTAccountFinder::GetDataForAccID(long aAccID)
{
	HRESULT hr = S_OK;
	AdapterMap::iterator aItr;
	MTACCOUNTLib::IMTSearchResultCollection* pSRC = NULL;
	MTACCOUNTLib::IMTSearchResultCollection* pAccSRC = NULL;
	MTACCOUNTLib::IMTSearchResultCollection* pMergedSRC = NULL;
	
	hr = GetDataFromAdapters(aItr, aAccID, true, (IMTSearchResultCollection**)&pSRC);
	if(FAILED(hr))
		return hr;
	
	hr = GetDataFromAccount(aAccID, true, (IMTSearchResultCollection**)&pAccSRC);
	if(FAILED(hr))
		return hr;

	hr = MergeCollections((IMTSearchResultCollection*)pSRC, 
												(IMTSearchResultCollection*)pAccSRC, 
												(IMTSearchResultCollection**)&pMergedSRC);
	if(FAILED(hr))
		return hr;
	
	//pMergedSRC->QueryInterface(__uuidof(MTACCOUNTLib::IMTSearchResultCollection), (void**)&mpSRC);
	pSRC->Release();
	pAccSRC->Release();
	//mpSRC.Attach((IMTSearchResultCollection *)pMergedSRC);
	ASSERT(mpSRC != NULL);
	mpSRC->Append((IMTSearchResultCollection *)pMergedSRC);
	pMergedSRC->Release();
	return S_OK;
}


HRESULT CMTAccountFinder::GetDataFromAdapters(AdapterMap::iterator& aItr, long aAccID, bool aNewID, IMTSearchResultCollection** apSRC)
{
	HRESULT hr = S_OK;
	CAdapterInfo * pAdapterInfo;
	MTACCOUNTLib::IMTSearchResultCollectionPtr pNewSRCPtr;
	MTACCOUNTLib::IMTSearchResultCollectionPtr pTemp;

	hr = pNewSRCPtr.CreateInstance(MTPROGID_MTSEARCHRESULTCOLLECTION);

	if(!SUCCEEDED(hr))
	{
		return hr;
	}
	
	//1. Assume that if collection passed in is NULL, then it's the first time through,
	//initialize iterator, if not, then advance iterator
	if(!*apSRC)
	{
		aItr = mAdapterMap.begin();
		MTACCOUNTLib::IMTSearchResultCollectionPtr temp;
		hr = temp.CreateInstance(MTPROGID_MTSEARCHRESULTCOLLECTION);
		ASSERT(SUCCEEDED(hr));
		hr = temp->QueryInterface(__uuidof(MTACCOUNTLib::IMTSearchResultCollection), (void**)apSRC);
	}	
	else
	{
		if (++aItr ==  mAdapterMap.end())
		{
			return S_OK;
		}
	}
	
	//2.	Get current adapter pointer
	pAdapterInfo = aItr->second;
	CComPtr<IMTAccountAdapter> pAdapterServer = pAdapterInfo->pAdapter;   
	
	CComPtr<IMTSearchResultCollection> pSRC = pAdapterInfo->pSRC;
	
	//3. Create Search Criteria collection and init it with account id
	MTACCOUNTLib::IMTAccountPropertyCollectionPtr pAPCPtr;	
	hr = pAPCPtr.CreateInstance(MTPROGID_MTACCOUNTPROPERTYCOLLECTION);
	
	if(!SUCCEEDED(hr))
	{
		return hr;
	}
	
	ASSERT(pAPCPtr != NULL);
	pAPCPtr->Add(L"id_acc", _variant_t(aAccID));
	
	if(aNewID)
	{
		// get adapter name from adapter map key 
		_bstr_t bstrAdapterName = (aItr->first).c_str();

			mLogger->LogVarArgs(LOG_DEBUG, 
							"Searching Data on <%s> adapter", (const char*) bstrAdapterName);
		
		// destroy cached results and execute new query
		pSRC.Release();	
		
		hr = pAdapterServer->SearchData(bstrAdapterName, (IMTAccountPropertyCollection *)pAPCPtr.GetInterfacePtr(), _variant_t(NULL), &pSRC);
		
		if(FAILED(hr))
		{
			// CR4834: Return no data only for Internal Adapter
  			if (0 == _wcsicmp(bstrAdapterName, L"Internal") && (hr == ACCOUNT_NOT_FOUND))
				{
					mLogger->LogThis(LOG_ERROR, 
							"No records satisfying search criteria found in Internal Adapter, exiting.");
					return hr;
				}
				else if (hr == ACCOUNT_NOT_FOUND)
				{
						mLogger->LogVarArgs(LOG_DEBUG, 
							"Searching on <%s> adapter resulted no data", (const char*) bstrAdapterName);
				}
				else
					return hr;

		}
		
		pAdapterInfo->pSRC = pSRC;
	}		
		
	if (pSRC != NULL)
	{
		SetIterator<CComPtr<IMTSearchResultCollection>, MTACCOUNTLib::IMTAccountPropertyCollectionPtr> it;
		hr = it.Init(pSRC);
		
		if(FAILED(hr)) return hr;
		
		//4. These loops are only needed to replace desc ids for enum types for actual
		//enumeration strings
		while (true)
		{
			MTACCOUNTLib::IMTAccountPropertyCollectionPtr APCPtr = it.GetNext();
			if(APCPtr == NULL) break;
			SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, MTACCOUNTLib::IMTAccountPropertyPtr> it1;
			hr = it1.Init(APCPtr);
			ASSERT(SUCCEEDED(hr));
			
			while(true)
			{
				MTACCOUNTLib::IMTAccountPropertyPtr pAP = it1.GetNext();
				if(pAP == NULL) break;
				
				// if new query was executed then re-populate result collection cache 
				if(aNewID)
				{
					_bstr_t name;
					_variant_t value;
					
					name = pAP->GetName();
					value = pAP->GetValue();
					
					string strName = (const char*)name;
					
					// if paramter type is ENUM then get enum value
					CFindProp * pProp;
					FindPropMap::iterator p = mPropMap.find(strName);
					
					if(p == mPropMap.end())
					{
						mLogger->LogVarArgs(LOG_WARNING, 
							"Property <%s>, that came back from search is not defined in the list of properties, skipping it", 
							strName.c_str());
						continue;
					}
					
					
					pProp = (*p).second;
					
					if(pProp->type == CMSIXProperties::TYPE_ENUM)
					{
						try 
						{
							//Handle VT_NULL, because this property may be not required on MSIXDEF
							if(value.vt != VT_NULL)
								value = mpEnumConfig->GetEnumeratorValueByID(value.lVal);
						}
						catch(_com_error & e)
						{
							ErrorObject * err = CreateErrorFromComError(e);
							SetError(err);
							mLogger->LogErrorObject(LOG_ERROR, GetLastError());
							delete err;
							return (_com_error::WCodeToHRESULT(e.WCode()));
						}
						
						pAP->PutValue(value);				
					}
				}	
				
				// add new property to the [IN/OUT] collection
				//CComPtr<IMTAccountProperty> pAddedAP;
				//hr = apAPC->Add(pAP->GetName(),pAP->GetValue(), &pAddedAP);
				//ASSERT(SUCCEEDED(hr));
			}
			
			//CComPtr<IMTAccountPropertyCollection> pAddedAP;
			hr = pNewSRCPtr->Add(APCPtr);
			ASSERT(SUCCEEDED(hr));
		}
	}
	
	//5. Create summ collection of the one passed into the method with the one just generated
	//MTACCOUNTLib::IMTSearchResultCollectionPtr pSummSRCPtr;	

	//IMTSearchResultCollection* pSummSRCPtr;

	IMTSearchResultCollection * oldValues = *apSRC;

	*apSRC = NULL;

	hr = MergeCollections(	(IMTSearchResultCollection *)pNewSRCPtr.GetInterfacePtr(),
													oldValues,
													apSRC);

	// release the collection passed in
	oldValues->Release();
	oldValues = NULL;

	//6. Recursive call
	hr = GetDataFromAdapters(aItr, aAccID, aNewID, apSRC);
	return hr;
}


HRESULT CMTAccountFinder::GetDataFromAccount(long aAccID, bool aNewID, IMTSearchResultCollection** apSRC)
{
	HRESULT hr = S_OK;
	DBSQLRowset rowset;		// returned by DBAccess::Execute
	wstring langRequest;  // actual query
	MTACCOUNTLib::IMTSearchResultCollectionPtr pSRC;
	MTACCOUNTLib::IMTAccountPropertyCollectionPtr pAPC;
	
	
	hr = pSRC.CreateInstance(MTPROGID_MTSEARCHRESULTCOLLECTION) ;
	
	if(FAILED(hr)) return hr;
	
	const char * procName = "CMTAccountFinder::GetDataFromAccount";
	
	// if new query was executed then re-populate result collection cache 
	if(aNewID)
	{
		mpAccountSRC.Release();
		
		// retrieve namespace for this account id from the account map
		string strNameSpace = "b.nm_space = ns.nm_space AND ns.tx_typ_space=N'";
		strNameSpace += DEFAULT_NAMESPACE_TYPE;
		strNameSpace += "'";
		
		if(mSearchType == ACCOUNT)
		{
			AccMap::iterator p = mAccMap.find(aAccID);
			ASSERT(p != mAccMap.end());
			
			// search on namespace only if it is specified and this is not alias search
			string ns = (*p).second;
			if(ns != "")
			{
				strNameSpace = "b.nm_space =N'";
				strNameSpace += ns;
				strNameSpace += "'";
			}
		}		
		
		try
		{
			_variant_t vtNameSpace = strNameSpace.c_str();
			
			mpQueryAdapter->ClearQuery();
			mpQueryAdapter->SetQueryTag(L"__SEARCH_ACCOUNT_DATA__");
			mpQueryAdapter->AddParam(MTPARAM_ACCOUNTID, aAccID);
			mpQueryAdapter->AddParam(MTPARAM_NAMESPACE, vtNameSpace, VARIANT_TRUE);
			langRequest = mpQueryAdapter->GetQuery();
		}
		catch (_com_error & e)
		{
			ErrorObject * err = CreateErrorFromComError(e);
			SetError(err);
			mLogger->LogErrorObject(LOG_ERROR, GetLastError());
			
			delete err;
			return GetLastErrorCode();		
		}
		
		if(!DBAccess::Execute(langRequest, rowset))
		{
			SetError(DBAccess::GetLastError());
			mLogger->LogErrorObject(LOG_ERROR, GetLastError());
			return GetLastErrorCode();
		}
		
		if (rowset.GetRecordCount() == 0)
		{
			char szAccID[12];
			_ltoa_s(aAccID, szAccID, 10);
			
			string buffer = "The account not found in the database for accountID <" + string(szAccID) + ">";
    		SetError(ACCOUNT_NOT_FOUND, ERROR_MODULE, ERROR_LINE, procName, buffer.c_str());
				mLogger->LogThis(LOG_DEBUG, buffer.c_str());
				return ACCOUNT_NOT_FOUND;
		}
		
		_variant_t vtIndex; // column index 
		_variant_t vtValue; // column value
		
		wstring wstrName;	// column name
		_bstr_t	 bstrName;
		
		BOOL bRetCode = TRUE;
		try
		{
			while(!rowset.AtEOF() && bRetCode)
			{
				hr = pAPC.CreateInstance(MTPROGID_MTACCOUNTPROPERTYCOLLECTION) ;
				for(int i = 0; i < rowset.GetCount(); i++)
				{
					CComPtr<IMTAccountProperty> pAP;		
					vtIndex = (long)i;
					rowset.GetName(vtIndex, wstrName);
					rowset.GetValue(vtIndex, vtValue);
					// ORACLE FIX: change accountid to _accountid and currency to _currency ...
					if (_wcsicmp(wstrName.c_str(), L"accountid") == 0)
					{
						bstrName = "_accountid" ;
					}
					else if (_wcsicmp(wstrName.c_str(), L"currency") == 0)
					{
						bstrName = "_currency" ;
					}
					else
					{
						bstrName = _bstr_t(wstrName.c_str());
					}
					hr = pAPC->Add(bstrName, vtValue);
					ASSERT(SUCCEEDED(hr));
				}
				
				hr = pSRC->Add(pAPC);
				ASSERT(SUCCEEDED(hr));
				bRetCode = rowset.MoveNext();
			}
			mpAccountSRC = (IMTSearchResultCollection*)pSRC.GetInterfacePtr();
			
			(*apSRC) = (IMTSearchResultCollection*)pSRC.Detach();
		}
		catch(_com_error& e)
		{
			ErrorObject * err = CreateErrorFromComError(e);
			SetError(err);
			mLogger->LogErrorObject(LOG_ERROR, GetLastError());
			delete err;
			return (_com_error::WCodeToHRESULT(e.WCode()));
		}
	}
	return S_OK;
}

HRESULT CMTAccountFinder::MergeCollections(	IMTSearchResultCollection* aColl1, 
																						IMTSearchResultCollection* aColl2,
																						IMTSearchResultCollection** aResultColl)
{
	HRESULT hr = S_OK;
	MTACCOUNTLib::IMTSearchResultCollectionPtr pColl1Ptr = aColl1;
	MTACCOUNTLib::IMTSearchResultCollectionPtr pColl2Ptr = aColl2;
	MTACCOUNTLib::IMTSearchResultCollectionPtr pResultCollPtr;
	
	BOOL bNewCollection = (*aResultColl) ? FALSE : TRUE;

	hr = pResultCollPtr.CreateInstance(MTPROGID_MTSEARCHRESULTCOLLECTION);

	if(FAILED(hr)) return hr;

	//if either collection is empty just return the second one
	if((pColl1Ptr == NULL) ||pColl1Ptr->GetCount() == 0)
	{
		(*aResultColl) = (IMTSearchResultCollection *)pColl2Ptr.Detach();
		return hr;
	}

	if((pColl2Ptr == NULL) || pColl2Ptr->GetCount() == 0)
	{
		(*aResultColl) = (IMTSearchResultCollection *)pColl1Ptr.Detach();
		return hr;
	}

	MTACCOUNTLib::IMTSearchResultCollectionPtr pAddingCollPtr = 
										(pColl2Ptr->GetCount() >= pColl1Ptr->GetCount()) ? pColl1Ptr.GetInterfacePtr() :
																																			pColl2Ptr.GetInterfacePtr();

	MTACCOUNTLib::IMTSearchResultCollectionPtr pAddedCollPtr = 
										(pAddingCollPtr == pColl1Ptr) ? pColl2Ptr.GetInterfacePtr()	:
																										pColl1Ptr.GetInterfacePtr();

	SetIterator<MTACCOUNTLib::IMTSearchResultCollectionPtr, MTACCOUNTLib::IMTAccountPropertyCollectionPtr> it1;
	SetIterator<MTACCOUNTLib::IMTSearchResultCollectionPtr, MTACCOUNTLib::IMTAccountPropertyCollectionPtr> it2;
	hr = it1.Init(pAddingCollPtr);
	ASSERT(SUCCEEDED(hr));

	mLogger->LogVarArgs(LOG_DEBUG, "About to merge two collections with sizes <%d> and <%d>", 
																pAddingCollPtr->GetCount(), pAddedCollPtr->GetCount());
	
	MTACCOUNTLib::IMTAccountPropertyCollectionPtr temp;

	while (true)
	{
		MTACCOUNTLib::IMTAccountPropertyCollectionPtr APCOuterPtr = it1.GetNext();
		if(APCOuterPtr == NULL) break;
		temp = NULL;		
		hr = temp.CreateInstance(MTPROGID_MTACCOUNTPROPERTYCOLLECTION);
		ASSERT(SUCCEEDED(hr));
		//CComObject<CMTAccountPropertyCollection> * temp;
		//APCOuterPtr->QueryInterface(IID_NULL, (void**)&temp);

		//Create a temp object and copy items fro the first one into it
		//TODO:: Implement Copy method on CMTAccountPropertyCollection
		SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, MTACCOUNTLib::IMTAccountPropertyPtr> tmpitr;
		hr = tmpitr.Init(APCOuterPtr);
		ASSERT(SUCCEEDED(hr));
		
		while(true)
		{
			MTACCOUNTLib::IMTAccountPropertyPtr tmpAPPtr = tmpitr.GetNext();
			if(tmpAPPtr == NULL) break;
				_bstr_t tmpname = tmpAPPtr->GetName();
				_variant_t tmpval = tmpAPPtr->GetValue();
				//Add these extra properties to outer object
				temp->Add(tmpname, tmpval);
		}

		long c = temp->GetCount();

		hr = it2.Init(pAddedCollPtr);
		ASSERT(SUCCEEDED(hr));

		while(true)
		{
			MTACCOUNTLib::IMTAccountPropertyCollectionPtr APCInnerPtr = it2.GetNext();
			if(APCInnerPtr == NULL) break;
			SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, MTACCOUNTLib::IMTAccountPropertyPtr> it3;
			hr = it3.Init(APCInnerPtr);
			ASSERT(SUCCEEDED(hr));

			while(true)
			{
				MTACCOUNTLib::IMTAccountPropertyPtr APPtr = it3.GetNext();
				if(APPtr == NULL) break;
				_bstr_t nm = APPtr->GetName();
				_variant_t val = APPtr->GetValue();
				//Add these extra properties to outer object
				APCOuterPtr->Add(nm, val);
			}
			
			(pResultCollPtr)->Add(APCOuterPtr);
			c = APCOuterPtr->GetCount();
			APCOuterPtr = NULL;
			hr = APCOuterPtr.CreateInstance(MTPROGID_MTACCOUNTPROPERTYCOLLECTION);

			//Copy Items back into APCOuterPtr
			//Ugly and expensive! Need Copy function

			SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, MTACCOUNTLib::IMTAccountPropertyPtr> tmpitr;
			hr = tmpitr.Init(temp);
			ASSERT(SUCCEEDED(hr));
		
			while(true)
			{
				MTACCOUNTLib::IMTAccountPropertyPtr tmpAPPtr = tmpitr.GetNext();
				if(tmpAPPtr == NULL) break;
				_bstr_t tmpname = tmpAPPtr->GetName();
				_variant_t tmpval = tmpAPPtr->GetValue();
				//Add these extra properties to outer object
				APCOuterPtr->Add(tmpname, tmpval);
			}
			
			c = APCOuterPtr->GetCount();

		}
		
		temp = NULL;
	}

	mLogger->LogVarArgs(LOG_DEBUG, 
		"Merging Collections resulted in a matrix with <%d> rows",(pResultCollPtr)->GetCount());
	//if(bNewCollection)
		(*aResultColl) = (IMTSearchResultCollection *)(pResultCollPtr).Detach();
	return hr;
}

		






