/**************************************************************************
 * @doc TEST
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 ***************************************************************************/

#include <iostream>

#include <mtcom.h>

#include "test.h"
#include <string>

using std::string;
using std::cout;
using std::endl;
using std::hex;
using std::dec;

_COM_SMARTPTR_TYPEDEF(IUnknown, __uuidof(IUnknown));

static ComInitialize gComInitialize;


void PrintSpaces(int count)
{
	for (int i = 0; i < count; i++)
	{
		cout << ' ';
	}
}

int indent = 0;
void PrintPropSet(IMTConfigPropSetPtr propset)
{
	//PrintSpaces(indent);
	//cout << "root" << endl;
	PrintSpaces(indent);
	cout << "[" << endl;
	indent += 2;

	IMTConfigPropPtr prop;

	while (TRUE)
	{
		prop = propset->Next();
		if (prop == NULL)
			break;

		PrintSpaces(indent);
		_bstr_t name = prop->GetName();
		cout << "name: " << (const char *)name << ' ';

		PropValType type;
		_variant_t var = prop->GetValue(&type);
		if (type == PROP_TYPE_SET)
		{
			cout << endl;
			PrintPropSet(IMTConfigPropSetPtr(var));
		}
		else
		{
			switch (type)
			{
			case PROP_TYPE_UNKNOWN:
					cout << "[UNKNOWN]";
					break;
			case PROP_TYPE_DEFAULT:
					cout << "[DEFAULT]";
					break;
			case PROP_TYPE_INTEGER:
					cout << "[INTEGER]";
					break;
			case PROP_TYPE_BIGINTEGER:
					cout << "[BIGINTEGER]";
					break;
			case PROP_TYPE_ENUM:
					cout << "[ENUM]";
					break;
			case PROP_TYPE_DOUBLE:
					cout << "[DOUBLE]";
					break;
			case PROP_TYPE_DECIMAL:
					cout << "[DECIMAL]";
					break;
			case PROP_TYPE_STRING:
					cout << "[STRING]";
					break;
			case PROP_TYPE_DATETIME:
					cout << "[DATETIME]";
					break;
			case PROP_TYPE_TIME:
					cout << "[TIME]";
					break;
			case PROP_TYPE_BOOLEAN:
					cout << "[BOOLEAN]";
					break;
			case PROP_TYPE_OPAQUE:
					cout << "[*OPAQUE]";
					break;
			}
			cout << ' ';

			_bstr_t strval = prop->GetValueAsString();

			cout << (const char *)strval << endl;
		}
	}

	indent -= 2;
	PrintSpaces(indent);
	cout << "]" << endl;
}


void Test3()
{
	IMTConfigPtr config("MetraTech.MTConfig.1");

	IMTConfigPropSetPtr set = 
		config->NewConfiguration("top");

	_variant_t var = 1L;
	
	set->InsertProp("version", PROP_TYPE_INTEGER, var);

	for (int i = 0; i < 4; i++)
	{
		IMTConfigPropSetPtr inner = set->InsertSet("inside");

		_variant_t var = (long) i;
		inner->InsertProp("property", PROP_TYPE_INTEGER, var);

		var = "A string";
		inner->InsertProp("str", PROP_TYPE_STRING, var);
	}

	set->Write("e:\\proj\\testwrite.xml");
}


void TestServerRead(const char * apServer, const char * apFilename)
{
	IMTConfigPtr config("MetraTech.MTConfig.1");

	VARIANT_BOOL match;
	IMTConfigPropSetPtr set =
		config->ReadConfigurationFromHost(apServer, apFilename, VARIANT_FALSE, &match);

	PrintPropSet(set);

	//set->WriteToHost(apServer, "test/testout.xml", "", "", VARIANT_FALSE, VARIANT_FALSE);
}


void TestRead(const char * apFilename)
{
	IMTConfigPtr config("MetraTech.MTConfig.1");


	VARIANT_BOOL flag;

	IMTConfigPropSetPtr set = 
		config->ReadConfiguration(apFilename, &flag);

	if (flag == VARIANT_TRUE)
	{
		cout << "Checksum match" << endl;
	}
	else
	{
		cout << "Checksum does not match" << endl;
	}


	PrintPropSet(set);
}


void Test1(const char * apDir, const char * apFilename)
{
	VARIANT_BOOL flag;
	string fullFn = apDir;
	fullFn += apFilename;

	IMTConfigPtr config("MetraTech.MTConfig.1");

	//config->PutChecksumSwitch(VARIANT_FALSE);

	IMTConfigPropSetPtr set = 
		config->ReadConfiguration(fullFn.c_str(), &flag);

	if (flag == VARIANT_TRUE)
	{
		cout << "Checksum match" << endl;
	}
	else
	{
		cout << "Checksum does not match" << endl;
	}

	_bstr_t name("opaque_name");

	_variant_t var;

	//var = "data";
	//var = "\n<msixtag>\n  <dataitem>\n    <configdata>&lt;msixdata</configdata>\n  </dataitem>\n</msixtag>\n";
	//set->InsertProp(name, PROP_TYPE_OPAQUE, var);

	//set->Reset();

	PrintPropSet(set);

	string outFn("test1writeTemp.xml");

	fullFn = apDir + outFn;
	set->Write(fullFn.c_str());

	set = config->ReadConfiguration(fullFn.c_str(), &flag);

	outFn = "Test1WriteChecksum.xml";

	fullFn = apDir + outFn;
	set->WriteWithChecksum(fullFn.c_str());

#if 0
	_bstr_t bstr(L"prop1");
	IMTConfigPropPtr prop = set->NextWithName(bstr);

	PropValType type;
	_variant_t var = prop->GetValue(&type);
	cout << "prop1 val: " << (_bstr_t) var << endl;



	IMTConfigPropPtr prop;

	cout << "Read successfully" << endl;

	while (TRUE)
	{
		prop = set->Next();
		if (prop == NULL)
			break;

		_bstr_t name = prop->GetName();
		cout << "name: " << name << endl;

		int type;
		_variant_t var = prop->GetValue(&type);
		cout << "value: " << (_bstr_t) var << endl;
	}


#endif


	//IMTSessionServerPtr server;
	//server->GetNameId(_bstr_t("foo"), &id);
	
}


int main(int argc, char * argv[])
{
	//Test3();
	//return 0;

	if (argc < 2)
	{
		cout << "XML file needed." << endl;
		return 0;
	}


	try
	{
		if (argc == 4 && 0 == strcmp(argv[1], "-net"))
		{
			TestServerRead(argv[2], argv[3]);
		}
		else if (argc == 2)
		{
			TestRead(argv[1]);
		}
		else if (argc == 3)
		{
	//	Test3();
			Test1(argv[1], argv[2]);
		}
		//"d:/public/config/pipeline/Test/stage.xml");
		//Test1("d:/scratch/mem.xml");
	}
	catch (HRESULT hr)
	{
		cout << "Error! " << hex << hr << dec << endl;
	}
	catch (_com_error err)
	{
		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
	}
/*
	catch (...)
	{
		cout << "everything else " << endl;
	}
	*/


	return 0;
}

