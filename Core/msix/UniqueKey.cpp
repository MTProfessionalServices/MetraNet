/**************************************************************************
 * @doc MSIXProperties
 *
 * @module	Encapsulation for Database UniqueKey Property |
 *
 * This class encapsulates the insertion or removal of UniqueKey Properties
 * from the database. All access to UniqueKey should be done through this
 * class.
 *
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * $Header$
 *
 * @index | UniqueKey
 ***************************************************************************/


// includes
#include <comdef.h>
#include <UniqueKey.h>
#include <loggerconfig.h>


//	@mfunc
//	Constructor. Initialize the data members.
//	@rdesc
//	No return value
UniqueKey::UniqueKey()
{	
}

//	@mfunc
//	Destructor
//	@rdesc
//	No return value
UniqueKey::~UniqueKey()
{
}

void UniqueKey::SetName(const wchar_t * name)
{
  mName = name;
}

void UniqueKey::AddColumnProperty(CMSIXProperties *property) 
{
  columnProperties.push_back(property);
}
