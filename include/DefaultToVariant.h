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

#include <errobj.h>
#include <comutil.h>
#include <MSIXProperties.h>

#ifndef __DEFAULTTOVARIANT_H__
#define __DEFAULTTOVARIANT_H__

class DefaultConversion : public ObjectWithError {
public:
	DefaultConversion() {}
	virtual ~DefaultConversion() {}

	BOOL ConvertDefaultStrToVariant(const CMSIXProperties& arMSIXProp,
																	_variant_t& arDefaultVal);


};

#endif //__DEFAULTTOVARIANT_H__
