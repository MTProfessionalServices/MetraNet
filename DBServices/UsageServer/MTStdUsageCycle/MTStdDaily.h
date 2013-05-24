// MTStdDaily.h : Declaration of the CMTStdDaily

#ifndef __MTSTDDAILY_H_
#define __MTSTDDAILY_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include "resource.h"       // main symbols
#include <NTLogger.h>
#undef min
#undef max
#include <MTDate.h>

#import <MTConfigLib.tlb> 
using namespace MTConfigLib;

__declspec(dllexport) BOOL GetUsageServerConfigInfo(long &arIntervalCreate) ;

/////////////////////////////////////////////////////////////////////////////
// CMTStdDaily
class ATL_NO_VTABLE CMTStdDaily : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTStdDaily, &CLSID_MTStdDaily>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUsageCycle, &IID_IMTUsageCycle, &LIBID_MTSTDUSAGECYCLELib>
{
public:
	CMTStdDaily() ;
	virtual ~CMTStdDaily() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSTDDAILY)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTStdDaily)
	COM_INTERFACE_ENTRY(IMTUsageCycle)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTStdDaily
public:
  STDMETHOD(AddAccount)(long aAccountID, 
    ICOMUsageCyclePropertyColl *apUCPropColl, long aUsageCycleTypeID, 
    LPDISPATCH pRowset) ;
  STDMETHOD(UpdateAccount)(long aAccountID, 
    ICOMUsageCyclePropertyColl *apUCPropColl, long aUsageCycleTypeID,
    VARIANT aDate) ;
  STDMETHOD(CreateInterval)(VARIANT aDate, 
    ICOMUsageCyclePropertyColl *apUCPropColl, long aUsageCycleTypeID) ;

	STDMETHOD(ComputeStartAndEndDate)(DATE aReferenceDate,
																		ICOMUsageCyclePropertyColl *apProperties,
																		DATE *arStartDate,
																		DATE *arEndDate);

private:
  
  void CreateStartAndEndDate (const MTDate &arToday, _bstr_t &arStartDate, 
    _bstr_t &arEndDate) ;

  NTLogger mLogger ;
};

#endif //__MTSTDDAILY_H_
