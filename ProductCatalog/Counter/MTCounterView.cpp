/**************************************************************************
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
 * Created by: Boris Partensky
 * $Header$
 *
 ***************************************************************************/

#include "StdAfx.h"
#include "MTCounterView.h"

HRESULT CMTCounterView::Create(BSTR aFromProductView, BSTR* apViewName)
{
	try
	{
		return E_NOTIMPL;
	}	
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

HRESULT CMTCounterView::CreateAllViews()
{
	try
	{
		return E_NOTIMPL;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}


HRESULT CMTCounterView::CreateUsageView(BSTR* apViewName)
{
	try
	{
		return E_NOTIMPL;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}
HRESULT CMTCounterView::Remove(BSTR aPVName)
{
  return E_NOTIMPL;
}
/*
HRESULT CMTCounterView::Remove(BSTR aPVName)
{
	try
	{
		// TODO: this is NOT the right way to construct the session context.
		// We should really retrieve the credentials and login as the user invoking the script
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
			context(MTPROGID_MTSESSIONCONTEXT);
		context->PutAccountID(0);

		HRESULT hr(S_OK);
		CComPtr<IMTDDLWriter> writer;
	
		hr = writer.CoCreateInstance(__uuidof(MTDDLWriter));	if(FAILED(hr))
			return hr;

		return writer->RemoveView((IMTSessionContext *) context.GetInterfacePtr(), aPVName);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}
*/
/*
HRESULT CMTCounterView::ViewExists(BSTR aViewName, VARIANT_BOOL* aFlag)
{
	HRESULT hr(S_OK);
	CComPtr<IMTCounterViewReader> reader;
	
	hr = reader.CoCreateInstance(__uuidof(MTCounterViewReader));
	if(FAILED(hr))
		return hr;

	return reader->ViewExists(aViewName, aFlag);
}
*/
// create the view name from the product view name ...
// table name is a string manipulation of the name
// for example: if name is metratech.com/audioconfcall, the
// table name gets translated to t_pv_metratech_com_audioconfcall

//TODO:: consolidate code with CMTDDLWriter::GetViewName()

_bstr_t CMTCounterView::GetViewName (const _bstr_t &arProductView)
{
  wstring viewName = (const wchar_t*) bstrPVName;

  //remove "t_" from the beginning if it's there
  if( viewName.find(L"t_") == 0)
  { 
    viewName.erase(0,2);
  }
  
  //strip all chars before and including first slash
  string::size_type pos = viewName.find (L"/") ;
  if (pos == string::npos)
  {
    pos = viewName.find (L"\\") ;
  }
  viewName.erase (0, pos+1) ;

  //limit to 19 chars
  string::size_type len = viewName.length() ;
  if (len > 19)
  {
    viewName.erase (19) ;
  }
  
  //prepend "t_vw_"
  viewName.insert(0, L"t_vw_");

  //replace "/" and "\" with "_" 
  while((viewName.find(L"/", 0) != string::npos) ||
    (viewName.find(L"\\", 0) != string::npos))
  {
    string::size_type charpos = viewName.find_first_of(L"/", 0);
    if (charpos != string::npos)
      viewName.replace(charpos, 1, L"_");
    charpos = viewName.find_first_of(L"\\", 0);
    if (charpos != string::npos)
      viewName.replace(charpos, 1, L"_");
  }
	
	return _bstr_t (viewName.c_str());
}
