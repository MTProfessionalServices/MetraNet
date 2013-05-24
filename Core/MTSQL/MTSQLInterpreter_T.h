#ifndef _MTSQLINTERPRETER_T_H_
#define _MTSQLINTERPRETER_T_H_

#include <stdexcept>
#include <boost/format.hpp>
#include <boost/cstdint.hpp>

#include "metralite.h"
#include "MTSQLInterpreter.h"
#include "MTSQLInstruction.h"
#include "PrimitiveFunctionLibrary.h"
#include "MTSQLSelectCommand.h"
#include "RuntimeValueCast.h"
#include "Environment.h"

template <class _RuntimeEnvironment>
class MTSQLRegisterMachine_T
{
public:
  typedef _RuntimeEnvironment environment;
private:
  RuntimeValue * mRegisters;
  int mNumRegisters;
  // These 3 pointers store the instructions.
  unsigned char * mStart;
  unsigned char * mPosition;
  unsigned char * mEnd;
  const RuntimeValue ** mFunctionArg;
  int mFunctionArgCapacity;
  TransactionContext * mTrans;
  NameIDProxy mNameID;

  // Builders for the instructions.
  void reserve(std::size_t sz)
  {
    ASSERT(mEnd >= mPosition);
    ASSERT(mPosition>=mStart);
    if (sz < std::size_t(mEnd-mPosition)) return;
    // Make sure that sz additional bytes will fit and that we increase
    // by at least a factor of 2.
    std::size_t toAlloc = sz > std::size_t(((mEnd-mStart) + (mEnd-mPosition))) ? 
      sz + std::size_t(mPosition-mStart) : 
      2*std::size_t(mEnd-mStart);
    unsigned char * newBuffer = new unsigned char [toAlloc];
    memcpy(newBuffer, mStart, mPosition-mStart);
    mPosition = newBuffer + (mPosition-mStart);
    mEnd = newBuffer + toAlloc;
    delete [] mStart;
    mStart = newBuffer;
  }

  void push_back(std::size_t regOrLabel)
  {
    reserve(sizeof(size_t));
    *((size_t *)mPosition) = regOrLabel;
    mPosition += sizeof(size_t);
  }

  void push_back(const string& func)
  {
    // Always preserve 4 byte alignment.
    std::size_t strStorage((((func.size()+1)*sizeof(char)+3) >> 2) << 2);
    push_back(strStorage);
    reserve(strStorage);
    strcpy((char *)mPosition, func.c_str());
    mPosition += strStorage;
  }

  void push_back(const char * func)
  {
    push_back(std::string(func));
  }

  void push_back(const wstring& func)
  {
    // Always preserve 4 byte alignment.
    std::size_t strStorage((((func.size()+1)*sizeof(wchar_t)+3) >> 2) << 2);
    push_back(strStorage);
    reserve(strStorage);
    wcscpy((wchar_t *)mPosition, func.c_str());
    mPosition += strStorage;
  }

  void push_back(MTSQLInstruction::Type ty)
  {
    reserve(sizeof(MTSQLInstruction::Type));
    *((MTSQLInstruction::Type *)mPosition) = ty;
    mPosition += sizeof(MTSQLInstruction::Type);
  }

  typedef struct tagLoadIntegerInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    long Value;
  } LoadIntegerInstruction;

  typedef struct tagLoadBigIntInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    boost::int64_t Value;
  } LoadBigIntInstruction;

  typedef struct tagLoadDecimalInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    DECIMAL Value;
  } LoadDecimalInstruction;

  typedef struct tagLoadDoubleInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    double Value;
  } LoadDoubleInstruction;

  typedef struct tagLoadDatetimeInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    DATE Value;
  } LoadDatetimeInstruction;

  typedef struct tagLoadTimeInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    long Value;
  } LoadTimeInstruction;

  typedef struct tagLoadEnumInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    long Value;
  } LoadEnumInstruction;

  typedef struct tagLoadBooleanInstruction
  {
    MTSQLInstruction::Type Type;
    // Put bool here because we want our struct to
    // have word alignment and a bool might be a single byte!
    // struct MEMBER alignment will make sure all is well
    // because the next member is a machine word.
    bool Value;
    MTSQLRegister Return;
  } LoadBooleanInstruction;

  typedef struct tagLoadBinaryInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    unsigned char Value[16];
  } LoadBinaryInstruction;

  typedef struct tagNullaryBranchInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
    MTSQLProgramLabel Label;
  } NullaryBranchInstruction;

  typedef struct tagUnaryBranchInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
    MTSQLProgramLabel Label;
  } UnaryBranchInstruction;

  typedef struct tagNullaryOpInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
    MTSQLRegister Return;
  } NullaryOpInstruction;

  typedef struct tagUnaryOpInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
    MTSQLRegister Return;
  } UnaryOpInstruction;

  typedef struct tagBinaryOpInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
    MTSQLRegister Arg2;
    MTSQLRegister Return;
  } BinaryOpInstruction;

  typedef struct tagUnaryOutputInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
  } UnaryOutputInstruction;

  typedef struct tagBinaryOutputInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
    MTSQLRegister Arg2;
  } BinaryOutputInstruction;

  typedef struct tagGlobalSetmemInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Arg1;
    typename environment::activation_record::access * Address;
  } GlobalSetmemInstruction;

  typedef struct tagGlobalGetmemInstruction
  {
    MTSQLInstruction::Type Type;
    MTSQLRegister Return;
    typename environment::activation_record::access * Address;
  } GlobalGetmemInstruction;

  typedef struct tagQueryBindInstruction
  {
    MTSQLInstruction::Type Type;
    long Index;
    MTSQLRegister Return;
  } QueryBindInstruction;

  void Convert(const std::vector<MTSQLInstruction *>& prog)
  {
    // Each instruction is a possible label.  The incoming
    // representation of labels is as vector offsets in the
    // instruction array.  We are abandoning fixed length
    // instructions in the target representation so we must
    // must represent labels as byte offsets.  Note that we
    // use byte offsets rather than actual pointers to have
    // position independent code. 
    //
    // The way we perform the translation is to make a first
    // pass in which we stick the input label into the instruction
    // stream.  At the time we do that we record the byte offset
    // at which put the label.
    // After the first pass is complete and all instruction offsets
    // are available we walk the recorded labels and convert them
    // to offsets.
    std::vector<size_t> instructionOffsets;
    std::vector<size_t> labelPositions;

    for(std::vector<MTSQLInstruction *>::const_iterator it = prog.begin();
        it != prog.end();
        ++it)
    {
      MTSQLInstruction * inst = *it;
      instructionOffsets.push_back(mPosition-mStart);
      switch(inst->GetType())
      {
      case MTSQLInstruction::EXEC_PRIMITIVE_FUNC:
      {
        push_back(inst->GetType());
        push_back(inst->GetFunctionArguements().size());
        for(std::vector<MTSQLRegister>::const_iterator it = inst->GetFunctionArguements().begin();
            it != inst->GetFunctionArguements().end();
            ++it)
        {
          push_back(*it);
        }
        push_back(inst->GetReturn());
        push_back(inst->GetFunctionName());
        break;
      }
      case MTSQLInstruction::NOT:
      case MTSQLInstruction::ISNULL:
      case MTSQLInstruction::MOVE:
      case MTSQLInstruction::CAST_TO_INTEGER:
      case MTSQLInstruction::INTEGER_UNARY_MINUS:
      case MTSQLInstruction::CAST_TO_BIGINT:
      case MTSQLInstruction::BIGINT_UNARY_MINUS:
      case MTSQLInstruction::CAST_TO_DECIMAL:
      case MTSQLInstruction::DECIMAL_UNARY_MINUS:
      case MTSQLInstruction::CAST_TO_DOUBLE:
      case MTSQLInstruction::DOUBLE_UNARY_MINUS:
      case MTSQLInstruction::CAST_TO_STRING:
      case MTSQLInstruction::CAST_TO_WSTRING:
      case MTSQLInstruction::CAST_TO_DATETIME:
      case MTSQLInstruction::CAST_TO_TIME:
      case MTSQLInstruction::CAST_TO_ENUM:
      case MTSQLInstruction::CAST_TO_BOOLEAN:
      case MTSQLInstruction::CAST_TO_BINARY:
      case MTSQLInstruction::BITWISE_NOT_INTEGER:
      case MTSQLInstruction::BITWISE_NOT_BIGINT:
      {
        reserve(sizeof(UnaryOpInstruction));
        UnaryOpInstruction * i = (UnaryOpInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Arg1 = inst->GetArg1();
        i->Return = inst->GetReturn();
        mPosition += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GT:
      case MTSQLInstruction::GTEQ:
      case MTSQLInstruction::LTN:
      case MTSQLInstruction::LTEQ:
      case MTSQLInstruction::NOTEQUALS:
      case MTSQLInstruction::EQUALS:
      case MTSQLInstruction::INTEGER_PLUS:
      case MTSQLInstruction::INTEGER_TIMES:
      case MTSQLInstruction::INTEGER_DIVIDE:
      case MTSQLInstruction::INTEGER_MINUS:
      case MTSQLInstruction::INTEGER_MODULUS:
      case MTSQLInstruction::BIGINT_PLUS:
      case MTSQLInstruction::BIGINT_TIMES:
      case MTSQLInstruction::BIGINT_DIVIDE:
      case MTSQLInstruction::BIGINT_MINUS:
      case MTSQLInstruction::BIGINT_MODULUS:
      case MTSQLInstruction::DECIMAL_PLUS:
      case MTSQLInstruction::DECIMAL_TIMES:
      case MTSQLInstruction::DECIMAL_DIVIDE:
      case MTSQLInstruction::DECIMAL_MINUS:
      case MTSQLInstruction::DOUBLE_PLUS:
      case MTSQLInstruction::DOUBLE_TIMES:
      case MTSQLInstruction::DOUBLE_DIVIDE:
      case MTSQLInstruction::DOUBLE_MINUS:
      case MTSQLInstruction::STRING_PLUS:
      case MTSQLInstruction::STRING_LIKE:
      case MTSQLInstruction::WSTRING_PLUS:
      case MTSQLInstruction::WSTRING_LIKE:
      case MTSQLInstruction::BITWISE_AND_INTEGER:
      case MTSQLInstruction::BITWISE_OR_INTEGER:
      case MTSQLInstruction::BITWISE_XOR_INTEGER:
      case MTSQLInstruction::BITWISE_AND_BIGINT:
      case MTSQLInstruction::BITWISE_OR_BIGINT:
      case MTSQLInstruction::BITWISE_XOR_BIGINT:
      {
        reserve(sizeof(BinaryOpInstruction));
        BinaryOpInstruction * i = (BinaryOpInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Arg1 = inst->GetArg1();
        i->Arg2 = inst->GetArg2();
        i->Return = inst->GetReturn();
        mPosition += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_INTEGER_IMMEDIATE:
      {
        reserve(sizeof(LoadIntegerInstruction));
        LoadIntegerInstruction * i = (LoadIntegerInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Value = inst->GetImmediate().getLong();
        mPosition += sizeof(LoadIntegerInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_BIGINT_IMMEDIATE:
      {
        reserve(sizeof(LoadBigIntInstruction));
        LoadBigIntInstruction * i = (LoadBigIntInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Value = inst->GetImmediate().getLongLong();
        mPosition += sizeof(LoadBigIntInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_DATETIME_IMMEDIATE:
      {
        reserve(sizeof(LoadDatetimeInstruction));
        LoadDatetimeInstruction * i = (LoadDatetimeInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Value = inst->GetImmediate().getDatetime();
        mPosition += sizeof(LoadDatetimeInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_DECIMAL_IMMEDIATE:
      {
        reserve(sizeof(LoadDecimalInstruction));
        LoadDecimalInstruction * i = (LoadDecimalInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        memcpy(&(i->Value), inst->GetImmediate().getDecPtr(), sizeof(DECIMAL));
        mPosition += sizeof(LoadDecimalInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_DOUBLE_IMMEDIATE:
      {
        reserve(sizeof(LoadDoubleInstruction));
        LoadDoubleInstruction * i = (LoadDoubleInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Value = inst->GetImmediate().getDouble();
        mPosition += sizeof(LoadDoubleInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_STRING_IMMEDIATE:
      {
        push_back(inst->GetType());
        push_back(inst->GetReturn());
        push_back(inst->GetImmediate().getStringPtr());
        break;
      }
      case MTSQLInstruction::LOAD_WSTRING_IMMEDIATE:
      {
        push_back(inst->GetType());
        push_back(inst->GetReturn());
        push_back(inst->GetImmediate().getWStringPtr());
        break;
      }
      case MTSQLInstruction::LOAD_TIME_IMMEDIATE:
      {
        reserve(sizeof(LoadTimeInstruction));
        LoadTimeInstruction * i = (LoadTimeInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Value = inst->GetImmediate().getTime();
        mPosition += sizeof(LoadTimeInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_ENUM_IMMEDIATE:
      {
        reserve(sizeof(LoadEnumInstruction));
        LoadEnumInstruction * i = (LoadEnumInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Value = inst->GetImmediate().getEnum();
        mPosition += sizeof(LoadEnumInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_BOOLEAN_IMMEDIATE:
      {
        reserve(sizeof(LoadBooleanInstruction));
        LoadBooleanInstruction * i = (LoadBooleanInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Value = inst->GetImmediate().getBool();
        mPosition += sizeof(LoadBooleanInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_BINARY_IMMEDIATE:
      {
        reserve(sizeof(LoadBinaryInstruction));
        LoadBinaryInstruction * i = (LoadBinaryInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        memcpy(&i->Value[0], inst->GetImmediate().getBinaryPtr(), 16);
        mPosition += sizeof(LoadBinaryInstruction);
        break;
      }
      case MTSQLInstruction::BRANCH_ON_CONDITION:
      {
        reserve(sizeof(UnaryBranchInstruction));
        UnaryBranchInstruction * i = (UnaryBranchInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Arg1 = inst->GetArg1();
        i->Label = inst->GetLabel();
        mPosition += sizeof(UnaryBranchInstruction);
        // Labels here are vector offsets,
        // these must be translated to byte offsets.
        // Record where I put the label so that it can
        // fixed up later.
        labelPositions.push_back(((unsigned char *)&(i->Label))-mStart);
        break;
      }
      case MTSQLInstruction::GOTO:
      case MTSQLInstruction::QUERY_EXEC:
      {
        reserve(sizeof(NullaryBranchInstruction));
        NullaryBranchInstruction * i = (NullaryBranchInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Label = inst->GetLabel();
        mPosition += sizeof(NullaryBranchInstruction);
        // Labels here are vector offsets,
        // these must be translated to byte offsets.
        // Record where I put the label so that it can
        // fixed up later.
        labelPositions.push_back(((unsigned char *)&(i->Label))-mStart);
        break;
      }
      case MTSQLInstruction::RETURN:
      case MTSQLInstruction::QUERY_FREE:
      {
        push_back(inst->GetType());
        break;
      }
      case MTSQLInstruction::GLOBAL_INTEGER_SETMEM:
      case MTSQLInstruction::GLOBAL_BIGINT_SETMEM:
      case MTSQLInstruction::GLOBAL_DECIMAL_SETMEM:
      case MTSQLInstruction::GLOBAL_DOUBLE_SETMEM:
      case MTSQLInstruction::GLOBAL_STRING_SETMEM:
      case MTSQLInstruction::GLOBAL_WSTRING_SETMEM:
      case MTSQLInstruction::GLOBAL_DATETIME_SETMEM:
      case MTSQLInstruction::GLOBAL_TIME_SETMEM:
      case MTSQLInstruction::GLOBAL_ENUM_SETMEM:
      case MTSQLInstruction::GLOBAL_BOOLEAN_SETMEM:
      case MTSQLInstruction::GLOBAL_BINARY_SETMEM:
      {
        reserve(sizeof(GlobalSetmemInstruction));
        GlobalSetmemInstruction * i = (GlobalSetmemInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Arg1 = inst->GetArg1();
        i->Address = dynamic_cast<typename environment::activation_record::access *>(inst->GetAddress());
        mPosition += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_INTEGER_GETMEM:
      case MTSQLInstruction::GLOBAL_BIGINT_GETMEM:
      case MTSQLInstruction::GLOBAL_DECIMAL_GETMEM:
      case MTSQLInstruction::GLOBAL_DOUBLE_GETMEM:
      case MTSQLInstruction::GLOBAL_STRING_GETMEM:
      case MTSQLInstruction::GLOBAL_WSTRING_GETMEM:
      case MTSQLInstruction::GLOBAL_DATETIME_GETMEM:
      case MTSQLInstruction::GLOBAL_TIME_GETMEM:
      case MTSQLInstruction::GLOBAL_ENUM_GETMEM:
      case MTSQLInstruction::GLOBAL_BOOLEAN_GETMEM:
      case MTSQLInstruction::GLOBAL_BINARY_GETMEM:
      {
        reserve(sizeof(GlobalGetmemInstruction));
        GlobalGetmemInstruction * i = (GlobalGetmemInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        i->Address = dynamic_cast<typename environment::activation_record::access *>(inst->GetAddress());
        mPosition += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_NULL_IMMEDIATE:
      case MTSQLInstruction::IS_OK_PRINT:
      {
        reserve(sizeof(NullaryOpInstruction));
        NullaryOpInstruction * i = (NullaryOpInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Return = inst->GetReturn();
        mPosition += sizeof(NullaryOpInstruction);
        break;
      }
      case MTSQLInstruction::STRING_PRINT:
      case MTSQLInstruction::WSTRING_PRINT:
      case MTSQLInstruction::RAISE_ERROR_INTEGER:
      case MTSQLInstruction::RAISE_ERROR_STRING:
      case MTSQLInstruction::RAISE_ERROR_WSTRING:
      {
        reserve(sizeof(UnaryOutputInstruction));
        UnaryOutputInstruction * i = (UnaryOutputInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Arg1 = inst->GetArg1();
        mPosition += sizeof(UnaryOutputInstruction);
        break;
      }
      case MTSQLInstruction::THROW:
      {
        push_back(inst->GetType());
        push_back(inst->GetImmediate().castToString().getStringPtr());
        break;
      }
      case MTSQLInstruction::RAISE_ERROR_STRING_INTEGER:
      case MTSQLInstruction::RAISE_ERROR_WSTRING_INTEGER:
      {
        reserve(sizeof(BinaryOutputInstruction));
        BinaryOutputInstruction * i = (BinaryOutputInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Arg1 = inst->GetArg1();
        i->Arg2 = inst->GetArg2();
        mPosition += sizeof(BinaryOutputInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_ALLOC:
      {
        push_back(inst->GetType());
        push_back(inst->GetImmediate().getWStringPtr());
        break;
      }
      case MTSQLInstruction::QUERY_BIND_PARAM:
      case MTSQLInstruction::QUERY_INTEGER_BIND_COLUMN:
      case MTSQLInstruction::QUERY_DECIMAL_BIND_COLUMN:
      case MTSQLInstruction::QUERY_DOUBLE_BIND_COLUMN:
      case MTSQLInstruction::QUERY_STRING_BIND_COLUMN:
      case MTSQLInstruction::QUERY_WSTRING_BIND_COLUMN:
      case MTSQLInstruction::QUERY_DATETIME_BIND_COLUMN:
      case MTSQLInstruction::QUERY_TIME_BIND_COLUMN:
      case MTSQLInstruction::QUERY_ENUM_BIND_COLUMN:
      case MTSQLInstruction::QUERY_BOOLEAN_BIND_COLUMN:
      case MTSQLInstruction::QUERY_BINARY_BIND_COLUMN:
      {
        reserve(sizeof(QueryBindInstruction));
        QueryBindInstruction * i = (QueryBindInstruction *)mPosition;
        i->Type = inst->GetType();
        i->Index = inst->GetImmediate().getLong();
        i->Return = inst->GetReturn();
        mPosition += sizeof(QueryBindInstruction);
        break;
      }
      default:
      {
        MTSQLInstruction::Type type = inst->GetType();
        throw std::domain_error((boost::format("invalid instruction of type: %1%") % type).str());
      }
      }
    }

    ASSERT(instructionOffsets.size() == prog.size());

    // Stick in one more offset to the end of the program
    instructionOffsets.push_back(mEnd-mStart);

    // Fix up labels.  Note that labels point 1 behind where
    // they really should.
    for(std::vector<size_t>::iterator it = labelPositions.begin();
        it != labelPositions.end();
        ++it)
    {
      ASSERT(*it < std::size_t(mEnd-mStart));
      std::size_t original = *((std::size_t *)(mStart + *it));
      ASSERT(original < prog.size());
      *((std::size_t *)(mStart + *it)) = instructionOffsets[original+1];
    }
  }

public:
  MTSQLRegisterMachine_T(int numRegisters, const std::vector<MTSQLInstruction *>& prog)
    :
    mRegisters(NULL),
    mStart(NULL),
    mPosition(NULL),
    mEnd(NULL),
    mFunctionArg(NULL),
    mFunctionArgCapacity(10)
  {
    mNumRegisters = numRegisters;
    mRegisters = new RuntimeValue [mNumRegisters];
    mFunctionArg = new const RuntimeValue * [mFunctionArgCapacity];

    mStart = new unsigned char [1024];
    mPosition = mStart;
    mEnd = mStart + 1024;
    Convert(prog);
  }


  ~MTSQLRegisterMachine_T()
  {
    delete [] mRegisters;
    delete [] mFunctionArg;
    delete [] mStart;
  }

  void SetTransactionContext(TransactionContext * trans)
  {
    mTrans = trans;
  }
  void Execute(_RuntimeEnvironment * env, Logger * log)
  {
    unsigned char * programCounter = mStart;
    unsigned char * lastInstruction = mPosition;

    MTSQLSelectCommand * query = 0;

    typename environment::activation_record * globalEnvironment = env->getGlobalEnvironment();

    while(programCounter < lastInstruction)
    {
      switch(*((MTSQLInstruction::Type *)programCounter))
      {
      case MTSQLInstruction::EXEC_PRIMITIVE_FUNC:
      {
        programCounter += sizeof(MTSQLInstruction::Type);
        const std::size_t count(*((std::size_t *) programCounter));
        programCounter += sizeof(std::size_t);

        if (int(count) > mFunctionArgCapacity)
        {
          delete [] mFunctionArg;
          mFunctionArgCapacity = int(count);
          mFunctionArg = new const RuntimeValue * [mFunctionArgCapacity];
        }

        for (unsigned int i = 0; i < count; i++)
        {
          mFunctionArg[i] = &mRegisters[*((MTSQLRegister *)programCounter)];
          programCounter += sizeof(MTSQLRegister);
        }
        RuntimeValue * ret = &mRegisters[*((MTSQLRegister *)programCounter)];
        programCounter += sizeof(MTSQLRegister);

        const std::size_t strSize(*((std::size_t *) programCounter));
        programCounter += sizeof(std::size_t);

        env->executePrimitiveFunction((const char *)programCounter, mFunctionArg, (int) count, ret);
        programCounter += strSize;

        break;
      }
      case MTSQLInstruction::NOT:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        if(mRegisters[inst->Arg1].isNullRaw())
          mRegisters[inst->Return].assignNull();
        else if(mRegisters[inst->Arg1].getBool())
          mRegisters[inst->Return].assignBool(false);
        else
          mRegisters[inst->Return].assignBool(true);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GT:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::GreaterThan(&mRegisters[inst->Arg1], 
                                  &mRegisters[inst->Arg2], 
                                  &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GTEQ:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::GreaterThanEquals(&mRegisters[inst->Arg1], 
                                        &mRegisters[inst->Arg2], 
                                        &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::LTN:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LessThan(&mRegisters[inst->Arg1], 
                               &mRegisters[inst->Arg2], 
                               &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::LTEQ:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LessThanEquals(&mRegisters[inst->Arg1], 
                                     &mRegisters[inst->Arg2], 
                                     &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::EQUALS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::Equals(&mRegisters[inst->Arg1], 
                             &mRegisters[inst->Arg2], 
                             &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::NOTEQUALS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::NotEquals(&mRegisters[inst->Arg1], 
                                &mRegisters[inst->Arg2], 
                                &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::ISNULL:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].isNull(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::MOVE:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Return] = mRegisters[inst->Arg1];
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_NULL_IMMEDIATE:
      {
        NullaryOpInstruction * inst = (NullaryOpInstruction *)programCounter;
        mRegisters[inst->Return].assignNull();
        programCounter += sizeof(NullaryOpInstruction);
        break;      
      }
      case MTSQLInstruction::LOAD_INTEGER_IMMEDIATE:
      {
        LoadIntegerInstruction * inst = (LoadIntegerInstruction *)programCounter;
        mRegisters[inst->Return].assignLong(inst->Value);
        programCounter += sizeof(LoadIntegerInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_BIGINT_IMMEDIATE:
      {
        LoadBigIntInstruction * inst = (LoadBigIntInstruction *)programCounter;
        mRegisters[inst->Return].assignLongLong(inst->Value);
        programCounter += sizeof(LoadBigIntInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_DATETIME_IMMEDIATE:
      {
        LoadDatetimeInstruction * inst = (LoadDatetimeInstruction *)programCounter;
        mRegisters[inst->Return].assignDatetime(inst->Value);
        programCounter += sizeof(LoadDatetimeInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_DECIMAL_IMMEDIATE:
      {
        LoadDecimalInstruction * inst = (LoadDecimalInstruction *)programCounter;
        mRegisters[inst->Return].assignDec(&(inst->Value));
        programCounter += sizeof(LoadDecimalInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_DOUBLE_IMMEDIATE:
      {
        LoadDoubleInstruction * inst = (LoadDoubleInstruction *)programCounter;
        mRegisters[inst->Return].assignDouble(inst->Value);
        programCounter += sizeof(LoadDoubleInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_STRING_IMMEDIATE:
      {
        programCounter += sizeof(MTSQLInstruction::Type);
        MTSQLRegister ret(*(MTSQLRegister *)programCounter);
        programCounter += sizeof(MTSQLRegister);
        std::size_t toSkip(*(std::size_t *)programCounter);
        programCounter += sizeof(std::size_t);
        mRegisters[ret].assignString((const char *)programCounter);
        programCounter += toSkip;
        break;
      }
      case MTSQLInstruction::LOAD_WSTRING_IMMEDIATE:
      {
        programCounter += sizeof(MTSQLInstruction::Type);
        MTSQLRegister ret(*(MTSQLRegister *)programCounter);
        programCounter += sizeof(MTSQLRegister);
        std::size_t toSkip(*(std::size_t *)programCounter);
        programCounter += sizeof(std::size_t);
        mRegisters[ret].assignWString((const wchar_t *)programCounter);
        programCounter += toSkip;
        break;
      }
      case MTSQLInstruction::LOAD_TIME_IMMEDIATE:
      {
        LoadTimeInstruction * inst = (LoadTimeInstruction *)programCounter;
        mRegisters[inst->Return].assignTime(inst->Value);
        programCounter += sizeof(LoadTimeInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_ENUM_IMMEDIATE:
      {
        LoadEnumInstruction * inst = (LoadEnumInstruction *)programCounter;
        mRegisters[inst->Return].assignEnum(inst->Value);
        programCounter += sizeof(LoadEnumInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_BOOLEAN_IMMEDIATE:
      {
        LoadBooleanInstruction * inst = (LoadBooleanInstruction *)programCounter;
        mRegisters[inst->Return].assignBool(inst->Value);
        programCounter += sizeof(LoadBooleanInstruction);
        break;
      }
      case MTSQLInstruction::LOAD_BINARY_IMMEDIATE:
      {
        LoadBinaryInstruction * inst = (LoadBinaryInstruction *)programCounter;
        mRegisters[inst->Return].assignBinary(&inst->Value[0], &inst->Value[0]+16);
        programCounter += sizeof(LoadBinaryInstruction);
        break;
      }
      case MTSQLInstruction::BRANCH_ON_CONDITION:
      {
        UnaryBranchInstruction * inst = (UnaryBranchInstruction *) programCounter;
        if(!mRegisters[inst->Arg1].isNullRaw() && mRegisters[inst->Arg1].getBool())
        {
          programCounter += sizeof(UnaryBranchInstruction);
        }
        else
        {
          programCounter = mStart + inst->Label;
        }
        break;
      }
      case MTSQLInstruction::GOTO:
      {
        NullaryBranchInstruction * inst = (NullaryBranchInstruction *) programCounter;
        programCounter = mStart + inst->Label;
        break;
      }
      case MTSQLInstruction::RETURN:
      {
        // Lame of me not to figure out how to compile RETURN into GOTO :-(
        programCounter = lastInstruction;
        break;
      }
      case MTSQLInstruction::GLOBAL_INTEGER_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setLongValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_INTEGER_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getLongValue(inst->Address, &mRegisters[inst->Return] );
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::INTEGER_PLUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::INTEGER_TIMES:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::INTEGER_DIVIDE:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::INTEGER_MINUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_INTEGER:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToLong(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::INTEGER_UNARY_MINUS:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValue::LongUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::INTEGER_MODULUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongModulus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_BIGINT_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setLongLongValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_BIGINT_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getLongLongValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::BIGINT_PLUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongLongPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BIGINT_TIMES:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongLongTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BIGINT_DIVIDE:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongLongDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BIGINT_MINUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongLongMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_BIGINT:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToLongLong(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BIGINT_UNARY_MINUS:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValue::LongLongUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BIGINT_MODULUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::LongLongModulus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_DECIMAL_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setDecimalValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_DECIMAL_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getDecimalValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::DECIMAL_PLUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DecimalPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DECIMAL_TIMES:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DecimalTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DECIMAL_DIVIDE:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DecimalDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DECIMAL_MINUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DecimalMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_DECIMAL:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToDec(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DECIMAL_UNARY_MINUS:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValue::DecimalUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_DOUBLE_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setDoubleValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_DOUBLE_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getDoubleValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::DOUBLE_PLUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DoublePlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DOUBLE_TIMES:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DoubleTimes(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DOUBLE_DIVIDE:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DoubleDivide(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DOUBLE_MINUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::DoubleMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_DOUBLE:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToDouble(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::DOUBLE_UNARY_MINUS:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValue::DoubleUnaryMinus(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_STRING_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setStringValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_STRING_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getStringValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::STRING_PLUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::StringPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_STRING:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValueCast::ToString(&mRegisters[inst->Return], &mRegisters[inst->Arg1], mNameID.GetEnumConfig());
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::STRING_LIKE:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        mRegisters[inst->Return] = RuntimeValue::StringLike(mRegisters[inst->Arg1], mRegisters[inst->Arg2]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_WSTRING_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setWStringValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_WSTRING_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getWStringValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::WSTRING_PLUS:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::WStringPlus(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_WSTRING:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValueCast::ToWString(&mRegisters[inst->Return], &mRegisters[inst->Arg1], mNameID.GetEnumConfig());
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::WSTRING_LIKE:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        mRegisters[inst->Return] = RuntimeValue::WStringLike(mRegisters[inst->Arg1], mRegisters[inst->Arg2]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_DATETIME_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setDatetimeValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_DATETIME_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getDatetimeValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_DATETIME:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToDatetime(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_TIME_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setTimeValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_TIME_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getTimeValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_TIME:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToTime(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_ENUM_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setEnumValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_ENUM_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getEnumValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_ENUM:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValueCast::ToEnum(&mRegisters[inst->Return], &mRegisters[inst->Arg1], mNameID.GetNameID());
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_BOOLEAN_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setBooleanValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_BOOLEAN_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getBooleanValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_BOOLEAN:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToBool(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_BINARY_SETMEM:
      {
        GlobalSetmemInstruction * inst = (GlobalSetmemInstruction *) programCounter;
        globalEnvironment->setBinaryValue(inst->Address, &mRegisters[inst->Arg1]);
        programCounter += sizeof(GlobalSetmemInstruction);
        break;
      }
      case MTSQLInstruction::GLOBAL_BINARY_GETMEM:
      {
        GlobalGetmemInstruction * inst = (GlobalGetmemInstruction *) programCounter;
        globalEnvironment->getBinaryValue(inst->Address, &mRegisters[inst->Return]);
        programCounter += sizeof(GlobalGetmemInstruction);
        break;
      }
      case MTSQLInstruction::CAST_TO_BINARY:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        mRegisters[inst->Arg1].castToBinary(&mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_AND_INTEGER:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseAndLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_OR_INTEGER:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseOrLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_XOR_INTEGER:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseXorLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_NOT_INTEGER:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseNotLong(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_AND_BIGINT:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseAndLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_OR_BIGINT:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseOrLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_XOR_BIGINT:
      {
        BinaryOpInstruction * inst = (BinaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseXorLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Arg2], &mRegisters[inst->Return]);
        programCounter += sizeof(BinaryOpInstruction);
        break;
      }
      case MTSQLInstruction::BITWISE_NOT_BIGINT:
      {
        UnaryOpInstruction * inst = (UnaryOpInstruction *)programCounter;
        RuntimeValue::BitwiseNotLongLong(&mRegisters[inst->Arg1], &mRegisters[inst->Return]);
        programCounter += sizeof(UnaryOpInstruction);
        break;
      }
      case MTSQLInstruction::IS_OK_PRINT:
      {
        NullaryOpInstruction * inst = (NullaryOpInstruction *)programCounter;
        mRegisters[inst->Return].assignBool(log->isOkToLogDebug());
        programCounter += sizeof(NullaryOpInstruction);
        break;
      }
      case MTSQLInstruction::STRING_PRINT:
      {
        UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
        RuntimeValue& r (mRegisters[inst->Arg1]);
        log->logDebug(r.isNullRaw() ? "NULL" : r.getStringPtr());
        programCounter += sizeof(UnaryOutputInstruction);
        break;
      }
      case MTSQLInstruction::WSTRING_PRINT:
      {
        UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
        RuntimeValue& r (mRegisters[inst->Arg1]);
        log->logDebug(r.isNullRaw() ? "NULL" : r.castToString().getStringPtr());
        programCounter += sizeof(UnaryOutputInstruction);
        break;
      }
      case MTSQLInstruction::THROW:
      {
        programCounter += sizeof(MTSQLInstruction::Type);
        programCounter += sizeof(std::size_t);
        throw MTSQLRuntimeErrorException((const char *)programCounter);
      }
      case MTSQLInstruction::RAISE_ERROR_INTEGER:
      {
        UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
        throw MTSQLUserException("", mRegisters[inst->Arg1].isNullRaw() ?
                                 E_FAIL :
                                 mRegisters[inst->Arg1].getLong());
      }
      case MTSQLInstruction::RAISE_ERROR_STRING:
      {
        UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
        throw MTSQLUserException(mRegisters[inst->Arg1].isNullRaw() ?
                                 "NULL" :
                                 mRegisters[inst->Arg1].getStringPtr(), E_FAIL);
      }
      case MTSQLInstruction::RAISE_ERROR_STRING_INTEGER:
      {
        BinaryOutputInstruction * inst = (BinaryOutputInstruction *)programCounter;
        throw MTSQLUserException(mRegisters[inst->Arg2].isNullRaw() ?
                                 "NULL" :
                                 mRegisters[inst->Arg2].getStringPtr(), 
                                 mRegisters[inst->Arg1].isNullRaw() ?
                                 E_FAIL :
                                 mRegisters[inst->Arg1].getLong());
      }
      case MTSQLInstruction::RAISE_ERROR_WSTRING:
      {
        UnaryOutputInstruction * inst = (UnaryOutputInstruction *)programCounter;
        throw MTSQLUserException(mRegisters[inst->Arg1].isNullRaw() ?
                                 "NULL" :
                                 mRegisters[inst->Arg1].castToString().getStringPtr(), E_FAIL);
      }
      case MTSQLInstruction::RAISE_ERROR_WSTRING_INTEGER:
      {
        BinaryOutputInstruction * inst = (BinaryOutputInstruction *)programCounter;
        throw MTSQLUserException(mRegisters[inst->Arg2].isNullRaw() ?
                                 "NULL" :
                                 mRegisters[inst->Arg2].castToString().getStringPtr(), 
                                 mRegisters[inst->Arg1].isNullRaw() ?
                                 E_FAIL :
                                 mRegisters[inst->Arg1].getLong());
      }
      case MTSQLInstruction::QUERY_ALLOC:
      {
        programCounter += sizeof(MTSQLInstruction::Type);
        const std::size_t strSz(*((const std::size_t *) programCounter));
        programCounter += sizeof(std::size_t);
        query = new MTSQLSelectCommand(mTrans->getRowset());
        query->setQueryString((const wchar_t *) programCounter);
        programCounter += strSz;
        break;
      }
      case MTSQLInstruction::QUERY_EXEC:
      {
        NullaryBranchInstruction * inst = (NullaryBranchInstruction *)programCounter;
        query->execute();
        if (query->getRecordCount() < 1)
        {
          programCounter = mStart + inst->Label;
        } else if (query->getRecordCount() > 1) {
          programCounter += sizeof(NullaryBranchInstruction);
          log->logWarning("Multiple records returned from query; dropping all but the first");
        }
        else
        {
          programCounter += sizeof(NullaryBranchInstruction);
        }
        break;
      }
      case MTSQLInstruction::QUERY_FREE:
      {
        delete query;
        query = 0;
        programCounter += sizeof(MTSQLInstruction::Type);
        break;
      }
      case MTSQLInstruction::QUERY_BIND_PARAM:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        query->setParam(inst->Index, mRegisters[inst->Return]);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_INTEGER_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getLong(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_DECIMAL_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getDec(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_DOUBLE_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getDouble(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_STRING_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getString(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_WSTRING_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getWString(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_DATETIME_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getDatetime(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_TIME_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getTime(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_ENUM_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getEnum(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_BOOLEAN_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getBool(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      case MTSQLInstruction::QUERY_BINARY_BIND_COLUMN:
      {
        QueryBindInstruction * inst = (QueryBindInstruction *)programCounter;
        mRegisters[inst->Return] = query->getBinary(inst->Index);
        programCounter += sizeof(QueryBindInstruction);
        break;
      }
      default:
      {
        throw std::domain_error("invalid instruction");
      }
      }
    }
  }
  const RuntimeValue * GetReturnValue() const
  {
    return &mRegisters[0];
  }
};

// The ActivationRecord concept is
// access - type of access.  Right now must inherit from Access because
// it has to come out of the compile time infrastructure that is inheritence based.
// all getters and setters.
// 
// The RuntimeEnvironment concept needed by RegisterMachine has
// methods:
// getGlobalEnvironment
// executePrimitiveFunction
template <class _ActivationRecord>
class TestRuntimeEnvironment_T 
{
public:
  typedef _ActivationRecord activation_record;
private:
  _ActivationRecord mGlobalEnvironment;
	map<string, PrimitiveFunction*> mPrimitiveFun;
public:

	TestRuntimeEnvironment_T(const _ActivationRecord& globalEnvironment) 
    :
    mGlobalEnvironment(globalEnvironment)
	{
	}

  _ActivationRecord * getGlobalEnvironment()
  {
    return &mGlobalEnvironment;
  }

  void setGlobalEnvironment(const _ActivationRecord * globalEnvironment)
  {
    mGlobalEnvironment = *globalEnvironment;
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

// The register machine requires:
// TransactionContext
// RuntimeEnvironment
// Logger
//
// The RuntimeEnvironment concept has 
// getActivationRecord
// executePrimitiveFunction
// and is provided by the TestRuntimeEnvironment
//
// The logger concept has
// logDebug,isOKToLog, etc.
// and is passed in externally.
//
// The TransactionContext has:
// MTPipelineLib::IMTSQLRowsetPtr getRowset()
// and is passed in externally.

template <class _GlobalRuntimeEnvironment>
class MTSQLExecutable_T
{
public:
  typedef TestRuntimeEnvironment_T<typename _GlobalRuntimeEnvironment::activation_record> environment;
private:
  environment * mRuntimeEnv;
  MTSQLRegisterMachine_T<environment> * mRegisterMachine;

public:
	MTSQLExecutable_T(const wchar_t * str, MTSQLInterpreter* analyzer) 
    :
    mRuntimeEnv(NULL),
    mRegisterMachine(NULL)
  {
    std::size_t numRegisters;
    std::vector<MTSQLInstruction *> code;
    analyzer->code_generate(str, code, numRegisters);
    mRegisterMachine = new MTSQLRegisterMachine_T<TestRuntimeEnvironment_T<typename _GlobalRuntimeEnvironment::activation_record> >(numRegisters, 
                                                             code);
    while(code.size() > 0)
    {
      MTSQLInstruction* param =  code.back();
      delete param;
      code.pop_back();
    }

    mRuntimeEnv = new TestRuntimeEnvironment_T<typename _GlobalRuntimeEnvironment::activation_record>(NULL);
    for (std::vector<int>::size_type i=0; i<analyzer->getLibraries().size(); i++)
      mRuntimeEnv->loadLibrary(analyzer->getLibraries()[i]);
  }

	~MTSQLExecutable_T()
  {
    delete mRegisterMachine;
    delete mRuntimeEnv;
  }
  void execCompiled(_GlobalRuntimeEnvironment * env, TransactionContext * txn, Logger * log)
  {
    mRuntimeEnv->setGlobalEnvironment(env->getActivationRecord());
    mRegisterMachine->SetTransactionContext(txn);
    mRegisterMachine->Execute(mRuntimeEnv, log);
  }
  const RuntimeValue * getReturnValue() const
  {
    // Only handles register machine implementation right now.
    return mRegisterMachine->GetReturnValue();
  }
};


#endif

