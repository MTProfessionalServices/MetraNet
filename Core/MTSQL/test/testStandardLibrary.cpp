#pragma warning( disable : 4786 ) 
#include "test.h"
#include "StandardLibrary.h"
#include <crtdbg.h>

TestStandardLibrary::TestStandardLibrary()
{
}

RuntimeValue TestStandardLibrary::execute(PrimitiveFunction * f, const std::vector<RuntimeValue>& args)
{
  const RuntimeValue ** argVec = new const RuntimeValue * [args.size()];
  for (unsigned int i=0; i<args.size(); i++)
  {
    argVec[i] = &args[i];
  }

  RuntimeValue result;
  f->execute(argVec, int(args.size()), &result);
  return result;
}

void TestStandardLibrary::VerifyStandardLibraryContents()
{
	StandardLibrary lib;
	_ASSERT(lib.getFunctions().size() == 16);
	_ASSERT(lib.getFunctions()[0]->getName() == "substr");
	_ASSERT(lib.getFunctions()[1]->getName() == "upper");
	_ASSERT(lib.getFunctions()[2]->getName() == "lower");
	_ASSERT(lib.getFunctions()[3]->getName() == "round");
	_ASSERT(lib.getFunctions()[4]->getName() == "floor");
	_ASSERT(lib.getFunctions()[5]->getName() == "ceiling");
	_ASSERT(lib.getFunctions()[6]->getName() == "getdate");
	_ASSERT(lib.getFunctions()[7]->getName() == "getutcdate");
	_ASSERT(lib.getFunctions()[8]->getName() == "sqr");
	_ASSERT(lib.getFunctions()[9]->getName() == "sqrt");
	_ASSERT(lib.getFunctions()[10]->getName() == "intervaldays");
	_ASSERT(lib.getFunctions()[11]->getName() == "dateadd");
	_ASSERT(lib.getFunctions()[12]->getName() == "datediff");
	_ASSERT(lib.getFunctions()[13]->getName() == "len");
	_ASSERT(lib.getFunctions()[14]->getName() == "around");
	_ASSERT(lib.getFunctions()[15]->getName() == "bround");
}
void TestStandardLibrary::TestSubstr()
{
	StandardLibrary lib;
	PrimitiveFunction* f = lib.getFunctions()[0];
	_ASSERT(RuntimeValue::TYPE_STRING == f->getReturnType());
	_ASSERT(3 == f->getArgTypes().size());
	_ASSERT(RuntimeValue::TYPE_STRING == f->getArgTypes()[0]);
	_ASSERT(RuntimeValue::TYPE_INTEGER == f->getArgTypes()[1]);
	_ASSERT(RuntimeValue::TYPE_INTEGER == f->getArgTypes()[2]);
	
	std::vector<RuntimeValue> args;
	args.push_back(RuntimeValue::createString("abcdefghijklmno"));
	args.push_back(RuntimeValue::createLong(3L));
	args.push_back(RuntimeValue::createLong(3L));
	RuntimeValue cmp = RuntimeValue::createString("cde") == execute(f,args);
	_ASSERT(cmp.getBool());

	args.clear();
	args.push_back(RuntimeValue::createString("abcdefghijklmno"));
	args.push_back(RuntimeValue::createLong(8L));
	args.push_back(RuntimeValue::createLong(6L));
	cmp = RuntimeValue::createString("hijklm") == execute(f,args);
	_ASSERT(cmp.getBool());

	try {
		args.clear();
		args.push_back(RuntimeValue::createString("abcdefghijklmno"));
		args.push_back(RuntimeValue::createLong(8L));
		args.push_back(RuntimeValue::createLong(10000L));
		cmp = RuntimeValue::createString("hijklmno") == execute(f,args);
		_ASSERT(cmp.getBool());
	} catch (std::exception e) {
		_ASSERT(false);
	}

	try {
		args.clear();
		args.push_back(RuntimeValue::createString("abcdefghijklmno"));
		args.push_back(RuntimeValue::createLong(-3L));
		args.push_back(RuntimeValue::createLong(5L));
		cmp = RuntimeValue::createString("a") == execute(f,args);
		_ASSERT(cmp.getBool());
	} catch (std::exception e) {
		_ASSERT(false);
	}

	try {
		args.clear();
		args.push_back(RuntimeValue::createString("abcdefghijklmno"));
		args.push_back(RuntimeValue::createLong(-3L));
		args.push_back(RuntimeValue::createLong(3L));
		cmp = RuntimeValue::createString("") == execute(f,args);
		_ASSERT(cmp.getBool());
	} catch (std::exception e) {
		_ASSERT(false);
	}

	try {
		args.clear();
		args.push_back(RuntimeValue::createString("abcdefghijklmno"));
		args.push_back(RuntimeValue::createLong(-3L));
		args.push_back(RuntimeValue::createLong(-5L));
		execute(f,args);
		_ASSERT(false);
	} catch (MTSQLException e) {
	}
}
void TestStandardLibrary::TestUpper()
{
	StandardLibrary lib;
	PrimitiveFunction* f = lib.getFunctions()[1];
	_ASSERT(RuntimeValue::TYPE_STRING == f->getReturnType());
	_ASSERT(1 == f->getArgTypes().size());
	_ASSERT(RuntimeValue::TYPE_STRING == f->getArgTypes()[0]);

	std::vector<RuntimeValue> args;
	args.push_back(RuntimeValue::createString("abcdefghijklmno"));
	RuntimeValue cmp = RuntimeValue::createString("ABCDEFGHIJKLMNO") == execute(f,args);
	_ASSERT(cmp.getBool());

	args.clear();
	args.push_back(RuntimeValue::createString("sjdf234"));
	cmp = RuntimeValue::createString("SJDF234") == execute(f,args);
	_ASSERT(cmp.getBool());	
}

void TestStandardLibrary::TestLower()
{
	StandardLibrary lib;
	PrimitiveFunction* f = lib.getFunctions()[2];
	_ASSERT(RuntimeValue::TYPE_STRING == f->getReturnType());
	_ASSERT(1 == f->getArgTypes().size());
	_ASSERT(RuntimeValue::TYPE_STRING == f->getArgTypes()[0]);

	std::vector<RuntimeValue> args;
	args.push_back(RuntimeValue::createString("ABCDEFGHIJKLMNO"));
	RuntimeValue cmp = RuntimeValue::createString("abcdefghijklmno") == execute(f,args);
	_ASSERT(cmp.getBool());

	args.clear();
	args.push_back(RuntimeValue::createString("SJDF234"));
	cmp = RuntimeValue::createString("sjdf234") == execute(f,args);
	_ASSERT(cmp.getBool());	
}

void TestStandardLibrary::RunTests()
{
	VerifyStandardLibraryContents();
	TestSubstr();
	TestUpper();
	TestLower();
}
