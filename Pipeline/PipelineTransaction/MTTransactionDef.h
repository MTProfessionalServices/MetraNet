/**************************************************************************
 * @doc MTTRANSACTIONDEF
 *
 * Copyright 2000 by MetraTech Corporation
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
 * Created by: Alan Blount
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __MTTRANSACTIONDEF_H_
#define __MTTRANSACTIONDEF_H_

#include "resource.h"       // main symbols

#include <comdef.h>

#include <txdtc.h>  // distributed transaction support
#include <xolehlp.h>  // distributed transaction support

_COM_SMARTPTR_TYPEDEF(ITransactionDispenser, IID_ITransactionDispenser);
_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

/////////////////////////////////////////////////////////////////////////////
// CMTTransaction
class ATL_NO_VTABLE CMTTransaction : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTTransaction, &CLSID_CMTTransaction>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTTransaction, &IID_IMTTransaction, &LIBID_PIPELINETRANSACTIONLib>
{
public:
	CMTTransaction();
	~CMTTransaction();

DECLARE_REGISTRY_RESOURCEID(IDR_MTTRANSACTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTTransaction)
	COM_INTERFACE_ENTRY(IMTTransaction)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

#if 0
	HRESULT FinalConstruct();
	void FinalRelease();
#endif

	STDMETHOD(CreateObjectWithTransactionByCLSID)(/*[in]*/ REFIID riid,/*[out,retval]*/ IDispatch** ppDisp);
	STDMETHOD(CreateObjectWithTransaction)(/*[in]*/ BSTR progid,/*[out,retval]*/ IDispatch** pDisp);
  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

  // IMTTransaction

	// begin a distributed transaction.  This object will be the owner of the
	// new transaction.
	STDMETHOD(Begin)(BSTR aDescription, int aTimeout);

	// commit the transaction
	STDMETHOD(Commit)();

	// rollback the transaction
	STDMETHOD(Rollback)();

	// copy in an existing transaction object.  If the second argument is
	// true, then this IMTTransaction object will "own" the transaction.
	STDMETHOD(SetTransaction)(IUnknown * apTransaction, /*[in, optional]*/ VARIANT aOwner);

	// return the underlying ITransaction object (usually used to pass into
	// ADO/OLEDB/ODBC.
	STDMETHOD(GetTransaction)(/*[out, retval]*/ IUnknown * * apTransaction);

	// given a DTC's whereabouts, encode this transaction into a cookie
	STDMETHOD(Export)(BSTR aWhereAbouts, /*[out, retval]*/ BSTR * aEncodedCookie);

	// given a transaction cookie/ID, reconstruct a real transaction object
	STDMETHOD(Import)(BSTR aEncodedCookie);
	
	// returns true if this IMTTransaction object "owns" the transaction.
	STDMETHOD(IsOwner)(/*[out, retval]*/ VARIANT_BOOL* aIsOwner);

	// returns the default transaction timeout set for COM+
	STDMETHOD(get_DefaultTimeout)(/*[out, retval]*/ long *pVal);

private:
	static ITransactionDispenserPtr CMTTransaction::GetFactory(HRESULT & hr);

	HRESULT Export(
		/*[in]*/ ULONG cbWhereabouts,
		/*[in]*/ BYTE * rgbWhereabouts,
		/*[out]*/ ULONG * cbCookie,
		/*[out]*/ BYTE ** rgbCookie);

	HRESULT Import(/*[in]*/  ULONG   cbTransactionCookie,
								 /*[in]*/  BYTE *  rgbTransactionCookie);

private:
	ITransactionPtr mITransaction;
	BOOL mOwner;
};

#endif //__MTTRANSACTIONDEF_H_
