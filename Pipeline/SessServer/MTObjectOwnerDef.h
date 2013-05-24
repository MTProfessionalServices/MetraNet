/**************************************************************************
 * @doc MTOBJECTOWNER
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 *			   Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MTOBJECTOWNER
 ***************************************************************************/

#ifndef _MTOBJECTOWNER_H
#define _MTOBJECTOWNER_H

#include "resource.h"       // main symbols

//----- Mandatory includes>
#include "MTObjectOwnerBaseDef.h"

//----- CMTSession COM wrapper declaration.
class ATL_NO_VTABLE CMTObjectOwner : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTObjectOwner, &CLSID_MTObjectOwner>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTObjectOwner, &IID_IMTObjectOwner, &LIBID_SESSSERVERLib>
{
	public:
		CMTObjectOwner();

		//----- Set the object owner object into COM wrapper.
		void SetObjectOwner(CMTObjectOwnerBase* pObjectOwnerBase)
		{
			if (mpObjectOwnerBase)
				delete mpObjectOwnerBase;
				
			mpObjectOwnerBase = pObjectOwnerBase;
		};

		DECLARE_REGISTRY_RESOURCEID(IDR_MTOBJECTOWNER)
		DECLARE_GET_CONTROLLING_UNKNOWN()

		BEGIN_COM_MAP(CMTObjectOwner)
			COM_INTERFACE_ENTRY(IMTObjectOwner)
			COM_INTERFACE_ENTRY(IDispatch)
			COM_INTERFACE_ENTRY(ISupportErrorInfo)
		END_COM_MAP()

		HRESULT FinalConstruct();
		void FinalRelease();

	// ISupportsErrorInfo
		STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	// IMTObjectOwner
	public:
		STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);

		STDMETHOD(get_TotalCount)(/*[out, retval]*/ long *pVal);

		STDMETHOD(get_StageID)(/*[out, retval]*/ long *pVal);

		STDMETHOD(get_SessionSetID)(/*[out, retval]*/ long *pVal);

		STDMETHOD(get_NotifyStage)(/*[out, retval]*/ VARIANT_BOOL *pVal);
		STDMETHOD(get_CompleteProcessing)(/*[out, retval]*/ VARIANT_BOOL *pVal);
		STDMETHOD(get_SendFeedback)(/*[out, retval]*/ VARIANT_BOOL *pVal);

		STDMETHOD(get_WaitingCount)(/*[out, retval]*/ long *pVal);

		STDMETHOD(get_IsComplete)(/*[out, retval]*/ VARIANT_BOOL *pVal);
		
		STDMETHOD(DecrementWaitingCount)(/*[out, retval]*/ VARIANT_BOOL *pVal);

		STDMETHOD(InitForNotifyStage)(int aTotalCount, int aOwnerStage);
		STDMETHOD(InitForSendFeedback)(int aTotalCount, int aSessionSetID);
		STDMETHOD(InitForCompleteProcessing)(int aTotalCount, int aSessionSetID);

		STDMETHOD(FlagError)();
		STDMETHOD(get_ErrorFlag)(/*[out, retval]*/ VARIANT_BOOL *pVal);

		STDMETHOD(get_NextObjectOwnerID)(/*[out, retval]*/ long *pVal);
		STDMETHOD(put_NextObjectOwnerID)(long val);

		STDMETHOD(IncreaseSharedRefCount)(long * apNewCount);

		STDMETHOD(DecreaseSharedRefCount)(long * apNewCount);

		STDMETHOD(get_Transaction)(/*[out, retval]*/ IMTTransaction * * apTran);
		STDMETHOD(put_Transaction)(/*[in]*/ IMTTransaction * apTran);

		STDMETHOD(get_TransactionID)(/*[out, retval]*/ BSTR * pVal);
		STDMETHOD(put_TransactionID)(/*[in]*/ BSTR newVal);

		STDMETHOD(get_SerializedSessionContext)(/*[out, retval]*/ BSTR * pVal);
		STDMETHOD(put_SerializedSessionContext)(/*[in]*/ BSTR newVal);

		STDMETHOD(get_SessionContextUserName)(/*[out, retval]*/ BSTR * pVal);
		STDMETHOD(put_SessionContextUserName)(/*[in]*/ BSTR newVal);

		STDMETHOD(get_SessionContextPassword)(/*[out, retval]*/ BSTR * pVal);
		STDMETHOD(put_SessionContextPassword)(/*[in]*/ BSTR newVal);

		STDMETHOD(get_SessionContextNamespace)(/*[out, retval]*/ BSTR * pVal);
		STDMETHOD(put_SessionContextNamespace)(/*[in]*/ BSTR newVal);

		STDMETHOD(get_SessionContext)(/*[out, retval]*/ IMTSessionContext * * apTran);
		STDMETHOD(put_SessionContext)(/*[in]*/ IMTSessionContext * apTran);

		STDMETHOD(get_RSIDCache)(/*[out, retval]*/ IUnknown * * apCache);
		STDMETHOD(put_RSIDCache)(/*[in]*/ IUnknown * apCache);

		STDMETHOD(InitLock)();
		STDMETHOD(Lock)();
		STDMETHOD(Unlock)();

	private: // DATA
		CMTObjectOwnerBase* mpObjectOwnerBase;
};

#endif /* _MTOBJECTOWNER_H */

//-- EOF --
