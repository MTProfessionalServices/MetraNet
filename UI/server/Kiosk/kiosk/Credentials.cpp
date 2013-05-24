/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * Created by: Raju Matta
 * $Header: c:\development35\UI\server\Kiosk\kiosk\Credentials.cpp, 21, 7/26/2002 5:54:53 PM, Raju Matta$
 * 
 * 	Credentials.cpp : 
 *	------------------
 *	This is the implementation of the Credentials class.
 *
 ***************************************************************************/


// All the includes
// ADO includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>

// Local includes
#include <Credentials.h>
#include <loggerconfig.h>

// All the constants

// @mfunc CCredentials default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CCredentials::CCredentials()
{
	SetLoginName(W_NULL_STR);
	SetPwd(W_NULL_STR);
	SetName_Space(W_NULL_STR);
	SetTicket(W_NULL_STR);
}


// @mfunc CCredentials copy constructor
// @parm CCredentials& 
// @rdesc This implementations is for the copy constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CCredentials::CCredentials(const CCredentials &c) 
{
	*this = c;
}

// @mfunc CCredentials assignment operator
// @parm 
// @rdesc This implementations is for the assignment operator of the 
// Core Kiosk Gate class
DLL_EXPORT const CCredentials& 
CCredentials::operator=(const CCredentials& rhs)
{
	// set the member attributes here
	mLoginName = rhs.mLoginName;
	mPwd = rhs.mPwd;
	mName_Space = rhs.mName_Space;
	mTicket = rhs.mTicket;

 	return ( *this );
}


// @mfunc CCredentials destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CCredentials::~CCredentials()
{
}

// @mfunc Initialize
// @parm 
// @rdesc 
DLL_EXPORT BOOL
CCredentials::Initialize()
{
	// assign null strings
	SetLoginName(W_NULL_STR);
	SetPwd(W_NULL_STR);
	SetName_Space(W_NULL_STR);
	SetTicket(W_NULL_STR);

	return (TRUE); 
}

//	Mutators
void CCredentials::SetLoginName (const wchar_t* LoginName) 
{ 
  mLoginName = LoginName; 
}
void CCredentials::SetPwd (const wchar_t* pwd) 
{ 
  mPwd = pwd; 
}
void CCredentials::SetName_Space (const wchar_t* name_space) 
{ 
  mName_Space = name_space; 
}
void CCredentials::SetTicket (const wchar_t* ticket) 
{ 
  mTicket = ticket; 
}

