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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | PLUGINSKELETON
 ***************************************************************************/

#ifndef _HOOKSKELETON_H
#define _HOOKSKELETON_H
#include <ComSkeleton.h>

#include "MTHook.h"
#include "MTHook_i.c"
#include <mtprogids.h>
#include <mtcomerr.h>
#include <NTLogger.h>
#include <loggerconfig.h>


template <class T, const CLSID* pclsid,
	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTHookSkeleton : 
  public MTImplementedInterface<T,IMTHook,pclsid,&IID_IMTHook,ThreadModel>
{
public:
	MTHookSkeleton()
	{
	  LoggerConfigReader configReader;
    _bstr_t aProgId(_PlugInProgId);
    _bstr_t aTempStr = "[" + aProgId + "]";
    mLogger.Init(configReader.ReadConfiguration(aProgId),aTempStr);
	}

protected:
    STDMETHOD(Execute)(/*[in]*/ VARIANT var,/*[in, out]*/ long* pVal)
    {
      try {
      return ExecuteHook(var,pVal);
      }
      catch(_com_error e) {
        return ReturnComError(e);
      }
    }
public:
   virtual HRESULT ExecuteHook(VARIANT var, long* pVal) = 0;
protected: // data
  NTLogger mLogger;
};

#define HOOK_INFO PLUGIN_INFO

#endif // _HOOKSKELETON_H
