#ifndef __COMPOSITE_DICTIONARY_H__
#define __COMPOSITE_DICTIONARY_H__

#include "CompositeDefinition.h"
#include "LogAdapter.h"

class DesignTimePlan;

/**
 * A dictionary of all composite definitions.
 */
class CompositeDictionary 
{
private:
  /** Logger */
  MetraFlowLoggerPtr mLogger;

  /**
   * A map of composite name to definition.
   * This class owns all the composite definition
   * and is responsible for freeing them.
   */
  std::map<std::wstring, CompositeDefinition *> mDictionary;

public:
  /** Constructor */
  CompositeDictionary();

  /** Destructor */
  ~CompositeDictionary();

  /**
   * Add the composite name to the dictionary.  If the composite
   * already had an entry in the dictionary (unexpected), 
   * then the prior definition is removed.
   *
   * @param definition  definition of composite.  Ownership of definition
   *                    passes to the dictionary.
   */
  void add(CompositeDefinition *definition);

  /**
   * Get the definition of the given composite name.
   * If not found, a null pointer is returned (unexpected).
   *
   * @param  name  Name of a composite.
   * @return definition or null if not found.
   */
  CompositeDefinition* getDefinition(const std::wstring &name);

  /**
   * Is the given composite defined to have the given argument?
   */
  bool doesArgExist(const std::wstring &compositeName,
                    const std::wstring &argName);

  /**
   * Get the argument type for the given argument according to the
   * definition.
   */
  OperatorArgType getArgType(const std::wstring &compositeName,
                             const std::wstring &argName);

  /**
   * Does the given composite have a definition?
   *
   * @param  name  Name of a composite.
   * @return true  if there is a definition.
   */
  bool isDefined(const wchar_t* name);

  /**
   * Remove the definition of the given composite name.
   * from the dictionary.  If the given composite is not
   * in the dictionary, nothing is done.
   *
   * @param  name  Name of a composite.
   */
  void removeDefinition(const std::wstring &name);
  
  /** 
   * Set the design time plan for the composite.
   * The composite must already exist in the dictionary.  If not,
   * this method ignores the request (unexpected).
   * The ownership of the plan is given to the composite definition.
   * This method also completes final bookkeeping for the definition.
   * This bookkeeping includes:
   * verifying that the input/output parameter do not refer to
   * non-existant operator or ports.
   * For all composites, this also normalizes the composite arguments, ensuring
   * that both port name and number are set, and marks the operator
   * port as being an argument to a composite
   * 
   * @param name  name of the composite.
   * @param plan  design time plan for the composite.
   */
  void setDesignTimePlan(const std::wstring &name,
                         DesignTimePlan* plan);

  /** 
   * Set the symbol table for the composite.
   * The composite must already exist in the dictionary.  If not,
   * this method ignores the request (unexpected).
   * The ownership of the symbol table is given to the composite definition.
   * 
   * @param name         name of the composite.
   * @param symbolTable  symbol table of composite operators.
   */
  void setSymbolTable(const std::wstring &name,
                      std::map<std::wstring, DataflowSymbol>* symbolTable);

  /** 
   * Set the symbol table for the composite.
   * The ownership of the symbol table is given to the composite definition.
   * Updates the symbol table input/output port counts to reflect
   * composite parameters.  This must be done before actually 
   * constructing any operators (since some depend on input/output count)
   * withing the composite design time plan.
   * 
   * @param name         name of the composite.
   * @param symbolTable  symbol table of composite operators.
   */
  void setSymbolTableAndUpdateForComposite(
                      const std::wstring &name,
                      std::map<std::wstring, DataflowSymbol>* symbolTable);
  /** 
   * Get the symbol table for the composite.
   * 
   * @param name  name of the composite.
   */
  std::map<std::wstring, DataflowSymbol>* getSymbolTable(
                                                const std::wstring &name);

  /**
   * Verify that all the ports are connected within the
   * composite definitions in the dictionary.
   * Throws a DataflowException on error.
   */
  void verifyAllPortsConnected();

private:
  /** Disallowed */
  CompositeDictionary(const CompositeDictionary&);

  /** Disallowed */
  CompositeDictionary& operator = (const CompositeDictionary&);
};

/** 
 * Symbol table of composites.
 * Map of composite instance name to composite definition.
 * This is a temporary map that is used between the DataflowParser
 * and DataflowTreeGeneratorStage.
 */
typedef std::map<std::wstring, const CompositeDefinition*> ReferencedComposites;

#endif
