#ifndef __MTSQLINSTRUCTION_H__
#define __MTSQLINSTRUCTION_H__

#include <string>
#include "RuntimeValue.h"


typedef int MTSQLRegister;
typedef int MTSQLProgramLabel;

class MTSQLInstruction
{
public:
  enum Type { GOTO, BRANCH_ON_CONDITION, RETURN, LOAD_NULL_IMMEDIATE, MOVE, 
              GT, GTEQ, LTN, LTEQ, EQUALS, NOTEQUALS, ISNULL, FUN_CALL,
              GLOBAL_INTEGER_SETMEM, GLOBAL_INTEGER_GETMEM, QUERY_INTEGER_BIND_PARAM, QUERY_INTEGER_BIND_COLUMN, INTEGER_PLUS, INTEGER_MINUS, INTEGER_UNARY_MINUS, INTEGER_TIMES, INTEGER_DIVIDE, CAST_TO_INTEGER, INTEGER_MODULUS, LOAD_INTEGER_IMMEDIATE,
              GLOBAL_BIGINT_SETMEM, GLOBAL_BIGINT_GETMEM, QUERY_BIGINT_BIND_PARAM, QUERY_BIGINT_BIND_COLUMN, BIGINT_PLUS, BIGINT_MINUS, BIGINT_UNARY_MINUS, BIGINT_TIMES, BIGINT_DIVIDE, CAST_TO_BIGINT, BIGINT_MODULUS, LOAD_BIGINT_IMMEDIATE, 
              GLOBAL_DECIMAL_SETMEM, GLOBAL_DECIMAL_GETMEM, QUERY_DECIMAL_BIND_PARAM, QUERY_DECIMAL_BIND_COLUMN, DECIMAL_PLUS, DECIMAL_MINUS, DECIMAL_UNARY_MINUS, DECIMAL_TIMES, DECIMAL_DIVIDE, CAST_TO_DECIMAL, LOAD_DECIMAL_IMMEDIATE,
              GLOBAL_DOUBLE_SETMEM, GLOBAL_DOUBLE_GETMEM, QUERY_DOUBLE_BIND_PARAM, QUERY_DOUBLE_BIND_COLUMN, DOUBLE_PLUS, DOUBLE_MINUS, DOUBLE_UNARY_MINUS, DOUBLE_TIMES, DOUBLE_DIVIDE, CAST_TO_DOUBLE, LOAD_DOUBLE_IMMEDIATE,
              GLOBAL_STRING_SETMEM, GLOBAL_STRING_GETMEM, QUERY_STRING_BIND_PARAM, QUERY_STRING_BIND_COLUMN, STRING_PLUS, CAST_TO_STRING, STRING_LIKE, LOAD_STRING_IMMEDIATE, 
              GLOBAL_WSTRING_SETMEM, GLOBAL_WSTRING_GETMEM, QUERY_WSTRING_BIND_PARAM, QUERY_WSTRING_BIND_COLUMN, WSTRING_PLUS, CAST_TO_WSTRING, WSTRING_LIKE, LOAD_WSTRING_IMMEDIATE,
              GLOBAL_DATETIME_SETMEM, GLOBAL_DATETIME_GETMEM, QUERY_DATETIME_BIND_PARAM, QUERY_DATETIME_BIND_COLUMN, CAST_TO_DATETIME, LOAD_DATETIME_IMMEDIATE,
              GLOBAL_TIME_SETMEM, GLOBAL_TIME_GETMEM, QUERY_TIME_BIND_PARAM, QUERY_TIME_BIND_COLUMN, CAST_TO_TIME, LOAD_TIME_IMMEDIATE,
              GLOBAL_ENUM_SETMEM, GLOBAL_ENUM_GETMEM, QUERY_ENUM_BIND_PARAM, QUERY_ENUM_BIND_COLUMN, CAST_TO_ENUM, LOAD_ENUM_IMMEDIATE,
              GLOBAL_BOOLEAN_SETMEM, GLOBAL_BOOLEAN_GETMEM, QUERY_BOOLEAN_BIND_PARAM, QUERY_BOOLEAN_BIND_COLUMN, CAST_TO_BOOLEAN, NOT, LOAD_BOOLEAN_IMMEDIATE, 
              GLOBAL_BINARY_SETMEM, GLOBAL_BINARY_GETMEM, QUERY_BINARY_BIND_PARAM, QUERY_BINARY_BIND_COLUMN, CAST_TO_BINARY, LOAD_BINARY_IMMEDIATE,
              BITWISE_AND_INTEGER, BITWISE_OR_INTEGER, BITWISE_NOT_INTEGER, BITWISE_XOR_INTEGER,
              BITWISE_AND_BIGINT, BITWISE_OR_BIGINT, BITWISE_NOT_BIGINT, BITWISE_XOR_BIGINT,
              EXEC_PRIMITIVE_FUNC, STRING_PRINT, WSTRING_PRINT, IS_OK_PRINT, THROW, RAISE_ERROR_INTEGER, RAISE_ERROR_WSTRING, RAISE_ERROR_STRING, RAISE_ERROR_STRING_INTEGER, RAISE_ERROR_WSTRING_INTEGER,
              QUERY_ALLOC, QUERY_EXEC, QUERY_FREE, QUERY_BIND_PARAM
            };
private:
  Type mType;
  MTSQLRegister mArg1;
  MTSQLRegister mArg2;
  MTSQLRegister mReturn;
  MTSQLProgramLabel mLabel;
  AccessPtr mAddress;
  RuntimeValue mImmediate;
  string mFuncName;
  std::vector<MTSQLRegister> mArguements;

  MTSQLInstruction(Type type, MTSQLRegister arg1, MTSQLRegister arg2, MTSQLRegister ret)
    :
    mType(type),
    mArg1(arg1),
    mArg2(arg2),
    mReturn(ret)
  {
  }
  MTSQLInstruction(Type type, MTSQLRegister arg1, MTSQLRegister ret, AccessPtr addr)
    :
    mType(type),
    mArg1(arg1),
    mReturn(ret),
    mAddress(addr)
  {
  }
  MTSQLInstruction(Type type, RuntimeValue immed, MTSQLRegister ret)
    :
    mType(type),
    mReturn(ret),
    mImmediate(immed)
  {
  }
  MTSQLInstruction(Type type, MTSQLRegister arg, MTSQLProgramLabel label)
    :
    mType(type),
    mArg1(arg),
    mLabel(label)
  {
  }
  MTSQLInstruction(Type type, string func, std::vector<MTSQLRegister> args, MTSQLRegister ret)
	  :
		mType(type),
    mReturn(ret),
		mFuncName(func),
		mArguements(args)
		{
		}
public:
  // Factory methods for instructions
  static MTSQLInstruction * CreateGoto(MTSQLProgramLabel label)
  {
    return new MTSQLInstruction(GOTO, -1, label);
  }
  static MTSQLInstruction * CreateBranchOnCondition(MTSQLRegister arg, MTSQLProgramLabel label)
  { 
    return new MTSQLInstruction(BRANCH_ON_CONDITION, arg, label);
  }
  static MTSQLInstruction * CreateReturn()
  {
    return new MTSQLInstruction(RETURN, -1, -1, -1);
  }
  static MTSQLInstruction * CreateLoadNullImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_NULL_IMMEDIATE, value, arg);
  }
  static MTSQLInstruction * CreateMove(MTSQLRegister arg, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(MOVE, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLNot(MTSQLRegister arg1, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(NOT, arg1, -1, ret);
  }
  static MTSQLInstruction * CreateGreaterThan(MTSQLRegister arg1, MTSQLRegister arg2, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GT, arg1, arg2, ret);
  }
  static MTSQLInstruction * CreateGreaterThanEquals(MTSQLRegister arg1, MTSQLRegister arg2, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GTEQ, arg1, arg2, ret);
  }
  static MTSQLInstruction * CreateLessThan(MTSQLRegister arg1, MTSQLRegister arg2, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(LTN, arg1, arg2, ret);
  }
  static MTSQLInstruction * CreateLessThanEquals(MTSQLRegister arg1, MTSQLRegister arg2, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(LTEQ, arg1, arg2, ret);
  }
  static MTSQLInstruction * CreateEquals(MTSQLRegister arg1, MTSQLRegister arg2, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(EQUALS, arg1, arg2, ret);
  }
  static MTSQLInstruction * CreateNotEquals(MTSQLRegister arg1, MTSQLRegister arg2, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(NOTEQUALS, arg1, arg2, ret);
  }
  static MTSQLInstruction * CreateIsNull(MTSQLRegister arg1, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(ISNULL, arg1, -1, ret);
  }
  static MTSQLInstruction * ExecutePrimitiveFunction(string func, std::vector<MTSQLRegister> args, MTSQLRegister ret)
  {
	  //anu check this... does not look right!
	  return new MTSQLInstruction(EXEC_PRIMITIVE_FUNC, func, args, ret);
  }

  // Integer instructions
  static MTSQLInstruction * CreateGlobalIntegerSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_INTEGER_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalIntegerGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_INTEGER_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryIntegerBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_INTEGER_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryIntegerBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_INTEGER_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateIntegerPlus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(INTEGER_PLUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateIntegerMinus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(INTEGER_MINUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateIntegerTimes(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(INTEGER_TIMES, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateIntegerDivide(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(INTEGER_DIVIDE, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateIntegerUnaryMinus(MTSQLRegister lhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(INTEGER_UNARY_MINUS, lhs, -1, ret);
  }
  static MTSQLInstruction * CreateCastToInteger(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_INTEGER, arg, -1, ret);
  }
  static MTSQLInstruction * CreateIntegerModulus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(INTEGER_MODULUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateLoadIntegerImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_INTEGER_IMMEDIATE, value, arg);
  }
  
  // BigInt instructions
  static MTSQLInstruction * CreateGlobalBigIntSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_BIGINT_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalBigIntGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_BIGINT_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryBigIntBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_BIGINT_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryBigIntBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_BIGINT_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateBigIntPlus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BIGINT_PLUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBigIntMinus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BIGINT_MINUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBigIntTimes(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BIGINT_TIMES, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBigIntDivide(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BIGINT_DIVIDE, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBigIntUnaryMinus(MTSQLRegister lhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BIGINT_UNARY_MINUS, lhs, -1, ret);
  }
  static MTSQLInstruction * CreateCastToBigInt(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_BIGINT, arg, -1, ret);
  }
  static MTSQLInstruction * CreateBigIntModulus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BIGINT_MODULUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateLoadBigIntImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_BIGINT_IMMEDIATE, value, arg);
  }
  
  // Decimal instructions
  static MTSQLInstruction * CreateGlobalDecimalSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_DECIMAL_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalDecimalGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_DECIMAL_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryDecimalBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_DECIMAL_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryDecimalBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_DECIMAL_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateDecimalPlus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DECIMAL_PLUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDecimalMinus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DECIMAL_MINUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDecimalTimes(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DECIMAL_TIMES, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDecimalDivide(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DECIMAL_DIVIDE, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDecimalUnaryMinus(MTSQLRegister lhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DECIMAL_UNARY_MINUS, lhs, -1, ret);
  }
  static MTSQLInstruction * CreateCastToDecimal(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_DECIMAL, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLoadDecimalImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_DECIMAL_IMMEDIATE, value, arg);
  }

  // Double instructions
  static MTSQLInstruction * CreateGlobalDoubleSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_DOUBLE_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalDoubleGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_DOUBLE_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryDoubleBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_DOUBLE_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryDoubleBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_DOUBLE_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateDoublePlus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DOUBLE_PLUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDoubleMinus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DOUBLE_MINUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDoubleTimes(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DOUBLE_TIMES, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDoubleDivide(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DOUBLE_DIVIDE, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateDoubleUnaryMinus(MTSQLRegister lhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(DOUBLE_UNARY_MINUS, lhs, -1, ret);
  }
  static MTSQLInstruction * CreateCastToDouble(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_DOUBLE, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLoadDoubleImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_DOUBLE_IMMEDIATE, value, arg);
  }

  // String instructions
  static MTSQLInstruction * CreateGlobalStringSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_STRING_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalStringGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_STRING_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryStringBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_STRING_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryStringBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_STRING_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateStringPlus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(STRING_PLUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateCastToString(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_STRING, arg, -1, ret);
  }
  static MTSQLInstruction * CreateStringLike(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(STRING_LIKE, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateLoadStringImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_STRING_IMMEDIATE, value, arg);
  }
  
  // WideString instructions
  static MTSQLInstruction * CreateGlobalWideStringSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_WSTRING_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalWideStringGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_WSTRING_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryWideStringBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_WSTRING_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryWideStringBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_WSTRING_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateWideStringPlus(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(WSTRING_PLUS, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateCastToWideString(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_WSTRING, arg, -1, ret);
  }
  static MTSQLInstruction * CreateWideStringLike(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(WSTRING_LIKE, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateLoadWideStringImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_WSTRING_IMMEDIATE, value, arg);
  }
  
  // Datetime instructions
  static MTSQLInstruction * CreateGlobalDatetimeSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_DATETIME_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalDatetimeGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_DATETIME_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryDatetimeBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_DATETIME_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryDatetimeBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_DATETIME_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateCastToDatetime(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_DATETIME, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLoadDatetimeImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_DATETIME_IMMEDIATE, value, arg);
  }
  
  // Time instructions
  static MTSQLInstruction * CreateGlobalTimeSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_TIME_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalTimeGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_TIME_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryTimeBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_TIME_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryTimeBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_TIME_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateCastToTime(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_TIME, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLoadTimeImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_TIME_IMMEDIATE, value, arg);
  }
  
  // Enum instructions
  static MTSQLInstruction * CreateGlobalEnumSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_ENUM_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalEnumGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_ENUM_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryEnumBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_ENUM_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryEnumBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_ENUM_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateCastToEnum(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_ENUM, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLoadEnumImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_ENUM_IMMEDIATE, value, arg);
  }
  
  // Boolean instructions
  static MTSQLInstruction * CreateGlobalBooleanSetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_BOOLEAN_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalBooleanGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_BOOLEAN_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryBooleanBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_BOOLEAN_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryBooleanBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_BOOLEAN_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateCastToBoolean(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_BOOLEAN, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLoadBooleanImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_BOOLEAN_IMMEDIATE, value, arg);
  }

  // Binary instructions
  static MTSQLInstruction * CreateGlobalBinarySetmem(AccessPtr addr, MTSQLRegister arg)
  { 
    return new MTSQLInstruction(GLOBAL_BINARY_SETMEM, arg, -1, addr);
  }
  static MTSQLInstruction * CreateGlobalBinaryGetmem(AccessPtr addr, MTSQLRegister ret)
  { 
    return new MTSQLInstruction(GLOBAL_BINARY_GETMEM, -1, ret, addr);
  }
  static MTSQLInstruction * CreateQueryBinaryBindParameter(RuntimeValue param, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_BINARY_BIND_PARAM, param, val);
  }
  static MTSQLInstruction * CreateQueryBinaryBindColumn(RuntimeValue column, MTSQLRegister val)
  { 
    return new MTSQLInstruction(QUERY_BINARY_BIND_COLUMN, column, val);
  }
  static MTSQLInstruction * CreateCastToBinary(MTSQLRegister arg, MTSQLRegister ret)
  {
    return new MTSQLInstruction(CAST_TO_BINARY, arg, -1, ret);
  }
  static MTSQLInstruction * CreateLoadBinaryImmediate(MTSQLRegister arg, RuntimeValue value)
  { 
    return new MTSQLInstruction(LOAD_BINARY_IMMEDIATE, value, arg);
  }
  
  // Bitwise operations
  static MTSQLInstruction * CreateBitwiseAndInteger(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_AND_INTEGER, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBitwiseOrInteger(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_OR_INTEGER, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBitwiseXorInteger(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_XOR_INTEGER, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBitwiseNotInteger(MTSQLRegister val, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_NOT_INTEGER, val, -1, ret);
  }
  static MTSQLInstruction * CreateBitwiseAndBigInt(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_AND_BIGINT, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBitwiseOrBigInt(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_OR_BIGINT, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBitwiseXorBigInt(MTSQLRegister lhs, MTSQLRegister rhs, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_XOR_BIGINT, lhs, rhs, ret);
  }
  static MTSQLInstruction * CreateBitwiseNotBigInt(MTSQLRegister val, MTSQLRegister ret)
  {
    return new MTSQLInstruction(BITWISE_NOT_BIGINT, val, -1, ret);
  }

  // Print support
  static MTSQLInstruction * CreateStringPrint(MTSQLRegister arg)
  {
    return new MTSQLInstruction(STRING_PRINT, arg, -1, -1);
  }
  static MTSQLInstruction * CreateWStringPrint(MTSQLRegister arg)
  {
    return new MTSQLInstruction(WSTRING_PRINT, arg, -1, -1);
  }
  static MTSQLInstruction * CreateIsOkPrint(MTSQLRegister ret)
  {
    return new MTSQLInstruction(IS_OK_PRINT, -1, -1, ret);
  }
  // Error instructions
  static MTSQLInstruction * CreateThrow(RuntimeValue value)
  {
    return new MTSQLInstruction(THROW, value, -1);
  }
  static MTSQLInstruction * CreateRaiseErrorInteger(MTSQLRegister value)
  {
    return new MTSQLInstruction(RAISE_ERROR_INTEGER, value, -1, -1);
  }
  static MTSQLInstruction * CreateRaiseErrorString(MTSQLRegister value)
  {
    return new MTSQLInstruction(RAISE_ERROR_STRING, value, -1, -1);
  }
  static MTSQLInstruction * CreateRaiseErrorStringInteger(MTSQLRegister i, MTSQLRegister str)
  {
    return new MTSQLInstruction(RAISE_ERROR_STRING_INTEGER, i, str, -1);
  }
  static MTSQLInstruction * CreateRaiseErrorWString(MTSQLRegister value)
  {
    return new MTSQLInstruction(RAISE_ERROR_WSTRING, value, -1, -1);
  }
  static MTSQLInstruction * CreateRaiseErrorWStringInteger(MTSQLRegister i, MTSQLRegister str)
  {
    return new MTSQLInstruction(RAISE_ERROR_WSTRING_INTEGER, i, str, -1);
  }
  // Query instructions
  static MTSQLInstruction * CreateQueryAlloc(RuntimeValue queryString)
  {
    return new MTSQLInstruction(QUERY_ALLOC, queryString, -1);
  }
  static MTSQLInstruction * CreateQueryExecute(MTSQLProgramLabel ifRecordCountZero)
  {
    return new MTSQLInstruction(QUERY_EXEC, -1, ifRecordCountZero);
  }
  static MTSQLInstruction * CreateQueryFree()
  {
    return new MTSQLInstruction(QUERY_FREE, -1, -1, -1);
  }
  static MTSQLInstruction * CreateQueryBindParam(RuntimeValue param, MTSQLRegister val)
  {
    return new MTSQLInstruction(QUERY_BIND_PARAM, param, val);
  }
  
  ~MTSQLInstruction()
  {
  }
  
  Type GetType() const { return mType; }
  MTSQLRegister GetArg1() const { return mArg1; }
  MTSQLRegister GetArg2() const { return mArg2; }
  MTSQLRegister GetReturn() const { return mReturn; }
  MTSQLProgramLabel GetLabel() const { return mLabel; }
  void SetLabel(MTSQLProgramLabel value) { mLabel = value; }
  const RuntimeValue& GetImmediate() const { return mImmediate; }
  Access* GetAddress() { return mAddress.get(); }
  const std::string& GetFunctionName() const { return mFuncName;}
  const std::vector<MTSQLRegister>& GetFunctionArguements() {return mArguements;}
  static std::string PrintType(Type type);
  std::string PrintType() const;
  std::string Print() const;
};

#endif
