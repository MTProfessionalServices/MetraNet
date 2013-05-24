#include "MTSQLException.h"
#include <stdio.h>
#include "antlr/ANTLRException.hpp"
#ifdef WIN32
#include <MTMSIXUnicodeConversion.h>
#endif

MTSQLInternalErrorException::MTSQLInternalErrorException(const std::string& file, int line, const std::string& text) 
	: MTSQLException(text),
		mFile(file)
{
	char buf[64];
	sprintf(buf, "%d", line);
}

MTSQLInternalErrorException::~MTSQLInternalErrorException() throw()
{
}

std::string MTSQLInternalErrorException::toString() const 
{ 
	return "Internal Error: file = " + mFile + " line = " + mLine + " message = " + getMessage(); 
}

#ifdef WIN32
MTSQLComException::MTSQLComException(HRESULT hr) : MTSQLRuntimeErrorException(),
																									 mComError(NULL)
{
	mComError = new _com_error(hr);
  mText = toString();
}

MTSQLComException::~MTSQLComException()
{
	delete mComError;
}

std::string MTSQLComException::toString() const
{
	return getMessage();
}

std::string MTSQLComException::getMessage() const
{
	MTMSIXUnicodeConversion convert((const char *)mComError->ErrorMessage());
	return std::string(convert.ConvertToASCII());
}

const char* MTSQLComException::what() const throw()
{
  return MTSQLException::what();
}
#else
MTSQLComException::MTSQLComException(boost::uint32_t ) 
  : 
  MTSQLRuntimeErrorException("Unimplmeneted")
{
}
#endif

MTSQLUnhandledAntlrException::MTSQLUnhandledAntlrException(ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrException) :
	mAntlrException(antlrException)
{
}
std::string MTSQLUnhandledAntlrException::toString() const 
{ 
	return mAntlrException.toString(); 
}

std::string MTSQLUnhandledAntlrException::getMessage() const 
{ 
	return mAntlrException.getMessage(); 
}

const char* MTSQLUnhandledAntlrException::what() const throw() 
{ 
	return mAntlrException.toString().c_str(); 
}
