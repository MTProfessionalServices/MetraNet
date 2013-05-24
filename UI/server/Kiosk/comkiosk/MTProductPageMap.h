	
// MTProductPageMap.h : Declaration of the CMTProductPageMap

#ifndef __MTPRODUCTPAGEMAP_H_
#define __MTPRODUCTPAGEMAP_H_

#include "resource.h"       // main symbols
#include <atlbase.h>
#include <NTLogger.h>
#include <mtglobal_msg.h>
#include <KioskDefs.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <ConfigChange.h>
#include <ComKioskLogging.h>
#include <autologger.h>
#include <vector>

using std::vector;

// import the configloader tlb file
#import <MTConfigLib.tlb>
using namespace MTConfigLib;

// == operator
inline bool operator ==(const CComVariant & arVar1, const CComVariant & arVar2)
{
    ASSERT(0);
	return FALSE;
}

// == operator
inline bool operator <(const CComVariant & arVar1, const CComVariant & arVar2)
{
    ASSERT(0);
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// CMTProductPageMap
class ATL_NO_VTABLE CMTProductPageMap : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProductPageMap, &CLSID_MTProductPageMap>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProductPageMap, &IID_IMTProductPageMap, &LIBID_COMKIOSKLib>,
	public ConfigChangeObserver
{
public:
	CMTProductPageMap()
	{
		mSize = 0;
		mObserverInitialized = FALSE;
	}

    virtual ~CMTProductPageMap()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTPAGEMAP)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProductPageMap)
	COM_INTERFACE_ENTRY(IMTProductPageMap)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	void FinalRelease()
	{
		mSiteCollectionList.clear();
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProductPageMap
public:
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(Add)(IMTSiteCollection* pMTSiteCollection);
	STDMETHOD(Initialize)(BSTR aNameSpace);
    virtual void ConfigurationHasChanged();

private:
    long mSize;
		MTAutoInstance<MTAutoLoggerImpl<szCOMKioskProductPageMap,szComKioskLoggingDir> >	mLogger;
    vector<CComVariant> mSiteCollectionList;

    BOOL mObserverInitialized;
    ConfigChangeObservable mObserver;
		_bstr_t mExtensionName;
};

#endif //__MTPRODUCTPAGEMAP_H_
