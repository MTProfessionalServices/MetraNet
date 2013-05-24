#ifndef _MTSQLINTERPRETER_H_
#define _MTSQLINTERPRETER_H_

class MTSQLLexer;
class MTSQLParser;
class MTSQLTreeParser;
class MTSQLOracleTreeParser;
class MTSQLRefactorLexer;
class RewriteTreeParser;
class RewriteOracleTreeParser;
class GenerateQueryTreeParser;
class GenerateOracleQueryTreeParser;
class MTSQLTreeExecution;
class Access;
class Frame;
class ActivationRecord;
class MTSQLInterpreter;
class MTSQLExecutable;
class Environment;
class BatchQuery;
class MTSQLInstruction;
class TestRuntimeEnvironment;
class MTSQLRegisterMachine;
class RuntimeValue;
class AbstractSyntaxTree;

#include "MTSQLConfig.h"

#include <string>
#include <vector>
#include <map>
#include <boost/shared_ptr.hpp>

#ifndef WIN32
#include <unicode/utypes.h>
#endif

#ifdef WIN32
#include <comutil.h>
#endif

#include "MTSQLParam.h"

namespace antlr
{
  class Parser;
  class TreeParser;
  class TokenStreamHiddenTokenFilter;
};

#ifdef WIN32
// import the pipeline tlb.  Only used for MTSQLSelectCommand stuff
#import <MTPipelineLib.tlb> rename( "EOF", "RowsetEOF" )
#else
namespace MTPipelineLib
{
  typedef long IMTSQLRowsetPtr;
};
#endif

class PrimitiveFunctionLibrary;

// An address of a variable in a stack frame/activation record
class Access
{
public:
  virtual ~Access() {}
};

typedef boost::shared_ptr<Access> AccessPtr;
MTSQL_DECL extern AccessPtr nullAccess;

// The runtime aspect of a stack frame/activation record
class ActivationRecord
{
public:
  typedef Access access;
  virtual void getLongValue(const Access * access, RuntimeValue * value)=0;
  virtual void getLongLongValue(const Access * access, RuntimeValue * value)=0;
  virtual void getDoubleValue(const Access * access, RuntimeValue * value)=0;
  virtual void getDecimalValue(const Access * access, RuntimeValue * value)=0;
  virtual void getStringValue(const Access * access, RuntimeValue * value)=0;
  virtual void getWStringValue(const Access * access, RuntimeValue * value)=0;
  virtual void getBooleanValue(const Access * access, RuntimeValue * value)=0;
  virtual void getDatetimeValue(const Access * access, RuntimeValue * value)=0;
  virtual void getTimeValue(const Access * access, RuntimeValue * value)=0;
  virtual void getEnumValue(const Access * access, RuntimeValue * value)=0;
  virtual void getBinaryValue(const Access * access, RuntimeValue * value)=0;
  virtual void setLongValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setLongLongValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setDoubleValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setDecimalValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setStringValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setWStringValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setBooleanValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setDatetimeValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setTimeValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setEnumValue(const Access * access, const RuntimeValue * value)=0;
  virtual void setBinaryValue(const Access * access, const RuntimeValue * value)=0;

  virtual ActivationRecord* getStaticLink()=0;

  virtual ~ActivationRecord() {}
};

// The compile time side of an activation record.  A frame creates
// an address for a variable that can be used at runtime to access
// variables in an activation record during runtime.
class Frame
{
public:
  virtual AccessPtr allocateVariable(const std::string& var, int ty) =0;
  virtual ~Frame() {}
};

class Logger
{
public:
  virtual void logError(const std::string&) =0;
  virtual void logWarning(const std::string&) =0;
  virtual void logInfo(const std::string& str)=0;
  virtual void logDebug(const std::string& str)=0;
  virtual bool isOkToLogError()=0;
  virtual bool isOkToLogWarning()=0;
  virtual bool isOkToLogInfo()=0;
  virtual bool isOkToLogDebug()=0;
  virtual ~Logger() {}
};

class TransactionContext
{
public:
  virtual MTPipelineLib::IMTSQLRowsetPtr getRowset()=0;
  virtual ~TransactionContext() {}
  
};

// Creates a frame that describes the global environment
// in which the interpreter will execute the program.
// At compile time, the global environment exposes a method for
// generating "runtime addresses" of variables.  At runtime,
// the global environment provides a mechanism for getting/setting
// values at "runtime addresses" created during compilation.
class GlobalCompileEnvironment : public Logger
{
public:
  virtual Frame* createFrame()=0;
  virtual void logDebug(const std::string& str)=0;
  virtual void logInfo(const std::string& str)=0;
  virtual void logWarning(const std::string& str)=0;
  virtual void logError(const std::string& str)=0;
  virtual bool isOkToLogError()=0;
  virtual bool isOkToLogWarning()=0;
  virtual bool isOkToLogInfo()=0;
  virtual bool isOkToLogDebug()=0;
};

class GlobalRuntimeEnvironment : public Logger, public TransactionContext
{
public:
  virtual ActivationRecord* getActivationRecord()=0;
  virtual MTPipelineLib::IMTSQLRowsetPtr getRowset()=0;
  virtual void logDebug(const std::string& str)=0;
  virtual void logInfo(const std::string& str)=0;
  virtual void logWarning(const std::string& str)=0;
  virtual void logError(const std::string& str)=0;
  virtual bool isOkToLogError()=0;
  virtual bool isOkToLogWarning()=0;
  virtual bool isOkToLogInfo()=0;
  virtual bool isOkToLogDebug()=0;
};

class MTSQLInterpreterBase
{
public:
  virtual ~MTSQLInterpreterBase() {}
  virtual bool getSupportVarchar()=0;
  virtual void setSupportVarchar(bool supportVarchar) =0;
#ifndef WIN32
  virtual MTSQLExecutable *analyze(const UChar* str, class MTSQLInterpreter * i) =0;
  virtual void code_generate(const UChar* str, 
                             std::vector<MTSQLInstruction *>& code, 
                             std::size_t& numRegisters, 
                             class MTSQLInterpreter * i) =0;
#endif
  virtual MTSQLExecutable *analyze(const wchar_t* str, class MTSQLInterpreter * i) =0;
  virtual void code_generate(const wchar_t* str, 
                             std::vector<MTSQLInstruction *>& code, 
                             std::size_t& numRegisters, 
                             class MTSQLInterpreter * i) =0;
  virtual int getReturnType() =0;

  /**
   * Produces a new script by renaming the given variable.
   * Throws an exception if the MTSQL cannot be parsed.
   */
  virtual string refactorRenameVariable(const std::string& script,
                                        const std::string& oldVariableName,
                                        const std::string& newVariableName) = 0;
  /**
   * Produces a new script by converting string literals 
   * to wide string literals ("xyz" -> N"xyz") and 
   * VARCHAR declarations to NVARCHAR.  
   * Throws an exception if the MTSQL cannot be parsed.
   */
  virtual string refactorVarchar(const std::string& script) = 0;

  virtual void setTempTable (const std::string& table, const std::string& tag) =0;
#ifdef WIN32
  virtual BatchQuery* analyzeQuery() =0;
#endif

  virtual const std::vector<PrimitiveFunctionLibrary *>& getLibraries() =0;
  virtual const std::vector<MTSQLParam>& getProgramParams() =0;
  virtual boost::shared_ptr<AbstractSyntaxTree> getAST() =0;

private:
  /** 
   * Produces a new script by refactoring.  The given lex refactor
   * options should be set prior to calling this.
   */
  virtual string refactor(MTSQLRefactorLexer &lex) = 0;

};

class MTSQLInterpreter
{
private:
  bool mIsOracle;
  MTSQLInterpreterBase * mImpl;

  boost::shared_ptr<AbstractSyntaxTree> getAST()
  {
    return mImpl->getAST();
  }

public:
  // Requires: globalEnvironment is not NULL.
  // Default constructor loads the Standard library
  MTSQL_DECL MTSQLInterpreter(GlobalCompileEnvironment* globalEnvironment);
  // Requires: globalEnvironment is not NULL.
  // Default constructor loads the Standard library and inserts
  // globalVars into the environment.
  MTSQL_DECL MTSQLInterpreter(GlobalCompileEnvironment* globalEnvironment, 
                              const std::map<std::string,int>& globalVars);

  MTSQL_DECL ~MTSQLInterpreter();

  MTSQL_DECL bool getSupportVarchar() { return mImpl->getSupportVarchar(); }
  MTSQL_DECL void setSupportVarchar(bool supportVarchar) { mImpl->setSupportVarchar(supportVarchar); }
#ifndef WIN32
  MTSQL_DECL MTSQLExecutable *analyze(const UChar* str)
  {
    MTSQLExecutable * e = mImpl->analyze(str, this);
    return e;
  }
  MTSQL_DECL void code_generate(const UChar* str, 
                     std::vector<MTSQLInstruction *>& code, 
                     std::size_t& numRegisters)
  {
    mImpl->code_generate(str, code, numRegisters, this);
  }
#endif
  MTSQL_DECL MTSQLExecutable *analyze(const wchar_t* str)
  {
    MTSQLExecutable * e = mImpl->analyze(str, this);
    return e;
  }
  MTSQL_DECL void code_generate(const wchar_t* str, 
                     std::vector<MTSQLInstruction *>& code, 
                     std::size_t& numRegisters)
  {
    mImpl->code_generate(str, code, numRegisters, this);
  }
  MTSQL_DECL int getReturnType()
  {
    return mImpl->getReturnType();
  }

  MTSQL_DECL void setTempTable (const std::string& table, const std::string& tag)
  {
    mImpl->setTempTable(table, tag);
  }

#ifdef WIN32
  MTSQL_DECL BatchQuery* analyzeQuery()
  {
    return mImpl->analyzeQuery();
  }
#endif

  MTSQL_DECL const std::vector<PrimitiveFunctionLibrary *>& getLibraries()
  {
    return mImpl->getLibraries();
  }
  MTSQL_DECL const std::vector<MTSQLParam>& getProgramParams() 
  {
    return mImpl->getProgramParams();
  }

  /**
   * Produces a new script by renaming the given variable.
   * Throws an exception if the MTSQL cannot be parsed.
   */
  virtual string refactorRenameVariable(const std::string& script,
		                        const std::string& oldVariableName,
				        const std::string& newVariableName)
  {
    return mImpl->refactorRenameVariable(script, 
                                         oldVariableName,
                                         newVariableName);
  }

  /**
   * Produce a new script by converting string literals 
   * to wide string literals ("xyz" -> N"xyz") and 
   * VARCHAR declarations to NVARCHAR.  
   * Throws an exception if the MTSQL cannot be parsed.
   */
  virtual string refactorVarchar(const std::string& script)
  {
    return mImpl->refactorVarchar(script);
  }

  friend class MTSQLExecutable;
};

class MTSQLExecutable
{
private:
  MTSQLInterpreter* mSemanticAnalyzer;
  MTSQLTreeExecution* mProgram;
  std::vector<MTSQLInstruction *> mCode;
  TestRuntimeEnvironment * mRuntimeEnv;
  MTSQLRegisterMachine * mRegisterMachine;

public:
  MTSQL_DECL MTSQLExecutable(MTSQLInterpreter* analyzer);
  MTSQL_DECL ~MTSQLExecutable();
  // May be called multiple times after compilation.
  // The caller may modify values in the global environment
  // between calls to exec() so as to change the result of
  // each execution.  It is the responsibility of the caller
  // to setup (or reinitialize) the values in the global environment
  // between calls to exec().
  //
  // Requires: analyze() must be called prior to calling exec().
  //
  MTSQL_DECL void exec(GlobalRuntimeEnvironment* globalEnvironment);

  MTSQL_DECL void codeGenerate(GlobalCompileEnvironment * globalEnvironment); 
  MTSQL_DECL void execCompiled(GlobalRuntimeEnvironment * globalEnvironment);
  MTSQL_DECL int getReturnType() const;
  MTSQL_DECL const RuntimeValue * getReturnValue() const;
};

#endif

