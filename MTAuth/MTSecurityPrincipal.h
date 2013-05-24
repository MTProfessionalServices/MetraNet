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
	
// MTSecurityPrincipal.h : Declaration of the CMTSecurityPrincipal

#ifndef __MTSECURITYPRINCIPAL_H_
#define __MTSECURITYPRINCIPAL_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTSecurityPrincipal
class CMTSecurityPrincipal 
	
{
public:
	CMTSecurityPrincipal()
	{
		mActivePolicy = NULL;
		mDefaultPolicy = NULL;
		mID = -1;
	}
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_PrincipalType)(/*[out, retval]*/ MTSecurityPrincipalType *pVal);
	STDMETHOD(put_PrincipalType)(/*[in]*/ MTSecurityPrincipalType newVal);
	STDMETHOD(GetActivePolicy)(/*[in]*/IMTSessionContext* aCtx, IMTSecurityPrincipal* aConcretePrincipal, /*[out, retval]*/ IMTPrincipalPolicy** apPolicy);
	STDMETHOD(GetDefaultPolicy)(/*[in]*/IMTSessionContext* aCtx, IMTSecurityPrincipal* aConcretePrincipal, /*[out, retval]*/ IMTPrincipalPolicy** apPolicy);
	STDMETHOD(Save)(IMTSecurityPrincipal* aConcretePrincipal);
private:
	MTAUTHLib::IMTPrincipalPolicyPtr mActivePolicy;
	MTAUTHLib::IMTPrincipalPolicyPtr mDefaultPolicy;
	long mID;
	MTSecurityPrincipalType mPrincipalType;
};

#define DEFINE_SECURITY_PRINCIPAL_METHODS	\
	STDMETHOD(get_ID)(long *pVal) \
		{ return CMTSecurityPrincipal::get_ID(pVal); } \
	STDMETHOD(put_ID)(long newVal)	\
		{ return CMTSecurityPrincipal::put_ID(newVal); }	\
	STDMETHOD(get_PrincipalType)(/*[out, retval]*/ MTSecurityPrincipalType *pVal)	\
		{ return CMTSecurityPrincipal::get_PrincipalType(pVal); }	\
	STDMETHOD(put_PrincipalType)(/*[in]*/ MTSecurityPrincipalType newVal) \
		{ return CMTSecurityPrincipal::put_PrincipalType(newVal); }	\
	STDMETHOD(GetActivePolicy)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/ IMTPrincipalPolicy** apPolicy)	\
		{ return CMTSecurityPrincipal::GetActivePolicy(aCtx, this, apPolicy); }	\
	STDMETHOD(GetDefaultPolicy)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/ IMTPrincipalPolicy** apPolicy)	\
		{ return CMTSecurityPrincipal::GetDefaultPolicy(aCtx, this, apPolicy); } \
//	STDMETHOD(Save)()	
//		{ return CMTSecurityPrincipal::Save(this); } 

#endif //__MTSECURITYPRINCIPAL_H_
