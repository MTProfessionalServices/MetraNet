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
// MTPCBase.h : Declaration of the CMTPCBase

#ifndef __MTPCBASE_H_
#define __MTPCBASE_H_

#include "IMTAuth.h"
#import <MTProductCatalogExec.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#include <PCCache.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPCBase

class CMTPCBase
{
public:
	CMTPCBase();
	~CMTPCBase();

// IMTPCBase
public:
	STDMETHOD(SetSessionContext)(/*[in]*/ IMTSessionContext* apSessionContext);
	STDMETHOD(GetSessionContext)(/*[out, retval]*/ IMTSessionContext** apSessionContext);


protected:
// methods only visible to derived C++ classes (not exposed to COM clients)
	MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr GetSessionContextPtr();
  MTAuthInterfacesLib::IMTSecurityContextPtr GetSecurityContext();

//overridable methods
	virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);

protected:
	MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr mSessionContextPtr;
};


// macro that needs to be included in all derived classes
#define DEFINE_MT_PCBASE_METHODS																							\
	STDMETHOD(SetSessionContext)(/*[in]*/ IMTSessionContext* apSessionContext)	\
		{ return CMTPCBase::SetSessionContext(apSessionContext); }								\
	STDMETHOD(GetSessionContext)(/*[out, retval]*/ IMTSessionContext** apSessionContext) \
		{ return CMTPCBase::GetSessionContext(apSessionContext); }								\


#endif //__MTPCBASE_H_
