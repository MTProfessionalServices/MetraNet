/**************************************************************************
 * @doc PLUGINSKELETON
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | PLUGINSKELETON
 ***************************************************************************/

#ifndef _PLUGINSKELETON_H
#define _PLUGINSKELETON_H


//enables numerically precise DECIMAL properties
//rather than less accurate doubles
#define DECIMAL_PLUGINS


// import the type library of the plug in interfaces
// so we can use generated smart pointers
// #include <metra.h>
#include <metra.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping


#include "SetIterate.h"
#include "MTPipelinePlugIn.h"
#include "MTPipelinePlugIn_i.c"
#include "ComSkeleton.h"
#include "MTDec.h"
#include <mtglobal_msg.h>
#include <processpluginproperties.h>

HRESULT ReturnComError(const _com_error & arError);


/////////////////////////////////////////////////////////////////////////////
//MTPipelinePlugIn
/////////////////////////////////////////////////////////////////////////////


template <class T, const CLSID* pclsid,
					class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTPipelinePlugIn : 
  public MTImplementedInterface<T,
                                ::IMTPipelinePlugIn,
																pclsid,
																&IID_IMTPipelinePlugIn,
																ThreadModel>
{
public:
	MTPipelinePlugIn()
	{
	}


// IMTPipelinePlugIn
private:

	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	STDMETHOD(Configure)(
		/* [in] */ IUnknown * systemContext,
    /* [in] */ ::IMTConfigPropSet * propSet)
	{
		// do any initialization necessary here.
		// this method can be called any number of times during the
		// lifetime of the plugin.

		// the plug in's configuration is in the IMTConfigPropSet object

		// the system context object can be used to retrieve interface
		// pointers to the name ID lookup object and logging object.
		HRESULT hr = S_OK;
		try
		{
			// store a pointer to the logger object
			MTPipelineLib::IMTLogPtr logger(systemContext);
			MTPipelineLib::IMTConfigPropSetPtr propset(propSet);
			MTPipelineLib::IMTNameIDPtr idlookup(systemContext);
			MTPipelineLib::IMTSystemContextPtr syscontext(systemContext);

			hr = PlugInConfigure(logger, propset, idlookup, syscontext);
		}
		catch (_com_error err)
		{
			return ReturnComError(err);
		}
		return hr;
	}


	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	STDMETHOD(Shutdown)()
	{
		HRESULT hr = S_OK;
		try
		{
			hr = PlugInShutdown();
		}
		catch (_com_error err)
		{
			return ReturnComError(err);
		}
		return hr;
	}

	// Return information about this processor.
	// combination of 
	//    MTPROC_FREETHREADED
	//    MTPROC_PASSIVE
	//    MTPROC_STAGECHANGER
	STDMETHOD(get_ProcessorInfo)(/* [out] */ long * info)
	{
		HRESULT hr = S_OK;
		try
		{
			hr = PlugInInfo(info);
		}
		catch (_com_error err)
		{
			return ReturnComError(err);
		}
		return hr;

	}

  STDMETHOD(ProcessSessions)(/* [in] */ ::IMTSessionSet * sessions)
	{
		HRESULT hr = S_OK;
		try
		{
			MTPipelineLib::IMTSessionSetPtr set(sessions);

			hr = PlugInProcessSessions(set);
		}
		catch (_com_error err)
		{
			return ReturnComError(err);
		}
		return hr;
	}


protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext) = 0;

	virtual HRESULT PlugInShutdown()
	{ return S_OK; }

	virtual HRESULT PlugInInfo(long * apInfo)
	{ return E_NOTIMPL; }


	virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
	{
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
				hr = PlugInProcessSession(session);
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
		return S_OK;
	}

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession) = 0;


};



#endif /* _PLUGINSKELETON_H */
