
#include <iostream>
#include <sstream>
#include "CompositePortParam.h"

CompositePortParam::CompositePortParam(
                           const std::wstring& paramName,
                           int paramNumber,
                           const std::wstring& operatorName,
                           const std::wstring& portName,
                           int portNumber,
                           bool isInput,
                           int paramNameLine, int paramNameCol,
                           int opNameLine, int opNameCol,
                           int opPortLine, int opPortCol)
 : mIsRange(false),
   mParamName(paramName),
   mParamNumber(paramNumber),
   mOperatorName(operatorName),
   mPortName(portName),
   mRangeRootPortName(L""),
   mPortNumber(portNumber),
   mIsInput(isInput),
   mIsSimplifiedInputNamingUsed(false),
   mParamNameLine(paramNameLine),
   mParamNameCol(paramNameCol),
   mOpLine(opNameLine),
   mOpCol(opNameCol),
   mOpPortLine(opPortLine),
   mOpPortCol(opPortCol)
{
  // Determine if the parameter name indicates
  // a range of ports.  Syntax: (*) or (n..*)
  size_t nStart = portName.find(L"(");
  size_t nEnd = portName.find(L"*)");
  if (nStart != string::npos && nEnd != string::npos &&
      nStart < nEnd)
  {
    mIsRange = true;
    mPortNumber = 0;
    mRangeRootPortName = portName.substr(0, nStart);

    if (nEnd - nStart - 1 > 0)
    {
      int i;
      std::wstring number = portName.substr(nStart + 1, nEnd-nStart);
      std::wstringstream s(number);
      if (s >> i)
      {
        mPortNumber = i;
      }
      else
      {
        mIsRange = false;
      }
    }
  }
}

CompositePortParam::~CompositePortParam()
{
}

const std::wstring& CompositePortParam::getParamName() const
{
  return mParamName;
}

int CompositePortParam::getNumberOfPortsReferenced() const
{
  // If this is a range parameter, then it is up to the
  // user of the composite to determine how many (if any)
  // of this parameter are used.  This method is used to
  // help construct an operator inside the composite. At this
  // point there are no instatiated references using the range.
  if (mIsRange)
  {
    return 0;
  }

  return 1;
}

const std::wstring& CompositePortParam::getOperatorName() const
{
  return mOperatorName;
}

const std::wstring& CompositePortParam::getOperatorPortName() const
{
  return mPortName;
}

int CompositePortParam::getParamNumber() const
{
  return mParamNumber;
}

int CompositePortParam::getOperatorPortNumber() const
{
  return mPortNumber;
}

std::wstring CompositePortParam::getOperatorPortNameRoot() const
{
  if (!mIsRange)
  {
    return L"";
  }

  return mRangeRootPortName;
}

std::wstring CompositePortParam::getParamNameInRange(int index) const
{
  if (!mIsRange)
  {
    return L"";
  }

  std::wstringstream out;
  out << mParamName << L"(" << index << L")";
  return out.str();
}

std::wstring CompositePortParam::getPortNameInRange(int index) const
{
  if (!mIsRange)
  {
    return L"";
  }

  std::wstringstream out;
  out << mRangeRootPortName << L"(" << index + mPortNumber << L")";
  return out.str();
}

bool CompositePortParam::isInput() const
{
  return mIsInput;
}

bool CompositePortParam::isParamNameValid() const
{
  // The parameter name cannot contain "("
  // We use "(" to indicate an instance of a range parameter.
  // Example: IN j("probe(3..*)") AS myInput
  // The parameter name is "myInput". We will generate
  // myInput(0), myInput(1) based on usage.
  return (mParamName.find(L"(") != string::npos);
}

bool CompositePortParam::isRange() const
{
  return mIsRange;
}

bool CompositePortParam::isSimplifiedInputNamingUsed() const
{
  return mIsSimplifiedInputNamingUsed;
}

int CompositePortParam::getParamNameLine() const
{
  return mParamNameLine;
}

int CompositePortParam::getParamNameCol() const
{
  return mOpCol;
}

int CompositePortParam::getOpLine() const
{
  return mOpLine;
}

int CompositePortParam::getOpCol() const
{
  return mOpCol;
}

int CompositePortParam::getOpPortLine() const
{
  return mOpPortLine;
}

int CompositePortParam::getOpPortCol() const
{
  return mOpPortCol;
}

void CompositePortParam::setIsSimplifiedInputNamingUsed()
{
  mIsSimplifiedInputNamingUsed = true;
}

void CompositePortParam::setPortNumber(int portNumber)
{
  mPortNumber = portNumber;
}

void CompositePortParam::setPortName(const std::wstring &name)
{
  mPortName = name;
}

void CompositePortParam::setOperatorName(const std::wstring &opName)
{
  mOperatorName = opName;
}
