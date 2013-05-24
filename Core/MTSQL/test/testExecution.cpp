#pragma warning( disable : 4786 ) 

#include <string>
#include <iostream>
#include <fstream>
#include <strstream>

#include "crtdbg.h"

#include "MTSQLInterpreter.h"

#include "MTSQLLexer.hpp"
#include "MTSQLParser.hpp"
#include "MTSQLTreeParser.hpp"
#include "MTSQLAST.h"

#include "AST.hpp"
#include "CommonAST.hpp"
#include "TokenStreamHiddenTokenFilter.hpp"
#include "CommonHiddenStreamToken.hpp"
#include "Token.hpp"

#include "testFrame.h"
#include "test.h"

static void AssertTrue(const RuntimeValue & val)
{
	_ASSERT(val.getBool());
}

static void AssertTrue(bool val)
{
	_ASSERT(val);
}

ANTLR_USING_NAMESPACE(std)
ANTLR_USING_NAMESPACE(antlr)

UnitTestMTSQLExecution::UnitTestMTSQLExecution()
{
}

void UnitTestMTSQLExecution::ExecuteProgram(const std::wstring& prog, const std::vector<RuntimeValue>& inputs, const std::vector<RuntimeValue>& outputs)
{
	// Don't terminate with an ends!  The STL will make this look like an EOF
	// which is what the parser wants.
	MTSQLTestGlobalCompileEnvironment globalEnvironment;
	MTSQLInterpreter interpreter(&globalEnvironment);
	MTSQLExecutable* exe = interpreter.analyze(prog.c_str());
	AssertTrue(NULL != exe);

	MTSQLTestGlobalRuntimeEnvironment globalRuntime;

	MTFrame* frame = globalEnvironment.getFrame();

	// Set the inputs
	for (std::vector<RuntimeValue>::size_type i = 0; i<inputs.size(); i++)
	{
		switch(inputs[i].getType())
		{
		case(RuntimeValue::eLong):
		{
			globalRuntime.getActivationRecord()->setLongValue(frame->getVariable(i).get(), &inputs[i]);
			break;
		}
		case(RuntimeValue::eDouble):
		{
			globalRuntime.getActivationRecord()->setDoubleValue(frame->getVariable(i).get(), &inputs[i]);
			break;
		}
		case(RuntimeValue::eStr):
		{
			globalRuntime.getActivationRecord()->setStringValue(frame->getVariable(i).get(), &inputs[i]);
			break;
		}
		case(RuntimeValue::eWStr):
		{
			globalRuntime.getActivationRecord()->setWStringValue(frame->getVariable(i).get(), &inputs[i]);
			break;
		}
		case(RuntimeValue::eDec):
		{
			globalRuntime.getActivationRecord()->setDecimalValue(frame->getVariable(i).get(), &inputs[i]);
			break;
		}
		case(RuntimeValue::eBool):
		{
			globalRuntime.getActivationRecord()->setBooleanValue(frame->getVariable(i).get(), &inputs[i]);
			break;
		}
		default:
		{
			AssertTrue(false);
		}
		}
	}
	// Execute the program
	try {
		exe->exec(&globalRuntime);
	} catch (MTSQLException e) {
		cerr << e.toString().c_str() << endl;
		AssertTrue(false);
	}
  RuntimeValue val;
	// Check the outputs
	for(i = 0; i<outputs.size(); i++)
	{
		switch(outputs[i].getType())
		{
		case(RuntimeValue::eLong):
		{
      globalRuntime.getActivationRecord()->getLongValue(frame->getVariable(i+inputs.size()).get(), &val);
			AssertTrue(outputs[i] == val);
			break;
		}
		case(RuntimeValue::eDouble):
		{
      globalRuntime.getActivationRecord()->getDoubleValue(frame->getVariable(i+inputs.size()).get(), &val);
			AssertTrue(outputs[i] == val);
			break;
		}
		case(RuntimeValue::eStr):
		{
      globalRuntime.getActivationRecord()->getStringValue(frame->getVariable(i+inputs.size()).get(), &val);
			AssertTrue(outputs[i] == val);
			break;
		}
		case(RuntimeValue::eWStr):
		{
      globalRuntime.getActivationRecord()->getWStringValue(frame->getVariable(i+inputs.size()).get(), &val);
			AssertTrue(outputs[i] == val);
			break;
		}
		case(RuntimeValue::eDec):
		{
      globalRuntime.getActivationRecord()->getDecimalValue(frame->getVariable(i+inputs.size()).get(), &val);
			AssertTrue(outputs[i] == val);
			break;
		}
		case(RuntimeValue::eBool):
		{
      globalRuntime.getActivationRecord()->getBooleanValue(frame->getVariable(i+inputs.size()).get(), &val);
			AssertTrue(outputs[i] == val);
			break;
		}
		default:
		{
			AssertTrue(false);
		}
		}
	}
}

void UnitTestMTSQLExecution::ArithmeticTests()
{
	std::vector<RuntimeValue> inputs;
	std::vector<RuntimeValue> outputs;

	inputs.push_back(RuntimeValue::createLong(10912L));
	inputs.push_back(RuntimeValue::createLong(-998L));
	outputs.push_back(RuntimeValue::createLong(10912L + -998L));
	outputs.push_back(RuntimeValue::createLong(10912L - -998L));
	outputs.push_back(RuntimeValue::createLong(10912L * -998L));
	outputs.push_back(RuntimeValue::createLong(10912L / -998L));
	outputs.push_back(RuntimeValue::createLong(10912L % -998L));
	ExecuteProgram(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c INTEGER @d INTEGER @e INTEGER @f INTEGER @g INTEGER AS SET @c = @a + @b; SET @d = @a - @b; SET @e = @a * @b; SET @f = @a / @b; SET @g = @a % @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();

	inputs.push_back(RuntimeValue::createDouble(10912.98));
	inputs.push_back(RuntimeValue::createDouble(-998.755));
	outputs.push_back(RuntimeValue::createDouble(10912.98 + -998.755));
	outputs.push_back(RuntimeValue::createDouble(10912.98 - -998.755));
	outputs.push_back(RuntimeValue::createDouble(10912.98 * -998.755));
	outputs.push_back(RuntimeValue::createDouble(10912.98 / -998.755));
	ExecuteProgram(L"CREATE PROCEDURE foo @a DOUBLE @b DOUBLE @c DOUBLE @d DOUBLE @e DOUBLE @f DOUBLE  AS SET @c = @a + @b; SET @d = @a - @b; SET @e = @a * @b; SET @f = @a / @b; ", inputs, outputs); 
	inputs.clear();
	outputs.clear();

	DECIMAL dec;
	memset(&dec, 0, sizeof(DECIMAL));
	dec.scale = 2;
	dec.Lo64 = 1091298;
	dec.sign = 0;
	inputs.push_back(RuntimeValue::createDec(dec));
	dec.scale = 3;
	dec.Lo64 = 998755;
	dec.sign = 0x80;
	inputs.push_back(RuntimeValue::createDec(dec));
	dec.scale = 3;
	dec.Lo64 = 9914225;
	dec.sign = 0;
	outputs.push_back(RuntimeValue::createDec(dec));
	dec.scale = 3;
	dec.Lo64 = 11911735;
	dec.sign = 0;
	outputs.push_back(RuntimeValue::createDec(dec));
	dec.scale = 4;
	dec.Lo64 = 108993933399;
	dec.sign = 0x80;
	outputs.push_back(RuntimeValue::createDec(dec));
	dec.scale = 6;
	dec.Lo64 = 10926584;
	dec.sign = 0x80;
	outputs.push_back(RuntimeValue::createDec(dec));
	ExecuteProgram(L"CREATE PROCEDURE foo @a DECIMAL @b DECIMAL @c DECIMAL @d DECIMAL @e DECIMAL @f DECIMAL  AS SET @c = @a + @b; SET @d = @a - @b; SET @e = @a * @b; SET @f = @a / @b; ", inputs, outputs); 
	inputs.clear();
	outputs.clear();

}

void UnitTestMTSQLExecution::ConditionalTests()
{
	std::vector<RuntimeValue> inputs;
	std::vector<RuntimeValue> outputs;

	inputs.push_back(RuntimeValue::createLong(10912L));
	inputs.push_back(RuntimeValue::createLong(-998L));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createLong(10912L));
	inputs.push_back(RuntimeValue::createLong(10912L));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a INTEGER @b INTEGER @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createDouble(10912.98));
	inputs.push_back(RuntimeValue::createDouble(-998.989));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a DOUBLE @b DOUBLE @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createDouble(10912.99));
	inputs.push_back(RuntimeValue::createDouble(10912.99));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a DOUBLE @b DOUBLE @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

	DECIMAL dec;
	memset(&dec, 0, sizeof(DECIMAL));
	dec.scale = 2;
	dec.Lo64 = 1091298;
	inputs.push_back(RuntimeValue::createDec(dec));
	dec.scale = 3;
	dec.sign = 0x80;
	dec.Lo64 = 998989;
	inputs.push_back(RuntimeValue::createDec(dec));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a DECIMAL @b DECIMAL @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

	dec.scale = 4;
	dec.Lo64 = 90923424;
	inputs.push_back(RuntimeValue::createDec(dec));
	inputs.push_back(RuntimeValue::createDec(dec));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a DECIMAL @b DECIMAL @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createString("LLleradasdf"));
	inputs.push_back(RuntimeValue::createString("LLLerasdfe"));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a VARCHAR @b VARCHAR @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createString("kjPEjer82934"));
	inputs.push_back(RuntimeValue::createString("kjPEjer82934"));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a VARCHAR @b VARCHAR @c BOOLEAN @d BOOLEAN @e BOOLEAN @f BOOLEAN  @h BOOLEAN @i BOOLEAN AS SET @c = @a = @b; SET @d = @a <> @b; SET @e = @a < @b; SET @f = @a > @b; SET @h = @a <= @b; SET @i = @a >= @b;", inputs, outputs); 
	inputs.clear();
	outputs.clear();	

}

void UnitTestMTSQLExecution::LogicalTests()
{
	std::vector<RuntimeValue> inputs;
	std::vector<RuntimeValue> outputs;

	inputs.push_back(RuntimeValue::createBool(true));
	inputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	ExecuteProgram(L"CREATE PROCEDURE foo @a BOOLEAN @b BOOLEAN @c BOOLEAN @d BOOLEAN @e BOOLEAN AS SET @c = @a AND @b; SET @d = @a OR @b; SET @e = NOT @a; ", inputs, outputs);
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createBool(false));
	inputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a BOOLEAN @b BOOLEAN @c BOOLEAN @d BOOLEAN @e BOOLEAN AS SET @c = @a AND @b; SET @d = @a OR @b; SET @e = NOT @a; ", inputs, outputs);
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createBool(false));
	inputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(false));
	outputs.push_back(RuntimeValue::createBool(true));
	ExecuteProgram(L"CREATE PROCEDURE foo @a BOOLEAN @b BOOLEAN @c BOOLEAN @d BOOLEAN @e BOOLEAN AS SET @c = @a AND @b; SET @d = @a OR @b; SET @e = NOT @a; ", inputs, outputs);
	inputs.clear();
	outputs.clear();	

	inputs.push_back(RuntimeValue::createBool(true));
	inputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(true));
	outputs.push_back(RuntimeValue::createBool(false));
	ExecuteProgram(L"CREATE PROCEDURE foo @a BOOLEAN @b BOOLEAN @c BOOLEAN @d BOOLEAN @e BOOLEAN AS SET @c = @a AND @b; SET @d = @a OR @b; SET @e = NOT @a; ", inputs, outputs);
	inputs.clear();
	outputs.clear();	
}

void UnitTestMTSQLExecution::RunTests()
{
	ArithmeticTests();
	ConditionalTests();
	LogicalTests();
}
