#pragma warning( disable : 4786 ) 

#include <string>
#include <iostream>
#include <fstream>
#include <strstream>
#include <mtcom.h>
#include <process.h>
#include <MTUtil.h>
#include "crtdbg.h"

#include "MTSQLLexer.hpp"
#include "MTSQLParser.hpp"
#include "MTSQLTreeParser.hpp"
#include "MTSQLTreeExecution.hpp"

#include "AST.hpp"
#include "CommonAST.hpp"
#include "Token.hpp"

#include "MTSQLInterpreter.h"
#include "MTSQLSharedSessionInterface.h"
#include "BatchQuery.h"

#import <SysContext.tlb>
#import <MTPipelineLib.tlb>
#import <NameID.tlb>

#include <boost/thread/thread.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/bind.hpp>

#include "propids.h"
#include "mtprogids.h"
#include "test.h"

ANTLR_USING_NAMESPACE(std)
ANTLR_USING_NAMESPACE(antlr)

#include "testFrame.h"

void testStream(istream& istr)
{
	if(false == istr.fail())
	{
		char buf [256];
		istr.getline(buf, 256);
		cout << buf << ends << endl;
	}
}

void testIO(const string& filename)
{
	fstream fstr;
	fstr.open(filename.c_str());
	bool fail = fstr.fail();
	fail = fstr.is_open();
	testStream(fstr);
	fstr.close();
}

void testRuntimeValue()
{
	RuntimeValue val1 = RuntimeValue::createString("casdf");
	_ASSERT(0 == strcmp(val1.getStringPtr(), "casdf"));
	_ASSERT(0 == strcmp(val1.getStringPtr(), "casdf"));
	RuntimeValue val2 = RuntimeValue::createLong(12312312L);
	_ASSERT(val2.getLong() == 12312312);
	val2 = RuntimeValue::createLong(243L);
	_ASSERT(val2.getLong() == 243);
	RuntimeValue val3 = RuntimeValue::createBool(true);
	_ASSERT(val3.getBool() == true);
	val3 = RuntimeValue::createBool(false);
	_ASSERT(val3.getBool() == false);
	RuntimeValue val4 = RuntimeValue::createDouble(1231.2123);
	_ASSERT(val4.getDouble() == 1231.2123);
	val4 = RuntimeValue::createDouble(123233.23);
	_ASSERT(val4.getDouble() == 123233.23);
	DECIMAL dec;
	memset(&dec, 0, sizeof(DECIMAL));
	dec.scale = 2;
	dec.Hi32 = 0;
	dec.Lo64 = 2344423;
	RuntimeValue val5 = RuntimeValue::createDec(dec);
	_ASSERT(1 == VarDecCmp((LPDECIMAL) &val5.getDec(),&dec));
	_ASSERT(val5.getDec().scale == 2);
	_ASSERT(val5.getDec().Hi32 == 0);
	_ASSERT(val5.getDec().Lo64 == 2344423);

	RuntimeValue val6(val1);
	_ASSERT(0 == strcmp(val6.getStringPtr(), "casdf"));
	_ASSERT(0 == strcmp(val1.getStringPtr(), "casdf"));
	val6 = RuntimeValue::createString("pppp");
	_ASSERT(0 == strcmp(val6.getStringPtr(), "pppp"));
}

void testRuntimeValueCast()
{
	RuntimeValue val1 = RuntimeValue::createString("casdf");
	try {
		val1.castToBool();
		_ASSERT(false);
	} catch (MTSQLException& e) {
		cout << e.toString() << endl; 
	}

	val1 = RuntimeValue::createDouble(890.90);
	val1 = val1.castToDec();
	DECIMAL decVal;
	memset(&decVal, 0, sizeof(DECIMAL));
	decVal.scale = 2;
	decVal.Lo64 = 89090;
	RuntimeValue cmp = val1 == RuntimeValue::createDec(decVal);
	_ASSERT(cmp.getBool());
	
	val1 = val1.castToDouble();
	_ASSERT(val1.getDouble() == 890.90);
	
	val1 = val1.castToLong();
	_ASSERT(val1.getLong() == 890);

	val1 = val1.castToBool();
	_ASSERT(val1.getBool() == true);
}

void testRuntimeValueCastToString()
{
	RuntimeValue val = RuntimeValue::createLong(11123L);
	RuntimeValue cmp = val.castToString() == RuntimeValue::createString("11123");
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createDouble(123123.123);
	// TODO: FIX THIS CASE!!!!!!!!!
	//_ASSERT(val.castToString() == "1.23123123E+005");
	val = RuntimeValue::createString("sdfasdf");
	cmp = val.castToString() == RuntimeValue::createString("sdfasdf");
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createBool(true);
	cmp = val.castToString() == RuntimeValue::createString("true");
	_ASSERT(cmp.getBool());
	DECIMAL decVal;
	memset(&decVal, 0, sizeof(DECIMAL));
	decVal.scale = 2;
	decVal.Lo64 = 89090;
	val = RuntimeValue::createDec(decVal);
	cmp = val.castToString() == RuntimeValue::createString("890.9");
	_ASSERT(cmp.getBool());
}

void testRuntimeValueCastToDouble()
{
	RuntimeValue val = RuntimeValue::createLong(11123L);
	RuntimeValue cmp = val.castToDouble() == RuntimeValue::createDouble(11123.0);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createDouble(123123.123);
	cmp = val.castToDouble() == RuntimeValue::createDouble(123123.123);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createString("1.23123123E005");
	cmp = val.castToDouble() == RuntimeValue::createDouble(123123.123);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createBool(true);
	cmp = val.castToDouble() == RuntimeValue::createDouble(1.0);
	_ASSERT(cmp.getBool());
	DECIMAL decVal;
	memset(&decVal, 0, sizeof(DECIMAL));
	decVal.scale = 2;
	decVal.Lo64 = 89090;
	val = RuntimeValue::createDec(decVal);
	cmp = val.castToDouble() == RuntimeValue::createDouble(890.90);
	_ASSERT(cmp.getBool());
}

void testRuntimeValueCastToLong()
{
	RuntimeValue val = RuntimeValue::createLong(11123L);
	RuntimeValue cmp = val.castToLong() == RuntimeValue::createLong(11123L);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createDouble(123123.123);
	cmp = val.castToLong() == RuntimeValue::createLong(123123L);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createString("123123");
	cmp = val.castToLong() == RuntimeValue::createLong(123123L);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createBool(true);
	cmp = val.castToLong() == RuntimeValue::createLong(1L);
	_ASSERT(cmp.getBool());
	DECIMAL decVal;
	memset(&decVal, 0, sizeof(DECIMAL));
	decVal.scale = 2;
	decVal.Lo64 = 89090;
	val = RuntimeValue::createDec(decVal);
	cmp = val.castToLong() == RuntimeValue::createLong(891L);
	_ASSERT(cmp.getBool());
}

void testRuntimeValueCastToBool()
{
	RuntimeValue val = RuntimeValue::createLong(11123L);
	RuntimeValue cmp = val.castToBool() == RuntimeValue::createBool(true);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createLong(0L);
	cmp = val.castToBool() == RuntimeValue::createBool(false);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createDouble(123123.123);
	cmp = val.castToBool() == RuntimeValue::createBool(true);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createString("false");
	cmp = val.castToBool() == RuntimeValue::createBool(false);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createBool(true);
	cmp = val.castToBool() == RuntimeValue::createBool(true);
	_ASSERT(cmp.getBool());
	DECIMAL decVal;
	memset(&decVal, 0, sizeof(DECIMAL));
	val = RuntimeValue::createDec(decVal);
	cmp = val.castToBool() == RuntimeValue::createBool(false);
	_ASSERT(cmp.getBool());
	memset(&decVal, 0, sizeof(DECIMAL));
	decVal.scale = 2;
	decVal.Lo64 = 238493;
	val = RuntimeValue::createDec(decVal);
	cmp = val.castToBool() == RuntimeValue::createBool(true);
	_ASSERT(cmp.getBool());
}

void testRuntimeValueCastToDec()
{
	DECIMAL decVal;
	memset(&decVal, 0, sizeof(DECIMAL));
	RuntimeValue val = RuntimeValue::createLong(11123L);
	decVal.Lo64 = 11123;
	RuntimeValue cmp = val.castToDec() == RuntimeValue::createDec(decVal);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createDouble(123123.123);
	decVal.scale = 3;
	decVal.Lo64 = 123123123;
	cmp = val.castToDec() == RuntimeValue::createDec(decVal);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createBool(false);
	decVal.scale = 0;
	decVal.Lo64 = 0;
	cmp = val.castToDec() == RuntimeValue::createDec(decVal);
	_ASSERT(cmp.getBool());
	val = RuntimeValue::createBool(true);
	decVal.scale = 0;
	decVal.Lo64 = 1;
	cmp = val.castToDec() == RuntimeValue::createDec(decVal);
	_ASSERT(cmp.getBool());
}

//  void testTestRuntimeEnvironment()
//  {
//  	TestRuntimeEnvironment mTestEnv;
//  	const Access* var1 = mTestEnv.allocateVariable("var1");
//  	mTestEnv.setValue(var1, "strval");
//  	_ASSERT(mTestEnv.getValue(var1) == "strval");

//  	vector<RuntimeValue> args;
//  	args.push_back("asdfjkl;");
//  	args.push_back(2L);
//  	args.push_back(3L);
//  	RuntimeValue ret = mTestEnv.executePrimitiveFunction("substr", args);
//  	_ASSERT(ret == "sdf");
//  }



class TestExecutable
{
private:
	MTSQLTestGlobalCompileEnvironment globalEnvironment;
	MTSQLInterpreter* interpreter;
	MTSQLExecutable* exe;
	int iterations;

	MTSQLTestGlobalRuntimeEnvironment globalRuntime;
public:
	TestExecutable(int numExec) : iterations(numExec)
	{
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS DECLARE @d VARCHAR SET @d = CAST(@a AS VARCHAR)");

		interpreter = new MTSQLInterpreter(&globalEnvironment);

		exe = interpreter->analyze(str.c_str());
		_ASSERT(NULL != exe);
	}

	void Execute()
	{
		globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(1000L));
		//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
		globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(10L));
		globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &RuntimeValue::createLong(0L));
		exe->exec(&globalRuntime);
	}
	
	void RunTest()
	{
		for(int i=0; i<iterations; i++)
		{
			Execute();
		}
	}

	static unsigned int __stdcall RunTest(void* arg)
	{
		TestExecutable* texe = (TestExecutable*)arg;
		texe->RunTest();
		return 0;
	}
};

class TestBatchQuery
{
public:
  static void CompileQuery(std::wstring query)
  {
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
    MTSQLInterpreter interpreter (&globalEnvironment);
    BatchQuery * batch = NULL;
    if(NULL != interpreter.analyze(query.c_str()))
    {
      batch = interpreter.analyzeQuery();
    }

    std::vector<MTSQLTestGlobalRuntimeEnvironment *> runtimes;
    std::vector<ActivationRecord *> activations;
    for(int i=0; i<1000; i++)
    {
      runtimes.push_back(new MTSQLTestGlobalRuntimeEnvironment());
      activations.push_back(runtimes.back()->getActivationRecord());
      activations.back()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(i+1));
    }
    batch->ExecuteQuery(activations);

    for(int i=0; i<1000; i++)
    {
      RuntimeValue tmp;
      activations[i]->getStringValue(globalEnvironment.getFrame()->getVariable(1).get(), &tmp);
      cout << tmp.getStringPtr() << endl;
      delete runtimes[i];
    }
  }

  static void Test1()
  {
    CompileQuery(L"CREATE PROCEDURE test @id_enum_data INTEGER @nm_enum_data VARCHAR AS SELECT ed.nm_enum_data INTO @nm_enum_data FROM t_enum_data ed WHERE ed.id_enum_data=@id_enum_data");
  }
};


class TestNewInterpreter
{
public: 
  static void TestGlobalVariables()
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS  SET @c = @a + @b");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
    MTSQLTestGlobalRuntimeEnvironment globalRuntime;
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(1000L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(10L));
    TestRuntimeEnvironment renv(globalRuntime.getActivationRecord());
    exe->execCompiled(&globalRuntime);
    RuntimeValue val;
    globalRuntime.getActivationRecord()->getLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &val);
    RuntimeValue cmp = (RuntimeValue::createLong(1010L) == val);
    if(!cmp.getBool())
    {
      _ASSERT(false);
    }
  }
  static void TestLocalVariables()
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS  DECLARE @d INTEGER SET @d = @a + @b SET @c = @b*@d");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
    MTSQLTestGlobalRuntimeEnvironment globalRuntime;
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(1000L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(10L));
    TestRuntimeEnvironment renv(globalRuntime.getActivationRecord());
    exe->execCompiled(&globalRuntime);
    RuntimeValue val;
    globalRuntime.getActivationRecord()->getLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &val);
    RuntimeValue cmp = (RuntimeValue::createLong(10100L) == val);
    if(!cmp.getBool())
    {
      _ASSERT(false);
    }
  }
  static void TestWhileLoop()
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS "
               L"DECLARE @d INTEGER "
               L"SET @c = 0 "
               L"SET @d = @b "
               L"WHILE @d > @a "
               L"BEGIN "
               L"SET @c = @c + 1 "
               L"SET @d = @d - 1 "
               L"END "
               L"SET @c = 2*@c");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
    MTSQLTestGlobalRuntimeEnvironment globalRuntime;
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(0L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(100L));
    TestRuntimeEnvironment renv(globalRuntime.getActivationRecord());
    LARGE_INTEGER freq, tick, tock;
    ::QueryPerformanceFrequency(&freq);
    ::QueryPerformanceCounter(&tick);
    exe->execCompiled(&globalRuntime);
    ::QueryPerformanceCounter(&tock);
    long ms = (long) ((1000000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
    std::cout << "New interpreter TestWhileLoop " << ms << " microseconds" << std::endl;
    RuntimeValue val;
    globalRuntime.getActivationRecord()->getLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &val);
    RuntimeValue cmp = (RuntimeValue::createLong(200L) == val);
    if(!cmp.getBool())
    {
      _ASSERT(false);
    }

    ::QueryPerformanceCounter(&tick);
    exe->exec(&globalRuntime);
    ::QueryPerformanceCounter(&tock);
    ms = (long) ((1000000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
    std::cout << "Antlr interpreter TestWhileLoop " << ms << " microseconds" << std::endl;
  }
  static void TestIf()
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS "
               L"DECLARE @d INTEGER "
               L"SET @d = @b "
               L"IF @d > @a "
               L"SET @c = @d + 1 "
               L"ELSE "
               L"SET @c = @d - 1 "
               L"SET @c = 2*@c");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
    MTSQLTestGlobalRuntimeEnvironment globalRuntime;
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(0L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(100L));
    TestRuntimeEnvironment renv(globalRuntime.getActivationRecord());
    exe->execCompiled(&globalRuntime);
    RuntimeValue val;
    globalRuntime.getActivationRecord()->getLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &val);
    RuntimeValue cmp = (RuntimeValue::createLong(202L) == val);
    if(!cmp.getBool())
    {
      _ASSERT(false);
    }
  }
};

class TestNewInterpreterWithSharedSession
{
public: 
  static void TestGlobalVariables(MTSQLSharedSessionWrapper * session)
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    SYSCONTEXTLib::IMTLogPtr logger(__uuidof(SYSCONTEXTLib::MTLog));
    logger->Init("logging", "[MTSQLSharedSession]");

    NAMEIDLib::IMTNameIDPtr nameID(__uuidof(NAMEIDLib::MTNameID));
    MTSQLSessionCompileEnvironment globalEnvironment(reinterpret_cast<MTPipelineLib::IMTLog *>(logger.GetInterfacePtr()), 
                                                           reinterpret_cast<MTPipelineLib::IMTNameID *>(nameID.GetInterfacePtr()));
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS  SET @c = @a + @b");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
        
    // Initialize value in the session manually.
    // Getnameid for a,b,c
    int addr_a = nameID->GetNameID("a");
    int addr_b = nameID->GetNameID("b");
    int addr_c = nameID->GetNameID("c");
    session->SetInt32Value(addr_a, 1000);
    session->SetInt32Value(addr_b, 10);

    // Execute
    MTSQLSharedSessionRuntimeEnvironment<> renv(logger, session, NULL);
    exe->execCompiled(&renv);

    // Check results
    RuntimeValue val;
    session->GetInt32Value(addr_c, &val);
    int c = val.getLong();
    if (c == 1010)
    {
      std::cout << "Test passed" << std::endl;
    }
    else
    {
      std::cerr << "Test failed: " << c << std::endl;
    }
  }
  static void TestSimplePerformance(MTSQLSharedSessionWrapper * session)
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    SYSCONTEXTLib::IMTLogPtr logger(__uuidof(SYSCONTEXTLib::MTLog));
    logger->Init("logging", "[MTSQLSharedSession]");

    NAMEIDLib::IMTNameIDPtr nameID(__uuidof(NAMEIDLib::MTNameID));
    MTSQLSessionCompileEnvironment globalEnvironment(reinterpret_cast<MTPipelineLib::IMTLog *>(logger.GetInterfacePtr()), 
                                                           reinterpret_cast<MTPipelineLib::IMTNameID *>(nameID.GetInterfacePtr()));
		wstring str(L"CREATE PROCEDURE foo @a VARCHAR AS  SET @a = 'HEY'");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
        
    // Initialize value in the session manually.
    // Getnameid for a,b,c
    int addr_a = nameID->GetNameID("a");

    LARGE_INTEGER tick, tock, freq;
    ::QueryPerformanceCounter(&tick);
    // Execute a number of times
    for(int i = 0; i<1000000; i++)
    {
      MTSQLSharedSessionRuntimeEnvironment<> renv(logger, session, NULL);
      exe->execCompiled(&renv);
    }
    ::QueryPerformanceCounter(&tock);
    ::QueryPerformanceFrequency(&freq);
    std::cout << (1000*(tock.QuadPart - tick.QuadPart))/freq.QuadPart << " ms" << std::endl;
    // Check results
    RuntimeValue val;
    session->GetStringValue(addr_a, &val);
    std::wstring a(val.getWStringPtr());
    if (a == std::wstring(L"HEY"))
    {
      std::cout << "Test passed" << std::endl;
    }
    else
    {
      std::cerr << "Test failed: " << a.c_str() << std::endl;
    }
  }
  static void TestCalcDiscountPerformance(MTSQLSharedSessionWrapper * session)
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    SYSCONTEXTLib::IMTLogPtr logger(__uuidof(SYSCONTEXTLib::MTLog));
    logger->Init("logging", "[MTSQLSharedSession]");

    NAMEIDLib::IMTNameIDPtr nameID(__uuidof(NAMEIDLib::MTNameID));
    MTSQLSessionCompileEnvironment globalEnvironment(reinterpret_cast<MTPipelineLib::IMTLog *>(logger.GetInterfacePtr()), 
                                                           reinterpret_cast<MTPipelineLib::IMTNameID *>(nameID.GetInterfacePtr()));
		wstring str(L"CREATE PROCEDURE CalcTotalDiscount "	
L"	    @BridgeAmount DECIMAL \n"
L"			@TransportAmount DECIMAL\n"
L"			-- @ConnectionMinutes DECIMAL\n"
L"			@DiscountPercent DECIMAL\n"
L"			@BridgeAmount_Discount DECIMAL\n"
L"			@TransportAmount_Discount DECIMAL\n"
L"			@TotalDiscount DECIMAL\n"
L"			@_Amount DECIMAL\n"
L"			@_Currency VARCHAR\n"
L"			@strTemp VARCHAR\n"
L"			AS\n"
L"			\n"
L"			declare @RoundDigits INTEGER;\n"
L"\n"
L"			IF @_Currency = 'JPY'\n"
L"				SET @RoundDigits = 0\n"
L"			ELSE\n"
L"				SET @RoundDigits = 2;\n"
L"\n"
L"			SET @strTemp = '';\n"
L"			SET @BridgeAmount_Discount = 0.0;\n"
L"			SET @TransportAmount_Discount = 0.0;\n"
L"			SET @TotalDiscount = 0.0;\n"
L"			\n"
L"			IF (@DiscountPercent <= 0.0)\n"
L"				BEGIN\n"
L"					PRINT '[SUPRA][CalcTotalDiscount] DiscountPercent = ' + CAST(@DiscountPercent AS VARCHAR) + ', No discounts to calculate';\n"
L"					RETURN;\n"
L"				END\n"
L"\n"
L"				\n"
L"				BEGIN\n"
L"					SET @strTemp = @strTemp + '(Bridge Amount)' + CAST(@BridgeAmount as VARCHAR);\n"
L"					SET @BridgeAmount_Discount = round(@BridgeAmount * round(@DiscountPercent/100.0,2),@RoundDigits);\n"
L"					SET @strTemp = @strTemp + ' - (BridgeAmount_Discount)' + CAST(@BridgeAmount_Discount as VARCHAR);\n"
L"					SET @BridgeAmount = @BridgeAmount - @BridgeAmount_Discount;\n"
L"					SET @strTemp = @strTemp + ' = (BridgeAmount)' + CAST(@BridgeAmount as VARCHAR);\n"
L"					-- Subtract Bridge discount from the final amount\n"
L"					SET @_Amount = round(@_Amount - @BridgeAmount_Discount,@RoundDigits);\n"
L"\n"
L"				END	\n"
L"					\n"
L"				SET @strTemp = '';\n"
L"				\n"
L"				BEGIN\n"
L"					SET @strTemp = @strTemp + '(TransportAmount)' + CAST(@TransportAmount as VARCHAR);\n"
L"					SET @TransportAmount_Discount = round(@TransportAmount * round(@DiscountPercent/100.0,2),@RoundDigits);\n"
L"					SET @strTemp = @strTemp + ' - (TransportAmount_Discount)' + CAST(@TransportAmount_Discount as VARCHAR);\n"
L"					SET @TransportAmount = @TransportAmount - @TransportAmount_Discount;\n"
L"					SET @strTemp = @strTemp + ' = (TransportAmount)' + CAST(@TransportAmount as VARCHAR);\n"
L"					-- Subtract Transport discount from the final amount\n"
L"					SET @_Amount = round(@_Amount - @TransportAmount_Discount,@RoundDigits);\n"
                L"				END\n");
		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
        
    // Initialize value in the session manually.
    // Getnameid for a,b,c
    int addr_DiscountPercent = nameID->GetNameID("DiscountPercent");
    int addr_BridgeAmount = nameID->GetNameID("BridgeAmount");
    int addr_TransportAmount = nameID->GetNameID("TransportAmount");
    int addr_Currency = nameID->GetNameID("_Currency");

    RuntimeValue val;
    RuntimeValue tmp;
    tmp.assignLong(10);
    val.assignDecimal(tmp.castToDec().getDecPtr());
    session->SetDecimalValue(addr_DiscountPercent, val.getDecPtr());
    tmp.assignLong(50);
    val.assignDecimal(tmp.castToDec().getDecPtr());
    session->SetDecimalValue(addr_BridgeAmount, val.getDecPtr());
    tmp.assignLong(60);
    val.assignDecimal(tmp.castToDec().getDecPtr());
    session->SetDecimalValue(addr_TransportAmount, val.getDecPtr());
    val.assignWString(L"USD");
    session->SetStringValue(addr_DiscountPercent, val.getWStringPtr());

    LARGE_INTEGER tick, tock, freq;
    MTSQLSharedSessionRuntimeEnvironment<> renv(logger, session, NULL);
    ::QueryPerformanceCounter(&tick);
    exe->execCompiled(&renv);
    ::QueryPerformanceCounter(&tock);
    ::QueryPerformanceFrequency(&freq);
    long ms = (long) ((1000000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
    std::cout << "Register machine CalcDiscount " << ms << " microseconds" << std::endl;
  }
  static void TestLocalVariables()
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS  DECLARE @d INTEGER SET @d = @a + @b SET @c = @b*@d");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
    MTSQLTestGlobalRuntimeEnvironment globalRuntime;
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(1000L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(10L));
    TestRuntimeEnvironment renv(globalRuntime.getActivationRecord());
    exe->execCompiled(&globalRuntime);
    RuntimeValue val;
    globalRuntime.getActivationRecord()->getLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &val);
    RuntimeValue cmp = (RuntimeValue::createLong(10100L) == val);
    if(!cmp.getBool())
    {
      _ASSERT(false);
    }
  }
  static void TestWhileLoop()
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS "
               L"DECLARE @d INTEGER "
               L"SET @c = 0 "
               L"SET @d = @b "
               L"WHILE @d > @a "
               L"BEGIN "
               L"SET @c = @c + 1 "
               L"SET @d = @d - 1 "
               L"END "
               L"SET @c = 2*@c");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
    MTSQLTestGlobalRuntimeEnvironment globalRuntime;
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(0L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(100L));
    TestRuntimeEnvironment renv(globalRuntime.getActivationRecord());
    LARGE_INTEGER freq, tick, tock;
    ::QueryPerformanceFrequency(&freq);
    ::QueryPerformanceCounter(&tick);
    exe->execCompiled(&globalRuntime);
    ::QueryPerformanceCounter(&tock);
    long ms = (long) ((1000000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
    std::cout << "New interpreter TestWhileLoop " << ms << " microseconds" << std::endl;
    RuntimeValue val;
    globalRuntime.getActivationRecord()->getLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &val);
    RuntimeValue cmp = (RuntimeValue::createLong(200L) == val);
    if(!cmp.getBool())
    {
      _ASSERT(false);
    }

    ::QueryPerformanceCounter(&tick);
    exe->exec(&globalRuntime);
    ::QueryPerformanceCounter(&tock);
    ms = (long) ((1000000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
    std::cout << "Antlr interpreter TestWhileLoop " << ms << " microseconds" << std::endl;
  }
  static void TestIf()
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
    MTSQLTestGlobalCompileEnvironment globalEnvironment;
		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS "
               L"DECLARE @d INTEGER "
               L"SET @d = @b "
               L"IF @d > @a "
               L"SET @c = @d + 1 "
               L"ELSE "
               L"SET @c = @d - 1 "
               L"SET @c = 2*@c");

		MTSQLInterpreter * interpreter = new MTSQLInterpreter(&globalEnvironment);

		MTSQLExecutable * exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
    MTSQLTestGlobalRuntimeEnvironment globalRuntime;
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(0L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
    globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(100L));
    TestRuntimeEnvironment renv(globalRuntime.getActivationRecord());
    exe->execCompiled(&globalRuntime);
    RuntimeValue val;
    globalRuntime.getActivationRecord()->getLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &val);
    RuntimeValue cmp = (RuntimeValue::createLong(202L) == val);
    if(!cmp.getBool())
    {
      _ASSERT(false);
    }
  }
};

class TestScalability
{
public:
  MTSQLTestGlobalCompileEnvironment globalEnvironment;
  MTSQLInterpreter * interpreter;
  MTSQLExecutable * exe;
  MTSQLTestGlobalRuntimeEnvironment globalRuntime;

  TestScalability()
    :
    interpreter(NULL),
    exe(NULL)
  {
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
// 		wstring str(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER AS "
//                L"DECLARE @d INTEGER "
//                L"SET @c = 0 "
//                L"SET @d = @b "
//                L"WHILE @d > @a "
//                L"BEGIN "
//                L"SET @c = CASE @d % 2 WHEN 0 THEN @c + 1 ELSE @c+2 END "
//                L"SET @d = @d - 1 "
//                L"END "
//                L"SET @c = 2*@c");

    wstring str(
      L"CREATE PROCEDURE gen @intVal1 INTEGER @intVal2 INTEGER @intVal3 INTEGER \n"
      L"@datetimeVal1 DATETIME  @datetimeVal2 DATETIME  @datetimeVal3 DATETIME @strVal VARCHAR\n"
      L"@intValOut INTEGER OUTPUT @boolVal BOOLEAN OUTPUT @datetimeValOut DATETIME OUTPUT\n"
      L"@isNullValOut DATETIME OUTPUT @intCopyOut INTEGER OUTPUT @intLitOut INTEGER OUTPUT\n"
      L"AS\n"
      L"SET @intValOut = CASE WHEN @intVal2 >= @intVal1 AND @intVal2 <= @intVal3 THEN @intVal1 ELSE @intVal3 END\n"
      L"SET @boolVal = CASE WHEN 'Y' = @strVal THEN TRUE ELSE FALSE END\n"
      L"SET @datetimeValOut = CASE WHEN @datetimeVal2 >= @datetimeVal1 AND @datetimeVal2 <= @datetimeVal3 THEN @datetimeVal1 ELSE @datetimeVal3 END\n"
      L"SET @isNullValOut = CASE WHEN @datetimeVal2 IS NULL THEN @datetimeVal1 ELSE @datetimeVal3 END\n"
      L"SET @intCopyOut = @intVal3\n"
      L"SET @intLitOut = 233\n");

    interpreter = new MTSQLInterpreter(&globalEnvironment);
    exe = interpreter->analyze(str.c_str());
    exe->codeGenerate(&globalEnvironment);
    
  }
  ~TestScalability()
  {
    delete interpreter;
  }

  void Run()
  {
    for(int i=0; i<10000000; i++)
    {
      globalRuntime.getActivationRecord()->getValues()[0].assignLong(i%2);
      globalRuntime.getActivationRecord()->getValues()[1].assignLong(i%10);
      globalRuntime.getActivationRecord()->getValues()[2].assignLong(i%10);
      globalRuntime.getActivationRecord()->getValues()[3].assignDatetime(666662.1);
      globalRuntime.getActivationRecord()->getValues()[4].assignDatetime(7773.8);
      globalRuntime.getActivationRecord()->getValues()[5].assignDatetime(8832.0);
      globalRuntime.getActivationRecord()->getValues()[6].assignString("Y");
      exe->execCompiled(&globalRuntime);
    }
  }
};

int main(int argc, char* argv[])
{
  // initialize COM ...
  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);

// 	PipelinePropIDs::Init();
//   MTSQLSharedSessionFactoryWrapper server;
//   unsigned char uid[16];

//   std::vector<MTSQLSharedSessionWrapper *> sessions;

//   // Load up shmem with a bunch of sessions...

//   LARGE_INTEGER tick, tock, freq;
//   ::QueryPerformanceCounter(&tick);
//   for(int j=2; j<5000; j++)
//   {
//     memset(&uid[0], 0, 16);
//     *((int *) &uid[0]) = j;
//     sessions.push_back(new MTSQLSharedSessionWrapper());
//     server.InitSession(uid, NULL, 5, sessions.back());
//     // Put a bunch of properties on the session...
//     for(int k=1; k<=100; k++)
//     {
//       sessions.back()->SetInt32Value(k,k);
//     }
//   }
//   ::QueryPerformanceCounter(&tock);
//   ::QueryPerformanceFrequency(&freq);
//   std::cout << "Creating 5000 session took " << (1000LL*(tock.QuadPart-tick.QuadPart))/freq.QuadPart << " ms " << std::endl;

//   memset(&uid[0], 1, 16);
//   MTSQLSharedSessionWrapper session;
//   server.InitSession(uid, NULL, 5, &session);
//   session.SetStringValue(987, L"shjshdfaksdfhshdfkasdhfasf");
//   // Put a bunch of properties on the session...
//   for(int k=1; k<=1000; k++)
//   {
//     session.SetInt32Value(k,k);
//   }
//   ::QueryPerformanceCounter(&tick);
//   // Loop and read
//   for(int ii = 0; ii<1000000; ii++)
//   {
//     RuntimeValue rtval;
//     session.GetStringValue(987, &rtval);
//     const wchar_t * val = rtval.getWString().c_str();
//     std::wstring copy(val);
//   }
//   ::QueryPerformanceCounter(&tock);
//   ::QueryPerformanceFrequency(&freq);
//   std::cout << (1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart << " ms" << std::endl;

//   TestNewInterpreterWithSharedSession::TestGlobalVariables(&session);
// //   TestNewInterpreterWithSharedSession::TestSimplePerformance(&session);
//   TestNewInterpreterWithSharedSession::TestCalcDiscountPerformance(&session);

//   return 0;

	// Are we doing runtimevalue tests?
	bool runtimeValueTest=false;
	// Are we doing the file test?
	bool fileTest=false;
	string fname;
	// Are we doing the interpreter smoke test
	bool smokeTest = false;
	// Are we doing the multithread test?
	bool multithreadTest = false;
	bool scalabilityTest = false;
	int maxThreads = 4;
  bool registerMachineTest = false;
	int numThreads = 10;
	int numExec = 10000;

	// Parse the argv array to get parameters
	int i=1;
	while(i<argc)
	{
		if(0 == strcmp(argv[i], "-runtimevalue"))
		{
			runtimeValueTest = true;
			i += 1;
		}
		if(0 == strcmp(argv[i], "-register"))
		{
			registerMachineTest = true;
			i += 1;
		}
		else if(0 == strcmp(argv[i], "-file"))
		{
			fileTest = true;
			fname = argv[i+1];
			i += 2;
		}
		else if(0 == strcmp(argv[i], "-smoke"))
		{
			smokeTest = true;
			i += 1;
		}
		else if(0 == strcmp(argv[i], "-thread"))
		{
			multithreadTest = true;
			numThreads = atoi(argv[i+1]);
			numExec = atoi(argv[i+2]);
			i += 3;
		}
		else if(0 == strcmp(argv[i], "-scalability"))
		{
			scalabilityTest = true;
			maxThreads = atoi(argv[i+1]);
			i += 2;
		}
		else if(0 == strcmp(argv[i], "/?") || 0 == strcmp(argv[i], "-?"))
		{
			cout << "Usage: testmtsql [-runtimevalue] [-smoke] [-thread <numthreads> <iterations>] [-?]" << endl;
			return 0;
		}
		else
		{
			cerr << "Unknown command line argument" << endl;
			return -1;
		}
	}

  if (scalabilityTest)
  {
    for(int threadCount = 1; threadCount <= maxThreads; threadCount *= 2)
    {
      std::vector<boost::shared_ptr<TestScalability> > scalability;
      for(int i=0; i<threadCount; i++)
      {
        scalability.push_back(boost::shared_ptr<TestScalability>(new TestScalability));
      }
      std::vector<boost::shared_ptr<boost::thread> > threads;
    
      LARGE_INTEGER freq, tick, tock;
      ::QueryPerformanceFrequency(&freq);
      ::QueryPerformanceCounter(&tick);
      for(std::vector<boost::shared_ptr<TestScalability> >::iterator it = scalability.begin();
          it != scalability.end();
          ++it)
      {
        boost::function0<void> threadFunc = boost::bind(&TestScalability::Run, *it);
        // Create delegates for each partition InternalStart method and run in a thread
        threads.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
      }
      for(std::vector<boost::shared_ptr<boost::thread> >::iterator it=threads.begin();
          it != threads.end();
          ++it)
      {
        (*it)->join();
      }
      ::QueryPerformanceCounter(&tock);
      long ms = (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
      std::cout << "New interpreter " << threadCount << " threads TestWhileLoop " << ms << " milliseconds" << std::endl;
    }
  }

  if(registerMachineTest)
  {
    TestNewInterpreter::TestGlobalVariables();
    TestNewInterpreter::TestLocalVariables();
    TestNewInterpreter::TestWhileLoop();
    TestNewInterpreter::TestIf();
  }

	if(runtimeValueTest)
	{
		testRuntimeValue();
		testRuntimeValueCast();
		testRuntimeValueCastToString();
		testRuntimeValueCastToDouble();
		testRuntimeValueCastToLong();
		testRuntimeValueCastToBool();
		testRuntimeValueCastToDec();
	}
	//testTestRuntimeEnvironment();

	try {
		if(smokeTest)
		{
      TestBatchQuery::Test1();
			UnitTestMTSQLParser parserTest;
			parserTest.RunTests();
			UnitTestMTSQLAnalyzer analyzerTest;
			analyzerTest.RunTests();
			TestStandardLibrary libTest;
			libTest.RunTests();
			UnitTestMTSQLExecution execTest;
			execTest.RunTests();
		}

		// Default is to use stdin for input stream
		// if filename argument is passed use that.
		if(fileTest)
		{
			istream* istr = &cin;
			fstream fstr;
			if(argc > 1)
			{
				fname = argv[1];
				testIO(fname);
				fstr.open(fname.c_str());
				istr = &fstr;
			}

			// Due to stdio issues, I didn't want to expose istream
			// in MTSQLInterpreter interface.  So read the whole file
			// into a single string.
			string prog;
			char buf[1024];
			while(!istr->eof())
			{
				istr->read(buf, 1024);
				unsigned int numread = (unsigned int) istr->gcount();
				prog += string(buf, numread);
			}
			wstring wideProg;
			::ASCIIToWide(wideProg, (const char *)prog.c_str(), -1, CP_UTF8);
			MTSQLTestGlobalCompileEnvironment globalEnvironment;
			MTSQLInterpreter interpreter(&globalEnvironment);
			MTSQLExecutable* exe = interpreter.analyze(wideProg.c_str());

			MTSQLTestGlobalRuntimeEnvironment globalRuntime;
			globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(0).get(), &RuntimeValue::createLong(1000L));
			//globalRuntime.getActivationRecord()->setDoubleValue(MTOffsetAccess::create(1), 9807.34234);
			globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(1).get(), &RuntimeValue::createLong(10L));
			globalRuntime.getActivationRecord()->setLongValue(globalEnvironment.getFrame()->getVariable(2).get(), &RuntimeValue::createLong(0L));
			exe->exec(&globalRuntime);

			AccessPtr access = globalEnvironment.getFrame()->getVariable(0);
			AccessPtr access2 = globalEnvironment.getFrame()->getVariable(2);
			long numiter=0;
			DWORD dwTick = ::GetTickCount();
			for(long l=0; l<10; l++)
			{
				globalRuntime.getActivationRecord()->setLongValue(access.get(), &RuntimeValue::createLong(l));
				globalRuntime.getActivationRecord()->setLongValue(access2.get(), &RuntimeValue::createLong(l+1L));
				exe->exec(&globalRuntime);
//  			cout << "-------------" << endl;
//  			cout << "Param 1: " << globalRuntime.getActivationRecord()->getLongValue(access) << endl;
//  			cout << "Param 2: " << globalRuntime.getActivationRecord()->getLongValue(MTOffsetAccess::create(1)) << endl;
			}
			DWORD dwTock = ::GetTickCount();
			cout << "Number of iterations = " << l << "; number of milliseconds = " << (dwTock-dwTick) << endl;
		}

		if(multithreadTest)
		{
			vector<TestExecutable*> texes;

			if(numThreads > MAXIMUM_WAIT_OBJECTS)
			{
				cerr << "Too many threads specified; test only supports maximum of " << MAXIMUM_WAIT_OBJECTS << " threads" << endl;
				return -1;
			}

			HANDLE* threads = new HANDLE [numThreads];
			int i;
			for(i=0; i<numThreads; i++)
			{
				TestExecutable* texe = new TestExecutable(numExec);
				texes.push_back(texe);
//			threads[i] = (HANDLE) _beginthread(TestExecutable::RunTest, 0, texe);
				threads[i] = (HANDLE) _beginthreadex(NULL, 0, TestExecutable::RunTest, texe, CREATE_SUSPENDED, NULL);
				if (threads[i] == NULL)
				{
					DWORD dwErr = ::GetLastError();
					cerr << "Failed to create thread.  Error : " << dwErr << endl;
					return -1;
				}
			}

			// Crank up the threads
			for(i=0; i<numThreads; i++)
			{
				::ResumeThread(threads[i]);
			}

			DWORD dwResult = ::WaitForMultipleObjects(numThreads, threads, TRUE, INFINITE);
			if(dwResult < WAIT_OBJECT_0 || dwResult >= WAIT_OBJECT_0+numThreads) 
			{
				if(dwResult == WAIT_FAILED)
				{
					DWORD dwError = ::GetLastError();
					cerr<<"failed waiting for threads: error = " << dwError << endl;
				}
				else
				{
					cerr<<"failed waiting for threads: result = " << dwResult << endl;
				}
			}

			delete [] threads;
		}

	} catch(exception* e) {
		cerr << "exception: " << e->what() << endl;
		delete e;
	}

	return 0;
}
