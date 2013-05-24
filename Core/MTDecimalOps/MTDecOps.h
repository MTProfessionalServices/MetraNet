/**************************************************************************
 * MTDecOps
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

#ifndef __MTDECOPS_H_
#define __MTDECOPS_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTDecOps
class ATL_NO_VTABLE CMTDecOps : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTDecOps, &CLSID_MTDecimalOps>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTDecimalOps, &IID_IMTDecimalOps, &LIBID_MTDECIMALOPSLib>
{
public:
	CMTDecOps()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDECOPS)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTDecOps)
	COM_INTERFACE_ENTRY(IMTDecimalOps)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTDecimalOps
public:
	STDMETHOD(Create)(/*[in]*/ VARIANT aValue, /*[out, retval]*/ VARIANT * pResult);	
	STDMETHOD(Compare)(/*[in]*/ VARIANT aVal1, /*[in]*/ VARIANT aVal2, /*[out, retval]*/ long * pResult);
	STDMETHOD(Round)(/*[in]*/ VARIANT aValue, /*[in]*/ int iDecimals, /*[out, retval]*/ VARIANT * pResult);
	STDMETHOD(Negate)(/*[in]*/ VARIANT aValue, /*[out, retval]*/ VARIANT * pResult);
	STDMETHOD(Int)(/*[in]*/ VARIANT aValue, /*[out, retval]*/ VARIANT * pResult);
	STDMETHOD(Fix)(/*[in]*/ VARIANT aValue, /*[out, retval]*/ VARIANT * pResult);
	STDMETHOD(Abs)(/*[in]*/ VARIANT aValue, /*[out, retval]*/ VARIANT * pResult);
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
