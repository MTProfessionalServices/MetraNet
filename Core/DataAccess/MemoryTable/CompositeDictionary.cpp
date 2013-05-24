#include "CompositeDictionary.h"

CompositeDictionary::CompositeDictionary()
{
  mLogger = MetraFlowLoggerManager::GetLogger("CompositeDictionary");
}

CompositeDictionary::~CompositeDictionary()
{
  for (std::map<std::wstring, CompositeDefinition*>::iterator 
         it = mDictionary.begin(); it != mDictionary.end(); it++)
  {
    delete it->second;
  }
}

void CompositeDictionary::add(CompositeDefinition *definition)
{
  // If there's an existing definition in the dictionary
  // delete it (unexpected).
  removeDefinition(definition->getName());

  // Store the definition.
  mDictionary[definition->getName()] = definition;
}

CompositeDefinition* CompositeDictionary::getDefinition(
                                                const std::wstring & name)
{
  if (mDictionary.find(name) != mDictionary.end())
  {
    return mDictionary[name];
  }

  return NULL;
}

bool CompositeDictionary::doesArgExist(const std::wstring &compositeName,
                                       const std::wstring &argName)
{
  const CompositeDefinition* definition = getDefinition(compositeName);
  if (!definition)
  {
    return false;
  }

  return definition->doesArgExist(argName);
}

OperatorArgType CompositeDictionary::getArgType(
                                       const std::wstring &compositeName,
                                       const std::wstring &argName)
{
  const CompositeDefinition* definition = getDefinition(compositeName);
  if (!definition)
  {
    // We didn't find.  Just return this.
    mLogger->logError(L"Unexpectedly failed to find composite: "+compositeName);
    return OPERATOR_ARG_TYPE_STRING;
  }

  return definition->getArgType(argName);
}

bool CompositeDictionary::isDefined(const wchar_t* name)
{
  const CompositeDefinition* definition = getDefinition(name);

  return (definition != NULL);
}

void CompositeDictionary::removeDefinition(const std::wstring & name)
{
  if (mDictionary.find(name) != mDictionary.end())
  {
    delete mDictionary[name];
    mDictionary[name] = NULL;
  }
}

void CompositeDictionary::setDesignTimePlan(
                            const std::wstring & name,
                            DesignTimePlan* plan)
{
  if (mDictionary.find(name) == mDictionary.end())
  {
    mLogger->logError(L"Unexpectedly failed to find composite: " + name);
    return;
  }

  CompositeDefinition* defn = mDictionary[name];

  if (defn == NULL)
  {
    mLogger->logError(L"Encountered null composite definition for: " + name);
    return;
  }

  defn->setDesignTimePlan(plan);
  defn->finalizeBookkeeping();
}

DataflowSymbolTable* CompositeDictionary::getSymbolTable(
                                                  const std::wstring & name)
{
  if (mDictionary.find(name) == mDictionary.end())
  {
    mLogger->logError(L"Unexpectedly failed to find composite: " + name);
    return NULL;
  }

  CompositeDefinition* defn = mDictionary[name];

  if (defn == NULL)
  {
    mLogger->logError(L"Encountered null composite definition for: " + name);
    return NULL;
  }

  return defn->getSymbolTable();
}

void CompositeDictionary::setSymbolTable(
                            const std::wstring & name,
                            DataflowSymbolTable* symbolTable)
{
  if (mDictionary.find(name) == mDictionary.end())
  {
    mLogger->logError(L"Unexpectedly failed to find composite: " + name);
    return;
  }

  CompositeDefinition* defn = mDictionary[name];

  if (defn == NULL)
  {
    mLogger->logError(L"Encountered null composite definition for: " + name);
    return;
  }

  defn->setSymbolTable(symbolTable);
}

void CompositeDictionary::setSymbolTableAndUpdateForComposite(
                            const std::wstring & name,
                            DataflowSymbolTable* symbolTable)
{
  if (mDictionary.find(name) == mDictionary.end())
  {
    mLogger->logError(L"Unexpectedly failed to find composite: " + name);
    return;
  }

  CompositeDefinition* defn = mDictionary[name];

  if (defn == NULL)
  {
    mLogger->logError(L"Encountered null composite definition for: " + name);
    return;
  }

  defn->setSymbolTable(symbolTable);
  defn->updateSymbolTableBasedOnParameters();
}

void CompositeDictionary::verifyAllPortsConnected()
{
  for (std::map<std::wstring, CompositeDefinition*>::iterator 
         it = mDictionary.begin(); it != mDictionary.end(); it++)
  {
    (it->second)->verifyAllPortsConnected();
  }
}
