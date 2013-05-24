#ifndef __SEHEXCEPTION_H__
#define __SEHEXCEPTION_H__

// Should I derive from std::exception?
#include "CallStack.h"

class SEHException
{
public:
  METRAFLOW_DECL static void TranslateStructuredExceptionHandlingException(unsigned int id, struct _EXCEPTION_POINTERS* );
private:
  unsigned int mExceptionID;
  const char * mMessage;
  CallStack mCallStack;
  std::string mCallStackString;
public:
  explicit SEHException(unsigned int exceptionID, const char * msg, const CallStack & callStack)
    :
    mExceptionID(exceptionID),
    mMessage(msg),
    mCallStack(callStack)
  {
  }
  virtual ~SEHException()
  {
  }
  const char * what()
  {
    return mMessage != NULL ? mMessage : "Unknown exception";
  }
  const char * callStack()
  {
    if (mCallStackString.size() == 0)
    {
      mCallStack.ToString(mCallStackString);
    }
    return mCallStackString.c_str();
  }
};

class FatalSystemErrorException : public SEHException
{
public:
  explicit FatalSystemErrorException(unsigned int exceptionID, const char * msg, const CallStack & callStack)
    :
    SEHException(exceptionID, msg, callStack)
  {
  }
  ~FatalSystemErrorException()
  {
  }
};

class NonFatalSystemErrorException : public SEHException
{
public:
  explicit NonFatalSystemErrorException(unsigned int exceptionID, const char * msg, const CallStack & callStack)
    :
    SEHException(exceptionID, msg, callStack)
  {
  }
  ~NonFatalSystemErrorException()
  {
  }
};

class IntegerOperationException : public SEHException 
{
public:
  explicit IntegerOperationException(unsigned int exceptionID, const char * msg, const CallStack & callStack)
    :
    SEHException(exceptionID, msg, callStack)
  {
  }
  ~IntegerOperationException()
  {
  }
};

class FloatingPointOperationException : public SEHException
{
public:
  explicit FloatingPointOperationException(unsigned int exceptionID, const char * msg, const CallStack & callStack)
    :
    SEHException(exceptionID, msg, callStack)
  {
  }
  ~FloatingPointOperationException()
  {
  }
};

#endif
