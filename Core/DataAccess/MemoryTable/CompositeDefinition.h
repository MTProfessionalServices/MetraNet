#ifndef __COMPOSITE_DEFINITION_H__
#define __COMPOSITE_DEFINITION_H__

#include "CompositePortParam.h"
#include "CompositeArgDefinition.h"
#include "Scheduler.h"
#include "LogAdapter.h"
#include "DataflowSymbol.h"
#include "OperatorArg.h"

class DesignTimePlan;
class CompositeDictionary;

/**
 * Contains the definition of composite.  The definition of a composite
 * is created by processing MetraFlow script containing the composite
 * definition.  The composite definition contains the names of all input
 * and output ports and the design time plan of the composite.
 * <p>
 * The CompositeDefinition contains all the information required
 * to create a DesignTimeComposite operator.  The CompositeDefinition
 * also contains enough information to ultimately expand the DesignTimeComposite
 * into a sub-graph for the design time plan.
 */
class CompositeDefinition 
{
private:
  /**
   * The name of the composite.  This is the name of the defined composite,
   * and is not the name of an individual instance.
   */
  std::wstring mName;

  /** 
   * Symbol table containing instances of design time operators. 
   * This symbol table is filled by dataflow_parser.g.
   */
  std::map<std::wstring, DataflowSymbol>* mSymbolTable;

  /** The design time plan for the composite. Filled by dataflow_generate.g */
  DesignTimePlan* mPlan;

  /** The names of the inputs to this composite. This map owns the pointers */
  std::map<std::wstring, CompositePortParam*> mInputs;

  /** A vector matching index (port number) to parameter. */
  std::vector<CompositePortParam*> mInputsIndex;

  /** The names of the outputs to this composite. This map owns the pointers */
  std::map<std::wstring, CompositePortParam*> mOutputs;

  /** A vector matching index (port number) to parameter. */
  std::vector<CompositePortParam*> mOutputsIndex;

  /** The names of the arguments to this composite. */
  std::map<std::wstring, CompositeArgDefinition*> mArgs;

  /** The line number in the script where the composite was defined. */
  int mLineNumber;

  /** The column number in the script where the composite was defined. */
  int mColumnNumber;

  /** The name of file where the composite was defined. */
  std::wstring mFilename;

  /** The logger. */
  MetraFlowLoggerPtr mLogger;

public:
  /** 
   * Constructor 
   * 
   * @param filename  Name of the file where the composite was defined.
   *                  Used for error reporting.
   */
  CompositeDefinition(const std::wstring &filename);

  /** Destructor */
  ~CompositeDefinition();

  /**
   * Adds an argument to the definition of the composite.
   *
   * @param argType    argument type
   * @param argName    name of the argument.
   * @param argLine    the line where the arg was defined
   * @param argCol     the column where the arg was defined
   */
  void addArg(OperatorArgType argType,
              const std::wstring& argName,
              int argLine,
              int argCol);
  /** 
   * Identifies an input to the composite.  The customized
   * composite port has a name and refers to an operator's node
   * in the composite sub-graph.  When this method is called,
   * the composite definition need not be complete -- there
   * is no checking of the given operator or port to see if
   * it exists. 
   *
   * @param portParamName            the customized name for this composite port
   * @param operatorName       the name of referred to operator
   * @param operatorPortName   identifies to the referred to operator node.
   *                           If not empty, takes precedence over portNumber.
   */
  void addInput(std::wstring portParamName,
                std::wstring operatorName,
                std::wstring operatorPortName,
                int operatorPortNumber,
                int portParamNameLine, int portParamNameCol,
                int opNameLine, int opNameCol,
                int opPortLine, int opPortCol);
  /** 
   * Identifies an output to the composite.  The customized
   * composite port has a name and refers to an operator's node
   * in the composite sub-graph.  When this method is called,
   * the composite definition need not be complete -- there
   * is no checking of the given operator or port to see if
   * it exists. 
   *
   * @param compositePortName  the customized name for this composite port
   * @param operatorName       the name of referred to operator
   * @param operatorPortName   identifies to the referred to operator node.
   *                           If not empty, takes precedence over portNumber.
   */
  void addOutput(std::wstring compositePortName,
                 std::wstring operatorName,
                 std::wstring operatorPortName,
                 int operatorPortNumber,
                 int portParamNameLine, int portParamNameCol,
                 int opNameLine, int opNameCol,
                 int opPortLine, int opPortCol);

  /**
   * Does the given argument exist in this composite definition?
   */
  bool doesArgExist(const std::wstring &argName) const;

  /**
   * Get the argument type of the given argument in the definition.
   */
  OperatorArgType getArgType(const std::wstring &argName) const;

  /**
   * Perform any final bookkeeping needed for the definition
   * such as marking some composite operator ports as being parameters.
   * This should be called only after setting the design time plan.
   */
  void finalizeBookkeeping();

  /** 
   * Get the name of the operator inside the composite and the
   * name of the port of the operator inside the composite,
   * referenced by the given composite port parameter.  Returns 
   * empty strings for names if not found.
   *
   * @param portParamName the name of the composite port parameter.
   *                    This name can be a dynamic name such as 
   *                    "myInput(0)" identifying parameter "input"
   *                    as in defn: "in "myInput" is j("input(*)")"
   * @param inputPorts  Unfortunately, the names of the other input
   *                    ports influences the name of the given port.
   *                    Namely, if there is more than one "input" port,
   *                    the created name maybe "input" or "input(0)".
   *                    This parameter is the input ports to the place
   *                    holder composite.
   * @param operatorName set to the composite operator name.
   *                    In the example above, this would be "j".
   * @param operatorPortName  set to the composite operator port name
   *                    In the example above, this might be "input(0)"
   */
  void getInputPortParam(const std::wstring &portParamName,
                         const PortCollection *inputPorts,
                         std::wstring &operatorName,
                         std::wstring &operatorPortName);

  /** 
   * Get the number of parameters
   *
   * @param isInput   if true, number of input parameters returned,
   *                  if false, number of output parameters.
   */
  unsigned int getNumberOfParameters(bool isInput) const;

  /** 
   * Get the name of the operator inside the composite and the
   * name of the port of the operator inside the composite,
   * referenced by the given composite port parameter.  Returns 
   * empty strings for names if not found.
   *
   * @param paramName   the name of parameter in the definition.
   *                    This name can be a dynamic name such as 
   *                    "myOutput(0)" identifying parameter "output"
   *                    as in defn: "in "myOutput" is j("output(*)")"
   * @param operatorName set to the composite operator name.
   *                    In the example above, this would be "j".
   * @param operatorPortName  set to the composite operator port name
   *                    In the example above, this might be "output(0)"
   */
  void getOutputPortParam(const std::wstring &portParamName,
                          std::wstring &operatorName,
                          std::wstring &operatorPortName);
  /** Get line number */
  int getLineNumber() const;

  /** Get column number */
  int getColumnNumber() const;

  /** Get the symbol table for the composite. */
  DataflowSymbolTable* getSymbolTable() const;

  /** Get the design time plan of the definition. */
  DesignTimePlan& getDesignTimePlan() const;

  /** Get the name of the composite */
  const std::wstring& getName() const;

  /** Get the port parameter identified by the given parameter number. */
  CompositePortParam* getParameter(bool isInput, int i) const;

  /**
   * Given a port name used in a placeholder composite reference,
   * check if this port name is referring to an instance of
   * a dynamic range parameter to the composite.  If so, 
   * return true and the composite operator name
   * An example: given definition: IN "myProbe" is j("probe(1..*")", 
   * "myProbe(2)" would return true, "j".
   */
  bool isInstanceOfRangeParameter(const std::wstring &paramName,
                                  bool isInputParam,
                                  std::wstring &compositeOpName) const;

  /** Set the location of where in a file the composite was defined. */
  void setLocation(int lineNumber, int columnNumber, 
                   const std::wstring& filename);

  /** Set the name of the definition. */
  void setName(const std::wstring& name);

  /** 
   * Set the design time plan for the composite.
   * Takes ownership of the pointer and is responsible for freeing it.
   */
  void setDesignTimePlan(DesignTimePlan* plan);

  /** 
   * Set the symbol table for the composite.
   * Takes ownership of the pointer and is responsible for freeing it.
   */
  void setSymbolTable(std::map<std::wstring, DataflowSymbol>* symbolTable);

  /**
   * Update the input/output counts in the symbol table
   * based on the composite parameters. In other words,
   * if a composite parameter mentions an input(output)
   * port for an operator, then that operator's input(output)
   * count must be updated.
   */
  void updateSymbolTableBasedOnParameters();

  /**
   * Verify that all the ports are connected within the
   * composite definition.
   * Throws a DataflowException if this is not true.
   */
  void verifyAllPortsConnected();

private:
  /** Disallowed */
  CompositeDefinition();

  /** Disallowed */
  CompositeDefinition(const CompositeDefinition&);

  /** Disallowed */
  CompositeDefinition& operator = (const CompositeDefinition&);

  /**
   * Given a port name used in a placeholder composite reference,
   * check if this port name is referring to an instance of
   * a dynamic range parameter to the composite.  If so, 
   * return various information.
   * An example: given definition: IN j("probe(1..*") as "myProbe", 
   * "myProbe(2)" would return true, instanceNumber=2, 
   * instanceNameRoot=myProbe, compositeOpName=j, 
   * compositePortRootName=probe, compositePortStartingNumber=1
   */
  void analyzeInstanceOfRangeParameter(
                             const std::wstring& instanceName,
                             bool isInputParam,
                             bool &isRangeParameter,
                             int &instanceNumber,
                             std::wstring &instanceNameRoot,
                             std::wstring &compositeOpName,
                             std::wstring &compositePortRootName,
                             int &compositePortStartingNumber,
                             bool &compositeIsSimplifiedInputNamingUsed) const;
  /**
   * Perform any final bookkeeping needed for the definition
   * such as marking some composite operator ports as being parameters.
   * This should be called only after set the design time plan.
   */
  void finalizeBookkeeping(
                    std::map<std::wstring, CompositePortParam*> &params);
  /** 
   * Get the input parameter identified by the parameter name. 
   * May return NULL if parameter is not found (unexpected).
   */
  const CompositePortParam* getInputPortParam(std::wstring portParamName);

  /** 
   * Get the output parameter identified by the parameter name. 
   * May return NULL if parameter is not found (unexpected).
   */
  const CompositePortParam* getOutputPortParam(std::wstring portParamName);

  /**
   * Given a port name used in a placeholder composite reference,
   * check if this port name is referring to an instance of
   * a dynamic range parameter to the composite.  If so, 
   * return true and the composite operator name and 
   * appropriate port name.
   * An example: given definition: IN j("probe(1..*") as "myProbe", 
   * "myProbe(2)" would return true, instanceNumber=2, 
   * instanceNameRoot=myProbe, compositeOpName=j, 
   * compositeOpPortName=probe(3).
   *
   * @param ports       Should be non-null is isInputParam is true.
   *                    Unfortunately, the names of the other 
   *                    ports influences the name of the given port.
   *                    Namely, if there is more than one "input" port,
   *                    the created name maybe "input" or "input(0)".
   */
  bool isInstanceOfRangeParameter(const std::wstring &paramName,
                                  bool isInputParam,
                                  const PortCollection* ports,
                                  std::wstring &compositeOpName,
                                  std::wstring &compositeOpPortName) const;
  /**
   * Using the given parameter, identify the corresponding port
   * in the sub-graph defining the composite.
   * If unable to identify the port (bad name or number), an exception 
   * is thrown. We will also updated out composite parameter definition
   * to contain both the number and the name of the port.
   * <p>
   * Mark the port as being a composite parameter.  This is needed when
   * analyzing if all ports in composite that should be connected
   * actually are.
   * <p>
   * Throws a DataflowException if the parameter refers to
   * a non-existent operator/port name in the sub-graph.
   */
  void markOperatorPortAsParameter(CompositePortParam& arg);

  /**
   * Update the input/output counts in the symbol table
   * based on the composite parameters.
   */
  void updateSymbolTableBasedOnParameters(
                    std::map<std::wstring, CompositePortParam*> &params);
};

#endif
