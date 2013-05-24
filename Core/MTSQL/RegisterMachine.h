
#ifndef __REGISTER_MACHINE_H__
#define __REGISTER_MACHINE_H__

#include "MTSQLInterpreter_T.h"

class MTSQLRegisterMachine : public MTSQLRegisterMachine_T<RuntimeEnvironment>
{
public:
  MTSQLRegisterMachine(int numRegisters, const std::vector<MTSQLInstruction *>& prog)
    :
    MTSQLRegisterMachine_T<RuntimeEnvironment>(numRegisters, prog)
  {
  }

  ~MTSQLRegisterMachine()
  {
  }
};

// class MTSQLRegisterMachine
// {
// private:
//   RuntimeValue * mRegisters;
//   int mNumRegisters;
//   // These 3 pointers store the instructions.
//   unsigned char * mStart;
//   unsigned char * mPosition;
//   unsigned char * mEnd;
//   const RuntimeValue ** mFunctionArg;
//   int mFunctionArgCapacity;
//   TransactionContext * mTrans;
//   NameIDProxy mNameID;

//   // Builders for the instructions.
//   void reserve(std::size_t sz);
//   void push_back(std::size_t regOrLabel);
//   void push_back(const string & );
//   void push_back(const wstring &);
//   void push_back(MTSQLInstruction::Type ty);
//   void Convert(const std::vector<MTSQLInstruction *>& prog);

// public:
// //   MTSQLRegisterMachine(int numRegisters=10000);
//   MTSQLRegisterMachine(int numRegisters, const std::vector<MTSQLInstruction *>& prog);

//   ~MTSQLRegisterMachine();
//   void SetTransactionContext(TransactionContext * trans)
//   {
//     mTrans = trans;
//   }
//   void Execute(const std::vector<MTSQLInstruction *>& prog, RuntimeEnvironment * env, Logger * log);
//   void Execute(RuntimeEnvironment * env, Logger * log);
//   const RuntimeValue * GetReturnValue() const
//   {
//     return &mRegisters[0];
//   }
// };

#endif 
