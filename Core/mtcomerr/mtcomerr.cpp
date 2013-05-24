/**************************************************************************
 * @doc MTCOMERR
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <comutil.h>
#include <comdef.h>

#include <mtcomerr.h>

ErrorObject * CreateErrorFromComError(const _com_error & arError)
{
	_bstr_t desc = arError.Description();
	_bstr_t src = arError.Source();

	// extract module and line from source, looking for format "module[line]"
	string module;
	long line = -1;
	
	if ( (char*)src != NULL )
	{	string source = src;
	
		//looking for line
		string::size_type moduleEndPos = source.rfind("[");
		if(moduleEndPos != string::npos &&
			 source[source.size()-1] == ']')
		{
			line = atol(source.substr(moduleEndPos+1, source.size()-2).c_str());
			module = source.substr(0, moduleEndPos);
		}
		else
			module = source;
	}

	ErrorObject * obj = new ErrorObject(arError.Error(), module.c_str(), line, "");

	// set the description as the programmer detail
	if ( (char*)desc != NULL )
		obj->SetProgrammerDetail(desc);

	return obj;
}


HRESULT ReturnComError(const _com_error & arError)
{
	IErrorInfo * errInfo = arError.ErrorInfo();
	SetErrorInfo(0, errInfo);
	if (errInfo)
		errInfo->Release();
	return arError.Error();
}

/*void StringFromComError(std::string & arBuffer, const char * apMsg,
												const _com_error & arError)
{
	string str;
	StringFromComError(str, apMsg, arError);

	arBuffer = str.c_str();
}*/


void StringFromComError(string & arBuffer, const char * apMsg,
												const _com_error & arError)
{
	_bstr_t desc = arError.Description();
	_bstr_t src =  arError.Source();
	const char * descString;
	if (desc.length() > 0)
		descString = desc;
	else
		descString = NULL;

	// try to convert the error code to a string
	string errorString;
	Message message(arError.Error());
	message.GetErrorMessage(errorString, TRUE);

	arBuffer = apMsg;

	char buff[100];
	sprintf(buff, ": %x", arError.Error());
	arBuffer += buff;

	if (descString)
	{
		arBuffer += " (";
		arBuffer += descString;
		arBuffer += ')';
	}

	if (errorString.length() > 0)
	{
		arBuffer += " (";
		arBuffer += errorString;
		arBuffer += ')';
	}
}



void PassThroughComError()
{
	IErrorInfo* pError = NULL;
	if(GetErrorInfo(0,&pError) == S_OK) {
		SetErrorInfo(0, pError);
	}
}

