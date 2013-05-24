/**************************************************************************
 *
 * Copyright 2002 by MetraTech Corporation
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

#ifndef __COMPLUSSKELETON_H__
#define __COMPLUSSKELETON_H__
#pragma once

#define MT_SUPPORT_IDispatch

#include "ComSkeleton.h"
#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#include "MTPipelineExecutant.h"
#include "MTPipelineExecutant_i.c"
#include "SetIterate.h"
#include <mtglobal_msg.h>
#include <comsvcs.h>
#include <mtautocontext.h>
#include <processpluginproperties.h>
#include <MTPipelineLib.h>
#include <MTPipelineLib_i.c>

HRESULT ReturnComError(const _com_error & arError);


template <class T, const CLSID* pclsid,
	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTComPlusExecutantSkeleton : 
  public MTImplementedInterface<T,
																IMTPipelineExecutant,
																pclsid,
																&IID_IMTPipelineExecutant,
																&LIBID_MTPipelineLib,
																ThreadModel>,
	public IObjectControl

{
public:
  MTComPlusExecutantSkeleton() {}

  STDMETHOD(Configure)(
    IDispatch * systemContext,
    IMTConfigPropSet * propSet,
    VARIANT * configState)
  {
		HRESULT hr = S_OK;
		try
		{
			// store a pointer to the logger object
			MTPipelineLib::IMTLogPtr logger(systemContext);
			MTPipelineLib::IMTConfigPropSetPtr propset(propSet);
			MTPipelineLib::IMTNameIDPtr idlookup(systemContext);
			MTPipelineLib::IMTSystemContextPtr syscontext(systemContext);

			hr = PlugInConfigure(logger, propset, idlookup, syscontext,configState);
		}
		catch (_com_error err)
		{
			return ReturnComError(err);
		}
		return hr;
  }

  STDMETHOD(ProcessSessions)(
    IMTSessionSet * sessions,
    IDispatch * systemContext,
    VARIANT configState)
  {
    MTPipelineLib::IMTSessionSetPtr aSet(sessions);
	  MTAutoContext context(m_spObjectContext);

		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(aSet);
		if (FAILED(hr))
		return hr;

		HRESULT errHr = S_OK;
		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr session = it.GetNext();
			if (session == NULL)
			  break;

			try
			{
				hr = PlugInProcessSession(session,configState);
				if (FAILED(hr))
				{
					HRESULT errHr = hr;
					IErrorInfo * errInfo;
					hr = GetErrorInfo(0, &errInfo);
					if (FAILED(hr))
						throw _com_error(errHr);

					throw _com_error(errHr, errInfo);
				}
			}
			catch (_com_error & err)
			{
				_bstr_t message = err.Description();
				errHr = err.Error();
				session->MarkAsFailed(message.length() > 0 ? message : L"", errHr);
			}
		}
		if (FAILED(errHr))
			return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

	  context.Complete();
		return S_OK;
  }

public: // COM+ stuff

  STDMETHOD(Activate)()
  {
	  HRESULT hr = GetObjectContext(&m_spObjectContext);
	  if (SUCCEEDED(hr))
		  return S_OK;
	  return hr;
  } 

STDMETHOD_(BOOL, CanBePooled)()
  {
	  return TRUE;
  } 

	STDMETHOD_(void, Deactivate)()
  {
	  m_spObjectContext.Release();
  } 

protected:
  // note that the skeleton will call complete on the object context 
  // if this method returns S_OK

  STDMETHOD(PlugInConfigure)(MTPipelineLib::IMTLogPtr aLogger,
						MTPipelineLib::IMTConfigPropSetPtr aPropSet,
						MTPipelineLib::IMTNameIDPtr aNameID,
						MTPipelineLib::IMTSystemContextPtr aSysContext,
            VARIANT* configState) = 0;

	STDMETHOD(PlugInProcessSession)(MTPipelineLib::IMTSessionPtr aSession,VARIANT ConfigState) = 0;

protected:
  	CComPtr<IObjectContext> m_spObjectContext;
};

#endif //__COMPLUSSKELETON_H__
