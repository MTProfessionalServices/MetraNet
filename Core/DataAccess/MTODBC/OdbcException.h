#ifndef _ODBCEXCEPTION_H_
#define _ODBCEXCEPTION_H_

#pragma warning( disable : 4251 )

#include <string>
#include <exception>
#include <metra.h>
#include <sql.h>
#include <comdef.h>

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class DllExport COdbcException : public std::exception {
private:
	std::string mText;
	std::string mSqlState;
	HRESULT mErrorCode;
	// The string we return in what() is const char * so
	// we need to manage that buffer.
	std::string mWhatBuffer;

	void createWhatBuffer()
	{
		mWhatBuffer = mText;

		if (mSqlState.length() > 0)
			mWhatBuffer += "; SQLSTATE = " + mSqlState;

		if (mErrorCode != 0)
		{
			char hrBuffer[64];
			sprintf(hrBuffer, "%x", mErrorCode);
			mWhatBuffer += "; HRESULT = ";
			mWhatBuffer += hrBuffer;
		}
	}
protected:
	void setMessage(const char* message) 
	{ 
		mText = message; 
		createWhatBuffer();
	}
	void setSqlState(SQLCHAR sqlState[5]) 
	{
		mSqlState = std::string((const char *)&sqlState[0], 5);
		createWhatBuffer();
	}
	void setErrorCode(const HRESULT aErrorCode) 
	{ 
		mErrorCode = aErrorCode; 
		createWhatBuffer();
	}

public:
	COdbcException() : mErrorCode(0) 
	{
		createWhatBuffer();
	}
	COdbcException(const HRESULT aErrorCode) : mErrorCode(aErrorCode) 
	{
		createWhatBuffer();
	}
	COdbcException(const HRESULT aErrorCode, const std::string& aDetail) : mErrorCode(aErrorCode), mText(aDetail) 
	{
		createWhatBuffer();
	}
	COdbcException(const std::string& text) : mText(text), mErrorCode(E_FAIL) 
	{
		createWhatBuffer();
	}
	COdbcException(const HRESULT aErrorCode,
                 const std::string& aDetail,
	               const std::string aSqlState) : mErrorCode(aErrorCode), mText(aDetail), mSqlState(aSqlState)
  {
    createWhatBuffer();
  }
	COdbcException(const COdbcException& ex)
	{
		mText = ex.getMessage();
		mSqlState = ex.getSqlState();
	  mErrorCode = ex.getErrorCode();
		createWhatBuffer();
	}
	virtual ~COdbcException() throw() {}

	virtual std::string toString() const
	{
		return mWhatBuffer;
	}

	virtual std::string getMessage() const { return mText; }

	virtual std::string getSqlState() const { return mSqlState; }

	virtual const char* what() const throw() { return mWhatBuffer.c_str(); }

	virtual HRESULT getErrorCode() const { return mErrorCode; }

};

// This class calls SQLGetDiagRec and creates appropriate messages.
class DllExport COdbcConnectionException : public COdbcException
{
public:
	COdbcConnectionException(HDBC hConnection);
};

// This class calls SQLGetDiagRec and creates appropriate messages.
class DllExport COdbcStatementException : public COdbcException
{
public:
	COdbcStatementException(HSTMT hStmt);
};

// This class calls SQLGetDiagRec and creates appropriate messages.
class DllExport COdbcDescriptorException : public COdbcException
{
public:
	COdbcDescriptorException(SQLHDESC hDesc);
};

// This class constructs an OdbcException from a _com_error
// OK, a com_error is not really an OdbcException, but it makes catching and
// forwarding these errors a lot easier
class DllExport COdbcComException : public COdbcException
{
public:
	COdbcComException(const _com_error& aError);
};

class DllExport COdbcBindingException : public COdbcException
{
public:
	COdbcBindingException(const std::string& text)
		:
		COdbcException(text)
	{
	}
};

#pragma warning( default : 4251 )

#endif 

