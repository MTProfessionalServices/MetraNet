#include <iostream> 

#include "DesignTimeComposite.h"
#include "CompositeDefinition.h"
#include "OperatorArg.h"
#include "ArgEnvironment.h"

DesignTimeComposite::DesignTimeComposite(const std::wstring& compositeDefnName)
  :
  mCompositeDefnName(compositeDefnName)
{
}

DesignTimeComposite::DesignTimeComposite(const CompositeDefinition* defn,
                                         int neededNumberOfInputs,
                                         int neededNumberOfOutputs)
{
  mCompositeDefnName = defn->getName();

  // By using the definition of the composite, 
  // we can create the input and output ports.

  createPorts(defn, true, mInputPorts, neededNumberOfInputs);
  createPorts(defn, false, mOutputPorts, neededNumberOfOutputs);
}

DesignTimeComposite::~DesignTimeComposite()
{
  for (std::vector<OperatorArg*>::iterator it=mArgs.begin();
       it != mArgs.end(); it++)
  {
    delete *it;
  }
}

void DesignTimeComposite::handleArg(const OperatorArg& arg)
{
  ASSERT(0);  // This should never be called.
}

DesignTimeComposite* DesignTimeComposite::clone(
                                   const std::wstring& name,
                                   std::vector<OperatorArg*>& placeholderArgs,
                                   int nInputs, int nOutputs) const
{
  DesignTimeComposite* result = new DesignTimeComposite(mCompositeDefnName);

  result->SetName(name);

  // We do not copy pending arguments because there's not a concept
  // of pending arguments for placeholders (see dataflow_generate.g
  // where the DesignTimeComposite is construct for details).

  // Copy the ports
  int i = 0;
  PortCollection& inputPorts = result->GetInputPorts();
  for (PortCollection::const_iterator it=mInputPorts.begin();
                                      it != mInputPorts.end(); it++)
  {
    inputPorts.insert(result, i, (*it)->GetName(), false);
    i++;
  }

  i = 0;
  PortCollection& outputPorts = result->GetOutputPorts();
  for (PortCollection::const_iterator it=mOutputPorts.begin();
                                      it != mOutputPorts.end(); it++)
  {
    outputPorts.insert(result, i, (*it)->GetName(), false);
    i++;
  }

  ArgEnvironment* argEnvironment = ArgEnvironment::getActiveEnvironment();

  // Copy the arguments
  for (std::vector<OperatorArg*>::const_iterator it=mArgs.begin();
       it != mArgs.end(); it++)
  {
    OperatorArg* orgArg = (*it);

    // Resolve any variables in the arguments
    bool found = false;
    OperatorArg* arg;

    switch (orgArg->getType())
    {
      case OPERATOR_ARG_TYPE_STRING:
        arg = new OperatorArg(*orgArg);

        if (arg->isThereAnEmbeddedArg())
        {
          // For each embedded argument, attempt to find
          // a replacement for it.
          const std::vector<std::wstring> embeddedArgs = arg->getEmbeddedArgs();
          
          for (unsigned int i=0; i<embeddedArgs.size(); i++)
          {
            std::wstring replacementValue = argEnvironment->getValue(
                                                    embeddedArgs[i],
                                                    placeholderArgs);
            arg->replaceEmbeddedArg(embeddedArgs[i], replacementValue);
          }
        }

        result->addArg(arg);
        break;

      case OPERATOR_ARG_TYPE_VARIABLE:
        for (std::vector<OperatorArg*>::iterator i=placeholderArgs.begin();
             i != placeholderArgs.end(); i++)
        {
          OperatorArg* placeholderDefinedArg = *i;
   
          if (orgArg->getStringValue().compare(
              placeholderDefinedArg->getName()) == 0)
          {
            // Before handling the argument, we need the name of the
            // argument to match the true operator argument name.
            // For example, if this operator was specified as
            // "print[numToPrint=@myCompArg]" and arg's name is "myCompArg",
            // then we must handle this argument, but change the name
            // to "numToPrint" -- this is what the operator understands.
            OperatorArg* arg = new OperatorArg(*placeholderDefinedArg);
            arg->setName(orgArg->getName());
            result->addArg(arg);
            found = true;
          }
        }

        if (!found)
        {
          // Unfortunately, the placeholder for the composite
          // didn't define the argument.  We need to now check
          // our environment for the value to use.  We want to form
          // an OperatorArg whose type matches the definition.

          arg = argEnvironment->getValueAsOperatorArg(
                                  orgArg->getName(),
                                  orgArg->getVarType());

          if (arg != NULL)
          {
            arg->setName(orgArg->getStringValue());
            result->addArg(arg);
            continue;
          }
        }

        break;

      default:
        arg = new OperatorArg(*orgArg);
        result->addArg(arg);
    }
  }

  return result;
}

void DesignTimeComposite::createPorts(
          const CompositeDefinition* defn,
          bool isInput,
          PortCollection &ports,
          int neededNumberOfPorts)
{
  for (unsigned int j=0; j<defn->getNumberOfParameters(isInput); j++)
  {
     CompositePortParam* param = defn->getParameter(isInput, j);

    // If the parameter describes a simple parameter (not a range)
    // we just create a port for the place holder.
    if (!param->isRange())
    {
      ports.insert(this, param->getParamNumber(), param->getParamName(), false);
    }
    else
    {
      // We know that this range parameter is the last parameter
      // of the composite (enforced in CompositeDefinition::finalizeBookkeeping
      // Given the total number of inputs (or outputs) there should be,
      // we need to create a range of input (or output) ports.

      int numberToCreate = neededNumberOfPorts - ports.size();
      for (int i=0; i<numberToCreate; i++)
      {
        ports.insert(this, param->getParamNumber() + i, param->getParamNameInRange(i), false);
      }
    }
  }
}

METRAFLOW_DECL void DesignTimeComposite::type_check()
{
}

METRAFLOW_DECL RunTimeOperator * DesignTimeComposite::code_generate(
                                                partition_t maxPartition)
{
   return 0;
}

void DesignTimeComposite::addArg(OperatorArg* arg)
{
  mArgs.push_back(arg);
}

std::vector<OperatorArg*>& DesignTimeComposite::getArgs()
{
  return mArgs;
}

const std::wstring& DesignTimeComposite::getCompositeDefinitionName() const
{
  return mCompositeDefnName;
}

