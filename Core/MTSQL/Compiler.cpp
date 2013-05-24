#ifdef WIN32
#pragma warning( disable : 4786 ) 
#endif
#include "ASTFactory.hpp"
#include "MTSQLLexer.hpp"
#include "MTSQLParser.hpp"
#include "MTSQLOracleParser.hpp"
#include "MTSQLTreeParser.hpp"
#include "MTSQLOracleTreeParser.hpp"
#include "MTSQLTreeExecution.hpp"
#include "MTSQLTreeCompile.hpp"
#include "MTSQLRefactorLexer.hpp"
#include "RewriteTreeParser.hpp"
#include "RewriteOracleTreeParser.hpp"
#include "GenerateOracleQueryTreeParser.hpp"
#include "GenerateQueryTreeParser.hpp"
#include "StandardLibrary.h"
#ifdef WIN32
#include "BatchQuery.h"
#endif
#include "MTSQLInterpreter.h"
#include "RegisterMachine.h"
#include "MTSQLUnitTest.h"
#include <sstream>



#include "AST.hpp"
#include "CommonAST.hpp"
#include "TokenStreamHiddenTokenFilter.hpp"
#include "CommonHiddenStreamToken.hpp"
#include "Token.hpp"

ANTLR_USING_NAMESPACE(antlr)

#include <iostream>
#include <sstream>
#include <string>

  ANTLR_USING_NAMESPACE(std)

  AccessPtr nullAccess;

class OracleInterpreter
{
public:
  typedef MTSQLOracleParser parser;
  typedef MTSQLOracleTreeParser semantic_analyzer;
  typedef RewriteOracleTreeParser query_rewriter;
  typedef GenerateOracleQueryTreeParser query_generator;
};

class SQLServerInterpreter
{
public:
  typedef MTSQLParser parser;
  typedef MTSQLTreeParser semantic_analyzer;
  typedef RewriteTreeParser query_rewriter;
  typedef GenerateQueryTreeParser query_generator;
};

/**
 * A simple proxy/pimpl to keep ANTLR out of the headers.
 */
class AbstractSyntaxTree
{
private:
  RefAST mTree;
  
public:
  AbstractSyntaxTree(RefAST tree)
    :
    mTree(tree)
  {
  }

  RefAST getTree()
  {
    return mTree;
  }
};

template <class _T>
class MTSQLInterpreterImpl : public MTSQLInterpreterBase
{
private:
  typename _T::parser * mParser;
  typename _T::semantic_analyzer * mSemanticAnalyzer;
  typename _T::query_rewriter * mQueryRewriter;
  typename _T::query_generator * mQueryGenerator;
  std::string mTempTable;
  std::string mTagName;

  Environment* mEnvironment;

  typename _T::semantic_analyzer * getSemanticAnalyzer(bool createNew=false);
  typename _T::query_rewriter * getQueryRewriter(bool createNew=false);
  typename _T::query_generator * getQueryGenerator(bool createNew=false);

  GlobalCompileEnvironment* mGlobalEnvironment;
  std::map<std::string, int> mGlobalVariables;

  std::vector<PrimitiveFunctionLibrary *> mLibraries;

  std::vector<MTSQLParam> mProgramParams;

  antlr::TokenStreamHiddenTokenFilter* mFilter;

  bool mSupportVarchar;
  
  typename _T::parser * CreateParser(MTSQLLexer& lexer);
  typename _T::semantic_analyzer * CreateSemanticAnalyzer();
  typename _T::query_rewriter * CreateQueryRewriter();
  typename _T::query_generator * CreateQueryGenerator();
  
  std::vector<MTSQLExecutable *> mExecutables;
public:
  // Requires: globalEnvironment is not NULL.
  // Default constructor loads the Standard library
  MTSQLInterpreterImpl(GlobalCompileEnvironment* globalEnvironment);
  // Requires: globalEnvironment is not NULL.
  // Default constructor loads the Standard library and inserts
  // globalVars into the environment.
  MTSQLInterpreterImpl(GlobalCompileEnvironment* globalEnvironment, 
                       const std::map<std::string,int>& globalVars);

  ~MTSQLInterpreterImpl();

  bool getSupportVarchar() { return mSupportVarchar; }
  void setSupportVarchar(bool supportVarchar) { mSupportVarchar = supportVarchar; }
#ifndef WIN32
  MTSQLExecutable *analyze(const UChar* str, MTSQLInterpreter * i);
  void code_generate(const UChar* str, 
                     std::vector<MTSQLInstruction *>& code, 
                     std::size_t& numRegisters,
                     MTSQLInterpreter * i);
#endif
  MTSQLExecutable *analyze(const char* str, MTSQLInterpreter * i);
  void code_generate(const char* str, 
                     std::vector<MTSQLInstruction *>& code, 
                     std::size_t& numRegisters,
                     MTSQLInterpreter * i);
  MTSQLExecutable *analyze(const wchar_t* str, MTSQLInterpreter * i);
  void code_generate(const wchar_t* str, 
                     std::vector<MTSQLInstruction *>& code, 
                     std::size_t& numRegisters,
                     MTSQLInterpreter * i);
  int getReturnType();

  void setTempTable (const std::string& table, const std::string& tag) { mTempTable = table; mTagName = tag; }
#ifdef WIN32
  BatchQuery* analyzeQuery();
#endif

  std::string refactorRenameVariable(const std::string &script,
                                     const std::string &oldName,
                                     const std::string &newName);

  std::string refactorVarchar(const std::string &script);

  const std::vector<PrimitiveFunctionLibrary *>& getLibraries();
  const std::vector<MTSQLParam>& getProgramParams() {return mProgramParams; }

  boost::shared_ptr<AbstractSyntaxTree> getAST()
  {
    return boost::shared_ptr<AbstractSyntaxTree>(new AbstractSyntaxTree(getQueryGenerator()->getAST()));
  }

  antlr::TokenStreamHiddenTokenFilter* GetFilter();

private:
  /** 
   * Produce a new script by refactoring.  The given lex refactor
   * options should be set prior to calling this.
   */
  string refactor(MTSQLRefactorLexer &lex);

};

template <class _T>
MTSQLInterpreterImpl<_T>::MTSQLInterpreterImpl(GlobalCompileEnvironment* globalEnvironment) :
  mParser(NULL),
  mSemanticAnalyzer(NULL),
  mQueryRewriter(NULL),
  mQueryGenerator(NULL),
  mEnvironment(NULL),
  mGlobalEnvironment(globalEnvironment),
  mFilter(NULL),
  mSupportVarchar(false)
{
  mTempTable = "#tmp_args";
  mTagName = "";
  mLibraries.push_back(new StandardLibrary());
}

template <class _T>
MTSQLInterpreterImpl<_T>::MTSQLInterpreterImpl(GlobalCompileEnvironment* globalEnvironment,
                                               const std::map<std::string,int>& globalVariables) :
  mParser(NULL),
  mSemanticAnalyzer(NULL),
  mQueryRewriter(NULL),
  mQueryGenerator(NULL),
  mEnvironment(NULL),
  mGlobalEnvironment(globalEnvironment),
  mGlobalVariables(globalVariables),
  mFilter(NULL),
  mSupportVarchar(false)
{
  mTempTable = "#tmp_args";
  mTagName = "";
  mLibraries.push_back(new StandardLibrary());
}

template <class _T>
MTSQLInterpreterImpl<_T>::~MTSQLInterpreterImpl()
{
  if (mSemanticAnalyzer != NULL)
  {
    delete mSemanticAnalyzer->getASTFactory();
  }
  delete mSemanticAnalyzer;
  if (mQueryRewriter != NULL)
  {
    delete mQueryRewriter->getASTFactory();
  }
  delete mQueryRewriter;
  if (mQueryGenerator != NULL)
  {
    delete mQueryGenerator->getASTFactory();
  }
  delete mQueryGenerator;
  delete mFilter;
  if (mParser != NULL)
  {
    delete mParser->getASTFactory();
  }
  delete mParser;
	
  // Unload and delete all of the libraries
  while(mLibraries.size() > 0)
  {
    delete mLibraries.back();
    mLibraries.pop_back();
  }

  delete mEnvironment;

  // Delete all of the executables that were created from me.
  while(mExecutables.size() > 0)
  {
    delete mExecutables.back();
    mExecutables.pop_back();
  }
}

template <class _T>
typename _T::semantic_analyzer * MTSQLInterpreterImpl<_T>::getSemanticAnalyzer(bool createNew)
{
  if (createNew == true)
  {
    if (mSemanticAnalyzer != NULL)
    {
      delete mSemanticAnalyzer->getASTFactory();
    }
    delete mSemanticAnalyzer;
    mSemanticAnalyzer = CreateSemanticAnalyzer();
    ANTLR_USE_NAMESPACE(antlr)ASTFactory* ast = new ANTLR_USE_NAMESPACE(antlr)ASTFactory("MTSQLAST", MTSQLAST::factory);
    delete mEnvironment;
    mEnvironment = new Environment(mGlobalEnvironment->createFrame());
    mSemanticAnalyzer->initASTFactory(*ast);
    mSemanticAnalyzer->setASTFactory(ast);
    mSemanticAnalyzer->setSupportVarchar(mSupportVarchar);
    mSemanticAnalyzer->setEnvironment(mEnvironment);
    mSemanticAnalyzer->setLog(mGlobalEnvironment);
    // Load up all of the libraries into the environment
    for(std::vector<int>::size_type i = 0; i<getLibraries().size(); i++)
      mEnvironment->loadLibrary(getLibraries()[i]);
    // Load up all of the global variables
    for(std::map<std::string, int>::iterator it = mGlobalVariables.begin();
        it != mGlobalVariables.end();
        it++)
    {
      mEnvironment->insertVar(it->first, 
                              VarEntry::create(it->second, 
                                               mEnvironment->allocateVariable(it->first, it->second), 
                                               mEnvironment->getCurrentLevel()));
    }
  }
  return mSemanticAnalyzer;
}

template <class _T>
typename _T::query_rewriter * MTSQLInterpreterImpl<_T>::getQueryRewriter(bool createNew)
{
  if (createNew == true)
  {
    if (mQueryRewriter != NULL)
    {
      delete mQueryRewriter->getASTFactory();
    }
    delete mQueryRewriter;
    // Must recreate environment because the symbol table of the inner scope is destroyed
    // at this point.
    delete mEnvironment;
    mEnvironment = new Environment(mGlobalEnvironment->createFrame());
    // Load up all of the libraries into the environment
    for(std::vector<int>::size_type i = 0; i<getLibraries().size(); i++)
      mEnvironment->loadLibrary(getLibraries()[i]);
    mQueryRewriter = CreateQueryRewriter();
  }
  return mQueryRewriter;
}

template <class _T>
typename _T::query_generator * MTSQLInterpreterImpl<_T>::getQueryGenerator(bool createNew)
{
  if (createNew == true)
  {
    if (mQueryGenerator != NULL)
    {
      delete mQueryGenerator->getASTFactory();
    }
    delete mQueryGenerator;
    // Must recreate environment because the symbol table of the inner scope is destroyed
    // at this point.
    delete mEnvironment;
    mEnvironment = new Environment(mGlobalEnvironment->createFrame());
    // Load up all of the libraries into the environment
    for(std::vector<int>::size_type i = 0; i<getLibraries().size(); i++)
      mEnvironment->loadLibrary(getLibraries()[i]);
    mQueryGenerator = CreateQueryGenerator();
  }
  return mQueryGenerator;
}

template <class _T>
const std::vector<PrimitiveFunctionLibrary *>& MTSQLInterpreterImpl<_T>::getLibraries()
{
  return mLibraries;
}

#ifdef WIN32
template <class _T>
BatchQuery* MTSQLInterpreterImpl<_T>::analyzeQuery()
{
  try 
  {
    // We've already done two passes of semantic analysis.
    // Convert the query.
//     RewriteTreeParser rewrite;
//     rewrite.initialize("#tmp_args");
//     rewrite.setASTNodeFactory(&MTSQLAST::factory);
//     rewrite.setEnvironment(mEnvironment);
//     rewrite.program(getSemanticAnalyzer()->getAST());

//     RefAST ast = RefAST(rewrite.getAST());
// 		if(ast) 
// 		{
// 			mGlobalEnvironment->logDebug(ast->toStringList());
// 		}
// 		else 
// 		{
// 			mGlobalEnvironment->logError("Parse failed");
// 			return NULL;
// 		}

//     GenerateQueryTreeParser generate;
//     generate.setASTNodeFactory(&MTSQLAST::factory);
//     generate.program(ast);


    // Go back to the 2nd semantic analysis pass and rewrite the queries.
    RefAST ast = getSemanticAnalyzer(false)->getAST();
    typename _T::query_rewriter * rewrite = getQueryRewriter(true);
    try {
      rewrite->program((ANTLR_USE_NAMESPACE(antlr)RefAST) ast);
    } catch (MTSQLSemanticException& e) {
      mGlobalEnvironment->logError(e.toString());
      return NULL;
    } catch (ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrSemanticException) {
      mGlobalEnvironment->logError(antlrSemanticException.toString());
      return NULL;
    }

    ast = RefAST(rewrite->getAST());
		if(ast) 
		{
		}
		else 
		{
			mGlobalEnvironment->logError("Query rewrite failed");
			return NULL;
		}

    std::wstring query;
//     UnicodeString query;
    std::string create;
    std::string insert;
    std::vector<VarEntryPtr> inputs;
    std::vector<VarEntryPtr> outputs;

    typename _T::query_generator * generate = getQueryGenerator(true);
    
    generate->setFilter(GetFilter());
    generate->program(ast);
    query = generate->getQueryString();

    rewrite->getTempTable(create, insert, inputs, outputs);
      

    //mGlobalEnvironment->logDebug(generate->getQueryString());

    return new BatchQuery(create, 
			  insert, 
			  query, 
			  rewrite->getTempTableName(),
			  inputs, 
			  outputs);
  }
  catch(MTSQLException& e)
  {
    mGlobalEnvironment->logError(string("exception: ") + e.what());
    return NULL;
  }
}
#endif

template <class _T>
ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter* MTSQLInterpreterImpl<_T>::GetFilter()
{
  ASSERT(mFilter != NULL);
  if(mFilter == NULL)
    throw MTSQLException(std::string("TokenStreamHiddenTokenFilter is NULL"));
  return mFilter;
}

template <class _T>
typename _T::parser * MTSQLInterpreterImpl<_T>::CreateParser(MTSQLLexer& lexer)
{
  mFilter = new ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter(lexer);
  mFilter->hide(MTSQLParser::WS);
  mFilter->hide(MTSQLParser::SL_COMMENT);
  mFilter->hide(MTSQLParser::ML_COMMENT);
  
  if(mParser != NULL)
  {
    delete mParser; mParser = NULL;
  }
  
  mParser = new typename _T::parser (*mFilter);

  return mParser;
}

template <class _T>
typename _T::semantic_analyzer * MTSQLInterpreterImpl<_T>::CreateSemanticAnalyzer()
{
  return new typename _T::semantic_analyzer();
}

template <class _T>
typename _T::query_rewriter * MTSQLInterpreterImpl<_T>::CreateQueryRewriter()
{
  typename _T::query_rewriter * parser = new typename _T::query_rewriter();
  parser->initialize(mTempTable, mTagName);
  ANTLR_USE_NAMESPACE(antlr)ASTFactory* ast = new ANTLR_USE_NAMESPACE(antlr)ASTFactory("MTSQLAST", MTSQLAST::factory);
  parser->initASTFactory(*ast);
  parser->setASTFactory(ast);
  parser->setEnvironment(mEnvironment);
  // 		parser->setLog(mGlobalEnvironment);
  return parser;
}

template <class _T>
typename _T::query_generator * MTSQLInterpreterImpl<_T>::CreateQueryGenerator()
{
  typename _T::query_generator * parser = new typename _T::query_generator();
  ANTLR_USE_NAMESPACE(antlr)ASTFactory* ast = new ANTLR_USE_NAMESPACE(antlr)ASTFactory("MTSQLAST", MTSQLAST::factory);
  parser->initASTFactory(*ast);
  parser->setASTFactory(ast);
  parser->setEnvironment(mEnvironment);
  // 		parser->setLog(mGlobalEnvironment);
  return parser;
}

#ifndef WIN32
template <class _T>
MTSQLExecutable* MTSQLInterpreterImpl<_T>::analyze(const UChar* str, MTSQLInterpreter * itrp)
{
  std::string utf8String;
  ::UnicodeStringToUTF8(str, utf8String);
  return analyze(utf8String.c_str(), itrp);
}
#endif


template <class _T>
MTSQLExecutable* MTSQLInterpreterImpl<_T>::analyze(const wchar_t* str, MTSQLInterpreter * itrp)
{
  std::string utf8String;
  ::WideStringToUTF8(str, utf8String);
  return analyze(utf8String.c_str(), itrp);
}

template <class _T>
MTSQLExecutable* MTSQLInterpreterImpl<_T>::analyze(const char* str, MTSQLInterpreter * itrp)
{
  try {
    istringstream istr(str);		
    MTSQLLexer lexer(istr);
    lexer.setTokenObjectFactory(&CommonHiddenStreamToken::factory);
    lexer.setLog(mGlobalEnvironment);
    CreateParser(lexer);
    mParser->setLog(mGlobalEnvironment);
    ASTFactory* ast_factory = new ASTFactory("MTSQLAST", MTSQLAST::factory);
    mParser->initASTFactory(*ast_factory);
    mParser->setASTFactory(ast_factory);
    try {
      mParser->program();
    } catch (ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrException) {
      mGlobalEnvironment->logError(antlrException.toString());
      return NULL;
    }


		RefCommonAST ast = RefCommonAST(mParser->getAST());
		if(!mParser->getHasError() && ast) 
		{
		}
		else 
		{
			mGlobalEnvironment->logError("Parse failed");
			return NULL;
		}

    // Do first pass semantic analysis of the parse tree
    try {
      getSemanticAnalyzer(true)->program((RefAST)ast);
      mProgramParams = getSemanticAnalyzer(false)->getParams();
      ast = RefCommonAST(getSemanticAnalyzer()->getAST());
    } catch (MTSQLSemanticException& e) {
      mGlobalEnvironment->logError(e.toString());
      return NULL;
    } catch (ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrSemanticException) {
      mGlobalEnvironment->logError(antlrSemanticException.toString());
      return NULL;
    }

		if(ast) 
		{
		}
		else 
		{
			mGlobalEnvironment->logError("Type checking failed; null AST");
			return NULL;
		}

		// Do second pass semantic analysis of the parse tree
		try {
  	  getSemanticAnalyzer(true)->program((RefAST)ast);
			ast = RefCommonAST(getSemanticAnalyzer()->getAST());
		} catch (MTSQLSemanticException& e) {
			mGlobalEnvironment->logError(e.toString());
			return NULL;
		} catch (ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrSemanticException) {
			mGlobalEnvironment->logError(antlrSemanticException.toString());
			return NULL;
		}
		if(ast) 
		{
		}
		else 
		{
			mGlobalEnvironment->logError("Second pass failed; null AST");
			return NULL;
		}

    // We've already done two passes of semantic analysis.
    // Transform the tree to create query strings.
    typename _T::query_generator * generate = getQueryGenerator(true);
    generate->setFilter(GetFilter());
    try {
      generate->program((ANTLR_USE_NAMESPACE(antlr)RefAST) ast);
			ast = RefCommonAST(getSemanticAnalyzer()->getAST());
		} catch (MTSQLSemanticException& e) {
			mGlobalEnvironment->logError(e.toString());
			return NULL;
		} catch (ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrSemanticException) {
			mGlobalEnvironment->logError(antlrSemanticException.toString());
			return NULL;
		}
		if(ast) 
		{
		}
		else 
		{
			mGlobalEnvironment->logError("Generate query failed; null AST");
			return NULL;
		}

    MTSQLExecutable* exe = new MTSQLExecutable(itrp);
    if (exe != NULL) mExecutables.push_back(exe);
    
    vector<MTSQLParam>::iterator it;
    
    return exe;

  } catch (MTSQLException& e) {
    mGlobalEnvironment->logError(string("exception: ") + e.what());
    return NULL;
  }
}

template <class _T>
void MTSQLInterpreterImpl<_T>::code_generate(const char* str,
                                             std::vector<MTSQLInstruction*>& code, 
                                             std::size_t& numRegisters,
                                             MTSQLInterpreter * itrp)
{
  try {
    analyze(str, itrp);
    MTSQLTreeCompile codeGenerator;
    codeGenerator.initialize();
    codeGenerator.setLog(mGlobalEnvironment);
    codeGenerator.setSourceCode(str);
    codeGenerator.program(getQueryGenerator()->getAST());
    code = codeGenerator.getProgram();
    numRegisters = codeGenerator.getNumRegisters();
//     if (mGlobalEnvironment->isOkToLogDebug())
//     {
//       for(std::size_t i = 0; i<code.size(); i++)
//       {
//         char buf[2048];
//         sprintf(buf, "Line %d: %s", i, code[i]->Print().c_str());
//         mGlobalEnvironment->logDebug(buf);
//       }
//     }
  } catch(ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrException) {
    throw MTSQLUnhandledAntlrException(antlrException);
  }
}

template <class _T>
void MTSQLInterpreterImpl<_T>::code_generate(const wchar_t* str,
                                             std::vector<MTSQLInstruction*>& code, 
                                             std::size_t& numRegisters,
                                             MTSQLInterpreter * itrp)
{
  std::string utf8Str;
  ::WideStringToUTF8(str, utf8Str);
  code_generate(utf8Str.c_str(), code, numRegisters, itrp);
}

#ifndef WIN32
template <class _T>
void MTSQLInterpreterImpl<_T>::code_generate(const UChar* str,
                                             std::vector<MTSQLInstruction*>& code, 
                                             std::size_t& numRegisters,
                                             MTSQLInterpreter * itrp)
{
  std::string utf8Str;
  ::UnicodeStringToUTF8(str, utf8Str);
  code_generate(utf8Str.c_str(), code, numRegisters, itrp);
}
#endif

template <class _T>
int MTSQLInterpreterImpl<_T>::getReturnType() 
{
  return getSemanticAnalyzer()->getReturnType();
}

MTSQLExecutable::MTSQLExecutable(MTSQLInterpreter* analyzer) :
  mSemanticAnalyzer(analyzer), mProgram(NULL), mRegisterMachine(NULL)
{
  // Must preallocate the MTSQLTreeExecution object, it is expensive
  // to create since symbols are loaded.
  mProgram = new MTSQLTreeExecution();
  mRuntimeEnv = new TestRuntimeEnvironment(NULL);
  for (std::vector<int>::size_type i=0; i<mSemanticAnalyzer->getLibraries().size(); i++)
    mRuntimeEnv->loadLibrary(mSemanticAnalyzer->getLibraries()[i]);
}

template <class _T>
string MTSQLInterpreterImpl<_T>::refactorRenameVariable(const string& script,
                                                        const string& oldName,
                                                        const string& newName)
{
  // Create lexer
  istringstream istr(script.c_str());		
  MTSQLRefactorLexer lexer(istr);

  // Set refactoring options
  lexer.setRefactorRenameVariable(oldName, newName);

  return refactor(lexer);
}

template <class _T>
string MTSQLInterpreterImpl<_T>::refactorVarchar(const string& script)
{
  // Create lexer
  istringstream istr(script.c_str());		
  MTSQLRefactorLexer lexer(istr);

  // Set refactoring options
  lexer.setRefactorVarchar();

  return refactor(lexer);
}

template <class _T>
string MTSQLInterpreterImpl<_T>::refactor(MTSQLRefactorLexer &lexer)
{
  // This method is similar to the beginning of analyze().
  // We are using the parser to drive the lexing of the
  // script.
  
  lexer.setTokenObjectFactory(&CommonHiddenStreamToken::factory);
  lexer.setLog(mGlobalEnvironment);

  try {
    // This is the equivalent of the CreateParserMethod()
    mFilter = new ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter(lexer);
    mFilter->hide(MTSQLParser::WS);
    mFilter->hide(MTSQLParser::SL_COMMENT);
    mFilter->hide(MTSQLParser::ML_COMMENT);
  
    if(mParser != NULL)
    {
      delete mParser; mParser = NULL;
    }
  
    mParser = new typename _T::parser (*mFilter);

    mParser->setLog(mGlobalEnvironment);
    ASTFactory* ast_factory = new ASTFactory("MTSQLAST", MTSQLAST::factory);
    mParser->initASTFactory(*ast_factory);
    mParser->setASTFactory(ast_factory);
    try {
      mParser->program();
    } catch (ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrException) {
      mGlobalEnvironment->logError(antlrException.toString());
      throw;
    }
  } catch (MTSQLException& e) {
    mGlobalEnvironment->logError(string("exception: ") + e.what());
    throw;
  }

  return lexer.getConvertedScript();
}


MTSQLInterpreter::MTSQLInterpreter(GlobalCompileEnvironment* globalEnvironment)
  :
  mImpl(NULL)
{
#ifdef WIN32
  COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
  mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
  if (mIsOracle)
    mImpl = new MTSQLInterpreterImpl<OracleInterpreter>(globalEnvironment);
  else
    mImpl = new MTSQLInterpreterImpl<SQLServerInterpreter>(globalEnvironment);
#else
  mIsOracle = true;
  mImpl = new MTSQLInterpreterImpl<OracleInterpreter>(globalEnvironment);
#endif
}

MTSQLInterpreter::MTSQLInterpreter(GlobalCompileEnvironment* globalEnvironment,
                                   const std::map<std::string,int>& globalVariables) 
  :
  mImpl(NULL)
{
#ifdef WIN32
  COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
  mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
  if (mIsOracle)
    mImpl = new MTSQLInterpreterImpl<OracleInterpreter>(globalEnvironment, globalVariables);
  else
    mImpl = new MTSQLInterpreterImpl<SQLServerInterpreter>(globalEnvironment, globalVariables);
#else
  mIsOracle = true;
  mImpl = new MTSQLInterpreterImpl<OracleInterpreter>(globalEnvironment, globalVariables);
#endif
}

MTSQLInterpreter::~MTSQLInterpreter()
{
  delete mImpl;
}

MTSQLExecutable::~MTSQLExecutable()
{
  delete mProgram;
  delete mRegisterMachine;
  delete mRuntimeEnv;

  while(mCode.size() > 0)
  {
    MTSQLInstruction* param =  mCode.back();
    delete param;
    param = NULL;
    mCode.pop_back();
  }
}

void MTSQLExecutable::exec(GlobalRuntimeEnvironment* env)
{
  try {
    mRuntimeEnv->setGlobalEnvironment(env->getActivationRecord());
    mProgram->setRuntimeEnvironment(mRuntimeEnv);
    mProgram->setLog(env);
    mProgram->setTransactionContext(env);
    mProgram->program(mSemanticAnalyzer->getAST()->getTree());	
  } catch(ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrException) {
    throw MTSQLUnhandledAntlrException(antlrException);
  }
}

void MTSQLExecutable::codeGenerate(GlobalCompileEnvironment * globalEnvironment)
{
  try 
  {
    MTSQLTreeCompile codeGenerator;
    codeGenerator.initialize();
    codeGenerator.setLog(globalEnvironment);
    codeGenerator.program(mSemanticAnalyzer->getAST()->getTree());
    mCode = codeGenerator.getProgram();
    mRegisterMachine = new MTSQLRegisterMachine(codeGenerator.getNumRegisters(), mCode);
//     if (globalEnvironment->isOkToLogDebug())
//     {
//       for(std::size_t i = 0; i<mCode.size(); i++)
//       {
//         char buf[2048];
//         sprintf(buf, "Line %d: %s", i, mCode[i]->Print().c_str());
//         globalEnvironment->logDebug(buf);
//       }
//     }
    return;
  } catch(ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrException) {
    throw MTSQLUnhandledAntlrException(antlrException);
  }
}

void MTSQLExecutable::execCompiled(GlobalRuntimeEnvironment* env)
{
  try {
    mRuntimeEnv->setGlobalEnvironment(env->getActivationRecord());
    mRegisterMachine->SetTransactionContext(env);
    mRegisterMachine->Execute(mRuntimeEnv, env);
  } catch(ANTLR_USE_NAMESPACE(antlr)ANTLRException& antlrException) {
    throw MTSQLUnhandledAntlrException(antlrException);
  }
}

int MTSQLExecutable::getReturnType() const
{
  return mSemanticAnalyzer->getReturnType();
}

const RuntimeValue * MTSQLExecutable::getReturnValue() const
{
  // Only handles register machine implementation right now.
  return mRegisterMachine->GetReturnValue();
}


// Unit testing methods
bool MTSQLUnitTest::ParseProgram(const std::string& prog)
{
	// Don't terminate with an ends!  The STL will make this look like an EOF
	// which is what the parser wants.
	stringstream sstr;
	sstr << prog;
	MTSQLLexer lexer(sstr);

	StdioLogger stdioLog;
	lexer.setLog(&stdioLog);
	lexer.setTokenObjectFactory(&CommonHiddenStreamToken::factory);
	ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter filter(lexer);
	filter.hide(MTSQLParser::WS);
	filter.hide(MTSQLParser::SL_COMMENT);
	filter.hide(MTSQLParser::ML_COMMENT);
	MTSQLParser parser(filter);
	parser.setLog(&stdioLog);
  ASTFactory fac("MTSQLAST", MTSQLAST::factory);
  parser.initializeASTFactory(fac);
	parser.setASTFactory(&fac);
	parser.program();	
	return !parser.getHasError();
}

void MTSQLUnitTest::AnalyzeProgram(const std::string& prog, std::vector<MTSQLParam>& params)
{
		// Don't terminate with an ends!  The STL will make this look like an EOF
		// which is what the parser wants.
		stringstream sstr;
		sstr << prog;
		StdioLogger stdioLog;
		MTSQLLexer lexer(sstr);
		lexer.setLog(&stdioLog);
		lexer.setTokenObjectFactory(&CommonHiddenStreamToken::factory);
		ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter filter(lexer);
		filter.hide(MTSQLParser::WS);
		filter.hide(MTSQLParser::SL_COMMENT);
		filter.hide(MTSQLParser::ML_COMMENT);
		MTSQLParser parser(filter);
		parser.setLog(&stdioLog);
    ASTFactory fac("MTSQLAST", MTSQLAST::factory);
    parser.initializeASTFactory(fac);
	  parser.setASTFactory(&fac);
		parser.program();	
		RefCommonAST ast = RefCommonAST(parser.getAST());
		MTSQLTreeParser analyzer;
		analyzer.setASTFactory(&fac);
		MTFrame frame;
		Environment env(&frame);
		analyzer.setEnvironment(&env);	
		analyzer.setLog(&stdioLog);
		analyzer.program((RefAST)ast);
		ast = RefMTSQLAST(analyzer.getAST());
		
		params = analyzer.getParams();
}

