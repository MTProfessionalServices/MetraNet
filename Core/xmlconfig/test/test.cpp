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

#include <metra.h>
#include <xmlconfig.h>
#include <time.h>
#include <stdio.h>

using namespace std;

#define READ_SIZE 1024

void ParseString(XMLParser & arParser, const char * apStr);

int indent = 0;
void PrintPropSet(XMLConfigPropSet * propset);

void PrintError(const char * apStr, const ErrorObject * obj)
{
	cout << apStr << ": " << hex << obj->GetCode() << dec << endl;
	string message;
	obj->GetErrorMessage(message, true);
	cout << message.c_str() << "(";
	const string & detail = obj->GetProgrammerDetail();
	cout << detail.c_str() << ')' << endl;

	if (strlen(obj->GetModuleName()) > 0)
		cout << " module: " << obj->GetModuleName() << endl;
	if (strlen(obj->GetFunctionName()) > 0)
		cout << " function: " << obj->GetFunctionName() << endl;
	if (obj->GetLineNumber() != -1)
		cout << " line: " << obj->GetLineNumber() << endl;

	char * theTime = ctime(obj->GetErrorTime());
	cout << " time: " << theTime << endl;
}

int testparse(int argc, char * * argv)
{
	cout << "Processing." << endl;

	XMLConfigParser parser(0);
	if (!parser.Init())
	{
		PrintError("Unable to initialize", parser.GetLastError());
		return -1;
	}

	XMLConfigPropSet * propset;
	if (argc > 1)
		propset = parser.ParseFile(argv[1]);
	else
		propset = parser.ParseFile(stdin);

	if (!propset)
	{
		PrintError("Unable to parse file", parser.GetLastError());
		return -1;
	}

	indent = 0;
	PrintPropSet(propset);

//	cout << *propset;

	delete propset;

	return 0;
}


void PrintSpaces(int count)
{
	for (int i = 0; i < count; i++)
	{
		cout << ' ';
	}
}


void PrintPropSet(XMLConfigPropSet * propset)
{
	PrintSpaces(indent);
	cout << propset->GetName() << endl;
	PrintSpaces(indent);
	cout << "[" << endl;
	indent += 2;

	const XMLConfigPropSet::XMLConfigObjectList & contents = propset->GetContents();
	XMLConfigPropSet::XMLConfigObjectList::const_iterator it;
	for (it = contents.begin(); it != contents.end(); it++)
	{
		XMLObject * obj = *it;
		XMLConfigPropSet * subset = NULL;
		subset = ConvertUserObject(obj, subset);
		if (subset)
		{
			PrintPropSet(subset);
		}
		else
		{
			XMLConfigNameVal * nameval = static_cast<XMLConfigNameVal *>(obj);
			PrintSpaces(indent);
			cout << nameval->GetName() << ' ';
			ValType::Type type = nameval->GetPropType();
			switch (type)
			{
			case ValType::TYPE_UNKNOWN:
					cout << "[UNKNOWN]";
					break;
			case ValType::TYPE_DEFAULT:
					cout << "[DEFAULT]";
					break;
			case ValType::TYPE_INTEGER:
					cout << "[INTEGER]";
					break;
			case ValType::TYPE_DOUBLE:
					cout << "[DOUBLE]";
					break;
			case ValType::TYPE_DECIMAL:
					cout << "[DECIMAL]";
					break;
			case ValType::TYPE_STRING:
					cout << "[STRING]";
					break;
			case ValType::TYPE_DATETIME:
					cout << "[DATETIME]";
					break;
			case ValType::TYPE_TIME:
					cout << "[TIME]";
					break;
			case ValType::TYPE_BOOLEAN:
					cout << "[BOOLEAN]";
					break;
			}
			cout << ' ';

			string value;
			nameval->FormatValue(value);
			cout << value.c_str();
			cout << endl;
		}
	}

	indent -= 2;
	PrintSpaces(indent);
	cout << "]" << endl;
}


#if 0
void ParseString(XMLParser & arParser, const char * apStr)
{
	arParser.Restart();

	XMLObject * results;
	BOOL result = arParser.ParseFinal(apStr, strlen(apStr), &results);

	ASSERT(results);

	XMLConfigPropSet * propset = ConvertUserObject(results, propset);
	ASSERT(propset);

	indent = 0;
	PrintPropSet(propset);

	cout << *results;

	delete results;
}
#endif

int main(int argc, char **argv)
{
	testparse(argc, argv);

	return 0;
}



