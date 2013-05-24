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
	
// MTStdOnDemand.h : Declaration of the CMTStdOnDemand

#ifndef __MTSTDONDEMAND_H_
#define __MTSTDONDEMAND_H_

#include <comdef.h>
#include "resource.h"       // main symbols
#include <NTLogger.h>
#undef min
#undef max
#include <MTDate.h>

/////////////////////////////////////////////////////////////////////////////
// CMTStdOnDemand
class ATL_NO_VTABLE CMTStdOnDemand : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTStdOnDemand, &CLSID_MTStdOnDemand>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUsageCycle, &IID_IMTUsageCycle, &LIBID_MTSTDUSAGECYCLELib>
{
public:
	CMTStdOnDemand() ;
	virtual ~CMTStdOnDemand() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSTDONDEMAND)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTStdOnDemand)
	COM_INTERFACE_ENTRY(IMTUsageCycle)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
  
  // IMTStdOnDemand
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

#endif //__MTSTDONDEMAND_H_
