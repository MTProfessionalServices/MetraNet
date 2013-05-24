// Ticket.cpp : Implementation of CTicket
/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Rudi Perkins
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"
#include "comticketagent.h"
#include "Ticket.h"

/////////////////////////////////////////////////////////////////////////////
// CTicket

STDMETHODIMP CTicket::get_Namespace(BSTR *pVal)
{
  *pVal = mNamespace.copy();
	return S_OK;
}

STDMETHODIMP CTicket::put_Namespace(BSTR newVal)
{
	mNamespace=newVal;

	return S_OK;
}

STDMETHODIMP CTicket::get_AccountIdentifier(BSTR *pVal)
{
  *pVal = mAccountIdentifier.copy();
	return S_OK;
}

STDMETHODIMP CTicket::put_AccountIdentifier(BSTR newVal)
{
  mAccountIdentifier=newVal;
	return S_OK;
}

STDMETHODIMP CTicket::get_LoggedInAs(BSTR *pVal)
{
  *pVal = mLoggedInAs.copy();
	return S_OK;
}

STDMETHODIMP CTicket::put_LoggedInAs(BSTR newVal)
{
  mLoggedInAs=newVal;
	return S_OK;
}

STDMETHODIMP CTicket::get_ApplicationName(BSTR *pVal)
{
  *pVal = mApplicationName.copy();
	return S_OK;
}

STDMETHODIMP CTicket::put_ApplicationName(BSTR newVal)
{
  mApplicationName=newVal;
	return S_OK;
}