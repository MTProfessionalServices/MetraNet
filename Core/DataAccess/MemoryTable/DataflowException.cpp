#include "DataflowException.h"
#include "ScriptInterpreter.h"

#include <sstream>

DataflowException::DataflowException() :
  mMessage(L""),
  mLineNumber(0),
  mColumnNumber(0),
  mFilename(L"")
{
}

DataflowException::~DataflowException() throw()
{
}

std::wstring DataflowException::getMessage() const
{
  return mMessage;
}

int DataflowException::getLineNumber() const
{
  return mLineNumber;
}

int DataflowException::getColumnNumber() const
{
  return mColumnNumber;
}

DataflowParseException::DataflowParseException()
{
}

DataflowParseException::~DataflowParseException() throw()
{
}

std::wstring DataflowParseException::getMessage() const
{
  return mMessage;
}

DataflowCompositeParamNameException::
    DataflowCompositeParamNameException(
                               const std::wstring &compName,
                               const std::wstring &paramName,
                               bool wasReferencedAsInput,
                               int lineNumber,
                               int columnNumber,
                               const std::wstring &filename)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;
  std::wstring paramType = L"output";

  if (wasReferencedAsInput)
  {
      paramType = L"input";
  }

  out << L"Error: " << mFilename << L" "
      << L" (line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L"In definition of composite " << compName << L", " << paramType
      << L" parameter name \"" << paramName << L"\" is invalid. A parameter "
      << L"name must not contain '('";

  mMessage = out.str();
}

DataflowCompositeParamNameException::
    ~DataflowCompositeParamNameException() throw()
{
}
DataflowCompositeRangeParamException::
    DataflowCompositeRangeParamException(
                               const std::wstring &compName,
                               const std::wstring &portName,
                               bool wasReferencedAsInput,
                               int lineNumber,
                               int columnNumber,
                               const std::wstring &filename)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;
  std::wstring paramType = L"output";

  if (wasReferencedAsInput)
  {
      paramType = L"input";
  }

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L"In definition of composite " << compName << L", " << paramType
      << L" parameter \"" << portName << L"\" defines a range of ports "
      << L"and must therefore appear as the last " << paramType << L" parameter.";

  mMessage = out.str();
}

DataflowCompositeRangeParamException::
    ~DataflowCompositeRangeParamException() throw()
{
}

DataflowInvalidArgumentValueException::
    DataflowInvalidArgumentValueException(int lineNumber,
                                          int columnNumber,
                                          const std::wstring &filename,
                                          const std::wstring &opName,
                                          const std::wstring &argName,
                                          const std::wstring &argValue,
                                          const std::wstring &expected)
      : mOpName(opName),
        mArgName(argName),
        mArgValue(argValue)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Operator: "    << mOpName
      << L", Argument: "   << mArgName
      << L". The value "    << mArgValue 
      << L" is not acceptable. " << expected;

  mMessage = out.str();
}

DataflowInvalidArgumentValueException::
    ~DataflowInvalidArgumentValueException() throw()
{
}

std::wstring DataflowInvalidArgumentValueException::getOperationName() const
{
  return mOpName;
}

std::wstring DataflowInvalidArgumentValueException::getOperationArgName() const
{
  return mArgName;
}

std::wstring DataflowInvalidArgumentValueException::getOperationArgValue() const
{
  return mArgValue;
}

DataflowInvalidArgumentException::
    DataflowInvalidArgumentException(int lineNumber,
                                     int columnNumber,
                                     const std::wstring &filename,
                                     const std::wstring &opName,
                                     const std::wstring &argName)
      : mOpName(opName)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Operator: "    << mOpName
      << L". Unrecognized argument: "    << argName 
      << L".";

  mMessage = out.str();
}

DataflowInvalidArgumentException::
    ~DataflowInvalidArgumentException() throw()
{
}

std::wstring DataflowInvalidArgumentException::getOperationName() const
{
  return mOpName;
}

DataflowInvalidArgumentsException::
    DataflowInvalidArgumentsException(int lineNumber,
                                      int columnNumber,
                                      const std::wstring &filename,
                                      const std::wstring &opName,
                                      const std::wstring &reason)
      : mOpName(opName)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Operator: " << mOpName << L".  " 
      << reason;

  mMessage = out.str();
}

DataflowInvalidArgumentsException::
    ~DataflowInvalidArgumentsException() throw()
{
}

std::wstring DataflowInvalidArgumentsException::getOperationName() const
{
  return mOpName;
}

DataflowRedefinedOperatorException::
    DataflowRedefinedOperatorException(const std::wstring &opName,
                                       int originalLineNumber,
                                       int originalColumnNumber,
                                       const std::wstring &filename,
                                       int redefinedLineNumber,
                                       int redefinedColumnNumber)
      : mOpName(opName)
{
  mLineNumber = redefinedLineNumber;
  mColumnNumber = redefinedColumnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Operator " << mOpName << L" has already been defined on line " 
      << originalLineNumber << L".";

  mMessage = out.str();
}

DataflowRedefinedOperatorException::
    ~DataflowRedefinedOperatorException() throw()
{
}

DataflowRedefinedCompositePortParamException::
    DataflowRedefinedCompositePortParamException(const std::wstring &argName,
                                       int originalLineNumber,
                                       int originalColumnNumber,
                                       const std::wstring &filename,
                                       int redefinedLineNumber,
                                       int redefinedColumnNumber)
{
  mLineNumber = redefinedLineNumber;
  mColumnNumber = redefinedColumnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Composite argument " << argName 
      << L" has already been defined on line " 
      << originalLineNumber << L".";

  mMessage = out.str();
}

DataflowRedefinedCompositePortParamException::
    ~DataflowRedefinedCompositePortParamException() throw()
{
}

DataflowRedefinedCompositeException::
    DataflowRedefinedCompositeException(const std::wstring &name,
                                       int originalLineNumber,
                                       int originalColumnNumber,
                                       const std::wstring &filename,
                                       int redefinedLineNumber,
                                       int redefinedColumnNumber)
      : mName(name)
{
  mLineNumber = redefinedLineNumber;
  mColumnNumber = redefinedColumnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Composite " << mName << L" has already been defined on line " 
      << originalLineNumber << L".";

  mMessage = out.str();
}

DataflowRedefinedCompositeException::
    ~DataflowRedefinedCompositeException() throw()
{
}

std::wstring DataflowRedefinedCompositeException::getCompositeName() const
{
  return mName;
}

DataflowRedefinedStepException::
    DataflowRedefinedStepException(const std::wstring &name,
                                   const std::wstring &filename,
                                   int redefinedLineNumber,
                                   int redefinedColumnNumber)
      : mName(name)
{
  mLineNumber = redefinedLineNumber;
  mColumnNumber = redefinedColumnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Step " << mName << L" has already been defined. ";

  mMessage = out.str();
}

DataflowRedefinedStepException::
    ~DataflowRedefinedStepException() throw()
{
}

std::wstring DataflowRedefinedStepException::getStepName() const
{
  return mName;
}

DataflowUndefOperatorException::
    DataflowUndefOperatorException(const std::wstring &opName,
                                   int lineNumber,
                                   int columnNumber,
                                   const std::wstring &filename)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Reference to undefined operator: " << opName << L".";

  mMessage = out.str();
}

DataflowUndefOperatorException::
    ~DataflowUndefOperatorException() throw()
{
}

DataflowUndefPortException::
    DataflowUndefPortException(const std::wstring &opName,
                               const std::wstring &portName,
                               int portNumber,
                               bool wasReferencedAsInput,
                               int lineNumber,
                               int columnNumber,
                               const std::wstring &filename)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Operator " << opName << L" does not have an ";
  if (wasReferencedAsInput)
  {
      out << L"input";
  }
  else
  {
      out << L"output";
  }

  if (portName.size() > 0)
  {
    out << L" named " << portName << L".";
  }
  else
  {
    out << L" numbered " << portNumber << L".";
  }

  mMessage = out.str();
}

DataflowUndefPortException::
    ~DataflowUndefPortException() throw()
{
}

DataflowArrowUndefOperatorException::
    DataflowArrowUndefOperatorException(const std::wstring &opName,
                                        int lineNumber,
                                        int columnNumber,
                                        const std::wstring &filename)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" An arrow is referencing undefined operator: " << opName << L".";

  mMessage = out.str();
}

DataflowArrowUndefOperatorException::
    ~DataflowArrowUndefOperatorException() throw()
{
}

DataflowInvalidArrowArgumentValueException::
    DataflowInvalidArrowArgumentValueException(int lineNumber,
                                               int columnNumber,
                                               const std::wstring &filename,
                                               const std::wstring &argName,
                                               const std::wstring &argValue,
                                               const std::wstring &expected)
      : mArgName(argName),
        mArgValue(argValue)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"):"
      << L" Arrow argument: " << mArgName
      << L". The value "     << mArgValue 
      << L" is not acceptable. " << expected;

  mMessage = out.str();
}

DataflowInvalidArrowArgumentValueException::
    ~DataflowInvalidArrowArgumentValueException() throw()
{
}

std::wstring DataflowInvalidArrowArgumentValueException::getArgName() const
{
  return mArgName;
}

std::wstring DataflowInvalidArrowArgumentValueException::getArgValue() const
{
  return mArgValue;
}

DataflowInternalErrorException::
    DataflowInternalErrorException(const std::wstring &reason)
{
  mMessage = reason;
}

DataflowInternalErrorException::
    ~DataflowInternalErrorException() throw()
{
}

DataflowGeneralException::DataflowGeneralException(int lineNumber,
                                                   int columnNumber,
                                                   const std::wstring &filename,
                                                   const std::wstring &reason)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
  std::wstringstream out;

  out << L"Error: " << mFilename << L" "
      << L"(line " << mLineNumber << L" col " << mColumnNumber << L"): "
      << reason;

  mMessage = out.str();
}

DataflowGeneralException::
    ~DataflowGeneralException() throw()
{
}
