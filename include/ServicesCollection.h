/**************************************************************************
 * @doc ServicesCollection
 * 
 * @module  Encapsulation for Database Product Property |
 * 
 * This class encapsulates the insertion or removal of Product Properties
 * from the database. All access to Product Properties should be done 
 * through this class.
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
 * Created by: Raju Matta
 * $Header$
 *
 * @index | ServicesCollection
 ***************************************************************************/

#ifndef _SERVICESCOLLECTION_H_
#define _SERVICESCOLLECTION_H_

#include <msixdefcollection.h>
#include <MSIXDefinitionObjectFactory.h>
#include <string>

class CServicesCollection : public MSIXDefCollection
{
public:
	CServicesCollection();

	BOOL FindService (const std::wstring &arName, CMSIXDefinition *& arpServicesDef);

	BOOL Initialize(const wchar_t* pDirName = NULL);
};

typedef CServicesCollection::MSIXDefinitionList ServicesDefList;

#endif // _SERVICESCOLLECTION_H_
