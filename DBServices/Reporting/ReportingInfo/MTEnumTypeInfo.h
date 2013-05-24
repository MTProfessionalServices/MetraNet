	
// MTEnumTypeInfo.h : Declaration of the CMTEnumTypeInfo

#ifndef __MTENUMTYPEINFO_H_
#define __MTENUMTYPEINFO_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <NTLogger.h>

/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeInfo
class ATL_NO_VTABLE CMTEnumTypeInfo : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumTypeInfo, &CLSID_MTEnumTypeInfo>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumTypeInfo, &IID_IMTEnumTypeInfo, &LIBID_REPORTINGINFOLib>
{
public:
	CMTEnumTypeInfo() ;
  virtual ~CMTEnumTypeInfo() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMTYPEINFO)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEnumTypeInfo)
	COM_INTERFACE_ENTRY(IMTEnumTypeInfo)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTEnumTypeInfo
public:
  STDMETHOD(Drop)();
	STDMETHOD(Create)();
	STDMETHOD(Remove)();
	STDMETHOD(Add)();
private:
  NTLogger    mLogger ;
};

#endif //__MTENUMTYPEINFO_H_
