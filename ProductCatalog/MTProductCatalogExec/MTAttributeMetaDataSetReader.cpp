/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

// MTAttributeMetaDataSetReader.cpp : Implementation of CMTAttributeMetaDataSetReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTAttributeMetaDataSetReader.h"

#include <msixdefcollection.h>

#include "pcexecincludes.h"

using MTPRODUCTCATALOGLib::IMTAttributeMetaDataSetPtr;
using MTPRODUCTCATALOGLib::IMTAttributeMetaDataPtr;

using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTAttributeMetaDataSetReader

/******************************************* error interface ***/
STDMETHODIMP CMTAttributeMetaDataSetReader::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTAttributeMetaDataSetReader
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

HRESULT CMTAttributeMetaDataSetReader::Activate()
{
  HRESULT hr = GetObjectContext(&m_spObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTAttributeMetaDataSetReader::CanBePooled()
{
  return TRUE;
} 

void CMTAttributeMetaDataSetReader::Deactivate()
{
  m_spObjectContext.Release();
} 


STDMETHODIMP CMTAttributeMetaDataSetReader::Load(IMTAttributeMetaDataSet ** ppSet)
{
  
  MSIXDefCollection defColl;
  
  defColl.Initialize(L"attributes\\attributes.msixdef", FALSE);

  IMTAttributeMetaDataSetPtr attribMetaDataSet(__uuidof(MTAttributeMetaDataSet)); 

  MSIXDefCollection::MSIXDefinitionList& lst = defColl.GetDefList();
  list <CMSIXDefinition *>::iterator it;
  for ( it = lst.begin(); it != lst.end(); it++ )
  {
    CMSIXDefinition * msixDef = *it;
  
    MSIXPropertiesList msixProps = msixDef->GetMSIXPropertiesList();

    MSIXPropertiesList::iterator itr;
    for (itr = msixProps.begin(); itr != msixProps.end(); ++itr)
    {
      CMSIXProperties * msixProp = *itr;
  
      IMTAttributeMetaDataPtr attribMetaData;

      _bstr_t bstrName = _bstr_t(msixProp->GetDN().c_str());
      attribMetaData = attribMetaDataSet->CreateMetaData(bstrName);
      attribMetaData->DefaultValue = _variant_t(msixProp->GetDefault().c_str());  
    }

  }

  *ppSet = (IMTAttributeMetaDataSet*)attribMetaDataSet.Detach();

  return S_OK;
}
