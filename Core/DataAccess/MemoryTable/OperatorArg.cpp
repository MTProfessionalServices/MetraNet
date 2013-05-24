
#include <iostream>
#include <sstream>

#include "OperatorArg.h"
#include "DataflowException.h"

#include <boost/algorithm/string/predicate.hpp>

OperatorArg::OperatorArg(const std::wstring& name,
                         const std::wstring& value,
                         int nameLine,
                         int nameColumn,
                         int valueLine,
                         int valueColumn,
                         const std::wstring& filename)
 : mName(name),
   mType(OPERATOR_ARG_TYPE_STRING),
   mStringValue(value),
   mBoolValue(false),
   mIntValue(0),
   mCompositeArgType(OPERATOR_ARG_TYPE_STRING),
   mNameLine(nameLine),
   mNameColumn(nameColumn),
   mValueLine(valueLine),
   mValueColumn(valueColumn),
   mFilename(filename)
{
  findEmbeddedArgs();
}

OperatorArg::OperatorArg(const std::wstring& name,
                         bool value,
                         int nameLine,
                         int nameColumn,
                         int valueLine,
                         int valueColumn,
                         const std::wstring& filename)
 : mName(name),
   mType(OPERATOR_ARG_TYPE_BOOLEAN),
   mStringValue(L""),
   mBoolValue(value),
   mIntValue(0),
   mCompositeArgType(OPERATOR_ARG_TYPE_STRING),
   mNameLine(nameLine),
   mNameColumn(nameColumn),
   mValueLine(valueLine),
   mValueColumn(valueColumn),
   mFilename(filename)
{
}

OperatorArg::OperatorArg(const std::wstring& name,
                         int value,
                         int nameLine,
                         int nameColumn,
                         int valueLine,
                         int valueColumn,
                         const std::wstring& filename)
 : mName(name),
   mType(OPERATOR_ARG_TYPE_INTEGER),
   mStringValue(L""),
   mBoolValue(false),
   mIntValue(value),
   mCompositeArgType(OPERATOR_ARG_TYPE_STRING),
   mNameLine(nameLine),
   mNameColumn(nameColumn),
   mValueLine(valueLine),
   mValueColumn(valueColumn),
   mFilename(filename)
{
}

OperatorArg::OperatorArg(OperatorArgType opType)
 : mName(L""),
   mType(OPERATOR_ARG_TYPE_SUBLIST),
   mStringValue(L""),
   mBoolValue(false),
   mIntValue(0),
   mCompositeArgType(OPERATOR_ARG_TYPE_STRING),
   mNameLine(0),
   mNameColumn(0),
   mValueLine(0),
   mValueColumn(0),
   mFilename(L"")
{
}

OperatorArg::OperatorArg(OperatorArgType opType,
                         const std::wstring& name,
                         const std::wstring& value,
                         OperatorArgType argType,
                         int nameLine,
                         int nameColumn,
                         int valueLine,
                         int valueColumn,
                         const std::wstring& filename)
 : mName(name),
   mType(OPERATOR_ARG_TYPE_VARIABLE),
   mStringValue(value),
   mBoolValue(false),
   mIntValue(0),
   mCompositeArgType(argType),
   mNameLine(nameLine),
   mNameColumn(nameColumn),
   mValueLine(valueLine),
   mValueColumn(valueColumn),
   mFilename(filename)
{
}

OperatorArg::OperatorArg(const OperatorArg& other)
  : mName(other.mName),
    mType(other.mType),
    mStringValue(other.mStringValue),
    mBoolValue(other.mBoolValue),
    mIntValue(other.mIntValue),
    mCompositeArgType(other.mCompositeArgType),
    mNameLine(other.mNameLine),
    mNameColumn(other.mNameColumn),
    mValueLine(other.mValueLine),
    mValueColumn(other.mValueColumn),
    mFilename(other.mFilename)
{
  const std::vector<OperatorArg> & otherArgs = other.getSubList();
  for (unsigned int i=0; i<otherArgs.size(); i++)
  {
    mSubList.push_back(otherArgs[i]);
  }

  findEmbeddedArgs();
}

OperatorArg& OperatorArg::operator=(const OperatorArg& other)
{
  if (this != &other)
  {
    mName = other.mName;
    mType = other.mType;
    mStringValue = other.mStringValue;
    mBoolValue = other.mBoolValue;
    mIntValue = other.mIntValue;
    mCompositeArgType = other.mCompositeArgType;
    mNameLine = other.mNameLine;
    mNameColumn = other.mNameColumn;
    mValueLine = other.mValueLine;
    mValueColumn = other.mValueColumn;
    mFilename = other.mFilename;

    const std::vector<OperatorArg> & otherArgs = other.getSubList();
    for (unsigned int i=0; i<otherArgs.size(); i++)
    {
      mSubList.push_back(otherArgs[i]);
    }
  }

  return *this;
}

OperatorArg::~OperatorArg()
{
}

void OperatorArg::addSubListArg(const OperatorArg& arg)
{
  if (mType == OPERATOR_ARG_TYPE_SUBLIST)
  {
    mSubList.push_back(arg);
  }
}

void OperatorArg::findEmbeddedArgs()
{
  // Look for embedded arguments in the string.
  size_t pos = 0;
  size_t argStart, argEnd;

  while(pos < mStringValue.length() &&
        (argStart = mStringValue.find(L"$(", pos)) != string::npos)
  {
    argEnd = mStringValue.find(L")", argStart);
    if (argEnd == string::npos)
    {
      pos = argStart + 2;
      continue;
    }

    pos = argEnd;

    std::wstring embeddedArg = mStringValue.substr(argStart+2,argEnd-argStart-2);
    mEmbeddedArgs.push_back(embeddedArg);
  }

  // TODO: This does not handle sublists.
}

OperatorArgType OperatorArg::getType() const
{
  return mType;
}

std::wstring OperatorArg::getName() const
{
  return mName;
}

std::wstring OperatorArg::getStringValue() const
{
  return mStringValue;
}

std::wstring OperatorArg::getNormalizedString() const
{
  if (mStringValue.size() <= 2)
  {
    return L"";
  }
  return mStringValue.substr(1, mStringValue.size()-2);
}

int OperatorArg::getIntValue() const
{
  return mIntValue;
}

bool OperatorArg::getBoolValue() const
{
  return mBoolValue;
}

std::wstring OperatorArg::getValueAsString() const
{
  std::wstringstream stm;

  switch (mType)
  {
    case OPERATOR_ARG_TYPE_STRING:  
         if (mStringValue.size() <= 2)
         {
           return L"";
         }
         return mStringValue.substr(1, mStringValue.size()-2);

    case OPERATOR_ARG_TYPE_BOOLEAN:
         if (mBoolValue)
         {
           return L"true";
         }
         return L"false";

    case OPERATOR_ARG_TYPE_INTEGER: 
         stm << mIntValue;
         return stm.str();

    default:
         return L"";
  }
}

const std::vector<OperatorArg> & OperatorArg::getSubList() const
{
  return mSubList;
}

int OperatorArg::getNameLine() const
{
  return mNameLine;
}

int OperatorArg::getNameColumn() const
{
  return mNameColumn;
}

int OperatorArg::getValueLine() const
{
  return mValueLine;
}

int OperatorArg::getValueColumn() const
{
  return mValueColumn;
}

std::wstring OperatorArg::getFilename() const
{
  return mFilename;
}

OperatorArgType OperatorArg::getVarType() const
{
  return mCompositeArgType;
}

const std::vector<std::wstring> & OperatorArg::getEmbeddedArgs() const
{
  return mEmbeddedArgs;
}

bool OperatorArg::is(const std::wstring &matchThis,
                     OperatorArgType expectedType, 
                     const std::wstring &opName) const
{
  bool matches = 
         (boost::algorithm::iequals(mName.c_str(), matchThis.c_str()));

  if (matches && expectedType != mType)
  {
    std::wstring expected;
    std::wstring saw;
    std::wstringstream stm;

    switch (expectedType)
    {
      case OPERATOR_ARG_TYPE_STRING:  expected = L"Expected a string.";
                                      saw = mStringValue;
                                      break;
      case OPERATOR_ARG_TYPE_BOOLEAN: expected = L"Expected true or false.";
                                      saw = L"false";
                                      if (mBoolValue)
                                        saw = L"true";
                                      break;
      case OPERATOR_ARG_TYPE_INTEGER: expected = L"Expected an integer.";
                                      stm << mIntValue;
                                      saw = stm.str();
                                      break;
      default:                        expected = L"Expected something else.";
                                      saw = L"";
                                      break;
    }

    throw DataflowInvalidArgumentValueException(mValueLine,
                                                mValueColumn,
                                                mFilename,
                                                opName,
                                                mName,
                                                saw,
                                                expected);
    return false;
  }

  return matches;
}

bool OperatorArg::isThereAnEmbeddedArg() const
{
  return (mEmbeddedArgs.size() > 0);
}

bool OperatorArg::isValue(const std::wstring &matchThis) const
{
  if (mType != OPERATOR_ARG_TYPE_STRING)
  {
    return false;
  }

  std::wstring value = mStringValue.substr(1, mStringValue.size()-2);

  return (boost::algorithm::iequals(value.c_str(), matchThis.c_str()));
}

void OperatorArg::replaceEmbeddedArg(const std::wstring &embeddedArg,
                                     const std::wstring &replacementValue)
{
  std::wstring lookFor = L"$(" + embeddedArg + L")";
  size_t argStart;

  argStart = mStringValue.find(lookFor);
  if (argStart == string::npos)
  {
    return;
  }
  
  std::wstring result = mStringValue.substr(0, argStart) + replacementValue;

  size_t argEnd = argStart + lookFor.length();
  if (argEnd < mStringValue.length())
  {
    result = result + mStringValue.substr(argEnd);
  }

  //std::cout << "Result (" << result << ")" << std::endl;
  mStringValue = result;
}

void OperatorArg::setName(const std::wstring &name,
                          int line, int column)
{
  mName = name;
  mNameLine = line;
  mNameColumn = column;
}

void OperatorArg::setName(const std::wstring &name)
{
  mName = name;
}

void OperatorArg::repairNewLines(std::wstring &s)
{
  int pos=0;

  do
  {
    pos = s.find(L"\\n", pos);
    if (pos >= 0)
    {
      s.erase(pos, 2);
      s.insert(pos, L"\n");
      pos = pos + 1;
    }
  } while (pos < (int) s.length() && pos != std::wstring::npos);
}
