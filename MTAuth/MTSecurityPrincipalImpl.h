/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __MTSECURITYPRINCIPALIMPL_H__
#define __MTSECURITYPRINCIPALIMPL_H__
#pragma once

#include "Auth.h"
#include "MTSecurityPrincipalImplbase.h"

template<class T,const IID* piid, const GUID* plibid>
class MTSecurityPrincipalImpl : public MTSecurityPrincipalImplBase<T,piid,plibid>
{
public:
  MTSecurityPrincipalImpl() 
    : MTSecurityPrincipalImplBase<T,piid,plibid>()
  {
  
  }
  virtual ~MTSecurityPrincipalImpl() {}
  STDMETHODIMP LogAndReturnPrincipalError(_com_error& err)
  {
    return LogAndReturnAuthError(err);
  }
  STDMETHODIMP LogPrincipalError(char* aMsg)
  {
    return LogAuthError(aMsg);
  }



};



#endif //__MTSECURITYPRINCIPALIMPL_H__