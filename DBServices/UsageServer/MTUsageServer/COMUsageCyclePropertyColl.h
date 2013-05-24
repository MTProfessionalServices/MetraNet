// COMUsageCyclePropertyColl.h : Declaration of the CCOMUsageCyclePropertyColl

#ifndef __COMUSAGECYCLEPROPERTYCOLL_H_
#define __COMUSAGECYCLEPROPERTYCOLL_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>

#include <map>
#include <string>

// typedefs ...
typedef std::map<std::wstring, _variant_t>	UsageCyclePropColl;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCyclePropertyColl
class ATL_NO_VTABLE CCOMUsageCyclePropertyColl : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUsageCyclePropertyColl, &CLSID_COMUsageCyclePropertyColl>,
	public ISupportErrorInfo,
	public IDispatchImpl<ICOMUsageCyclePropertyColl, &IID_ICOMUsageCyclePropertyColl, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMUsageCyclePropertyColl() ;
  virtual ~CCOMUsageCyclePropertyColl() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMUSAGECYCLEPROPERTYCOLL)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CCOMUsageCyclePropertyColl)
	COM_INTERFACE_ENTRY(ICOMUsageCyclePropertyColl)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUsageCyclePropertyColl
public:
// The AddProperty method adds a property to the collection.
  STDMETHOD(AddProperty)(BSTR aName, VARIANT aValue) ;
// The GetProperty method adds a property to the collection.
  STDMETHOD(GetProperty)(BSTR aName, VARIANT *apValue) ;
// The ModifyProperty method modifies the specified property in the collection.
  STDMETHOD(ModifyProperty)(BSTR aName, VARIANT aValue) ;
private:
  NTLogger              mLogger ;
  UsageCyclePropColl    mPropColl ;
};

#endif //__COMUSAGECYCLEPROPERTYCOLL_H_
