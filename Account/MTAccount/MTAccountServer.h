	
// MTAccountServer.h : Declaration of the CMTAccountServer

#ifndef __MTACCOUNTSERVER_H_
#define __MTACCOUNTSERVER_H_

#include "resource.h"       // main symbols
#include <errobj.h>
#include <NTLogger.h>
#include "MTAccountDefs.h"
#include <loggerconfig.h>
#include <AccountServerLogging.h>
#include <autologger.h>
#include <comutil.h>

// for propset
#import <MTConfigLib.tlb>
//using namespace MTConfigLib;


/////////////////////////////////////////////////////////////////////////////
// CMTAccountServer
class ATL_NO_VTABLE CMTAccountServer : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountServer, &CLSID_MTAccountServer>,
	public IDispatchImpl<::IMTAccountAdapter, &IID_IMTAccountAdapter, &LIBID_MTACCOUNTLib>,
	public ISupportErrorInfo,
	public IMTAccountAdapter2
	{
public:
	CMTAccountServer() : mName(""), mProgID(""), mConfigFile("")
	{}

	~CMTAccountServer()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTSERVER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountServer)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter2)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	HRESULT FinalConstruct() { return S_OK; }

	void FinalRelease() { }

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountServer2
public:
	STDMETHOD(Uninstall)();
	STDMETHOD(Install)();
	STDMETHOD(Initialize)(BSTR AdapterName);
	STDMETHOD(AddData)(BSTR ConfigFile, 
				       ::IMTAccountPropertyCollection* mtptr,VARIANT apRowset);
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
	STDMETHOD(SearchDataWithUpdLock)(BSTR AdapeterName,
						::IMTAccountPropertyCollection* mtptr,
						BOOL wUpdLock,
						VARIANT apRowset,
						::IMTSearchResultCollection** mtp);
	STDMETHOD(GetPropertyMetaData)(BSTR aPropertyName,
																 ::IMTPropertyMetaData** apMetaData); 

private:
	MTAutoInstance<MTAutoLoggerImpl<aAccountServerLogTitle> >			mLogger;
	_bstr_t mName;
	_bstr_t mProgID;
	_bstr_t mConfigFile;

	MTACCOUNTLib::IMTAccountAdapter2Ptr mpAccountAdapter;
};

#endif //__MTACCOUNTSERVER_H_
