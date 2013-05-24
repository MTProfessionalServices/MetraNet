#ifndef __REPORTER_CMD_LINE_H
#define __REPORTER_CMD_LINE_H

#include "Reporter.h"

#include "MetraFlowConfig.h"
#include "LogAdapter.h"

/**
 * Reports exceptions that occur and other results of running MetraFlow
 * from the command line.
 */
class ReporterCmdLine : public Reporter
{
  public:
    /** Constructor */
    METRAFLOW_DECL ReporterCmdLine();

    /** Destructor */
    METRAFLOW_DECL ~ReporterCmdLine();

    /** Report the given ANTLR exception.  */
    virtual void reportException(antlr::ANTLRException& e);

    /** Report the given DataflowException */
    virtual void reportException(DataflowException& e);

    /** Report the given standard exception */
    virtual void reportException(std::exception& e);

    /** 
     * Report an unrecognized exception.
     *
     * @param phase  Name of the phase were the exception occurred
     *               For example, "parsing", "type checking".
     */
    virtual void reportException(const std::wstring& phase);
    
    /** Report an error. */
    virtual void reportError(const std::wstring& errMessage);
};

#endif
