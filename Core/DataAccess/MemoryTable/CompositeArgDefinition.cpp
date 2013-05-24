
#include <iostream>
#include "CompositeArgDefinition.h"

CompositeArgDefinition::CompositeArgDefinition(
                           const std::wstring& name,
                           OperatorArgType argType,
                           int line, int col)
 : mName(name),
   mType(argType),
   mLine(line),
   mCol(col)
{
}

CompositeArgDefinition::~CompositeArgDefinition()
{
}

OperatorArgType CompositeArgDefinition::getType() const
{
  return mType;
}

const std::wstring& CompositeArgDefinition::getName() const
{
  return mName;
}

int CompositeArgDefinition::getLine() const
{
  return mLine;
}

int CompositeArgDefinition::getCol() const
{
  return mCol;
}
