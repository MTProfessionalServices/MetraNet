// MTARReader.cpp : Implementation of CMTARReader
#include "StdAfx.h"

#include "MTARInterfaceExec.h"
#include "MTARReader.h"

#import "MetraTech.AR.tlb"

/////////////////////////////////////////////////////////////////////////////
// CMTARReader

/******************************************* error interface ***/
STDMETHODIMP CMTARReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTARReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTARReader::CMTARReader()
{
  // The following information should not change.  In order for changes to
  // any .xml config file to take effect, the pipeline must be stopped and
  // restarted.
  //
  // If the following information can change during runtime then this code
  // and the associated code in the destructor should be moved into the
  // CallConfiguredReader() method.

  MetraTech_AR::IARConfigurationProxyPtr ARConfig;
  HRESULT hr = ARConfig.CreateInstance((const wchar_t*)(L"MetraTech.AR.ARConfigurationProxy"));
  if (FAILED(hr))
    MT_THROW_COM_ERROR("Instance creation in CMTARReader for MetraTech.AR.ARConfigurationProxy failed.");

  m_isAREnabled = (ARConfig->GetIsAREnabled() == VARIANT_TRUE);

  _bstr_t arReaderProgID = ARConfig->GetARReaderObject();

  hr = m_pReader.CreateInstance(((const wchar_t*)arReaderProgID));
  if (FAILED(hr))
  {
    char errorMsg[256] = "Instance creation in CMTARReader for ";

    strcat(errorMsg, (char*)(arReaderProgID));
    strcat(errorMsg, " failed.");

    MT_THROW_COM_ERROR(errorMsg);
  }
}

CMTARReader::~CMTARReader()
{
  m_isAREnabled = false;
  m_pReader.Release();
}

HRESULT CMTARReader::Activate()
{
	return(GetObjectContext(&m_pObjectContext));
} 

BOOL CMTARReader::CanBePooled()
{
	return FALSE;
} 

void CMTARReader::Deactivate()
{
	m_pObjectContext.Release();
} 

HRESULT CMTARReader::CallConfiguredReader( ARInterfaceMethod aMethod,
                                           BSTR              aDoc,
                                           VARIANT           aConfigState,
                                           BSTR*             apResponseDoc)
{
  MTAutoContext context(m_pObjectContext);

  if (apResponseDoc == NULL)
    return E_POINTER;

  *apResponseDoc = NULL;

  ARLogMethod(aMethod, aDoc, m_isAREnabled);

  try
  {
    _bstr_t responseDoc;

    if (m_isAREnabled)
    {
      _bstr_t doc = aDoc;

      switch (aMethod)
      {
        case ARMETHOD_GetBalances:
          responseDoc = m_pReader->GetBalances( doc, aConfigState );
          break;

        case ARMETHOD_GetBalanceDetails:
          responseDoc = m_pReader->GetBalanceDetails( doc, aConfigState );
          break;

        case ARMETHOD_GetAgingConfiguration:
          responseDoc = m_pReader->GetAgingConfiguration( aConfigState );
          break;

        case ARMETHOD_CanDeleteInvoices:
          responseDoc = m_pReader->CanDeleteInvoices( doc, aConfigState );
          break;

        case ARMETHOD_CanDeleteAdjustments:
          responseDoc = m_pReader->CanDeleteAdjustments( doc, aConfigState );
          break;

        case ARMETHOD_CanDeletePayments:
          responseDoc = m_pReader->CanDeletePayments( doc, aConfigState );
          break;

        case ARMETHOD_CanDeleteBatches:
          responseDoc = m_pReader->CanDeleteBatches( doc, aConfigState );
          break;

        case ARMETHOD_GetAccountStatusChanges:
          responseDoc = m_pReader->GetAccountStatusChanges( aConfigState );
          break;

        default:
          MT_THROW_COM_ERROR("invalid ARReader method");
      }
    }
    else
    {
      //interface not enabled, just return xml doc with empty <ARDocuments> node
      responseDoc = "<ARDocuments></ARDocuments>";
    }

    //set the out var
    *apResponseDoc = responseDoc.Detach();

    //log success
    ARLogMethodSuccess(aMethod, *apResponseDoc);

  }
  catch (_com_error & err)
  {
    //log failure
    ARLogMethodFailure(aMethod, err);

    //translate error and return it
    return ReturnTranslatedARError(err);
  }

  context.Complete();
  return S_OK;
}



STDMETHODIMP CMTARReader::GetBalances(BSTR aDoc, VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_GetBalances,
                               aDoc,
                               aConfigState,
                               apResponseDoc);
}

STDMETHODIMP CMTARReader::GetBalanceDetails(BSTR aDoc, VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_GetBalanceDetails,
                               aDoc,
                               aConfigState,
                               apResponseDoc);
}

STDMETHODIMP CMTARReader::GetAgingConfiguration(VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_GetAgingConfiguration,
                               NULL,
                               aConfigState,
                               apResponseDoc);
}

STDMETHODIMP CMTARReader::CanDeleteInvoices(BSTR aDoc, VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_CanDeleteInvoices,
                               aDoc,
                               aConfigState,
                               apResponseDoc);
}

STDMETHODIMP CMTARReader::CanDeleteAdjustments(BSTR aDoc, VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_CanDeleteAdjustments,
                               aDoc,
                               aConfigState,
                               apResponseDoc);
}

STDMETHODIMP CMTARReader::CanDeletePayments(BSTR aDoc, VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_CanDeletePayments,
                               aDoc,
                               aConfigState,
                               apResponseDoc);
}

STDMETHODIMP CMTARReader::CanDeleteBatches(BSTR aDoc, VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_CanDeleteBatches,
                               aDoc,
                               aConfigState,
                               apResponseDoc);
}

STDMETHODIMP CMTARReader::GetAccountStatusChanges(VARIANT aConfigState, BSTR *apResponseDoc)
{
  return CallConfiguredReader( ARMETHOD_GetAccountStatusChanges,
                               NULL,
                               aConfigState,
                               apResponseDoc);
}
