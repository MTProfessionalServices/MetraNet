// MTAccountFinder.h : Declaration of the CMTAccountFinder

#ifndef __MTACCOUNTFINDER_H_
#define __MTACCOUNTFINDER_H_

#include "resource.h"       // main symbols
#include <DBAccess.h>
#include <NTLogger.h>
#include <AccountServerLogging.h>
#include "MTAccountServer.h"
#include "MTSQLAdapter.h"
#include "MTLDAPAdapter.h"
#include <autologger.h>
#include <map>
#include <set>
#include <string>

#include <SetIterate.h>
#import <MTEnumConfigLib.tlb>
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <RCD.tlb>

using namespace std;

class CMTSearchResultCollection;
class CAdapterInfo;
class CFindProp;

typedef map<string, CAdapterInfo*> AdapterMap;
typedef map<string, CFindProp*> FindPropMap;   
typedef map<long, string> AccMap;

typedef CMSIXProperties::PropertyType PropType;

/////////////////////////////////////////////////////////////////////////////
// CMTAccountFinder
class ATL_NO_VTABLE CMTAccountFinder : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountFinder, &CLSID_MTAccountFinder>,
	public IDispatchImpl<IMTAccountFinder, &IID_IMTAccountFinder, &LIBID_MTACCOUNTLib>,
	public ISupportErrorInfo,
	public DBAccess
{
public:
	CMTAccountFinder(): mMaxRows(100L), mpLDAPServer(NULL) {}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTFINDER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountFinder)
	COM_INTERFACE_ENTRY(IMTAccountFinder)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	HRESULT FinalConstruct();
	void FinalRelease();

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountFinder
public:
	STDMETHOD(Search)(/*[in]*/ IMTAccountPropertyCollection * apAPC, /*[out,retval]*/ IMTSearchResultCollection ** appSRC);
	STDMETHOD(get_MaxRows)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_MaxRows)(/*[in]*/ long newVal);
	
private:

	// data members
	//static const char* DEFAULT_NAMESPACE;				// namespace to search on if none is specified

	long mMaxRows;										// maximum number of rows to be returned	

	enum SearchType {CONTACT, ACCOUNT} mSearchType;		// type of search to perform
	enum ContactSrc {SQL, LDAP} mContactSrc;			// source of contact info

	AdapterMap mAdapterMap;								// map of searchable adapters
	FindPropMap	mPropMap;								// map of searchable properties	
	AccMap mAccMap;										// map of searchable accounts

	CComPtr<IMTSearchResultCollection> mpSRC;			// collection to be returned to the client   
	CComObject<CMTLDAPAdapter> * mpLDAPServer;			// LDAP server

	CComPtr<IMTSearchResultCollection> mpAccountSRC; // account data collection cache

	QUERYADAPTERLib::IMTQueryAdapterPtr mpQueryAdapter;	// query adapter server	
	MTENUMCONFIGLib::IEnumConfigPtr mpEnumConfig;		// EnumConfig server

	MTAutoInstance<MTAutoLoggerImpl<aAccountServerLogTitle> > mLogger;
	
	// member functions
	HRESULT SearchLDAPForContactInfo(long & aCount,long aAccID=0, IMTAccountPropertyCollection * apAPC = NULL);
	HRESULT SearchForAccountIDs(IMTAccountPropertyCollection * apAPC);
	
	HRESULT GetDataForAccID(long aAccID);
	HRESULT GetDataFromAdapters(AdapterMap::iterator& aItr, long aAccID, bool aNewID, IMTSearchResultCollection ** apAPC);
	HRESULT GetDataFromAccount(long aAccID, bool aNewID, IMTSearchResultCollection ** apAPC);

	//Internal Use Only
	HRESULT MergeCollections(	IMTSearchResultCollection* aColl1, 
														IMTSearchResultCollection* aColl2,
														IMTSearchResultCollection** aResultColl);

	HRESULT InitializeAdapters();
	void PopulateFindPropMap();
};


class CFindProp
{
public:
	
	CFindProp(string TableName, string ColName, PropType PType) :
		strTN(TableName), strCN(ColName), type(PType) {}

	string strTN;		// table name
	string strCN;		// column name
	PropType type;		// type
};


class CAdapterInfo
{
public:

	CAdapterInfo(wstring Config, CComPtr<IMTAccountAdapter> pServer) :
		strConfigFile(Config), pAdapter(pServer), pAPC(0) {}

	// explicit release of interface pointers
	~CAdapterInfo() { pAdapter.Release(); pAPC.Release(); }

	wstring strConfigFile;							// account view config file
	CComPtr<IMTAccountAdapter> pAdapter;			// adapter server object
	CComPtr<IMTAccountPropertyCollection> pAPC;		// collection to hold account info
	CComPtr<IMTSearchResultCollection> pSRC;		// collection to hold account info
};



#endif //__MTACCOUNTFINDER_H_
