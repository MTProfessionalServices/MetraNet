/**************************************************************************
 * @doc MTWHEREABOUTSMANAGERDEF
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MTWHEREABOUTSMANAGERDEF
 ***************************************************************************/

#ifndef _MTWHEREABOUTSMANAGERDEF_H
#define _MTWHEREABOUTSMANAGERDEF_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include "resource.h"       // main symbols

#include <txdtc.h>  // distributed transaction support
#include <xolehlp.h>  // distributed transaction support

#include <comdef.h>
#include "transactionconfig.h"

//_COM_SMARTPTR_TYPEDEF(ITransactionDispenser, IID_ITransactionDispenser);
//_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

/////////////////////////////////////////////////////////////////////////////
// CMTTransaction
class ATL_NO_VTABLE CMTWhereaboutsManager : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTWhereaboutsManager, &CLSID_CMTWhereaboutsManager>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTWhereaboutsManager, &IID_IMTWhereaboutsManager, &LIBID_PIPELINETRANSACTIONLib>
{
public:
	CMTWhereaboutsManager();
	~CMTWhereaboutsManager();

DECLARE_REGISTRY_RESOURCEID(IDR_MTWHEREABOUTSMANAGER)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTWhereaboutsManager)
	COM_INTERFACE_ENTRY(IMTWhereaboutsManager)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

#if 0
	HRESULT FinalConstruct();
	void FinalRelease();
#endif

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

  // IMTWhereaboutsManager
	// given a machine, tell me the whereabouts
	STDMETHOD(GetWhereaboutsForServer)(BSTR aServer,
																		 /*[out, retval]*/ BSTR * aWhereabouts);

	// return the local whereabouts
	STDMETHOD(GetLocalWhereabouts)(/*[out, retval]*/ BSTR * aWhereabouts);

private:
	HRESULT GetLocalWhereabouts(
		/*[out]*/ ULONG * cbWhereAbouts,
		/*[out]*/ BYTE ** rgbWhereAbouts);

private:
	// cache the local whereabouts - it doesn't change
	_bstr_t mLocalWhereabouts;

	//cache the transactionConfig object
	CTransactionConfig* mTransactionConfig;
};


#endif /* _MTWHEREABOUTSMANAGERDEF_H */
