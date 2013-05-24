#pragma warning( disable : 4786 ) 

#include <metra.h>
#include <string>
#include <iostream>
#include <fstream>
#include <strstream>

#include "crtdbg.h"

#include "MTSQLInterpreter.h"
#include "MTSQLUnitTest.h"

#include "MTSQLLexer.hpp"
#include "MTSQLParser.hpp"
#include "MTSQLAST.h"
#include "TokenStreamHiddenTokenFilter.hpp"
#include "CommonHiddenStreamToken.hpp"
#include "Token.hpp"

#include "test.h"


ANTLR_USING_NAMESPACE(std)
ANTLR_USING_NAMESPACE(antlr)

UnitTestMTSQLParser::UnitTestMTSQLParser()
{
}

bool UnitTestMTSQLParser::ParseProgram(const std::string& prog)
{
  return MTSQLUnitTest::ParseProgram(prog);
}

void UnitTestMTSQLParser::UnitTest1()
{
	ParseProgram("CREATE PROCEDURE sdf @param DECIMAL SA SET @param = 3.3;");
}

void UnitTestMTSQLParser::UnitTestSelectStatement()
{
	// This should succeed
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS SELECT a,b INTO @output1, @output2 FROM t_A, t_B WHERE t_A.col = t_B.col "
											"AND t_A.foo = @input1 AND t_B.bar = @input2"));

	// Test BETWEEN
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS SELECT a,b INTO @output1, @output2 FROM t_A, t_B WHERE t_A.col = t_B.col "
											"AND t_A.foo = @input1 AND t_B.bar = @input2 AND t_B.baz BETWEEN @input1 AND @input2"));

	// Test table alias
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS SELECT a1.a,a2.b INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2"));

	// Test your basic group by
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS SELECT a1.b, SUM(a2.num) INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 GROUP BY a1.b"));

	// Test your basic group by with having
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS SELECT a1.b, SUM(a2.num) INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 GROUP BY a1.b HAVING SUM(a2.num) > 0.0 AND a1.c <> a1.b"));

	// Test JOIN
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 INNER JOIN t_B a2 ON a1.col=a2.col WHERE a1.boo=@input1"));

	// Test JOIN
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 JOIN t_B a2 ON a1.col=a2.col WHERE a1.boo=@input1"));

	// Test JOIN
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 LEFT OUTER JOIN t_B a2 ON a1.col=a2.col WHERE a1.boo=@input1"));

	// Test JOIN
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 LEFT JOIN t_B a2 ON a1.col=a2.col WHERE a1.boo=@input1"));

	// Test JOIN 
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 CROSS JOIN t_B a2 WHERE a1.boo=@input1 AND a2.boo=@input2"));

	// Test multiple JOINs
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 "
											"INNER JOIN t_B a2 ON a1.col=a2.col "
                      "LEFT OUTER JOIN t_C a3 ON a3.col=a2.col2 "
                      "CROSS JOIN t_D a4 WHERE a1.boo=@input1 AND a4.boo=@input2"));

	// Test multiple JOINs with multiple table parameters
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 "
											"INNER JOIN t_B a2 ON a1.col=a2.col "
                      "LEFT OUTER JOIN t_C a3 ON a3.col=a2.col2 "
                      "CROSS JOIN t_D a4, "
											"t_E a5 "
                      "WHERE a1.boo=@input1 AND a4.boo=@input2 AND a4.col=a5.col"));

	// Test multiple JOINs with multiple table parameters
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1 "
											"INNER JOIN t_B a2 ON a1.col=a2.col "
                      "LEFT OUTER JOIN t_C a3 ON a3.col=a2.col2, "
											"t_E a5 "
											"INNER JOIN t_F a6 ON a5.col2=a6.col "
                      "WHERE a1.boo=@input1 AND a4.boo=@input2 AND a4.col=a5.col"));

	// Test an exists query
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 AND EXISTS (SELECT * FROM t_C a3 WHERE a3.col=a1.col AND a3.baz <> @input1)"));

	// Test a not exists query
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS SELECT a1.b, a2.num INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 AND NOT EXISTS ("
											"SELECT * FROM t_C a3 "
											"INNER JOIN t_D ON a3.blah=basdrf "
											"WHERE a3.col=a1.col AND a3.baz <> @input1 "
											") AND EXISTS ("
											"SELECT * FROM t_E WHERE t_E.fasdf=a2.sdf AND floor(t_E.ttt) < @input2 "
											")"));

	// Simple UNION query
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, SUM(a2.num) INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 "
											"UNION "
											"SELECT a3.b, a3.c INTO @output1, @output2 FROM t_C a3 WHERE a3.a=@input2"
					 ));

	// Simple UNION ALL query
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, SUM(a2.num) INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 "
											"UNION ALL "
											"SELECT a3.b, a3.c INTO @output1, @output2 FROM t_C a3 WHERE a3.a=@input2"
					 ));

	// Simple ORDER BY query
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, SUM(a2.num) INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 "
											"ORDER BY a1.a ASC, a2.num, a1.b + a2.c DESC"
					 ));

	// Simple subquery with IN
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, SUM(a2.num) INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 "
                      "OR a1.foo NOT IN (SELECT a3.foo FROM t_C a3 WHERE a3.baz=a2.blah)"
					 ));

	// Simple IN with expression list
	ASSERT(ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
											"AS "
											"SELECT a1.b, SUM(a2.num) INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
											"AND a1.foo = @input1 AND a2.bar = @input2 "
                      "OR a1.foo NOT IN (33.33, @input1, -556.234)"
					 ));

	// Invalid param in the select list
  // Is this really an error????
// 	ASSERT(!ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
// 											 "AS "
// 											 "SELECT @input1,a2.b INTO @output1, @output2 FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
// 											 "AND a1.foo = @input1 AND a2.bar = @input2"));
											 
	// Omit INTO
// 	ASSERT(!ParseProgram("CREATE PROCEDURE proc @input1 DECIMAL @input2 DECIMAL @output1 DECIMAL @output2 DECIMAL "
// 											 "AS SELECT a1.a,a2.b FROM t_A a1, t_B a2 WHERE a1.col = a2.col "
// 											 "AND a1.foo = @input1 AND a2.bar = @input2"));
											 
}

void UnitTestMTSQLParser::RunTests()
{
	UnitTest1();
	UnitTestSelectStatement();
	ParseProgram("CREAT PROCEDURE sdf @param DECIMAL AS SET @param = 3.3;");
	ParseProgram("CREATE PROEDURE sdf @param DECIMAL AS SET @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf param DECIMAL AS SET @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf @param DECIMAL SA DECIMAL AS SET @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf param DECIMAL @SA DECIMAL AS SET @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf @param DEeCIMAL AS SET @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf @param DECIMAL AS SET @param = 3.3; ST @param = 3.3; SET @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf @param DECIMAL AS ST @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf @param DECIMAL AS ST @param = 3.3; SET @param = 3.3;");
	ParseProgram("CREATE PROCEDURE sdf @param DOUBLE AS SET @param = CAST(3.3+CAST('4.4' AS DECIMAL) AS DOUBLE);");
	ParseProgram("CREATE PROCEDURE sdf @param DOUBLE AS SET @param = (2.234E3 + 2.1E6)/8.9E3;");
}
