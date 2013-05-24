// MTARWriter.h : Declaration of the CMTARWriter

#ifndef __MTARWRITER_H_
#define __MTARWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>



/////////////////////////////////////////////////////////////////////////////
// CMTARWriter
class ATL_NO_VTABLE CMTARWriter : 
  public CComObjectRootEx<CComSingleThreadModel>,
  public CComCoClass<CMTARWriter, &CLSID_MTARWriter>,
  public ISupportErrorInfo,
  public IObjectControl,
  public IDispatchImpl<IMTARWriter, &IID_IMTARWriter, &LIBID_MTARINTERFACEEXECLib>
{
public:
           CMTARWriter();
  virtual ~CMTARWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTARWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTARWriter)

BEGIN_COM_MAP(CMTARWriter)
  COM_INTERFACE_ENTRY(IMTARWriter)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
  COM_INTERFACE_ENTRY(IObjectControl)
  COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IObjectControl
public:
  STDMETHOD(Activate)();
  STDMETHOD_(BOOL, CanBePooled)();
  STDMETHOD_(void, Deactivate)();

// IMTARWriter
public:
  STDMETHOD(DeleteAccountStatusChanges)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(UpdateTerritoryManagers)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(RunAging)(/*[in]*/ BSTR doc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(ApplyCredits)(/*[in]*/ VARIANT aConfigState);
  STDMETHOD(DeleteBatches)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(DeletePayments)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(DeleteAdjustments)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(DeleteInvoices)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(CreatePayments)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(CreateAdjustments)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(CreateInvoices)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(MoveBalances)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState, /*[out, retval]*/ BSTR* apResponseDoc);
  STDMETHOD(CreateOrUpdateSalesPersons)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(CreateOrUpdateTerritories)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(UpdateAccountStatus)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);
  STDMETHOD(CreateOrUpdateAccounts)(/*[in]*/ BSTR doc, /*[in]*/ VARIANT configState);
  STDMETHOD(CreateInvoicesWithTaxDetails)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState);


private:
  HRESULT CallConfiguredInterface( ARInterfaceMethod aMethod,
                                   BSTR aDoc,
                                   VARIANT aConfigState,
                                   BSTR* apResponseDoc = NULL);

  CComPtr<IObjectContext>          m_pObjectContext;
  bool                             m_isAREnabled;
  MTARInterfaceLib::IMTARWriterPtr m_pWriter;
};

#endif //__MTARWRITER_H_
