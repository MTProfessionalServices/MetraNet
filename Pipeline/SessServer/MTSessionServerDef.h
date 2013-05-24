/**************************************************************************
 * @doc MTSESSIONSERVER
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
 *			   Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTSESSIONSERVER_H_
#define __MTSESSIONSERVER_H_

#include "MTSessionDef.h"
#include "MTSessionSetDef.h"
#include "MTSessionSetBaseDef.h"
#include "MTSessionServerBaseDef.h"

/****************************************** CMTSessionServer ***/
class ATL_NO_VTABLE CMTSessionServer : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSessionServer, &CLSID_MTSessionServer>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSessionServer, &IID_IMTSessionServer, &LIBID_SESSSERVERLib>
{
	public:
		CMTSessionServer();

		DECLARE_REGISTRY_RESOURCEID(IDR_MTSESSIONSERVER)
		DECLARE_GET_CONTROLLING_UNKNOWN()

		BEGIN_COM_MAP(CMTSessionServer)
			COM_INTERFACE_ENTRY(IMTSessionServer)
			COM_INTERFACE_ENTRY(IDispatch)
			COM_INTERFACE_ENTRY(ISupportErrorInfo)
		END_COM_MAP()

		HRESULT FinalConstruct();
		void FinalRelease();

	// ISupportsErrorInfo
		STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	// IMTSessionServer
	public:
		STDMETHOD(CreateSessionSet)(/*[out, retval]*/ IMTSessionSet * * apSet);
		STDMETHOD(CreateSession)(/*[in]*/ unsigned char uid[], long serviceId,
								 /*[out]*/ IMTSession * * session);

		STDMETHOD(CreateChildSession)(/*[in]*/ unsigned char uid[], long serviceId,
									  /*[in]*/ unsigned char parentUid[16],
									  /*[out]*/ IMTSession * * session);

		STDMETHOD(CreateTestSession)(long serviceId, /*[out]*/ IMTSession * * session);

		STDMETHOD(CreateChildTestSession)(long serviceId, long parentId,
										  /*[out,retval]*/ IMTSession * * session);

		STDMETHOD(GetSession)(long sessionId, IMTSession * * session);
		STDMETHOD(GetSessionSet)(long setId, /*[out,retval]*/ IMTSessionSet * * set);

		STDMETHOD(Init)(BSTR filename, BSTR sharename, long totalSize);

		STDMETHOD(SessionsInProcessBy)(int aStageID, /*[out,retval]*/ IMTSessionSet * * set);

		STDMETHOD(DeleteSessionsInProcessBy)(int aStageID);

		STDMETHOD(FailedSessions)(/*[out,retval]*/ IMTSessionSet * * set);

		STDMETHOD(GetSessionWithUID)(unsigned char uid[], IMTSession * * session);

		// depracated - use PercentFull instead
		STDMETHOD(get_CurrentCapacity)(/*[out, retval]*/ double * pVal);

		STDMETHOD(get_PercentUsed)(/*[out, retval]*/ double * pVal);

		STDMETHOD(GetObjectOwner)(long ownerId, /*[out,retval]*/ IMTObjectOwner * * objectOwner);

		STDMETHOD(CreateObjectOwner)(/*[out,retval]*/ IMTObjectOwner * * objectOwner);

		STDMETHOD(DeleteObjectOwner)(long ownerId);

		// For internal use only.
		STDMETHOD(GetInternalServerHandle)(/*[out, retval]*/ long *pVal);

	private: // DATA

		CMTSessionServerBase* mpSessionServerBase;
};

#endif //__MTSESSIONSERVER_H_

//-- EOF --