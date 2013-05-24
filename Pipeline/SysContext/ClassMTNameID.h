
// MTNameID.h : Declaration of the CMTNameID

#ifndef __MTNAMEID_H_
#define __MTNAMEID_H_

// ADO includes
#include <comdef.h>
#include <adoutil.h>

#include <CodeLookup.h>

#include "resource.h"       // main symbols

#include <comutil.h>
#include <comsingleton.h>


/////////////////////////////////////////////////////////////////////////////
// CMTNameID
class ATL_NO_VTABLE CMTNameID :
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTNameID, &CLSID_MTNameID>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTNameID, &IID_IMTNameID, &LIBID_SYSCONTEXTLib>
{
public:
	CMTNameID();

	~CMTNameID();

// NOTE: don't use DECLARE_CLASSFACTORY_SINGLETON in DLLs!
//DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTNameID>)

DECLARE_REGISTRY_RESOURCEID(IDR_MTNAMEID)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTNameID)
	COM_INTERFACE_ENTRY(IMTNameID)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease();

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTNameID
public:
	STDMETHOD(GetNameID)(BSTR name, long * id);
	STDMETHOD(GetName)(long id, BSTR * name);

private:
	// critical section to lock next id and name pool map
	CComAutoCriticalSection mNamePoolLock;

	CCodeLookup * mpCodeLookup;

#ifdef DEBUG
	int * mLeakDetector;
#endif
};

#endif //__MTNAMEID_H_
