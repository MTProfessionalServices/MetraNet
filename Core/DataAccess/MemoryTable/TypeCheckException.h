#ifndef __TYPE_CHECK_EXCEPTION_H
#define __TYPE_CHECK_EXCEPTION_H

#include "MetraFlowConfig.h"
#include "DataflowException.h"

class DesignTimeOperator;
class Port;
class DatabaseColumn;
class PhysicalFieldType;
class DataflowScriptInterpreter;

/**
 * The abstract base class for type-checking exceptions.
 * Type-check exceptions occur during execution of the
 * DesignTimePlan::type_check().
 */
class TypeCheckException : public DataflowException
{
  public:
    /** 
     * Constructor 
     */
    METRAFLOW_DECL TypeCheckException();

    /** Destructor */
    METRAFLOW_DECL ~TypeCheckException() throw();

    /** Get a displayable message describing the exception.*/
    METRAFLOW_DECL std::wstring getMessage() const;

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                    DataflowScriptInterpreter &interpreter)=0;
};

/**
 * Generic exception class for exceptions emanating from a single
 * operator.
 */
class SingleOperatorException : public TypeCheckException
{
public:
  /** 
   * Constructor 
   */
  METRAFLOW_DECL SingleOperatorException(const DesignTimeOperator & op,
                                         const std::wstring& message);
  
  /** Destructor */
  METRAFLOW_DECL ~SingleOperatorException() throw();

  /** Get a displayable message describing the exception.*/
  METRAFLOW_DECL std::wstring getMessage() const;

  /**
   * Add line and column numbers to the exception message.
   *
   * @param interpreter  the interpreter of the script hold in the
   *                     symbol tables.
   */
  METRAFLOW_DECL virtual void addLineNumbers(
    DataflowScriptInterpreter &interpreter);
private:
  /**
   * Form the error message using the line and column number
   *
   * @param opLineNumber  line number of operator or -1 if not known.
   * @param opColumnNumber  column number of operator or -1 if not known.
   */
  void formMessage(int opLineNumber, int opColumnNumber);

  const DesignTimeOperator & mOp;
  std::wstring mMessageFormat;
};

/**
 * A required input port to an operator is not connected.
 */
class PortUnconnectedException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL PortUnconnectedException(
                             const DesignTimeOperator &op,
                             const Port& port,
                             bool  isInputPort);
    /** Destructor */
    METRAFLOW_DECL ~PortUnconnectedException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                  DataflowScriptInterpreter &interpreter);

  private:
    PortUnconnectedException();

    /**
     * Form the error message using the line and column number
     *
     * @param opLineNumber  line number of operator or -1 if not known.
     * @param opColumnNumber  column number of operator or -1 if not known.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPort;
    bool mIsInputPort;
};

/**
 * A parallel partitioner must be connected to a collector.
 */
class ParallelPartitionerConnectException : 
                                    public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL ParallelPartitionerConnectException(
                                        const DesignTimeOperator &source,
                                        const DesignTimeOperator &target);
    /** Destructor */
    METRAFLOW_DECL ~ParallelPartitionerConnectException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                        DataflowScriptInterpreter &interpreter);

  private:
    ParallelPartitionerConnectException();

    /**
     * Form the error message using the line and column numbers.
     */
    void formMessage(int sourceLineNumber,
                     int sourceColumnNumber,
                     int targetLineNumber,
                     int targetColumnNumber);
    
  private:
    const DesignTimeOperator &mSource;
    const DesignTimeOperator &mTarget;
};

/**
 * A parallel collector must be connected to a partitioner.
 */
class ParallelCollectorConnectException : 
                                    public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL ParallelCollectorConnectException(
                                      const DesignTimeOperator &source,
                                      const DesignTimeOperator &target);
    /** Destructor */
    METRAFLOW_DECL ~ParallelCollectorConnectException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                      DataflowScriptInterpreter &interpreter);

  private:
    ParallelCollectorConnectException();

    /**
     * Form the error message using the line and column numbers.
     */
    void formMessage(int sourceLineNumber,
                     int sourceColumnNumber,
                     int targetLineNumber,
                     int targetColumnNumber);
    
  private:
    const DesignTimeOperator &mSource;
    const DesignTimeOperator &mTarget;
};

/**
 * A partitioner must be used to connect a sequential operator to a 
 * parallel operator.
 */
class SeqToParallelConnectException : public TypeCheckException
{
  public:
    /**
     * Constructor
     *
     * @param source  a sequential operator
     * @param target  a parallel operator
     */
    METRAFLOW_DECL SeqToParallelConnectException(
                                    const DesignTimeOperator &source,
                                    const DesignTimeOperator &target);
    /** Destructor */
    METRAFLOW_DECL ~SeqToParallelConnectException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                    DataflowScriptInterpreter &interpreter);

  private:
    SeqToParallelConnectException();

    /**
     * Form the error message using the line and column numbers.
     */
    void formMessage(int sourceLineNumber,
                     int sourceColumnNumber,
                     int targetLineNumber,
                     int targetColumnNumber);
    
  private:
    const DesignTimeOperator &mSource;
    const DesignTimeOperator &mTarget;
};

/**
 * A partitioner must be used to connect a sequential operator to a 
 * parallel operator.
 */
class ParallelToSeqConnectException : public TypeCheckException
{
  public:
    /**
     * Constructor
     *
     * @param source  a parallel operator
     * @param target  a sequential operator
     */
    METRAFLOW_DECL ParallelToSeqConnectException(
                                        const DesignTimeOperator &source,
                                        const DesignTimeOperator &target);
    /** Destructor */
    METRAFLOW_DECL ~ParallelToSeqConnectException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                        DataflowScriptInterpreter &interpreter);

  private:
    ParallelToSeqConnectException();

    /**
     * Form the error message using the line and column numbers.
     */
    void formMessage(int sourceLineNumber,
                     int sourceColumnNumber,
                     int targetLineNumber,
                     int targetColumnNumber);
    
  private:
    const DesignTimeOperator &mSource;
    const DesignTimeOperator &mTarget;
};

/**
 * After type-checking a port is found to have no metadata.
 */
class PortHasNoMetadataException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL PortHasNoMetadataException(const DesignTimeOperator &op,
                                              const Port& port);
    /** Destructor */
    METRAFLOW_DECL ~PortHasNoMetadataException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                        DataflowScriptInterpreter &interpreter);

  private:
    PortHasNoMetadataException();

    /**
     * Form the error message using the line and column number
     *
     * @param opLineNumber  line number of operator or -1 if not known.
     * @param opColumnNumber  column number of operator or -1 if not known.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPort;
};

/**
 * After type-checking the source of a port, the port
 * is found to have no metadata.
 */
class PortHasNoMetadataSourceException : public TypeCheckException
{
  public:
    /**
     * Constructor
     *
     * @param ownerOp   operator owning the port
     * @param sourceOp  source of port
     */
    METRAFLOW_DECL PortHasNoMetadataSourceException(
                               const DesignTimeOperator &ownerOp,
                               const DesignTimeOperator &sourceOp,
                               const Port& port);
    /** Destructor */
    METRAFLOW_DECL ~PortHasNoMetadataSourceException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                      DataflowScriptInterpreter &interpreter);

  private:
    PortHasNoMetadataSourceException();

    /**
     * Form the error message using the line and column number
     */
    void formMessage(int ownerLineNumber,
                     int ownerColumnNumber,
                     int sourceOpLineNumber,
                     int sourceOpColumnNumber);
    
  private:
    const DesignTimeOperator &mOwnerOp;
    const DesignTimeOperator &mSourceOp;
    const Port &mPort;
};

/**
 * Indicates that keys have not been configured a port of an operator.
 */
class MissingKeyException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL MissingKeyException(const DesignTimeOperator &op,
                                       const Port &port);
    /** Destructor */
    METRAFLOW_DECL ~MissingKeyException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                        DataflowScriptInterpreter &interpreter);

  private:
    MissingKeyException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPort;
};

/**
 * An error occured compiling MTSQL
 */
class MtsqlCompilationException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL MtsqlCompilationException(const DesignTimeOperator &op);

    /** Destructor */
    METRAFLOW_DECL ~MtsqlCompilationException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                        DataflowScriptInterpreter &interpreter);

  private:
    MtsqlCompilationException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
};

/**
 * Indicates that two ports do not have the same number of keys.
 */
class KeySizeMismatchException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL KeySizeMismatchException(const DesignTimeOperator &op,
                                            const Port &portA,
                                            const Port &portB);
    /** Destructor */
    METRAFLOW_DECL ~KeySizeMismatchException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                        DataflowScriptInterpreter &interpreter);

  private:
    KeySizeMismatchException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPortA;
    const Port &mPortB;
};

/**
 * Indicates that a referenced field does not exit on an input port.
 */
class MissingFieldException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL MissingFieldException(const DesignTimeOperator &op,
                                         const Port &port,
                                         const std::wstring& fieldName);
    /** Destructor */
    METRAFLOW_DECL ~MissingFieldException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                        DataflowScriptInterpreter &interpreter);

  private:
    MissingFieldException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPort;
    std::wstring mFieldName;
};

/**
 * Thrown in the type checking phase to indicate that a field to be created already exists in a record.
 */
class FieldAlreadyExistsException : public TypeCheckException
{
private:
  const DesignTimeOperator &mOp;
  const Port &mPort;
  std::wstring mFieldName;

  /**
   * Form the error message using the line and column number.
   */
  void formMessage(int opLineNumber, int opColumnNumber);

public:
  /**
   * Constructor
   */
  METRAFLOW_DECL FieldAlreadyExistsException(const DesignTimeOperator& op, const Port& port, const std::wstring& name);

  /**
   * Destructor
   */
  METRAFLOW_DECL ~FieldAlreadyExistsException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                      DataflowScriptInterpreter &interpreter);

};

/**
 * Indicates that a field does not have an expected/hard-coded type
 */
class FieldTypeException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL FieldTypeException(const DesignTimeOperator &op,
                                      const Port &port,
                                      const DatabaseColumn& colA,
                                      const PhysicalFieldType& expectedType);
    /** Destructor */
    METRAFLOW_DECL ~FieldTypeException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                      DataflowScriptInterpreter &interpreter);

  private:
    FieldTypeException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPort;
    const DatabaseColumn& mColA;
    const PhysicalFieldType& mExpectedType;
};

/**
 * Indicates that two fields do not have the same data type.
 */
class FieldTypeMismatchException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL FieldTypeMismatchException(
                               const DesignTimeOperator &op,
                               const Port &portA,
                               const DatabaseColumn& colA,
                               const Port &portB,
                               const DatabaseColumn& colB);
    /** Destructor */
    METRAFLOW_DECL ~FieldTypeMismatchException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(DataflowScriptInterpreter &interpreter);

  private:
    FieldTypeMismatchException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPortA;
    const Port &mPortB;
    const DatabaseColumn& mColA;
    const DatabaseColumn& mColB;
};

/**
 * Indicates that two inputs do not have the same record format.
 */
class RecordTypeMismatchException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL RecordTypeMismatchException(
                                const DesignTimeOperator &op,
                                const Port &portA,
                                const Port &portB);
    /** Destructor */
    METRAFLOW_DECL ~RecordTypeMismatchException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                      DataflowScriptInterpreter &interpreter);

  private:
    RecordTypeMismatchException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPortA;
    const Port &mPortB;
};

/**
 * Indicates that there is a circular reference to a composite.
 */
class CircularCompositeReferenceException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL CircularCompositeReferenceException(
                                          const std::wstring& compositeName);

    /** Destructor */
    METRAFLOW_DECL ~CircularCompositeReferenceException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(DataflowScriptInterpreter &interpreter);

  private:
    CircularCompositeReferenceException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);

  private:
    /** Name of composite being circularlly referred to. */
    std::wstring mCompositeName;
};

/**
 * Reference to a non-existent composite port.
 */
class CompositeUndefPortException : public TypeCheckException
{
  public:
    /**
     * Constructor
     */
    METRAFLOW_DECL CompositeUndefPortException(
                                const DesignTimeOperator &op,
                                const Port &port,
                                const std::wstring &compositePortName);
    /** Destructor */
    METRAFLOW_DECL ~CompositeUndefPortException() throw();

    /**
     * Add line and column numbers to the exception message.
     *
     * @param interpreter  the interpreter of the script hold in the
     *                     symbol tables.
     */
    METRAFLOW_DECL virtual void addLineNumbers(
                                      DataflowScriptInterpreter &interpreter);

  private:
    CompositeUndefPortException();

    /**
     * Form the error message using the line and column number.
     */
    void formMessage(int opLineNumber, int opColumnNumber);
    
  private:
    const DesignTimeOperator &mOp;
    const Port &mPort;
    std::wstring mCompositePortName;
};

#endif
