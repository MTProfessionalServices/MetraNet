using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
using NUnit.Framework.Extensions;

using MetraTech.MTSQL;
using MetraTech.Test;
using MetraTech.Test.Common;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;


  // To run the this test fixture:
  //
  // On older systems:
  //     nunit-console /fixture:MetraTech.MTSQL.Test.MTSQLTest /assembly:o:\debug\bin\MetraTech.MTSQL.Test.dll
  //
  // On newer systems:
  //    cd C:\Program Files (x86)\NUnit 2.5.6\bin\net-2.0
  //    nunit-console-x86.exe /fixture:MetraTech.MTSQL.Test.MTSQLTest /assembly:o:\debug\bin\MetraTech.MTSQL.Test.dll 
  
namespace MetraTech.MTSQL.Test
{
	/// <summary>
	/// Summary description for Test.
	/// </summary>
	[TestFixture]
	public class MTSQLTest
	{
		
		public MTSQLTest()
		{
		}

		[Test]
		public void TestMtsqlRefactor()
		{
			MetraTech.MTSQL.MTSQLMethod mtsql = new MTSQLMethod();
			String script = 
                "CREATE PROCEDURE f \n" + 
                "        @abc NVARCHAR \n" +
                "        @nm_space VARCHAR \n" +
                "        @nm_login_space NVARCHAR OUTPUT \n" +
                "AS \n" +
                "        SET @nm_login_space = @nm_space + \n" +
                "        'MyPrefix' + @nm_login";

            String output = "";

            try
            {
                output = mtsql.refactorRenameVariable(script,
                                                      "@nm_space",
                                                      "@sam");
                output = mtsql.refactorVarchar(output);
            }
            catch (Exception)
            {
                System.Console.WriteLine("I couldn't refactor the MTSQL.");
                return;
            }

            System.Console.WriteLine("Refactored MTSQL: \n" + output);
		}

		[Test, Explicit]
		[Category("JustThisOne")]
		public void TestTABLOCKX()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test2 @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"lock table t_account in exclusive mode; " +
				@"select id_acc into @var1 from  t_account a; " +
				@"end";

			mtsql.Execute();
		}

		[Test, Explicit]
		[Category("JustThisOne")]
		public void TestBatchTABLOCKX()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"create procedure test2 @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"lock table t_account in exclusive mode; " +
				@"select id_acc % 5 into @var1 from  t_account a " +
				@"INNER join t_po po on po.id_po = a.id_acc " +
				@"end";

			mtsql.Execute();
		}
		
		[Test]
		//[Category("JustThisOne")]
		public void TestModulo()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"select id_acc % 5 into @var1 from  t_account a " +
				@"INNER join t_po po on po.id_po = a.id_acc " +
				@"end";

			mtsql.Execute();
		}

		[Test]
		public void TestOracleJoinHint()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"select /* + USE_MERGE(a, po)  */ id_acc into @var1 from  t_account a " +
				@"INNER join t_po po on po.id_po = a.id_acc " +
				@"end";

			mtsql.Execute();
		}

		[Test]
		public void TestSwallowLockHint()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"select id_acc into @var1 from t_account a with(readcommitted) " +
				@"end";

			mtsql.Execute();
		}

		[Test]
		public void Test1()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
			@"as " +
			@"begin " +
			@"select id_acc into @var1 from t_account a " +
			@"end";
			mtsql.Execute();
		}
		[Test]
		public void TestSwallowJoinHint()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"select id_acc into @var1 from t_account a " +
				@"INNER HASH join t_po po on po.id_po = a.id_acc " +
				@"end";

			mtsql.Execute();
		}

		
		[Test]
		public void TestFORUPDATEHint()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"select id_acc into @var1 from t_account a FOR UPDATE  " +
				@"end";

			mtsql.Execute();
		}

		[Test]
		public void TestFORUPDATEOF1Hint()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"select id_acc into @var1 from t_account a FOR UPDATE OF id_acc " +
				@"end";

			mtsql.Execute();
		}

		[Test]
		public void TestFORUPDATEOF2Hint()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"create procedure test @var1 INTEGER OUTPUT " +
				@"as " +
				@"begin " +
				@"select id_acc into @var1 from t_account a FOR UPDATE OF a.id_acc " +
				@"end";

			mtsql.Execute();
		}


	}
	
}
