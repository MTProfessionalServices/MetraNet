	
// MTProductViewDef.h : Declaration of the CMTProductViewDef

#ifndef __MTPRODUCTVIEWDEF_H_
#define __MTPRODUCTVIEWDEF_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <NTLogger.h>

#include <MSIXDefinition.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewDef
class ATL_NO_VTABLE CMTProductViewDef : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProductViewDef, &CLSID_MTProductViewDef>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProductViewDef, &IID_IMTProductViewDef, &LIBID_MTPRODUCTVIEWLib>
{
public:
    // default constructor
	CMTProductViewDef();

    // destructor
    virtual ~CMTProductViewDef();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTVIEWDEF)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTProductViewDef)
	COM_INTERFACE_ENTRY(IMTProductViewDef)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProductViewDef
public:
	STDMETHOD(get_exttablename)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_exttablename)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_tablename)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_tablename)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_minorversion)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_minorversion)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_majorversion)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_majorversion)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Save)();
	STDMETHOD(Initialize)();
	STDMETHOD(AddProperty)(BSTR dn, BSTR type, BSTR length, BSTR required, BSTR defaultVal);

private:
    // instance of msix definition object
    CMSIXDefinition* mpProdViewDef;

  //CServices* mpServices;
    BOOL mIsInitialized;

    NTLogger mLogger;
};

#endif //__MTPRODUCTVIEWDEF_H_
