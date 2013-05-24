#ifndef _MTSQLEXCEPTION_H_
#define _MTSQLEXCEPTION_H_

#include "MTSQLConfig.h"

#include <string>
#include <exception>
#ifdef WIN32
#include <comdef.h>
#else
#include <boost/cstdint.hpp>
#endif

// Forward declarations
namespace antlr 
{
	class ANTLRException;
};

class MTSQLException : public std::exception {
protected:
	std::string mText;

public:
	MTSQLException() {}
	MTSQLException(const std::string& text) : mText(text) {}
	virtual ~MTSQLException() throw() {}

	virtual std::string toString() const { return mText; }

	virtual std::string getMessage() const { return mText; }

	virtual const char* what() const throw() { return mText.c_str(); }
};

// A generic runtime error exception. The execution engine should only throw subclasses of this.
class MTSQLRuntimeErrorException : public MTSQLException
{
public:
	MTSQLRuntimeErrorException(const std::string& text) : MTSQLException(text) {}
	MTSQLRuntimeErrorException() : MTSQLException() {}
};

#ifdef WIN32
// An exception that corresponds to a failure HRESULT
class MTSQLComException : public MTSQLRuntimeErrorException
{
private:
	_com_error * mComError;
public:
	MTSQL_DECL MTSQLComException(HRESULT hr);
	MTSQL_DECL virtual ~MTSQLComException() throw();

	MTSQL_DECL virtual std::string toString() const;

	MTSQL_DECL virtual std::string getMessage() const; 

	MTSQL_DECL virtual const char* what() const throw();
};
#else
class MTSQLComException : public MTSQLRuntimeErrorException
{
private:
public:
  MTSQL_DECL MTSQLComException(boost::uint32_t hr);
	MTSQL_DECL virtual ~MTSQLComException() throw() {}
};
#endif


// An internal error exception.  Essentially these are equivalent to ASSERT's.  An internal
// error should only be thrown when it could be attributed to programming errors in the 
// interpreter itself.
class MTSQLInternalErrorException : public MTSQLException
{
private:
	std::string mFile;
	std::string mLine;

public:
	MTSQL_DECL MTSQLInternalErrorException(const std::string& file, int line, const std::string& text);
	MTSQL_DECL ~MTSQLInternalErrorException() throw() ;
	MTSQL_DECL virtual std::string toString() const; 
};

// An unhandled Antlr exception that occurs in the code.
// It is a bug if one of these puppies gets through.  Nonetheless,
// we don't want our interface to have anything Antlr specific in it
// so we'll create this wrapper.
class MTSQLUnhandledAntlrException : public MTSQLException
{
private:
	antlr::ANTLRException& mAntlrException;
public:
	MTSQL_DECL MTSQLUnhandledAntlrException(antlr::ANTLRException& antlrException);
	MTSQL_DECL ~MTSQLUnhandledAntlrException() throw() {}
	MTSQL_DECL virtual std::string toString() const;

	MTSQL_DECL virtual std::string getMessage() const;

	MTSQL_DECL virtual const char* what() const throw();
};

// A bit of a hack!  The MTSQLReturnException is used by the
// interpreter to handle the RETURN statement in the language.
class MTSQLReturnException : public MTSQLException
{
public:
	MTSQLReturnException() : MTSQLException("RETURN") {}
};

// A bit of a hack!  The MTSQLReturnException is used by the
// interpreter to handle the CONTINUE statement in the language.
class MTSQLContinueException : public MTSQLException
{
public:
	MTSQLContinueException() : MTSQLException("CONTINUE") {}
};

// A bit of a hack!  The MTSQLBreakException is used by the
// interpreter to handle the BREAK statement in the language.
class MTSQLBreakException : public MTSQLException
{
public:
	MTSQLBreakException() : MTSQLException("BREAK") {}
};

// A bit of a hack!  The MTSQLUserException is thrown by the
// RAISERROR function in the MTSQL standard library.  The interpreter
// passes this exception through, so folks integrating MTSQL should
// be prepared to handle these and react accordingly (e.g. translate
// to _com_error or something).
#ifdef WIN32
class MTSQLUserException : public MTSQLException
{
private:
	HRESULT mHr;
public:
	HRESULT GetHRESULT() const { return mHr; }
	MTSQLUserException(const std::string& text, HRESULT hr) : MTSQLException(text), mHr(hr) {}
};
#else
class MTSQLUserException : public MTSQLException
{
private:
	boost::uint32_t mHr;
public:
	boost::uint32_t GetHRESULT() const { return mHr; }
	MTSQLUserException(const std::string& text, boost::uint32_t hr) : MTSQLException(text), mHr(hr) {}
};
#endif

#endif
