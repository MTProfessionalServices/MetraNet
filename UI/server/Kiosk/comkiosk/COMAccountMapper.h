	
// COMAccountMapper.h : Declaration of the CCOMAccountMapper

#ifndef __COMACCOUNTMAPPER_H_
#define __COMACCOUNTMAPPER_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <AccountMapper.h>
#include <ComKioskLogging.h>
#include <autologger.h>


/////////////////////////////////////////////////////////////////////////////
// CCOMAccountMapper
class ATL_NO_VTABLE CCOMAccountMapper : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMAccountMapper, &CLSID_COMAccountMapper>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMAccountMapper, &IID_ICOMAccountMapper, &LIBID_COMKIOSKLib>
{
public:

	// Default constructor
	CCOMAccountMapper();

	// Destructor
	virtual ~CCOMAccountMapper();

DECLARE_REGISTRY_RESOURCEID(IDR_COMACCOUNTMAPPER)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMAccountMapper)
	COM_INTERFACE_ENTRY(ICOMAccountMapper)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMAccountMapper
public:
	STDMETHOD(Modify)(int ActionType, BSTR LoginName,  BSTR NameSpace,  BSTR NewLoginName,  BSTR NewNameSpace, LPDISPATCH pRowset);
	STDMETHOD(MapAccountIdentifier)(/*[in]*/ BSTR fromAccountIdentifier, /*[in]*/ BSTR fromName_space, BSTR toName_space, /*[out]*/ BSTR * pAccountIdentifier);
	STDMETHOD(Initialize)();
	STDMETHOD(Add)(BSTR login, BSTR name_space, long lAccID, LPDISPATCH pRowset);
	
private:
  // pointer to c++ account mapper object
  CAccountMapper mAccountMapper;
  
  // member to check if the object initialized itself
  // properly
  BOOL mIsInitialized;
  
	MTAutoInstance<MTAutoLoggerImpl<szComKioskAccountMapper,szComKioskLoggingDir> >	mLogger;
};

#endif //__COMACCOUNTMAPPER_H_
