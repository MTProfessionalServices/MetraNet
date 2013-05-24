#ifndef __COMPOSITE_ARG_DEFN_H__
#define __COMPOSITE_ARG_DEFN_H__

#include "LogAdapter.h"
#include "OperatorArg.h"

/**
 * Definition of a composite argument.
 * A composite argument is defined in the composite declaration.
 */
class CompositeArgDefinition 
{
private:

  /** The argument name. */
  std::wstring mName;

  /** The argument type. */
  OperatorArgType mType;

  /** The line,column where the arg name was specified. */
  int mLine;
  int mCol;

public:
  /** 
   * Constructor 
   */
  CompositeArgDefinition(const std::wstring& name,
               OperatorArgType argType,
               int line, int col);

  /** Destructor */
  ~CompositeArgDefinition();

  /** Get the name */
  const std::wstring& getName() const;

  /** Get argument type */
  OperatorArgType getType() const;

  /** Get the line where the arg was specified */
  int getLine() const;
  int getCol() const;

private:
  /** Disallowed */
  CompositeArgDefinition();

  /** Disallowed */
  CompositeArgDefinition(const CompositeArgDefinition&);

  /** Disallowed */
  CompositeArgDefinition& operator = (const CompositeArgDefinition&);
};

#endif
