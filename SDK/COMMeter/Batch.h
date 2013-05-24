/**************************************************************************
* Copyright 1998, 1999 by MetraTech Corporation
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
***************************************************************************/

// SessionSet.h : Declaration of the CSessionSet

#ifndef __BATCH_H_
#define __BATCH_H_

#include "resource.h"       // main symbols
#include <comdef.h>         // bstr_r, variant_t datatypes

// Forward Declarations
class MTMeterBatch;
class CMeter;

/////////////////////////////////////////////////////////////////////////////
// CBatch
class ATL_NO_VTABLE CBatch : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CBatch, &CLSID_Batch>,
	public ISupportErrorInfo,
	public IDispatchImpl<IBatch, &IID_IBatch, &LIBID_COMMeterLib>
{
	friend CMeter;
	friend CBatch;
public:
	CBatch();
	~CBatch();

DECLARE_REGISTRY_RESOURCEID(IDR_BATCH)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CBatch)
	COM_INTERFACE_ENTRY(IBatch)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_FUNC(IID_NULL, 0, _This)
END_COM_MAP()

// ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IBatch
public:
  STDMETHOD(get_UID)(/*[out, retval]*/ BSTR *pVal);

  STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);  
  STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);

  STDMETHOD(get_NameSpace)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_NameSpace)(/*[in]*/ BSTR newVal);
  
	STDMETHOD(get_Status)(/*[out, retval]*/ BSTR *pVal);
  
	STDMETHOD(get_CompletionDate)(/*[out, retval]*/ DATE *pVal);
  
	STDMETHOD(get_Source)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_Source)(/*[in]*/ BSTR newVal);
  
	STDMETHOD(get_CreationDate)(/*[out, retval]*/ DATE *pVal);

	STDMETHOD(get_SourceCreationDate)(/*[out, retval]*/ DATE *pVal);
  STDMETHOD(put_SourceCreationDate)(/*[in]*/ DATE newVal);
  
	STDMETHOD(get_CompletedCount)(/*[out, retval]*/ long *pVal);
  
	STDMETHOD(get_SequenceNumber)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_SequenceNumber)(/*[in]*/ BSTR newVal);
  
	STDMETHOD(get_ExpectedCount)(/*[out, retval]*/ long *pVal);
  STDMETHOD(put_ExpectedCount)(/*[in]*/ long newVal);
  
	STDMETHOD(get_FailureCount)(/*[out, retval]*/ long *pVal);
  
	STDMETHOD(get_Comment)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_Comment)(/*[in]*/ BSTR newVal);
  
	STDMETHOD(get_MeteredCount)(/*[out, retval]*/ long *pVal);
  STDMETHOD(put_MeteredCount)(/*[in]*/ long newVal);
	
	STDMETHOD(CreateSessionSet)(/*[out, retval]*/ ISessionSet ** pNewSessionSet);
	STDMETHOD(CreateSession)(/*[in]*/ BSTR ServiceName, /*[out, retval]*/ ISession ** pNewSession);

	STDMETHOD(Refresh)();
  
	STDMETHOD(Save)();
	STDMETHOD(MarkAsActive)(BSTR Comment);
	STDMETHOD(MarkAsBackout)(BSTR Comment);
	STDMETHOD(MarkAsFailed)(BSTR Comment);
	STDMETHOD(MarkAsDismissed)(BSTR Comment);
	STDMETHOD(MarkAsCompleted)(BSTR Comment);
	STDMETHOD(UpdateMeteredCount)();
	STDMETHOD(ProcessExceptions)();
  
	// Used by meter to populate batch on CreateBatch
	void SetSDKBatch(MTMeterBatch * batch);	
	
private:
	MTMeterBatch * m_Batch;						// Pointer To SDK Object

};

#endif //__BATCH_H_
