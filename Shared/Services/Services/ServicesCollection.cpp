/**************************************************************************
 * @doc ServicesCollection
 * 
 * @module  Encapsulation for Database Product Property |
 * 
 * This class encapsulates the insertion or removal of Product Properties
 * from the database. All access to ServicesCollection should be done through this 
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
 * Created by: Raju Matta
 * $Header$
 *
 * @index | ServicesCollection
 ***************************************************************************/

#include <metra.h>

#import <MTConfigLib.tlb>
#include <ServicesCollection.h>

CServicesCollection::CServicesCollection()
{
	SetPath(SERVICE_CONFIG_PATH);
	SetIndexFile(SERVICE_XML_FILE);
}

BOOL 
CServicesCollection::FindService (const wstring &arName, CMSIXDefinition * & arpService)
{
	return FindDefinition(arName, arpService);
}

BOOL CServicesCollection::Initialize(const wchar_t* pDirName /* NULL */)
{
	const char * functionName = "CServicesCollection::Initialize";
	const wchar_t* pArg = L"service";

	if (!MSIXDefCollection::Initialize(pArg))
		return FALSE;

	return TRUE;
}

