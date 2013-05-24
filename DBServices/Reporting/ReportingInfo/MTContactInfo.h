	
// MTContactInfo.h : Declaration of the CMTContactInfo

#ifndef __MTCONTACTINFO_H_
#define __MTCONTACTINFO_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <NTLogger.h>
#include <string>

/////////////////////////////////////////////////////////////////////////////
// CMTContactInfo
class ATL_NO_VTABLE CMTContactInfo : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTContactInfo, &CLSID_MTContactInfo>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTContactInfo, &IID_IMTContactInfo, &LIBID_REPORTINGINFOLib>
{
public:
	CMTContactInfo() ;
  virtual ~CMTContactInfo() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONTACTINFO)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTContactInfo)
	COM_INTERFACE_ENTRY(IMTContactInfo)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTContactInfo
public:
	STDMETHOD(Drop)();
  STDMETHOD(Create)();
	STDMETHOD(Remove)();
	STDMETHOD(Add)();
private:
  BOOL GetContactInfo(const long &arAcctID) ;

  NTLogger    mLogger ;
  _bstr_t   mName ;
  _bstr_t   mAddr1 ;
  _bstr_t   mAddr2 ;
  _bstr_t   mAddr3 ;
  _bstr_t   mCity ;
  _bstr_t   mState ;
  _bstr_t   mZip ;
  _bstr_t   mCountry ;
  _bstr_t   mCompany ;
};

#endif //__MTCONTACTINFO_H_
