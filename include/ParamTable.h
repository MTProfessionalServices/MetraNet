/**************************************************************************
 * @doc PARAMTABLE
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | PARAMTABLE
 ***************************************************************************/

#ifndef _PARAMTABLE_H
#define _PARAMTABLE_H

#include <DynamicTable.h>
#include <msixdefcollection.h>

class ParamTableCreator : public DynamicTableCreator
{
public:
	BOOL Init();

	BOOL SetupDatabase(CMSIXDefinition & arDef);
	BOOL CleanupDatabase(CMSIXDefinition & arDef, const wchar_t * apTableName = NULL);
};

class ParamTableCollection : public MSIXDefCollection
{
public:
	BOOL Init(const wchar_t * apFilename = NULL);
	BOOL CreateTables();
	BOOL DropTables();

private:
	BOOL Setup(CMSIXDefinition & arDef);

private:
	ParamTableCreator mCreator;
};

#endif /* _PARAMTABLE_H */
