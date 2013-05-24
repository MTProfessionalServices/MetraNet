// MTARWriter.cpp : Implementation of CMTARWriter
#include "StdAfx.h"

#include "MTARInterfaceExec.h"
#include "MTARWriter.h"

#import "MetraTech.AR.tlb"

/////////////////////////////////////////////////////////////////////////////
// CMTARWriter

/******************************************* error interface ***/
STDMETHODIMP CMTARWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTARWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTARWriter::CMTARWriter()
{
  // The following information should not change.  In order for changes to
  // any .xml config file to take effect, the pipeline must be stopped and
  // restarted.
  //
  // If the following information can change during runtime then this code
  // and the associated code in the destructor should be moved into the
  // CallConfiguredInterface() method.

  MetraTech_AR::IARConfigurationProxyPtr ARConfig;
  HRESULT hr = ARConfig.CreateInstance((const wchar_t*)(L"MetraTech.AR.ARConfigurationProxy"));
  if (FAILED(hr))
    MT_THROW_COM_ERROR("Instance creation in CMTARWriter for MetraTech.AR.ARConfigurationProxy failed.");

  m_isAREnabled = (ARConfig->GetIsAREnabled() == VARIANT_TRUE);

  _bstr_t arWriterProgID = ARConfig->GetARWriterObject();

  hr = m_pWriter.CreateInstance(((const wchar_t*)arWriterProgID));
  if (FAILED(hr))
  {
    char errorMsg[256] = "Instance creation in CMTARWriter for ";

    strcat(errorMsg, (char*)(arWriterProgID));
    strcat(errorMsg, " failed.");

    MT_THROW_COM_ERROR(errorMsg);
  }
}

CMTARWriter::~CMTARWriter()
{
  m_isAREnabled = false;
  m_pWriter.Release();
}

HRESULT CMTARWriter::Activate()
{
	return(GetObjectContext(&m_pObjectContext));
} 

BOOL CMTARWriter::CanBePooled()
{
	return FALSE;
} 

void CMTARWriter::Deactivate()
{
	m_pObjectContext.Release();
} 


HRESULT CMTARWriter::CallConfiguredInterface( ARInterfaceMethod aMethod,
                                              BSTR aDoc,
                                              VARIANT aConfigState,
                                              BSTR* apResponseDoc /* = NULL */)
{
  MTAutoContext context(m_pObjectContext);

  if (apResponseDoc != NULL)
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
        case ARMETHOD_CreateOrUpdateAccounts:
          m_pWriter->CreateOrUpdateAccounts( doc, aConfigState );
          break;

        case ARMETHOD_UpdateAccountStatus:
          m_pWriter->UpdateAccountStatus( doc, aConfigState );
          break;

        case ARMETHOD_CreateOrUpdateTerritories:
          m_pWriter->CreateOrUpdateTerritories( doc, aConfigState );
          break;

        case ARMETHOD_UpdateTerritoryManagers:
          m_pWriter->UpdateTerritoryManagers( doc, aConfigState );
          break;

        case ARMETHOD_CreateOrUpdateSalesPersons:
          m_pWriter->CreateOrUpdateSalesPersons( doc, aConfigState );
          break;

        case ARMETHOD_MoveBalances:
          responseDoc = m_pWriter->MoveBalances( doc, aConfigState);
          break;

        case ARMETHOD_CreateInvoices:
          m_pWriter->CreateInvoices( doc, aConfigState );
          break;

        case ARMETHOD_CreateInvoicesWithTaxDetails:
          m_pWriter->CreateInvoicesWithTaxDetails( doc, aConfigState );
          break;
          
        case ARMETHOD_CreateAdjustments:
          m_pWriter->CreateAdjustments( doc, aConfigState );
          break;

        case ARMETHOD_CreatePayments:
          m_pWriter->CreatePayments( doc, aConfigState );
          break;

        case ARMETHOD_DeleteInvoices:
          m_pWriter->DeleteInvoices( doc, aConfigState );
          break;

        case ARMETHOD_DeleteAdjustments:
          m_pWriter->DeleteAdjustments( doc, aConfigState );
          break;

        case ARMETHOD_DeletePayments:
          m_pWriter->DeletePayments( doc, aConfigState );
          break;

        case ARMETHOD_DeleteBatches:
          m_pWriter->DeleteBatches( doc, aConfigState );
          break;

        case ARMETHOD_ApplyCredits:
          m_pWriter->ApplyCredits( aConfigState );
          break;

        case ARMETHOD_RunAging:
          m_pWriter->RunAging( doc, aConfigState );
          break;

        case ARMETHOD_DeleteAccountStatusChanges:
          m_pWriter->DeleteAccountStatusChanges( doc, aConfigState );
          break;

        default:
          MT_THROW_COM_ERROR("invalid ARWriter method");
      }
    }
    else
    {
      //interface not enabled, just return xml doc with empty <ARDocuments> node
      responseDoc = "<ARDocuments></ARDocuments>";
    }

    //set the out var if provided
    if (apResponseDoc)
      *apResponseDoc = responseDoc.Detach();

    //log success
    ARLogMethodSuccess(aMethod, apResponseDoc == NULL ? NULL : *apResponseDoc);
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



STDMETHODIMP CMTARWriter::CreateOrUpdateAccounts(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_CreateOrUpdateAccounts,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::UpdateAccountStatus(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_UpdateAccountStatus,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::CreateOrUpdateTerritories(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_CreateOrUpdateTerritories,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::UpdateTerritoryManagers(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_UpdateTerritoryManagers,
                                  aDoc,
                                  aConfigState );
}


STDMETHODIMP CMTARWriter::CreateOrUpdateSalesPersons(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_CreateOrUpdateSalesPersons,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::MoveBalances(BSTR aDoc, VARIANT aConfigState, BSTR* apResponseDoc)
{
  return CallConfiguredInterface( ARMETHOD_MoveBalances,
                                  aDoc,
                                  aConfigState,
                                  apResponseDoc);
}

STDMETHODIMP CMTARWriter::CreateInvoices(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_CreateInvoices,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::CreateInvoicesWithTaxDetails(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_CreateInvoicesWithTaxDetails,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::CreateAdjustments(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_CreateAdjustments,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::CreatePayments(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_CreatePayments,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::DeleteInvoices(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_DeleteInvoices,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::DeleteAdjustments(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_DeleteAdjustments,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::DeletePayments(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_DeletePayments,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::DeleteBatches(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_DeleteBatches,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::ApplyCredits(VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_ApplyCredits,
                                  NULL,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::RunAging(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_RunAging,
                                  aDoc,
                                  aConfigState );
}

STDMETHODIMP CMTARWriter::DeleteAccountStatusChanges(BSTR aDoc, VARIANT aConfigState)
{
  return CallConfiguredInterface( ARMETHOD_DeleteAccountStatusChanges,
                                  aDoc,
                                  aConfigState );
}
