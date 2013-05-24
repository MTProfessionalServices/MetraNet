	
// MTLanguageList.h : Declaration of the CMTLanguageList

#ifndef __MTLANGUAGELIST_H_
#define __MTLANGUAGELIST_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <errobj.h>
#include <NTLogger.h>

#include <vector>
#include <string>

using std::vector;

#include "MTSiteConfigDefs.h"

#import <MTConfigLib.tlb> 
using namespace MTConfigLib ;

/////////////////////////////////////////////////////////////////////////////
// CMTLanguageList
class ATL_NO_VTABLE CMTLanguageList : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTLanguageList, &CLSID_MTLanguageList>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTLanguageList, &IID_IMTLanguageList, &LIBID_MTSITECONFIGLib>,
  public virtual ObjectWithError
{
public:
	CMTLanguageList() ;
  virtual ~CMTLanguageList() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTLANGUAGELIST)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTLanguageList)
	COM_INTERFACE_ENTRY(IMTLanguageList)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTLanguageList
public:
	STDMETHOD(Initialize)(/*[in]*/ BSTR aHostName, /*[in]*/ BSTR aRelativePath, 
    /*[in]*/ BSTR aRelativeFile);
	STDMETHOD(Add)(/*[in]*/ BSTR aName, /*[in]*/ BSTR aDescription);
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);

private:
  vector<CComVariant> mLanguageList;
  long                  mSize;
  NTLogger              mLogger ;
  BOOL                  mInitialized ;
  std::wstring             mHostName ;

};

#endif //__MTLANGUAGELIST_H_
