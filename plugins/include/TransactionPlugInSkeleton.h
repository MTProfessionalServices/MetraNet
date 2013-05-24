/**************************************************************************
 * @doc TRANSACTIONPLUGINSKELETON
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
 * Created by: Ralf Boeck
 *
 * $Date: 3/12/2002 6:27:47 PM$
 * $Author: Derek Young$
 * $Revision: 1$
 *
 * @index | TRANSACTIONPLUGINSKELETON
 ***************************************************************************/

#ifndef _TRANSACTIONPLUGINSKELETON_H
#define _TRANSACTIONPLUGINSKELETON_H

#include <PlugInSkeleton.h>


// plugin skeleton that gives derived classes access to a transactional rowset
// derived classes must set mQueryInitPath and implement PlugInProcessSessionWithTransaction
template <class T, const CLSID* pclsid, class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTTransactionPlugIn: 
  public MTPipelinePlugIn<T, pclsid, ThreadModel>
{
protected:
  //data
  _bstr_t mQueryInitPath;

  //methods
  MTTransactionPlugIn() { }

  // processes the session set
  virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);

  // to be implemented in derived class
  virtual HRESULT PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                      MTPipelineLib::IMTSQLRowsetPtr aTransactionRowset) = 0;


private:
  HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
  {
    ASSERT(0);
    return E_NOTIMPL;
  }
};

template <class T, const CLSID* pclsid, class ThreadModel>
HRESULT MTTransactionPlugIn<T, pclsid, ThreadModel>
::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
  MTPipelineLib::IMTSQLRowsetPtr transactionRowset;
  HRESULT errHr = S_OK;


  //get transactional rowset from first session
  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
  HRESULT hr = it.Init(aSet);
  if (FAILED(hr))
    return hr;

  MTPipelineLib::IMTSessionPtr session = it.GetNext();
  try
  {
    transactionRowset = session->GetRowset(mQueryInitPath);


    SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
    HRESULT hr = it.Init(aSet);
    if (FAILED(hr))
      return hr;
    
    while (TRUE)
    {
      MTPipelineLib::IMTSessionPtr session = it.GetNext();
      if (session == NULL)
        break;


      hr = PlugInProcessSessionWithTransaction(session,transactionRowset);
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
	}
  catch (_com_error & err)
  {
    _bstr_t message = err.Description();
    errHr = err.Error();
    session->MarkAsFailed(message.length() > 0 ? message : L"", errHr);
  }
	
	if (FAILED(errHr))
		return PIPE_ERR_SUBSET_OF_BATCH_FAILED;
	
  return S_OK;
}


#endif /* _TRANSACTIONPLUGINSKELETON_H */


