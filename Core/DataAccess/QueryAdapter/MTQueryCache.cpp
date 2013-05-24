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
* $Header: c:\mainline\development\Core\DataAccess\QueryAdapter\MTQueryCache.cpp, 49, 11/8/2002 1:42:24 PM, Derek Young$
* 
***************************************************************************/
// MTQueryCache.cpp : Implementation of CMTQueryCache
#include "StdAfx.h"
#include "QueryAdapter.h"
#include "MTQueryCache.h"
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <DataAccessDefs.h>
#include <autocritical.h>
#include <OdbcConnMan.h>

#include <mtprogids.h>
#import <RCD.tlb>
#include <SetIterate.h>
#include <RcdHelper.h>
#include "MTUtil.h"

#include <ConfigDir.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

#include <boost/thread.hpp> 
#include <boost/algorithm/string.hpp> 
#include <boost/filesystem.hpp>

/////////////////////////////////////////////////////////////////////////////
//                       GLOBAL DECLARATIONS                               //
/////////////////////////////////////////////////////////////////////////////
static mtwstring EmptyString = L""; 
BOOL gInitializedFlag = FALSE;
MTDBAccessInfo *pGlobalDefaultDBAccessInfo = NULL;
BOOL gVersion1Flag = TRUE;

/////////////////////////////////////////////////
// String Helper
std::string ConvertWCSToMBS(const wchar_t* pstr, long wslen) 
{ 
    int len = ::WideCharToMultiByte(CP_ACP, 0, pstr, wslen, NULL, 0, NULL, NULL); 

    std::string dblstr(len, '\0'); 
    len = ::WideCharToMultiByte(CP_ACP, 0 /* no flags */, 
        pstr, wslen /* not necessary NULL-terminated */, 
        &dblstr[0], len, 
        NULL, NULL /* no default char */); 

    return dblstr; 
} 

std::string ConvertBSTRToMBS(BSTR bstr) 
{ 
    int wslen = ::SysStringLen(bstr); 
    if(wslen == 0)
        wslen = wcslen((wchar_t*)bstr);

    return ConvertWCSToMBS((wchar_t*)bstr, wslen); 
} 

std::wstring ConvertBSTRToMWS(BSTR bstr) 
{ 
    const _bstr_t wrapper(bstr);  
    std::wstring wstrVal((const wchar_t*)wrapper);
    return wstrVal;
} 


BSTR ConvertMBSToBSTR(const std::string& str) 
{ 
    int wslen = ::MultiByteToWideChar(CP_ACP, 0 /* no flags */, 
        str.data(), str.length(), 
        NULL, 0); 

    BSTR wsdata = ::SysAllocStringLen(NULL, wslen); 
    ::MultiByteToWideChar(CP_ACP, 0 /* no flags */, 
        str.data(), str.length(), 
        wsdata, wslen); 
    return wsdata; 
}

/////////////////////////////////////////////////////////////////////////////
// CMTQueryCache
CMTQueryCache::CMTQueryCache() 
    : mObserverInitialized(FALSE), mbGlobalDbAccessInit(false), mbCryptoInitialized(false)
{
    //intialize DBAccess property map with all supported properties
    mDBAccessProps[L"version"]            = PROP_TYPE_INTEGER;
    mDBAccessProps[L"dbaccess_type"]      = PROP_TYPE_STRING;
    mDBAccessProps[L"database_config"]    = PROP_TYPE_SET;
    mDBAccessProps[L"dbusername"]         = PROP_TYPE_STRING;
    mDBAccessProps[L"dbpassword"]         = PROP_TYPE_STRING;
    mDBAccessProps[L"dbname"]             = PROP_TYPE_STRING;
    mDBAccessProps[L"servername"]         = PROP_TYPE_STRING;
    mDBAccessProps[L"dbtype"]             = PROP_TYPE_STRING;
    mDBAccessProps[L"provider"]           = PROP_TYPE_STRING;
    mDBAccessProps[L"timeout"]            = PROP_TYPE_INTEGER;
    mDBAccessProps[L"datasource"]         = PROP_TYPE_STRING;
    mDBAccessProps[L"logical_servername"] = PROP_TYPE_STRING;

}

CMTQueryCache::~CMTQueryCache() 
{
    TearDown() ;
}

void CMTQueryCache::TearDown() 
{
    // DumpDBAccessColl();
    // mLogger->LogVarArgs(LOG_DEBUG, "TearDown continuing");

    gInitializedFlag = FALSE;

    MTDBAccessInfoColl::iterator it;
    for (it = mDBAccessColl.begin(); it != mDBAccessColl.end(); ++it)
    {
        if(gVersion1Flag || pGlobalDefaultDBAccessInfo != it->second)
           delete it->second;
    }
    // Cleanup the default (shared instance)
    if(!gVersion1Flag) 
    {
        delete pGlobalDefaultDBAccessInfo;
        pGlobalDefaultDBAccessInfo = NULL;
    }
    if(gVersion1Flag)
    {
        MTQueryFileColl::iterator it2;
        for (it2 = mQueryFileColl.begin(); it2 != mQueryFileColl.end(); ++it2)
            delete it2->second;
    }
    else
    {
        t_querycache::iterator it2;
        for (it2 = mTagQueryColl.begin(); it2 != mTagQueryColl.end(); ++it2)
            delete it2->second;
    }
    // clear the query cache ...
    mDBAccessColl.clear() ;
    mQueryFileColl.clear() ;
    mConfigDirColl.clear() ;
}

STDMETHODIMP CMTQueryCache::InterfaceSupportsErrorInfo(REFIID riid)
{
    static const IID* arr[] = 
    {
        &IID_IMTQueryCache,
    };
    for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
    {
        if (InlineIsEqualGUID(*arr[i],riid))
            return S_OK;
    }
    return S_FALSE;
}

// ----------------------------------------------------------------
// Name:          Init
// Arguments:     apConfigPath - The configuration path for the query file.
// Return Value:      
// Errors Raised: 80020009  - Unable to allocate memory
//                80020009  - Unable to add query to query collection
//                80020009  - Unable to get computer name
//                80020009  - Invalid database access type found
//                80020009  - Unable to add database access configuration information
//                80020009  - Unable to initialize query cache    
// Description:   The Init method initializes the query cache with the
//  relative configuration directory passed. If the query file is not 
//  resident in the cache, a new entry in the cache is created, the query file 
//  is read in and stored and the database access information is read and stored.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::Init(BSTR apConfigPath)
{

    HRESULT hr(S_OK);
    // Create the finder instance first thing...
    MetraTech_DataAccess_QueryManagement::IQueryMapperPtr qm;
    hr = qm.CreateInstance(__uuidof(MetraTech_DataAccess_QueryManagement::QueryMapper));
    if (FAILED(hr)) 
    {
        mLogger->LogVarArgs(LOG_ERROR, "Couldn't instantiate Query Management support. COM Error HResult=%d", hr);
        return hr;
    }

    mLogger->LogVarArgs(LOG_TRACE, "CMTQueryCache::Init entered");

    if(qm->Enabled)
    {
        mLogger->LogThis(LOG_TRACE, "Query management enabled");
        AutoCriticalSection aLock(&mLock);
        gVersion1Flag = FALSE;
        if(!Init_v2(qm))
        {
            mLogger->LogThis(LOG_ERROR,"Failed to populate query cache");
            return Error("Failed to populate query cache");
        }
        return S_OK;
    }
	
	mLogger->LogThis(LOG_TRACE, "Query management not enabled");
    // Looks like we are in the old mode
    gVersion1Flag = TRUE;
    wstring wstrConfigPath ;
    _bstr_t configPath ;
    _bstr_t queryFile ;
    _bstr_t aXmlQueryFile,aDbaccessFile;
    BOOL bServerNamePresent=FALSE ;
    BOOL bDBAccessPresent=FALSE ;
    BOOL bQueryAdapterPresent=FALSE ;
    MTDBAccessInfo *pDBAccessInfo=NULL ;
    MTQueryCollection *pQueryCollection=NULL ;
    VARIANT_BOOL flag;
    bool bAbsolutePath = false;

    // copy the config path ...
    wstrConfigPath = apConfigPath ;
    configPath = apConfigPath ;

    // get the configdir ...
    string configDir ;
    _bstr_t bstrConfigDir ;

    GetMTConfigDir (configDir);
    bstrConfigDir = configDir.c_str();

    // create the config com object ...
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr confSet;

    // create the configuration to read ...
    _bstr_t aSystemDbAccessFile = configDir.c_str() ;
    aSystemDbAccessFile += "\\Queries\\Database\\dbaccess.xml" ;



    // look for the config path in the queryfile collection ...
    AutoCriticalSection aLock(&mLock);
    BOOL bRetCode = mConfigDirColl.count(wstrConfigPath) > 0;
    if (bRetCode == FALSE)
    {
        // create a new query collection and dbaccess info collection object ...
        pDBAccessInfo = new MTDBAccessInfo ;
        ASSERT (pDBAccessInfo) ;
        if (pDBAccessInfo == NULL)
        {
            return Error("Unable to allocate memory") ;
        }
        pQueryCollection = new MTQueryCollection ;
        ASSERT (pQueryCollection) ;
        if (pQueryCollection == NULL)
        {
            return Error("Unable to allocate memory") ;
        }

        // start the try to catch _com_error ...
        try
        {
            // and set configPath to ""
            string aFilename = configPath;
            if(aFilename.find(":") != string::npos) 
            {
                // if we have an absolute path, use it for propset
                bAbsolutePath = true;
                bstrConfigDir = apConfigPath;

                // build the dbaccess.xml from this path
                aDbaccessFile = apConfigPath;
                aDbaccessFile += DIR_SEP;
                aDbaccessFile += "dbaccess.xml";
            }
            else 
            {
                // the path must be relative to the config tree
                // create the configuration to read ...
                aXmlQueryFile = bstrConfigDir;

                aDbaccessFile = bstrConfigDir;
                aDbaccessFile += apConfigPath;
                aDbaccessFile += DIR_SEP;
                aDbaccessFile += "dbaccess.xml";
            }

            //
            // read dbaccess.xml
            //
            MTConfigLib::IMTConfigPropSetPtr propset ;

            mLogger->LogVarArgs (LOG_TRACE, "Loading DB connection info from <%s>", (const char*)aDbaccessFile);
            hr = config->raw_ReadConfiguration(aDbaccessFile, &flag, &propset);
            if(FAILED(hr))
            {
				mLogger->LogVarArgs (LOG_TRACE, "File <%s> not found, falling over to the default one", (const char*)aDbaccessFile);
                bDBAccessPresent = FALSE ;
            }
            else
                bDBAccessPresent = ReadDbAccessFile(*pDBAccessInfo,propset);
            // if we dont have a dbaccess file then read the default ...
            if (bDBAccessPresent == FALSE)
            {
                if(!mbGlobalDbAccessInit) 
                {
                    VARIANT_BOOL flag;

                    // open the database config file ...      
                    mLogger->LogVarArgs (LOG_TRACE, "Loading DB connection info from <%s>", (const char*)aSystemDbAccessFile);
                    propset = config->ReadConfiguration(aSystemDbAccessFile, &flag);
                    if(!ReadDbAccessFile(mDBGlobalDBAccessInfo,propset))
                    {
                        mLogger->LogThis(LOG_ERROR,"Failed to read system dbaccess.xml file");
                        return Error("Failed to read system dbaccess.xml file");
                    }
                    mbGlobalDbAccessInit = true;
                }
                *pDBAccessInfo = mDBGlobalDBAccessInfo;
            }

            //Find all queryadapter.xml files in extensions and load them as well
            BOOL bQueryAdapterPresentInExtensions=FALSE;
            if (!bAbsolutePath && configPath.length()>0)
            {
                bstr_t aQueryAdapterFile = "config\\";
                aQueryAdapterFile += apConfigPath;
                aQueryAdapterFile += DIR_SEP;
                aQueryAdapterFile += QUERY_ADAPTER_FILE;

                RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
                aRCD->Init();
                RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery(aQueryAdapterFile, VARIANT_TRUE);

                if(aFileList->GetCount() != 0) 
                {
                    SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
                    if(FAILED(it.Init(aFileList))) return E_FAIL;

                    while(TRUE)
                    {
                        _variant_t aVariant= it.GetNext();
                        _bstr_t afile = aVariant;
                        if(afile.length() == 0)
                            break;

                        hr=AddQueriesFromQueryAdapterFile(afile,    apConfigPath, pDBAccessInfo, pQueryCollection);
                        if (FAILED(hr))
                            return hr;
                        bQueryAdapterPresentInExtensions=TRUE; //We don't need to load the default because we have one in the extension

                    }
                }

            }

            //
            // read queryadapter.xml
            //
            aXmlQueryFile += apConfigPath;
            aXmlQueryFile += DIR_SEP;
            aXmlQueryFile += QUERY_ADAPTER_FILE;
            hr = config->raw_ReadConfiguration(aXmlQueryFile,&flag, &confSet);
            if(FAILED(hr))
                bQueryAdapterPresent = FALSE;
            else
                bQueryAdapterPresent = TRUE;

            //If there is a query adapter file in an extension, only continue if it is not the default file
            if ((bQueryAdapterPresentInExtensions == FALSE) || (bQueryAdapterPresent == TRUE))
            {
                // if there was no query adapter file ... read the default ...
                if (bQueryAdapterPresent == FALSE)
                {
                    aXmlQueryFile = bstrConfigDir;
                    aXmlQueryFile += DATABASE_CONFIGDIR;
                    aXmlQueryFile += DIR_SEP;
                    aXmlQueryFile += QUERY_ADAPTER_FILE;

                    confSet = config->ReadConfiguration(aXmlQueryFile,&flag);
                }
                MTConfigLib::IMTConfigPropSetPtr aTempSet;
                MTConfigLib::IMTConfigPropSetPtr subset;
                // backwards compatibility for effective date driven files
                if(confSet->NextMatches("mtsysconfigdata",MTConfigLib::PROP_TYPE_SET) ||
                    confSet->NextMatches("mtconfigdata",MTConfigLib::PROP_TYPE_SET)) 
                {
                    aTempSet = confSet->NextSetWithName("mtconfigdata");
                } 
                else 
                {
                    aTempSet = confSet;
                }
                subset= aTempSet->NextSetWithName("adapter_config");

                // ignore the prog_id tag if it's found
                if (subset->NextMatches(L"prog_id", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
                    subset->Next();

                // the file will hold either a single query_file (old style)
                // that is used regardless of database type, or it will hold
                // two entries - sql_server_query_file and oracle_query_file.
                // the choice between them is made based on the database type in dbaccess.xml
                if (subset->NextMatches(L"query_file", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
                {
                    // old style
                    // get the query file (usually database dependent)...
                    queryFile = subset->NextStringWithName("query_file");

                    //mLogger->LogVarArgs (LOG_DEBUG, "Loading query file from tag query_file (old style): <%s>",
                    //                                         (const char*) queryFile);
                }
                else
                {
                    if (pDBAccessInfo->GetDBType() == _bstr_t(L"{SQL Server}"))
                    {
                        queryFile = subset->NextStringWithName(L"sql_server_query_file");
                        //mLogger->LogVarArgs (LOG_DEBUG, "Loading query file from tag sql_server_query_file: <%s>",
                        //                                         (const char*) queryFile);
                    }
                    else
                    {
                        queryFile = subset->NextStringWithName(L"oracle_query_file");
                        //mLogger->LogVarArgs (LOG_DEBUG, "Loading query file from tag oracle_query_file: <%s>",
                        //                                         (const char*) queryFile);
                    }
                }

                if (queryFile.length()>0)
                {
                    hr = AddQueries(queryFile, bstrConfigDir,
                        apConfigPath,
                        bQueryAdapterPresent, bAbsolutePath,
                        pQueryCollection);

                    if (FAILED(hr))
                    {
                        mLogger->LogVarArgs (LOG_ERROR, "Failed reading queries from database specific query file <%s> in folder <%s>",
                            (const char*) queryFile, (const char*) bstrConfigDir);
                        return hr;
                    }
                }
                else
                {
                    mLogger->LogVarArgs (LOG_TRACE, "Skipping loading queries from database specific query file as they are not specified in <%s>",
                        (const char*) aXmlQueryFile);
                }


                // skip the other type of query file, if it exists
                if (subset->NextMatches("sql_server_query_file", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE
                    || subset->NextMatches("oracle_query_file", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
                    subset->Next();

                // there may be a pointer to a database independent query file
                if (subset->NextMatches("common_query_file", MTConfigLib::PROP_TYPE_STRING)
                    == VARIANT_TRUE)
                {
                    _bstr_t commonQueryFile = subset->NextStringWithName("common_query_file");

                    //mLogger->LogVarArgs (LOG_DEBUG, "Loading common query file from <%s>",
                    //                                         (const char*) commonQueryFile);

                    if (commonQueryFile.length()>0)
                    {
                        hr = AddQueries(commonQueryFile, bstrConfigDir,
                            apConfigPath,
                            bQueryAdapterPresent, bAbsolutePath,
                            pQueryCollection);

                        if (FAILED(hr))
                        {
                            mLogger->LogVarArgs (LOG_ERROR, "Failed reading queries from common query file <%s> in folder <%s>",
                                (const char*) commonQueryFile, (const char*) bstrConfigDir);
                            return hr;
                        }
                    }
                    else
                    {
                        mLogger->LogVarArgs (LOG_TRACE, "Skipping loading queries from common query file as it is not specified in <%s>",
                            (const char*) aXmlQueryFile);
                    }
                }
            }

            // we read in everything ... add the config path to the collection ...
            AutoCriticalSection aLock(&mLock);
            mConfigDirColl.insert (wstrConfigPath) ;
            mQueryFileColl[wstrConfigPath] = pQueryCollection;
            pQueryCollection = NULL ;
            mDBAccessColl[wstrConfigPath] = pDBAccessInfo;
            pDBAccessInfo = NULL ;
        }
        catch (_com_error& e)
        {
            SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "MTQueryCache::Init");
            mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
            mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Error Description = %s", 
                (char*)e.Description()) ;

            return Error ("Unable to initialize query cache.") ;
        }
    }

    // if we havent initialized the observer stuff ...
    if (mObserverInitialized == FALSE)
    {
        if (!mObservable.Init())
        {
            mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Unable to initialize Observer.") ;
            bRetCode = FALSE ;
        }
        else
        {    
            mObservable.AddObserver(*this);

            if (!mObservable.StartThread())
            {
                mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Unable to start Observer Thread.") ;
                bRetCode = FALSE ;
            }
            else
            {
                mObserverInitialized = TRUE ;
            }
        }
    }

    return S_OK;
}


HRESULT CMTQueryCache::AddQueriesFromQueryAdapterFile(const wchar_t * apFilename,    // complete path of query adapter file
    const wchar_t * apConfigPath, // path specified in init, used as collection name to add queries to
    MTDBAccessInfo * apDBAccessInfo, 
    MTQueryCollection *pQueryCollection)
{

    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr confSet;
    VARIANT_BOOL flag;
    HRESULT hr;
    _bstr_t queryFile;

    _bstr_t tempFilename(apFilename);
    hr = config->raw_ReadConfiguration(tempFilename,&flag, &confSet);
    if(FAILED(hr))
    {
        mLogger->LogVarArgs (LOG_WARNING, "Unable to open query adapter file <%s>", (const char*) tempFilename);
        return E_FAIL;
    }

    MTConfigLib::IMTConfigPropSetPtr aTempSet;
    MTConfigLib::IMTConfigPropSetPtr subset;
    // backwards compatibility for effective date driven files
    if(confSet->NextMatches("mtsysconfigdata",MTConfigLib::PROP_TYPE_SET) ||
        confSet->NextMatches("mtconfigdata",MTConfigLib::PROP_TYPE_SET)) 
    {
        aTempSet = confSet->NextSetWithName("mtconfigdata");
    } 
    else 
    {
        aTempSet = confSet;
    }
    subset= aTempSet->NextSetWithName("adapter_config");

    // ignore the prog_id tag if it's found
    if (subset->NextMatches(L"prog_id", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
        subset->Next();

    // the file will hold either a single query_file (old style)
    // that is used regardless of database type, or it will hold
    // two entries - sql_server_query_file and oracle_query_file.
    // the choice between them is made based on the database type in dbaccess.xml
    if (subset->NextMatches(L"query_file", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
    {
        // old style
        // get the query file (usually database dependent)...
        queryFile = subset->NextStringWithName("query_file");

        mLogger->LogVarArgs (LOG_TRACE, "Loading query file from tag query_file (old style): <%s>",
            (const char*) queryFile);
    }
    else
    {
        if (apDBAccessInfo->GetDBType() == _bstr_t(L"{SQL Server}"))
        {
            queryFile = subset->NextStringWithName(L"sql_server_query_file");
            //mLogger->LogVarArgs (LOG_DEBUG, "Loading query file from tag sql_server_query_file: <%s>",
            //                                         (const char*) queryFile);
        }
        else
        {
            queryFile = subset->NextStringWithName(L"oracle_query_file");
            //mLogger->LogVarArgs (LOG_DEBUG, "Loading query file from tag oracle_query_file: <%s>",
            //                                         (const char*) queryFile);
        }
    }

    string filePath;
    string localFilename;
    ParseFilename((char *)tempFilename, filePath, localFilename);
    if ((filePath.length()==0) || (filePath.length()==0))
    {
        mLogger->LogVarArgs (LOG_WARNING, "Unable to parse file name of <%s>",
            (const char*) tempFilename);

        return E_FAIL;
    }

    _bstr_t queryFilePath(filePath.c_str());

    if (queryFile.length()>0)
    {
        hr = AddQueries(queryFile, queryFilePath,
            apConfigPath,
            true, true,
            pQueryCollection);

        if (FAILED(hr))
        {
            mLogger->LogVarArgs (LOG_ERROR, "Failed reading queries from database specific query file <%s> in folder <%s>",
                (const char*) queryFile, (const char*) queryFilePath);
            return hr;
        }
    }
    else
    {
        mLogger->LogVarArgs (LOG_TRACE, "Skipping loading queries from database specific query file as they are not specified in <%s>",
            (const char*) tempFilename);
    }

    // skip the other type of query file, if it exists
    if (subset->NextMatches("sql_server_query_file", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE
        || subset->NextMatches("oracle_query_file", MTConfigLib::PROP_TYPE_STRING) == VARIANT_TRUE)
        subset->Next();

    // there may be a pointer to a database independent query file
    if (subset->NextMatches("common_query_file", MTConfigLib::PROP_TYPE_STRING)
        == VARIANT_TRUE)
    {
        _bstr_t commonQueryFile = subset->NextStringWithName("common_query_file");

        //mLogger->LogVarArgs (LOG_DEBUG, "Loading common query file from <%s>",
        //                                         (const char*) commonQueryFile);

        /*
        hr = AddQueries(commonQueryFile, bstrConfigDir,
        apConfigPath,
        bQueryAdapterPresent, bAbsolutePath,
        pQueryCollection);*/
        if (commonQueryFile.length()!=0)
        {
            hr = AddQueries(commonQueryFile, queryFilePath,
                apConfigPath,
                true, true,
                pQueryCollection);

            if (FAILED(hr))
            {
                mLogger->LogVarArgs (LOG_ERROR, "Failed reading queries from common query file <%s> in folder <%s>",
                    (const char*) commonQueryFile, (const char*) queryFilePath);
                return hr;
            }
        }
        else
        {
            mLogger->LogVarArgs (LOG_TRACE, "Skipping loading queries from common query file as it is not specified in <%s>",
                (const char*) tempFilename);
        }
    }

    return S_OK;
}


HRESULT CMTQueryCache::AddQueries(const wchar_t * apFilename,    // filename in file
    const wchar_t * apConfigDir, // registry config dir
    const wchar_t * apConfigPath,    // path specified in init
    BOOL bQueryAdapterPresent,
    BOOL bAbsolutePath,
    MTQueryCollection *pQueryCollection)
{
    // if we have a query adapter file in the config path sent in ...
    _bstr_t fullPath;
    if (bQueryAdapterPresent == TRUE)
    {
        fullPath = apConfigDir;
        if(!bAbsolutePath) 
        {
            fullPath += apConfigPath ;
        }
        fullPath += DIR_SEP;
        fullPath += apFilename;
    }
    /// otherwise ... read from the default config path ...
    else
    {
        fullPath = apConfigDir;
        fullPath += DATABASE_CONFIGDIR;
        fullPath += DIR_SEP;
        fullPath += apFilename;
    }

    _bstr_t configPath(apConfigPath);
    mLogger->LogVarArgs(LOG_TRACE, "Loading queries from query file %s for Init(%s)", (const char *) fullPath, (const char *) configPath);

    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    VARIANT_BOOL flag;
    MTConfigLib::IMTConfigPropSetPtr aTopLevelQueryset = config->ReadConfiguration(fullPath, &flag);

    MTConfigLib::IMTConfigPropSetPtr configSet ;
    if(aTopLevelQueryset->NextMatches("mtsysconfigdata",MTConfigLib::PROP_TYPE_SET) ||
        aTopLevelQueryset->NextMatches("mtconfigdata",MTConfigLib::PROP_TYPE_SET)) 
    {
        configSet = aTopLevelQueryset->NextSetWithName("mtconfigdata");
    }
    else 
    {
        configSet = aTopLevelQueryset;
    }
    //configSet = aTempQuerySet->NextSetWithName("adapter_config");

    // iterate through the set of queries ...
    MTConfigLib::IMTConfigPropSetPtr queryset ;
    while ((queryset = configSet->NextSetWithName("query")) != NULL)
    {
        _bstr_t queryTag = queryset->NextStringWithName("query_tag");
        _bstr_t    queryString = queryset->NextStringWithName("query_string");

        //mLogger->LogVarArgs(LOG_DEBUG, "Adding query tag %s", (const char *) queryTag);

        // add the query to the collection ...
        if (!pQueryCollection->AddQuery ((char*)queryTag, (char*) queryString))
        {
            mLogger->LogVarArgs (LOG_ERROR, "Unable to add duplicate query tag %s from query file %s.",
                (char*) queryTag, (char*) fullPath) ;
            return Error ("Unable to add query to query collection") ;
        }

        // reads in an optional hinter for the query
        if (queryset->NextMatches("hinter", PROP_TYPE_STRING))
        {
            _bstr_t    hinter = queryset->NextStringWithName("hinter");
            if (!pQueryCollection->AddHinter((char*)queryTag, (char*) hinter))
            {
                mLogger->LogVarArgs (LOG_ERROR, "Unable to add a duplicate hinter for query tag %s from query file %s.",
                    (char*) queryTag, (char*) fullPath) ;
                return Error ("Unable to add hinter to query collection") ;
            }
        }
    }

    return S_OK;
}

// ----------------------------------------------------------------
// Name:          GetQueryString
// Arguments:     apConfigPath - The configuration path to get the query from
//                apQueryTag   - The query tag
//                apQueryString- The query string
// Return Value:  The query string
// Errors Raised: 0xE1500005L - Unable to get the query string. Unknown config path
//                0xE1500005L - Unable to get the query string
// Description:   The GetQueryString method gets the query string from the query file
//  specified by the configuraiton path passed in.
// ----------------------------------------------------------------

STDMETHODIMP CMTQueryCache::GetQueryString(BSTR apConfigPath, 
    BSTR apQueryTag, 
    BSTR *apQueryString)
{
    string queryStr ;
    _bstr_t queryTag = apQueryTag ;
    MTQueryCollection *pQueryColl=NULL ;
    if(NULL == apQueryTag || 0 >= wcslen((wchar_t*)apQueryTag))
    {
        _bstr_t errorBuffer;
        errorBuffer = L"QueryTag is empty or null";
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_INVALID_PARAMETER);
    }
    // find the config path in the query file collection ...
    AutoCriticalSection aLock(&mLock);
    if(!gVersion1Flag)
    {
        if(GetQueryString_v2(apQueryTag, apQueryString))
            return S_OK;

        apQueryString = NULL ;
        SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
            "MTQueryCache::GetQueryString") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

        _bstr_t errorBuffer;
        errorBuffer = L"Unable to find config path ";
        errorBuffer += apConfigPath;
        errorBuffer += " in query file collection ";

        mLogger->LogThis (LOG_ERROR, (const wchar_t *) errorBuffer);

        return Error ((const wchar_t *) errorBuffer,
            IID_IMTQueryCache, DB_ERR_ITEM_NOT_FOUND);
    }

    if(NULL == apConfigPath || 0 >= wcslen((wchar_t*)apConfigPath))
    {
        _bstr_t errorBuffer;
        errorBuffer = L"ConfigPath is empty or null";
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_INVALID_PARAMETER);
    }

    MTQueryFileColl::iterator it = mQueryFileColl.find(apConfigPath);
    if (it == mQueryFileColl.end())
    {
        apQueryString = NULL ;
        SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
            "MTQueryCache::GetQueryString") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

        _bstr_t errorBuffer;
        errorBuffer = L"Unable to find config path ";
        errorBuffer += apConfigPath;
        errorBuffer += " in query file collection ";

        mLogger->LogThis (LOG_ERROR, (const wchar_t *) errorBuffer);

        return Error ((const wchar_t *) errorBuffer,
            IID_IMTQueryCache, DB_ERR_ITEM_NOT_FOUND) ;
    }
    else
    {
        pQueryColl = it->second;

        // find the query string ...
        BOOL bRetCode = pQueryColl->FindQuery ((char*) queryTag, queryStr) ;
        if (bRetCode == FALSE)
        {
            apQueryString = NULL ;
            SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
                "MTQueryCache::GetQueryString") ;
            mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

            _bstr_t errorBuffer;
            errorBuffer = L"Unable to find query tag ";
            errorBuffer += queryTag;
            errorBuffer += " in query file for config path ";
            errorBuffer += apConfigPath;

            mLogger->LogThis(LOG_ERROR, (const wchar_t *) errorBuffer);
            return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, 
                DB_ERR_ITEM_NOT_FOUND) ;
        }
        else
        {
            // copy the query string to a _bstr_t so we can return it ...
            _bstr_t newValue = queryStr.c_str() ;
            *apQueryString = newValue.copy() ;
			            
			mLogger->LogVarArgs (LOG_TRACE, "GetQueryString: QueryTag = %s", (const char*)queryTag);
        }
        return S_OK;
    }
}


// ----------------------------------------------------------------
// Name:          GetHinter
// Arguments:     apConfigPath - The configuration path to get the query from
//                apQueryTag   - The query tag
// Description:   Returns a compiled hint generataion MTSQL procedure (hinter) for the given
//                query. If there is no hinter, returns empty string.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetHinter(BSTR apConfigPath, 
    BSTR apQueryTag, 
    IDispatch** apHinter)
{
    if(NULL == apQueryTag || 0 >= wcslen((wchar_t*)(apQueryTag)))
    {
        _bstr_t errorBuffer;
        errorBuffer = L"QueryTag is empty or null";
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_INVALID_PARAMETER);
    }

    // finds the query collection for the config path
    AutoCriticalSection aLock(&mLock);
    if(!gVersion1Flag)
    {
        if(GetHinter_v2(apQueryTag, apHinter))
            return S_OK;

        apHinter = NULL;
        SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "MTQueryCache::GetHinter");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError());

        _bstr_t errorBuffer;
        errorBuffer = L"Unable to find config path ";
        errorBuffer += apConfigPath;
        errorBuffer += " in query file collection ";

        mLogger->LogThis(LOG_ERROR, (const wchar_t *) errorBuffer);
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_ITEM_NOT_FOUND);
    }
    if(NULL == apConfigPath || 0 >= wcslen((wchar_t*)apConfigPath))
    {
        _bstr_t errorBuffer;
        errorBuffer = L"ConfigPath is empty or null";
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_INVALID_PARAMETER);
    }

    MTQueryFileColl::iterator it = mQueryFileColl.find(apConfigPath);
    if (it == mQueryFileColl.end())
    {
        apHinter = NULL;
        SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "MTQueryCache::GetHinter");
        mLogger->LogErrorObject(LOG_ERROR, GetLastError());

        _bstr_t errorBuffer;
        errorBuffer = L"Unable to find config path ";
        errorBuffer += apConfigPath;
        errorBuffer += " in query file collection ";

        mLogger->LogThis(LOG_ERROR, (const wchar_t *) errorBuffer);
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_ITEM_NOT_FOUND);
    }
    MTQueryCollection * pQueryColl = it->second;


    // attempts to find the associated hinter
    _bstr_t queryTag = apQueryTag;
    MetraTech_DataAccess_Hinter::IQueryHinterPtr hinter;
    pQueryColl->FindHinter((char*) queryTag, hinter);
    *apHinter =  hinter.Detach();

    return S_OK;
}
// ----------------------------------------------------------------
// HELPER MACRO FOR THE GET METHODS BELOW
// Many of the following methods all do the same thing, 
// except for the extractAssignment statement, 
// so this macro keeps the code to a minimum
// ----------------------------------------------------------------
#define m_GET(apConfigPath, method, errStr, inputvar, extractAssignment) \
    if(NULL == (apConfigPath) || 0 >= wcslen((wchar_t*)(apConfigPath))) \
    { \
        _bstr_t errorBuffer; \
        errorBuffer = L"ConfigPath is empty or null"; \
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_INVALID_PARAMETER); \
    } \
    AutoCriticalSection aLock(&mLock); \
    MTDBAccessInfo *pDBAccessInfo = GetDBAccessInfo((apConfigPath)); \
    if (!pDBAccessInfo) { \
        (inputvar) = NULL; \
        SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, (method)); \
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()); \
        mLogger->LogVarArgs (LOG_ERROR,  \
            L"Unable to find config path %ls in db access info collection.",  \
            (apConfigPath)) ; \
        return Error ((errStr), IID_IMTQueryCache, DB_ERR_ITEM_NOT_FOUND); \
    } \
    else (extractAssignment); \
    return S_OK;

// ----------------------------------------------------------------
// Name:             GetUserName
// Arguments:     apConfigPath - The relative configuration path
//                apUserName   - The database user name
// Return Value:  The database user name    
// Errors Raised: 0xE1500005L - Unable to get the user name. Unknown config path
// Description:   The GetUserName method gets the user name from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetUserName(BSTR apConfigPath, BSTR * apUserName)
{
    m_GET(apConfigPath,
          "MTQueryCache::GetUserName",
          "Unable to get the user name. Unknown config path",
          apUserName,
          *apUserName = pDBAccessInfo->GetUserName().copy());
}

// ----------------------------------------------------------------
// Name:             GetPassword
// Arguments:     apConfigPath - The relative configuration path
//                apPassword   - The database password
// Return Value:  The database password
// Errors Raised: 0xE1500005L - Unable to get the password. Unknown config path
// Description:   The GetPassword method gets the password from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetPassword(BSTR apConfigPath, BSTR * apPassword)
{
    m_GET(apConfigPath,
          "MTQueryCache::GetPassword",
          "Unable to get the password. Unknown config path",
          apPassword,
          *apPassword  = pDBAccessInfo->GetPassword().copy());
}

// ----------------------------------------------------------------
// Name:             GetDBName
// Arguments:     apConfigPath - The relative configuration path
//                apDBName     - The database name
// Return Value:  The database name
// Errors Raised: 0xE1500005L - Unable to get the database name. Unknown config path
// Description:   The GetDBName method gets the database name from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetDBName(BSTR apConfigPath, BSTR * apDBName)
{
    m_GET(apConfigPath,
          "MTQueryCache::GetDBName",
          "Unable to get the database name. Unknown config path",
          apDBName,
          *apDBName = pDBAccessInfo->GetDBName().copy());
}

// ----------------------------------------------------------------
// Name:          GetLogicalServerName
// Arguments:     apConfigPath - The relative configuration path
//                apServerName - The server name
// Return Value:  The server name
// Errors Raised: 0xE1500005L - Unable to get the server name. Unknown config path
// Description:   The GetServerName method gets the server name from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetLogicalServerName(BSTR apConfigPath, BSTR * apServerName)
{
    _bstr_t msg;
    msg = L"GetLogicalServerName";
    msg += apConfigPath;
    mLogger->LogThis(LOG_TRACE, (const wchar_t *) msg);

    if(NULL == apConfigPath || 0 >= wcslen((wchar_t*)apConfigPath))
    { 
        _bstr_t errorBuffer; 
        errorBuffer = L"ConfigPath is empty or null"; 
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_INVALID_PARAMETER); 
    } 
    AutoCriticalSection aLock(&mLock); 
    MTDBAccessInfo *pDBAccessInfo = GetDBAccessInfo((apConfigPath)); 
    if (!pDBAccessInfo) {
        apServerName = NULL; 
        SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "MTQueryCache::GetLogicalServerName"); 
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()); 
        mLogger->LogVarArgs (LOG_ERROR,  
            L"Unable to find config path %ls in db access info collection.",  
            apConfigPath) ; 
        return Error ("Unable to get the server name. Unknown config path", IID_IMTQueryCache, DB_ERR_ITEM_NOT_FOUND); 
    } 
    else
    {
        *apServerName = pDBAccessInfo->GetLogicalServerName().copy();
        _bstr_t msg2;
        msg2 = L"GetLogicalServerName RETURNING ";
        msg2 += *apServerName;
        mLogger->LogThis(LOG_TRACE, (const wchar_t *) msg);
    }

    return S_OK;

/*
    m_GET(apConfigPath,
          "MTQueryCache::GetLogicalServerName",
          "Unable to get the server name. Unknown config path",
          apServerName ,
          *apServerName = pDBAccessInfo->GetLogicalServerName().copy());
*/
}


// ----------------------------------------------------------------
// Name:             GetServerName
// Arguments:     apConfigPath - The relative configuration path
//                apServerName - The server name
// Return Value:  The server name
// Errors Raised: 0xE1500005L - Unable to get the server name. Unknown config path
// Description:   The GetServerName method gets the server name from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetServerName(BSTR apConfigPath, BSTR * apServerName)
{
    m_GET(apConfigPath,
          "MTQueryCache::GetServerName",
          "Unable to get the server name. Unknown config path",
          apServerName ,
          *apServerName= pDBAccessInfo->GetServerName().copy());
}

// ----------------------------------------------------------------
// Name:             GetAccessType
// Arguments:     apConfigPath - The relative configuration path
//                apAccessType - The access type
// Return Value:  The access type
// Errors Raised: 0xE1500005L - Unable to get the access type. Unknown config path
// Description:   The GetAccessType method gets the access type from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetAccessType(BSTR apConfigPath, BSTR * apAccessType)
{
    m_GET(apConfigPath,
        "MTQueryCache::GetAccessType",
        "Unable to get the access type. Unknown config path",
        apAccessType ,
        *apAccessType  = pDBAccessInfo->GetAccessType().copy());
}
// ----------------------------------------------------------------
// Name:             GetDBType
// Arguments:     apConfigPath - The relative configuration path
//                apDBType     - The database type
// Return Value:  The database type
// Errors Raised: 0xE1500005L - Unable to get the database type. Unknown config path
// Description:   The GetDBType method gets the database type from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetDBType(BSTR apConfigPath, BSTR * apDBType)
{
    m_GET(apConfigPath,
        "MTQueryCache::GetDBType",
        "Unable to get the database type. Unknown config path",
        apDBType ,
        *apDBType = pDBAccessInfo->GetDBType().copy());
}

// ----------------------------------------------------------------
// Name:             GetProvider
// Arguments:     apConfigPath - The relative configuration path
//                apProvider   - The provider
// Return Value:  The provider
// Errors Raised: 0xE1500005L - Unable to get the provider. Unknown config path
// Description:   The GetProvider method gets the provider from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetProvider(BSTR apConfigPath, BSTR * apProvider)
{
    m_GET(apConfigPath,
        "MTQueryCache::GetProvider",
        "Unable to get the provider. Unknown config path",
        apProvider ,
        *apProvider= pDBAccessInfo->GetProvider().copy());
}

// ----------------------------------------------------------------
// Name:             GetTimeout
// Arguments:     apConfigPath - The relative configuration path
//                apTimeout - The timeout value
// Return Value:  The timeout value
// Errors Raised: 0xE1500005L - Unable to get the timeout value. Unknown config path
// Description:   The GetTimeout method gets the timeout value from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetTimeout(BSTR apConfigPath, long * apTimeout)
{
    if(NULL == apConfigPath || 0 >= wcslen((wchar_t*)apConfigPath))
    {
        _bstr_t errorBuffer;
        errorBuffer = L"ConfigPath is empty or null";
        mLogger->LogVarArgs (LOG_ERROR, L"%ls", errorBuffer) ;
        return Error ((const wchar_t *) errorBuffer, IID_IMTQueryCache, DB_ERR_INVALID_PARAMETER);
    }
    // find the config path in the db access info collection ...
    AutoCriticalSection aLock(&mLock);

    MTDBAccessInfo *pDBAccessInfo = GetDBAccessInfo(apConfigPath);
    if (!pDBAccessInfo)
    {
        *apTimeout = -1 ;
        SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
            "MTQueryCache::GetTimeout") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        mLogger->LogVarArgs (LOG_ERROR, 
            L"Unable to find config path %ls in db access info collection.", 
            apConfigPath) ;
        return Error ("Unable to get the timeout value. Unknown config path", 
            IID_IMTQueryCache, DB_ERR_ITEM_NOT_FOUND) ;
    }
    else
    {
        // copy the timeout ...
        *apTimeout = pDBAccessInfo->GetTimeout() ;
    }

    return S_OK;
}

// ----------------------------------------------------------------
// Name:             GetDataSource
// Arguments:     apConfigPath - The relative configuration path
//                apDataSource - The datasource
// Return Value:  The data source
// Errors Raised: 0xE1500005L - Unable to get the data source. Unknown config path
// Description:   The GetDataSource method gets the data source from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetDataSource(BSTR apConfigPath, BSTR * apDataSource)
{
    m_GET(apConfigPath,
        "MTQueryCache::GetDataSource",
        "Unable to get the data source. Unknown config path",
        apDataSource,
        *apDataSource= pDBAccessInfo->GetDataSource().copy());
}

// ----------------------------------------------------------------
// Name:             GetDBDriver
// Arguments:     apConfigPath - The relative configuration path
//                apDBDriver - The database driver
// Return Value:  The database driver
// Errors Raised: 0xE1500005L - Unable to get the database driver. Unknown config path
// Description:   The GetDBDriver method gets the database driver from the database access
//  configuration file specified by the relatvie configuration path passed.
// ----------------------------------------------------------------
STDMETHODIMP CMTQueryCache::GetDBDriver(BSTR apConfigPath, BSTR * apDBDriver)
{
    m_GET(apConfigPath,
        "MTQueryCache::GetDBDriver",
        "Unable to get the db driver. Unknown config path",
        apDBDriver,
        *apDBDriver= pDBAccessInfo->GetDBDriver().copy());

}

STDMETHODIMP CMTQueryCache::RefreshConfiguration(VARIANT_BOOL ImmediateReload, long *pVal)
{
    //Eventually will want to add option to conditionally reload everything or just
    //wait until its needed again and possibly return a count of directories reloaded.

    //For now, always reload
    *pVal = 1;

    ConfigurationHasChanged();

    return S_OK;
}

//
//    @mfunc
//    Update the configuration.
//  @rdesc 
//  No return value
//
void CMTQueryCache::ConfigurationHasChanged()
{
    // local variables ...

    MTConfigDirColl localConfigDirColl ;


    // get the critical section
    AutoCriticalSection aLock(&mLock);

    // iterate through the query file collection and 
    //create a local queryfile collection ...

    MTConfigDirColl::iterator it;
    for (it = mConfigDirColl.begin(); it != mConfigDirColl.end(); ++it)
    {
        // insert the query file name into the local query file collection ...
        localConfigDirColl.insert(*it) ;
    }

    // delete the allocated memory ... deletes the query file collection ...
    TearDown() ;

    // iterate through the local query file collection ...
    MTConfigDirColl::iterator localit;
    for (localit = localConfigDirColl.begin(); localit != localConfigDirColl.end(); ++localit)
    {
        // call init with the query file name ...
        _bstr_t configPath = localit->c_str();
        Init (configPath) ;
    }

    return ;
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///  CMTQueryCache METHODS
// ----------------------------------------------------------------
// Name:          Init
// Arguments:     
// Return Value:  
// Description:   The Init method initializes the query cache with the
//  relative configuration directory passed. If the query file is not 
//  resident in the cache, a new entry in the cache is created, the query file 
//  is read in and stored and the database access information is read and stored.
// ----------------------------------------------------------------
BOOL CMTQueryCache::Init_v2(const MetraTech_DataAccess_QueryManagement::IQueryMapperPtr & arQueryMapper)
{
    if (gInitializedFlag) { return TRUE; }

    mLogger->LogVarArgs(LOG_TRACE, "Init_v2 enter");

    // Note, that the QueryMapper.QueryCache will return an IEnumVariat array of query properties
    HRESULT hr(S_OK);
    IEnumVARIANT* properties = NULL;
    hr = arQueryMapper->QueryCache(& properties);
    if (FAILED(hr)) 
    {
        mLogger->LogVarArgs(LOG_ERROR, "Could not get cache effective set, COM HResult=%d", hr);
        return FALSE;
    }

    if(!PopulateCache(properties))
    {
        mLogger->LogVarArgs(LOG_ERROR, "Couldn't POPULATE query cache");
        return FALSE;
    }

    mLogger->LogVarArgs(LOG_TRACE, "Init_v2 exit");

    this->AddRef(); // Make sure we never, release. 
    return gInitializedFlag = TRUE;
}

BOOL CMTQueryCache::GetHinter_v2(BSTR apQueryTag, IDispatch** apHinter)
{
    std::wstring tag = ConvertBSTRToMWS(apQueryTag);
    if (!mTagQueryColl.count(tag))
    {
        _bstr_t errorBuffer;
        errorBuffer = L"Unable to find query tag ";
        errorBuffer += apQueryTag;

        mLogger->LogThis(LOG_ERROR, (const wchar_t *) errorBuffer);
        return FALSE;
    }
    *apHinter = mTagQueryColl[tag]->Hinter();
    return TRUE;
}

BOOL CMTQueryCache::GetQueryString_v2(BSTR apQueryTag, BSTR *apQueryString)
{
    if(!gInitializedFlag) return FALSE;
	
    std::wstring tag = ConvertBSTRToMWS(apQueryTag);

	mLogger->LogVarArgs (LOG_TRACE, L"GetQueryString_v2 : %ls",   tag.c_str());
	
    if (!mTagQueryColl.count(tag))
    {
        _bstr_t errorBuffer;
        errorBuffer = L"Unable to find query tag ";
        errorBuffer += apQueryTag;

        mLogger->LogThis(LOG_ERROR, (const wchar_t *) errorBuffer);
        return FALSE;
    }
    
    _bstr_t newValue = mTagQueryColl[tag]->Query().c_str();
    if(newValue.length() == 0)
        return FALSE;

    *apQueryString = newValue.copy() ;
    return TRUE;
}

mtwstring CMTQueryCache::GetTag (const mtwstring & arFileName)
{
    std::size_t found;
    std::wstring tag = L"";
    found = arFileName.find_first_of(L".");
    if(found) tag = arFileName.substr(0,found);    
    return mtwstring (tag.c_str());
}


BOOL CMTQueryCache::PopulateCache(IEnumVARIANT* queryPropertiesArray)
{
    mLogger->LogVarArgs(LOG_TRACE, "PopulateCache enter");

    unsigned long  it = 1;
    VARIANT  queryInfoVar;
    unsigned long  pItFetched = 0;
    HRESULT hr(S_OK);
    do
    {
        // Iterate over the IEnumerable values and 
        // marshal the objects into unmanaged memory
        hr = queryPropertiesArray->Next(it, &queryInfoVar, &pItFetched);
        if(S_OK == hr)
        {
            // Grab the pointer to the instance created in C#
            MetraTech_DataAccess_QueryManagement::QueryTagProperties* prop = (MetraTech_DataAccess_QueryManagement::QueryTagProperties*)queryInfoVar.pdispVal; 

            mtwstring tag(L"");
            if(NULL != prop->QueryTag)
                tag = (PCWSTR)prop->QueryTag;

            if(FALSE == (BOOL)prop->DbAccessFileInfoOnly)
            {
                mtwstring hinter(L"");
                if(NULL != prop->QueryHinterString)
                    hinter = (PCWSTR)prop->QueryHinterString;
            
                mtwstring qpath(L"");
                if(NULL != (PCWSTR)prop->QueryFilePath)
                    qpath = (PCWSTR)prop->QueryFilePath;
            
                mtwstring qname(L"");
                if(NULL != (PCWSTR)prop->QueryFileName)
                    qname = (PCWSTR)prop->QueryFileName;
                        
                if(!AddQueryInfo(tag, qpath, qname, hinter))
                {
                    string msg = "Couldn't add query " + ascii(tag.c_str());
                    mLogger->LogThis(LOG_ERROR, msg.c_str());
                    return FALSE;
                }
            }

            mtwstring dbapath(L"");
            if(NULL != (PCWSTR)prop->DbAccessFilePath)
                dbapath = (PCWSTR)prop->DbAccessFilePath;
            
            mtwstring dbaname(L"");
            if(NULL != (PCWSTR)prop->DbAccessFileName)
                dbaname = (PCWSTR)prop->DbAccessFileName;

            mtwstring dbakey(L"");
            if(NULL != (PCWSTR)prop->ConfigurationDirectory)
                dbakey = (PCWSTR)prop->ConfigurationDirectory;

            dbakey.tolower();
            if(!AddDBAccessInfo((BOOL)prop->DefaultDbAccessFile, dbakey, dbapath, dbaname))
            {
                string msg = "Couldn't add dbaccess data for tag " + ascii(tag.c_str());
                mLogger->LogThis(LOG_ERROR, msg.c_str());
                return FALSE;
            }
        }
    }
    while(S_OK == hr);
    mLogger->LogVarArgs(LOG_TRACE, "PopulateCache exit");
    return TRUE;
}

BOOL CMTQueryCache::AddQueryInfo(const mtwstring & arQTag, const mtwstring & arQPath, const mtwstring & arQName, const mtwstring & arQHinter)
{
    if(arQTag == L"")
    {
        mLogger->LogVarArgs(LOG_ERROR, "AddQueryInfo() Tag parameter empty");
        return FALSE;
    }
    if(arQPath == L"")
    {
        mLogger->LogVarArgs(LOG_ERROR, "AddQueryInfo() Query Path parameter empty");
        return FALSE;
    }
    if(arQName == L"")
    {
        mLogger->LogVarArgs(LOG_ERROR, "AddQueryInfo() Query File Name parameter empty");
        return FALSE;
    }

    mLogger->LogVarArgs(LOG_TRACE, "AddQueryInfo(%ls, %ls, %ls) enter", arQTag.c_str(), arQPath.c_str(), arQName.c_str());
    mtwstring fullsqlfilepath(arQPath);
    fullsqlfilepath +=  L"\\";
    fullsqlfilepath +=  arQName;

    boost::filesystem::path sqlfilepath(ascii(fullsqlfilepath.c_str())); 
    if (!boost::filesystem::exists(fullsqlfilepath))
    {
        string msg = "File ";
        msg += ascii(fullsqlfilepath.c_str());
        msg += " doesn't exist, please correct support settings or replace file.";
        mLogger->LogThis(LOG_ERROR, msg.c_str());
        return FALSE;
    }
    // Check for duplicate in cache
    if (0 != mTagQueryColl.count(arQTag))
    {
        string msg = "file ";
        msg += ascii(fullsqlfilepath.c_str());
        msg += " is a duplicate of ";
        msg += ascii(mTagQueryColl[arQTag]->InfoFile().c_str());
        mLogger->LogThis(LOG_ERROR, msg.c_str());
        return FALSE;
    }

    // Everything looks good, lets allocate the query info container
    CMTQueryInfo* info = new CMTQueryInfo(arQTag, arQPath, arQName, arQHinter);
    if(!info)
    {
        string msg = "Can't allocate memory for ";
        msg += ascii(fullsqlfilepath.c_str());
        mLogger->LogThis(LOG_ERROR, msg.c_str());
        return FALSE;
    }
    mTagQueryColl[arQTag] = info;
    mLogger->LogVarArgs(LOG_TRACE, "AddQueryInfo exit");
    return TRUE;
}

BOOL CMTQueryCache::AddDBAccessInfo(const BOOL isDefault, const mtwstring & arDBAccessKey, const mtwstring & arDBAccessPath,const mtwstring & arDBAccessName)
{
    MTDBAccessInfo *pDBAccessInfo = NULL;

    // First, always check if we already have the entry...
    // this is important to ensure we are not overwriting
    // existing entries and causing a memory leak...
    MTDBAccessInfoColl::iterator it = mDBAccessColl.find(arDBAccessKey);
    if (it != mDBAccessColl.end())
    {
        // Already logged a DB access for this relative path
        return TRUE;
    }

    mLogger->LogVarArgs(LOG_TRACE, "AddDBAccessInfo(%ls, %ls, %ls) enter", arDBAccessKey.c_str(), arDBAccessPath.c_str(), arDBAccessName.c_str());

    // Only create a new one if it is the first default instance, 
    // or is not a default at all
    if((isDefault && !pGlobalDefaultDBAccessInfo) || !isDefault)
    {

        std::string fullsqlfilepath(ascii(arDBAccessPath.c_str()));
        fullsqlfilepath +=  "\\";
        fullsqlfilepath +=  arDBAccessName;

        boost::filesystem::path sqlfilepath(fullsqlfilepath); 
        if (!boost::filesystem::exists(fullsqlfilepath))
        {
            std::string msg = "File ";
            msg += fullsqlfilepath;
            msg += " doesn't exist, please correct support settings or replace file.";
            mLogger->LogThis(LOG_ERROR, msg.c_str());
            return FALSE;
        }
        // read dbaccess.xml
        //
        MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
        MTConfigLib::IMTConfigPropSetPtr propset;
        VARIANT_BOOL flag;
        BSTR bs = ConvertMBSToBSTR(fullsqlfilepath); 
        mLogger->LogVarArgs (LOG_TRACE, "Loading DB connection info from <%s>", fullsqlfilepath.c_str());
        HRESULT hr = config->raw_ReadConfiguration(bs, &flag, &propset);
        ::SysFreeString(bs); // Don't leak...
        if(FAILED(hr))
        {
            mLogger->LogVarArgs (LOG_TRACE, "File <%s> not found, falling over to the default one", fullsqlfilepath.c_str());
            return FALSE;
        }
        pDBAccessInfo = new MTDBAccessInfo ;
        ASSERT (pDBAccessInfo) ;
        if (pDBAccessInfo == NULL)
        {
            mLogger->LogVarArgs (LOG_TRACE, "Unable to allocate memory for dbaccess file <%s>", fullsqlfilepath.c_str());
            return FALSE;
        }
        if(!ReadDbAccessFile(*pDBAccessInfo, propset))
        {
            mLogger->LogVarArgs(LOG_ERROR,"Failed to read system %s file", fullsqlfilepath.c_str());
            return FALSE;
        }
        // Save off the single global instance
        if(isDefault) pGlobalDefaultDBAccessInfo = pDBAccessInfo;

    }
    BSTR cdir = ::SysAllocStringLen(arDBAccessKey.data(), arDBAccessKey.size()); 
    mDBAccessColl[cdir] = (isDefault) ? pGlobalDefaultDBAccessInfo : pDBAccessInfo;
    SysFreeString(cdir); // Don't leak...
    return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/// CMTQueryInfo Methods
// ----------------------------------------------------------------
// Name:          C'Tor
// Arguments:     arQueryTagString      Unique tag for the query
//                arFilePath            Full Directory Path to the query
//                arFileName            Query file name
//                arHinterString        Optional hinter string (Defa
// Return Value:  none
// Errors Raised: DB_ERR_INVALID_PARAMETER when filename, path or tag are emtpy.
// Description:   Initializes a CMTQueryInstance
// ----------------------------------------------------------------
CMTQueryInfo::CMTQueryInfo(const mtwstring &arQueryTagString, const mtwstring & arFilePath, 
    const mtwstring & arFileName, const mtwstring &arHinterString = EmptyString)
{
    if(arQueryTagString == NULL || arFileName == NULL || arFilePath == NULL)
    {
        mLogger->LogVarArgs(LOG_ERROR, "Manditory parameter is null (%x, %x, %x)", arQueryTagString, arFilePath, arFileName);
        throw DB_ERR_INVALID_PARAMETER;
    }
    if(arQueryTagString.length() == 0 || arFileName.length() == 0 || arFilePath.length() == 0)
    {
        mLogger->LogVarArgs(LOG_ERROR, "Manditory parameter is empty (%x, %x, %x)", arQueryTagString.length(), arFilePath.length(), arFileName.length());
        throw DB_ERR_INVALID_PARAMETER;
    }
    if(arQueryTagString == L"" || arFileName == L"" || arFilePath == L"")
    {
        mLogger->LogVarArgs(LOG_ERROR, "Manditory parameter is empty (%ls, %ls, %ls)", arQueryTagString.c_str(), arFilePath.c_str(), arFileName.c_str());
        throw DB_ERR_INVALID_PARAMETER;
    }

    mPath = arFilePath;
    mFileName = arFileName;
    mTag = arQueryTagString;
    AddHinter(arHinterString);
}

// ----------------------------------------------------------------
// Name:          AddHinter
// Arguments:     arHinterSource - hinter source for creating a hinter object
// Return Value:  TRUE is hinter is creates, otherwise the failing HRESULT code
// Errors Raised: 
// Description:   Creates a Hinter (MTSql) helper
// ----------------------------------------------------------------
BOOL CMTQueryInfo::AddHinter(const mtwstring & arHinterSource = EmptyString)
{
    if(arHinterSource == NULL || arHinterSource.length() == 0|| arHinterSource == L"")
    {
        mHinter = NULL;
        mLogger->LogVarArgs(LOG_TRACE, "No hinter for query %ls", mTag.c_str());
        return TRUE;
    }
    // Create our instance
    MetraTech_DataAccess_Hinter::IQueryHinterPtr hinter;
    HRESULT hr = hinter.CreateInstance(__uuidof(MetraTech_DataAccess_Hinter::QueryHinter));
    if (FAILED(hr)) 
    {
        mLogger->LogVarArgs(LOG_ERROR, "Could not create Hinter, COM HResult=%d", hr);
        return hr;
    }

    // compiles the hinter source
    hinter->Initialize(_bstr_t(ascii(arHinterSource.c_str()).c_str()), _bstr_t(ascii(mTag.c_str()).c_str()));

    mHinter = hinter;
    return TRUE;
}

// ----------------------------------------------------------------
// Name:          LoadFromFile
// Arguments:     arFilePath - Full path to the sql file
//                arFileName - Query File Name
// Return Value:  Boolean (True on load, false on failure)
// Errors Raised: 
// Description:   Loads the query into the query object. This is used for 
//                supporting lazy load
// ----------------------------------------------------------------
BOOL CMTQueryInfo::LoadFromFile(const mtwstring & arFilePath, const mtwstring & arFileName)
{
    mtwstring fullsqlfilepath = arFilePath;
    // Check for the trailing slash, and add it if necessary
    if(arFilePath[arFilePath.length() - 1] != '\\')
    {
        fullsqlfilepath += L"\\";
    }
    fullsqlfilepath += arFileName;

    // Make sure the file is actually there...
    boost::filesystem::path sqlfilepath(ascii(fullsqlfilepath.c_str()).c_str()); 
    if (!boost::filesystem::exists(fullsqlfilepath))
    {
        mLogger->LogVarArgs(LOG_ERROR, "file  %ls doesn't exist, please correct support settings or replace file.", fullsqlfilepath.c_str());
        return FALSE;
    }

    std::ifstream file(fullsqlfilepath); 
    file.open (fullsqlfilepath, std::ios::in );
    if (file.is_open())
    {
        file.seekg(0, std::ios::beg); 
        std::wstring str((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        mQuery.reserve(str.length());
        mQuery.assign(str);
        file.close();
        return TRUE;
    }
    // Lets not leak...
    file.close();
    mLogger->LogVarArgs(LOG_ERROR, "Could not load query tag %ls from file %ls", mTag.c_str(), fullsqlfilepath.c_str());
    return FALSE;
}

///////////////////////////////////////////////////////////////////////////////

BOOL MTQueryCollection::AddQuery(const string &arQueryTag, 
    const string &arQueryString)
{
    // add the query to the list ...
    if (mQueryColl.count(arQueryTag) == 0)
    {
        mQueryColl[arQueryTag] = arQueryString;
    }
    else
    {
        return FALSE ;
    }

    return TRUE ;
}

BOOL MTQueryCollection::FindQuery (const string &arQueryTag, 
    string &arQueryString)
{
    // find the query in the list ...
    if (mQueryColl.count(arQueryTag) == 0)
        return FALSE;

    arQueryString = mQueryColl[arQueryTag];

    return TRUE ;
}

BOOL MTQueryCollection::AddHinter(const string & arQueryTag, 
    const string & arHinterSource)
{
    if (mHinterColl.count(arQueryTag) == 1)
        return FALSE; // hints have already been added for this query

    if (arHinterSource.length() == 0)
        return S_OK;

    MetraTech_DataAccess_Hinter::IQueryHinterPtr hinter;
    HRESULT hr = hinter.CreateInstance(__uuidof(MetraTech_DataAccess_Hinter::QueryHinter));
    if (FAILED(hr))
        return hr;

    // compiles the hinter source
    hinter->Initialize(_bstr_t(arHinterSource.c_str()), _bstr_t(arQueryTag.c_str()));

    mHinterColl[arQueryTag] = hinter;
    return TRUE;
}

BOOL MTQueryCollection::FindHinter(const string & arQueryTag, MetraTech_DataAccess_Hinter::IQueryHinterPtr & apHinter)
{
    if (mHinterColl.count(arQueryTag) == 0)
    {
        // no hinter is associated with the query
        apHinter = NULL;
        return FALSE; 
    }

    apHinter = mHinterColl[arQueryTag];

    return TRUE;
}

///////////////////////////////////////////////////////////////////////////////

BOOL MTDBAccessInfo::AddInfo (const _bstr_t &arAccessType, 
    const _bstr_t &arUserName, 
    const _bstr_t &arPassword, 
    const _bstr_t &arDBName, 
    const _bstr_t &arLogicalServerName, 
    const _bstr_t &arServerName, 
    const _bstr_t &arDBType, 
    const _bstr_t &arProvider, 
    const long &arTimeout,
    const _bstr_t &arDataSource)
{
    // copy the parameters ...
    mUserName = arUserName ;
    mPassword = arPassword ;
    mDBName = arDBName ;
    mLocicalServerName = arLogicalServerName ;
    mServerName = arServerName ;
    mAccessType = arAccessType ;
    mDBType = arDBType ;
    mProvider = arProvider ;
    mDataSource = arDataSource ;

    mTimeout = arTimeout ;

    return TRUE ;
}

//
//
//


BOOL CMTQueryCache::ReadDbAccessFile(MTDBAccessInfo& aInfo,
    MTConfigLib::IMTConfigPropSetPtr& propset)
{

    if(!ParseXMLTagsAndInitInfo(aInfo, propset))
        return FALSE;
    //Done parsing, now set necessary defaults and log
    _bstr_t accessType = aInfo.GetAccessType();

    if ((accessType == ((_bstr_t) MTACCESSTYPE_ADO)) ||
        (accessType == ((_bstr_t) MTACCESSTYPE_OLEDB)))
    {

        if(!aInfo.GetDBName().length())
        {
            mLogger->LogVarArgs(LOG_ERROR, "Specified  DB access type <%s> requires dbname to be specified", (char*)accessType);
            return FALSE;
        }
        if(!aInfo.GetServerName().length())
        {
            //get localhost name
            DWORD nMaxSize=MAX_COMPUTERNAME_LENGTH + 1 ;
            char computerName[MAX_COMPUTERNAME_LENGTH + 1] ;

            BOOL bRetCode = ::GetComputerNameA(computerName, &nMaxSize) ;
            if (!bRetCode)
            {
                SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "MTQueryCache::Init",
                    "Unable to get computer name.") ;
                mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
                return Error ("Unable to get computer name.") ;
            }
            // otherwise copy the computername ...
            else
            {
                aInfo.SetServerName(_bstr_t(computerName));
            }
            mLogger->LogVarArgs(LOG_TRACE, "<servername> element not found in DBAccess.xml, assume localhost: <%s>", computerName);
        }
    }

    // otherwise if the access type is ADO-DSN ...
    else if ((accessType == ((_bstr_t) MTACCESSTYPE_ADO_DSN)) ||
        (accessType == ((_bstr_t) MTACCESSTYPE_OLEDB_DSN)))
    {
        if(!aInfo.GetDataSource().length())
        {
            mLogger->LogVarArgs(LOG_ERROR, "Specified DB access type <%s> requires datasource to be specified", (char*)accessType);
            return FALSE;        
        }
    }
    // otherwise ... invalid access type ...
    else 
    {
        mLogger->LogVarArgs (LOG_ERROR, "Invalid database access type found. Access type = %s.",
            (char*) accessType) ;
        return Error("Invalid database access type found") ;
    }

    if(!aInfo.GetDBType().length())
    {
        aInfo.SetDBType(_bstr_t(DEFAULT_DATABASE_TYPE));
        mLogger->LogVarArgs(LOG_TRACE, "<dbtype> element not found in DBAccess.xml, assume default: <%s>", (char*)aInfo.GetDBType());
    }
    if(!aInfo.GetProvider().length())
    {
        if (aInfo.GetDBType() == _bstr_t("{Oracle}"))
        {
            aInfo.SetProvider(_bstr_t(ORACLE_PROVIDER_TYPE));
            mLogger->LogVarArgs(LOG_TRACE, "<provider> element not found in DBAccess.xml, assume default: <%s>", (char*)aInfo.GetProvider());
        }
        else
        {
            aInfo.SetProvider(_bstr_t(SQLSERVER_PROVIDER_TYPE));
            mLogger->LogVarArgs(LOG_TRACE, "<provider> element not found in DBAccess.xml, assume default: <%s>", (char*)aInfo.GetProvider());
        }
    }
    if(aInfo.GetTimeout() < 0)
    {
        aInfo.SetTimeout(DEFAULT_TIMEOUT_VALUE);
        mLogger->LogVarArgs(LOG_TRACE, "<timeout> element not found in DBAccess.xml, assume default: <%d>", aInfo.GetTimeout());
    }

    /*
    // add the dbacces information ...
    bRetCode = aInfo.AddInfo(accessType, userName, password, dbName, 
    serverName, dbType, provider, timeout, dataSource) ;
    if (bRetCode == FALSE)
    {
    mLogger->LogVarArgs (LOG_ERROR, 
    "Unable to add database access configuration information.");
    Error ("Unable to add database access configuration information.");
    }
    */
    return TRUE;
}

BOOL CMTQueryCache::Decrypt(std::string& arStr)
{
    // step 1: obtain the handle to the current thread
    HANDLE hThread = ::GetCurrentThread();
    BOOL bError = TRUE;
    HANDLE hToken = INVALID_HANDLE_VALUE;

    do {

        // step 2: get the thread token
        bError = ::OpenThreadToken(hThread,TOKEN_QUERY | TOKEN_IMPERSONATE,TRUE,&hToken);
        if(!bError) {
            DWORD Error = ::GetLastError();
            // I think we get this error because we don't always have a security access token.  For instance,
            // we get this error when running the pipeline or usageservermaintainance.  Probably
            // the only place where we have an access token is when running under the context of IIS.
            if(Error != ERROR_NO_TOKEN) {
                mLogger->LogVarArgs(LOG_ERROR,"failed to open thread token: Error %d",Error);
                break;
            }
        }

        // step 3: revert to self
        if(hToken != INVALID_HANDLE_VALUE) {
            if(!::RevertToSelf()) {
                mLogger->LogThis(LOG_WARNING,"Failed to revert to self.");
            }
        }

        // step 4: attempt decryption

        if(!mbCryptoInitialized) {
            // do the crypto stuff here
            int result = mCrypto.CreateKeys("mt_dbaccess", TRUE, "dbaccess");
            if (result == 0) {
                result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, "mt_dbaccess", TRUE, "dbaccess");
                if(result == 0) {
                    mbCryptoInitialized = true;
                    bError = TRUE;
                }
                else {
                    mLogger->LogThis(LOG_ERROR,"failed in mCrypto::Initialize");
                    bError = FALSE;
                }
            }
            else {
                mLogger->LogThis(LOG_ERROR,"Failed in CMTCryptoAPI::CreateKeys");
                bError = FALSE;
            }
        }
        if(mbCryptoInitialized) {
            bError = mCrypto.Decrypt(arStr) == 0 ? TRUE : FALSE;
        }
    } while(false);

    // step 5: revert token and clean up
    if(hThread != INVALID_HANDLE_VALUE && hToken != INVALID_HANDLE_VALUE) {
        if(!SetThreadToken(NULL,hToken)) {
            mLogger->LogVarArgs(LOG_ERROR,"SetThreadToken call failed; Error %d",::GetLastError());
        }
        ::CloseHandle(hToken);
    }
    return bError;
}


BOOL CMTQueryCache::ParseXMLTagsAndInitInfo(MTDBAccessInfo& aInfo,
    MTConfigLib::IMTConfigPropSetPtr& propset)
{
    _bstr_t dbName,serverName,accessType,userName,password;
    _bstr_t dataSource,provider,dbType, logicalname;

    BOOL bDBNameFound(FALSE);
    BOOL bServerNameFound(FALSE);
    BOOL bDBTypeFound(FALSE);
    BOOL bDataSourceNameFound(FALSE);
    BOOL bProviderFound(FALSE);
    BOOL bTimeoutFound(FALSE);

    long timeout;
    BOOL bRetCode;
    MTConfigLib::IMTConfigAttribSetPtr attribSet;
    MTConfigLib::IMTConfigPropPtr propPtr;
    MTConfigLib::IMTConfigPropPtr innerPropPtr;

    bRetCode = TRUE;
    map<mtwstring, PropValType>::iterator it;
    MTConfigLib::IMTConfigPropSetPtr dbset;

    //iterate thru DBAccess.xml file
    try
    {
        while( (propPtr = propset->Next()) != NULL)
        {
            //1. If not found amoung supported properties, then display error
            mtwstring wsName =  (wchar_t*)propPtr->GetName();
            wsName.tolower();
            it = mDBAccessProps.find(wsName);
            
            if(it == mDBAccessProps.end())
            {
                mLogger->LogVarArgs (LOG_ERROR, 
                    "Not supported property: <%s>", ascii(wsName).c_str());
                map<mtwstring, PropValType>::iterator iter;   
                for( iter = mDBAccessProps.begin(); iter != mDBAccessProps.end(); iter++ ) {
                     mLogger->LogVarArgs (LOG_ERROR, "VALID PROPERTY ENTRY: %s", ascii(iter->first).c_str());
                }
                continue;
            }
            else
            {
                //2. Check if type matches
                if(propPtr->GetPropType() != (*it).second)
                {
                    mLogger->LogVarArgs (LOG_ERROR, 
                        "Property is supported, but types mismatch: <%s>/<%d>", ascii(wsName).c_str(), (int)propPtr->GetPropType());
                    continue;
                }
                //3.    check if the tag type is set and log error
                //        if the name is not "database_config", otherwise parse inner tags
                if(propPtr->GetPropType() == PROP_TYPE_SET)
                {
                    it = mDBAccessProps.find(wsName);
                    if(it == mDBAccessProps.end())
                    {
                        //TODO: will never get here
                        mLogger->LogVarArgs (LOG_ERROR, 
                            "Set other then \"database_config\" found: <%s>",ascii(wsName).c_str());
                        continue;
                    }
                    else
                    {
                        _variant_t vtDisp = propPtr->GetPropValue();
                        HRESULT hr = vtDisp.pdispVal->QueryInterface(__uuidof(IMTConfigPropSet),
                            reinterpret_cast<void**>(&dbset));
                        if (FAILED(hr))
                            return hr;
                        //recurse
                        if(!ParseXMLTagsAndInitInfo(aInfo, dbset)) return FALSE;

                    }
                }

                //4. Why do we need version?
                if(!_wcsicmp ( wsName.c_str(), L"version"))
                {
                    long version = propPtr->GetPropValue().lVal;
                    continue;
                }

                //5. Read Access Type
                if(!_wcsicmp ( wsName.c_str(), L"dbaccess_type"))
                {
                    accessType = propPtr->GetValueAsString();
                    aInfo.SetAccessType(accessType);
                    continue;
                }
                //6. Read User Name
                if(!_wcsicmp ( wsName.c_str(), L"dbusername"))
                {
                    userName = propPtr->GetValueAsString();
                    aInfo.SetUserName(userName);
                    continue;
                }
                //7. Read Password
                if(!_wcsicmp ( wsName.c_str(), L"dbpassword"))
                {
                    attribSet = propPtr->GetAttribSet();
                    //Password is not encrypted
                    if (attribSet == NULL)
                    {
                        mLogger->LogThis(LOG_TRACE, "Password not encrypted in dbaccess.xml file");
                        password = propPtr->GetValueAsString();
                        aInfo.SetPassword(password);
                        continue;
                    }
                    else
                    {
                        _variant_t vtValue = attribSet->GetAttrValue("encrypted");
                        if ((0 == _wcsicmp(vtValue.bstrVal, L"TRUE")) ||
                            (0 == _wcsicmp(vtValue.bstrVal, L"T")) ||
                            (0 == _wcsicmp(vtValue.bstrVal, L"YES")) ||
                            (0 == _wcsicmp(vtValue.bstrVal, L"Y")))
                        {
                            // ------------------------------------------------------
                            // the password coming back here is encrypted password.  
                            // we need to decrypt it.
                            // base64 decode and decrypt the password property that is 
                            // coming in to this function
                            _bstr_t bstrEncryptedPassword = propPtr->GetValueAsString();
                            std::string sPlainText((const char *)bstrEncryptedPassword);
                            if (!Decrypt(sPlainText))
                            {
                                mLogger->LogThis (LOG_ERROR, 
                                    "Failed to decrypt the password buffer") ;
                                return FALSE;
                            }
                            password = sPlainText.c_str();
                            aInfo.SetPassword(password);
                            continue;
                        }
                        else
                        {
                            mLogger->LogVarArgs (LOG_ERROR, 
                                "Unknown Atrribute Value: <%s>", (const char*)vtValue.bstrVal);
                            continue;
                        }
                    }
                }
                //7. Read DB Name
                if(!_wcsicmp ( wsName.c_str(), L"dbname"))
                {
                    bDBNameFound = TRUE;
                    dbName = propPtr->GetValueAsString();
                    aInfo.SetDBName(dbName);
                    continue;
                }
                //7. Read Server Name
                if(!_wcsicmp ( wsName.c_str(), L"servername"))
                {
                    bServerNameFound = TRUE;
                    serverName = propPtr->GetValueAsString();
                    aInfo.SetServerName(serverName);
                    continue;
                }
                //7. Read Data source name
                if(!_wcsicmp ( wsName.c_str(), L"datasource"))
                {
                    bDataSourceNameFound = TRUE;
                    dataSource = propPtr->GetValueAsString();
                    aInfo.SetDSN(dataSource);
                    continue;
                }
                //8. DB Type
                if(!_wcsicmp ( wsName.c_str(), L"dbtype"))
                {
                    bDBTypeFound = TRUE;
                    dbType = propPtr->GetValueAsString();
                    aInfo.SetDBType(dbType);
                    continue;
                }
                //9. Provider
                if(!_wcsicmp ( wsName.c_str(), L"provider"))
                {
                    bProviderFound = TRUE;
                    provider = propPtr->GetValueAsString();
                    aInfo.SetProvider(provider);
                    continue;
                }
                //10. Timeout
                if(!_wcsicmp ( wsName.c_str(), L"timeout"))
                {
                    bTimeoutFound = TRUE;
                    timeout = propPtr->GetPropValue().lVal;
                    aInfo.SetTimeout(timeout);
                    continue;
                }

                //11. Logical server name
                if (!_wcsicmp( wsName.c_str(), L"logical_servername"))
                {
                    // if a "logical" server name is specified, read the info out
                    // of config\ServerAccess\servers.xml
                    COdbcConnectionInfo info;
                    try {
                        info = COdbcConnectionManager::GetConnectionInfo(propPtr->GetValueAsString());
                    }
                    catch(_com_error& e)
                    {
                        mLogger->LogVarArgs(LOG_ERROR, "Failed reading logical_servername %s from Config\\ServerAccess\\servers.xml. Error <%x>", (char *) propPtr->GetValueAsString(), e.Error());
                        throw;
                    }
                    logicalname = propPtr->GetValueAsString();
                    aInfo.SetLogicalServerName(logicalname);
                    
                    std::wstring buffer;
                    // override any information not already set
                    if (aInfo.GetDBName().length() == 0)
                    {
                        ASCIIToWide(buffer, info.GetCatalog());
                        aInfo.SetDBName(const_cast<wchar_t *>(buffer.c_str()));
                    }

                    if (aInfo.GetServerName().length() == 0)
                    {
                        ASCIIToWide(buffer, info.GetServer());
                        aInfo.SetServerName(const_cast<wchar_t *>(buffer.c_str()));
                    }

                    if (aInfo.GetDataSource().length() == 0)
                    {
                        ASCIIToWide(buffer, info.GetDataSource());
                        if(!buffer.empty())
                        {
                            aInfo.SetDSN(const_cast<wchar_t *>(buffer.c_str()));

                            //if DSN provided, force access Type to ADO-DSN
                            aInfo.SetAccessType(const_cast<wchar_t *>(MTACCESSTYPE_ADO_DSN));
                        }
                    }

                    if (aInfo.GetDBDriver().length() == 0)
                    {
                        ASCIIToWide(buffer, info.GetDatabaseDriver());
                        aInfo.SetDBDriver(const_cast<wchar_t *>(buffer.c_str()));
                    }

                    if (aInfo.GetUserName().length() == 0)
                    {
                        ASCIIToWide(buffer, info.GetUserName());
                        aInfo.SetUserName(const_cast<wchar_t *>(buffer.c_str()));
                    }

                    if (aInfo.GetPassword().length() == 0)
                    {
                        ASCIIToWide(buffer, info.GetPassword());
                        aInfo.SetPassword(const_cast<wchar_t *>(buffer.c_str()));
                    }

                    // only override the type if it's not set in the file
                    if (aInfo.GetDBType().length() == 0)
                    {
                        COdbcConnectionInfo::DBType dbtype = info.GetDatabaseType();
                        if (dbtype == COdbcConnectionInfo::DBTYPE_SQL_SERVER)
                            aInfo.SetDBType(L"{SQL Server}");
                        else if (dbtype == COdbcConnectionInfo::DBTYPE_ORACLE)
                            aInfo.SetDBType(L"{Oracle}");
                        else
                        {
                            ASSERT(0);
                            aInfo.SetDBType(L"{SQL Server}");
                        }
                    }

                    // only override the timeout if it's not set in the file
                    if (aInfo.GetTimeout() == DEFAULT_TIMEOUT_VALUE)
                        aInfo.SetTimeout(info.GetTimeout());

                }

            }
        }
    }
    catch(_com_error& e)
    {
        mLogger->LogVarArgs(LOG_ERROR, "Failed parsing DBAccess.xml. Error <%x>", e.Error());
        return FALSE;
    }
    return TRUE;
}

mtwstring Replace(mtwstring source, mtwstring match, mtwstring replacement)
{
    size_t pos;
    do
    {
        pos = source.find(match);
        if (pos != mtwstring::npos)  
            source.replace(pos, match.length(), replacement);
    }
    while (pos != mtwstring::npos);
    return source;
}

MTDBAccessInfo * CMTQueryCache::GetDBAccessInfo(const wchar_t * apConfigPath)
{
    mtwstring wstr(apConfigPath);
    mLogger->LogVarArgs(LOG_TRACE, "GetDBAccessInfo(%ls)", wstr.c_str());
    if(!gVersion1Flag)
    {
        wstr.tolower();
        if(wstr.at(0) == L'\\')
        {
            // Found preceeding slash, clearing now...
            mtwstring newstr;
            newstr.reserve(wstr.length());
            newstr.assign(wstr.begin() + 1, wstr.end());
            wstr.assign(newstr.begin(), newstr.end());
        }
    }
        
    MTDBAccessInfoColl::iterator it = mDBAccessColl.find(wstr.c_str());
    if (it == mDBAccessColl.end())
    {
        if(!gVersion1Flag)
        {
            // First see if there a the string dbinstall, and replace it w/ install
            // Case When the string is "queries\dbinstall" or "queries\dbinstall\abc"
            mtwstring queryInstallPathStr = Replace(wstr, L"queries\\dbinstall", L"install");
            if(queryInstallPathStr.length() > 0)
            {
                mLogger->LogVarArgs(LOG_TRACE, "Trying by prefixing path GetDBAccessInfo(%ls)", queryInstallPathStr.c_str());
                it = mDBAccessColl.find(queryInstallPathStr.c_str());
                if (it != mDBAccessColl.end())
                    return it->second;
                mLogger->LogVarArgs(LOG_TRACE, "Prefixing path GetDBAccessInfo(%ls) FAILED", queryInstallPathStr.c_str());
            }

            mtwstring dbinstallPathStr = Replace(wstr, L"dbinstall", L"install");
            if(dbinstallPathStr.length() > 0)
            {
                mLogger->LogVarArgs(LOG_TRACE, "Trying by prefixing path GetDBAccessInfo(%ls)", dbinstallPathStr.c_str());
                it = mDBAccessColl.find(dbinstallPathStr.c_str());
                if (it != mDBAccessColl.end())
                    return it->second;
                mLogger->LogVarArgs(LOG_TRACE, "Prefixing path GetDBAccessInfo(%ls) FAILED", dbinstallPathStr.c_str());
            }
            return pGlobalDefaultDBAccessInfo;
        }
        // DumpDBAccessColl();
        return NULL;
    }
    return it->second;
}
