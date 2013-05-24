/**************************************************************************
 * @doc SECUREDHOOKSKELETON
 *
 * @module |
 *
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | SECUREDHOOKSKELETON
 ***************************************************************************/

#ifndef _SECUREDHOOKSKELETON_H
#define _SECUREDHOOKSKELETON_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#define MT_SUPPORT_IDispatch
#include <ComSkeleton.h>

#include "MTHook.h"
#include "MTHook_i.c"
#include "MTSecuredHook.h"
#include "MTSecuredHook_i.c"
#include "MTHooklib.h"
#include "MTHooklib_i.c"
#include <mtprogids.h>
#include <mtcomerr.h>
#include <NTLogger.h>
#include <loggerconfig.h>

#import <MTHooklib.tlb> rename ("EOF", "RowsetEOF")
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF")

// secured hook (takes a session context as an argument)
template <class T, const CLSID* pclsid,
	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTSecuredHookSkeleton : 
  public MTImplementedInterface<T,IMTSecuredHook,pclsid,&IID_IMTSecuredHook, &LIBID_MTHookLib, ThreadModel>

{
public:
	MTSecuredHookSkeleton()
	{
	  LoggerConfigReader configReader;
    _bstr_t aProgId(_PlugInProgId);
    _bstr_t aTempStr = "[" + aProgId + "]";
    mLogger.Init(configReader.ReadConfiguration(aProgId),aTempStr);
	}

protected:
	STDMETHOD(Execute)(/*[in]*/IMTSessionContext * context, /*[in]*/ VARIANT var,/*[in, out]*/ long* pVal)
    {
      try {
      return ExecuteHook(context, var,pVal);
      }
      catch(_com_error e) {
        return ReturnComError(e);
      }
    }
public:
   virtual HRESULT ExecuteHook(MTAuthInterfacesLib::IMTSessionContextPtr context, VARIANT var, long* pVal) = 0;
protected: // data
  NTLogger mLogger;
};

#define HOOK_INFO PLUGIN_INFO


#endif /* _SECUREDHOOKSKELETON_H */
