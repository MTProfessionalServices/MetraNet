/**************************************************************************
 * @doc ProductViewCollection
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
 * @index | ProductViewCollection
 ***************************************************************************/

#ifndef _PRODUCTVIEWCOLLECTION_H_
#define _PRODUCTVIEWCOLLECTION_H_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include <msixdefcollection.h>
#include <string>

#include <ProductViewDefCreator.h>

class CProductViewCollection
	: public MSIXDefCollection
{
public:
	CProductViewCollection();

	BOOL Initialize(const wchar_t* xmlfilename = NULL);

	BOOL FindProductView (const std::wstring &arName,
												CMSIXDefinition *& arpProductViewDef);

	// @cmember Create tables
	BOOL CreateTables();

	// @cmember Drop tables
	BOOL DropTables();

	// @cmember Update tables
	BOOL UpdateTables();

	// @cmember Insert into PV log
	BOOL InsertIntoPVLog();

	// @cmember Update PV log 
	BOOL UpdatePVLog(const char* arProductViewName, const char* arChecksum);

	// @cmember Drop tables
	BOOL DeleteFromPVLog();

	// TODO: this is only here because Usage server code calls it.  should try to
	// eliminate it.
	BOOL GenerateCreateTableQuery(CMSIXDefinition & arDef, std::wstring& langRequest);
	BOOL GenerateInsertIntoPVLogQuery(CMSIXDefinition & arDef, std::wstring& langRequest);

private:
	BOOL Validate(CMSIXDefinition * apDef);
	BOOL ValidatePVReservedProps(CMSIXDefinition * apDef);

private:
	ProductViewDefCreator mCreator;
};

typedef CProductViewCollection::MSIXDefinitionList ProductViewDefList;

#define PV_TABLE_PREFIX L"t_pv_"

#endif // _PRODUCTVIEWCOLLECTION_H_
