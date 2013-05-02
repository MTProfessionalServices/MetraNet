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
using MetraTech.Interop.COMInterpreter;
using System.Reflection;
using MetraTech.Interop.NameID;



namespace MetraTech.MTSQL.Test
{
	/// <summary>
	/// Summary description for Test.
	/// </summary>
	[TestFixture]
	public class MTSQLBatchSelectTest
	{
		
		public MTSQLBatchSelectTest()
		{
		}

		[TestFixtureTearDown]
		public void CleanupTestData()
		{
			Setup.CleanupTestData();
		}
		
		[TestFixtureSetUp]
		public void SetupTestData()
		{
			Setup.SetupTestData();
		}

	
		[Test]
		public void TestSimpleBatchSelect()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE simpleselect @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT b INTO @out FROM mtsqltest_1 WHERE a = @in";
			mtsql.SetParam("in", 2);
			mtsql.PushRequest();
			mtsql.SetParam("in", 1);
			mtsql.Execute();

			mtsql.SetRequest(0);
			Assert.AreEqual(mtsql.GetParam("in"), 2);
		
		}
		
		[Test]
		public void TestBatchNestedSelect()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchNestedSelect @in VARCHAR @acc INTEGER  @parent INTEGER " +
				@" AS "+
				@"SELECT id_ancestor, id_descendent INTO @parent, @acc " +
				@"FROM t_account_ancestor " +
				@"WHERE id_descendent = (SELECT id_acc FROM t_account_mapper WHERE nm_login = @in)" +
				@"AND " +
				@"num_generations = 1";
				
			mtsql.SetParam("in", "demo");
			mtsql.PushRequest();
			mtsql.SetParam("in", "hanzel");
			mtsql.Execute();

			mtsql.SetRequest(0);
			object parent = mtsql.GetParam("parent");
			object acc = mtsql.GetParam("acc");
			Assert.IsTrue(Utils.IsNull(parent) || ((int)parent) == 1, "Expected parent = 1; got {0}", new object[]{parent});
			Assert.IsTrue(Utils.IsNull(acc) || ((int)acc) == 123, "Expected acc = 123; got {0}", new object[]{acc});
			mtsql.SetRequest(1);
			parent = mtsql.GetParam("parent");
			acc = mtsql.GetParam("acc");
			Assert.IsTrue(Utils.IsNull(parent) || ((int)parent) == 1, "Expected parent = 1; got {0}", new object[]{parent});
			Assert.IsTrue(Utils.IsNull(acc) || ((int)acc) == 124, "Expected acc = 124; got {0}", new object[]{acc});

			//mtsql.Cleanup();
		
		}

		[Test]
		public void TestBatchExists()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchExists @in VARCHAR @acc INTEGER  @parent INTEGER " +
				@" AS "+
				@"SELECT id_ancestor, id_descendent INTO @parent, @acc " +
				@"FROM t_account_ancestor " +
				@"WHERE EXISTS (SELECT * FROM t_account_mapper WHERE id_acc=id_descendent AND nm_login = @in) " +
				@"AND " +
				@"num_generations = 1";
				
			mtsql.SetParam("in", "demo");
			mtsql.PushRequest();
			mtsql.SetParam("in", "hanzel");
			mtsql.Execute();

			mtsql.SetRequest(0);
			object parent = mtsql.GetParam("parent");
			object acc = mtsql.GetParam("acc");
			Assert.IsTrue(Utils.IsNull(parent) || ((int)parent) == 1, "Expected parent = 1; got {0}", new object[]{parent});
			Assert.IsTrue(Utils.IsNull(acc) || ((int)acc) == 123, "Expected acc = 123; got {0}", new object[]{acc});
			mtsql.SetRequest(1);
			parent = mtsql.GetParam("parent");
			acc = mtsql.GetParam("acc");
			Assert.IsTrue(Utils.IsNull(parent) || ((int)parent) == 1, "Expected parent = 1; got {0}", new object[]{parent});
			Assert.IsTrue(Utils.IsNull(acc) || ((int)acc) == 124, "Expected acc = 124; got {0}", new object[]{acc});
		}

		[Test]
		public void TestBatchNotExists()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchNotExists @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT id_interval INTO @out FROM t_pc_interval WHERE NOT EXISTS (SELECT * FROM mtsqltest_6 WHERE a = @in) " +
				@" AND " +
				@"id_interval = @in ";
				
			mtsql.SetParam("in", 718077954);
			mtsql.PushRequest();
			mtsql.SetParam("in", 718340151);
			mtsql.Execute();


			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res), "Error looking up in TestBatchNotExists; expected=null, actual={0}", new object[]{res});
			
		}
		[Test]
		public void TestBatchInSubSelect()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchInSubSelect @in VARCHAR @acc INTEGER  @parent INTEGER " +
				@" AS "+
				@"SELECT id_ancestor, id_descendent INTO @parent, @acc " +
				@"FROM t_account_ancestor " +
				@"WHERE id_descendent IN (SELECT id_acc FROM t_account_mapper WHERE nm_login = @in) " +
				@"AND " +
				@"num_generations = 1";
				
			mtsql.SetParam("in", "demo");
			mtsql.PushRequest();
			mtsql.SetParam("in", "hanzel");
			mtsql.Execute();

			mtsql.SetRequest(0);
			object parent = mtsql.GetParam("parent");
			object acc = mtsql.GetParam("acc");
			//Assert.IsInstanceOfType(typeof(System.Int32), parent);
			//Assert.IsInstanceOfType(typeof(System.Int32), acc);
			Assert.AreEqual(1, parent);
			Assert.AreEqual(123, acc);
			mtsql.SetRequest(1);
			parent = mtsql.GetParam("parent");
			acc = mtsql.GetParam("acc");
			//Assert.IsInstanceOfType(typeof(System.Int32), parent);
			//Assert.IsInstanceOfType(typeof(System.Int32), acc);
			Assert.AreEqual(1, parent);
			Assert.AreEqual(124, acc);
			
		}
		[Test]
		public void TestBatchIn()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchIn @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT id_cycle INTO @out FROM t_pc_interval WHERE id_interval IN (718143490, (3*239424851 + 9), ABS(-3)) AND id_interval = @in";
				
			mtsql.SetParam("in", 718274562);
			mtsql.PushRequest();
			mtsql.SetParam("in", 718274665);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res) == 2, "Error looking up in TestBatchIn; expected=2, actual={0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res), "Error looking up in TestBatchIn; expected=null, actual={0}", new object[]{res});
			
		}
		[Test]
		public void TestBatchNotIn()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchIn @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT id_cycle INTO @out FROM t_pc_interval WHERE id_interval NOT IN (718143490, (3*239424851 + 9), ABS(-3)) AND id_interval = @in";
				
			mtsql.SetParam("in", 718274562);
			mtsql.PushRequest();
			mtsql.SetParam("in", 718274665);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res),"Error looking up in TestBatchNotIn; expected=null, actual={0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res) == 105, "Error looking up in TestBatchNotIn; expected=105, actual= {0}", new object[]{res});
			
		}

		[Test]
		public void TestBatchGroupBy()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchGroupBy @in VARCHAR @acc INTEGER  @count INTEGER @maxmin INTEGER " +
				@" AS "+
				@"SELECT count(*), id_descendent, max(distinct num_generations)+MIN(all num_generations) INTO @count, @acc, @maxmin " +
				@"FROM t_account_ancestor "  +
        @"INNER JOIN t_account_mapper ON id_descendent = id_acc "  +
        @"WHERE nm_login = @in " +
        @"GROUP BY id_descendent";
				
			mtsql.SetParam("in", "demo");
			mtsql.PushRequest();
			mtsql.SetParam("in", "hanzel");
			mtsql.Execute();


			mtsql.SetRequest(0);
			
			object acc = mtsql.GetParam("acc");
			object count = mtsql.GetParam("count");
			object maxmin = mtsql.GetParam("maxmin");

			Assert.IsTrue(Utils.IsNull(acc) || ((int)acc) == 123, "Expected acc = 123; got {0}", new object[]{acc});
			Assert.IsTrue(Utils.IsNull(count) || ((int)count) == 2, "Expected count = 2; got {0}", new object[]{count});
			Assert.IsTrue(Utils.IsNull(maxmin) || ((int)maxmin) == 1, "Expected maxmin = 1; got {0}", new object[]{maxmin});

			mtsql.SetRequest(1);

			acc = mtsql.GetParam("acc");
			count = mtsql.GetParam("count");
			maxmin = mtsql.GetParam("maxmin");

			Assert.IsTrue(Utils.IsNull(acc) || ((int)acc) == 124, "Expected acc = 124; got {0}", new object[]{acc});
			Assert.IsTrue(Utils.IsNull(count) || ((int)count) == 2, "Expected count = 2; got {0}", new object[]{count});
			Assert.IsTrue(Utils.IsNull(maxmin) || ((int)maxmin) == 1, "Expected maxmin = 1; got {0}", new object[]{maxmin});
			
			
		}

		[Test]
		public void TestBatchDerivedTable()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchDerivedTable @min INTEGER @max INTEGER @out DATETIME " +
				@" AS "+
				@"SELECT test3.d " +
				@"INTO @out  "  +
				@"FROM "  +
				@"mtsqltest_3 test3 " +
				@"INNER JOIN " +
				@"(SELECT COUNT(*) total FROM t_pc_interval WHERE id_interval BETWEEN @min AND @max and id_cycle=2) " +
				@"   foo ON foo.total = test3.a";
				
				
			mtsql.SetParam("min", 718077954);
			mtsql.SetParam("max", 718143490);
			mtsql.PushRequest();
			mtsql.SetParam("min", 718077954);
			mtsql.SetParam("max", 718209026);
			
			mtsql.Execute();


			mtsql.SetRequest(0);
			
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((DateTime)res) == DateTime.Parse("3/26/2002"), "Expected result = 3/26/2002; actual = {0}", new object[]{res});
			
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((DateTime)res) == DateTime.Parse("3/27/2002"), "Expected result = 3/27/2002; actual = {0}", new object[]{res});
			

		}
		[Test]
		public void TestBatchCase()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE simplecaseinselectlist @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT CASE WHEN b=1 THEN -1 ELSE b END INTO @out FROM mtsqltest_1 WHERE a = @in";
				
				
			mtsql.SetParam("in", 2);
			mtsql.PushRequest();
			mtsql.SetParam("in", 1);
			mtsql.Execute();


			mtsql.SetRequest(0);
			
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_1; expected 2, got {0}", new object[]{res});
			
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == -1, "Error looking up in mtsqltest_1; expected -1, got {0}", new object[]{res});

			mtsql.Query = @"CREATE PROCEDURE caseinselectlist @in INTEGER @out INTEGER " +
										@" AS " +
										@"SELECT CASE b WHEN 1 THEN -1 ELSE b END INTO @out FROM mtsqltest_1 WHERE a = @in";

			mtsql.SetParam("in", 2);
			mtsql.PushRequest();
			mtsql.SetParam("in", 1);
			mtsql.Execute();


			mtsql.SetRequest(0);
			
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_1; expected 2, got {0}", new object[]{res});
			
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == -1, "Error looking up in mtsqltest_1; expected -1, got {0}", new object[]{res});

			
			mtsql.Query = @"CREATE PROCEDURE caseinwhereclause @in INTEGER @out INTEGER " +
										@" AS " +
										@"SELECT b INTO @out FROM mtsqltest_1 WHERE a = CASE @in WHEN 10 THEN 1 WHEN 20 THEN 2 ELSE 0 END";

			mtsql.SetParam("in", 20);
			mtsql.PushRequest();
			mtsql.SetParam("in", 10);
			mtsql.Execute();

			mtsql.SetRequest(0);
			
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_1; expected 2, got {0}", new object[]{res});
			
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1, "Error looking up in mtsqltest_1; expected -1, got {0}", new object[]{res});

			

		}

		[Test]
		public void TestBatchLike()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE testlike @in VARCHAR @out INTEGER " +
				@" AS "+
				@"SELECT a INTO @out FROM mtsqltest_5 WHERE f LIKE @in OR f LIKE 'onethousand%'";
				
			mtsql.SetParam("in", "o%");
			mtsql.PushRequest();
			mtsql.SetParam("in", "tw%");
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1, "Error looking up in mtsqltest_5; expected 1, got {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_5; expected 2, got {0}", new object[]{res});
			
		}

		[Test]
		public void TestBatchNotLike()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchNotLike @in VARCHAR @out INTEGER " +
				@" AS "+
				@"SELECT a INTO @out FROM mtsqltest_5 WHERE f NOT LIKE @in";
				
			mtsql.SetParam("in", "t%");
			mtsql.PushRequest();
			mtsql.SetParam("in", "%e");
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1, "Error looking up in mtsqltest_5; expected 1, got {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_5; expected 2, got {0}", new object[]{res});
			
		}

		[Test]
		public void TestBatchUnion()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE testunion @in VARCHAR @out INTEGER " +
				@" AS "+
				@"SELECT a INTO @out FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=1" +
				@" UNION " +
				@"SELECT a INTO @out FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=0";
				
			mtsql.SetParam("in", "o%");
			mtsql.PushRequest();
			mtsql.SetParam("in", "tw%");
			mtsql.Execute();


			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1, "Error looking up in mtsqltest_5; expected 1, got {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_5; expected 2, got {0}", new object[]{res});

			//The INTO clause is not required on all of the queries in a UNION
			mtsql.Query = @"CREATE PROCEDURE testunion @in VARCHAR @out INTEGER " +
										@" AS " +
										@"SELECT a INTO @out FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=1 " +
										@" UNION " +
										@" SELECT a FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=0 ";
										
			mtsql.SetParam("in", "o%");
			mtsql.PushRequest();
			mtsql.SetParam("in", "tw%");
			mtsql.Execute();

			mtsql.SetRequest(0);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1, "Error looking up in mtsqltest_5; expected 1, got {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_5; expected 2, got {0}", new object[]{res});

			//BP: Error cases were moved into next 2 tests

			 mtsql.Query = @"CREATE PROCEDURE testunion @in VARCHAR @out INTEGER " +
									@" AS " +
									@" SELECT a INTO @out FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=1 " +
									@" UNION ALL " +
									@" SELECT a INTO @out FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=0 ";
									
			mtsql.SetParam("in", "o%");
			mtsql.PushRequest();
			mtsql.SetParam("in", "tw%");
			mtsql.Execute();

			mtsql.SetRequest(0);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1, "Error looking up in mtsqltest_5; expected 1, got {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_5; expected 2, got {0}", new object[]{res});


			
		}

		[Test]
		[ExpectedException(typeof(TargetInvocationException))]
		public void TestBatchUnionNoInto()
		{
			try
			{
				ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
				mtsql.Query = @"CREATE PROCEDURE testunion @in VARCHAR @out INTEGER " +
					@" AS "+
					@"SELECT a FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=1 " +
					@" UNION " +
					@"SELECT a FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=0 ";

			}
			catch(Exception e)
			{
				string msg = e.InnerException.Message;
				Assert.AreEqual("line 1: column 57: All SELECT statments must have an INTO\n", msg);
				throw;
			}
		}

		[Test]
		[ExpectedException(typeof(TargetInvocationException))]
		public void TestBatchUnionIntoNoIdentical()
		{
			try
			{
				ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
				mtsql.Query = @"CREATE PROCEDURE testunion @in VARCHAR @out INTEGER @out2 INTEGER " +
					@" AS "+
					@"SELECT a INTO @out FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=1" +
					@" UNION " +
					@"SELECT a INTO @out2 FROM mtsqltest_5 WHERE (f LIKE @in OR f LIKE 'onethousand%') AND a%2=0 ";
			}
			catch(Exception e)
			{
				string msg = e.InnerException.Message;
				StringAssert.Contains("All INTO clauses in a SELECT query must be identical", msg);
				throw;
			}
		}
		[Test]
		public void TestBatchTableHints()
		{
      ////FASTFIRSTROW functionality is discontinued in SQL Server 2012 and replaced with OPTION (FAST 1)
			//TestBatchTableHint("FASTFIRSTROW"); // FIRST_ROWS(1) "(select /*+ first_rows(1) */ from student;)" 
			TestBatchTableHint("HOLDLOCK"); /* FOR UPDATE OF */
			TestBatchTableHint("NOLOCK"); /* No Support on Oracle */
			TestBatchTableHint("PAGLOCK"); /* ?? */
			TestBatchTableHint("READCOMMITTED"); /* ?? */
			TestBatchTableHint("READPAST"); /* No Support on Oracle */
			TestBatchTableHint("READUNCOMMITTED"); /* No Support on Oracle */
			TestBatchTableHint("REPEATABLEREAD"); /* No Support on Oracle */
			TestBatchTableHint("ROWLOCK"); /* No Support on Oracle */
			TestBatchTableHint("SERIALIZABLE"); /* No Support on Oracle */
			TestBatchTableHint("TABLOCK"); /* No Support on Oracle */
			TestBatchTableHint("TABLOCKX"); /* LOCK TABLE */
			TestBatchTableHint("UPDLOCK"); /* No Support on Oracle */
			TestBatchTableHint("XLOCK"); /* No Support on Oracle */

			TestBatchTableHint("INDEX (time_pc_interval_index)"); /* Should be same on Oracle */
			TestBatchTableHint("INDEX (fk1idx_T_PC_INTERVAL, time_pc_interval_index)");
			TestBatchTableHint("INDEX (0)");
			TestBatchTableHint("INDEX (1, time_pc_interval_index)");

			// FORCE ORDER =  ORDERED (select /*+ ordered use_nl(bonus) parallel(e, 4) */...)
			
			
		}

		private void TestBatchTableHint(string aHint)
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE testhints @in INTEGER @out INTEGER " +
				@" AS "+
				string.Format(@"SELECT id_cycle INTO @out FROM t_pc_interval WITH ( {0} ) WHERE id_interval = @in ", aHint);

			mtsql.SetParam("in", 718077954);
			mtsql.PushRequest();
			mtsql.SetParam("in", 718078030);
			mtsql.Execute();


			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 2), "Error looking up in t_pc_interval; expected 2, got '{0}'", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 78), "Error looking up in t_pc_interval; expected 78, got '{0}'", new object[]{res});
		}

		[Test]
		public void TestBatchJoinHints()
		{
			TestBatchJoinHint("");
			TestBatchJoinHint("LOOP");
			TestBatchJoinHint("HASH");
			TestBatchJoinHint("MERGE");
			
		}


		private void TestBatchJoinHint(string aHint)
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE testhints @in INTEGER @out INTEGER " +
				@" AS "+
				string.Format(@"SELECT pci.id_interval INTO @out FROM t_usage_interval ui INNER {0}", aHint) +
				@" JOIN t_pc_interval pci ON pci.id_interval = ui.id_interval WHERE pci.id_interval = @in";

			mtsql.SetParam("in", 15000);
			mtsql.PushRequest();
			mtsql.SetParam("in", 20000);
			mtsql.Execute();
		}

		[Test]
		public void TestBatchIsNull()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE testisnull @in VARCHAR @out INTEGER " +
				@" AS "+
				@"SELECT CASE WHEN a IS NULL THEN 1000 ELSE a END INTO @out FROM mtsqltest_5 WHERE @in = f";

			mtsql.SetParam("in", "one");
			mtsql.PushRequest();
			mtsql.SetParam("in", "two");
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1, "Error looking up in mtsqltest_5; expected 1, got {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 2, "Error looking up in mtsqltest_5; expected 2, got {0}", new object[]{res});

			mtsql.Query = @"CREATE PROCEDURE testisnotnull @in VARCHAR @out INTEGER " +
				@" AS "+
				@"SELECT CASE WHEN a IS NOT NULL THEN 1000 ELSE a END INTO @out FROM mtsqltest_5 WHERE @in = f";

			mtsql.SetParam("in", "one");
			mtsql.PushRequest();
			mtsql.SetParam("in", "two");
			mtsql.Execute();

			mtsql.SetRequest(0);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1000, "Error looking up in mtsqltest_5; expected 1000, got {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 1000, "Error looking up in mtsqltest_5; expected 1000, got {0}", new object[]{res});
		}

		[Test]
		public void TestBatchImplicitGroupBys()
		{
			TestBatchImplicitGroupBy("COUNT(*)", 999, 1, 0);
			TestBatchImplicitGroupBy("SUM(id_cycle)", 192057, 1, 0);
			TestBatchImplicitGroupBy("AVG(id_cycle)", 192, 1, 0);
			TestBatchImplicitGroupBy("MAX(id_cycle)", 429, 1, 0);
			TestBatchImplicitGroupBy("MIN(id_cycle)", 2, 1, 0);

		}


		private void TestBatchImplicitGroupBy(string aggregateFunction, int out1, int out2Null, int out2)
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchImplicitGroupBy @in INTEGER @out INTEGER " +
				@" AS "+
				string.Format(@"SELECT {0} INTO @out FROM t_pc_interval WHERE id_interval < @in ", aggregateFunction);
				

			mtsql.SetParam("in", 721158511);
			mtsql.PushRequest();
			mtsql.SetParam("in", -1);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == out1, 
									"Incorrect count returned from TestBatchImplicitGroupBy procedure! expected = {0}, actual = {1}", new object[]{out1, res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			if(out2Null == 0)
			{
				Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 0, 
					"Incorrect count returned from TestBatchImplicitGroupBy procedure! expected = {0}, actual = {1}", new object[]{out2, res});
			
			}
			else
			{
				Assert.IsTrue(Utils.IsNull(res), "Incorrect count returned from TestBatchImplicitGroupBy procedure! expected=null, actual= {0}", new object[]{res});
			}
		}

		[Test]
		public void TestBatchNestedImplicitGroupBy()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchNestedImplicitGroupBy @in INTEGER @count INTEGER " +
				@" AS "+
				"SELECT total INTO @count FROM (SELECT COUNT(*) total FROM t_pc_interval WHERE id_interval < @in) intervals";
				

			mtsql.SetParam("in", 721158511);
			mtsql.PushRequest();
			mtsql.SetParam("in", -1);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("count");
			Assert.IsTrue(Utils.IsNull(res) == false && (int)res == 999, 
				"Incorrect count returned from TestBatchNestedImplicitGroupBy procedure! expected=999, actual= {0}", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("count");
			Assert.IsTrue(Utils.IsNull(res), "Incorrect count returned from TestBatchNestedImplicitGroupBy procedure! expected=null, actual= {0}", new object[]{res});
		}

		[Test]
		[Ignore("TODO: waiting on CR10840 to fully implement this test case")]
		public void TestBatchLogicalExpressions()
		{
			TestBatchLogicalExpression("= @in", 1, 2, 1, 1);
		}


		private void TestBatchLogicalExpression(string expr, int in1, int in2, int expected1, int expected2)
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchLogicalExpression @in INTEGER @out INTEGER " +
				@" AS "+
				string.Format(@"SELECT COUNT(*) INTO @out FROM t_pc_interval WHERE id_interval {0} GROUP BY id_request", expr);
			mtsql.SetParam("in", in1);
			mtsql.PushRequest();
			mtsql.SetParam("in", in2);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.AreEqual(expected1, res);
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.AreEqual(expected1, res);
		}

		[Test]
		public void TestBatchSemicolon()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchSemicolon @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT id_cycle INTO @out FROM t_pc_interval WHERE id_interval = @in;";
			mtsql.SetParam("in", 718077954);
			mtsql.PushRequest();
			mtsql.SetParam("in", 718078030);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 2), "Error looking up in t_pc_interval; expected 2, got '{0}'", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 78), "Error looking up in t_pc_interval; expected 78, got '{0}'", new object[]{res});
		}

		[Test]
		public void TestBatchBetween()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchBetween @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT id_interval INTO @out FROM t_pc_interval WHERE id_interval = @in AND id_cycle BETWEEN 1 AND 10";
			
			mtsql.SetParam("in", 718077954);
			mtsql.PushRequest();
			mtsql.SetParam("in", 718078030);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 718077954), "Error looking up in t_pc_interval; expected 718077954, actual= '{0}'", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res), "Error looking up in t_pc_interval; expected null, actual= '{0}'", new object[]{res});
		}

		[Test]
		public void TestBatchNotBetween()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestBatchNotBetween @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT id_interval INTO @out FROM t_pc_interval WHERE id_interval = @in AND id_cycle NOT BETWEEN 1 AND 10";
			
			mtsql.SetParam("in", 718077954);
			mtsql.PushRequest();
			mtsql.SetParam("in", 718078030);
			mtsql.Execute();

			mtsql.SetRequest(0);
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res), "Error looking up in t_pc_interval; expected null, actual= '{0}'", new object[]{res});
			mtsql.SetRequest(1);
			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 718078030), "Error looking up in t_pc_interval; expected 718078030, actual= '{0}'", new object[]{res});
		}

		[Test]
		[ExpectedException(typeof(TargetInvocationException))]
		public void TestOrderByBug2()
		{
			try
			{
				ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
				mtsql.Query = @"CREATE PROCEDURE TestOrderByBug2 @out INTEGER @out2 INTEGER " +
					@" AS "+
					@"SELECT id_interval INTO @out FROM t_pc_interval WHERE id_interval = 1 ORDER BY dt_start " +
					@"SELECT id_interval INTO @out2 FROM t_pc_interval WHERE id_interval = 2 ORDER BY dt_start";
			}
			catch(Exception e)
			{
				string msg = e.InnerException.Message;
				Assert.AreEqual("line 1: column 65: ORDER BY not supported in batch queries\n", msg);
				throw;
			}
		}

		[Test]
		public void TestDistinct()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestDistinct @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT DISTINCT a INTO @out FROM mtsqltest_1 WHERE b BETWEEN 3 AND @in";
			
			mtsql.SetParam("in", 4);
			mtsql.Execute();

			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 3), 
							"Invalid results returned from TestDistinct procedure! expected=3, actual='{0}'", new object[]{res});

			mtsql.Query = @"CREATE PROCEDURE TestAll @in INTEGER @out INTEGER "+
										@" AS " +
										@"SELECT ALL a INTO @out FROM mtsqltest_1 WHERE b BETWEEN 3 AND @in";

			mtsql.SetParam("in", 4);
			mtsql.Execute();

			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 3), 
				"Invalid results returned from TestDistinct procedure! expected=3, actual='{0}'", new object[]{res});

			 mtsql.Query = @"CREATE PROCEDURE TestNestedDistinct @in INTEGER @out INTEGER "+
										 @" AS "+
										 @" SELECT DISTINCT a INTO @out FROM mtsqltest_1 WHERE b IN (SELECT DISTINCT a FROM mtsqltest_2 WHERE c = @in)";

			mtsql.SetParam("in", 9);
			mtsql.Execute();

			res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 3), 
				"Invalid results returned from TestDistinct procedure! expected=3, actual='{0}'", new object[]{res});


		}

		[Test]
		public void TestEnumLiteral()
		{
			IMTNameID nameID = new MTNameID();
			int enumid = nameID.GetNameID("metratech.com/accountcreation/InvoiceMethod/None");
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestEnumLiteral @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT c_InvoiceMethod INTO @out FROM t_av_internal WHERE c_InvoiceMethod=#metratech.com/accountcreation/InvoiceMethod/None# AND id_acc=@in";
			
			mtsql.SetParam("in", 123);
			mtsql.Execute();

			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == enumid), 
				"Invalid results returned from TestEnumLiteral procedure! expected= '{0}'", new object[]{res});
		}

		[Test]
		public void TestEnumVariable()
		{
			IMTNameID nameID = new MTNameID();
			int enumid = nameID.GetNameID("metratech.com/accountcreation/InvoiceMethod/None");
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestEnumVariable @in INTEGER @enum ENUM @out NVARCHAR " +
				@" AS "+
				@"SELECT nm_enum_data INTO @out FROM t_av_internal INNER JOIN t_enum_data on c_InvoiceMethod=id_enum_data WHERE c_InvoiceMethod=@enum AND id_acc=@in";
			
			mtsql.SetParam("in", 123);
			mtsql.SetParam("enum", enumid);
			mtsql.Execute();

			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((string)res == "metratech.com/accountcreation/InvoiceMethod/None"), 
				"Invalid results returned from TestEnumLiteral procedure! expected='metratech.com/accountcreation/InvoiceMethod/None', actual = '{0}'", new object[]{res});
		}

		[Test]
		public void TestStringSelect()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestStringSelect @Comments VARCHAR @StringType NVARCHAR " +
				@" AS "+
				@"SELECT nm_space INTO @StringType FROM t_namespace WHERE tx_typ_space= @Comments ";
			
			mtsql.SetParam("Comments", "system_csr");
			mtsql.PushRequest();
			mtsql.SetParam("Comments", "system_mcm");
			mtsql.Execute();

			mtsql.SetRequest(0);
			object StringType = mtsql.GetParam("StringType");
			Assert.IsTrue(Utils.IsNull(StringType) == false && ((string)StringType == "csr"), 
				"Invalid results returned from TestStringSelect procedure! expected='csr', actual ='{0}'", new object[]{StringType});
			mtsql.SetRequest(1);
			StringType = mtsql.GetParam("StringType");
			Assert.IsTrue(Utils.IsNull(StringType) == false && ((string)StringType == "mcm"), 
				"Invalid results returned from TestStringSelect procedure! expected='mcm', actual ='{0}'", new object[]{StringType});

			//BP: Moved expected error case into the next test
		}

		[Test]
		[Category("JustThisOne")]
		[ExpectedException(typeof(TargetInvocationException))]
		public void TestStringSelect2()
		{
			try
			{
				ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
				mtsql.Query = @"CREATE PROCEDURE TestStringSelect @Comments VARCHAR @StringType VARCHAR " +
					@" AS "+
					@"SELECT nm_space INTO @StringType FROM t_namespace WHERE tx_typ_space= @Comments ";
			}
			catch(Exception e)
			{
				string msg = e.InnerException.Message;
				StringAssert.Contains("Type mismatch between MTSQL variable of type VARCHAR and resultset column 'nm_space'".ToLower(), msg.ToLower());
				throw;
			}
		}

		[Test]
		public void TestDecimalLiteral()
		{
			//BP: Moved Non Batch part of this test into SelectTest
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE TestDecimalLiteral @out INTEGER " +
				@" AS "+
				@"SELECT a INTO @out FROM mtsqltest_4 WHERE e = 12.23 ";
			
			mtsql.Execute();
			object res = mtsql.GetParam("out");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 1), 
				"Invalid results returned from TestDecimalLiteral procedure! expected=1, actual='{0}'", new object[]{res});
		}

		[Test]
		[Ignore("Commented out in VBS")]
		public void TestJuliaBug()
		{
			//BP: Moved Non Batch part of this test into SelectTest
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE MTSQLSelectDec  @StringType VARCHAR @FloatType DECIMAL " +
				@" AS "+
				@"SELECT min_amount INTO @FloatType FROM mtsql_product WHERE id_po IN (SELECT id_po FROM mtsql_order WHERE id_acc = (SELECT id_acc from mtsql_account where acc_name = @StringType))";

			mtsql.SetParam("StringType", "acc1");
			mtsql.Execute();
			object res = mtsql.GetParam("FloatType");
			Assert.IsTrue(Utils.IsNull(res) == false && ((float)res == 15.0), 
				"Invalid results returned from TestJuliaBug procedure! expected=15.0, actual='{0}'", new object[]{res});
		}

		[Test]
		public void TestSingleTableGroupByWithHaving()
		{
			//BP: Moved Non Batch part of this test into SelectTest
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE testsingletablegroupbywithhaving @out1 INTEGER @out2 INTEGER " +
				@" AS "+
				@"SELECT mtsqltest_1.a, SUM(mtsqltest_1.b) INTO @out1, @out2 FROM mtsqltest_1 GROUP BY mtsqltest_1.a HAVING SUM(mtsqltest_1.b) > 0 AND mtsqltest_1.a = 2";
			
			mtsql.Execute();
			object res = mtsql.GetParam("out1");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 2), 
				"Error with parameter out1 in single table group by! expected=2, actual='{0}'", new object[]{res});
			res = mtsql.GetParam("out2");
			Assert.IsTrue(Utils.IsNull(res) == false && ((int)res == 2), 
				"Error with parameter out2 in single table group by! expected=2, actual='{0}'", new object[]{res});
		}

		[Test]
		public void TestJuliaBug2()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Query = @"CREATE PROCEDURE MTSQLSelectDec  @StringType VARCHAR @WideStringType NVARCHAR " +
				@" AS "+
				@"SELECT nm_space INTO @WideStringType FROM t_namespace WHERE tx_desc=@StringType";
			
			mtsql.SetParam("StringType", "External System");
			mtsql.Execute();
			object res = mtsql.GetParam("WideStringType");
			Assert.IsTrue(Utils.IsNull(res) == false && ((string)res == "metratech.com/external"), 
				"Invalid results returned from TestJuliaBug2 procedure! expected='metratech.com/external', actual='{0}'", new object[]{res});
		}


		
	}


	public class ComInterpreterWrapper
	{

		private object disp;
		private Type type;

		public ComInterpreterWrapper()
		{
			type = Type.GetTypeFromProgID("ComInterpreter.ComMtsqlInterpreter");
			disp = Activator.CreateInstance(type);
		}

		public void Cleanup()
		{
			Marshal.ReleaseComObject(disp);
		}

		public string Query
		{
			set
			{
				IntPtr p = Marshal.GetIDispatchForObject(disp);
				object lpDispatch = new DispatchWrapper(p); 
				ArrayList arguments = new ArrayList();
				arguments.Add(value);
				object ret = type.InvokeMember("Query",
					System.Reflection.BindingFlags.PutDispProperty,
					null, disp, arguments.ToArray()); 
				return;
			
			}
		}
    
		public string Program
		{
			set
			{
				IntPtr p = Marshal.GetIDispatchForObject(disp);
				object lpDispatch = new DispatchWrapper(p); 
				ArrayList arguments = new ArrayList();
				arguments.Add(value);
				object ret = type.InvokeMember("Program",
					System.Reflection.BindingFlags.PutDispProperty,
					null, disp, arguments.ToArray()); 
				return;
			
			}
		}                                                                    

		public void SetParam(string name, object value)
		{
			IntPtr p = Marshal.GetIDispatchForObject(disp);
			object lpDispatch = new DispatchWrapper(p); 
			ArrayList arguments = new ArrayList();
			arguments.Add(value);
			object ret = type.InvokeMember(name,
				System.Reflection.BindingFlags.PutDispProperty,
				null, disp, arguments.ToArray()); 
			return;
		}

		public object GetParam(string name)
		{
			IntPtr p = Marshal.GetIDispatchForObject(disp);
			object lpDispatch = new DispatchWrapper(p); 
			object ret = type.InvokeMember(name,
				System.Reflection.BindingFlags.GetProperty,
				null, disp, null); 
			return ret;
		}

		public void PushRequest()
		{
			IntPtr p = Marshal.GetIDispatchForObject(disp);
			object lpDispatch = new DispatchWrapper(p); 
			ArrayList arguments = new ArrayList();
			object ret = type.InvokeMember("PushRequest",
				System.Reflection.BindingFlags.InvokeMethod,
				null, disp, null); 
			return;
		}

		public void SetRequest(int aRow)
		{
			IntPtr p = Marshal.GetIDispatchForObject(disp);
			object lpDispatch = new DispatchWrapper(p); 
			ArrayList arguments = new ArrayList();
			arguments.Add(aRow);
			object ret = type.InvokeMember("SetRequest",
				System.Reflection.BindingFlags.InvokeMethod,
				null, disp, arguments.ToArray()); 
			return;
		}

		public void Execute()
		{
			IntPtr p = Marshal.GetIDispatchForObject(disp);
			object lpDispatch = new DispatchWrapper(p); 
			ArrayList arguments = new ArrayList();
			object ret = type.InvokeMember("Execute",
				System.Reflection.BindingFlags.InvokeMethod,
				null, disp, null); 
			return;
		}


	}

	
}

