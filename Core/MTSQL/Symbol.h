#ifndef _SYMBOL_H_
#define _SYMBOL_H_

#include <string>
#include <map>
#include <vector>

using namespace std;

#include <boost/shared_ptr.hpp>

class Access;
class Frame;
class Symbol;
class FunEntry;
class VarEntry;

// TODO: replace this with MTautoptr
#include "MTSQLInterpreter.h"

typedef boost::shared_ptr<Symbol> SymbolPtr;
typedef boost::shared_ptr<FunEntry> FunEntryPtr;
typedef boost::shared_ptr<VarEntry> VarEntryPtr;

namespace boost
{
  class mutex;
};

class Symbol
{
private:
  friend class SymbolFactory;

	string mName;
	Symbol(const string& str) { mName = str; }

public:

	const string& toString() const
	{
		return mName;
	}
};

class SymbolFactory
{
private:
	map<string, SymbolPtr> mHash;
  // Use pointer to avoid putting header 
	boost::mutex * mMutex;
public:
  SymbolFactory();

  ~SymbolFactory();

	// Factory -- can only create these objects as reference counted pointers
	// In fact, we guarantee that only one symbol gets created for a given
	// string value.  This makes symbol equality comparisons a simple integer ==.
	const SymbolPtr create(const string& str);
};


class VarEntry
{
private:
	int mType;
	AccessPtr mAccess;
	int mLevel;

	// Constructor
	VarEntry(int ty, AccessPtr access, int level) { setType(ty); setAccess(access); setLevel(level); }

public:
	int getType() const { return mType; }
	void setType(int type) { mType = type; }

	AccessPtr getAccess() const 
	{ 
		return mAccess; 
	}
	void setAccess(AccessPtr access) 
	{ 
		mAccess = access; 
	}

	int getLevel() const { return mLevel; }
	void setLevel(int level) { mLevel = level; }
		
	// Factory -- can only create these objects as reference counted pointers
	static VarEntryPtr create(int ty, AccessPtr access, int level) { return VarEntryPtr(new VarEntry(ty, access, level)); }
};

class FunEntry
{
private:
	int mRetType;
	vector<int> mArgType;
  std::string mDecoratedName;

	// Constructor
	FunEntry(int retTy, 
           const vector<int>& argTy,
           const std::string& decoratedName) 
    :
    mRetType(retTy),
    mArgType(argTy),
    mDecoratedName(decoratedName)
  { 
  }

public:
	int getReturnType() const { return mRetType; }
	void setReturnType(int type) { mRetType = type; }

	const vector<int>& getArgType() const { return mArgType; }
	void setArgType(const vector<int>& argTy) { mArgType = argTy; }

  const std::string& getDecoratedName() const { return mDecoratedName; }
		
	// Factory -- can only create these objects as reference counted pointers
	static FunEntryPtr create(int retTy, 
                            const vector<int>& argTy, 
                            const std::string& decoratedName) 
  { 
    return FunEntryPtr(new FunEntry(retTy, argTy, decoratedName)); 
  }
};

// One Scope worth of Symbol Table
class Scope 
{
private:
	std::map<SymbolPtr, FunEntryPtr> mFunHash;
	std::map<SymbolPtr, VarEntryPtr> mVarHash;

	Frame* mFrame;
	bool mOwnFrame;
public:
	Scope(Frame* frame, bool ownFrame) : mFrame(frame), mOwnFrame(ownFrame)
	{
	}

	void putVar(SymbolPtr sym, VarEntryPtr entry)
	{
		mVarHash.insert(map<SymbolPtr, VarEntryPtr>::value_type(sym, entry));
	}

	VarEntryPtr getVar(SymbolPtr sym)
	{
		return mVarHash[sym];
	}

	void putFun(SymbolPtr sym, FunEntryPtr entry)
	{
		mFunHash.insert(map<SymbolPtr, FunEntryPtr>::value_type(sym, entry));
	}

	FunEntryPtr getFun(SymbolPtr sym)
	{
		return mFunHash[sym];
	}

	AccessPtr allocateVariable(const std::string& var, int ty);

	~Scope();
};

#endif


