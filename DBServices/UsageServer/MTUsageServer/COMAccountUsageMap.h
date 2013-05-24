// COMAccountUsageMap.h : Declaration of the CCOMAccountUsageMap

#ifndef __COMACCOUNTUSAGEMAP_H_
#define __COMACCOUNTUSAGEMAP_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <MTRowSetImpl.h>

// forward declarations 
struct IMTSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMAccountUsageMap
class ATL_NO_VTABLE CCOMAccountUsageMap : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMAccountUsageMap, &CLSID_COMAccountUsageMap>,
  public ISupportErrorInfo,
	public MTRowSetImpl<ICOMAccountUsageMap, &IID_ICOMAccountUsageMap, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMAccountUsageMap() ;
  virtual ~CCOMAccountUsageMap() ;
  
DECLARE_REGISTRY_RESOURCEID(IDR_COMACCOUNTUSAGEMAP)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMAccountUsageMap)
	COM_INTERFACE_ENTRY(ICOMAccountUsageMap)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMAccountUsageMap)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMAccountUsageMap
public:
	STDMETHOD(InitByAccountID)(long aAccountID);
  STDMETHOD(InitByIntervalID)(long aIntervalID) ;
	STDMETHOD(get_Status)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Status)(/*[in]*/ BSTR newVal);

private:
  NTLogger              mLogger ;
};

#endif //__COMACCOUNTUSAGEMAP_H_
