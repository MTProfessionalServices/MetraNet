/**************************************************************************
 * MTBigIntegerOps
 *
 * Copyright 1997-2000 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTBIGINTEGEROPS_H_
#define __MTBIGINTEGEROPS_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTBigIntegerOps
class ATL_NO_VTABLE CMTBigIntegerOps : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTBigIntegerOps, &CLSID_MTBigIntegerOps>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTBigIntegerOps, &IID_IMTBigIntegerOps, &LIBID_MTDECIMALOPSLib>
{
public:
	CMTBigIntegerOps()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTBIGINTEGEROPS)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTBigIntegerOps)
	COM_INTERFACE_ENTRY(IMTBigIntegerOps)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTBigIntegerOps
public:
	STDMETHOD(Create)(/*[in]*/ VARIANT aValue, /*[out, retval]*/ VARIANT * pResult);	
	STDMETHOD(Compare)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ long * pResult);
	STDMETHOD(Divide)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT * pResult);
	STDMETHOD(Multiply)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT * pResult);
	STDMETHOD(Subtract)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT* pResult);
	STDMETHOD(Add)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT * pResult);

	STDMETHOD(EQ)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT_BOOL * pResult);
	STDMETHOD(NE)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT_BOOL * pResult);
	STDMETHOD(LT)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT_BOOL * pResult);
	STDMETHOD(LE)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT_BOOL * pResult);
	STDMETHOD(GT)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT_BOOL * pResult);
	STDMETHOD(GE)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ VARIANT_BOOL * pResult);
};

#endif //__MTDECOPS_H_
