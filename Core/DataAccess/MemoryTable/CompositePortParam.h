#ifndef __COMPOSITE_PORT_PARAM_H__
#define __COMPOSITE_PORT_PARAM_H__

#include "LogAdapter.h"

/**
 * Describes an input or output port to a composite.
 */
class CompositePortParam 
{
private:
  /** 
   * True if this param is describing a range of ports.
   * Example: IN j("probe(3..*)") AS myInput
   */
  bool mIsRange;

  /** The name chosen for the composite port. */
  std::wstring mParamName;

  /** 
   * The zero-based parameter number.
   * The parameter number is unique with in the collection of
   * input or output parameters.  The parameter number should match
   * the order the parameter appears in the composite declaration
   * in the script.  It is up to the caller of the constructor to
   * enforce this.
   */
  int mParamNumber;

  /** The name of the referenced operator in the subgraph. */
  std::wstring mOperatorName;

  /** The name of the referenced port in the subgraph. */
  std::wstring mPortName;

  /** 
   * If a range, the root port name.  
   * For example: IN j("probe(3..*)") AS myInput
   * the root name is "probe".
   */
  std::wstring mRangeRootPortName;

  /** 
   * The number of the referenced port in the subgraph. 
   * If this parameter is describing a range of ports,
   * this port number is starting index that should be used.
   * Example: IN j("probe(3..*)") AS myInput
   * The starting index is 3.
   */
  int mPortNumber;

  /** True if this is an input parameter (false if output). */
  bool mIsInput;

  /**
   * True if the simplified input naming scheme is used
   * by the referenced operator in the sub-graph.
   * This applies to operators that take a dynamic number of inputs.
   * If true, a single input is referred to as "input" rather
   * than "input(0)".
   */
  bool mIsSimplifiedInputNamingUsed;

  /** The line,column where the parameter name was specified. */
  int mParamNameLine;
  int mParamNameCol;

  /** The line,column where the operator name was specified. */
  int mOpLine;
  int mOpCol;

  /** The line,column where the operator port was specified. */
  int mOpPortLine;
  int mOpPortCol;

public:
  /** 
   * Constructor 
   *
   * @param parameterNumber   This should be 0-based and unique
   *                          within the collection of input or output
   *                          ports.  The number should match the order
   *                          of appearance in the composite declaration.
   */
  CompositePortParam(const std::wstring& parameterName,
               int parameterNumber,
               const std::wstring& operatorName,
               const std::wstring& portName,
               int portNumber,
               bool isInput,
               int parameterNameLine, int parameterNameCol,
               int opNameLine, int opNameCol,
               int opPortLine, int opPortCol);

  /** Destructor */
  ~CompositePortParam();

  /** Get the parameter name */
  const std::wstring& getParamName() const;

  /**
   * If this is a range parameter, then get the port name for
   * the given index (0-based) in the range.  
   * For example: IN j("probe(3..*)") AS myInput
   * getRangeParamName(2) would return "myInput(2)".
   * If this is not a range parameter then an empty string is returned.
   */
  std::wstring getParamNameInRange(int index) const;

  /** 
   * Get the number of ports specifically referenced by this parameter.
   * If range parameter, returns 0 (it is unknown how many actual
   * ports will be used by the caller of the composite).
   * Otherwise, returns 1.
   */
  int getNumberOfPortsReferenced() const;

  /** Get the referenced operator name */
  const std::wstring& getOperatorName() const;

  /** Get the referenced operator port name */
  const std::wstring& getOperatorPortName() const;

  /** 
   * Get the number of this parameter.
   */
  int getParamNumber() const;

  /** Get the referenced operator's port number */
  int getOperatorPortNumber() const;

  /** Is it an input parameter? */
  bool isInput() const;

  /** Is the parameter name valid? */
  bool isParamNameValid() const;

  /** Is this parameter describing a range of ports? */
  bool isRange() const;

  /** Is the simplified input naming scheme used? */
  bool isSimplifiedInputNamingUsed() const;

  /** 
   * For a range parameter, get the root of the referenced
   * operator port name.  Returns empty string if not a range parameter.
   * For example: IN j("probe(3..*)") AS myInput
   * the root name is "probe".  
   */
  std::wstring getOperatorPortNameRoot() const;

  /** Get the line where the parameter name was specified */
  int getParamNameLine() const;
  int getParamNameCol() const;

  /** Get the line where the parameter operator was specified */
  int getOpLine() const;
  int getOpCol() const;

  /** Get the line where the parameter operator port was specified */
  int getOpPortLine() const;
  int getOpPortCol() const;

  /**
   * If this is a range parameter, then get the port name for
   * the given index (0-based) in the range.  
   * For example: IN j("probe(3..*)") AS myInput
   * getRangePortName(2) would return "probe(5)".
   * If this is not a range parameter then an empty string is returned.
   */
  std::wstring getPortNameInRange(int index) const;

  /** Set is the simplified input naming scheme used to true */
  void setIsSimplifiedInputNamingUsed();

  /** Set the name of the port referenced by this parameter */
  void setPortName(const std::wstring& paramName);

  /** Set the number of the port referenced by this parameter */
  void setPortNumber(int portNumber);

  /** Set the referenced operator name */
  void setOperatorName(const std::wstring& opName);

private:
  /** Disallowed */
  CompositePortParam();

  /** Disallowed */
  CompositePortParam(const CompositePortParam&);

  /** Disallowed */
  CompositePortParam& operator = (const CompositePortParam&);
};

#endif
