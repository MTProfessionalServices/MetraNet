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

// MTStdQuarterly.h : Declaration of the CMTStdQuarterly

#ifndef __MTSTDQUARTERLY_H_
#define __MTSTDQUARTERLY_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <MTDate.h>

/////////////////////////////////////////////////////////////////////////////
// CMTStdQuarterly
class ATL_NO_VTABLE CMTStdQuarterly : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTStdQuarterly, &CLSID_MTStdQuarterly>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUsageCycle, &IID_IMTUsageCycle, &LIBID_MTSTDUSAGECYCLELib>
{
public:
	CMTStdQuarterly() ;
  virtual ~CMTStdQuarterly() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSTDQUARTERLY)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTStdQuarterly)
	COM_INTERFACE_ENTRY(IMTUsageCycle)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTUsageCycle
public:
  STDMETHOD(AddAccount)(/*[in]*/ long aAccountID, /*[in]*/ 
    ICOMUsageCyclePropertyColl *apUCPropColl, /*[in]*/ long aUsageCycleTypeID, 
    LPDISPATCH pRowset) ;
  STDMETHOD(UpdateAccount)(/*[in]*/ long aAccountID, 
													 /*[in]*/ ICOMUsageCyclePropertyColl *apUCPropColl,
													 /*[in]*/ long aUsageCycleTypeID,
													 /*[in]*/ VARIANT aDate);
  STDMETHOD(CreateInterval)(/*[in]*/ VARIANT aDate, 
    /*[in]*/ ICOMUsageCyclePropertyColl *apUCPropColl, /*[in]*/ long aUsageCycleTypeID) ;

	STDMETHOD(ComputeStartAndEndDate)(DATE aReferenceDate,
																		ICOMUsageCyclePropertyColl *apProperties,
																		DATE *arStartDate,
																		DATE *arEndDate);

private:
  HRESULT CreateStartAndEndDate(const MTDate &arToday,
																const long &arMonth, const long &arDay,
																_bstr_t &arStartDate, _bstr_t &arEndDate,
																::ICOMUsageCyclePropertyColl *apUCPropColl);
	HRESULT GetAndValidateProperty(::ICOMUsageCyclePropertyColl *apUCPropColl,
																 long &arMonth, long &arDay);
  
  NTLogger mLogger;
};

#endif //__MTSTDQUARTERLY_H_
