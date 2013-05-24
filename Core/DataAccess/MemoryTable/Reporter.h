#ifndef __REPORTER_H
#define __REPORTER_H

#include "DataflowException.h"
#include "ANTLRException.hpp"

/**
 * An abstract base class defining the interface for reporting
 * an exceptions that occur and other results of running MetraFlow.
 */
class Reporter
{
  protected:
    /** True if an error was reported. */
    bool mWasErrorReported;

    /** Last error message reported. */
    std::wstring mErrMessage;

    /** Line number of last error. */
    int mLineNumber;

    /** Column number of last error. */
    int mColumnNumber;

  public:
    /** 
     * Constructor 
     */
    Reporter() 
      : mWasErrorReported(false),
        mErrMessage(L""),
        mLineNumber(0),
        mColumnNumber(0) {}

  /**
   * Destructor
   */
  virtual ~Reporter() 
  {
  }

    /** Report the given ANTLR exception.  */
    virtual void reportException(antlr::ANTLRException& e) = 0;

    /** Report the given DataflowException */
    virtual void reportException(DataflowException& e) = 0;

    /** Report the given standard exception */
    virtual void reportException(std::exception& e) = 0;

    /** 
     * Report an unrecognized exception 
     * 
     * @param phase  Name of the phase were the exception occurred
     *               For example, "parsing", "type checking".
     */
    virtual void reportException(const std::wstring& phase) = 0;

    /** Report an error. */
    virtual void reportError(const std::wstring& errMessage) = 0;

    /**
     * Returns true if an error was reported through this interface.
     *
     * @param msg        Error message.
     * @param lineNumber Line number where the error occurred. <= 0 is unknown.
     * @param colNumber  Col number where the error occurred. <= 0 is unknown.
     */
    bool didErrorOccur(std::wstring &msg, 
                       int &lineNumber, int &colNumber) const
    {
      msg = mErrMessage;
      lineNumber = mLineNumber;
      colNumber = mColumnNumber;
      return mWasErrorReported;
    }
};


#endif
