// MTCondition.h : Declaration of the CMTCondition

#ifndef __MTCONDITION_H_
#define __MTCONDITION_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTCondition
class ATL_NO_VTABLE CMTCondition : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCondition, &CLSID_MTCondition>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCondition, &IID_IMTCondition, &LIBID_MTRULESETLib>
{
public:
	CMTCondition()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONDITION)

BEGIN_COM_MAP(CMTCondition)
	COM_INTERFACE_ENTRY(IMTCondition)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCondition
public:
};

#endif //__MTCONDITION_H_
