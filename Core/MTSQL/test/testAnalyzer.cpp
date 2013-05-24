#pragma warning( disable : 4786 ) 

#include <string>
#include <iostream>
#include <fstream>
#include <strstream>

#include "crtdbg.h"

#include "MTSQLInterpreter.h"
#include "MTSQLUnitTest.h"

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
#include <MTSQLParam.h>


ANTLR_USING_NAMESPACE(std)
ANTLR_USING_NAMESPACE(antlr)

UnitTestMTSQLAnalyzer::UnitTestMTSQLAnalyzer()
{
}

void UnitTestMTSQLAnalyzer::AnalyzeProgram(const std::string& prog)
{
	try {
		std::vector<MTSQLParam> params;
    MTSQLUnitTest::AnalyzeProgram(prog, params);
		vector<MTSQLParam>::iterator it;
		std::cout << "\n Program " << prog << " has " << params.size() << " parameters: " << endl;
		for(it = params.begin(); it != params.end(); it++)
		{
			cout << "Param -- Name: "<< (*it).GetName() << ", Type: " << (*it).GetType() << ", Direction: " << (*it).GetDirection() << ". "  << endl;
		}
	} catch (MTSQLSemanticException& semantic) {
		cerr << "Type Checking Exception: " << semantic.toString().c_str() << endl;
	} catch (exception& e) {
		cerr << "Generic internal error: " << e.what() << endl;
	}
}

void UnitTestMTSQLAnalyzer::UnitTest1()
{
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL AS SET @param = 3;");
}

void UnitTestMTSQLAnalyzer::RunTests()
{
	UnitTest1();
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL AS SET @param = 3.3 + 'asdf';");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL AS SET @param = 3.3 % 'asdf';");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL AS SET @param = 3.3 + undef('asdf');");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL AS SET @param = 3.3 + @parm;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL AS SELECT foo INTO @param FROM table;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param1 BOOLEAN @param2 BOOLEAN @param3 BOOLEAN AS SET @param1 = @param2 + @param3;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL @param1 INTEGER AS SET @param = 0.5;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL OUTPUT @param1 INTEGER AS SET @param = 0.5;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL @param1 INTEGER @param2 INTEGER OUTPUT AS SET @param = 0.5;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL @param1 INTEGER @param2 INTEGER OUTPUT @param3 INTEGER AS SET @param = 0.5;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL @param1 INTEGER @param2 INTEGER OUTPUT @param3 INTEGER AS DECLARE @param4 INTEGER; SET @param4 = 0.5;");
	AnalyzeProgram("CREATE PROCEDURE sdf @param DECIMAL @param1 INTEGER AS DECLARE @param4 INTEGER SET @param = 0.5;");
}
