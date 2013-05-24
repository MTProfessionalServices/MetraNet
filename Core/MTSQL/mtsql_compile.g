header {
#include "Environment.h"
#include "MTSQLAST.h"
#include "MTDec.h"
#include "MTSQLSelectCommand.h"
#include "RegisterMachine.h"
#include "antlr/SemanticException.hpp"
#include <iostream>
}
options {
  language="Cpp";
}
class MTSQLTreeCompile extends TreeParser;
options {
  importVocab=MTSQLTreeParser;
}
{
  std::list<std::list<MTSQLInstruction*> *> mContinue;
  std::list<std::list<MTSQLInstruction*> *> mBreak;

  // Note that this isn't really safe if we introduce nested scopes (which don't exist today).
  private: std::map<std::string, MTSQLRegister> mLocals;
  private: void allocateRegister(const std::string& name)
  {
    mLocals[name] = allocateRegister();
  }
  private: MTSQLRegister getRegister(const std::string& name) const
  {
    return mLocals.find(name)->second;
  }
  private: std::vector<MTSQLInstruction *> mProg;
  public: std::vector<MTSQLInstruction *> getProgram() 
  { 
    return mProg; 
  }
  private: MTSQLRegister mNextRegister;
  private: MTSQLRegister allocateRegister()
  {
	return mNextRegister++;
  }
  public: int getNumRegisters() const
  {
    return mNextRegister;
  }
  private: bool isRegister(LexicalAddressPtr addr) const
  {
    return addr->getOffset() == 0;
  }
  private: MTSQLProgramLabel getNextLabel() const
  {
    return mProg.size() - 1;
  }

private:
  Logger* mLog;
  std::string mSourceCode;   // Code being compiled.  Used for error reporting
  TransactionContext* mTrans;

  std::string getFullText(RefMTSQLAST q)
  {
		std::string str = q->getText();
		str = str + (q->getHiddenAfter()==ANTLR_USE_NAMESPACE(antlr)nullToken ? "" : q->getHiddenAfter()->getText());
		return str;
  }
public:
  
	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
	mLog->logError(ex.toString());
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logError(s);
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }

  void setLog(Logger * log)
  {
	mLog = log;
  }

  /** 
   * Set the source code. 
   * In Compiler.cpp we set the source code in code_generate().
   * The source code is used here for error reporting only.
   */
  void setSourceCode(const char* sourceCode)
  {
    mSourceCode = sourceCode;
  }

  void initialize()
  {
    // Register 0 is reserved for return value if any.
    mNextRegister = 1;
  }
  
   //BP: Just to get around inheritance issues.
  //This method
  private: vector<MTSQLParam> mParams;
  public: virtual vector<MTSQLParam> getParams() 
	{
		return mParams;
	}
}

program
	:
	(typeDeclaration)* 
        (returnsDeclaration)?
	#(SCOPE 
	  sl:statementList 
	)
        ;

returnsDeclaration
        :
	#(TK_RETURNS BUILTIN_TYPE)
        ;

statementList
	: (statement)*
	;

statement
{
}
	:
	setStatement 
	|
	localVariableDeclaration
	|
    stringPrintStatement
	|
    wstringPrintStatement
    |
	seq
    |
	ifStatement
    |
	listOfStatements
    |
	returnStatement
    |
	queryStatement
	| 
    breakStatement
	| 
    continueStatement
	| 
    whileStatement
  |
    raiserrorStringStatement
  |
    raiserrorWStringStatement
  |
    raiserrorIntegerStatement
  |
    raiserror2StringStatement
  |
    raiserror2WStringStatement
	;

typeDeclaration
	:
	#(TK_DECLARE var:LOCALVAR ty:BUILTIN_TYPE) 
	{ 
          // Allocate a register
          allocateRegister(var->getText());
	}
	;

localVariableDeclaration
	:
	#(TK_DECLARE var:LOCALVAR ty:BUILTIN_TYPE) 
	{ 
          // Allocate a register and set NULL value if local.
          allocateRegister(var->getText());
          MTSQLRegister reg = getRegister(var->getText());
          RuntimeValue nil;
	  mProg.push_back(MTSQLInstruction::CreateLoadNullImmediate(reg, nil));          
	}
	;


setStatement 
{
  LexicalAddressPtr addr;
}
	:
	#(INTEGER_SETMEM addr=iva:varAddress iex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#iva)->getText());
              expression(iex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(iex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalIntegerSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(BIGINT_SETMEM addr=biva:varAddress biex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#biva)->getText());
              expression(biex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(biex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalBigIntSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(DOUBLE_SETMEM addr=dva:varAddress dex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#dva)->getText());
              expression(dex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(dex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalDoubleSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(DECIMAL_SETMEM addr=decva:varAddress decex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#decva)->getText());
              expression(decex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(decex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalDecimalSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(BOOLEAN_SETMEM addr=bva:varAddress bex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#bva)->getText());
              expression(bex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(bex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalBooleanSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(STRING_SETMEM addr=sva:varAddress sex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#sva)->getText());
              expression(sex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(sex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalStringSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(WSTRING_SETMEM addr=wva:varAddress wex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#wva)->getText());
              expression(wex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(wex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalWideStringSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(DATETIME_SETMEM addr=dtva:varAddress dtex:EXPR)
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#dtva)->getText());
              expression(dtex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(dtex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalDatetimeSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(TIME_SETMEM addr=tva:varAddress tex:EXPR) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#tva)->getText());
              expression(tex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(tex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalTimeSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(ENUM_SETMEM addr=eva:varAddress eex:EXPR)
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#eva)->getText());
              expression(eex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(eex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalEnumSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(BINARY_SETMEM addr=bina:varAddress binex:EXPR)
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#bina)->getText());
              expression(binex, e);
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              expression(binex, e);
              mProg.push_back(MTSQLInstruction::CreateGlobalBinarySetmem(addr->getFrameAccess(), e));
            }
	} 
	;

varAddress returns [LexicalAddressPtr a]
	:
	l:LOCALVAR { a = ((RefMTSQLAST)#l)->getAccess(); }
	;

stringPrintStatement
{
}
	:
	#(STRING_PRINT print:EXPR)
    {
      MTSQLRegister isOkToPrint=allocateRegister();
      MTSQLRegister printExpr=allocateRegister();
      // As an optimization, we only evaluate the argument to the print function if logging is enabled
      mProg.push_back(MTSQLInstruction::CreateIsOkPrint(isOkToPrint)); 
      // Use dummy label -1 for now, we find the branch location after the expression code is generated
      MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(isOkToPrint, -1);
      mProg.push_back(inst1);
      expression(#print, printExpr);
      mProg.push_back(MTSQLInstruction::CreateStringPrint(printExpr));
      inst1->SetLabel(getNextLabel());
    }
	;

wstringPrintStatement
{
}
	:
	#(WSTRING_PRINT print:EXPR)
    {
      MTSQLRegister isOkToPrint=allocateRegister();
      MTSQLRegister printExpr=allocateRegister();
      // As an optimization, we only evaluate the argument to the print function if logging is enabled
      mProg.push_back(MTSQLInstruction::CreateIsOkPrint(isOkToPrint)); 
      // Use dummy label -1 for now, we find the branch location after the expression code is generated
      MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(isOkToPrint, -1);
      mProg.push_back(inst1);
      expression(#print, printExpr);
      mProg.push_back(MTSQLInstruction::CreateWStringPrint(printExpr));
      inst1->SetLabel(getNextLabel());
    }
	;

seq
	:
	#(SEQUENCE statement statement)
	;


queryStatement
{
  std::wstring s;
}
    :
    #(q:QUERY p:ARRAY out:TK_INTO)
	{
    mProg.push_back(MTSQLInstruction::CreateQueryAlloc(((RefMTSQLAST)q)->getValue()));
    localParamList(#p);
    MTSQLInstruction * inst = MTSQLInstruction::CreateQueryExecute(-1);
    mProg.push_back(inst);
    setmemQuery(#out);
    inst->SetLabel(getNextLabel());
    mProg.push_back(MTSQLInstruction::CreateQueryFree());
	}
	;

setmemQuery
{
  int i=0;
  LexicalAddressPtr addr;
}
    :
    #(TK_INTO  ( 
	#(INTEGER_SETMEM_QUERY addr=iva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#iva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryIntegerBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryIntegerBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalIntegerSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(BIGINT_SETMEM_QUERY addr=biva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#biva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryBigIntBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryBigIntBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalBigIntSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(DOUBLE_SETMEM_QUERY addr=dva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#dva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryDoubleBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryDoubleBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalDoubleSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(DECIMAL_SETMEM_QUERY addr=decva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#decva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryDecimalBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryDecimalBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalDecimalSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(BOOLEAN_SETMEM_QUERY addr=bva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#bva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryBooleanBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryBooleanBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalBooleanSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(STRING_SETMEM_QUERY addr=sva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#sva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryStringBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryStringBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalStringSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(WSTRING_SETMEM_QUERY addr=wva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#wva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryWideStringBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryWideStringBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalWideStringSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(DATETIME_SETMEM_QUERY addr=dtva:varAddress)
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#dtva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryDatetimeBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryDatetimeBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalDatetimeSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(TIME_SETMEM_QUERY addr=tva:varAddress) 
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#tva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryTimeBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryTimeBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalTimeSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(ENUM_SETMEM_QUERY addr=eva:varAddress)
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#eva)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryEnumBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryEnumBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalEnumSetmem(addr->getFrameAccess(), e));
            }
	} 
	| #(BINARY_SETMEM_QUERY addr=bina:varAddress)
	{ 
	    // Classify whether we are assigning to a register variable or not
	    if (isRegister(addr))
            {
              MTSQLRegister e = getRegister(((RefMTSQLAST)#bina)->getText());
              mProg.push_back(MTSQLInstruction::CreateQueryBinaryBindColumn(RuntimeValue::createLong(i++), e));
            }
            else
            {
              // Here we must move from a register into the global environment (e.g. session server,...)
              MTSQLRegister e = allocateRegister();
              mProg.push_back(MTSQLInstruction::CreateQueryBinaryBindColumn(RuntimeValue::createLong(i++), e));
              mProg.push_back(MTSQLInstruction::CreateGlobalBinarySetmem(addr->getFrameAccess(), e));
            }
	} 
	  )*
	)
    ;

localParamList 
{
int i = 0;
}
    :
    #(ARRAY ( 
              {
                MTSQLRegister e = allocateRegister();
              }
              primaryExpression[e] 
              { 
                mProg.push_back(MTSQLInstruction::CreateQueryBindParam(RuntimeValue::createLong(i++), e)); 
              }
            )*)
    ;

ifStatement
{
  bool hasElse = false;
  MTSQLRegister ex=allocateRegister();
}
    :
	#(IFTHENELSE expression[ex] ifstmt:DELAYED_STMT (elsestmt:DELAYED_STMT { hasElse = true; })? )
		{
                        MTSQLInstruction * inst = MTSQLInstruction::CreateBranchOnCondition(ex, 1);
                        mProg.push_back(inst);
                        // Don't know the branch label yet.  After generating code for if block we'll know,
                        // so update then.
			delayedStatement(#ifstmt);
			if(true == hasElse) 
                        {
                          // if there is an else block, then we need to have the if block skip to after
                          // the else block
                          MTSQLInstruction * inst2 = MTSQLInstruction::CreateGoto(-1);
                          mProg.push_back(inst2);
                          inst->SetLabel(getNextLabel());
                          delayedStatement(#elsestmt);
                          inst2->SetLabel(getNextLabel());
                        }
                        else
                        {
                          inst->SetLabel(getNextLabel());
                        }
		}
    ;

delayedStatement
	:
	#(DELAYED_STMT statement)
	;

listOfStatements
	:
	#(SLIST (statement)*)
	;

// For a return statement put the optional return value in register 0
returnStatement
	:
	#(TK_RETURN (expression[0])?
        {
          MTSQLInstruction * inst = MTSQLInstruction::CreateReturn();
          mProg.push_back(inst);
        }
  )
	;

breakStatement
	:
	TK_BREAK
        {
          MTSQLInstruction * inst = MTSQLInstruction::CreateGoto(-1);
          mProg.push_back(inst);
          mBreak.back()->push_back(inst);
        } 
    ;

continueStatement
	:
	TK_CONTINUE
        {
          MTSQLInstruction * inst = MTSQLInstruction::CreateGoto(-1);
          mProg.push_back(inst);
          mContinue.back()->push_back(inst);
        } 
    ;

whileStatement
	:
	#(WHILE e:EXPR s:DELAYED_STMT) 
	{ 
          // Create a program label for the test expression.
          // Don't know where to branch after loop is done until
          // after the block is generated
          mContinue.push_back(new std::list<MTSQLInstruction *>());
          mBreak.push_back(new std::list<MTSQLInstruction *>());
          MTSQLProgramLabel label = getNextLabel();
          MTSQLRegister reg = allocateRegister();
          expression(#e, reg);
          MTSQLInstruction * inst = MTSQLInstruction::CreateBranchOnCondition(reg, -1);
          mProg.push_back(inst);
          delayedStatement(#s);
          mProg.push_back(MTSQLInstruction::CreateGoto(label));
          MTSQLProgramLabel label2 = getNextLabel();
          inst->SetLabel(label2);

          for(std::list<MTSQLInstruction *>::iterator it = mContinue.back()->begin(); it != mContinue.back()->end(); it++)
          {
            (*it)->SetLabel(label);
          }
          std::list<MTSQLInstruction *> * l = mContinue.back();
          mContinue.pop_back();
          delete l;

          for(std::list<MTSQLInstruction *>::iterator it = mBreak.back()->begin(); it != mBreak.back()->end(); it++)
          {
            (*it)->SetLabel(label2);
          }
          l = mBreak.back();
          mBreak.pop_back();
          delete l;
	}
    ;

raiserrorIntegerStatement
{
  MTSQLRegister i;
  i = allocateRegister();
}
	:
	#(RAISERRORINTEGER expression[i]) 
	{ 
            mProg.push_back(MTSQLInstruction::CreateRaiseErrorInteger(i));   
	}
    ;

raiserrorStringStatement
{
  MTSQLRegister s;
  s = allocateRegister();
}
	:
	#(RAISERRORSTRING expression[s]) 
        {
            mProg.push_back(MTSQLInstruction::CreateRaiseErrorString(s));   
      	}
    ;

raiserrorWStringStatement
{
  MTSQLRegister s;
  s = allocateRegister();
}
	:
	#(RAISERRORWSTRING expression[s]) 
        {
            mProg.push_back(MTSQLInstruction::CreateRaiseErrorWString(s));   
      	}
    ;

raiserror2StringStatement
{
  MTSQLRegister i,s;
  s = allocateRegister();
  i = allocateRegister();
}
	:
	#(RAISERROR2STRING expression[i] expression[s]) 
	{ 
            mProg.push_back(MTSQLInstruction::CreateRaiseErrorStringInteger(i, s));   
	}
    ;

raiserror2WStringStatement
{
  MTSQLRegister i,s;
  s = allocateRegister();
  i = allocateRegister();
}
	:
	#(RAISERROR2WSTRING expression[i] expression[s]) 
	{ 
            mProg.push_back(MTSQLInstruction::CreateRaiseErrorWStringInteger(i, s));   
	}
    ;

elist returns [std::vector<MTSQLRegister> r]
{
  MTSQLRegister reg;
}
	:
	#(ELIST (expression[reg=allocateRegister()] { r.push_back(reg); } (COMMA expression[reg=allocateRegister()] { r.push_back(reg); })*)?)
	;

expression[MTSQLRegister result] 
{
}
	:
	#(EXPR expr[result]) 
	;

expr[MTSQLRegister result]
{
  MTSQLRegister lhs, rhs, e;
  lhs = allocateRegister();
  rhs = allocateRegister();
  e = allocateRegister();
}
	:
	// Bitwise
	#(BAND expr[lhs] expr[rhs]) 
		{
            mProg.push_back(MTSQLInstruction::CreateBitwiseAndInteger(lhs, rhs, result));   
		}
	| #(BNOT expr[lhs]) 
		{
            mProg.push_back(MTSQLInstruction::CreateBitwiseNotInteger(lhs, result));   
		}
	| #(BOR expr[lhs] expr[rhs]) 
		{
            mProg.push_back(MTSQLInstruction::CreateBitwiseOrInteger(lhs, rhs, result));   
		}
	| #(BXOR expr[lhs] expr[rhs]) 
		{
            mProg.push_back(MTSQLInstruction::CreateBitwiseXorInteger(lhs, rhs, result));   
    }
	// Logical
	| #(LAND expr[lhs] andrhs:EXPR) 
	{
          // Check the lhs first, if false then don't execute the rhs  
          MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(lhs, -1);
          mProg.push_back(inst1);
          expression(#andrhs, result);
          MTSQLInstruction * gotoInst = MTSQLInstruction::CreateGoto(-1);
          mProg.push_back(gotoInst);
          inst1->SetLabel(getNextLabel());
          mProg.push_back(MTSQLInstruction::CreateMove(lhs, result));
          gotoInst->SetLabel(getNextLabel());
	}
	| #(LOR expr[lhs] orrhs:EXPR) 
		{
          // Check the lhs first, if true then don't execute the rhs  
          MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(lhs, -1);
          mProg.push_back(inst1);
          mProg.push_back(MTSQLInstruction::CreateMove(lhs, result));
          MTSQLInstruction * gotoInst = MTSQLInstruction::CreateGoto(-1);
          mProg.push_back(gotoInst);
          inst1->SetLabel(getNextLabel());
          expression(#orrhs, result);
          gotoInst->SetLabel(getNextLabel());
		}
	| #(LNOT expr[lhs]) 
		{
          mProg.push_back(MTSQLInstruction::CreateLNot(lhs, result));
		}
	// Comparison
	| #(EQUALS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateEquals(lhs, rhs, result));   
          }
	| #(GT expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateGreaterThan(lhs, rhs, result));   
          }
	| #(GTEQ expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateGreaterThanEquals(lhs, rhs, result));   
          }
	| #(LTN expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateLessThan(lhs, rhs, result));   
          }
	| #(LTEQ expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateLessThanEquals(lhs, rhs, result));   
          }
	| #(NOTEQUALS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateNotEquals(lhs, rhs, result));   
          }
  // null checking
	| #(ISNULL expr[lhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateIsNull(lhs, result));   
          }
	// String operators
	| #(STRING_PLUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateStringPlus(lhs, rhs, result));   
          }
	| #(WSTRING_PLUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateWideStringPlus(lhs, rhs, result));   
          }
        | #(STRING_LIKE expr[lhs] expr[rhs]) 
           {
						mProg.push_back(MTSQLInstruction::CreateStringLike(lhs, rhs, result));
           }
        | #(WSTRING_LIKE expr[lhs] expr[rhs]) 
           {
						mProg.push_back(MTSQLInstruction::CreateWideStringLike(lhs, rhs, result));
           }
	// Arithmetic
	| #(INTEGER_MINUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateIntegerMinus(lhs, rhs, result));   
          }
	| #(INTEGER_DIVIDE expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateIntegerDivide(lhs, rhs, result));   
          }
	| #(INTEGER_PLUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateIntegerPlus(lhs, rhs, result));   
          }
	| #(INTEGER_TIMES expr[lhs] expr[rhs])  
          {
            mProg.push_back(MTSQLInstruction::CreateIntegerTimes(lhs, rhs, result));   
          }
	| #(INTEGER_UNARY_MINUS expr[lhs])  
          {
            mProg.push_back(MTSQLInstruction::CreateIntegerUnaryMinus(lhs, result));   
          }
	| #(BIGINT_MINUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateBigIntMinus(lhs, rhs, result));   
          }
	| #(BIGINT_DIVIDE expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateBigIntDivide(lhs, rhs, result));   
          }
	| #(BIGINT_PLUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateBigIntPlus(lhs, rhs, result));   
          }
	| #(BIGINT_TIMES expr[lhs] expr[rhs])  
          {
            mProg.push_back(MTSQLInstruction::CreateBigIntTimes(lhs, rhs, result));   
          }
	| #(BIGINT_UNARY_MINUS expr[lhs])  
          {
            mProg.push_back(MTSQLInstruction::CreateBigIntUnaryMinus(lhs, result));   
          }
	| #(DOUBLE_MINUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateDoubleMinus(lhs, rhs, result));   
          }
	| #(DOUBLE_DIVIDE expr[lhs] expr[rhs])
          {
            mProg.push_back(MTSQLInstruction::CreateDoubleDivide(lhs, rhs, result));   
          }
	| #(DOUBLE_PLUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateDoublePlus(lhs, rhs, result));   
          }
	| #(DOUBLE_TIMES expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateDoubleTimes(lhs, rhs, result));   
          }
	| #(DOUBLE_UNARY_MINUS expr[lhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateDoubleUnaryMinus(lhs, result));   
          }
	| #(DECIMAL_MINUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateDecimalMinus(lhs, rhs, result));   
          }
	| #(DECIMAL_DIVIDE expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateDecimalDivide(lhs, rhs, result));   
          }
	| #(DECIMAL_PLUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateDecimalPlus(lhs, rhs, result));   
          }
	| #(DECIMAL_TIMES expr[lhs] expr[rhs])  
          {
            mProg.push_back(MTSQLInstruction::CreateDecimalTimes(lhs, rhs, result));   
          }
	| #(DECIMAL_UNARY_MINUS expr[lhs])  
          {
            mProg.push_back(MTSQLInstruction::CreateDecimalUnaryMinus(lhs, result));   
          }
	| #(INTEGER_MODULUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateIntegerModulus(lhs, rhs, result));   
          }
	| #(BIGINT_MODULUS expr[lhs] expr[rhs]) 
          {
            mProg.push_back(MTSQLInstruction::CreateBigIntModulus(lhs, rhs, result));   
          }
	// Expression
	| #(IFBLOCK (
              {
                std::vector<MTSQLInstruction*> gotos;
                bool hasElse = false;
              }
              (ifThenElse[gotos, hasElse, result])+ 
              {
                if (false == hasElse)
                {
                  std::string errMsg = 
                    "While executing an MTSQL statement, encountered a "
                    "'case' statement that could not be evaluated.  None of "
                    "'when' branches matched the value being processed.  "
                    "Consider adding an 'else' statement which "
                    "would be executed when there "
                    "are no matching 'when' branches.  This is the code "
                    "causing the error: ";
                  errMsg += mSourceCode;
								  mProg.push_back(MTSQLInstruction::CreateThrow(
                    RuntimeValue::createString(errMsg.c_str())));
                }
                // Fix up all gotos to branch after the case statement.
                for(std::size_t i = 0; i<gotos.size(); i++)
                {
                  gotos[i]->SetLabel(getNextLabel());
                }
              }
              )
    )
	| #(ESEQ statement expr[result])
    | #(CAST_TO_INTEGER expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToInteger(lhs, result));
      }
    | #(CAST_TO_BIGINT expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToBigInt(lhs, result));
      }
    | #(CAST_TO_DOUBLE expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToDouble(lhs, result));
      }
    | #(CAST_TO_DECIMAL expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToDecimal(lhs, result));
      }
    | #(CAST_TO_STRING expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToString(lhs, result));
      }
    | #(CAST_TO_WSTRING expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToWideString(lhs, result));
      }
    | #(CAST_TO_BOOLEAN expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToBoolean(lhs, result));
      }
    | #(CAST_TO_DATETIME expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToDatetime(lhs, result));
      }
    | #(CAST_TO_TIME expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToTime(lhs, result));
      }
    | #(CAST_TO_ENUM expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToEnum(lhs, result));
      }
    | #(CAST_TO_BINARY expression[lhs]) 
      { 
        mProg.push_back(MTSQLInstruction::CreateCastToBinary(lhs, result));
      }
	| primaryExpression[result]
	;

ifThenElse [std::vector<MTSQLInstruction *>& gotos, bool& hasElse, MTSQLRegister result]
{
  MTSQLRegister cond;
  cond = allocateRegister();
}
	: #(IFEXPR expr[cond] action:EXPR) 
    {
      // Check the value in condition and branch to as yet undetermined label after action.
      // If match, then evaluate action and branch to end of case statement (not yet determined).
      // Fix up branch of false to after action.
      MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(cond, -1);
      mProg.push_back(inst1);
      expression(#action, result);
      MTSQLInstruction * gotoInst = MTSQLInstruction::CreateGoto(-1);
      mProg.push_back(gotoInst);
      gotos.push_back(gotoInst);
      inst1->SetLabel(getNextLabel());
    }
	| expression [result] { hasElse = true; }
	;


primaryExpression[MTSQLRegister reg]
{
  std::vector<MTSQLRegister> r;
}
	:
	i:NUM_INT 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadIntegerImmediate(reg, ((RefMTSQLAST)i)->getValue()));
		}
	| bi:NUM_BIGINT 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadBigIntImmediate(reg, ((RefMTSQLAST)bi)->getValue()));
		}
	| d:NUM_FLOAT 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadDoubleImmediate(reg, ((RefMTSQLAST)d)->getValue()));
		}
	| dec:NUM_DECIMAL 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadDecimalImmediate(reg, ((RefMTSQLAST)dec)->getValue()));
		}
	| s:STRING_LITERAL 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadStringImmediate(reg, ((RefMTSQLAST)s)->getValue()));
		}
	| ws:WSTRING_LITERAL 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadWideStringImmediate(reg, ((RefMTSQLAST)ws)->getValue()));
		}
	| e:ENUM_LITERAL 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadEnumImmediate(reg, ((RefMTSQLAST)e)->getValue()));
		}
	| t:TK_TRUE 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadBooleanImmediate(reg, ((RefMTSQLAST)t)->getValue()));
		}
	| f:TK_FALSE 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadBooleanImmediate(reg, ((RefMTSQLAST)f)->getValue()));
		}
	| nil:TK_NULL 
		{ 
			mProg.push_back(MTSQLInstruction::CreateLoadNullImmediate(reg, ((RefMTSQLAST)nil)->getValue()));
		}
	| #(mc:METHOD_CALL id:ID r = elist RPAREN) 
          { 
            const char * text = ((RefMTSQLAST)mc)->getValue().getStringPtr();
           	mProg.push_back(MTSQLInstruction::ExecutePrimitiveFunction(text, r, reg));
          }
	| igm:INTEGER_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)igm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)igm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalIntegerGetmem(((RefMTSQLAST)igm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| bigm:BIGINT_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)bigm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)bigm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalBigIntGetmem(((RefMTSQLAST)bigm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| dgm:DOUBLE_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)dgm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)dgm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalDoubleGetmem(((RefMTSQLAST)dgm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| decgm:DECIMAL_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)decgm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)decgm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalDecimalGetmem(((RefMTSQLAST)decgm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| bgm:BOOLEAN_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)bgm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)bgm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalBooleanGetmem(((RefMTSQLAST)bgm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| sgm:STRING_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)sgm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)sgm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalStringGetmem(((RefMTSQLAST)sgm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| wsgm:WSTRING_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)wsgm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)wsgm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalWideStringGetmem(((RefMTSQLAST)wsgm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| dtgm:DATETIME_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)dtgm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)dtgm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalDatetimeGetmem(((RefMTSQLAST)dtgm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| tm:TIME_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)tm)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)tm)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalTimeGetmem(((RefMTSQLAST)tm)->getAccess()->getFrameAccess(), reg));
            }
          }
	| en:ENUM_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)en)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)en)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalEnumGetmem(((RefMTSQLAST)en)->getAccess()->getFrameAccess(), reg));
            }
          }
	| bin:BINARY_GETMEM 
          {
            if(isRegister(((RefMTSQLAST)bin)->getAccess()))
            {
              mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)bin)->getText()), reg));
            }
            else
            {
              mProg.push_back(MTSQLInstruction::CreateGlobalBinaryGetmem(((RefMTSQLAST)bin)->getAccess()->getFrameAccess(), reg));
            }
          }
    | expression[reg]
	;
