	
// MTTimezone.h : Declaration of the CMTTimezone

#ifndef __MTTIMEZONE_H_
#define __MTTIMEZONE_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTTimezone
class ATL_NO_VTABLE CMTTimezone : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTTimezone, &CLSID_MTTimezone>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTTimezone, &IID_IMTTimezone, &LIBID_MTCALENDARLib>
{
public:
	CMTTimezone()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTTIMEZONE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTTimezone)
	COM_INTERFACE_ENTRY(IMTTimezone)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTTimezone
public:
	STDMETHOD(get_TimezoneID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TimezoneID)(/*[in]*/ long newVal);
	STDMETHOD(get_TimezoneOffset)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put_TimezoneOffset)(/*[in]*/ double newVal);

private:
	long mTimezoneID;
	double mTimezoneOffset;
  
};

#endif //__MTTIMEZONE_H_
