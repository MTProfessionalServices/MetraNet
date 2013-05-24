	
// COMKioskGate.h : Declaration of the CCOMKioskGate

#ifndef __COMKIOSKGATE_H_
#define __COMKIOSKGATE_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <KioskGate.h>
#include <ComKioskLogging.h>
#include <autologger.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMKioskGate
class ATL_NO_VTABLE CCOMKioskGate : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMKioskGate, &CLSID_COMKioskGate>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMKioskGate, &IID_ICOMKioskGate, &LIBID_COMKIOSKLib>
{
public:

	// Default constructore
	CCOMKioskGate();

	// Destructor
	virtual ~CCOMKioskGate();

DECLARE_REGISTRY_RESOURCEID(IDR_COMKIOSKGATE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMKioskGate)
	COM_INTERFACE_ENTRY(ICOMKioskGate)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMKioskGate
public:
	STDMETHOD(Initialize)(BSTR providerName, int port);
	STDMETHOD(get_URL)(/*[out, retval]*/ BSTR *pVal);

private:
	// KioskGate object
	CKioskGate mKioskGate;

	// member to check at any time if the object initialised itself
	// properly
	BOOL mIsInitialized;

	MTAutoInstance<MTAutoLoggerImpl<szComKioskGate,szComKioskLoggingDir> >	mLogger;
};

#endif //__COMKIOSKGATE_H_
