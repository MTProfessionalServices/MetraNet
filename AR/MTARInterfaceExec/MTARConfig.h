// MTARConfig.h : Declaration of the CMTARConfig

#ifndef __MTARCONFIG_H_
#define __MTARCONFIG_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTARConfig
class ATL_NO_VTABLE CMTARConfig : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTARConfig, &CLSID_MTARConfig>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTARConfig, &IID_IMTARConfig, &LIBID_MTARINTERFACEEXECLib>
{
public:
	         CMTARConfig();
	virtual ~CMTARConfig();

DECLARE_REGISTRY_RESOURCEID(IDR_MTARCONFIG)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTARConfig)

BEGIN_COM_MAP(CMTARConfig)
	COM_INTERFACE_ENTRY(IMTARConfig)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();


// IMTARConfig
public:
	STDMETHOD(Configure)(/*[in, optional]*/ VARIANT aInternalSystemInfo, /*[out, retval]*/ VARIANT* configState);


private:
	CComPtr<IObjectContext> m_pObjectContext;
  bool                    m_isAREnabled;
  _bstr_t                 m_arConfigProgID;
};

#endif //__MTARCONFIG_H_
