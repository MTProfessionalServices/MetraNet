
#include <iostream>
#include <sstream>

#include "LogAdapter.h"
#include "ArgEnvironment.h"
#include "WorkflowPredicate.h"

WorkflowPredicate::WorkflowPredicate()
{
}

WorkflowPredicate::~WorkflowPredicate()
{
}

WorkflowPredicateDoesFileExist::WorkflowPredicateDoesFileExist() :
  mVariable(L""),
  mDescription(L"doesFileExist")
{
  boost::filesystem::wpath mFilename(boost::filesystem::initial_path<boost::filesystem::wpath>());
}

WorkflowPredicateDoesFileExist::~WorkflowPredicateDoesFileExist()
{
}

bool WorkflowPredicateDoesFileExist::evaluate()
{
  if (mVariable.length() > 0)
  {
    ArgEnvironment* env = ArgEnvironment::getActiveEnvironment();
    std::wstring filename = env->getValue(mVariable);

    // Use the current setting of the variable to determine the filename.
    mFilename = boost::filesystem::system_complete<boost::filesystem::wpath>( 
                boost::filesystem::wpath(filename, boost::filesystem::native));
  }

  return (boost::filesystem::exists(mFilename));
}

void WorkflowPredicateDoesFileExist::setStringParameter(
                                            const std::wstring& filename)
{
  mFilename = boost::filesystem::system_complete( 
                boost::filesystem::wpath(filename, boost::filesystem::native));

  std::wstringstream sstream;
  sstream << L"doesFileExist(\"" << filename << L"\")";
  mDescription = sstream.str();
}

void WorkflowPredicateDoesFileExist::setVariableParameter(
                                            const std::wstring& variable)
{
  mVariable = variable;

  std::wstringstream sstream;
  sstream << L"doesFileExist($" << mVariable << L")";
  mDescription = sstream.str();
}

std::wstring WorkflowPredicateDoesFileExist::toString() const
{
  return mDescription;
}

WorkflowPredicateIsFileEmpty::WorkflowPredicateIsFileEmpty() :
  mVariable(L""),
  mDescription(L"isFileEmpty")
{
  boost::filesystem::wpath mFilename(boost::filesystem::initial_path<boost::filesystem::wpath>());
}

WorkflowPredicateIsFileEmpty::~WorkflowPredicateIsFileEmpty()
{
}

bool WorkflowPredicateIsFileEmpty::evaluate()
{
  if (mVariable.length() > 0)
  {
    ArgEnvironment* env = ArgEnvironment::getActiveEnvironment();
    std::wstring filename = env->getValue(mVariable);

    // Use the current setting of the variable to determine the filename.
    mFilename = boost::filesystem::system_complete( 
                boost::filesystem::wpath(filename, boost::filesystem::native));
  }

  if (!boost::filesystem::exists(mFilename))
  {
    return true;
  }

  return (boost::filesystem::file_size(mFilename) <= 0);
}

void WorkflowPredicateIsFileEmpty::setStringParameter(
                                            const std::wstring& filename)
{
  mFilename = boost::filesystem::system_complete( 
                boost::filesystem::wpath(filename, boost::filesystem::native));

  std::wstringstream sstream;
  sstream << L"isFileEmpty(\"" << filename << L"\")";
  mDescription = sstream.str();
}

void WorkflowPredicateIsFileEmpty::setVariableParameter(
                                            const std::wstring& variable)
{
  mVariable = variable;

  std::wstringstream sstream;
  sstream << L"isFileEmpty($" << mVariable << L")";
  mDescription = sstream.str();
}

std::wstring WorkflowPredicateIsFileEmpty::toString() const
{
  return mDescription;
}

WorkflowPredicateNot::WorkflowPredicateNot() :
  mOperand(NULL)
{
}

WorkflowPredicateNot::~WorkflowPredicateNot()
{
  if (mOperand)
  {
    delete mOperand;
  }
}

bool WorkflowPredicateNot::evaluate()
{
  if (!mOperand)
  {
    return false;
  }

  return (!mOperand->evaluate());
}

void WorkflowPredicateNot::setStringParameter(
                                            const std::wstring& filename)
{
}

void WorkflowPredicateNot::setVariableParameter(const std::wstring& variable)
{
}

void WorkflowPredicateNot::setOperand(WorkflowPredicate* predicate)
{
  mOperand = predicate;
}

std::wstring WorkflowPredicateNot::toString() const
{
  std::wstringstream sstream;
  sstream << L"!";

  if (mOperand)
  {
    sstream << mOperand->toString();
  }

  return sstream.str();
}

