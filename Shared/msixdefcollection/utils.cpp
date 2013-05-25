/**************************************************************************
 * @doc UTILS
 *
 * Copyright 2000 by MetraTech Corporation
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
#import <MTConfigLib.tlb>
#include <msixdefcollection.h>
#include <MSIXDefinition.h>
#include <mtprogids.h>
#include <iostream>

using namespace std;
using namespace MTConfigLib;

static void OutputSpaces(int spaces)
{
	if (spaces <= 0)
		spaces = 1;
	//RWCString spaceString(' ', spaces);
  string spaceString(spaces, ' ');
	cout << spaceString.c_str();
}


void DumpMSIXDef(CMSIXDefinition * apDef)
{
	const wstring & name = apDef->GetName();
	const _bstr_t bstr = name.c_str();
	cout << endl << "---- " << (const char *)bstr << " ----" << endl;
	//cout << endl << "---- " << name.c_str() << " ----" << endl;

	MSIXPropertiesList & props = apDef->GetMSIXPropertiesList();

	MSIXPropertiesList::iterator it;
	for (it = props.begin(); it != props.end(); ++it)
	{
		CMSIXProperties * serviceProp = *it;

		cout << ascii(serviceProp->GetDN());

		OutputSpaces(32 - serviceProp->GetDN().length());

		string typeName;
		switch (serviceProp->GetPropertyType())
		{
		case CMSIXProperties::TYPE_STRING:
			typeName = "string"; break;
		case CMSIXProperties::TYPE_WIDESTRING:
			typeName = "widestring"; break;
		case CMSIXProperties::TYPE_INT32:
			typeName = "int32"; break;
		case CMSIXProperties::TYPE_INT64:
			typeName = "int64"; break;
		case CMSIXProperties::TYPE_TIMESTAMP:
			typeName = "timestamp"; break;
		case CMSIXProperties::TYPE_TIME:
			typeName = "time"; break;
		case CMSIXProperties::TYPE_FLOAT:
			typeName = "float"; break;
		case CMSIXProperties::TYPE_DOUBLE:
			typeName = "double"; break;
		case CMSIXProperties::TYPE_NUMERIC:
			typeName = "numeric"; break;
		case CMSIXProperties::TYPE_DECIMAL:
			typeName = "decimal"; break;
		case CMSIXProperties::TYPE_ENUM:
			typeName = "enum"; break;
		case CMSIXProperties::TYPE_BOOLEAN:
			typeName = "boolean"; break;
		default:
			{
				const wstring & name = serviceProp->GetDataType();
				const _bstr_t bstr = name.c_str();
				typeName = bstr;
				break;
			}
		}

		cout << typeName.c_str();
		OutputSpaces(10 - typeName.length());

		string requiredString;
		requiredString = serviceProp->GetIsRequired() ? "required" : "optional";
		cout << requiredString.c_str();

		cout << endl;
	}
}

void MSIXDefAsAutosdk(CMSIXDefinition * apDef, string & arBuffer)
{
	IMTConfigPtr config(MTPROGID_CONFIG);

	IMTConfigPropSetPtr set = config->NewConfiguration("xmlconfig");
	IMTConfigPropSetPtr sessionSet = set->InsertSet("session");
	sessionSet->InsertProp("ServiceName", PROP_TYPE_STRING, apDef->GetName().c_str());
	sessionSet->InsertProp("ServiceID", PROP_TYPE_ENUM, apDef->GetName().c_str());
	IMTConfigPropSetPtr inputs = sessionSet->InsertSet("inputs");
	

	MSIXPropertiesList & props = apDef->GetMSIXPropertiesList();

	DATE now;
	OleDateFromTimet(&now, time(NULL));
	_variant_t nowVariant(now, VT_DATE);

	MSIXPropertiesList::iterator it;
	for (it = props.begin(); it != props.end(); ++it)
	{
		CMSIXProperties * serviceProp = *it;

		const wstring & name = serviceProp->GetDN();

		string typeName;
		switch (serviceProp->GetPropertyType())
		{
		case CMSIXProperties::TYPE_STRING:
			inputs->InsertProp(name.c_str(), PROP_TYPE_STRING, "xx");
			break;
		case CMSIXProperties::TYPE_INT32:
			inputs->InsertProp(name.c_str(), PROP_TYPE_INTEGER, (long) 123);
			break;
		case CMSIXProperties::TYPE_INT64:
			inputs->InsertProp(name.c_str(), PROP_TYPE_BIGINTEGER, (__int64) 123);
			break;
		case CMSIXProperties::TYPE_TIMESTAMP:
			inputs->InsertProp(name.c_str(), PROP_TYPE_DATETIME, nowVariant);
			break;
		case CMSIXProperties::TYPE_FLOAT:
			inputs->InsertProp(name.c_str(), PROP_TYPE_DOUBLE, 1.23);
			break;
		case CMSIXProperties::TYPE_DOUBLE:
			inputs->InsertProp(name.c_str(), PROP_TYPE_DOUBLE, 1.23);
		}
	}

	_bstr_t out = set->WriteToBuffer();
	arBuffer = out;
}


