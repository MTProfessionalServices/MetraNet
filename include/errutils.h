/**************************************************************************
 * @doc ERRUTILS
 *
 * @module |
 *
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
 *
 * @index | ERRUTILS
 ***************************************************************************/

#ifndef _ERRUTILS_H
#define _ERRUTILS_H

#include <errobj.h>
#include <string>
#include <exception>

using std::string;

void StringFromError(string & arBuffer,
										 const char * apPrefix, const ErrorObject * obj);

/**
 * An STL exception that carries a MetraTech ErrorObject
 * within it.
 */
class MTErrorObjectException : public std::exception
{
private:
	ErrorObject mErrorObject;
	string mWhat;

	void Init();
public:
	MTErrorObjectException(const ErrorObject& aErrorObject) : mErrorObject(aErrorObject) 
	{
		Init();
	}

	MTErrorObjectException(const ObjectWithError& aObject) 
	{
		if(aObject.GetLastError()) mErrorObject = *(aObject.GetLastError());
		Init();
	}

	MTErrorObjectException(ErrorObject::ErrorCode aCode,
												 const char * apModule, 
												 int aLine, 
												 const char * apProcedure, 
												 const char * apDetail)
		:
		mErrorObject(aCode, apModule, aLine, apProcedure)
	{
		mErrorObject.SetProgrammerDetail(apDetail);
		Init();
	}

	MTErrorObjectException(ErrorObject::ErrorCode aCode,
												 const char * apModule, 
												 int aLine, 
												 const char * apProcedure)
		:
		mErrorObject(aCode, apModule, aLine, apProcedure)
	{
		Init();
	}

	MTErrorObjectException(const MTErrorObjectException& ex) 
		: 
		mErrorObject(*ex.GetErrorObject())
	{
		Init();
	}

	/**
	 * Return a pointer to the error object within.  The
	 * pointer is guaranteed to be non NULL.
	 */
	const ErrorObject* GetErrorObject() const
	{
		return &mErrorObject;
	}

	const char* what() const;
};

#endif /* _ERRUTILS_H */
