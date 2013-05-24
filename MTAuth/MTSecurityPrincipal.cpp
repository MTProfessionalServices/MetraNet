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
* Created by: Boris Partensky
* 
***************************************************************************/


// MTSecurityPrincipal.cpp : Implementation of CMTSecurityPrincipal
#include "StdAfx.h"
#include "MTAuth.h"
#include "MTSecurityPrincipal.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSecurityPrincipal

STDMETHODIMP CMTSecurityPrincipal::get_ID(long *aVal)
{
	(*aVal) = mID;
	return S_OK;
}


STDMETHODIMP CMTSecurityPrincipal::put_ID(long newVal)
{
	//Properties.Item("ID").Value = 
	mID = newVal;

	return S_OK;
}

STDMETHODIMP CMTSecurityPrincipal::get_PrincipalType(MTSecurityPrincipalType* apVal)
{
	(*apVal) = mPrincipalType;

	return S_OK;
}


STDMETHODIMP CMTSecurityPrincipal::put_PrincipalType(MTSecurityPrincipalType newVal)
{
	mPrincipalType = newVal;
	return S_OK;
}


STDMETHODIMP CMTSecurityPrincipal::Save(IMTSecurityPrincipal* aPrincipal)
{
	try
	{
		if(mActivePolicy)
			mActivePolicy->Save();
		if(mDefaultPolicy)
			mDefaultPolicy->Save();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}
	return S_OK;
}

STDMETHODIMP CMTSecurityPrincipal::GetActivePolicy(/*[in]*/IMTSessionContext* aCtx, IMTSecurityPrincipal* aConcretePrincipal,  /*[out, retval]*/ IMTPrincipalPolicy** apPolicy)
{
	//TODO: check security here?
	try
	{
		if (mActivePolicy == NULL)
		{
			MTAUTHLib::IMTPrincipalPolicyPtr pp(__uuidof(MTAUTHLib::MTPrincipalPolicy));
			mActivePolicy =  reinterpret_cast<IMTPrincipalPolicy*>
			(pp->GetActive((MTAUTHLib::IMTSessionContext*) aCtx, (MTAUTHLib::IMTSecurityPrincipal*) aConcretePrincipal).GetInterfacePtr());
		}
		MTAUTHLib::IMTPrincipalPolicyPtr outPtr = mActivePolicy;
		(*apPolicy) = (IMTPrincipalPolicy*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTSecurityPrincipal::GetDefaultPolicy(/*[in]*/IMTSessionContext* aCtx, IMTSecurityPrincipal* aConcretePrincipal, /*[out, retval]*/ IMTPrincipalPolicy** apPolicy)
{
	//TODO: check security here?
	try
	{
		if (mDefaultPolicy == NULL)
		{
			MTAUTHLib::IMTPrincipalPolicyPtr pp(__uuidof(MTAUTHLib::MTPrincipalPolicy));
			mDefaultPolicy =  reinterpret_cast<IMTPrincipalPolicy*>
			(pp->GetDefault((MTAUTHLib::IMTSessionContext*) aCtx, (MTAUTHLib::IMTSecurityPrincipal*) aConcretePrincipal).GetInterfacePtr());
		}
		MTAUTHLib::IMTPrincipalPolicyPtr outPtr = mDefaultPolicy;
		(*apPolicy) = (IMTPrincipalPolicy*)outPtr.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnAuthError(e);
	}

	return S_OK;
}


