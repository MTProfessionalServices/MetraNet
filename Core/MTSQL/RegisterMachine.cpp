#include <vector>
#include <sstream>
#include "RegisterMachine.h"
#include "MTSQLSelectCommand.h"
#include "RuntimeValueCast.h"

std::string MTSQLInstruction::PrintType(Type type)
{
  switch(type)
  {
  case GOTO: { return "GOTO"; }
  case BRANCH_ON_CONDITION: { return "BRANCH_ON_CONDITION"; }
  case RETURN: { return "RETURN"; }
  case LOAD_NULL_IMMEDIATE: { return "LOAD_NULL_IMMEDIATE"; }
  case MOVE: { return "MOVE"; }
  case GT: { return "GT"; } 
  case GTEQ: { return "GTEQ"; } 
  case LTN: { return "LTN"; } 
  case LTEQ: { return "LTEQ"; } 
  case EQUALS: { return "EQUALS"; } 
  case NOTEQUALS: { return "NOTEQUALS"; } 
  case ISNULL: { return "ISNULL"; } 
  case FUN_CALL: { return "FUN_CALL"; } 
  case GLOBAL_INTEGER_SETMEM: { return "GLOBAL_INTEGER_SETMEM"; }
  case GLOBAL_INTEGER_GETMEM: { return "GLOBAL_INTEGER_GETMEM"; } 
  case INTEGER_PLUS: { return "INTEGER_PLUS"; } 
  case INTEGER_MINUS: { return "INTEGER_MINUS"; } 
  case INTEGER_UNARY_MINUS: { return "INTEGER_UNARY_MINUS"; } 
  case INTEGER_TIMES: { return "INTEGER_TIMES"; } 
  case INTEGER_DIVIDE: { return "INTEGER_DIVIDE"; } 
  case CAST_TO_INTEGER: { return "CAST_TO_INTEGER"; } 
  case INTEGER_MODULUS: { return "INTEGER_MODULUS"; } 
  case LOAD_INTEGER_IMMEDIATE: { return "LOAD_INTEGER_IMMEDIATE"; }
  case GLOBAL_BIGINT_SETMEM: { return "GLOBAL_BIGINT_SETMEM"; }
  case GLOBAL_BIGINT_GETMEM: { return "GLOBAL_BIGINT_GETMEM"; } 
  case BIGINT_PLUS: { return "BIGINT_PLUS"; } 
  case BIGINT_MINUS: { return "BIGINT_MINUS"; } 
  case BIGINT_UNARY_MINUS: { return "BIGINT_UNARY_MINUS"; } 
  case BIGINT_TIMES: { return "BIGINT_TIMES"; } 
  case BIGINT_DIVIDE: { return "BIGINT_DIVIDE"; } 
  case CAST_TO_BIGINT: { return "CAST_TO_BIGINT"; } 
  case BIGINT_MODULUS: { return "BIGINT_MODULUS"; } 
  case LOAD_BIGINT_IMMEDIATE: { return "LOAD_BIGINT_IMMEDIATE"; }
  case GLOBAL_DECIMAL_SETMEM: { return "GLOBAL_DECIMAL_SETMEM"; }
  case GLOBAL_DECIMAL_GETMEM: { return "GLOBAL_DECIMAL_GETMEM"; } 
  case DECIMAL_PLUS: { return "DECIMAL_PLUS"; } 
  case DECIMAL_MINUS: { return "DECIMAL_MINUS"; } 
  case DECIMAL_UNARY_MINUS: { return "DECIMAL_UNARY_MINUS"; } 
  case DECIMAL_TIMES: { return "DECIMAL_TIMES"; } 
  case DECIMAL_DIVIDE: { return "DECIMAL_DIVIDE"; } 
  case CAST_TO_DECIMAL: { return "CAST_TO_DECIMAL"; } 
  case LOAD_DECIMAL_IMMEDIATE: { return "LOAD_DECIMAL_IMMEDIATE"; }
  case GLOBAL_DOUBLE_SETMEM: { return "GLOBAL_DOUBLE_SETMEM"; }
  case GLOBAL_DOUBLE_GETMEM: { return "GLOBAL_DOUBLE_GETMEM"; } 
  case DOUBLE_PLUS: { return "DOUBLE_PLUS"; } 
  case DOUBLE_MINUS: { return "DOUBLE_MINUS"; } 
  case DOUBLE_UNARY_MINUS: { return "DOUBLE_UNARY_MINUS"; } 
  case DOUBLE_TIMES: { return "DOUBLE_TIMES"; } 
  case DOUBLE_DIVIDE: { return "DOUBLE_DIVIDE"; } 
  case CAST_TO_DOUBLE: { return "CAST_TO_DOUBLE"; } 
  case LOAD_DOUBLE_IMMEDIATE: { return "LOAD_DOUBLE_IMMEDIATE"; }
  case GLOBAL_STRING_SETMEM: { return "GLOBAL_STRING_SETMEM"; }
  case GLOBAL_STRING_GETMEM: { return "GLOBAL_STRING_GETMEM"; } 
  case STRING_PLUS: { return "STRING_PLUS"; } 
  case CAST_TO_STRING: { return "CAST_TO_STRING"; } 
  case STRING_LIKE: { return "STRING_LIKE"; } 
  case LOAD_STRING_IMMEDIATE: { return "LOAD_STRING_IMMEDIATE"; }
  case GLOBAL_WSTRING_SETMEM: { return "GLOBAL_WSTRING_SETMEM"; }
  case GLOBAL_WSTRING_GETMEM: { return "GLOBAL_WSTRING_GETMEM"; } 
  case WSTRING_PLUS: { return "WSTRING_PLUS"; } 
  case CAST_TO_WSTRING: { return "CAST_TO_WSTRING"; } 
  case WSTRING_LIKE: { return "WSTRING_LIKE"; } 
  case LOAD_WSTRING_IMMEDIATE: { return "LOAD_WSTRING_IMMEDIATE"; }
  case GLOBAL_DATETIME_SETMEM: { return "GLOBAL_DATETIME_SETMEM"; }
  case GLOBAL_DATETIME_GETMEM: { return "GLOBAL_DATETIME_GETMEM"; } 
  case CAST_TO_DATETIME: { return "CAST_TO_DATETIME"; } 
  case LOAD_DATETIME_IMMEDIATE: { return "LOAD_DATETIME_IMMEDIATE"; }
  case GLOBAL_TIME_SETMEM: { return "GLOBAL_TIME_SETMEM"; }
  case GLOBAL_TIME_GETMEM: { return "GLOBAL_TIME_GETMEM"; } 
  case CAST_TO_TIME: { return "CAST_TO_TIME"; } 
  case LOAD_TIME_IMMEDIATE: { return "LOAD_TIME_IMMEDIATE"; }
  case GLOBAL_ENUM_SETMEM: { return "GLOBAL_ENUM_SETMEM"; }
  case GLOBAL_ENUM_GETMEM: { return "GLOBAL_ENUM_GETMEM"; } 
  case CAST_TO_ENUM: { return "CAST_TO_ENUM"; } 
  case LOAD_ENUM_IMMEDIATE: { return "LOAD_ENUM_IMMEDIATE"; }
  case GLOBAL_BOOLEAN_SETMEM: { return "GLOBAL_BOOLEAN_SETMEM"; } 
  case GLOBAL_BOOLEAN_GETMEM: { return "GLOBAL_BOOLEAN_GETMEM"; } 
  case CAST_TO_BOOLEAN: { return "CAST_TO_BOOLEAN"; } 
  case LOAD_BOOLEAN_IMMEDIATE: { return "LOAD_BOOLEAN_IMMEDIATE"; }
  case NOT: { return "NOT"; } 
  case BITWISE_AND_INTEGER: { return "BITWISE_AND_INTEGER"; } 
  case BITWISE_OR_INTEGER: { return "BITWISE_OR_INTEGER"; } 
  case BITWISE_NOT_INTEGER: { return "BITWISE_NOT_INTEGER"; } 
  case BITWISE_XOR_INTEGER: { return "BITWISE_XOR_INTEGER"; } 
  case BITWISE_AND_BIGINT: { return "BITWISE_AND_BIGINT"; }
  case BITWISE_OR_BIGINT: { return "BITWISE_OR_BIGINT"; } 
  case BITWISE_NOT_BIGINT: { return "BITWISE_NOT_BIGINT"; } 
  case BITWISE_XOR_BIGINT: { return "BITWISE_XOR_BIGINT"; } 
  case EXEC_PRIMITIVE_FUNC: { return "EXEC_PRIMITIVE_FUNC"; }
  case STRING_PRINT: { return "STRING_PRINT"; } 
  case WSTRING_PRINT: { return "WSTRING_PRINT"; } 
  case IS_OK_PRINT: { return "IS_OK_PRINT"; } 
  case THROW: { return "THROW"; } 
  case RAISE_ERROR_INTEGER: { return "RAISE_ERROR_INTEGER"; } 
  case RAISE_ERROR_WSTRING: { return "RAISE_ERROR_WSTRING"; }
  case RAISE_ERROR_STRING: { return "RAISE_ERROR_STRING"; } 
  case RAISE_ERROR_STRING_INTEGER: { return "RAISE_ERROR_STRING_INTEGER"; } 
  case RAISE_ERROR_WSTRING_INTEGER: { return "RAISE_ERROR_WSTRING_INTEGER"; }
  case QUERY_ALLOC: { return "QUERY_ALLOC"; } 
  case QUERY_EXEC: { return "QUERY_EXEC"; } 
  case QUERY_FREE: { return "QUERY_FREE"; } 
  case QUERY_BIND_PARAM: { return "QUERY_BIND_PARAM"; }    
  case QUERY_INTEGER_BIND_COLUMN: { return "QUERY_INTEGER_BIND_COLUMN"; }
  case QUERY_BIGINT_BIND_COLUMN: { return "QUERY_BIGINT_BIND_COLUMN"; }
  case QUERY_DECIMAL_BIND_COLUMN: { return "QUERY_DECIMAL_BIND_COLUMN"; }
  case QUERY_DOUBLE_BIND_COLUMN: { return "QUERY_DOUBLE_BIND_COLUMN"; }
  case QUERY_STRING_BIND_COLUMN: { return "QUERY_STRING_BIND_COLUMN"; }
  case QUERY_WSTRING_BIND_COLUMN: { return "QUERY_WSTRING_BIND_COLUMN"; }
  case QUERY_DATETIME_BIND_COLUMN: { return "QUERY_DATETIME_BIND_COLUMN"; }
  case QUERY_TIME_BIND_COLUMN: { return "QUERY_TIME_BIND_COLUMN"; }
  case QUERY_ENUM_BIND_COLUMN: { return "QUERY_ENUM_BIND_COLUMN"; }
  case QUERY_BOOLEAN_BIND_COLUMN: { return "QUERY_BOOLEAN_BIND_COLUMN"; }
  default: { return "unknown"; }
  }
}

std::string MTSQLInstruction::PrintType() const
{
  return PrintType(mType);
}

std::string MTSQLInstruction::Print() const
{
  std::stringstream str;
  str << PrintType().c_str() << "(" << mArg1 << ", " << mArg2 << ", " << mReturn << ", " << mLabel << ")" << std::ends;
  std::string ret (str.str());
  return ret;
}

// MTSQLRegisterMachine::MTSQLRegisterMachine(int numRegisters)
//   :
//   mFunctionArgCapacity(10),
//   mRegisters(NULL),
//   mFunctionArg(NULL),
//   mStart(NULL),
//   mPosition(NULL),
//   mEnd(NULL)
// {
//   mNumRegisters = numRegisters;
//   mRegisters = new RuntimeValue [mNumRegisters];
//   mFunctionArg = new const RuntimeValue * [mFunctionArgCapacity];
// }

// MTSQLRegisterMachine::MTSQLRegisterMachine(int numRegisters, const std::vector<MTSQLInstruction *>& prog)
//   :
//   mFunctionArgCapacity(10),
//   mRegisters(NULL),
//   mFunctionArg(NULL),
//   mStart(NULL),
//   mPosition(NULL),
//   mEnd(NULL)
// {
//   mNumRegisters = numRegisters;
//   mRegisters = new RuntimeValue [mNumRegisters];
//   mFunctionArg = new const RuntimeValue * [mFunctionArgCapacity];

//   mStart = new unsigned char [1024];
//   mPosition = mStart;
//   mEnd = mStart + 1024;
//   Convert(prog);
// }

// MTSQLRegisterMachine::~MTSQLRegisterMachine()
// {
//   delete [] mRegisters;
//   delete [] mFunctionArg;
//   delete [] mStart;
// }

// void MTSQLRegisterMachine::Execute(const std::vector<MTSQLInstruction *>& prog, RuntimeEnvironment * env, Logger * log)
// {
//   int programCounter = 0;
//   int lastInstruction = prog.size();

//   MTSQLSelectCommand * query = 0;

//   ActivationRecord * globalEnvironment = env->getGlobalEnvironment();

//   while(programCounter < lastInstruction)
//   {
//     MTSQLInstruction * inst = prog[programCounter];
//     switch(inst->GetType())
//     {
// 	case MTSQLInstruction::EXEC_PRIMITIVE_FUNC:
// 	{
// 		const std::string & function (inst->GetFunctionName());
//     const std::vector<MTSQLRegister>& RegArguements(inst->GetFunctionArguements());

// 		vector <MTSQLRegister>::size_type count(RegArguements.size());

//     if (int(count) > mFunctionArgCapacity)
//     {
//       delete [] mFunctionArg;
//       mFunctionArgCapacity = int(count);
//       mFunctionArg = new const RuntimeValue * [mFunctionArgCapacity];
//     }

// 		//I am copying the arguements from registers to runtimevalues just because the executePrimitiveFunction
// 		//expects it that way.  TODO: change the executePrimitiveFunction to accept pointers to runtime values.

// 		for (unsigned int i = 0; i < count; i++)
// 		{
// 			mFunctionArg[i] = &mRegisters[RegArguements[i]];
// 		}

// 		env->executePrimitiveFunction(function, mFunctionArg, (int) count, &mRegisters[inst->GetReturn()]);

// 		break;
// 	}
// 	case MTSQLInstruction::NOT:
// 	{
// 		if(mRegisters[inst->GetArg1()].isNullRaw())
//       mRegisters[inst->GetReturn()].assignNull();
//     else if(mRegisters[inst->GetArg1()].getBool())
//       mRegisters[inst->GetReturn()].assignBool(false);
// 		else
//       mRegisters[inst->GetReturn()].assignBool(true);
// 		break;
// 	}
//     case MTSQLInstruction::GT:
//     {
//       RuntimeValue::GreaterThan(&mRegisters[inst->GetArg1()], 
//                                 &mRegisters[inst->GetArg2()], 
//                                 &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::GTEQ:
//     {
//       RuntimeValue::GreaterThanEquals(&mRegisters[inst->GetArg1()], 
//                                       &mRegisters[inst->GetArg2()], 
//                                       &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LTN:
//     {
//       RuntimeValue::LessThan(&mRegisters[inst->GetArg1()], 
//                              &mRegisters[inst->GetArg2()], 
//                              &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LTEQ:
//     {
//       RuntimeValue::LessThanEquals(&mRegisters[inst->GetArg1()], 
//                                    &mRegisters[inst->GetArg2()], 
//                                    &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::EQUALS:
//     {
//       RuntimeValue::Equals(&mRegisters[inst->GetArg1()], 
//                            &mRegisters[inst->GetArg2()], 
//                            &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::NOTEQUALS:
//     {
//       RuntimeValue::NotEquals(&mRegisters[inst->GetArg1()], 
//                               &mRegisters[inst->GetArg2()], 
//                               &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::ISNULL:
//     {
//       mRegisters[inst->GetArg1()].isNull(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::MOVE:
//     {
//       mRegisters[inst->GetReturn()] = mRegisters[inst->GetArg1()];
//       break;
//     }
//     case MTSQLInstruction::LOAD_NULL_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignNull();
//       break;
//     }
//     case MTSQLInstruction::BRANCH_ON_CONDITION:
//     {
//       if(!mRegisters[inst->GetArg1()].isNullRaw() && mRegisters[inst->GetArg1()].getBool())
//       {
//       }
//       else
//       {
//         programCounter = inst->GetLabel();
//       }
//       break;
//     }
//     case MTSQLInstruction::GOTO:
//     {
//       programCounter = inst->GetLabel();
//       break;
//     }
//     case MTSQLInstruction::RETURN:
//     {
//       // Lame of me not to figure out how to compile RETURN into GOTO :-(
//       programCounter = lastInstruction;
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_INTEGER_SETMEM:
//     {
//       globalEnvironment->setLongValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_INTEGER_GETMEM:
//     {
//       globalEnvironment->getLongValue(inst->GetAddress(), &mRegisters[inst->GetReturn()] );
//       break;
//     }
//     case MTSQLInstruction::INTEGER_PLUS:
//     {
//       RuntimeValue::LongPlus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_TIMES:
//     {
//       RuntimeValue::LongTimes(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_DIVIDE:
//     {
//       RuntimeValue::LongDivide(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_MINUS:
//     {
//       RuntimeValue::LongMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_INTEGER:
//     {
//       mRegisters[inst->GetArg1()].castToLong(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_UNARY_MINUS:
//     {
//       RuntimeValue::LongUnaryMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_MODULUS:
//     {
//       RuntimeValue::LongModulus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_INTEGER_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignLong(inst->GetImmediate().getLong());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BIGINT_SETMEM:
//     {
//       globalEnvironment->setLongLongValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BIGINT_GETMEM:
//     {
//       globalEnvironment->getLongLongValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_PLUS:
//     {
//       RuntimeValue::LongLongPlus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_TIMES:
//     {
//       RuntimeValue::LongLongTimes(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_DIVIDE:
//     {
//       RuntimeValue::LongLongDivide(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_MINUS:
//     {
//       RuntimeValue::LongLongMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_BIGINT:
//     {
//       mRegisters[inst->GetArg1()].castToLongLong(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_UNARY_MINUS:
//     {
//       RuntimeValue::LongLongUnaryMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_MODULUS:
//     {
//       RuntimeValue::LongLongModulus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_BIGINT_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignLongLong(inst->GetImmediate().getLongLong());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DECIMAL_SETMEM:
//     {
//       globalEnvironment->setDecimalValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DECIMAL_GETMEM:
//     {
//       globalEnvironment->getDecimalValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_PLUS:
//     {
//       RuntimeValue::DecimalPlus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_TIMES:
//     {
//       RuntimeValue::DecimalTimes(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_DIVIDE:
//     {
//       RuntimeValue::DecimalDivide(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_MINUS:
//     {
//       RuntimeValue::DecimalMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_DECIMAL:
//     {
//       mRegisters[inst->GetArg1()].castToDec(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_UNARY_MINUS:
//     {
//       RuntimeValue::DecimalUnaryMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_DECIMAL_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignDec(inst->GetImmediate().getDecPtr());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DOUBLE_SETMEM:
//     {
//       globalEnvironment->setDoubleValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DOUBLE_GETMEM:
//     {
//       globalEnvironment->getDoubleValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_PLUS:
//     {
//       RuntimeValue::DoublePlus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_TIMES:
//     {
//       RuntimeValue::DoubleTimes(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_DIVIDE:
//     {
//       RuntimeValue::DoubleDivide(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_MINUS:
//     {
//       RuntimeValue::DoubleMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_DOUBLE:
//     {
//       mRegisters[inst->GetArg1()].castToDouble(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_UNARY_MINUS:
//     {
//       RuntimeValue::DoubleUnaryMinus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_DOUBLE_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignDouble(inst->GetImmediate().getDouble());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_STRING_SETMEM:
//     {
//       globalEnvironment->setStringValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_STRING_GETMEM:
//     {
//       globalEnvironment->getStringValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::STRING_PLUS:
//     {
//       RuntimeValue::StringPlus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_STRING:
//     {
//       mRegisters[inst->GetArg1()].castToString(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::STRING_LIKE:
//     {
//       mRegisters[inst->GetReturn()] = RuntimeValue::StringLike(mRegisters[inst->GetArg1()], mRegisters[inst->GetArg2()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_STRING_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignString(inst->GetImmediate().getStringPtr());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_WSTRING_SETMEM:
//     {
//       globalEnvironment->setWStringValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_WSTRING_GETMEM:
//     {
//       globalEnvironment->getWStringValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::WSTRING_PLUS:
//     {
//       RuntimeValue::WStringPlus(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_WSTRING:
//     {
//       mRegisters[inst->GetArg1()].castToWString(&mRegisters[inst->GetReturn()] );
//       break;
//     }
//     case MTSQLInstruction::WSTRING_LIKE:
//     {
//       mRegisters[inst->GetReturn()] = RuntimeValue::WStringLike(mRegisters[inst->GetArg1()], mRegisters[inst->GetArg2()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_WSTRING_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignWString(inst->GetImmediate().getWStringPtr());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DATETIME_SETMEM:
//     {
//       globalEnvironment->setDatetimeValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DATETIME_GETMEM:
//     {
//       globalEnvironment->getDatetimeValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_DATETIME:
//     {
//       mRegisters[inst->GetArg1()].castToDatetime(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_DATETIME_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignDatetime(inst->GetImmediate().getDatetime());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_TIME_SETMEM:
//     {
//       globalEnvironment->setTimeValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_TIME_GETMEM:
//     {
//       globalEnvironment->getTimeValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_TIME:
//     {
//       mRegisters[inst->GetArg1()].castToTime(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_TIME_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignTime(inst->GetImmediate().getTime());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_ENUM_SETMEM:
//     {
//       globalEnvironment->setEnumValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_ENUM_GETMEM:
//     {
//        globalEnvironment->getEnumValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_ENUM:
//     {
//       RuntimeValueCast::ToEnum(&mRegisters[inst->GetReturn()], &mRegisters[inst->GetArg1()], mNameID.GetNameID());
//       break;
//     }
//     case MTSQLInstruction::LOAD_ENUM_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignEnum(inst->GetImmediate().getEnum());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BOOLEAN_SETMEM:
//     {
//       globalEnvironment->setBooleanValue(inst->GetAddress(), &mRegisters[inst->GetArg1()]);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BOOLEAN_GETMEM:
//     {
//        globalEnvironment->getBooleanValue(inst->GetAddress(), &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_BOOLEAN:
//     {
//       mRegisters[inst->GetArg1()].castToBool(&mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::LOAD_BOOLEAN_IMMEDIATE:
//     {
//       mRegisters[inst->GetReturn()].assignBool(inst->GetImmediate().getBool());
//       break;
//     }
//     case MTSQLInstruction::BITWISE_AND_INTEGER:
//     {
//       RuntimeValue::BitwiseAndLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_OR_INTEGER:
//     {
//       RuntimeValue::BitwiseOrLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_XOR_INTEGER:
//     {
//       RuntimeValue::BitwiseXorLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_NOT_INTEGER:
//     {
//       RuntimeValue::BitwiseNotLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_AND_BIGINT:
//     {
//       RuntimeValue::BitwiseAndLongLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_OR_BIGINT:
//     {
//       RuntimeValue::BitwiseOrLongLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_XOR_BIGINT:
//     {
//       RuntimeValue::BitwiseXorLongLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetArg2()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_NOT_BIGINT:
//     {
//       RuntimeValue::BitwiseNotLongLong(&mRegisters[inst->GetArg1()], &mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::IS_OK_PRINT:
//     {
//       mRegisters[inst->GetReturn()].assignBool(log->isOkToLogDebug());
//       break;
//     }
//     case MTSQLInstruction::STRING_PRINT:
//     {
//       RuntimeValue& r (mRegisters[inst->GetArg1()]);
//       log->logDebug(r.isNullRaw() ? "NULL" : r.getStringPtr());
//       break;
//     }
//     case MTSQLInstruction::WSTRING_PRINT:
//     {
//       RuntimeValue& r (mRegisters[inst->GetArg1()]);
//       log->logDebug(r.isNullRaw() ? "NULL" : r.castToString().getStringPtr());
//       break;
//     }
//     case MTSQLInstruction::THROW:
//     {
//       throw MTSQLRuntimeErrorException(inst->GetImmediate().castToString().getStringPtr());
//     }
//     case MTSQLInstruction::RAISE_ERROR_INTEGER:
//     {
//       throw MTSQLUserException("", mRegisters[inst->GetArg1()].isNullRaw() ?
//                                    E_FAIL :
//                                    mRegisters[inst->GetArg1()].getLong());
//     }
//     case MTSQLInstruction::RAISE_ERROR_STRING:
//     {
//       throw MTSQLUserException(mRegisters[inst->GetArg1()].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->GetArg1()].getStringPtr(), E_FAIL);
//     }
//     case MTSQLInstruction::RAISE_ERROR_STRING_INTEGER:
//     {
//       throw MTSQLUserException(mRegisters[inst->GetArg2()].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->GetArg2()].getStringPtr(), 
//                                mRegisters[inst->GetArg1()].isNullRaw() ?
//                                E_FAIL :
//                                mRegisters[inst->GetArg1()].getLong());
//     }
//     case MTSQLInstruction::RAISE_ERROR_WSTRING:
//     {
//       throw MTSQLUserException(mRegisters[inst->GetArg1()].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->GetArg1()].castToString().getStringPtr(), E_FAIL);
//     }
//     case MTSQLInstruction::RAISE_ERROR_WSTRING_INTEGER:
//     {
//       throw MTSQLUserException(mRegisters[inst->GetArg2()].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->GetArg2()].castToString().getStringPtr(), 
//                                mRegisters[inst->GetArg1()].isNullRaw() ?
//                                E_FAIL :
//                                mRegisters[inst->GetArg1()].getLong());
//     }
//     case MTSQLInstruction::QUERY_ALLOC:
//     {
//       query = new MTSQLSelectCommand(mTrans->getRowset());
//       query->setQueryString(inst->GetImmediate().getWStringPtr());
//       break;
//     }
//     case MTSQLInstruction::QUERY_EXEC:
//     {
//       query->execute();
//       if (query->getRecordCount() < 1)
//       {
//         programCounter = inst->GetLabel();
//       } else if (query->getRecordCount() > 1) {
//         log->logWarning("Multiple records returned from query; dropping all but the first");
//       }
//       break;
//     }
//     case MTSQLInstruction::QUERY_FREE:
//     {
//       delete query;
//       query = 0;
//       break;
//     }
//     case MTSQLInstruction::QUERY_BIND_PARAM:
//     {
//       long index = inst->GetImmediate().getLong();
//       query->setParam(index, mRegisters[inst->GetReturn()]);
//       break;
//     }
//     case MTSQLInstruction::QUERY_INTEGER_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getLong(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_DECIMAL_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getDec(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_DOUBLE_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getDouble(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_STRING_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getString(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_WSTRING_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getWString(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_DATETIME_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getDatetime(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_TIME_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getTime(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_ENUM_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getEnum(index);
//       break;
//     }
//     case MTSQLInstruction::QUERY_BOOLEAN_BIND_COLUMN:
//     {
//       long index = inst->GetImmediate().getLong();
//       mRegisters[inst->GetReturn()] = query->getBool(index);
//       break;
//     }
//     default:
//     {
//       MTSQLInstruction::Type type = inst->GetType();
//       throw std::exception("invalid instruction");
//     }
//     }
//     programCounter++;
//   }
// }

// void MTSQLRegisterMachine::reserve(std::size_t sz)
// {
//   ASSERT(mEnd >= mPosition);
//   ASSERT(mPosition>=mStart);
//   if (sz < std::size_t(mEnd-mPosition)) return;
//   // Make sure that sz additional bytes will fit and that we increase
//   // by at least a factor of 2.
//   std::size_t toAlloc = sz > std::size_t(((mEnd-mStart) + (mEnd-mPosition))) ? 
//     sz + std::size_t(mPosition-mStart) : 
//     2*std::size_t(mEnd-mStart);
//   unsigned char * newBuffer = new unsigned char [toAlloc];
//   memcpy(newBuffer, mStart, mPosition-mStart);
//   mPosition = newBuffer + (mPosition-mStart);
//   mEnd = newBuffer + toAlloc;
//   delete [] mStart;
//   mStart = newBuffer;
// }

// void MTSQLRegisterMachine::push_back(std::size_t regOrLabel)
// {
//   reserve(sizeof(size_t));
//   *((size_t *)mPosition) = regOrLabel;
//   mPosition += sizeof(size_t);
// }

// void MTSQLRegisterMachine::push_back(const string& func)
// {
//   // Always preserve 4 byte alignment.
//   std::size_t strStorage((((func.size()+1)*sizeof(char)+3) >> 2) << 2);
//   push_back(strStorage);
//   reserve(strStorage);
//   strcpy((char *)mPosition, func.c_str());
//   mPosition += strStorage;
// }

// void MTSQLRegisterMachine::push_back(const wstring& func)
// {
//   // Always preserve 4 byte alignment.
//   std::size_t strStorage((((func.size()+1)*sizeof(wchar_t)+3) >> 2) << 2);
//   push_back(strStorage);
//   reserve(strStorage);
//   wcscpy((wchar_t *)mPosition, func.c_str());
//   mPosition += strStorage;
// }

// void MTSQLRegisterMachine::push_back(MTSQLInstruction::Type ty)
// {
//   reserve(sizeof(MTSQLInstruction::Type));
//   *((MTSQLInstruction::Type *)mPosition) = ty;
//   mPosition += sizeof(MTSQLInstruction::Type);
// }

// typedef struct tagLoadIntegerInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   long Value;
// } LoadIntegerInstruction;

// typedef struct tagLoadBigIntInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   __int64 Value;
// } LoadBigIntInstruction;

// typedef struct tagLoadDecimalInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   DECIMAL Value;
// } LoadDecimalInstruction;

// typedef struct tagLoadDoubleInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   double Value;
// } LoadDoubleInstruction;

// typedef struct tagLoadDatetimeInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   DATE Value;
// } LoadDatetimeInstruction;

// typedef struct tagLoadTimeInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   time_t Value;
// } LoadTimeInstruction;

// typedef struct tagLoadEnumInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   long Value;
// } LoadEnumInstruction;

// typedef struct tagLoadBooleanInstruction
// {
//   MTSQLInstruction::Type Type;
//   // Put bool here because we want our struct to
//   // have word alignment and a bool might be a single byte!
//   // struct MEMBER alignment will make sure all is well
//   // because the next member is a machine word.
//   bool Value;
//   MTSQLRegister Return;
// } LoadBooleanInstruction;

// typedef struct tagNullaryBranchInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Arg1;
//   MTSQLProgramLabel Label;
// } NullaryBranchInstruction;

// typedef struct tagUnaryBranchInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Arg1;
//   MTSQLProgramLabel Label;
// } UnaryBranchInstruction;

// typedef struct tagNullaryOpInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
// } NullaryOpInstruction;

// typedef struct tagUnaryOpInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Arg1;
//   MTSQLRegister Return;
// } UnaryOpInstruction;

// typedef struct tagBinaryOpInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Arg1;
//   MTSQLRegister Arg2;
//   MTSQLRegister Return;
// } BinaryOpInstruction;

// typedef struct tagUnaryOutputInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Arg1;
// } UnaryOutputInstruction;

// typedef struct tagBinaryOutputInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Arg1;
//   MTSQLRegister Arg2;
// } BinaryOutputInstruction;

// typedef struct tagGlobalSetmemInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Arg1;
//   Access * Address;
// } GlobalSetmemInstruction;

// typedef struct tagGlobalGetmemInstruction
// {
//   MTSQLInstruction::Type Type;
//   MTSQLRegister Return;
//   Access * Address;
// } GlobalGetmemInstruction;

// typedef struct tagQueryBindInstruction
// {
//   MTSQLInstruction::Type Type;
//   long Index;
//   MTSQLRegister Return;
// } QueryBindInstruction;

// void MTSQLRegisterMachine::Convert(const std::vector<MTSQLInstruction *>& prog)
// {
//   // Each instruction is a possible label.  The incoming
//   // representation of labels is as vector offsets in the
//   // instruction array.  We are abandoning fixed length
//   // instructions in the target representation so we must
//   // must represent labels as byte offsets.  Note that we
//   // use byte offsets rather than actual pointers to have
//   // position independent code. 
//   //
//   // The way we perform the translation is to make a first
//   // pass in which we stick the input label into the instruction
//   // stream.  At the time we do that we record the byte offset
//   // at which put the label.
//   // After the first pass is complete and all instruction offsets
//   // are available we walk the recorded labels and convert them
//   // to offsets.
//   std::vector<size_t> instructionOffsets;
//   std::vector<size_t> labelPositions;

//   for(std::vector<MTSQLInstruction *>::const_iterator it = prog.begin();
//       it != prog.end();
//       ++it)
//   {
//     MTSQLInstruction * inst = *it;
//     instructionOffsets.push_back(mPosition-mStart);
//     switch(inst->GetType())
//     {
//     case MTSQLInstruction::EXEC_PRIMITIVE_FUNC:
//     {
//       push_back(inst->GetType());
//       push_back(inst->GetFunctionArguements().size());
//       for(std::vector<MTSQLRegister>::const_iterator it = inst->GetFunctionArguements().begin();
//           it != inst->GetFunctionArguements().end();
//           ++it)
//       {
//         push_back(*it);
//       }
//       push_back(inst->GetReturn());
//       push_back(inst->GetFunctionName());
//       break;
//     }
//     case MTSQLInstruction::NOT:
//     case MTSQLInstruction::ISNULL:
//     case MTSQLInstruction::MOVE:
//     case MTSQLInstruction::CAST_TO_INTEGER:
//     case MTSQLInstruction::INTEGER_UNARY_MINUS:
//     case MTSQLInstruction::CAST_TO_BIGINT:
//     case MTSQLInstruction::BIGINT_UNARY_MINUS:
//     case MTSQLInstruction::CAST_TO_DECIMAL:
//     case MTSQLInstruction::DECIMAL_UNARY_MINUS:
//     case MTSQLInstruction::CAST_TO_DOUBLE:
//     case MTSQLInstruction::DOUBLE_UNARY_MINUS:
//     case MTSQLInstruction::CAST_TO_STRING:
//     case MTSQLInstruction::CAST_TO_WSTRING:
//     case MTSQLInstruction::CAST_TO_DATETIME:
//     case MTSQLInstruction::CAST_TO_TIME:
//     case MTSQLInstruction::CAST_TO_ENUM:
//     case MTSQLInstruction::CAST_TO_BOOLEAN:
//     case MTSQLInstruction::BITWISE_NOT_INTEGER:
//     case MTSQLInstruction::BITWISE_NOT_BIGINT:
//     {
//       reserve(sizeof(UnaryOpInstruction));
//       UnaryOpInstruction * i = (UnaryOpInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Arg1 = inst->GetArg1();
//       i->Return = inst->GetReturn();
//       mPosition += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GT:
//     case MTSQLInstruction::GTEQ:
//     case MTSQLInstruction::LTN:
//     case MTSQLInstruction::LTEQ:
//     case MTSQLInstruction::NOTEQUALS:
//     case MTSQLInstruction::EQUALS:
//     case MTSQLInstruction::INTEGER_PLUS:
//     case MTSQLInstruction::INTEGER_TIMES:
//     case MTSQLInstruction::INTEGER_DIVIDE:
//     case MTSQLInstruction::INTEGER_MINUS:
//     case MTSQLInstruction::INTEGER_MODULUS:
//     case MTSQLInstruction::BIGINT_PLUS:
//     case MTSQLInstruction::BIGINT_TIMES:
//     case MTSQLInstruction::BIGINT_DIVIDE:
//     case MTSQLInstruction::BIGINT_MINUS:
//     case MTSQLInstruction::BIGINT_MODULUS:
//     case MTSQLInstruction::DECIMAL_PLUS:
//     case MTSQLInstruction::DECIMAL_TIMES:
//     case MTSQLInstruction::DECIMAL_DIVIDE:
//     case MTSQLInstruction::DECIMAL_MINUS:
//     case MTSQLInstruction::DOUBLE_PLUS:
//     case MTSQLInstruction::DOUBLE_TIMES:
//     case MTSQLInstruction::DOUBLE_DIVIDE:
//     case MTSQLInstruction::DOUBLE_MINUS:
//     case MTSQLInstruction::STRING_PLUS:
//     case MTSQLInstruction::STRING_LIKE:
//     case MTSQLInstruction::WSTRING_PLUS:
//     case MTSQLInstruction::WSTRING_LIKE:
//     case MTSQLInstruction::BITWISE_AND_INTEGER:
//     case MTSQLInstruction::BITWISE_OR_INTEGER:
//     case MTSQLInstruction::BITWISE_XOR_INTEGER:
//     case MTSQLInstruction::BITWISE_AND_BIGINT:
//     case MTSQLInstruction::BITWISE_OR_BIGINT:
//     case MTSQLInstruction::BITWISE_XOR_BIGINT:
//     {
//       reserve(sizeof(BinaryOpInstruction));
//       BinaryOpInstruction * i = (BinaryOpInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Arg1 = inst->GetArg1();
//       i->Arg2 = inst->GetArg2();
//       i->Return = inst->GetReturn();
//       mPosition += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_INTEGER_IMMEDIATE:
//     {
//       reserve(sizeof(LoadIntegerInstruction));
//       LoadIntegerInstruction * i = (LoadIntegerInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       i->Value = inst->GetImmediate().getLong();
//       mPosition += sizeof(LoadIntegerInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_BIGINT_IMMEDIATE:
//     {
//       reserve(sizeof(LoadBigIntInstruction));
//       LoadBigIntInstruction * i = (LoadBigIntInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       i->Value = inst->GetImmediate().getLongLong();
//       mPosition += sizeof(LoadBigIntInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_DECIMAL_IMMEDIATE:
//     {
//       reserve(sizeof(LoadDecimalInstruction));
//       LoadDecimalInstruction * i = (LoadDecimalInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       memcpy(&(i->Value), inst->GetImmediate().getDecPtr(), sizeof(DECIMAL));
//       mPosition += sizeof(LoadDecimalInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_DOUBLE_IMMEDIATE:
//     {
//       reserve(sizeof(LoadDoubleInstruction));
//       LoadDoubleInstruction * i = (LoadDoubleInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       i->Value = inst->GetImmediate().getDouble();
//       mPosition += sizeof(LoadDoubleInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_STRING_IMMEDIATE:
//     {
//       push_back(inst->GetType());
//       push_back(inst->GetReturn());
//       push_back(inst->GetImmediate().getStringPtr());
//       break;
//     }
//     case MTSQLInstruction::LOAD_WSTRING_IMMEDIATE:
//     {
//       push_back(inst->GetType());
//       push_back(inst->GetReturn());
//       push_back(inst->GetImmediate().getWStringPtr());
//       break;
//     }
//     case MTSQLInstruction::LOAD_TIME_IMMEDIATE:
//     {
//       reserve(sizeof(LoadTimeInstruction));
//       LoadTimeInstruction * i = (LoadTimeInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       i->Value = inst->GetImmediate().getTime();
//       mPosition += sizeof(LoadTimeInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_ENUM_IMMEDIATE:
//     {
//       reserve(sizeof(LoadEnumInstruction));
//       LoadEnumInstruction * i = (LoadEnumInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       i->Value = inst->GetImmediate().getEnum();
//       mPosition += sizeof(LoadEnumInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_BOOLEAN_IMMEDIATE:
//     {
//       reserve(sizeof(LoadBooleanInstruction));
//       LoadBooleanInstruction * i = (LoadBooleanInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       i->Value = inst->GetImmediate().getBool();
//       mPosition += sizeof(LoadBooleanInstruction);
//       break;
//     }
//     case MTSQLInstruction::BRANCH_ON_CONDITION:
//     {
//       reserve(sizeof(UnaryBranchInstruction));
//       UnaryBranchInstruction * i = (UnaryBranchInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Arg1 = inst->GetArg1();
//       i->Label = inst->GetLabel();
//       mPosition += sizeof(UnaryBranchInstruction);
//       // Labels here are vector offsets,
//       // these must be translated to byte offsets.
//       // Record where I put the label so that it can
//       // fixed up later.
//       labelPositions.push_back(((unsigned char *)&(i->Label))-mStart);
//       break;
//     }
//     case MTSQLInstruction::GOTO:
//     case MTSQLInstruction::QUERY_EXEC:
//     {
//       reserve(sizeof(NullaryBranchInstruction));
//       NullaryBranchInstruction * i = (NullaryBranchInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Label = inst->GetLabel();
//       mPosition += sizeof(NullaryBranchInstruction);
//       // Labels here are vector offsets,
//       // these must be translated to byte offsets.
//       // Record where I put the label so that it can
//       // fixed up later.
//       labelPositions.push_back(((unsigned char *)&(i->Label))-mStart);
//       break;
//     }
//     case MTSQLInstruction::RETURN:
//     case MTSQLInstruction::QUERY_FREE:
//     {
//       push_back(inst->GetType());
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_INTEGER_SETMEM:
//     case MTSQLInstruction::GLOBAL_BIGINT_SETMEM:
//     case MTSQLInstruction::GLOBAL_DECIMAL_SETMEM:
//     case MTSQLInstruction::GLOBAL_DOUBLE_SETMEM:
//     case MTSQLInstruction::GLOBAL_STRING_SETMEM:
//     case MTSQLInstruction::GLOBAL_WSTRING_SETMEM:
//     case MTSQLInstruction::GLOBAL_DATETIME_SETMEM:
//     case MTSQLInstruction::GLOBAL_TIME_SETMEM:
//     case MTSQLInstruction::GLOBAL_ENUM_SETMEM:
//     case MTSQLInstruction::GLOBAL_BOOLEAN_SETMEM:
//     {
//       reserve(sizeof(GlobalSetmemInstruction));
//       GlobalSetmemInstruction * i = (GlobalSetmemInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Arg1 = inst->GetArg1();
//       i->Address = inst->GetAddress();
//       mPosition += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_INTEGER_GETMEM:
//     case MTSQLInstruction::GLOBAL_BIGINT_GETMEM:
//     case MTSQLInstruction::GLOBAL_DECIMAL_GETMEM:
//     case MTSQLInstruction::GLOBAL_DOUBLE_GETMEM:
//     case MTSQLInstruction::GLOBAL_STRING_GETMEM:
//     case MTSQLInstruction::GLOBAL_WSTRING_GETMEM:
//     case MTSQLInstruction::GLOBAL_DATETIME_GETMEM:
//     case MTSQLInstruction::GLOBAL_TIME_GETMEM:
//     case MTSQLInstruction::GLOBAL_ENUM_GETMEM:
//     case MTSQLInstruction::GLOBAL_BOOLEAN_GETMEM:
//     {
//       reserve(sizeof(GlobalGetmemInstruction));
//       GlobalGetmemInstruction * i = (GlobalGetmemInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       i->Address = inst->GetAddress();
//       mPosition += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_NULL_IMMEDIATE:
//     case MTSQLInstruction::IS_OK_PRINT:
//     {
//       reserve(sizeof(NullaryOpInstruction));
//       NullaryOpInstruction * i = (NullaryOpInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Return = inst->GetReturn();
//       mPosition += sizeof(NullaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::STRING_PRINT:
//     case MTSQLInstruction::WSTRING_PRINT:
//     case MTSQLInstruction::RAISE_ERROR_INTEGER:
//     case MTSQLInstruction::RAISE_ERROR_STRING:
//     case MTSQLInstruction::RAISE_ERROR_WSTRING:
//     {
//       reserve(sizeof(UnaryOutputInstruction));
//       UnaryOutputInstruction * i = (UnaryOutputInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Arg1 = inst->GetArg1();
//       mPosition += sizeof(UnaryOutputInstruction);
//       break;
//     }
//     case MTSQLInstruction::THROW:
//     {
//       push_back(inst->GetType());
//       push_back(inst->GetImmediate().castToString().getStringPtr());
//       break;
//     }
//     case MTSQLInstruction::RAISE_ERROR_STRING_INTEGER:
//     case MTSQLInstruction::RAISE_ERROR_WSTRING_INTEGER:
//     {
//       reserve(sizeof(BinaryOutputInstruction));
//       BinaryOutputInstruction * i = (BinaryOutputInstruction *)mPosition;
//       i->Type = inst->GetType();
//       i->Arg1 = inst->GetArg1();
//       i->Arg2 = inst->GetArg2();
//       mPosition += sizeof(BinaryOutputInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_ALLOC:
//     {
//       push_back(inst->GetType());
//       push_back(inst->GetImmediate().getWStringPtr());
//       break;
//     }
//     case MTSQLInstruction::QUERY_BIND_PARAM:
//     case MTSQLInstruction::QUERY_INTEGER_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_DECIMAL_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_DOUBLE_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_STRING_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_WSTRING_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_DATETIME_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_TIME_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_ENUM_BIND_COLUMN:
//     case MTSQLInstruction::QUERY_BOOLEAN_BIND_COLUMN:
//     {
//       reserve(sizeof(QueryBindInstruction));
//       QueryBindInstruction * i = (QueryBindInstruction *)mPosition;
//       i->Index = inst->GetImmediate().getLong();
//       i->Return = inst->GetReturn();
//       mPosition += sizeof(QueryBindInstruction);
//       break;
//     }
//     default:
//     {
//       MTSQLInstruction::Type type = inst->GetType();
//       throw std::exception("invalid instruction");
//     }
//     }
//   }

//   ASSERT(instructionOffsets.size() == prog.size());

//   // Stick in one more offset to the end of the program
//   instructionOffsets.push_back(mEnd-mStart);

//   // Fix up labels.  Note that labels point 1 behind where
//   // they really should.
//   for(std::vector<size_t>::iterator it = labelPositions.begin();
//       it != labelPositions.end();
//       ++it)
//   {
//     ASSERT(*it < std::size_t(mEnd-mStart));
//     std::size_t original = *((std::size_t *)(mStart + *it));
//     ASSERT(original < prog.size());
//     *((std::size_t *)(mStart + *it)) = instructionOffsets[original+1];
//   }
// }

// void MTSQLRegisterMachine::Execute(RuntimeEnvironment * env, Logger * log)
// {
//   unsigned char * programCounter = mStart;
//   unsigned char * lastInstruction = mPosition;

//   MTSQLSelectCommand * query = 0;

//   ActivationRecord * globalEnvironment = env->getGlobalEnvironment();

//   while(programCounter < lastInstruction)
//   {
//     switch(*((MTSQLInstruction::Type *)programCounter))
//     {
//     case MTSQLInstruction::EXEC_PRIMITIVE_FUNC:
//     {
//       programCounter += sizeof(MTSQLInstruction::Type);
//       const std::size_t count(*((std::size_t *) programCounter));
//       programCounter += sizeof(std::size_t);

//       if (int(count) > mFunctionArgCapacity)
//       {
//         delete [] mFunctionArg;
//         mFunctionArgCapacity = int(count);
//         mFunctionArg = new const RuntimeValue * [mFunctionArgCapacity];
//       }

//       for (unsigned int i = 0; i < count; i++)
//       {
//         mFunctionArg[i] = &mRegisters[*((MTSQLRegister *)programCounter)];
//         programCounter += sizeof(MTSQLRegister);
//       }
//       RuntimeValue * ret = &mRegisters[*((MTSQLRegister *)programCounter)];
//       programCounter += sizeof(MTSQLRegister);

//       const std::size_t strSize(*((std::size_t *) programCounter));
//       programCounter += sizeof(std::size_t);

//       env->executePrimitiveFunction((const char *)programCounter, mFunctionArg, (int) count, ret);
//       programCounter += strSize;

// 		break;
// 	}
// 	case MTSQLInstruction::NOT:
// 	{
//     UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
// 		if(mRegisters[inst->Arg1].isNullRaw())
//       mRegisters[inst->Return].assignNull();
//     else if(mRegisters[inst->Arg1].getBool())
//       mRegisters[inst->Return].assignBool(false);
// 		else
//       mRegisters[inst->Return].assignBool(true);
//     programCounter += sizeof(UnaryOpInstruction);
// 		break;
// 	}
//     case MTSQLInstruction::GT:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::GreaterThan(&mRegisters[inst->Arg1], 
//                                 &mRegisters[inst->Arg2], 
//                                 &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GTEQ:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::GreaterThanEquals(&mRegisters[inst->Arg1], 
//                                       &mRegisters[inst->Arg2], 
//                                       &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::LTN:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LessThan(&mRegisters[inst->Arg1], 
//                              &mRegisters[inst->Arg2], 
//                              &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::LTEQ:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LessThanEquals(&mRegisters[inst->Arg1], 
//                                    &mRegisters[inst->Arg2], 
//                                    &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::EQUALS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::Equals(&mRegisters[inst->Arg1], 
//                            &mRegisters[inst->Arg2], 
//                            &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::NOTEQUALS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::NotEquals(&mRegisters[inst->Arg1], 
//                               &mRegisters[inst->Arg2], 
//                               &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::ISNULL:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].isNull(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::MOVE:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Return] = mRegisters[inst->Arg1];
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_NULL_IMMEDIATE:
//     {
//       NullaryOpInstruction * inst = (NullaryOpInstruction *)programCounter;
//       mRegisters[inst->Return].assignNull();
//       programCounter += sizeof(NullaryOpInstruction);
//       break;      
//     }
//     case MTSQLInstruction::LOAD_INTEGER_IMMEDIATE:
//     {
//       LoadIntegerInstruction * inst = (LoadIntegerInstruction *)programCounter;
//       mRegisters[inst->Return].assignLong(inst->Value);
//       programCounter += sizeof(LoadIntegerInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_BIGINT_IMMEDIATE:
//     {
//       LoadBigIntInstruction * inst = (LoadBigIntInstruction *)programCounter;
//       mRegisters[inst->Return].assignLongLong(inst->Value);
//       programCounter += sizeof(LoadBigIntInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_DECIMAL_IMMEDIATE:
//     {
//       LoadDecimalInstruction * inst = (LoadDecimalInstruction *)programCounter;
//       mRegisters[inst->Return].assignDec(&(inst->Value));
//       programCounter += sizeof(LoadDecimalInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_DOUBLE_IMMEDIATE:
//     {
//       LoadDoubleInstruction * inst = (LoadDoubleInstruction *)programCounter;
//       mRegisters[inst->Return].assignDouble(inst->Value);
//       programCounter += sizeof(LoadDoubleInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_STRING_IMMEDIATE:
//     {
//       programCounter += sizeof(MTSQLInstruction::Type);
//       MTSQLRegister ret(*(MTSQLRegister *)programCounter);
//       programCounter += sizeof(MTSQLRegister);
//       std::size_t toSkip(*(std::size_t *)programCounter);
//       programCounter += sizeof(std::size_t);
//       mRegisters[ret].assignString((const char *)programCounter);
//       programCounter += toSkip;
//       break;
//     }
//     case MTSQLInstruction::LOAD_WSTRING_IMMEDIATE:
//     {
//       programCounter += sizeof(MTSQLInstruction::Type);
//       MTSQLRegister ret(*(MTSQLRegister *)programCounter);
//       programCounter += sizeof(MTSQLRegister);
//       std::size_t toSkip(*(std::size_t *)programCounter);
//       programCounter += sizeof(std::size_t);
//       mRegisters[ret].assignWString((const wchar_t *)programCounter);
//       programCounter += toSkip;
//       break;
//     }
//     case MTSQLInstruction::LOAD_TIME_IMMEDIATE:
//     {
//       LoadTimeInstruction * inst = (LoadTimeInstruction *)programCounter;
//       mRegisters[inst->Return].assignTime(inst->Value);
//       programCounter += sizeof(LoadTimeInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_ENUM_IMMEDIATE:
//     {
//       LoadEnumInstruction * inst = (LoadEnumInstruction *)programCounter;
//       mRegisters[inst->Return].assignEnum(inst->Value);
//       programCounter += sizeof(LoadEnumInstruction);
//       break;
//     }
//     case MTSQLInstruction::LOAD_BOOLEAN_IMMEDIATE:
//     {
//       LoadBooleanInstruction * inst = (LoadBooleanInstruction *)programCounter;
//       mRegisters[inst->Return].assignBool(inst->Value);
//       programCounter += sizeof(LoadBooleanInstruction);
//       break;
//     }
//     case MTSQLInstruction::BRANCH_ON_CONDITION:
//     {
//       UnaryBranchInstruction * inst = (UnaryBranchInstruction *) programCounter;
//       if(!mRegisters[inst->Arg1].isNullRaw() && mRegisters[inst->Arg1].getBool())
//       {
//         programCounter += sizeof(UnaryBranchInstruction);
//       }
//       else
//       {
//         programCounter = mStart + inst->Label;
//       }
//       break;
//     }
//     case MTSQLInstruction::GOTO:
//     {
//       NullaryBranchInstruction * inst = (NullaryBranchInstruction *) programCounter;
//       programCounter = mStart + inst->Label;
//       break;
//     }
//     case MTSQLInstruction::RETURN:
//     {
//       // Lame of me not to figure out how to compile RETURN into GOTO :-(
//       programCounter = lastInstruction;
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_INTEGER_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setLongValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_INTEGER_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getLongValue(inst->Address, &mRegisters[inst->Return] );
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_PLUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_TIMES:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_DIVIDE:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_MINUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_INTEGER:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToLong(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_UNARY_MINUS:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       RuntimeValue::LongUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::INTEGER_MODULUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongModulus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BIGINT_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setLongLongValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BIGINT_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getLongLongValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_PLUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongLongPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_TIMES:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongLongTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_DIVIDE:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongLongDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_MINUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongLongMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_BIGINT:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToLongLong(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_UNARY_MINUS:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       RuntimeValue::LongLongUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BIGINT_MODULUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::LongLongModulus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DECIMAL_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setDecimalValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DECIMAL_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getDecimalValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_PLUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DecimalPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_TIMES:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DecimalTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_DIVIDE:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DecimalDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_MINUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DecimalMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_DECIMAL:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToDec(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DECIMAL_UNARY_MINUS:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       RuntimeValue::DecimalUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DOUBLE_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setDoubleValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DOUBLE_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getDoubleValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_PLUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DoublePlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_TIMES:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DoubleTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_DIVIDE:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DoubleDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_MINUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::DoubleMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_DOUBLE:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToDouble(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::DOUBLE_UNARY_MINUS:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       RuntimeValue::DoubleUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_STRING_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setStringValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_STRING_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getStringValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::STRING_PLUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::StringPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_STRING:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToString(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::STRING_LIKE:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       mRegisters[inst->Return] = RuntimeValue::StringLike(mRegisters[inst->Arg1], mRegisters[inst->Arg2]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_WSTRING_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setWStringValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_WSTRING_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getWStringValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::WSTRING_PLUS:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::WStringPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_WSTRING:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToWString(&mRegisters[inst->Return] );
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::WSTRING_LIKE:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       mRegisters[inst->Return] = RuntimeValue::WStringLike(mRegisters[inst->Arg1], mRegisters[inst->Arg2]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DATETIME_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setDatetimeValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_DATETIME_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getDatetimeValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_DATETIME:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToDatetime(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_TIME_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setTimeValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_TIME_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getTimeValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_TIME:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToTime(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_ENUM_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setEnumValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_ENUM_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getEnumValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_ENUM:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       RuntimeValueCast::ToEnum(&mRegisters[inst->Return], &mRegisters[inst->Arg1], mNameID.GetNameID());
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BOOLEAN_SETMEM:
//     {
//       GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
//       globalEnvironment->setBooleanValue(inst->Address, &mRegisters[inst->Arg1]);
//       programCounter += sizeof(GlobalSetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::GLOBAL_BOOLEAN_GETMEM:
//     {
//       GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
//       globalEnvironment->getBooleanValue(inst->Address, &mRegisters[inst->Return]);
//       programCounter += sizeof(GlobalGetmemInstruction);
//       break;
//     }
//     case MTSQLInstruction::CAST_TO_BOOLEAN:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       mRegisters[inst->Arg1].castToBool(&mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_AND_INTEGER:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseAndLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_OR_INTEGER:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseOrLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_XOR_INTEGER:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseXorLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_NOT_INTEGER:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseNotLong(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_AND_BIGINT:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseAndLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_OR_BIGINT:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseOrLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_XOR_BIGINT:
//     {
//       BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseXorLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
//       programCounter += sizeof(BinaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::BITWISE_NOT_BIGINT:
//     {
//       UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
//       RuntimeValue::BitwiseNotLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
//       programCounter += sizeof(UnaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::IS_OK_PRINT:
//     {
//       NullaryOpInstruction * inst = (NullaryOpInstruction *)programCounter;
//       mRegisters[inst->Return].assignBool(log->isOkToLogDebug());
//       programCounter += sizeof(NullaryOpInstruction);
//       break;
//     }
//     case MTSQLInstruction::STRING_PRINT:
//     {
//       UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
//       RuntimeValue& r (mRegisters[inst->Arg1]);
//       log->logDebug(r.isNullRaw() ? "NULL" : r.getStringPtr());
//       programCounter += sizeof(UnaryOutputInstruction);
//       break;
//     }
//     case MTSQLInstruction::WSTRING_PRINT:
//     {
//       UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
//       RuntimeValue& r (mRegisters[inst->Arg1]);
//       log->logDebug(r.isNullRaw() ? "NULL" : r.castToString().getStringPtr());
//       programCounter += sizeof(UnaryOutputInstruction);
//       break;
//     }
//     case MTSQLInstruction::THROW:
//     {
//       programCounter += sizeof(MTSQLInstruction::Type);
//       programCounter += sizeof(std::size_t);
//       throw MTSQLRuntimeErrorException((const char *)programCounter);
//     }
//     case MTSQLInstruction::RAISE_ERROR_INTEGER:
//     {
//       UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
//       throw MTSQLUserException("", mRegisters[inst->Arg1].isNullRaw() ?
//                                    E_FAIL :
//                                    mRegisters[inst->Arg1].getLong());
//     }
//     case MTSQLInstruction::RAISE_ERROR_STRING:
//     {
//       UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
//       throw MTSQLUserException(mRegisters[inst->Arg1].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->Arg1].getStringPtr(), E_FAIL);
//     }
//     case MTSQLInstruction::RAISE_ERROR_STRING_INTEGER:
//     {
//       BinaryOutputInstruction * inst = (BinaryOutputInstruction *)programCounter;
//       throw MTSQLUserException(mRegisters[inst->Arg2].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->Arg2].getStringPtr(), 
//                                mRegisters[inst->Arg1].isNullRaw() ?
//                                E_FAIL :
//                                mRegisters[inst->Arg1].getLong());
//     }
//     case MTSQLInstruction::RAISE_ERROR_WSTRING:
//     {
//       UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
//       throw MTSQLUserException(mRegisters[inst->Arg1].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->Arg1].castToString().getStringPtr(), E_FAIL);
//     }
//     case MTSQLInstruction::RAISE_ERROR_WSTRING_INTEGER:
//     {
//       BinaryOutputInstruction * inst = (BinaryOutputInstruction *)programCounter;
//       throw MTSQLUserException(mRegisters[inst->Arg2].isNullRaw() ?
//                                "NULL" :
//                                mRegisters[inst->Arg2].castToString().getStringPtr(), 
//                                mRegisters[inst->Arg1].isNullRaw() ?
//                                E_FAIL :
//                                mRegisters[inst->Arg1].getLong());
//     }
//     case MTSQLInstruction::QUERY_ALLOC:
//     {
//       programCounter += sizeof(MTSQLInstruction::Type);
//       const std::size_t strSz(*((const std::size_t *) programCounter));
//       programCounter += sizeof(std::size_t);
//       query = new MTSQLSelectCommand(mTrans->getRowset());
//       query->setQueryString((const wchar_t *) programCounter);
//       programCounter += strSz;
//       break;
//     }
//     case MTSQLInstruction::QUERY_EXEC:
//     {
//       NullaryBranchInstruction * inst = (NullaryBranchInstruction *)programCounter;
//       query->execute();
//       if (query->getRecordCount() < 1)
//       {
//         programCounter = mStart + inst->Label;
//       } else if (query->getRecordCount() > 1) {
//         programCounter += sizeof(NullaryBranchInstruction);
//         log->logWarning("Multiple records returned from query; dropping all but the first");
//       }
//       break;
//     }
//     case MTSQLInstruction::QUERY_FREE:
//     {
//       delete query;
//       query = 0;
//       break;
//     }
//     case MTSQLInstruction::QUERY_BIND_PARAM:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       query->setParam(inst->Index, mRegisters[inst->Return]);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_INTEGER_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getLong(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_DECIMAL_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getDec(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_DOUBLE_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getDouble(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_STRING_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getString(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_WSTRING_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getWString(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_DATETIME_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getDatetime(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_TIME_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getTime(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_ENUM_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getEnum(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     case MTSQLInstruction::QUERY_BOOLEAN_BIND_COLUMN:
//     {
//       QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
//       mRegisters[inst->Return] = query->getBool(inst->Index);
//       programCounter += sizeof(QueryBindInstruction);
//       break;
//     }
//     default:
//     {
//       throw std::exception("invalid instruction");
//     }
//     }
//   }
// }

