/**************************************************************************
 * @doc TEST
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
 ***************************************************************************/

#ifndef __ADSIUSER_H__
#define __ADSIUSER_H__
#pragma once


#pragma warning(disable: 4192)
#pragma warning(disable: 4196)
#import <activeds.tlb> exclude("_LARGE_INTEGER") exclude("_GUID") rename ("_LARGE_INTEGER","_ACTIVEDS_LARGE_INTEGER") rename("GetObject", "_ACTIVEDS_GetObject") \
inject_statement("#pragma warning(disable: 4196)") inject_statement("struct _ACTIVEDS_LARGE_INTEGER {struct { DWORD LowPart; LONG  HighPart; };LONGLONG QuadPart; }  ;")

#include <iads.h>

 /*#import <adsiis.tlb>  
#include <iiscnfg.h>
#include <header.h>
#include <iads.h>
#include <adshlp.h>

*/
#include <string>


class MTDomain {

public:
	MTDomain();
	virtual bool Init();
	bool IsDomain();
	void GetDomainName(std::string& aStr);
	std::wstring& GetDomainNameW() { return mDomainURL; }

protected: // data

	ActiveDs::IADsDomainPtr mDomain;
	IID mDomain_IID;
	std::wstring mDomainURL;
};

class MTUserPrivileges : public MTDomain {

public:
	virtual bool Init(std::string& aUser);
protected:



};


#endif //__ADSIUSER_H__
