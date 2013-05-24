#ifndef __DATAFLOWSYMBOL_H__
#define __DATAFLOWSYMBOL_H__

#include <boost/shared_ptr.hpp>

/**
 * Represents an operator symbol encountered during parsing.
 * Used by the interpreter to implement a symbol table.
 */
class DataflowSymbol
{
public:
  /** Number of operator data inputs */
  boost::int32_t NumInputs;

  /** Number of operator data outputs */
  boost::int32_t NumOutputs;

  /** Line number in the script where the operator is defined */
  boost::int32_t LineNumber;

  /** Column number in the script where the operator is defined. */
  boost::int32_t ColumnNumber;

  /** The design time operator */
  class DesignTimeOperator * Op;

  /** Constructor */
  DataflowSymbol()
    :
    NumInputs(0),
    NumOutputs(0),
    LineNumber(0),
    ColumnNumber(0),
    Op(NULL)
  {
  }

  /** Destructor */
  ~DataflowSymbol()
  {
  }
};

typedef std::map<std::wstring, DataflowSymbol> DataflowSymbolTable;

#endif
