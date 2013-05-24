#include <boost/tokenizer.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/algorithm/string.hpp>

#include "ArgEnvironment.h"
#include "OperatorArg.h"

ArgEnvironment* ArgEnvironment::mInstance = 0;

ArgEnvironment::ArgEnvironment()
{
}

ArgEnvironment::~ArgEnvironment()
{
}

ArgEnvironment& ArgEnvironment::operator=(const ArgEnvironment &rhs)
{
  if (this == &rhs)
  {
    return *this;
  }

  mArgs.clear();

  for (std::map<std::wstring, std::wstring>::const_iterator 
       it=mArgs.begin(); it != mArgs.end(); it++)
  {
    mArgs[it->first] = it->second;
  }

  return *this;
}

void ArgEnvironment::deserialize(const std::string &serialized)
{
  typedef boost::tokenizer<boost::escaped_list_separator<char> > toker;
  mArgs.clear();

  toker tok(serialized);
  std::wstring name;
  std::wstring value;

  // TODO: Handle escaping commas from names and values.
  for(toker::iterator it=tok.begin(); it!=tok.end(); ++it)
  {
    ::ASCIIToWide(name, boost::lexical_cast<std::string>(*it).c_str(), -1, CP_UTF8);
    it++;

    if (it != tok.end())
    {
      ::ASCIIToWide(value, boost::lexical_cast<std::string>(*it).c_str(), -1, CP_UTF8);
      mArgs[name] = value;
    }
  } 
}

ArgEnvironment* ArgEnvironment::getActiveEnvironment()
{
  if (!mInstance)
  {
    mInstance = new ArgEnvironment();
  }

  return mInstance;
}

std::wstring ArgEnvironment::getArg(const std::wstring &name)
{
  if (mArgs.find(name) == mArgs.end())
  {
    return L"";
  }

  return mArgs[name];
}

std::wstring ArgEnvironment::getIntrinsic(const std::wstring &name)
{
  if (mIntrinsics.find(name) == mIntrinsics.end())
  {
  
    return L"";
  }

  return mIntrinsics[name];
}

std::wstring ArgEnvironment::getValue(const std::wstring &argName)
{
  std::wstring result;

  // Check if the argument is instinsic
  result = getIntrinsic(argName);
  if (result.length() > 0)
  {
    return result;
  }

  // Check if the argument was specified by command line or environmental
  // variable.
  result = getArg(argName);
  if (result.length() > 0)
  {
    return result;
  }

  // We didn't find it.
  return L"";
}

std::wstring ArgEnvironment::getValue(
                        const std::wstring &argName,
                        const std::vector<OperatorArg *>&opArgList)
{
  // Check if the argument is in the given list.
  for (std::vector<OperatorArg*>::const_iterator i=opArgList.begin();
       i != opArgList.end(); i++)
  {
    OperatorArg* opArg = *i;
   
    if (opArg->getName().compare(argName) == 0)
    {
      return opArg->getValueAsString();
    }
  }

  return getValue(argName);
}

OperatorArg* ArgEnvironment::getValueAsOperatorArg(
                                const std::wstring &argName,
                                OperatorArgType desiredType)
{
  std::wstring value = getValue(argName);

  if (value.length() <= 0)
  {
    // We didn't find the value.
    return NULL;
  }

  // Constructed the desired type of operator argument.
  switch (desiredType)
  {
    case OPERATOR_ARG_TYPE_STRING:
         // The value we are using came from either an environmental
         // variable or from a command line argument.  We do not
         // expected there to be quotes around the string.  We are
         // adding the quotes.
         return new OperatorArg(argName, 
                                L"\"" + value + L"\"", 
                                0, 0, 0, 0, L"");

    case OPERATOR_ARG_TYPE_BOOLEAN:
         if (boost::algorithm::iequals(value.c_str(), L"true"))
         {
           return new OperatorArg(argName, true, 0, 0, 0, 0, L"");
         }
         return new OperatorArg(argName, false, 0, 0, 0, 0, L"");

    case OPERATOR_ARG_TYPE_INTEGER:
         try
         {
           int number = boost::lexical_cast< int >(value);
           return new OperatorArg(argName, number, 0, 0, 0, 0, L"");
         }
         catch(...)
         {
           return NULL;
         }

    default: return NULL;
  }
}

const std::map<std::wstring, std::wstring>& 
                                  ArgEnvironment::getNonIntrinsicArgs() const
{
  return mArgs;
}

const std::map<std::wstring, std::wstring>& 
                                  ArgEnvironment::getIntrinsicArgs() const
{
  return mIntrinsics;
}

bool ArgEnvironment::storeArg(const std::wstring &nameValue)
{
  size_t equalPos = nameValue.find(L"=");

  if (equalPos == string::npos || equalPos == 0 || 
      (equalPos+1) >= nameValue.length())
  {
    return false;
  }
  
  std::wstring name = nameValue.substr(0, equalPos);
  std::wstring value = nameValue.substr(equalPos+1);

  mArgs[name] = value;

  return true;
}

void ArgEnvironment::storeArg(const std::wstring &name,
                              const std::wstring &value)
{
  mArgs[name] = value;
}

void ArgEnvironment::storeEnvironmentalSettingForArg(const std::wstring &name)
{
  if (mArgs.find(name) == mArgs.end())
  {
    wchar_t* env = _wgetenv(name.c_str());
    if (env != NULL)
    {
      mArgs[name] = *env;
    }
  }
}

std::string ArgEnvironment::serialize() const
{
  std::stringstream sstream;

  for (std::map<std::wstring, std::wstring>::const_iterator 
       it=mArgs.begin(); it != mArgs.end(); it++)
  {
    // TODO: Handle escaping commas from name and values.
    if (it != mArgs.begin())
    {
      sstream << ",";
    }
    std::string utf8Name;
    ::WideStringToUTF8((*it).first, utf8Name);
    std::string utf8Value;
    ::WideStringToUTF8((*it).second, utf8Value);
    sstream << utf8Name << "," << utf8Value;
  }

  return sstream.str();
}

void ArgEnvironment::storeIntrinsicArg(const std::wstring &name,
                                       const std::wstring &value)
{
  mIntrinsics[name] = value;
}

void ArgEnvironment::storeIntrinsicArg(const std::wstring &name,
                                       int value)
{
  std::wstringstream sstream;
  sstream << value;
  storeIntrinsicArg(name, sstream.str());
}
