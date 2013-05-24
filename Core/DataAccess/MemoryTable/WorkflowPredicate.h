#ifndef __WORKFLOW_PREDICATE_H__
#define __WORKFLOW_PREDICATE_H__


#include <boost/filesystem/path.hpp>
#include <boost/filesystem/fstream.hpp>


/**
 * This is the abstract base class of control flow if-predicates.
 * If-predicates are functions used inside if-statements that
 * return true or false.
 */
class WorkflowPredicate
{
private:

public:
  /** Constructor */
  WorkflowPredicate();

  /** Destructor */
  ~WorkflowPredicate();

  /** 
   * Store the given string parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setStringParameter(const std::wstring& param)=0;

  /** 
   * Store the given variable parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setVariableParameter(const std::wstring& param)=0;

  /** Get a readable description of the predicate */
  virtual std::wstring toString() const =0;

  /**
   * Evaluate the predicate and return whether true or false.
   */
  virtual bool evaluate()=0;

private:
  /** Disallowed - copy constructor */
  WorkflowPredicate(const WorkflowPredicate&);

  /** Disallowed - assignment operator */
  WorkflowPredicate& operator = (const WorkflowPredicate&);
};

/**
 * DoesFileExist control flow if-instructions.
 */
class WorkflowPredicateDoesFileExist : public WorkflowPredicate
{
private:
  /** The file that may or may not be exist */
  boost::filesystem::wpath mFilename;

  /** Name of an environmental variable that will determine the file name */
  std::wstring mVariable;

  /** Readable description of predicate */
  std::wstring mDescription;

public:
  /** Constructor */
  WorkflowPredicateDoesFileExist();

  /** Destructor */
  ~WorkflowPredicateDoesFileExist();

  /**
   * Evaluate the predicate and return whether true or false.
   */
  virtual bool evaluate();

  /** 
   * Store the given string parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setStringParameter(const std::wstring& param);

  /** 
   * Store the given variable parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setVariableParameter(const std::wstring& param);

  /** Get a readable description of the predicate */
  virtual std::wstring toString() const;

private:
  /** Disallowed - copy constructor */
  WorkflowPredicateDoesFileExist(const WorkflowPredicateDoesFileExist&);

  /** Disallowed - assignment operator */
  WorkflowPredicateDoesFileExist& operator = 
                                    (const WorkflowPredicateDoesFileExist&);
};

/**
 * IsFileEmpty control flow if-instructions.
 */
class WorkflowPredicateIsFileEmpty : public WorkflowPredicate
{
private:
  /** The file that may or may not be empty */
  boost::filesystem::wpath mFilename;

  /** Name of an environmental variable that will determine the file name */
  std::wstring mVariable;

  /** Readable description of predicate */
  std::wstring mDescription;

public:
  /** Constructor */
  WorkflowPredicateIsFileEmpty();

  /** Destructor */
  ~WorkflowPredicateIsFileEmpty();

  /**
   * Evaluate the predicate and return whether true or false.
   */
  virtual bool evaluate();

  /** 
   * Store the given string parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setStringParameter(const std::wstring& param);

  /** 
   * Store the given variable parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setVariableParameter(const std::wstring& param);

  /** Get a readable description of the predicate */
  virtual std::wstring toString() const;

private:
  /** Disallowed - copy constructor */
  WorkflowPredicateIsFileEmpty(const WorkflowPredicateIsFileEmpty&);

  /** Disallowed - assignment operator */
  WorkflowPredicateIsFileEmpty& operator = 
                                    (const WorkflowPredicateIsFileEmpty&);
};

/**
 * Not control flow if-instructions.
 */
class WorkflowPredicateNot : public WorkflowPredicate
{
private:
  WorkflowPredicate *mOperand;

public:
  /** Constructor */
  WorkflowPredicateNot();

  /** Destructor */
  ~WorkflowPredicateNot();

  /**
   * Evaluate the predicate and return whether true or false.
   */
  virtual bool evaluate();

  /** 
   * Store the given string parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setStringParameter(const std::wstring& param);

  /** 
   * Store the given variable parameter that was specified
   * for the if-statement.  Use when executing. Thrown an
   * exception if this parameter is inappropriate.
   */
  virtual void setVariableParameter(const std::wstring& param);

  /** 
   * Set the operand. This class takes ownership of the pointer
   * and is responsible for freeing it.
   */
  void setOperand(WorkflowPredicate *predicate);

  /** Get a readable description of the predicate */
  virtual std::wstring toString() const;

private:
  /** Disallowed - copy constructor */
  WorkflowPredicateNot(const WorkflowPredicateNot&);

  /** Disallowed - assignment operator */
  WorkflowPredicateNot& operator = 
                                    (const WorkflowPredicateNot&);
};


#endif
