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
* Created by: Kevin Fitzgerald
* $Header$
* 
***************************************************************************/
	
// MTStdMonthly.h : Declaration of the CMTStdMonthly

#ifndef __MTSTDMONTHLY_H_
#define __MTSTDMONTHLY_H_

#include <comdef.h>
#include "resource.h"       // main symbols
#include <NTLogger.h>
#undef min
#undef max
#include <MTDate.h>

/////////////////////////////////////////////////////////////////////////////
// CMTStdMonthly
class ATL_NO_VTABLE CMTStdMonthly : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTStdMonthly, &CLSID_MTStdMonthly>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUsageCycle, &IID_IMTUsageCycle, &LIBID_MTSTDUSAGECYCLELib>
{
public:
	CMTStdMonthly() ;
	virtual ~CMTStdMonthly() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSTDMONTHLY)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTStdMonthly)
	COM_INTERFACE_ENTRY(IMTUsageCycle)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTStdUsageCycle
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
  void CreateStartAndEndDate (const MTDate &arToday, const long &arDayOfMonth, 
															_bstr_t &arStartDate, _bstr_t &arEndDate) ;
  HRESULT GetAndValidateProperty (ICOMUsageCyclePropertyColl *apUCPropColl,
    long &arDayOfMonth) ;

  NTLogger mLogger ;
};

#endif //__MTSTDMONTHLY_H_
