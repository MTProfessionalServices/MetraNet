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
	public class MTSQLSelectTestUnicode
	{
		
		public MTSQLSelectTestUnicode()
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
			/* Moved from selectTestUnicode.vbs */
		public void TestWideStringLiteral2()
		{
			ComInterpreterWrapper mtsql = new ComInterpreterWrapper();
			mtsql.Program = @"CREATE PROCEDURE TestWideStringLiteral @out1 NVARCHAR @out2 INTEGER " +
				@" AS "+
				@"SELECT N'スロヴェニア', id_desc  into @out1, @out2 from t_description where tx_desc = N'スロヴェニア' and id_lang_code= 392";
			
			mtsql.Execute();
			object out1 = mtsql.GetParam("out1");
			object out2 = mtsql.GetParam("out2");
			Assert.IsTrue(Utils.IsNull(out1) == false && ((string)out1 == "スロヴェニア"), 
				"Error with parameter out1 returned from TestWideStringLiteral2 procedure! Expected: \"スロヴェニア\"  actual='{0}'", new object[]{out1});
			Assert.IsTrue(Utils.IsNull(out2) == false && ((int)out2 == 204), 
				"Error with parameter out2 returned from TestWideStringLiteral2 procedure! Expected: '204' actual='{0}'", new object[]{out2});
		}


	
	}

	
}

