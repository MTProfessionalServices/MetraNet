#include <iostream>
#include <sstream>

#include "CompositeDefinition.h"
#include "DataflowException.h"
#include "DesignTimeComposite.h"
#include "CompositeDictionary.h"
#include "Scheduler.h"

CompositeDefinition::CompositeDefinition(const std::wstring &filename)
  : mName(L""),
    mSymbolTable(NULL),
    mPlan(NULL),
    mLineNumber(0),
    mColumnNumber(0),
    mFilename(filename)
{
  mLogger = MetraFlowLoggerManager::GetLogger("[CompositeDefinition]");
}

CompositeDefinition::~CompositeDefinition()
{
  if (mSymbolTable != NULL)
  {
    delete mSymbolTable;
  }

  if (mPlan != NULL)
  {
    delete mPlan;
  }

  for (std::map<std::wstring, CompositePortParam*>::const_iterator 
       it = mInputs.begin();
       it != mInputs.end();
       it++)
  {
    delete it->second;
  }

  for (std::map<std::wstring, CompositePortParam*>::const_iterator 
       it = mOutputs.begin();
       it != mOutputs.end();
       it++)
  {
    delete it->second;
  }

  for (std::map<std::wstring, CompositeArgDefinition*>::const_iterator 
       it = mArgs.begin();
       it != mArgs.end();
       it++)
  {
    delete it->second;
  }
}

void CompositeDefinition::addArg(
                OperatorArgType argType,
                const std::wstring& argName,
                int argLine, int argCol)
{
  CompositeArgDefinition* arg = new CompositeArgDefinition(
                                       argName,
                                       argType,
                                       argLine, argCol);
  mArgs[argName] = arg;
}

void CompositeDefinition::addInput(
                std::wstring paramName,
                std::wstring operatorName,
                std::wstring operatorPortName,
                int operatorPortNumber,
                int paramNameLine, int paramNameCol,
                int opNameLine, int opNameCol,
                int opPortLine, int opPortCol )
{
  // Check if the name already appears as an input
  if (mInputs.find(paramName) != mInputs.end())
  {
    CompositePortParam* oldParam = mInputs[paramName];
    throw DataflowRedefinedCompositePortParamException(paramName,
                                                 oldParam->getParamNameLine(),
                                                 oldParam->getParamNameCol(),
                                                 mFilename,
                                                 paramNameLine,
                                                 paramNameCol);
  }

  // Add the input
  int paramNumber = mInputs.size();
  CompositePortParam* param = new CompositePortParam(paramName, paramNumber,
                                       operatorName, operatorPortName, 
                                       operatorPortNumber, true,
                                       paramNameLine, paramNameCol,
                                       opNameLine, opNameCol,
                                       opPortLine, opPortCol);
  mInputs[paramName] = param;
  mInputsIndex.push_back(param);
}

void CompositeDefinition::addOutput(
                std::wstring paramName,
                std::wstring operatorName,
                std::wstring operatorPortName,
                int operatorPortNumber,
                int paramNameLine, int paramNameCol,
                int opNameLine, int opNameCol,
                int opPortLine, int opPortCol )
{
  // Check if the paramName already appears in the table.
  // If so, ignore the paramName.
  if (mOutputs.find(paramName) != mOutputs.end())
  {
    CompositePortParam* oldParam = mInputs[paramName];
    throw DataflowRedefinedCompositePortParamException(paramName,
                                                 oldParam->getParamNameLine(),
                                                 oldParam->getParamNameCol(),
                                                 mFilename,
                                                 paramNameLine,
                                                 paramNameCol);
  }

  // Add the output
  int paramNumber = mOutputs.size();
  CompositePortParam* param = new CompositePortParam(paramName, paramNumber,
                                       operatorName, operatorPortName, 
                                       operatorPortNumber, false,
                                       paramNameLine, paramNameCol,
                                       opNameLine, opNameCol,
                                       opPortLine, opPortCol);
  mOutputs[paramName] = param;
  mOutputsIndex.push_back(param);
}

bool CompositeDefinition::doesArgExist(const std::wstring &argName) const
{
  return (mArgs.find(argName) != mArgs.end());
}

OperatorArgType CompositeDefinition::getArgType(
                                            const std::wstring &argName) const
{
  if (mArgs.find(argName) == mArgs.end())
  {
    // Well, we didn't find it. So just return this...
    mLogger->logError(L"Unexpectedly failed to find argument: " + argName);
    return OPERATOR_ARG_TYPE_STRING;
  }
  
  const CompositeArgDefinition *argDefn = (*(mArgs.find(argName))).second;
  return argDefn->getType();
}

void CompositeDefinition::finalizeBookkeeping()
{
  finalizeBookkeeping(mInputs);
  finalizeBookkeeping(mOutputs);
}

void CompositeDefinition::finalizeBookkeeping(
          std::map<std::wstring, CompositePortParam*> &params)
{
  std::wstring opName;

  // Iterate through the input and output parameters
  int paramCount = 0;
  for (std::map<std::wstring, CompositePortParam*>::const_iterator 
       it = params.begin();
       it != params.end();
       it++)
  {
    paramCount++;
    CompositePortParam* param = it->second;

    // Check if the parameter name is valid.
    if (param->isParamNameValid())
    {
      throw DataflowCompositeParamNameException(
              mName, param->getParamName(), param->isInput(),
              param->getParamNameLine(), param->getParamNameCol(),
              mFilename);
    }

    // Mark referenced operator/ports as being composite parameters.
    std::wstring opName = param->getOperatorName();
    std::wstring portName = param->getOperatorPortName();
    int portNumber = param->getOperatorPortNumber();
  
    // Find the composite referenced operator in the subgraph
    DataflowSymbolTable::iterator itSym(mSymbolTable->find(opName));
    if (itSym == mSymbolTable->end())
    {
      throw DataflowUndefOperatorException(opName, 
                                         param->getOpLine(), param->getOpCol(),
                                         mFilename);
    }
    DesignTimeOperator* op = itSym->second.Op;

    // Check if this parameter defines a range ports (rather than a 
    // specific port).  
    if (param->isRange())
    {
      if (param->isInput() 
          && op->isSimplifiedInputNamingUsed() 
          && param->getParamName().compare(L"input"))
      {
        param->setIsSimplifiedInputNamingUsed();
      }

      // A range parameter must always be the very last parameter (and
      // there can only be one of them).  This is so that references to a
      // composite port in the main script by using a number (rather than
      // by name) has a defined meaning.
      if (param->getParamNumber()+1 != params.size())
      {
        throw DataflowCompositeRangeParamException(
                mName, param->getOperatorPortName(), 
                param->isInput(),
                param->getOpPortLine(), param->getOpPortCol(),
                mFilename);
      }

      // Range ports are not instantiated in the composite
      // sub-graph definition.  Therefore, there is no more
      // checking to be done.
      continue;
    }

    // If we reach this point, the parameter refers to a specific port.
    // Find the composite referenced operator port
    bool foundIt = false;
    int portIndex = -1;
    boost::shared_ptr<Port> port;
    if (param->isInput())
    {
      for(PortCollection::iterator pit=(op)->GetInputPorts().begin();
          !foundIt && pit != (op)->GetInputPorts().end();
          pit++)
      {
        portIndex++;
        port = *pit;
  
        foundIt = 
          ((portName.size() > 0 && port->GetName().compare(portName) == 0) ||
           (portName.size() <= 0 && portNumber == portIndex));
      }
    }
    else
    {
      for(PortCollection::iterator pit=(op)->GetOutputPorts().begin();
          !foundIt && pit != (op)->GetOutputPorts().end();
          pit++)
      {
        portIndex++;
        port = *pit;

        foundIt = 
          ((portName.size() > 0 && port->GetName().compare(portName) == 0) ||
           (portName.size() <= 0 && portNumber == portIndex));
      }
    }

    if (!foundIt)
    {
      throw DataflowUndefPortException(
                opName, portName, portNumber,
                param->isInput(), 
                param->getOpPortLine(), param->getOpPortCol(),
                mFilename);
    }

    // Ensure that both the port number and port name are set for all arguments
    param->setPortNumber(portIndex);
    param->setPortName(port->GetName());
  
    // Mark this port as a parameter.  This is needed for verifying
    // that all ports are connected (except the parameter ports).
    port->SetAsCompositeParameter();
  }
}

DesignTimePlan& CompositeDefinition::getDesignTimePlan() const
{
  if (mPlan == NULL)
  {
    mLogger->logError("Unexpectedly encountered null design time plan.");
    ASSERT(true);
  }

  return *mPlan;
}

const CompositePortParam* CompositeDefinition::getInputPortParam(
                                                        std::wstring name)
{
  if (mInputs.find(name) == mInputs.end())
  {
    return NULL;
  }

  return mInputs[name];
}

void CompositeDefinition::getInputPortParam(
                              const std::wstring &name,
                              const PortCollection *inputPorts,
                              std::wstring &opName,
                              std::wstring &opPortName)
{
  opName = L"";
  opPortName = L"";

  // Check if the parameter name is an instance of a dynamic reference.
  if (isInstanceOfRangeParameter(name, true, 
                                 inputPorts,
                                 opName, opPortName))
  {
    return;
  }

  const CompositePortParam* arg = mInputs[name];
  opName = arg->getOperatorName();
  opPortName = arg->getOperatorPortName();
}

const CompositePortParam* CompositeDefinition::getOutputPortParam(std::wstring name)
{
  if (mOutputs.find(name) == mOutputs.end())
  {
    return NULL;
  }

  return mOutputs[name];
}

void CompositeDefinition::getOutputPortParam(
                              const std::wstring &name,
                              std::wstring &opName,
                              std::wstring &opPortName)
{
  opName = L"";
  opPortName = L"";

  // Check if the parameter name is an instance of a dynamic reference.
  if (isInstanceOfRangeParameter(name, false, NULL, opName, opPortName))
  {
    return;
  }

  const CompositePortParam* arg = mOutputs[name];
  opName = arg->getOperatorName();
  opPortName = arg->getOperatorPortName();
}

int CompositeDefinition::getLineNumber() const
{
  return mLineNumber;
}

const std::wstring& CompositeDefinition::getName() const
{
  return mName;
}

int CompositeDefinition::getColumnNumber() const
{
  return mColumnNumber;
}


unsigned int CompositeDefinition::getNumberOfParameters(bool isInput) const
{
  if (isInput)
  {
    return mInputs.size();
  }

  return mOutputs.size();
}

CompositePortParam* CompositeDefinition::getParameter(bool isInput,
                                                      int i) const
{
  if (isInput)
  {
    if (i < 0 || (unsigned int) i >= mInputsIndex.size())
    {
      mLogger->logError("Unexpectedly encountered illegal parameter index.");
      ASSERT(true);
      return NULL;
    }

    return mInputsIndex[i];
  }
  else
  {
    if (i < 0 || (unsigned int) i >= mOutputsIndex.size())
    {
      mLogger->logError("Unexpectedly encountered illegal parameter index.");
      ASSERT(true);
      return NULL;
    }

    return mOutputsIndex[i];
  }
}

DataflowSymbolTable* CompositeDefinition::getSymbolTable() const
{
  return mSymbolTable;
}

bool CompositeDefinition::isInstanceOfRangeParameter(
                                      const std::wstring& instanceName,
                                      bool isInputParam,
                                      std::wstring& compositeOpName) const
{
  bool isRangeParameter;
  int instanceNumber;
  std::wstring instanceNameRoot;
  std::wstring compositePortRootName;
  int compositePortStartingNumber;
  bool compositeIsSimplifiedInputNamingUsed;

  analyzeInstanceOfRangeParameter(instanceName,
                                  isInputParam,
                                  isRangeParameter,
                                  instanceNumber,
                                  instanceNameRoot,
                                  compositeOpName,
                                  compositePortRootName,
                                  compositePortStartingNumber,
                                  compositeIsSimplifiedInputNamingUsed);
  return isRangeParameter;
}
                                    
bool CompositeDefinition::isInstanceOfRangeParameter(
                                      const std::wstring& instanceName,
                                      bool isInputParam,
                                      const PortCollection* ports,
                                      std::wstring& compositeOpName,
                                      std::wstring& compositeOpPortName) const
{
  bool isRangeParameter;
  int instanceNumber;
  std::wstring instanceNameRoot;
  std::wstring compositePortRootName;
  int compositePortStartingNumber;
  bool compositeIsSimplifiedInputNamingUsed;

  compositeOpPortName = L"";

  analyzeInstanceOfRangeParameter(instanceName,
                                  isInputParam,
                                  isRangeParameter,
                                  instanceNumber,
                                  instanceNameRoot,
                                  compositeOpName,
                                  compositePortRootName,
                                  compositePortStartingNumber,
                                  compositeIsSimplifiedInputNamingUsed);
  if (!isRangeParameter)
  {
    return false;
  }

  int number = compositePortStartingNumber + instanceNumber;

  // Form the standard name
  std::wstringstream out;
  out << compositePortRootName << L"(" << number << L")";
  compositeOpPortName = out.str();

  // There is a special case when we are given a placeholder
  // composite port name that corresponds to an operator port
  // input(0) in the composite and the operator uses the
  // simplified naming scheme and there is only one input!
  // In this case, the operator
  // port is referred to as "input" rather than "input(0)".

  if (number > 0 || 
      !compositeIsSimplifiedInputNamingUsed ||
      compositePortRootName.compare(L"input") != 0 ||
      ports == NULL)
  {
    return true;
  }

  // Unfortunately, we are going to have to check if we have
  // more than one input or not.  If more than one, then the 
  // name is "input(0)", otherwise it is "input".  

  int nFound = 0;
  std::wstring lookFor = instanceNameRoot + L"(";

  for (PortCollection::const_iterator it=ports->begin();
       it != ports->end() && nFound < 2; it++)
  {
    std::wstring portName = (*it)->GetName();
      
    size_t pos = portName.find(lookFor);
    if (pos != string::npos)
    {
      nFound++;
    }
  }

  if (nFound >= 2)
  {
    return true;
  }
  
  // Use the special name!
  compositeOpPortName = L"input";

  return true;
}

void CompositeDefinition::analyzeInstanceOfRangeParameter(
                              const std::wstring& instanceName,
                              bool isInputParam,
                              bool &isRangeParameter,
                              int &instanceNumber,
                              std::wstring &instanceNameRoot,
                              std::wstring &compositeOpName,
                              std::wstring &compositePortRootName,
                              int &compositePortStartingNumber,
                              bool &compositeIsSimplifiedInputNamingUsed) const
{
  isRangeParameter = false;
  instanceNumber = 0;
  instanceNameRoot = L"";
  compositeOpName = L"";
  compositePortRootName = L"";
  compositePortStartingNumber = 0;
  
  size_t nLeftParen = instanceName.find(L"(");
  size_t nRightParen = instanceName.find(L")");
  if (nLeftParen == string::npos || nRightParen - nLeftParen - 1 <= 0)
  {
    return;
  }

  instanceNameRoot = instanceName.substr(0, nLeftParen);
  std::wstring wNumber = instanceName.substr(nLeftParen+1, 
                                             nRightParen-nLeftParen-1); 
  std::wstringstream s(wNumber);
  if (!(s >> instanceNumber))
  {
    return;
  }

  const CompositePortParam *arg = NULL;
  if (isInputParam && mInputs.find(instanceNameRoot) != mInputs.end())
  {
    arg = mInputs.find(instanceNameRoot)->second;
  }
  else if (!isInputParam && mOutputs.find(instanceNameRoot) != mOutputs.end())
  {
    arg = mOutputs.find(instanceNameRoot)->second;
  }

  if (arg == NULL)
  {
    ASSERT(true);
    return;
  }

  compositeOpName = arg->getOperatorName();
  compositePortRootName = arg->getOperatorPortNameRoot();
  compositePortStartingNumber = arg->getOperatorPortNumber();
  compositeIsSimplifiedInputNamingUsed = arg->isSimplifiedInputNamingUsed();

  isRangeParameter = true;
  return;
}

void CompositeDefinition::setLocation(int lineNumber, int columnNumber,
                                      const std::wstring& filename)
{
  mLineNumber = lineNumber;
  mColumnNumber = columnNumber;
  mFilename = filename;
}

void CompositeDefinition::setName(const std::wstring& name)
{
  mName = name;
}

void CompositeDefinition::setSymbolTable(DataflowSymbolTable* symbolTable)
{
  if (mSymbolTable != NULL)
  {
    delete mSymbolTable;
  }

  mSymbolTable = symbolTable;
}

void CompositeDefinition::setDesignTimePlan(DesignTimePlan* plan)
{
  if (mPlan != NULL)
  {
    delete mPlan;
  }

  mPlan = plan;
}

void CompositeDefinition::verifyAllPortsConnected()
{
  mPlan->verifyAllPortsConnected();
}


void CompositeDefinition::updateSymbolTableBasedOnParameters()
{
  updateSymbolTableBasedOnParameters(mInputs);
  updateSymbolTableBasedOnParameters(mOutputs);
}

void CompositeDefinition::updateSymbolTableBasedOnParameters(
          std::map<std::wstring, CompositePortParam*> &params)
{
  std::wstring opName;

  // Iterate through the parameters
  for (std::map<std::wstring, CompositePortParam*>::const_iterator 
       it = params.begin();
       it != params.end();
       it++)
  {
    CompositePortParam* param = it->second;

    opName = param->getOperatorName();
  
    // Find the referenced operator
    DataflowSymbolTable::iterator itSym(mSymbolTable->find(opName));
    if (itSym == mSymbolTable->end())
    {
      throw DataflowUndefOperatorException(
              opName, param->getOpLine(), param->getOpCol(),
              mFilename);
    }

    // Update the number of input or outputs to the operator
    // based on the parameter.  Example IN j("input(0)") references 1 input
    // but IN j("input(*)") references 0 inputs (because we don't know
    // if the actual composite use will use these inputs or not.
    if (param->isInput())
    {
      itSym->second.NumInputs += param->getNumberOfPortsReferenced();
    }
    else
    {
      itSym->second.NumOutputs += param->getNumberOfPortsReferenced();
    }
  }
}
