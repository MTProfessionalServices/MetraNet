// COMUsageInterval.h : Declaration of the CCOMUsageInterval

#ifndef __COMUSAGEINTERVAL_H_
#define __COMUSAGEINTERVAL_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <UsageInterval.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageInterval
class ATL_NO_VTABLE CCOMUsageInterval : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUsageInterval, &CLSID_COMUsageInterval>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMUsageInterval, &IID_ICOMUsageInterval, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMUsageInterval() ;
  virtual ~CCOMUsageInterval() ;
  
DECLARE_REGISTRY_RESOURCEID(IDR_COMUSAGEINTERVAL)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMUsageInterval)
	COM_INTERFACE_ENTRY(ICOMUsageInterval)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUsageInterval
public:
	STDMETHOD(get_AccountExists)(long aAccountID,/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(Init)(/*[in]*/ BSTR apStartDate, /*[in]*/ BSTR apEndDate);
	STDMETHOD(AddAccount)(/*[in]*/ long aAccountID);
	STDMETHOD(Create)();
	STDMETHOD(get_Exists)(/*[out, retval]*/ VARIANT *pVal);
private:
  NTLogger              mLogger ;
  MTUsageInterval         mUsageInterval ;
};

#endif //__COMUSAGEINTERVAL_H_
