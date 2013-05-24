// MTHookHandlerImpl.h : Declaration of the CMTHookHandler

#ifndef __MTHOOKHANDLER_H_
#define __MTHOOKHANDLER_H_

#include "resource.h"       // main symbols
#include <mtcom.h>
#include <comdef.h>
#include <vector>
#include <NTLogger.h>

#import <MTHooklib.tlb>  rename("EOF", "xxEOF")
#import <MTHookHandler.tlb> rename("EOF", "xxEOF")
using namespace MTHookLib;

using std::vector;

/////////////////////////////////////////////////////////////////////////////
// CMTHookHandler
class ATL_NO_VTABLE CMTHookHandler : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTHookHandler, &CLSID_MTHookHandler>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTHookHandler, &IID_IMTHookHandler, &LIBID_MTHOOKHANDLERLib>
{
public:
  CMTHookHandler();

DECLARE_REGISTRY_RESOURCEID(IDR_MTHOOKHANDLER)

BEGIN_COM_MAP(CMTHookHandler)
	COM_INTERFACE_ENTRY(IMTHookHandler)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTHookHandler
public:
	STDMETHOD(ExecuteAll)();
	STDMETHOD(Next)();
	STDMETHOD(First)();
	STDMETHOD(Read)(/*[in]*/ IMTConfigPropSet* pPropSet);

	STDMETHOD(FirstHook)(/*[in]*/ VARIANT var, /*[in, out]*/ long* pVal);
	STDMETHOD(NextHook)(/*[in]*/ VARIANT var, /*[in, out]*/ long* pVal);
	STDMETHOD(ExecuteAllHooks)(/*[in]*/ VARIANT var, /*[in]*/ long val);

	STDMETHOD(get_HookCount)(/*[out, retval]*/ int * count);

	STDMETHOD(ClearHooks)();
	STDMETHOD(RunHookWithProgid)(BSTR aHookProgid,VARIANT var,long* val);

	STDMETHOD(put_SessionContext)(::IMTSessionContext * apSessionContext);

protected: // methods
  HRESULT RunHook(unsigned int, VARIANT var,
									long * val);
protected:
  // data

	vector<IMTHookPtr> mHookList;
	vector<IMTSecuredHookPtr> mSecuredHookList;

  //RWTValOrderedVector<RWCString> mHookList;
  unsigned int mHookIndex;
  NTLogger mLogger;

	// context passed to hooks
	MTHOOKHANDLERLib::IMTSessionContextPtr mSessionContext;
};

inline bool operator ==(const IMTHookPtr aPtr1, const IMTHookPtr aPtr2)
{
	return aPtr1 == aPtr2;
}

#endif //__MTHOOKHANDLER_H_
