/**************************************************************************
 * @doc MTSESSIONPROPDEF
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
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
 *
 * @index | MTSESSIONPROPDEF
 ***************************************************************************/

#ifndef _MTSESSIONPROPDEF_H
#define _MTSESSIONPROPDEF_H

#include "resource.h"       // main symbols

#include <sharedsess.h>

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") 

// "identifier truncated to 255 characters"
#pragma warning (disable : 4786)

//#include <mtatlerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTSession
class ATL_NO_VTABLE CMTSessionProp : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSessionProp, &CLSID_MTSessionProp>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSessionProp, &IID_IMTSessionProp, &LIBID_SESSSERVERLib>
{
public:
	CMTSessionProp();

DECLARE_REGISTRY_RESOURCEID(IDR_MTSESSIONPROP)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTSessionProp)
	COM_INTERFACE_ENTRY(IMTSessionProp)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct();
	void FinalRelease();

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSessionProp
public:
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_NameID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Type)(/*[out, retval]*/ MTSessionPropType *pVal);

public:
	void SetPropInfo(MTSessionPropType aType, _bstr_t aName, long aNameID);

private:
	MTSessionPropType mType;
	_bstr_t mName;
	long mNameID;
};


#endif /* _MTSESSIONPROPDEF_H */
