#include "TypeCheckException.h"
#include "Scheduler.h"
#include "ScriptInterpreter.h"
#include "RecordModel.h"

#include <sstream>

TypeCheckException::TypeCheckException()
{
}

TypeCheckException::~TypeCheckException() throw()
{
}

std::wstring TypeCheckException::getMessage() const
{
  return mMessage;
}

SingleOperatorException::SingleOperatorException(
  const DesignTimeOperator &op,
  const std::wstring& message)
  : mOp(op),
    mMessageFormat(message)
{
  formMessage(-1, -1);
}

SingleOperatorException::~SingleOperatorException() throw()
{
}

void SingleOperatorException::addLineNumbers(DataflowScriptInterpreter &interpreter)
{
  int lineNumber = interpreter.getLineNumber(mOp);
  int columnNumber = interpreter.getColumnNumber(mOp);
  formMessage(lineNumber, columnNumber);
}

void SingleOperatorException::formMessage(int opLineNumber,
                                             int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  out << L"Error";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L": Operator: "  << opName << L", ";

  out << mMessageFormat;

  mMessage = out.str();
}

PortUnconnectedException::PortUnconnectedException(
                                  const DesignTimeOperator &op,
                                  const Port& port,
                                  bool isInputPort)
  : mOp(op),
    mPort(port),
    mIsInputPort(isInputPort)
{
  formMessage(-1, -1);
}

PortUnconnectedException::~PortUnconnectedException() throw()
{
}

void PortUnconnectedException::addLineNumbers(
                                    DataflowScriptInterpreter &interpreter)
{
  int lineNumber = interpreter.getLineNumber(mOp);
  int columnNumber = interpreter.getColumnNumber(mOp);
  formMessage(lineNumber, columnNumber);
}

void PortUnconnectedException::formMessage(int opLineNumber,
                                           int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  out << L"Error";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L": Operator: "  << opName << L", ";

  if (mIsInputPort)
    out << L"Input";
  else
    out << L"Output";

  out << L" port: \""  << portName
      << L"\" has not been connected.";

  mMessage = out.str();
}

ParallelPartitionerConnectException::
                        ParallelPartitionerConnectException(
                                  const DesignTimeOperator &source,
                                  const DesignTimeOperator &target)
  : mSource(source),
    mTarget(target)
{
  formMessage(-1, -1, -1, -1);
}

ParallelPartitionerConnectException::
    ~ParallelPartitionerConnectException() throw()
{
}

void ParallelPartitionerConnectException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int sourceLineNumber = interpreter.getLineNumber(mSource);
  int sourceColumnNumber = interpreter.getColumnNumber(mSource);
  int targetLineNumber = interpreter.getLineNumber(mTarget);
  int targetColumnNumber = interpreter.getColumnNumber(mTarget);
  formMessage(sourceLineNumber, sourceColumnNumber,
              targetLineNumber, targetLineNumber);
}

void ParallelPartitionerConnectException::formMessage(
                                                       int sourceLineNumber,
                                                       int sourceColumnNumber,
                                                       int targetLineNumber,
                                                       int targetColumnNumber)
{
  std::wstringstream out;

  std::wstring sourceName;
   sourceName = mSource.GetName();

  std::wstring targetName;
   targetName = mTarget.GetName();

  out << L"Error: Parallel partioner \"" << sourceName << L"\"";

  if (sourceLineNumber >= 0 && sourceColumnNumber >= 0)
  {
    out << L"(line " << sourceLineNumber << L" col " << sourceColumnNumber << L")";
  }

  out << L" can only be connected to a collector.  Operator \"" 
      << targetName << L"\"";

  if (targetLineNumber >= 0 && targetColumnNumber >= 0)
  {
    out << L"(line " << targetLineNumber << L" col " << targetColumnNumber << L")";
  }

  out << L" is not a collector." << endl;

  mMessage = out.str();
}

ParallelCollectorConnectException::
                        ParallelCollectorConnectException(
                                  const DesignTimeOperator &source,
                                  const DesignTimeOperator &target)
  : mSource(source),
    mTarget(target)
{
  formMessage(-1, -1, -1, -1);
}

ParallelCollectorConnectException::
    ~ParallelCollectorConnectException() throw()
{
}

void ParallelCollectorConnectException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int sourceLineNumber = interpreter.getLineNumber(mSource);
  int sourceColumnNumber = interpreter.getColumnNumber(mSource);
  int targetLineNumber = interpreter.getLineNumber(mTarget);
  int targetColumnNumber = interpreter.getColumnNumber(mTarget);
  formMessage(sourceLineNumber, sourceColumnNumber,
             targetLineNumber, targetColumnNumber);
}

void ParallelCollectorConnectException::formMessage(
                                                       int sourceLineNumber,
                                                       int sourceColumnNumber,
                                                       int targetLineNumber,
                                                       int targetColumnNumber)
{
  std::wstringstream out;

  std::wstring sourceName;
   sourceName = mSource.GetName();

  std::wstring targetName;
   targetName = mTarget.GetName();

  out << L"Error: Parallel collector \"" << sourceName << L"\"";

  if (sourceLineNumber >= 0 && sourceColumnNumber > 0)
  {
    out << L"(line " << sourceLineNumber << L" col " << sourceColumnNumber << L")";
  }

  out << L" can only be connected to a partitioner.  Operator \"" 
      << targetName << L"\"";

  if (targetLineNumber >= 0 && targetColumnNumber >= 0)
  {
    out << L"(line " << targetLineNumber << L" col " << targetColumnNumber << L")";
  }

  out << L" is not a partitioner." << endl;

  mMessage = out.str();
}

SeqToParallelConnectException::
                        SeqToParallelConnectException(
                                  const DesignTimeOperator &source,
                                  const DesignTimeOperator &target)
  : mSource(source),
    mTarget(target)
{
  formMessage(-1, -1, -1, -1);
}

SeqToParallelConnectException::
    ~SeqToParallelConnectException() throw()
{
}

void SeqToParallelConnectException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int sourceLineNumber = interpreter.getLineNumber(mSource);
  int sourceColumnNumber = interpreter.getColumnNumber(mSource);
  int targetLineNumber = interpreter.getLineNumber(mTarget);
  int targetColumnNumber = interpreter.getColumnNumber(mTarget);
  formMessage(sourceLineNumber, sourceColumnNumber,
              targetLineNumber, targetColumnNumber);
}

void SeqToParallelConnectException::formMessage(int sourceLineNumber,
                                                int sourceColumnNumber,
                                                int targetLineNumber,
                                                int targetColumnNumber)
{
  std::wstringstream out;

  std::wstring sourceName;
   sourceName = mSource.GetName();

  std::wstring targetName;
   targetName = mTarget.GetName();

  out << L"Error: A partitioner must be used to connect sequential operator \"" 
      << sourceName << L"\"";

  if (sourceLineNumber >= 0 && sourceColumnNumber >= 0)
  {
    out << L"(line " << sourceLineNumber << L" col " << sourceColumnNumber << L")";
  }

  out << L" to parallel operator \"" << targetName << L"\"";

  if (targetLineNumber >= 0 && targetColumnNumber >= 0)
  {
    out << L"(line " << targetLineNumber << L" col " << targetColumnNumber << L")";
  }

  out << L"." << endl;

  mMessage = out.str();
}

ParallelToSeqConnectException::
                        ParallelToSeqConnectException(
                                  const DesignTimeOperator &source,
                                  const DesignTimeOperator &target)
  : mSource(source),
    mTarget(target)
{
  formMessage(-1, -1, -1, -1);
}

ParallelToSeqConnectException::
    ~ParallelToSeqConnectException() throw()
{
}

void ParallelToSeqConnectException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int sourceLineNumber = interpreter.getLineNumber(mSource);
  int sourceColumnNumber = interpreter.getColumnNumber(mSource);
  int targetLineNumber = interpreter.getLineNumber(mTarget);
  int targetColumnNumber = interpreter.getColumnNumber(mTarget);
  formMessage(sourceLineNumber, sourceColumnNumber, 
              targetLineNumber, targetColumnNumber);
}

void ParallelToSeqConnectException::formMessage(int sourceLineNumber,
                                                int sourceColumnNumber,
                                                int targetLineNumber,
                                                int targetColumnNumber)
{
  std::wstringstream out;

  std::wstring sourceName;
   sourceName = mSource.GetName();

  std::wstring targetName;
   targetName = mTarget.GetName();

  out << L"Error: A partitioner must be used to connect sequential operator \"" 
      << sourceName << L"\"";

  if (sourceLineNumber >= 0 && sourceColumnNumber >= 0)
  {
    out << L"(line " << sourceLineNumber << L" col " << sourceColumnNumber << L")";
  }

  out << L" to parallel operator \"" << targetName << L"\"";

  if (targetLineNumber >= 0 && targetColumnNumber >= 0)
  {
    out << L"(line " << targetLineNumber << L" col " << targetColumnNumber << L")";
  }

  out << L"." << endl;

  mMessage = out.str();
}

PortHasNoMetadataException::PortHasNoMetadataException(
                                  const DesignTimeOperator &op,
                                  const Port& port)
  : mOp(op),
    mPort(port)
{
  formMessage(-1, -1);
}

PortHasNoMetadataException::
    ~PortHasNoMetadataException() throw()
{
}

void PortHasNoMetadataException::addLineNumbers(
                                    DataflowScriptInterpreter &interpreter)
{
  int lineNumber = interpreter.getLineNumber(mOp);
  int columnNumber = interpreter.getColumnNumber(mOp);
  formMessage(lineNumber, columnNumber);
}

void PortHasNoMetadataException::formMessage(int opLineNumber,
                                             int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  out << L"Error";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L": Operator: "  << opName << L", ";

  out << L" port: \""  << portName
      << L"\" has no metadata after completing type-checking.";

  mMessage = out.str();
}

PortHasNoMetadataSourceException::PortHasNoMetadataSourceException(
                                  const DesignTimeOperator &ownerOp,
                                  const DesignTimeOperator &sourceOp,
                                  const Port& port)
  : mOwnerOp(ownerOp),
    mSourceOp(sourceOp),
    mPort(port)
{
  formMessage(-1, -1, -1, -1);
}

PortHasNoMetadataSourceException::
    ~PortHasNoMetadataSourceException() throw()
{
}

void PortHasNoMetadataSourceException::addLineNumbers(
                                    DataflowScriptInterpreter &interpreter)
{
  int ownerLineNumber = interpreter.getLineNumber(mOwnerOp);
  int ownerColumnNumber = interpreter.getColumnNumber(mOwnerOp);
  int sourceLineNumber = interpreter.getLineNumber(mSourceOp);
  int sourceColumnNumber = interpreter.getColumnNumber(mSourceOp);
  formMessage(ownerLineNumber, ownerColumnNumber,
              sourceLineNumber, sourceColumnNumber);
}

void PortHasNoMetadataSourceException::formMessage(int ownerLineNumber,
                                                   int ownerColumnNumber,
                                                   int sourceLineNumber,
                                                   int sourceColumnNumber)
{
  std::wstringstream out;

  std::wstring ownerOpName;
   ownerOpName = mOwnerOp.GetName();

  std::wstring sourceOpName;
   sourceOpName = mSourceOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  out << L"Error: ";

  out << L": Operator: \""  << ownerOpName << L"\"";

  if (ownerLineNumber >= 0)
  {
    out << L"(line " << ownerLineNumber << L" col " << ownerColumnNumber << L")";
  }

  out << L" port: \""  << portName
      << L"\" has no metadata after completing type-checking of "
      << L"source operator \"" << sourceOpName << L"\"";

  if (sourceLineNumber >= 0 && sourceColumnNumber >= 0)
  {
    out << L"(line " << sourceLineNumber << L" col " << sourceColumnNumber << L")";
  }

  mMessage = out.str();
}

MissingKeyException::MissingKeyException(
                                  const DesignTimeOperator &op,
                                  const Port &port)
  : mOp(op),
    mPort(port)
{
  formMessage(-1, -1);
}

MissingKeyException::
    ~MissingKeyException() throw()
{
}

void MissingKeyException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void MissingKeyException::formMessage(int opLineNumber, int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  out << L"Error: No keys have been set on port \"" << portName << L"\""
      << L" of operator \"" << opName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L".";

  mMessage = out.str();
}

MtsqlCompilationException::MtsqlCompilationException(
                                  const DesignTimeOperator &op)
  : mOp(op)
{
  formMessage(-1, -1);
}

MtsqlCompilationException::
    ~MtsqlCompilationException() throw()
{
}

void MtsqlCompilationException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void MtsqlCompilationException::formMessage(int opLineNumber, int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  out << L"Error: Unable to compile the MTSQL procedure associated with "
      << L"operator \"" << opName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L".";

  mMessage = out.str();
}

KeySizeMismatchException::KeySizeMismatchException(
                                  const DesignTimeOperator &op,
                                  const Port &portA,
                                  const Port &portB)
  : mOp(op),
    mPortA(portA),
    mPortB(portB)
{
  formMessage(-1, -1);
}

KeySizeMismatchException::
    ~KeySizeMismatchException() throw()
{
}

void KeySizeMismatchException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void KeySizeMismatchException::formMessage(int opLineNumber, int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portAName;
   portAName = mPortA.GetName();

  std::wstring portBName;
   portBName = mPortB.GetName();

  out << L"Error: The number of keys specified for input port \"" 
      << portAName << L"\""
      << L" does not match the number of keys specified for "
      << L" input port \"" << portBName << L"\""
      << L" of operator \"" << opName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L".";

  mMessage = out.str();
}

MissingFieldException::MissingFieldException(
                                  const DesignTimeOperator &op,
                                  const Port &port,
                                  const std::wstring& fieldName)
  : mOp(op),
    mPort(port)
{
   mFieldName = fieldName;

  formMessage(-1, -1);
}

MissingFieldException::
    ~MissingFieldException() throw()
{
}

void MissingFieldException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void MissingFieldException::formMessage(int opLineNumber, int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  // Get all of the field names into a string
  std::wstring fields(L"(");
  if (NULL != mPort.GetMetadata())
  {
    for(int i = 0; i < mPort.GetMetadata()->GetNumColumns(); i++)
    {
      if (i > 0) 
      {
        fields = fields + std::wstring(L", ");
      }
      std::wstring tmp = mPort.GetMetadata()->GetColumn(i)->GetName();
      fields = fields + tmp;
    }
  }
  fields = fields + std::wstring(L")");
  std::wstring fieldsStr;
   fieldsStr = fields;

  out << L"Error: Field \"" << mFieldName << L"\" referenced on "
      << L"port \"" << portName << L" " << fieldsStr << L"\" of operator \"" 
      << opName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L" does not exist.";

  mMessage = out.str();
}

FieldAlreadyExistsException::FieldAlreadyExistsException(
  const DesignTimeOperator &op,
  const Port &port,
  const std::wstring& fieldName)
  : mOp(op),
    mPort(port)
{
   mFieldName = fieldName;

  formMessage(-1, -1);
}

FieldAlreadyExistsException::
    ~FieldAlreadyExistsException() throw()
{
}

void FieldAlreadyExistsException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void FieldAlreadyExistsException::formMessage(int opLineNumber, int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  // Get all of the field names into a string
  std::wstring fields(L"(");
  if (NULL != mPort.GetMetadata())
  {
    for(int i = 0; i < mPort.GetMetadata()->GetNumColumns(); i++)
    {
      if (i > 0) 
      {
        fields = fields + std::wstring(L", ");
      }
      std::wstring tmp = mPort.GetMetadata()->GetColumn(i)->GetName();
      fields = fields + tmp;
    }
  }
  fields = fields + std::wstring(L")");
  std::wstring fieldsStr;
   fieldsStr = fields;

  out << L"Error: Field \"" << mFieldName << L"\" referenced on "
      << L"port \"" << portName << L" " << fieldsStr << L"\" of operator \"" 
      << opName << L"\" already exists";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L" does not exist.";

  mMessage = out.str();
}

FieldTypeException::FieldTypeException(
                                  const DesignTimeOperator &op,
                                  const Port &port,
                                  const DatabaseColumn& colA,
                                  const PhysicalFieldType& expectedType)
  : mOp(op),
    mPort(port),
    mColA(colA),
    mExpectedType(expectedType)
{
  formMessage(-1, -1);
}

FieldTypeException::
    ~FieldTypeException() throw()
{
}

void FieldTypeException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void FieldTypeException::formMessage(int opLineNumber, int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  std::wstring fieldName;
   fieldName = mColA.GetName();

  std::wstring expectedType;
   expectedType = mExpectedType.ToString();

  out << L"Error: Operator \"" << portName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L", field: \"" << fieldName << L"\" on port \"" << portName
      << L"\" must have the type \"" << expectedType << L"\".";

  mMessage = out.str();
}

FieldTypeMismatchException::FieldTypeMismatchException(
                                  const DesignTimeOperator &op,
                                  const Port &portA,
                                  const DatabaseColumn& colA,
                                  const Port &portB,
                                  const DatabaseColumn& colB)
  : mOp(op),
    mPortA(portA),
    mPortB(portB),
    mColA(colA),
    mColB(colB)
{
  formMessage(-1, -1);
}

FieldTypeMismatchException::
    ~FieldTypeMismatchException() throw()
{
}

void FieldTypeMismatchException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void FieldTypeMismatchException::formMessage(int opLineNumber, 
                                             int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portAName;
   portAName = mPortA.GetName();

  std::wstring portBName;
   portBName = mPortB.GetName();

  std::wstring fieldAName;
   fieldAName = mColA.GetName();

  std::wstring fieldBName;
   fieldBName = mColB.GetName();

  out << L"Error: Operator \"" << opName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L" record formats on the ports are different. The format"
      << L" must be the same. ";

  if (mPortA.GetMetadata() != NULL)
  {
    std::wstring metadataA;
     metadataA = mPortA.GetMetadata()->ToString();

    out << L"Port \"" << portAName << L"\" has format \"" << metadataA << L"\". ";
  }

  if (mPortB.GetMetadata() != NULL)
  {
    std::wstring metadataB;
     metadataB = mPortB.GetMetadata()->ToString();

    out << L"Port \"" << portBName << L"\" has format \"" << metadataB << L"\". ";
  }

  mMessage = out.str();
}

RecordTypeMismatchException::RecordTypeMismatchException(
                                  const DesignTimeOperator &op,
                                  const Port &portA,
                                  const Port &portB)
  : mOp(op),
    mPortA(portA),
    mPortB(portB)
{
  formMessage(-1, -1);
}

RecordTypeMismatchException::
    ~RecordTypeMismatchException() throw()
{
}

void RecordTypeMismatchException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void RecordTypeMismatchException::formMessage(int opLineNumber, 
                                              int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portAName;
   portAName = mPortA.GetName();

  std::wstring portBName;
   portBName = mPortB.GetName();

  out << L"Error: Record formats differ on \"" << portAName << L"\""
      << L" and on \"" << portAName << L"\""
      << L" of operator \"" << opName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L".";

  if (mPortA.GetMetadata() != NULL)
  {
    out << L"\"" << portAName << L"\"" << L" record format: ";
    std::wstring metadata;
     metadata = mPortA.GetMetadata()->ToString();
    out << metadata << L". ";
  }

  if (mPortB.GetMetadata() != NULL)
  {
    out << L"\"" << portBName << L"\"" << L" record format: ";
    std::wstring metadata;
     metadata = mPortB.GetMetadata()->ToString();
    out << metadata << L". ";
  }

  mMessage = out.str();
}

CircularCompositeReferenceException::CircularCompositeReferenceException(
                                  const std::wstring& compositeName)
{
  mCompositeName = compositeName;
  formMessage(-1, -1);
}

CircularCompositeReferenceException::
    ~CircularCompositeReferenceException() throw()
{
}

void CircularCompositeReferenceException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  // TODO Add the line numbers to the error message.
}

void CircularCompositeReferenceException::formMessage(int opLineNumber, 
                                                      int opColumnNumber)
{
  std::wstringstream out;

  out << L"Error: There is a circular reference to \"" << mCompositeName 
      << L"\" ";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L".";

  mMessage = out.str();
}

CompositeUndefPortException::CompositeUndefPortException(
                                  const DesignTimeOperator &op,
                                  const Port &port,
                                  const std::wstring& compositePortName)
  : mOp(op),
    mPort(port)
{
   mCompositePortName = compositePortName;
  formMessage(-1, -1);
}

CompositeUndefPortException::
    ~CompositeUndefPortException() throw()
{
}

void CompositeUndefPortException::addLineNumbers(
                                  DataflowScriptInterpreter &interpreter)
{
  int opLineNumber = interpreter.getLineNumber(mOp);
  int opColumnNumber = interpreter.getColumnNumber(mOp);
  formMessage(opLineNumber, opColumnNumber);
}

void CompositeUndefPortException::formMessage(int opLineNumber, 
                                              int opColumnNumber)
{
  std::wstringstream out;

  std::wstring opName;
   opName = mOp.GetName();

  std::wstring portName;
   portName = mPort.GetName();

  out << L"Error: Operator \"" << opName << L"\"";

  if (opLineNumber >= 0 && opColumnNumber >= 0)
  {
    out << L" (line " << opLineNumber << L" col " << opColumnNumber << L")";
  }

  out << L", port \"" << portName << L"\" refers to a composite port"
      << L" that does not exists (\"" << mCompositePortName << L"\").";

  mMessage = out.str();
}
