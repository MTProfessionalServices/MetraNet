#ifndef __DESIGN_TIME_COMPOSITE_H__
#define __DESIGN_TIME_COMPOSITE_H__

#include "Scheduler.h"

class CompositeDefinition;
class CompositePortParam;
class OperatorArg;

/**
 * The DesignTimeComposite is inserted into a design time plan
 * at parsing time. After some basic error checking is performed,
 * but before type-checking, this operator is replaced with
 * the sub-graph corresponding to the composite.
 */
class DesignTimeComposite : public DesignTimeOperator
{
private:
  /** The name of the composite definition being referenced. */
  std::wstring mCompositeDefnName;

  /** The arguments specified for the composite. */
  std::vector<OperatorArg *> mArgs;

protected:
  /**
   * Constructor.  This constructor is for code generated composites.  This constructor
   * does not set up the mInputPorts and mOutputPorts collections and it is the responsibility
   * of the derived class to do so.
   */
  DesignTimeComposite(const std::wstring& compositeDefnName);

public:
  /**
   * Constructor.  Given a composite definition, construct
   * a design time composite operator.
   *
   * @param definition  definition of the composite
   * @param nInputs     the number of inputs referenced in arrows to the comp.
   * @param nOutputs    the number of outputs referenced in arrows to the comp.
   */
  DesignTimeComposite(const CompositeDefinition* definition,
                      int nInputs,
                      int nOutputs);

  /** Destructor */
  ~DesignTimeComposite();

  /**
   * Not expected to be called.  This design time operator
   * is replaced with the composite sub-graph prior to type-checking.
   */
  METRAFLOW_DECL void type_check();

  /**
   * Not expected to be called.  This design time operator
   * is replaced with the composite sub-graph prior to run-time
   * code generation.
   */
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** 
   * Add an argument to this composite.  This is an argument
   * that has been specified in the declaration of this composite
   * instance. This ownership of the pointer is given to this
   * DesignTimeComposite.
   */
  void addArg(OperatorArg* arg);

  /** Get the arguments specified for this placeholder instance. */
  std::vector<OperatorArg*>& getArgs();

  /** Get the name of the composite being referenced. */
  const std::wstring& getCompositeDefinitionName() const;

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** 
   * Clone the initial configured state of an operator. 
   */
  METRAFLOW_DECL virtual DesignTimeComposite* clone(
                                     const std::wstring& name,
                                     std::vector<OperatorArg*>& args,
                                     int nInputs, int nOutputs) const;

private:
  /** 
   * Using the given the composite's definition of input (or output) ports,
   * add matching input (or output) ports to this placeholder composite
   * reference we are building.  In the simple case, for each parameter in 
   * the definition, we added a port to our composite placeholder.  In
   * the more complex case, the last composite parameter can describe
   * a range of ports.  In this case, we must create enough ports
   * to match the given needed number of ports.
   *
   * @param defn        definition of the composite
   * @param isInput     true if creating input ports (otherwise output)
   * @param ports       the input (or output) ports of this operator.
   * @param neededNumberOfPorts  the number of input (or output) ports we
   *                    ultimately need.
   */
  void createPorts(const CompositeDefinition* defn,
                   bool isInput,
                   PortCollection &ports,
                   int neededNumberOfPorts);
};

#endif
