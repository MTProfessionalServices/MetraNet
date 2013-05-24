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

#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTPCBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPCBase

CMTPCBase::CMTPCBase()
{
	mSessionContextPtr = NULL;
}

CMTPCBase::~CMTPCBase()
{
	mSessionContextPtr = NULL;
}


STDMETHODIMP CMTPCBase::SetSessionContext(IMTSessionContext* apSessionContext)
{
	try
	{
		mSessionContextPtr = apSessionContext;

		//give derived classes a chance to set session context of nested classes 
		OnSetSessionContext(apSessionContext);
	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTPCBase::GetSessionContext(IMTSessionContext **apSessionContext)
{
	//return an (addref'ed) copy
	MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr ctxtCopy = mSessionContextPtr;
	*apSessionContext = reinterpret_cast<IMTSessionContext *>(ctxtCopy.Detach());

	return S_OK;
}

// derived class can override this method to set session context of nested objects
// method should throw exception on error
void CMTPCBase::OnSetSessionContext(IMTSessionContext* apSessionContext)
{
}

//helper method used to pass session context from business obj to executant
MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr CMTPCBase::GetSessionContextPtr()
{
	return mSessionContextPtr;
}


MTAuthInterfacesLib::IMTSecurityContextPtr CMTPCBase::GetSecurityContext()
{
  return  MTAuthInterfacesLib::IMTSecurityContextPtr(reinterpret_cast<IMTSecurityContext*>(mSessionContextPtr->GetSecurityContext().GetInterfacePtr()));
}
