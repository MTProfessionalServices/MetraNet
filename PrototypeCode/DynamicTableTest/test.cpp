/**************************************************************************
 * TEST
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <DynamicTable.h>

#include <mtcomerr.h>


ComInitialize gComInit;

class DynamicTableTest
{
public:
	BOOL Init();
	BOOL Test();

private:
	DynamicTableCreator mCreator;
};

BOOL DynamicTableTest::Init()
{
	return mCreator.Init();
}

BOOL DynamicTableTest::Test()
{
	CMSIXDefinition * def = mCreator.ReadDefFile("c:\\scratch\\dyntable.msixdef");
	if (!def)
	{
		cout << "Unable to parse file" << endl;
		return FALSE;
	}

	def->SetTableName(L"t_foo");

	CMSIXProperties * prop = new CMSIXProperties;
	prop->SetDN(L"id_sess");
	prop->SetIsRequired(TRUE);
	prop->SetPartOfKey(VARIANT_TRUE);
	prop->SetPropertyType(CMSIXProperties::TYPE_INT32);
	prop->SetDataType(L"int");
	prop->SetColumnName(L"id_sess");
	prop->SetReferenceTable(L"t_acc_usage_1");
	prop->SetRefColumn(L"id_sess");
	def->GetMSIXPropertiesList().insert(def->GetMSIXPropertiesList().begin(), prop);


	//
	// create table
	//
	std::wstring buffer;
	if (!mCreator.GenerateCreateTableQuery(buffer, *def))
	{
		cout << "Unable to generate create table query" << endl;
		return FALSE;
	}

	std::string asciiQuery(ascii(buffer));

	cout << asciiQuery.c_str() << endl;


	if (!mCreator.CreateTable(*def))
	{
		cout << "Unable to create table" << endl;
		return FALSE;
	}

	//
	// drop table
	//
	if (!mCreator.GenerateDropTableQuery(buffer, *def))
	{
		cout << "Unable to generate drop table query" << endl;
		return FALSE;
	}

	asciiQuery = ascii(buffer);

	cout << asciiQuery.c_str() << endl;


	if (!mCreator.DropTable(*def))
	{
		cout << "Unable to drop table" << endl;
		return FALSE;
	}

	return TRUE;

}

int main(int argc, char * argv[])
{
	try
	{
		DynamicTableTest test;
		if (!test.Init())
		{
			cout << "Init failed" << endl;
			return -1;
		}

		if (!test.Test())
		{
			cout << "Test failed" << endl;
			return -1;
		}
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "exception thrown", err);
		cout << buffer.c_str();
		return -1;
	}


	return 0;
}
