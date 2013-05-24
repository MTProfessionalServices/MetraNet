/**************************************************************************
 * @doc MTSESSION
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Created by:	Derek Young
 *				Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTVARIANTSESSIONENUM_H_
#define __MTVARIANTSESSIONENUM_H_

#include "resource.h"       // main symbols
#include "MTVariantSessionEnumBase.h"

//----- Forward declarations
class CMTVariantSessionEnumBase;

class ATL_NO_VTABLE CMTVariantSessionEnum :
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTVariantSessionEnum, &CLSID_MTVariantSessionEnum>,
	public ISupportErrorInfo,
	public IDispatchImpl<IEnumVARIANT, &IID_IEnumVARIANT, &LIBID_SESSSERVERLib>
{
	public:
		CMTVariantSessionEnum();

		void SetVariantSessionEnum(CMTVariantSessionEnumBase* pVariantSessionEnumBase)
		{
			if (mpVariantSessionEnumBase)
				delete mpVariantSessionEnumBase;

			mpVariantSessionEnumBase = pVariantSessionEnumBase;
			mlPos = 0;
			mInitialState = TRUE;
		}

		DECLARE_REGISTRY_RESOURCEID(IDR_MTVARIANTSESSIONENUM)
		DECLARE_GET_CONTROLLING_UNKNOWN()

		BEGIN_COM_MAP(CMTVariantSessionEnum)
			COM_INTERFACE_ENTRY(IEnumVARIANT)
			COM_INTERFACE_ENTRY(ISupportErrorInfo)
		END_COM_MAP()

		HRESULT FinalConstruct();
		void FinalRelease();

	// ISupportsErrorInfo
		STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	// IMTVariantSessionEnum
	public:
		STDMETHOD(Clone)(/*[out]*/ IEnumVARIANT * * ppEnum);
		STDMETHOD(Reset)();
		STDMETHOD(Skip)(ULONG celt);
		STDMETHOD(Next)(unsigned long celt, /*[out, retval]*/ VARIANT * rgvar,
						unsigned long * pceltFetched);

	private: // DATA
		CMTVariantSessionEnumBase* mpVariantSessionEnumBase;

		//----- Maintain current iteration position.
		long mlPos;
		BOOL mInitialState;
};

#endif //__MTVARIANTSESSIONENUM_H_

//-- EOF --