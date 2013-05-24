	
// MTSQLAdapter.h : Declaration of the CMTSQLAdapter

#ifndef __MTSQLADAPTER_H_
#define __MTSQLADAPTER_H_

#include "resource.h"       // main symbols
#include "DBAccess.h"

#include <NTLogger.h>
#include "MTAccountDefs.h"
#include "AccountDefCreator.h"
#include <msixdefcollection.h>
#include <MSIXDefinitionObjectFactory.h>
#include <AccountServerLogging.h>
#include <autologger.h>



// import the configloader tlb file
#import <MTCLoader.tlb>

#import <MTEnumConfigLib.tlb>
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <RCD.tlb>


/////////////////////////////////////////////////////////////////////////////
// CMTSQLAdapter
class ATL_NO_VTABLE CMTSQLAdapter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSQLAdapter, &CLSID_MTSQLAdapter>,
	public ISupportErrorInfo,
	public IDispatchImpl<::IMTAccountAdapter, &IID_IMTAccountAdapter, &LIBID_MTACCOUNTLib>,
	public MSIXDefCollection,
	public IMTAccountAdapter2
{
public:

	CMTSQLAdapter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSQLADAPTER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSQLAdapter)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter2)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease();

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IMTSQLAdapter
public:


	STDMETHOD(Initialize)(BSTR ConfigFile);
	STDMETHOD(Uninstall)();
	STDMETHOD(Install)();
	STDMETHOD(AddData)(BSTR ConfigFile, 
				       ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);
	STDMETHOD(UpdateData)(BSTR ConfigFile, 
					      ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);
	STDMETHOD(GetData)(BSTR ConfigFile, 
				       long AccountID,
					   VARIANT apRowset,
				       ::IMTAccountPropertyCollection** mtptr);
	STDMETHOD(SearchData)(BSTR AdapeterName,
						::IMTAccountPropertyCollection* mtptr,
						VARIANT apRowset,
						::IMTSearchResultCollection** mtp);
	STDMETHOD(GetPropertyMetaData)(BSTR aPropertyName,
								   ::IMTPropertyMetaData** apMetaData); 
	STDMETHOD(SearchDataWithUpdLock)(BSTR AdapeterName,
						::IMTAccountPropertyCollection* mtptr,
						BOOL wUpdLock,
						VARIANT apRowset,						
						::IMTSearchResultCollection** mtp);

	// the object will be deleted by the constraint set object
	// TODO: need to delete the object in the destructor

	QUERYADAPTERLib::IMTQueryAdapterPtr mpQueryAdapter;	// query adapter server	
	MTENUMCONFIGLib::IEnumConfigPtr mpEnumConfig;		// EnumConfig server

	// @cmember Find the account view by name 
	BOOL FindAccountView (const wstring& arName, CMSIXDefinition *& arpAccountDef) ;

	// @cmember Create tables
	BOOL InstallAccountObjects();

	// @cmember Drop tables
	BOOL UninstallAccountObjects();

	// @cmember Insert Data
	BOOL InsertData(const wstring& arAdapterName, ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);

	// @cmember Update Data 
	BOOL UpdateData(const wstring& arAdapterName, ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);

  //BOOL Initialize(const wchar_t* xmlfilename = NULL);
	HRESULT GenerateGetDataQuery(::IMTAccountPropertyCollection* mtptr,  wstring& langRequest, const wstring& aTableName, BOOL wUpdLock);

	BOOL SqlStatementPrepareVar(_variant_t& vtValue, _bstr_t& sVar);

private:
	AccountDefCreator mCreator;

	MTAutoInstance<MTAutoLoggerImpl<aSQLLogTile> >			mLogger;
	CONFIGLOADERLib::IMTConfigLoaderPtr mpConfigLoader;

	_bstr_t mName;
	_bstr_t mProgID;
	_bstr_t mConfigFile;
  
};

typedef CMTSQLAdapter::MSIXDefinitionList AccountDefList;
typedef CMTSQLAdapter::MSIXDefinitionList::iterator AccountDefListIterator;


#endif //__MTSQLADAPTER_H_
