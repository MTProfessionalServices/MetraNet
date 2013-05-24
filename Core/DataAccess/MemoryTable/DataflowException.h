#ifndef __DATAFLOW_EXECPTION_H
#define __DATAFLOW_EXECPTION_H

#include "MetraFlowConfig.h"

#include <string>

class DataflowScriptInterpreter;

/**
 * The base class for Dataflow Exceptions.  
 * Dataflow exceptions are either parsing exceptions
 * or type-checking exceptions.
 */
class DataflowException : public std::exception
{
  public:
    /** 
     * Constructor 
     */
    METRAFLOW_DECL DataflowException();

    /** Get a displayable message describing the exception.*/
    METRAFLOW_DECL std::wstring getMessage() const;

    /** Get the line number of the error.  <= 0 if unknown. */
    METRAFLOW_DECL int getLineNumber() const;

    /** Get the column number of the error.  <= 0 if unknown. */
    METRAFLOW_DECL int getColumnNumber() const;

    /** Destructor */
    METRAFLOW_DECL ~DataflowException() throw();

  protected:
    /** Descriptive message for exception. */
    std::wstring mMessage;

    /** Line number of error. <= 0 if unknown. */
    int mLineNumber;

    /** Column number of error. <= 0 if unknown. */
    int mColumnNumber;

    /** Name of parsed file. Empty string if unknown. */
    std::wstring mFilename;
};

/**
 * The base class for parsing exceptions.
 * These are thrown in dataflow_analyze.g and 
 * dataflow_generate.g.
 */
class DataflowParseException : public DataflowException
{
  public:
    /** 
     * Constructor 
     */
    METRAFLOW_DECL DataflowParseException();

    /** Get a displayable message describing the exception.*/
    std::wstring getMessage() const;

    /** Destructor */
    METRAFLOW_DECL ~DataflowParseException() throw();

};

/**
 * An composite parameter name is invalid
 */
class DataflowCompositeParamNameException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param name                  name of the composite
     * @param paramName             name of the composite param
     * @param lineNumber            line number where param name defined
     * @param colNumber             column number where param name defined
     */
    METRAFLOW_DECL DataflowCompositeParamNameException(
                                       const std::wstring &name,
                                       const std::wstring &paramName,
                                       bool wasReferencedAsInput,
                                       int lineNumber,
                                       int columnNumber,
                                       const std::wstring& filename);
    /** Destructor */
    METRAFLOW_DECL ~DataflowCompositeParamNameException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getCompositeName() const;

  private:
    DataflowCompositeParamNameException();
};

/**
 * An composite range parameter is not the last argument.
 */
class DataflowCompositeRangeParamException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param name                  name of the composite
     * @param portName              name of the composite port param
     * @param wasReferencesAsInput  is an input parameter
     * @paran lineNumber            line number where port name defined
     * @param colNumber             column number where port name defined
     */
    METRAFLOW_DECL DataflowCompositeRangeParamException(
                                       const std::wstring &name,
                                       const std::wstring &portName,
                                       bool wasReferencedAsInput,
                                       int lineNumber,
                                       int columnNumber,
                                       const std::wstring& filename);
    /** Destructor */
    METRAFLOW_DECL ~DataflowCompositeRangeParamException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getCompositeName() const;

  private:
    DataflowCompositeRangeParamException();
};

/**
 * The value specified for the argument for an operation in
 * the MetraFlow script is invalid.
 */
class DataflowInvalidArgumentValueException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param lineNumber line number of error
     * @param columnNumber column number of error
     * @param opName    name of operation instance
     * @param argName   argument name
     * @param argValue  argument value
     * @param expected  a phrase explaining expected values (Expected a or b,
     *                Expected a string)
     */
    METRAFLOW_DECL DataflowInvalidArgumentValueException(
                                          int lineNumber,
                                          int columnNumber,
                                          const std::wstring &filename,
                                          const std::wstring &opName,
                                          const std::wstring &argName,
                                          const std::wstring &argValue,
                                          const std::wstring &expected);
    /** Destructor */
    METRAFLOW_DECL ~DataflowInvalidArgumentValueException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getOperationName() const;

    /** Get operation argument name. */
    METRAFLOW_DECL std::wstring getOperationArgName() const;

    /** Get operation argument value. */
    METRAFLOW_DECL std::wstring getOperationArgValue() const;

  private:
    DataflowInvalidArgumentValueException();

  private:
    /** Name of operation. */
    std::wstring mOpName;

    /** Name of operation argument. */
    std::wstring mArgName;

    /** Offending argument value. */
    std::wstring mArgValue;
};

/**
 * Encountered an unrecognized argument for an operation in
 * the MetraFlow script.
 */
class DataflowInvalidArgumentException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param opName    name of operation instance
     * @param argName   argument name
     */
    METRAFLOW_DECL DataflowInvalidArgumentException(
                                     int lineNumber,
                                     int columnNumber,
                                     const std::wstring &filename,
                                     const std::wstring &opName,
                                     const std::wstring &argName);
    /** Destructor */
    METRAFLOW_DECL ~DataflowInvalidArgumentException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getOperationName() const;

  private:
    DataflowInvalidArgumentException();

  private:
    /** Name of operation. */
    std::wstring mOpName;
};

/**
 * An operator encountered in the MetraFlow script has incorrectly
 * specified arguments.
 */
class DataflowInvalidArgumentsException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param lineNumber  line number where error occurs
     * @param columnNumber column number where error occurs
     * @param opName      name of operation instance
     * @param expected    a phrase explaining expected values (example: 
     *                  Argument 'probe' must be specified.)
     */
    METRAFLOW_DECL DataflowInvalidArgumentsException(
                                      int lineNumber,
                                      int columnNumber,
                                      const std::wstring &filename,
                                      const std::wstring &opName,
                                      const std::wstring &reason);
    /** Destructor */
    METRAFLOW_DECL ~DataflowInvalidArgumentsException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getOperationName() const;

  private:
    DataflowInvalidArgumentsException();

  private:
    /** Name of operation. */
    std::wstring mOpName;
};

/**
 * An operator has been redefined.
 */
class DataflowRedefinedOperatorException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param opName              name of operation being redefined
     * @param originalLineNumber  line where original defined
     * @param originalColumnNumber  column where original defined
     * @param redefinedLineNumber line where redefined
     * @param redefinedColumnNumber column where redefined
     */
    METRAFLOW_DECL DataflowRedefinedOperatorException(
                                       const std::wstring &opName,
                                       int originalLineNumber,
                                       int originalColumnNumber,
                                       const std::wstring &filename,
                                       int redefinedLineNumber,
                                       int redefinedColumnNumber);
    /** Destructor */
    METRAFLOW_DECL ~DataflowRedefinedOperatorException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getOperationName() const;

  private:
    DataflowRedefinedOperatorException();

  private:
    /** Name of operation. */
    std::wstring mOpName;
};

/**
 * An composite has been redefined.
 */
class DataflowRedefinedCompositeException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param compName            name of composite being redefined
     * @param originalLineNumber  line where original defined
     * @param originalColumnNumber  column where original defined
     * @param redefinedLineNumber line where redefined
     * @param redefinedColumnNumber column where redefined
     */
    METRAFLOW_DECL DataflowRedefinedCompositeException(
                                       const std::wstring &name,
                                       int originalLineNumber,
                                       int originalColumnNumber,
                                       const std::wstring &filename,
                                       int redefinedLineNumber,
                                       int redefinedColumnNumber);
    /** Destructor */
    METRAFLOW_DECL ~DataflowRedefinedCompositeException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getCompositeName() const;

  private:
    DataflowRedefinedCompositeException();

  private:
    /** Name of composite. */
    std::wstring mName;
};

/**
 * A step has been redefined.
 */
class DataflowRedefinedStepException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param stepName            name of step being redefined
     * @param redefinedLineNumber line where redefined
     * @param redefinedColumnNumber column where redefined
     */
    METRAFLOW_DECL DataflowRedefinedStepException(
                                       const std::wstring &name,
                                       const std::wstring &filename,
                                       int redefinedLineNumber,
                                       int redefinedColumnNumber);
    /** Destructor */
    METRAFLOW_DECL ~DataflowRedefinedStepException() throw();

    /** Get operation name. */
    METRAFLOW_DECL std::wstring getStepName() const;

  private:
    DataflowRedefinedStepException();

  private:
    /** Name of step. */
    std::wstring mName;
};

/**
 * Reference to an undefined operator.
 */
class DataflowUndefOperatorException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param opName      name of undefined operator
     * @param lineNumber  line number of error
     */
    METRAFLOW_DECL DataflowUndefOperatorException(
                                        const std::wstring &opName,
                                        int lineNumber,
                                        int columnNumber,
                                        const std::wstring &filename);
    /** Destructor */
    METRAFLOW_DECL ~DataflowUndefOperatorException() throw();

  private:
    DataflowUndefOperatorException();
};

/**
 * Reference to an undefined port.
 */
class DataflowUndefPortException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param opName      name of the operator
     * @param portName    name of the undefined port (empty string if not given)
     * @param portNumber  number of the undefined port (0 if not given)
     * @param wasReferencedAsInput  true if the port was referenced as input
     * @param lineNumber  line number of error
     */
    METRAFLOW_DECL DataflowUndefPortException(
                                        const std::wstring &opName,
                                        const std::wstring &portName,
                                        int portNumber,
                                        bool wasReferencedAsInput,
                                        int lineNumber,
                                        int columnNumber,
                                        const std::wstring &filename);
    /** Destructor */
    METRAFLOW_DECL ~DataflowUndefPortException() throw();

  private:
    DataflowUndefPortException();
};

/**
 * An arrow is referencing an undefined operator.
 */
class DataflowArrowUndefOperatorException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param opName      name of undefined operator
     * @param lineNumber  line number of error
     */
    METRAFLOW_DECL DataflowArrowUndefOperatorException(
                                        const std::wstring &opName,
                                        int lineNumber,
                                        int columnNumber,
                                        const std::wstring &filename);
    /** Destructor */
    METRAFLOW_DECL ~DataflowArrowUndefOperatorException() throw();

  private:
    DataflowArrowUndefOperatorException();
};

/**
 * The value specified for the argument for an arrow in
 * the MetraFlow script is invalid.
 */
class DataflowInvalidArrowArgumentValueException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param argName   argument name
     * @param argValue  argument value
     * @param expected  a phrase explaining expected values (Expected a or b,
     *                Expected a string)
     */
    METRAFLOW_DECL DataflowInvalidArrowArgumentValueException(
                                               int lineNumber,
                                               int columnNumber,
                                               const std::wstring &argName,
                                               const std::wstring &argValue,
                                               const std::wstring &expected,
                                               const std::wstring &filename);
    /** Destructor */
    METRAFLOW_DECL ~DataflowInvalidArrowArgumentValueException() throw();

    /** Get argument name. */
    METRAFLOW_DECL std::wstring getArgName() const;

    /** Get argument value. */
    METRAFLOW_DECL std::wstring getArgValue() const;

  private:
    DataflowInvalidArrowArgumentValueException();

  private:
    /** Name of operation argument. */
    std::wstring mArgName;

    /** Offending argument value. */
    std::wstring mArgValue;
};

/**
 * A composite port parameter has been redefined
 */
class DataflowRedefinedCompositePortParamException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param portParamName             name of arg being redefined
     * @param originalLineNumber  line where original defined
     * @param originalColumnNumber  column where original defined
     * @param redefinedLineNumber line where redefined
     * @param redefinedColumnNumber column where redefined
     */
    METRAFLOW_DECL DataflowRedefinedCompositePortParamException(
                                       const std::wstring &portParamName,
                                       int originalLineNumber,
                                       int originalColumnNumber,
                                       const std::wstring &filename,
                                       int redefinedLineNumber,
                                       int redefinedColumnNumber);
    /** Destructor */
    METRAFLOW_DECL ~DataflowRedefinedCompositePortParamException() throw();

  private:
    DataflowRedefinedCompositePortParamException();
};

/**
 * An internal error occurred during parsing.
 */
class DataflowInternalErrorException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param reason   phrase describing error.
     */
    METRAFLOW_DECL DataflowInternalErrorException(const std::wstring &reason);

    /** Destructor */
    METRAFLOW_DECL ~DataflowInternalErrorException() throw();

  private:
    DataflowInternalErrorException();
};

/**
 * An general error was encountered in the MetraFlow script.
 */
class DataflowGeneralException : public DataflowParseException
{
  public:
    /** 
     * Constructor 
     *
     * @param lineNumber   line number where error occurs
     * @param columnNumber column number where error occurs
     * @param reason       description of error
     */
    METRAFLOW_DECL DataflowGeneralException(
                                      int lineNumber,
                                      int columnNumber,
                                      const std::wstring &filename,
                                      const std::wstring &reason);
    /** Destructor */
    METRAFLOW_DECL ~DataflowGeneralException() throw();

  private:
    DataflowGeneralException();
};

#endif
