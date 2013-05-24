#ifndef __WORKFLOW_INSTRUCTION_IF_H__
#define __WORKFLOW_INSTRUCTION_IF_H__

#include "WorkflowInstruction.h"

class WorkflowPredicate; 

/**
 * This is the abstract base class of control flow if-instructions.
 * An if instruction is used to conditional execute
 * a group of statements in the control flow
 */
class WorkflowInstructionIf : public WorkflowInstruction
{
private:
  /** 
   * If predicate is NOT true, the number of instructions the
   * counter should advance.
   */
  boost::int32_t mNumberToJump;

  /** The predicate */
  WorkflowPredicate *mPredicate;

public:
  /** 
   * Constructor
   *
   * @param workflow      Workflow containing the instruction.
   * @description         Description of step for reporting
   */
  WorkflowInstructionIf(Workflow *workflow,
                        const std::wstring& description);

  /** Destructor */
  ~WorkflowInstructionIf();

  /** 
   * Execute the instruction.
   * After executing, the program counter must be set to the next
   * instruction to execute (typically just increased by one).
   *
   * @return false on failure
   */
  virtual bool execute();

  /**
   * Set the number of instructions to advance the counter by
   * if the predicate evaluates to false.
   */
  void setNumberToJump(boost::int32_t numberToJump);

  /**
   * Set the predicate for this if-statement.  The if-statement
   * takes ownership of the predicate and is resonsible for
   * deleting it.
   */
  void setPredicate(WorkflowPredicate* predicate);

private:
  /** Disallowed - default constructor */
  WorkflowInstructionIf();

  /** Disallowed - copy constructor */
  WorkflowInstructionIf(const WorkflowInstructionIf&);

  /** Disallowed - assignment operator */
  WorkflowInstructionIf& operator = (const WorkflowInstructionIf&);
};

/**
 * This is a control flow jump instruction.  If is generated
 * as part of constructing a control-flow if statement.
 */
class WorkflowInstructionJump : public WorkflowInstruction
{
private:
  /** The number of instructions to jump forward by. */
  boost::int32_t mNumberToJump;

public:
  /** 
   * Constructor
   *
   * @param workflow      Workflow containing the instruction.
   * @description         Description of step for reporting
   */
  WorkflowInstructionJump(Workflow *workflow,
                          const std::wstring& description);

  /** Destructor */
  ~WorkflowInstructionJump();

  /** 
   * Increase the program counter by the jump amount.
   *
   * @return always returns true
   */
  virtual bool execute();

  /**
   * Set the number of instructions to advance the counter by.
   */
  void setNumberToJump(boost::int32_t numberToJump);

private:
  /** Disallowed - default constructor */
  WorkflowInstructionJump();

  /** Disallowed - copy constructor */
  WorkflowInstructionJump(const WorkflowInstructionJump&);

  /** Disallowed - assignment operator */
  WorkflowInstructionJump& operator = (const WorkflowInstructionJump&);
};
#endif
