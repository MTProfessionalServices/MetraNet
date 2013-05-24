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
* $Header: s:\Core\DataAccess\QueryAdapter\MTQueryCache.h, 20, 7/24/2002 1:59:46 PM, Derek Young$
* 
***************************************************************************/
// MTQueryCache.h : Declaration of the CMTQueryCache

#ifndef __MTQUERYCACHE_H_
#define __MTQUERYCACHE_H_

#include "resource.h"       // main symbols
#include <comsingleton.h>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <errobj.h>
#include <ConfigChange.h>
#include <NTThreadLock.h>
#include <mtcryptoapi.h>

#include <map>
#include <set>
#include <string>
#include <stdutils.h>
#import <MTConfigLib.tlb>

#include <mtcomerr.h>

using namespace MTConfigLib;

using namespace std;

#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX")
#import <QueryAdapter.tlb> rename ("GetUserName", "QAGetUserName")

#import <MetraTech.DataAccess.Hinter.tlb> inject_statement("using namespace mscorlib; using namespace QUERYADAPTERLib;")
#import <MetraTech.DataAccess.QueryManagement.tlb> inject_statement("using namespace mscorlib;")

//#import <MTRuleSet.tlb>
//using namespace MTRULESETLib;

// forward declarations ...
class MTQueryCollection ;
class CMTQueryInfo ;

///////////////////////////////////////////////////////////////////////////////
///  MTDBAccessInfo 
class MTDBAccessInfo
{
public:
    MTDBAccessInfo() :    mTimeout(-1), 
        mDBName(""), 
        mLocicalServerName(""), 
        mServerName(""), 
        mDBType(""), 
        mProvider("") {} ;
    ~MTDBAccessInfo() {} ;

    BOOL AddInfo (const _bstr_t &arAccessType, const _bstr_t &arUserName, 
                  const _bstr_t &arPassword, const _bstr_t &arDBName, 
                  const _bstr_t &arLogicalServerName, const _bstr_t &arServerName, const _bstr_t &arDBType, 
                  const _bstr_t &arProvider, const long &arTimeout, const _bstr_t &arDataSource) ;
    _bstr_t& GetUserName() { return mUserName; } ;
    _bstr_t& GetPassword() { return mPassword; } ;
    _bstr_t& GetDBName() { return mDBName ;} ;
    _bstr_t& GetLogicalServerName() { return mLocicalServerName; } ;
    _bstr_t& GetServerName() { return mServerName; } ;
    _bstr_t& GetAccessType() { return mAccessType; } ;
    _bstr_t& GetDBType() { return mDBType; } ;
    _bstr_t& GetProvider() { return mProvider; } ;
    const long GetTimeout() const { return mTimeout; } ;
    _bstr_t& GetDataSource() { return mDataSource; } ;
    _bstr_t& GetDBDriver() { return mDBDriver; } ;

    void SetAccessType(wchar_t* aVal){mAccessType = aVal; };
    void SetUserName(wchar_t* aVal){mUserName = aVal; };
    void SetPassword(wchar_t* aVal){mPassword = aVal; };
    void SetDBName(wchar_t* aVal){mDBName = aVal; };
    void SetDBType(wchar_t* aVal){mDBType = aVal; };
    void SetLogicalServerName(wchar_t* aVal){mLocicalServerName = aVal; };
    void SetServerName(wchar_t* aVal){mServerName = aVal; };
    void SetProvider(wchar_t* aVal){mProvider = aVal; };
    void SetTimeout(const long& aVal){mTimeout = aVal; };
    void SetDSN(wchar_t* aVal){mDataSource = aVal; };
    void SetDBDriver(wchar_t* aVal){mDBDriver = aVal; };

private:
    _bstr_t   mUserName ;
    _bstr_t   mPassword ;
    _bstr_t   mDBName ;
    _bstr_t   mLocicalServerName ;
    _bstr_t   mServerName ;
    _bstr_t   mAccessType ;
    _bstr_t   mDBType ;
    _bstr_t   mProvider ;
    long      mTimeout ;
    _bstr_t   mDataSource ;
    _bstr_t   mDBDriver ;
} ;


///////////////////////////////////////////////////////////////////////////////
///  TYPEDEFS
///////////////////////////////////////////////////////////////////////////////
typedef std::map< wstring, CMTQueryInfo*> t_querycache;
typedef map<string, string> MTQueryColl;
typedef map<string, MetraTech_DataAccess_Hinter::IQueryHinterPtr> MTHinterColl;
typedef map<wstring, MTDBAccessInfo *> MTDBAccessInfoColl;
typedef map<wstring, MTQueryCollection *> MTQueryFileColl;
typedef set<wstring> MTConfigDirColl;

/////////////////////////////////////////////////////////////////////////////
// CMTQueryCache
class ATL_NO_VTABLE CMTQueryCache : 
    public CComObjectRootEx<CComMultiThreadModel>,
    public CComCoClass<CMTQueryCache, &CLSID_MTQueryCache>,
    public ISupportErrorInfo,
    public IDispatchImpl<IMTQueryCache, &IID_IMTQueryCache, &LIBID_QUERYADAPTERLib>,
    public virtual ObjectWithError,
    public ConfigChangeObserver
{
public:
    CMTQueryCache() ;
    virtual ~CMTQueryCache() ;

    // NOTE: don't use DECLARE_CLASSFACTORY_SINGLETON in DLLs!
    DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTQueryCache>)

    DECLARE_REGISTRY_RESOURCEID(IDR_MTQUERYCACHE)
    DECLARE_GET_CONTROLLING_UNKNOWN()

    BEGIN_COM_MAP(CMTQueryCache)
        COM_INTERFACE_ENTRY(IMTQueryCache)
        COM_INTERFACE_ENTRY(IDispatch)
        COM_INTERFACE_ENTRY(ISupportErrorInfo)
    END_COM_MAP()

    // ISupportsErrorInfo
    STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

    // IMTQueryCache
public:

    // Description: The GetDataSource method gets the datasource from the dbaccess.xml file.
    STDMETHOD(GetDataSource)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apDataSource);
    // Description: The GetTimeout method gets the timeout value from the dbaccess.xml file.
    STDMETHOD(GetTimeout)(BSTR apConfigPath,/*[out,retval]*/ long *apTimeout);
    // Description: The GetAccessType method gets the database access type from the dbaccess.xml file.
    STDMETHOD(GetAccessType)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apAccessType);
    // Description: The GetDBType method gets the database type from the dbaccess.xml file.
    STDMETHOD(GetDBType)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apDBType);
    // Description: The GetProvider method gets the provider from the dbaccess.xml file.
    STDMETHOD(GetProvider)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apProvider);
    // Description: The GetServerName method gets the server name from the dbaccess.xml file.
    STDMETHOD(GetLogicalServerName)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apServerName);
    // Description: The GetServerName method gets the server name from the dbaccess.xml file.
    STDMETHOD(GetServerName)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apServerName);
    // Description: The GetDBName method gets the database name from the dbaccess.xml file.
    STDMETHOD(GetDBName)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apDBName);
    // Description: The GetPassword method gets the database password from the dbaccess.xml file.
    STDMETHOD(GetPassword)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apPassword);
    // Description: The GetUserName method gets the database username from the dbaccess.xml file.
    STDMETHOD(GetUserName)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apUserName);
    // Description: The GetQueryString method gets the query string as it exists in the configuration file.
    STDMETHOD(GetQueryString)(BSTR apConfigPath,/*[in]*/ BSTR apQueryTag,/*[out,retval]*/ BSTR *apQueryString);
    // Description: The Init method initializes the query cache with the relative configuration path to the query file.
    STDMETHOD(Init)(/*[in]*/ BSTR apConfigPath);
    STDMETHOD(GetDBDriver)(BSTR apConfigPath,/*[out,retval]*/ BSTR *apDBDriver);
    STDMETHOD(RefreshConfiguration)(/*[in]*/ VARIANT_BOOL ImmediateReload, /*[out, retval]*/ long *pVal);
    // returns the compiled MTSQL hinter associated with the given query.
    STDMETHOD(GetHinter)(BSTR apConfigPath,/*[in]*/ BSTR apQueryTag,/*[out,retval]*/ IDispatch** apHinter);

    virtual void ConfigurationHasChanged() ;
    
protected:
    ///////////////////////////////////////////////////////////////////
    // Version 2 support for QueryManagement project
    BOOL Init_v2(const MetraTech_DataAccess_QueryManagement::IQueryMapperPtr & arQueryMapper);
    BOOL GetQueryString_v2(BSTR apQueryTag, BSTR *apQueryString);
    BOOL GetHinter_v2(BSTR apQueryTag, IDispatch** apHinter);

    BOOL PopulateCache(IEnumVARIANT* queryPropertiesArray);
    BOOL AddQueryInfo(const mtwstring & arQTag, const mtwstring & arQPath,const mtwstring & arQName, const mtwstring & arQHinter);
    BOOL AddDBAccessInfo(const BOOL isDefault, const mtwstring & arDBAccessKey, const mtwstring & arDBAccessPath,const mtwstring & arDBAccessName);
    mtwstring GetTag (const mtwstring & arFileName);

    //////////////////////////////////////////////////////////////////
    BOOL ReadDbAccessFile(MTDBAccessInfo&,MTConfigLib::IMTConfigPropSetPtr&);
    BOOL ParseXMLTagsAndInitInfo(MTDBAccessInfo&,MTConfigLib::IMTConfigPropSetPtr&);
    BOOL Decrypt(std::string& arStr);
private:
    void DumpDBAccessColl()
    {
        mLogger->LogVarArgs(LOG_DEBUG, "GetDBAccessInfo DUMP COLLECTION");
        MTDBAccessInfoColl::iterator dbgit;
        int i = 1;
        for (dbgit = mDBAccessColl.begin(); dbgit != mDBAccessColl.end(); ++dbgit)
        {
            mLogger->LogVarArgs(LOG_DEBUG, "mDBAccessColl[%d] = %ls", i, dbgit->first.c_str());
            i++;
        }
    }
    // add queries from the given file to the cache
    HRESULT AddQueries(const wchar_t * apFilename,
                       const wchar_t * apConfigDir,
                       const wchar_t * apConfigPath,
                       BOOL bQueryAdapterPresent, BOOL bAbsolutePath,
                       MTQueryCollection *pQueryCollection);

    // add queries from the given queryadapter file to the cache
    // by calling AddQueries for files specified in the query adapter file
    HRESULT AddQueriesFromQueryAdapterFile(const wchar_t * apFilename,   //Full path of the query adapter file
                                           const wchar_t * apConfigPath, // the 'configpath' from Init, used as the identifier when adding queries to collection
                                           MTDBAccessInfo * apDBAccessInfo, //Used to determine if the database is SQL or Oracle
                                           MTQueryCollection *pQueryCollection); //Query collection the queries will be added to

    // encryption object
    CMTCryptoAPI mCrypto;

    void TearDown() ;

    MTDBAccessInfo * GetDBAccessInfo(const wchar_t * apConfigPath);
private:
    MTAutoInstance<MTAutoLoggerImpl<szQueryCacheTag,szDbObjectsDir> >    mLogger; 
    t_querycache           mTagQueryColl;
    MTQueryFileColl        mQueryFileColl;
    MTConfigDirColl        mConfigDirColl;
    MTDBAccessInfoColl     mDBAccessColl;
    MTDBAccessInfo         mDBGlobalDBAccessInfo;
    bool                   mbGlobalDbAccessInit;
    bool                   mbCryptoInitialized;
    ConfigChangeObservable mObservable;
    BOOL                   mObserverInitialized;
    NTThreadLock           mLock;
    map<mtwstring, PropValType> mDBAccessProps;
};

///////////////////////////////////////////////////////////////////////////////
class CMTQueryInfo
{
public:
    CMTQueryInfo(const mtwstring &arQueryTagString, const mtwstring & arFilePath, const mtwstring & arFileName, const mtwstring &arHinterString);

    ~CMTQueryInfo() {};
    
    mtwstring Tag()
    {
        return mTag;
    }

    mtwstring Query()
    {
        if(0 == mQuery.length())
            LoadFromFile(mPath, mFileName);

        ++mUsageCount;
        return mQuery;
    }

    mtwstring InfoFile()
    {
        return mFileName;
    }

    MetraTech_DataAccess_Hinter::IQueryHinterPtr Hinter()
    {
        if(NULL != mHinter)
            return mHinter.Detach();
        return NULL;
    }

    long UsageCount()
    {
        return mUsageCount;
    }

protected:
    BOOL AddHinter(const mtwstring & arHinterSource);
    BOOL LoadFromFile(const mtwstring & arFilePath, const mtwstring & arFileName);

private:
    mtwstring mTag;
    mtwstring mFileName;
    mtwstring mPath;
    mtwstring mQuery;
    long mTimeout;
    MetraTech_DataAccess_Hinter::IQueryHinterPtr mHinter;
    long mUsageCount;
    MTAutoInstance<MTAutoLoggerImpl<szQueryCacheTag,szDbObjectsDir> >    mLogger;
};

///////////////////////////////////////////////////////////////////////////////
class MTQueryCollection
{
public:
    MTQueryCollection() {} ;

    ~MTQueryCollection() 
    {
        mQueryColl.clear();
        mHinterColl.clear();
    }

    BOOL AddQuery(const string &arQueryTag, const string &arQueryString) ;
    BOOL FindQuery (const string &arQueryTag, string &arQueryString) ;

    // adds an optional MTSQL procedure which provides hint logic for the given query
    BOOL AddHinter(const string &arQueryTag, const string &arHinter);
    BOOL FindHinter(const string &arQueryTag, MetraTech_DataAccess_Hinter::IQueryHinterPtr & apHinter);

private:
    MTQueryColl                     mQueryColl;
    MTHinterColl                    mHinterColl;

};

#endif //__MTQUERYCACHE_H_
