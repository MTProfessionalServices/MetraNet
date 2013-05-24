// MTModuleDescriptor.h : Declaration of the CMTModuleDescriptor

#ifndef __MTMODULEDESCRIPTOR_H_
#define __MTMODULEDESCRIPTOR_H_

#include "resource.h"       // main symbols
#include <comutil.h>
#include "MTModule.h"

/////////////////////////////////////////////////////////////////////////////
// CMTModuleDescriptor
class ATL_NO_VTABLE CMTModuleDescriptor : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTModuleDescriptor, &CLSID_MTModuleDescriptor>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTModuleDescriptor, &IID_IMTModuleDescriptor, &LIBID_MODULEREADERLib>
{
public:
	CMTModuleDescriptor()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTMODULEDESCRIPTOR)

BEGIN_COM_MAP(CMTModuleDescriptor)
	COM_INTERFACE_ENTRY(IMTModuleDescriptor)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTModuleDescriptor
public:
	STDMETHOD(get_ModConfigInfo)(/*[out, retval]*/ IMTModule** pVal);
	STDMETHOD(put_ModConfigInfo)(/*[in]*/ IMTModule* newVal);
	STDMETHOD(get_OrgType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_OrgType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(IsSubDir)(/*[out]*/ VARIANT_BOOL* pBool);

  
protected: // data
  IMTModulePtr mModPtr;
  _bstr_t mName;
  _bstr_t mOrgType;
};

#endif //__MTMODULEDESCRIPTOR_H_
