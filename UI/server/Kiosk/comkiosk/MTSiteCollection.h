	
// MTSiteCollection.h : Declaration of the CMTSiteCollection

#ifndef __MTSITECOLLECTION_H_
#define __MTSITECOLLECTION_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <mtglobal_msg.h>
#include <KioskDefs.h>
#include <ComKioskLogging.h>
#include <autologger.h>
#include <vector>

using std::vector;

/////////////////////////////////////////////////////////////////////////////
// CMTSiteCollection
class ATL_NO_VTABLE CMTSiteCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSiteCollection, &CLSID_MTSiteCollection>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSiteCollection, &IID_IMTSiteCollection, &LIBID_COMKIOSKLib>
{
public:
	CMTSiteCollection() : mSize(0) {}

	virtual ~CMTSiteCollection()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSITECOLLECTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSiteCollection)
	COM_INTERFACE_ENTRY(IMTSiteCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	void FinalRelease()
	{
		mProductCollectionList.clear();
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSiteCollection
public:
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(Add)(IMTProductCollection* pMTProductCollection);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DefaultProduct)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DefaultProduct)(/*[in]*/ BSTR newVal);

private:
    _bstr_t mName;
    _bstr_t mDefaultProduct;
    long mSize;
		MTAutoInstance<MTAutoLoggerImpl<szCOMKioskSiteCollection,szComKioskLoggingDir> >	mLogger;
    vector<CComVariant> mProductCollectionList;
};

#endif //__MTSITECOLLECTION_H_
