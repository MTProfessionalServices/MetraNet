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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTSESSION_H_
#define __MTSESSION_H_

#include "MTSessionBaseDef.h"

HRESULT WINAPI _ThisSession(void*,REFIID,void**,DWORD);

/////////////////////////////////////////////////////////////////////////////
// CMTSession
class ATL_NO_VTABLE CMTSession : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSession, &CLSID_MTSession>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSession, &IID_IMTSession, &LIBID_SESSSERVERLib>
{
	public:
		CMTSession();

		HRESULT FinalConstruct();
		void FinalRelease();

		//----- Set session information in this class
		void SetSession(CMTSessionBase* pSessionBase)
		{
			if (mpSessionBase)
				delete mpSessionBase;
				
			mpSessionBase = pSessionBase;
		}

		DECLARE_REGISTRY_RESOURCEID(IDR_MTSESSION)
		DECLARE_GET_CONTROLLING_UNKNOWN()

		BEGIN_COM_MAP(CMTSession)
			COM_INTERFACE_ENTRY(IMTSession)
			COM_INTERFACE_ENTRY(IDispatch)
			COM_INTERFACE_ENTRY(ISupportErrorInfo)
      COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_ThisSession)
		END_COM_MAP()

	// ISupportsErrorInfo
		STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	// IMTSession
	public:
		STDMETHOD(get_SessionID)(/*[out, retval]*/ long *pVal);
		STDMETHOD(get_UIDAsString)(/*[out, retval]*/ BSTR *pVal);
    STDMETHOD(get_ParentUIDAsString)(/*[out, retval]*/ BSTR *pVal);

		STDMETHOD(get_ServiceID)(/*[out, retval]*/ long *pVal);
		STDMETHOD(get_ParentID)(/*[out, retval]*/ long *pVal);

		STDMETHOD(get_DatabaseID)(/*[out, retval]*/ long *pVal);
		STDMETHOD(put_DatabaseID)(long aVal);
		STDMETHOD(get_OutstandingChildren)(/*[out, retval]*/ long *pVal);

		STDMETHOD(get_UID)(/*[out]*/ unsigned char uid[]);

		STDMETHOD(get_IsParent)(/*[out, retval]*/ VARIANT_BOOL * isparent);

		STDMETHOD(get_CompoundMarkedAsFailed)(/*[out, retval]*/ VARIANT_BOOL * failed);

		STDMETHOD(get_StartStage)(/*[out, retval]*/ long *pVal);
		STDMETHOD(put_StartStage)(long val);

		STDMETHOD(get_ObjectOwnerID)(/*[out, retval]*/ int * id);
		STDMETHOD(put_ObjectOwnerID)(/*[in]*/ long id);

	public:
		STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);

		STDMETHOD(GetLongProperty)(long propid, /*[out]*/ long * propval);
		STDMETHOD(SetLongProperty)(long propid, long propval);

		STDMETHOD(GetDoubleProperty)(long aPropId, /*[out, retval]*/ double * apValue);
		STDMETHOD(SetDoubleProperty)(long aPropId, double aValue);

		STDMETHOD(GetBoolProperty)(long propid, /*[out, retval]*/ VARIANT_BOOL * apValue);
		STDMETHOD(SetBoolProperty)(long aPropId, VARIANT_BOOL aVal);

		STDMETHOD(GetBSTRProperty)(long aPropId, /*[out, retval]*/ BSTR * apValue);
		STDMETHOD(SetBSTRProperty)(long aPropId, BSTR aValue);

		STDMETHOD(GetStringProperty)(long aPropId, /*[out, retval]*/ BSTR * apValue);
		STDMETHOD(SetStringProperty)(long aPropId, BSTR aValue);

		STDMETHOD(GetOLEDateProperty)(long aPropId, /*[out, retval]*/ DATE * apValue);
		STDMETHOD(SetOLEDateProperty)(long aPropId, DATE aValue);

		STDMETHOD(GetDateTimeProperty)(long aPropId, /*[out, retval]*/ long * apValue);
		STDMETHOD(SetDateTimeProperty)(long aPropId, long aValue);

		STDMETHOD(GetTimeProperty)(long aPropId, /*[out, retval]*/ long * apValue);
		STDMETHOD(SetTimeProperty)(long aPropId, long aValue);

		STDMETHOD(GetEnumProperty)(long propid, /*[out]*/ long * propval);
		STDMETHOD(SetEnumProperty)(long propid, long propval);

		STDMETHOD(GetDecimalProperty)(long aPropId, /*[out, retval]*/ VARIANT * apValue);
		STDMETHOD(SetDecimalProperty)(long aPropId, VARIANT aValue);

		STDMETHOD(SetObjectProperty)(long propid, VARIANT propval);
		STDMETHOD(GetObjectProperty)(long propid, /*[out, retval]*/ VARIANT * propval);

		STDMETHOD(GetLongLongProperty)(long propid, /*[out]*/ __int64 * propval);
		STDMETHOD(SetLongLongProperty)(long propid, __int64 propval);

		STDMETHOD(PropertyExists)(long aPropId, MTSessionPropType type,
								  VARIANT_BOOL * apExists);

			// DTC Support
		STDMETHOD(GetTransaction)(VARIANT_BOOL aCreate, IMTTransaction **xaction);
		STDMETHOD(GetRowset)(BSTR ConfigFile, IMTSQLRowset **pSQLRowset);
		STDMETHOD(FinalizeTransaction)();
		STDMETHOD(GetTransactionID)(BSTR* apTransactionID);
		
		STDMETHOD(DecryptEncryptedProp)(long aPropID, BSTR* aStringProp);
    STDMETHOD(EncryptStringProp)(long aPropID, BSTR aStringProp);

		STDMETHOD(CommitPendingTransaction)();

		STDMETHOD(MarkAsFailed)(BSTR aErrorMessage, long aErrorCode);
    STDMETHOD(MarkAsFailed)(BSTR aErrorMessage);

		STDMETHOD(get_SessionContext)(/*[out, retval]*/ IMTSessionContext** apCtx);

		STDMETHOD(get_HoldsSessionContext)(/*[out, retval]*/ VARIANT_BOOL * apVal);

    STDMETHOD(GetLongLongPropertyAsString)(long aPropId, /*[out, retval]*/ BSTR * apValue);

	public:
		STDMETHOD(Rollback)();

		STDMETHOD(SessionChildren)(IMTSessionSet * * apSet);
		STDMETHOD(AddSessionChildren)(IMTSessionSet * apSet);

		STDMETHOD(AddSessionDescendants)(IMTSessionSet * apSet);

		// NOTE: use this method with caution
		STDMETHOD(MarkComplete)(/*[out, retval]*/ VARIANT_BOOL * apParentReady);

		// NOTE: use this method with caution
		STDMETHOD(IncreaseSharedRefCount)(long * apNewCount);

		// NOTE: use this method with caution
		STDMETHOD(DecreaseSharedRefCount)(long * apNewCount);

		// NOTE: use this method with caution
		STDMETHODIMP DeleteForcefully();

		STDMETHOD(MarkCompoundAsFailed)();

		STDMETHOD(put_InTransitTo)(long id);
		STDMETHOD(put_InProcessBy)(long id);

		STDMETHOD(AddEvents)(/*[in]*/ int events);

		STDMETHOD(get_Events)(/*[out, retval]*/ int * events);
    
    void GetSessionBase(CMTSessionBase** apSessionBase)
		{
			(*apSessionBase) = mpSessionBase;
		}

	private: // Data
		CMTSessionBase* mpSessionBase;
};

#endif //__MTSESSION_H_

//-- EOF --
