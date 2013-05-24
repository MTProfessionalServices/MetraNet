#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma warning( disable : 4786 ) 
#endif

#include "Symbol.h"
#include "Environment.h"

#include <boost/thread/mutex.hpp>

AccessPtr Scope::allocateVariable(const std::string& var, int ty)
{
	return mFrame->allocateVariable(var, ty);
}

Scope::~Scope() 
{ 
	if (mOwnFrame) delete mFrame; 
}

SymbolFactory::SymbolFactory()
  :
  mMutex(NULL)
{
  mMutex = new boost::mutex();
}
  
SymbolFactory::~SymbolFactory()
{
  delete mMutex;
}

// Factory -- can only create these objects as reference counted pointers
// In fact, we guarantee that only one symbol gets created for a given
// string value.  This makes symbol equality comparisons a simple integer ==.
const SymbolPtr SymbolFactory::create(const string& str)
{
  // Synchronize the method
  boost::mutex::scoped_lock guard(*mMutex);

  SymbolPtr sym = mHash[str];
  if (sym == NULL)
  {
    sym = SymbolPtr(new Symbol(str));
    mHash[str] = sym;
  }
  return sym;
}  

