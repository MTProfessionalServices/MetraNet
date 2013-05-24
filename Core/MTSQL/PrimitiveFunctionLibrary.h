#ifndef _PRIMITIVEFUNCTIONLIBRARY_H_
#define _PRIMITIVEFUNCTIONLIBRARY_H_

#include <vector>
#include <string>

#include "RuntimeValue.h"

class PrimitiveFunction
{
public:
	virtual void execute(const RuntimeValue ** args, int sz, RuntimeValue * result) =0;
	virtual std::string getName() const =0;
	virtual int getReturnType() const =0;
	virtual std::vector<int> getArgTypes() const =0;
	virtual ~PrimitiveFunction() {}
};

class PrimitiveFunctionLibrary
{
public:
	virtual std::vector<PrimitiveFunction*> getFunctions() const =0;
	virtual void load() =0;
	virtual ~PrimitiveFunctionLibrary() {}
};

class PrimitiveFunctionImpl : public PrimitiveFunction
{
protected:
	std::vector<int> mArgTypes;
	int mRetType;
	std::string mName;
public:

	virtual void execute(const RuntimeValue ** args, int sz, RuntimeValue * result) =0;

	std::string getName() const
	{
		return mName;
	}
	int getReturnType() const
	{
		return mRetType;
	}
	std::vector<int> getArgTypes() const {
		return mArgTypes;
	}

	virtual ~PrimitiveFunctionImpl() {}
};

#endif
