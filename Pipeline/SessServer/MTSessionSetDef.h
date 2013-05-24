/**************************************************************************
 * @doc MTSESSIONSET
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTSESSIONSET_H_
#define __MTSESSIONSET_H_

//-----
#include "MTSessionSetBaseDef.h"

HRESULT WINAPI _This(void*,REFIID,void**,DWORD);

//----- Forward declarations.
class CMTSessionServerBase;

//-----
class ATL_NO_VTABLE CMTSessionSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSessionSet, &CLSID_MTSessionSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSessionSet, &IID_IMTSessionSet, &LIBID_SESSSERVERLib>
{
	public:
		CMTSessionSet();

		void SetServer(CMTSessionServerBase* apServerBase)
		{
			ASSERT(mpSessionSetBase);
			if (mpSessionSetBase)
				mpSessionSetBase->SetServer(apServerBase);
		}

		void SetSessionSet(CMTSessionSetBase* apSessionSetBase)
		{
			if (mpSessionSetBase)
				delete mpSessionSetBase;
				
			mpSessionSetBase = apSessionSetBase;
		}

    void GetSessionSet(CMTSessionSetBase** apSessionSetBase)
		{
			(*apSessionSetBase) = mpSessionSetBase;
		}

		DECLARE_REGISTRY_RESOURCEID(IDR_MTSESSIONSET)
		DECLARE_GET_CONTROLLING_UNKNOWN()

		BEGIN_COM_MAP(CMTSessionSet)
			COM_INTERFACE_ENTRY(IMTSessionSet)
			COM_INTERFACE_ENTRY(IDispatch)
			COM_INTERFACE_ENTRY(ISupportErrorInfo)
      COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_This)
		END_COM_MAP()

		HRESULT FinalConstruct();
		void FinalRelease();

	// ISupportsErrorInfo
		STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	// IMTSessionSet
	public:
		STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
		STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
		STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
		STDMETHOD(AddSession)(long aSessionId, long aServiceId);
		STDMETHOD(get_ID)(long * apID);
		STDMETHOD(get_UID)(/*[out]*/ unsigned char uid[]);
		STDMETHOD(SetUID)(/*[int]*/ unsigned char uid[]);
		STDMETHOD(get_UIDAsString)(/*[out, retval]*/ BSTR *pVal);

		// NOTE: use this method with caution
		STDMETHOD(IncreaseSharedRefCount)(long * apNewCount);

		// NOTE: use this method with caution
		STDMETHOD(DecreaseSharedRefCount)(long * apNewCount);

		// NOTE: use this method with caution
		STDMETHOD(GetInternalSetHandle)(/*[out, retval]*/ long *pVal);

	private:
		CMTSessionSetBase* mpSessionSetBase;
};

#endif //__MTSESSIONSET_H_

//-- EOF --