// MTARReader.h : Declaration of the CMTARReader

#ifndef __MTARREADER_H_
#define __MTARREADER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTARReader
class ATL_NO_VTABLE CMTARReader : 
  public CComObjectRootEx<CComSingleThreadModel>,
  public CComCoClass<CMTARReader, &CLSID_MTARReader>,
  public ISupportErrorInfo,
  public IObjectControl,
  public IDispatchImpl<IMTARReader, &IID_IMTARReader, &LIBID_MTARINTERFACEEXECLib>
{
public:
           CMTARReader();
  virtual ~CMTARReader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTARREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTARReader)

BEGIN_COM_MAP(CMTARReader)
  COM_INTERFACE_ENTRY(IMTARReader)
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


// IMTARReader
public:
  STDMETHOD(GetAccountStatusChanges)(/*[in]*/ VARIANT aConfigState, /*[out, retval]*/ BSTR* apResponseDoc);
  STDMETHOD(CanDeleteBatches)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState, /*[out, retval ]*/ BSTR* apResponseDoc);
  STDMETHOD(CanDeletePayments)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState, /*[out, retval ]*/ BSTR* apResponseDoc);
  STDMETHOD(CanDeleteAdjustments)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState, /*[out, retval ]*/ BSTR* apResponseDoc);
  STDMETHOD(CanDeleteInvoices)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState, /*[out, retval ]*/ BSTR* apResponseDoc);
  STDMETHOD(GetAgingConfiguration)(/*[in]*/ VARIANT aConfigState, /*[out, retval ]*/ BSTR* apResponseDoc);
  STDMETHOD(GetBalanceDetails)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState, /*[out, retval ]*/ BSTR* apResponseDoc);
  STDMETHOD(GetBalances)(/*[in]*/ BSTR aDoc, /*[in]*/ VARIANT aConfigState, /*[out, retval ]*/ BSTR* apResponseDoc);


private:
  HRESULT CallConfiguredReader( ARInterfaceMethod aMethod,
                                BSTR aDoc,
                                VARIANT aConfigState,
                                BSTR* apResponseDoc);

  CComPtr<IObjectContext>          m_pObjectContext;
  bool                             m_isAREnabled;
  MTARInterfaceLib::IMTARReaderPtr m_pReader;
};

#endif //__MTARREADER_H_
