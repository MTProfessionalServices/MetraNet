// MTUsageServerMaintenance.h : Declaration of the CMTUsageServerMaintenance

#ifndef __MTUSAGESERVERMAINTENANCE_H_
#define __MTUSAGESERVERMAINTENANCE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTUsageServerMaintenance
class ATL_NO_VTABLE CMTUsageServerMaintenance : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTUsageServerMaintenance, &CLSID_MTUsageServerMaintenance>,
	public IDispatchImpl<IMTUsageServerMaintenance, &IID_IMTUsageServerMaintenance, &LIBID_MTUSAGESERVERLib>
{
public:
	CMTUsageServerMaintenance()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTUSAGESERVERMAINTENANCE)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTUsageServerMaintenance)
	COM_INTERFACE_ENTRY(IMTUsageServerMaintenance)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTUsageServerMaintenance
public:
	STDMETHOD(RunSpecificRecurringEvent)(/*[in]*/ MTRecurringEvent aEvent);
	STDMETHOD(CloseIntervals)(/*[in]*/ VARIANT aExpirationDate, /*[in]*/ int aSoftGracePeriod, /*[in]*/ int aHardGracePeriod );
	STDMETHOD(RunRecurringEvents)();
};

#endif //__MTUSAGESERVERMAINTENANCE_H_
