/**************************************************************************
 * @doc ERRUTILS
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

#include <metralite.h>
#include <errutils.h>

#include <time.h>

void StringFromError(string & arBuffer,
										 const char * apPrefix, const ErrorObject * obj)
{

	if (apPrefix)
	{
		arBuffer = apPrefix;
		arBuffer += ": ";
	}

	char buffer[64];
	sprintf(buffer, "%X", obj->GetCode());
	arBuffer += buffer;

	//cout << apStr << ": " << hex << obj->GetCode() << dec << endl;

	string message;
	obj->GetErrorMessage(message, true);

	arBuffer += ' ';
	arBuffer += message;

	const string & detail = obj->GetProgrammerDetail();
	if (detail.length() > 0)
	{
		arBuffer += " (";
		arBuffer += detail;
		arBuffer += ")";
	}

	if (strlen(obj->GetModuleName()) > 0)
	{
		arBuffer += "\n module: ";
		arBuffer += obj->GetModuleName();
	}

	if (strlen(obj->GetFunctionName()) > 0)
	{
		arBuffer += "\n function: ";
		arBuffer += obj->GetFunctionName();
	}

	if (obj->GetLineNumber() != -1)
	{
		arBuffer += "\n line: ";
		sprintf(buffer, "%d", obj->GetLineNumber());
	}

	char * theTime = ctime(obj->GetErrorTime());
	arBuffer += "\n time: ";
	arBuffer += theTime;
}

void MTErrorObjectException::Init()
{
	// Not much we can do if this call fails...
	GetErrorObject()->GetErrorMessage(mWhat);
}

const char* MTErrorObjectException::what() const
{
	return mWhat.c_str();
}

