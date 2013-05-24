#ifndef _ENVIRONMENT_H_
#define _ENVIRONMENT_H_

#include <metralite.h>
#include <string>
#include <vector>
#include <map>
#include <list>
#include <stack>
#include <boost/algorithm/string.hpp>

using namespace std;

#include "MTSQLInterpreter.h"
#include "MTSQLException.h"
#include "Symbol.h"
#include "RuntimeValue.h"
#include "PrimitiveFunctionLibrary.h"
#include "LexicalAddress.h"


#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma warning( disable : 4786 ) 
#endif

class SimpleFrame : public Frame
{
private:
	map<string, AccessPtr> mHash;

public:
	class TestAccess : public Access
	{
		// Make SimpleFrame a friend since it constructs 
		// TestAccesses in its allocateVariable method
		friend class SimpleFrame;

	private:
		string mName;
		TestAccess(const string& str) : mName(str) {}
	public:
		const string& getName() const { return mName; }
	};

	virtual AccessPtr allocateVariable(const std::string& str, int)
	{
		AccessPtr access = mHash[str];
		if (access == nullAccess)
		{
			access = AccessPtr(new TestAccess(str));
			mHash[str] = access;
		}
		return access;
	}
};



class Environment
{
private:
  SymbolFactory mSymbols;

public:

	const VarEntryPtr lookupVar(const string& name)
	{
		VarEntryPtr entry;
		SymbolPtr sym = mSymbols.create(name);
		std::list<Scope *>::reverse_iterator it = mFrames.rbegin();
		while (it != mFrames.rend()) 
		{
			entry = (*it++)->getVar(sym);
			if(entry != VarEntryPtr()) break;
		}
		return entry;
	}

	void insertVar(const string& name, VarEntryPtr entry)
	{
		mFrames.back()->putVar(mSymbols.create(name), entry);
	}

	FunEntryPtr lookupFun(const string& name, const std::vector<int>& types)
	{
		FunEntryPtr entry;
		SymbolPtr sym = mSymbols.create(getDecoratedName(name, types));
		std::list<Scope *>::reverse_iterator it = mFrames.rbegin();
		while (it != mFrames.rend())
		{
			entry = (*it++)->getFun(sym);
			if(entry != FunEntryPtr()) break;
		}
		return entry;
	}

	void beginScope()
	{
		mFrames.push_back(new Scope(new SimpleFrame(), true));
	}

	void endScope()
	{
		Scope* frame = mFrames.back();
		mFrames.pop_back();
		delete frame;
	}

	int getCurrentLevel() const 
	{
		return mFrames.size();
	}

	AccessPtr allocateVariable(const string& name, int ty)
	{
		return AccessPtr(mFrames.back()->allocateVariable(name, ty));
	}

	void loadLibrary(PrimitiveFunctionLibrary* library)
		{
			vector<PrimitiveFunction *> funs = library->getFunctions();
			for(std::vector<int>::size_type i =0; i<funs.size(); i++)
      {
        std::string decoratedName = getDecoratedName(funs[i]->getName(), funs[i]->getArgTypes());
				insertFun(decoratedName, 
                  FunEntry::create(funs[i]->getReturnType(), funs[i]->getArgTypes(), decoratedName));
      }
		}

	// The caller owns the globalFrame.  It will not be
	// deleted.
	Environment(Frame* globalFrame)
	{
		mFrames.push_back(new Scope(globalFrame, false));
	}

	~Environment()
		{
			// Pop all of the scopes off of the stack.  Remember that
			// the Frame in the first scope is passed into us! We don't
			// delete it!
			while(getCurrentLevel()>0) endScope();
		}

  static std::string getDecoratedName(const std::string & name, const std::vector<int>& args)
  {
    // We normalize the name to lower case so that we are insensitive to case.
    std::string decorated(name);
    boost::to_lower(decorated);

    char buf[32];
    for(std::vector<int>::const_iterator it = args.begin();
        it != args.end();
        it++)
    {
      sprintf(buf, "_%d", *it);
      decorated += buf;
    }
    return decorated;
  }

private:
	std::list<Scope *> mFrames;

	void insertFun(const string& name, FunEntryPtr entry)
	{
		mFrames.back()->putFun(mSymbols.create(name), entry);
	}
};

class SimpleActivationRecord : public ActivationRecord
{
private:
	map<std::string, RuntimeValue> mRuntimeEnv;
	ActivationRecord* mStaticLink;

	void getValue(const Access * access, RuntimeValue * value)
	{
		value->operator=(mRuntimeEnv[(static_cast<const SimpleFrame::TestAccess *>(access))->getName()]);
	}
	void setValue(const Access * access, const RuntimeValue * value)
	{
		mRuntimeEnv[(static_cast<const SimpleFrame::TestAccess *>(access))->getName()] = *value;
	}

public:
	void getLongValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getLongLongValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getDoubleValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getDecimalValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getStringValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getWStringValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getBooleanValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getDatetimeValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getTimeValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getEnumValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void getBinaryValue(const Access * access, RuntimeValue * value)
		{
			getValue(access, value);
		}
	void setLongValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setLongLongValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setDoubleValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setDecimalValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setStringValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setWStringValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setBooleanValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setDatetimeValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setTimeValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setEnumValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}
	void setBinaryValue(const Access * access, const RuntimeValue * value)
		{
			setValue(access, value);
		}

	ActivationRecord* getStaticLink() 
	{
		return mStaticLink;
	}

	SimpleActivationRecord(ActivationRecord* staticLink) : mStaticLink(staticLink)
	{
	}
};

class RuntimeEnvironment
{
public:
  typedef ActivationRecord activation_record;
private:
  ActivationRecord* mActivation[10];
  ActivationRecord** mTop;

	ActivationRecord* getFrame(int offset) const
	{
		ActivationRecord* staticLink = *mTop;
		for(int i = 0; i < offset; i++) 
		{
			staticLink = staticLink->getStaticLink();
		}
		return staticLink;
	}
public:

  virtual ~RuntimeEnvironment() {}

  // Replace the global environment.
  // Requires that no activation records remain allocated.
  void setGlobalEnvironment(ActivationRecord * globalEnvironment)
  {
    ASSERT(mTop == &mActivation[0]);
    mActivation[0] = globalEnvironment;
  }

  // Retrieves the global environment.
  // Requires that no activation records remain allocated.
  ActivationRecord *  getGlobalEnvironment()
  {
    ASSERT(mTop == &mActivation[0]);
    return mActivation[0];
  }

	void getLongValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getLongValue(access->getFrameAccess().get(), value);
  }
	void getLongLongValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getLongLongValue(access->getFrameAccess().get(), value);
  }
	void getDoubleValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getDoubleValue(access->getFrameAccess().get(), value);
  }
	void getDecimalValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getDecimalValue(access->getFrameAccess().get(), value);
  }
	void getStringValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getStringValue(access->getFrameAccess().get(), value);
  }
	void getWStringValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getWStringValue(access->getFrameAccess().get(), value);
  }
	void getBooleanValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getBooleanValue(access->getFrameAccess().get(), value);
  }
	void getDatetimeValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getDatetimeValue(access->getFrameAccess().get(), value);
  }
	void getTimeValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getTimeValue(access->getFrameAccess().get(), value);
  }
	void getEnumValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getEnumValue(access->getFrameAccess().get(), value);
  }
	void getBinaryValue(const LexicalAddress * access, RuntimeValue * value)
  {
    getFrame(access->getOffset())->getBinaryValue(access->getFrameAccess().get(), value);
  }
	void setLongValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setLongValue(access->getFrameAccess().get(), val);
  }
	void setLongLongValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setLongLongValue(access->getFrameAccess().get(), val);
  }
	void setDoubleValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setDoubleValue(access->getFrameAccess().get(), val);
  }
	void setDecimalValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setDecimalValue(access->getFrameAccess().get(), val);
  }
	void setStringValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setStringValue(access->getFrameAccess().get(), val);
  }
	void setWStringValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setWStringValue(access->getFrameAccess().get(), val);
  }
	void setBooleanValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setBooleanValue(access->getFrameAccess().get(), val);
  }
	void setDatetimeValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setDatetimeValue(access->getFrameAccess().get(), val);
  }
	void setTimeValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setTimeValue(access->getFrameAccess().get(), val);
  }
	void setEnumValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setEnumValue(access->getFrameAccess().get(), val);
  }
	void setBinaryValue(const LexicalAddress *  access, const RuntimeValue * val)
  {
    getFrame(access->getOffset())->setBinaryValue(access->getFrameAccess().get(), val);
  }

	void allocateActivationRecord(int linkOffset)
	{
    if (mTop++ > &mActivation[9])
      throw std::exception("MetraFlow Stack overflow");
    *mTop = new SimpleActivationRecord(getFrame(linkOffset));
	}

	void freeActivationRecord()
	{
    if (mTop <= &mActivation[0])
      throw std::exception("MetraFlow Stack underflow");
    delete *mTop--;
	}

	RuntimeEnvironment(ActivationRecord* globalEnvironment)
	{
    mActivation[0] = globalEnvironment;
    mTop = &mActivation[0];
	}

	virtual void executePrimitiveFunction(const string& fun, const RuntimeValue ** args, int sz, RuntimeValue * result)=0;
};


// There is a bit of a hack here since we cannot assume that the
// globalEnvironment can store function values (in particular, the 
// session server cannot).  Thus, we are going to squirrel away
// primitive functions in a special map.
class TestRuntimeEnvironment : public RuntimeEnvironment
{

private:
	map<string, PrimitiveFunction*> mPrimitiveFun;

public:

	TestRuntimeEnvironment(ActivationRecord* globalEnvironment) : RuntimeEnvironment(globalEnvironment)
	{
	}

	void loadLibrary(PrimitiveFunctionLibrary* library)
		{
			vector<PrimitiveFunction *> funs = library->getFunctions();
			for(std::vector<int>::size_type i =0; i<funs.size(); i++)
      {
        std::string decoratedName = Environment::getDecoratedName(funs[i]->getName(), funs[i]->getArgTypes());
				mPrimitiveFun[decoratedName] = funs[i];
      }
		}

	void executePrimitiveFunction(const string& fun, const RuntimeValue ** args, int sz, RuntimeValue * result)
	{
		return mPrimitiveFun[fun]->execute(args, sz, result);
	}
};
#endif
