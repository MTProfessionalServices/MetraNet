// MTARConfig.cpp : Implementation of CMTARConfig
#include "StdAfx.h"

#include "MTARInterfaceExec.h"
#include "MTARConfig.h"

#import "MetraTech.AR.tlb"

/////////////////////////////////////////////////////////////////////////////
// CMTARConfig

/******************************************* error interface ***/
STDMETHODIMP CMTARConfig::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTARConfig
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTARConfig::CMTARConfig()
{
  // The following information should not change.  In order for changes to
  // any .xml config file to take effect, the pipeline must be stopped and
  // restarted.
  //
  // If the following information can change during runtime then this code
  // and the associated code in the destructor should be moved into the
  // Configure() method.

  MetraTech_AR::IARConfigurationProxyPtr ARConfig;
  HRESULT hr = ARConfig.CreateInstance((const wchar_t*)(L"MetraTech.AR.ARConfigurationProxy"));
  if (FAILED(hr))
    MT_THROW_COM_ERROR("Instance creation in CMTARConfig for MetraTech.AR.ARConfigurationProxy failed.");

  m_isAREnabled = (ARConfig->GetIsAREnabled() == VARIANT_TRUE);
  m_arConfigProgID = ARConfig->GetARConfigObject();
}

CMTARConfig::~CMTARConfig()
{
  m_isAREnabled = false;
  m_arConfigProgID.Assign(NULL);
}

HRESULT CMTARConfig::Activate()
{
	return(GetObjectContext(&m_pObjectContext));
} 

BOOL CMTARConfig::CanBePooled()
{
	return FALSE;
} 

void CMTARConfig::Deactivate()
{
	m_pObjectContext.Release();
} 

STDMETHODIMP CMTARConfig::Configure(VARIANT  aInternalSystemInfo,
                                    VARIANT* apConfigState)
{
  MTAutoContext context(m_pObjectContext);

  if (apConfigState == NULL)
    return E_POINTER;
  
  try
  {
    variant_t configState;

    if (m_isAREnabled)
    {
      MTARInterfaceLib::IMTARConfigPtr config;
      HRESULT hr = config.CreateInstance((const wchar_t*)m_arConfigProgID);
	    if (FAILED(hr))
		    return hr;

      configState = config->Configure("");
    }
    else
    {
      configState.vt = VT_DISPATCH;
      configState.pdispVal = NULL;
    }

    *apConfigState = configState.Detach();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}
