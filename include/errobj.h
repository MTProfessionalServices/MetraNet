/**************************************************************************
 * @doc ERROBJ
 *
 * @module Error object |
 *
 * Hold error codes and lookup error strings.
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
 *
 * @index | ERROBJ
 ***************************************************************************/

#ifndef _ERROBJ_H
#define _ERROBJ_H

#include <list>
#include <string>

#ifdef WIN32
// only include this once
#pragma once

 #include <comutil.h>
// #include <mtcomerr.h>

#endif // WIN32

using std::list;
using std::string;
using std::wstring;

/******************************************************** Message ***/

// bit 29 set
#define APPLICATION_ERROR_MASK 0x20000000

// mask to find severity
#define SEVERITY_MASK 0xC0000000
#define MSG_ID_MASK 0x7FFF

//mask to detect user error
#define USER_ERROR_MASK 0x2C000000

#define GET_SEVERITY(x) ((x & SEVERITY_MASK) >> 30)
#define GET_MSG_ID(x) (x & MSG_ID_MASK)

#define CRLF_SIZE 2

/* @class
 *
 * Class that can load message/error strings and deal with message/error codes.

 @comm
 From the win32 documentation:

     "Error codes are 32-bit values (bit 31 is the most significant
     bit). Bit 29 is reserved for application-defined error codes; no
     system error code has this bit set. If you are defining an error
     code for your application, set this bit to one. That indicates
     that the error code has been defined by an application, and
     ensures that your error code does not conflict with any error
     codes defined by the operating system."

	We'll follow this convention and set bit 29 for all application
	errors.
	On Windows, errors that don't have bit 29 set are windows error codes.
	On Unix, error without bit 29 set are errno errors.

  From windows.h with additions:

    Values are 32 bit values layed out as follows:
  
     3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
     1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
    +---+-+-+-----------------------+-------------------------------+
    |Sev|C|R|UU   Facility          |               Code            |
    +---+-+-+-----------------------+-------------------------------+
  
    where
  
        Sev - is the severity code
  
            00 - Success
            01 - Informational
            10 - Warning
            11 - Error
  
        C - is the Customer code flag
  
        R - is a reserved bit
  
        Facility - is the facility code
        UU - bits indicating a "USER ERROR"
  
        Code - is the facility's status code
*/

class Message
{
// @access Public:
public:
	// @cmember 32 bit integer
#ifdef WIN32
	typedef unsigned long ErrorCode;
#else // not WIN32
	typedef unsigned int ErrorCode;
#endif // WIN32

	// @cmember,menum Severity of this message.
	// The enum values are important.
	// @devnote don't use "ERROR" as a constant since
	// windows redefines it.
	enum Severity
	{
		SUCCESS=0x00,								// @@emem Not an error at all
		INFO=0x01,									// @@emem Informational only
		WARNING=0x02,								// @@emem Less severe
		ERROR_SEVERITY=0x03				// @@emem Most severe
	};

	// @cmember Constructor, given message id.
	Message(ErrorCode aCode);

	// @cmember,mfunc Return the error code.
	// @@rdesc ErrorCode
	ErrorCode GetCode() const
	{ return mCode; }

	// @cmember,mfunc Is this error code a system error code?
	//  @@rdesc
	//   @@flag non zero | Indicates a system error code
	//   @@flag 0 | Not a system error code
	BOOL IsSystemError() const
	{
		return (mCode & APPLICATION_ERROR_MASK) == 0;
	}

	// @cmember,mfunc Is this error code an application error code?
	//  @@rdesc
	//   @@flag non zero | Indicates an application error code
	//   @@flag 0 | Not an application error code
	BOOL IsApplicationError() const
	{
		return !IsSystemError();
	}

	// @cmember,mfunc Is this error code a "User Error"
	//  @@rdesc
	//   @@flag non zero | Indicates an user error code
	//   @@flag 0 | Not a user error code
	BOOL IsUserError() const
	{
		return IsUserError(mCode);
	}


	// @cmember Return the severity of this error
	Severity GetSeverity();

	// @cmember return a Unicode string describing the error code.
	BOOL GetErrorMessage(wstring & arUnicode,BOOL abStripCRLF=FALSE) const;

	// @cmember return an ASCII string describing the error code.
	BOOL GetErrorMessage(string & arAscii,BOOL abStripCRLF=FALSE) const;

	// format a message string with inserts
	BOOL FormatErrorMessage(string & arAscii,BOOL abStripCRLF=FALSE,...) const;

	// format a message string with inserts, accepts a va_list
	BOOL FormatErrorMessageArglist(string & arAscii,BOOL abStripCRLF, va_list aArglist) const;


	// @cmember convert a Unicode string to ASCII if possible.
	// characters that can't be converted will be replaced by the default character
	static BOOL ToAscii(string & arAscii, const wstring & arUnicode,
											char aDefaultChar = '?');

	// @cmember check if an error code is a "User Error"
	// User Error are errors that can be displayed directly to an end user
	static BOOL IsUserError(ErrorCode errorCode)
		{ return ((errorCode & USER_ERROR_MASK) == USER_ERROR_MASK); }

#ifdef WIN32
	// @cmember Set the module (DLL) name that the error object will
	// use to read the error message.
	static BOOL AddModule(const char * apModule);

	// call to ignore standard MetraTech errors
	static void IgnoreDefaultModules();

	// @cmember Free the module loaded by SetModule
	static BOOL FreeMessageModules();

	// @cmember Set the language ID.  See win32 documentation for more info.
	static void SetLanguageId(unsigned long aLangId);

#endif // WIN32

// @access Private:
private:
	// @cmember,mfunc return the severity (see comments above for mapping
	// of code to severity).
	// @rdesc severity code.
	int SeverityCode() const
	{
		return (mCode & SEVERITY_MASK) >> 30;
	}

// @access Protected:
protected:
	// @cmember error code
	ErrorCode mCode;

private:
#ifdef WIN32
	static BOOL sIgnoreDefaultModules;
	static BOOL sDefaultsAdded;

	static BOOL AddDefaultModules(string& apErrMsg);


	// @cmember list of handles to modules used to load error messages
	static list<HMODULE> sModules;

	// @cmember language ID
	static unsigned long sLanguageId;
#endif
};

/********************************************************** Error ***/

// shortcut to give a module name
#define ERROR_MODULE __FILE__
// shortcut to give a line number
#define ERROR_LINE __LINE__

/* @class
 *
 * Base class for errors which need to be reported to users.
 */
class ErrorObject : public Message
{
// @access Public:
public:

	// @cmember Constructor, given error information.
	ErrorObject(ErrorCode aCode,
							const char * apModule, int aLine, const char * apProcedure);

	// @cmember empty constructor
	ErrorObject();

	~ErrorObject();

	// @cmember copy constructor
	ErrorObject(const ErrorObject & arErr) : Message(arErr.GetCode())
	{ *this = arErr; }

	// @cmember assignment operator
	ErrorObject & operator =(const ErrorObject & arError);

	// @cmember initialize with given values and update the timestamp
	void Init(ErrorCode aCode,
				const char * apModule, int aLine, const char * apProcedure);

	// @cmember,mfunc Return the time the error occurred
	//  @@rdesc time error occurred
	const time_t * GetErrorTime() const
	{ return &mTime; }

	// @cmember,mfunc Allow access to a string that
	// holds programmer defined information.
	// @rdesc string that can be modified to hold any debugging info
	string & GetProgrammerDetail()
	{
		return mDetail;
	}

	void SetProgrammerDetail(const string & aString) { mDetail = aString; }
	void SetProgrammerDetail(const char* aString) { mDetail = aString; }

	// @cmember,mfunc Allows read only access to
	// the programmer defined detail string.
	// @rdesc const string that holds programmer information.
	const string & GetProgrammerDetail() const
	{
		return mDetail;
	}

	// @cmember,mfunc return the module name
	// @rdesc module name
	const char * GetModuleName() const
	{
		return mModule.c_str();
	}

	// @cmember,mfunc return the function name
	// @rdesc function name
	const char * GetFunctionName() const
	{
		return mProcedure.c_str();
	}

	// @cmember,mfunc return the line number
	// @rdesc line number
	int GetLineNumber() const
	{
		return mLine;
	}

// @access Protected:
protected:
	// @cmember programmer defined detail
	string mDetail;

// @access Private:
private:
	// @cmember time in UTC returned from time()
	time_t mTime;

	// @cmember module error occured in.
	string mModule;

	// @cmember line number error occured in.
	int mLine;

	// @cmember producedure error occurred in.
	string mProcedure;
};


/********************************************************** Error ***/

/* @class
 * 
 * an object that allows the user to call GetLastError.
 */

class ObjectWithError
{
// @access Public:
public:
	// @cmember constructor
	ObjectWithError();

	// @cmember destructor
	virtual ~ObjectWithError();

	// @cmember Return an object holding the last error.
	const ErrorObject * GetLastError() const;
	Message::ErrorCode GetLastErrorCode () const {
		if(mpLastError) return mpLastError->GetCode();
		else return 0;
	}
  
// @access Protected:
protected:
	// @cmember object that holds last error
	// accessable by derived classes.
	ErrorObject * mpLastError;

	//
	// helpers
	//

	// @cmember Clear error status
	// @devnote it is optional to call this function.
	// objects are not required to clear errors after successful calls.
	void ClearError();

	// @cmember Convenience function to set the error from another error
	//  object.  Also sets the error pending flag.
	void SetError(const ErrorObject * apError);
	// @cmember Convenience function to set the error from another error
	//  object.  Also sets the error pending flag.
	void SetError(const ObjectWithError & arObject);
  // @cmember Convenience function to set the error from another error
	//  object.  Also sets the error pending flag.
	void SetError(const ErrorObject * apError, const char *apDetail);
	// @cmember An error is pending with the given information
	void SetError(ErrorObject::ErrorCode aCode,
				const char * apModule, int aLine, const char * apProcedure);
  // @cmember An error is pending with the given information
	void SetError(ErrorObject::ErrorCode aCode,
				const char * apModule, int aLine, const char * apProcedure, const char * apDetail);

};

#ifdef WIN32

//----- MetraTech exception class declaration.
class MTException : public std::exception
{
	public:

		//----- Class constructors.
		MTException(const std::string& msg, HRESULT hr = E_FAIL);

		//----- Class over-rides.
		virtual const char* what() const throw()
		{
			return mMessage.c_str();
		}

		//----- Property access.
		operator HRESULT()
		{
			return mHr;
		}

		operator ErrorObject *()
		{
			ErrorObject * err = new ErrorObject(mHr, "", 0, "");
			err->GetProgrammerDetail() = mMessage.c_str();
			return err;
		}
	
	private:

		std::string mMessage;
		HRESULT mHr;
};


// ESR-5978 The MTPropNotInSessionException allows us to handle the case
// when a property is missing, but the corresponding condition in the parameter table is optional --
// Then we just want to say that the current rule doesn't match and continue on to examine
// the remaining rules in the ruleset.
class MTPropNotInSessionException : public MTException
{
  public:
    MTPropNotInSessionException(const std::string& msg, HRESULT hr = E_FAIL)
      : MTException(msg, hr) 
    {}
};

#endif

#endif /* _ERROBJ_H */
