	
// COMUsageIntervalColl.h : Declaration of the CCOMUsageIntervalColl

#ifndef __COMUSAGEINTERVALCOLL_H_
#define __COMUSAGEINTERVALCOLL_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <MTRowSetImpl.h>

// forward declarations 
struct IMTSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageIntervalColl
class ATL_NO_VTABLE CCOMUsageIntervalColl : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUsageIntervalColl, &CLSID_COMUsageIntervalColl>,
	public ISupportErrorInfo,
	public MTRowSetImpl<ICOMUsageIntervalColl, &IID_ICOMUsageIntervalColl, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMUsageIntervalColl() ;
  virtual ~CCOMUsageIntervalColl() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMUSAGEINTERVALCOLL)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMUsageIntervalColl)
	COM_INTERFACE_ENTRY(ICOMUsageIntervalColl)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMUsageIntervalColl)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUsageIntervalColl
public:
  STDMETHOD(InitByStateAndPeriodType)(BSTR aState, BSTR aPeriodType) ;
  STDMETHOD(ExportByTimePeriod)(BSTR aExportMethod, VARIANT aStartDate, VARIANT aEndDate);
	STDMETHOD(get_Expired)(VARIANT aDate,/*[out,retval]*/ VARIANT *pVal);
	STDMETHOD(get_Closed)(VARIANT aDate,/*[out,retval]*/ VARIANT *pVal);
  STDMETHOD(GetAccountUsageMap)(/*[out,retval]*/ LPDISPATCH *pAccountUsageMap);
	STDMETHOD(get_Status)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Status)(/*[in]*/ BSTR newVal);
	STDMETHOD(Init)(/*[in]*/ BSTR aStatus);

private:
  NTLogger              mLogger ;
};

#endif //__COMUSAGEINTERVALCOLL_H_
