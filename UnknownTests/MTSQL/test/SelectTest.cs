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
	public class MTSQLSelectTest
	{
		
		public MTSQLSelectTest()
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
		public void TestSimpleSelect()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE simpleselect @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT b INTO @out FROM mtsqltest_1 WHERE a = @in";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			object res = mtsql.GetParam("out");
			Assert.IsInstanceOfType(typeof(System.Int32), res);
			Assert.AreEqual(2, res);
		}

		[Test]
		public void TestSimpleJoin()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE simplejoin @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT b INTO @out FROM mtsqltest_1 inner join mtsqltest_2 on mtsqltest_1.a = mtsqltest_2.a WHERE mtsqltest_2.a = @in";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			object res = mtsql.GetParam("out");
			Assert.IsInstanceOfType(typeof(System.Int32), res);
			Assert.AreEqual(2, res);
		}


		[Test]
		public void TestSimpleJoinWithQualifier()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE simplejoin @in INTEGER @out INTEGER " +
				@" AS "+
				@"SELECT mtsqltest_1.b INTO @out FROM mtsqltest_1 inner join mtsqltest_2 on mtsqltest_1.a = mtsqltest_2.a WHERE mtsqltest_2.a = @in";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			object res = mtsql.GetParam("out");
			Assert.IsInstanceOfType(typeof(System.Int32), res);
			Assert.AreEqual(2, res);
		}

		[Test]
		public void TestSimpleJoinWithQualifierMultipleSelectList()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE simplejoin @in INTEGER @out1 INTEGER @out2 INTEGER " +
				@" AS "+
				@"SELECT mtsqltest_1.b, mtsqltest_2.c INTO @out1, @out2 FROM mtsqltest_1 inner join mtsqltest_2 on mtsqltest_1.a = mtsqltest_2.a WHERE mtsqltest_2.a = @in";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out1");
			object out2 = mtsql.GetParam("out2");
			Assert.AreEqual(2, out1);
			Assert.AreEqual(4, out2);
		}

		[Test]
		public void TestSimpleJoinWithAliasMultipleSelectList()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE simplejoin @in INTEGER @out1 INTEGER @out2 INTEGER " +
				@" AS "+
				@"SELECT m1.b, m2.c INTO @out1, @out2 FROM mtsqltest_1 m1 inner join mtsqltest_2 m2 on m1.a = m2.a WHERE m2.a = @in";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out1");
			object out2 = mtsql.GetParam("out2");
			Assert.AreEqual(2, out1);
			Assert.AreEqual(4, out2);
		}

		[Test]
		public void TestJoinOldSyntax()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE simplejoin @in INTEGER @out1 INTEGER @out2 INTEGER " +
				@" AS "+
				@"SELECT mtsqltest_1.b, mtsqltest_2.c INTO @out1, @out2 FROM mtsqltest_1, mtsqltest_2  WHERE mtsqltest_2.a = @in and mtsqltest_1.a = mtsqltest_2.a";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out1");
			object out2 = mtsql.GetParam("out2");
			Assert.AreEqual(2, out1);
			Assert.AreEqual(4, out2);
		}

		[Test]
		public void TestSingleTableWithFunction()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE testsingletablewithfunction @in INTEGER @out1 INTEGER @out2 DOUBLE " +
				@" AS "+
				@"SELECT mtsqltest_1.b, floor(9.887E+002) INTO @out1, @out2 FROM mtsqltest_1 WHERE mtsqltest_1.a = @in";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out1");
			object out2 = mtsql.GetParam("out2");
			Assert.AreEqual(2, out1);
			Assert.AreEqual(988, out2);
		}

		[Test]
		public void TestSingleTableGroupBy()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE testsingletablegroupby @in INTEGER @out1 INTEGER @out2 INTEGER " +
				@" AS "+
				@"SELECT mtsqltest_1.a, SUM(mtsqltest_1.b) INTO @out1, @out2 FROM mtsqltest_1 WHERE mtsqltest_1.a = @in GROUP BY mtsqltest_1.a";

			mtsql.SetParam("in", 3);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out1");
			object out2 = mtsql.GetParam("out2");
			Assert.AreEqual(3, out1);
			Assert.AreEqual(7, out2);
		}

		[Test]
		public void TestBug6813()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = "CREATE PROCEDURE bug6813 @username VARCHAR @name_space VARCHAR @PBInterval INTEGER @id_acc INTEGER " +
			@" AS " +
			@"select id_interval, am.id_acc into @PBInterval, @id_acc " +
			@"from t_acc_usage_interval aui, t_usage_interval ui, t_account_mapper am " +
			@"where aui.id_usage_interval = ui.id_interval " +
			@"  and aui.id_acc = am.id_acc "   +
			@"  and am.nm_login = @username " +
			@"  and am.nm_space = @name_space " +
			@"  and ui.tx_interval_status = 'H' " +
			@"  order by ui.dt_end desc ";
		}

		[Test]
		public void TestDateParameter()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestDateParameter @in DATETIME @out INTEGER " +
				@" AS "+
				@"SELECT a INTO @out FROM mtsqltest_3 WHERE d = @in";

			mtsql.SetParam("in", DateTime.Parse("3/26/2002"));
			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual(2, out1);

			mtsql.Program = @"CREATE PROCEDURE TestDateParameter2 @in INTEGER @out DATETIME " +
				@" AS "+
				@"SELECT d INTO @out FROM mtsqltest_3 WHERE a = @in";

			mtsql.SetParam("in", 3);
			mtsql.Execute();
			out1 = mtsql.GetParam("out");
			Assert.AreEqual(DateTime.Parse("3/27/2002"), out1);

		}

		[Test]
		public void TestNullHandling()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestNullHandling @in DECIMAL @out INTEGER " +
				@" AS "+
				@"SELECT a INTO @out FROM mtsqltest_4 WHERE e = @in";

			mtsql.SetParam("in", 12.23);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual(1, out1);

			mtsql.Program = @"CREATE PROCEDURE TestNullHandling2 @in INTEGER @out DECIMAL " +
				@" AS "+
				@"SELECT e INTO @out FROM mtsqltest_4 WHERE a = @in";

			mtsql.SetParam("in", 2);
			mtsql.Execute();
			out1 = mtsql.GetParam("out");
			Assert.IsInstanceOfType(typeof(System.DBNull), out1);


			mtsql.SetParam("in", 1);
			mtsql.Execute();
			out1 = mtsql.GetParam("out");
			decimal dec = (decimal)out1;
			Assert.AreEqual(12.23, dec);

		}


		[Test]
		public void TestNestedSelect()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestNestedSelect @in VARCHAR @out INTEGER "+
				@" AS "+
				@"SELECT id_ancestor INTO @out " +
				@"FROM t_account_ancestor " +
				@"WHERE id_descendent = (SELECT id_acc FROM t_account_mapper WHERE nm_login = @in) " +
				@" AND " +
				@"num_generations = 1";

			mtsql.SetParam("in", "demo");
			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual(1, out1);

		}

		[Test]
		public void TestMultipleReferencesOfSameVariable()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestMultipleReferencesOfSameVariable @in INTEGER @out INTEGER "+
				@" AS "+
				@"SELECT id_cycle INTO @out FROM t_pc_interval WHERE id_interval = @in " +
				@"SELECT id_cycle INTO @out FROM t_pc_interval WHERE id_interval = @in";

			mtsql.SetParam("in", 718077954);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual(2, out1);

		}

		[Test]
		public void TestOrderByBug()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestOrderByBug @out INTEGER @out2 INTEGER "+
				@" AS "+
				@"SELECT id_interval INTO @out FROM t_pc_interval WHERE id_interval = 718077954 ORDER BY dt_start " +
				@"SELECT id_interval INTO @out2 FROM t_pc_interval WHERE id_interval = 718078030  ORDER BY dt_start";

			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual(718077954, out1);
			object out2 = mtsql.GetParam("out2");
			Assert.AreEqual(718078030, out2);

		}

		[Test]
		public void TestDistinct()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestDistinct @in INTEGER @out INTEGER "+
				@" AS "+
				@"SELECT DISTINCT a INTO @out FROM mtsqltest_1 WHERE b BETWEEN 3 AND @in";

			mtsql.SetParam("in", 4);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual(3, out1);

			mtsql.Program = @"CREATE PROCEDURE TestAll @in INTEGER @out INTEGER "+
				@" AS "+
				@"SELECT ALL a INTO @out FROM mtsqltest_1 WHERE b BETWEEN 3 AND @in";

			mtsql.SetParam("in", 4);
			mtsql.Execute();
			out1 = mtsql.GetParam("out");
			Assert.AreEqual(3, out1);


		}

		
		[Test]
		public void TestIntoLocalVariable()
		{
			IMTNameID nameID = new MTNameID();
			int enumid = nameID.GetNameID("metratech.com/accountcreation/InvoiceMethod/None");

			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestIntoLocalVariable @in INTEGER @enum ENUM @out VARCHAR "+
				@" AS "+
				@"DECLARE @local VARCHAR " +
				@"SELECT nm_enum_data INTO @local FROM t_av_internal INNER JOIN t_enum_data on c_InvoiceMethod=id_enum_data WHERE c_InvoiceMethod=@enum AND id_acc=@in " +
				@"SET @out = @local";


			mtsql.SetParam("in", 123);
			mtsql.SetParam("enum", enumid);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual("metratech.com/accountcreation/InvoiceMethod/None", out1);
		}

		[Test]
		public void TestLocalVariableReference()
		{
			IMTNameID nameID = new MTNameID();
			int enumid = nameID.GetNameID("metratech.com/accountcreation/InvoiceMethod/None");

			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestLocalVariableReference @in INTEGER @enum ENUM @out VARCHAR "+
				@" AS "+
				@"DECLARE @localin INTEGER " +
				@"DECLARE @localout VARCHAR " +
				@"SET @localin = @in " +
				@"SELECT nm_enum_data INTO @localout FROM t_av_internal INNER JOIN t_enum_data on c_InvoiceMethod=id_enum_data WHERE c_InvoiceMethod=@enum AND id_acc=@localin " +
				@"SET @out = @localout";


			mtsql.SetParam("in", 123);
			mtsql.SetParam("enum", enumid);
			mtsql.Execute();
			object out1 = mtsql.GetParam("out");
			Assert.AreEqual("metratech.com/accountcreation/InvoiceMethod/None", out1);
		}




		[Test]
		public void TestDecimalLiteral()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestDecimalLiteral @out INTEGER " +
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
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE MTSQLSelectDec  @StringType VARCHAR @FloatType DECIMAL " +
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
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE testsingletablegroupbywithhaving @out1 INTEGER @out2 INTEGER " +
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

	
	}

	
}

