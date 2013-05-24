// MTPaymentWriter.h : Declaration of the CMTPaymentWriter

#ifndef __MTPAYMENTWRITER_H_
#define __MTPAYMENTWRITER_H_

#include <StdAfx.h>
#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPaymentWriter
class ATL_NO_VTABLE CMTPaymentWriter : 
  public CComObjectRootEx<CComSingleThreadModel>,
  public CComCoClass<CMTPaymentWriter, &CLSID_MTPaymentWriter>,
  public ISupportErrorInfo,
  public IObjectControl,
  public IDispatchImpl<IMTPaymentWriter, &IID_IMTPaymentWriter, &LIBID_MTYAACEXECLib>
{
public:
  CMTPaymentWriter()
  {
  }

DECLARE_REGISTRY_RESOURCEID(IDR_MTPAYMENTWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPaymentWriter)

BEGIN_COM_MAP(CMTPaymentWriter)
  COM_INTERFACE_ENTRY(IMTPaymentWriter)
  COM_INTERFACE_ENTRY(IObjectControl)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
  COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
  STDMETHOD(Activate)();
  STDMETHOD_(BOOL, CanBePooled)();
  STDMETHOD_(void, Deactivate)();

  CComPtr<IObjectContext> m_spObjectContext;

// IMTPaymentWriter
public:
  STDMETHOD(UpdatePaymentRecord)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPayer,/*[in]*/ long aPayee,/*[in]*/ DATE oldStart,/*[in]*/ DATE oldEnd,/*[in]*/ DATE aStartDate,/*[in]*/ DATE aEndDate);
  STDMETHOD(PayForAccount)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPayer,/*[in]*/ long aPayee,/*[in]*/ DATE aStartDate,/*[in]*/ DATE aEndDate);
  STDMETHOD(PayForAccountBatch)(/*[in]*/ IMTSessionContext* apCtxt, 
      IMTCollection* pCol,
      IMTProgress* pProgress,
      long aPayer,
      DATE StartDate,
      VARIANT aEndDate,
      IMTRowSet** ppRowset);

};

#endif //__MTPAYMENTWRITER_H_
