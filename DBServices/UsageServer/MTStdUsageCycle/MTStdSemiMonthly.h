/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Travis Gebhardt
* $Header$
* 
***************************************************************************/

// MTStdSemiMonthly.h : Declaration of the CMTStdSemiMonthly

#ifndef __MTSTDSEMIMONTHLY_H_
#define __MTSTDSEMIMONTHLY_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <MTDate.h>

#import <MTConfigLib.tlb> 
using namespace MTConfigLib;


/////////////////////////////////////////////////////////////////////////////
// CMTStdSemiMonthly
class ATL_NO_VTABLE CMTStdSemiMonthly : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTStdSemiMonthly, &CLSID_MTStdSemiMonthly>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUsageCycle, &IID_IMTUsageCycle, &LIBID_MTSTDUSAGECYCLELib>
{
public:
	CMTStdSemiMonthly() ;
  virtual ~CMTStdSemiMonthly() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSTDSEMIMONTHLY)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTStdSemiMonthly)
	COM_INTERFACE_ENTRY(IMTUsageCycle)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTUsageCycle
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
  void CreateStartAndEndDate(const MTDate &arToday,
														 const long &arFirstDay, const long &arSecondDay,
														 _bstr_t &arStartDate, _bstr_t &arEndDate);
	HRESULT GetAndValidateProperty(::ICOMUsageCyclePropertyColl *apUCPropColl,
																 long &arFirstDay, long &arSecondDay);

	BOOL GetUsageServerConfigInfo(long &arIntervalCreate);
  
  NTLogger mLogger;
};

#endif //__MTSTDSEMIMONTHLY_H_
