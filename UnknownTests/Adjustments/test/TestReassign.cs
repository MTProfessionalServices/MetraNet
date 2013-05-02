using System;
using System.Runtime.InteropServices;
using System.Collections;
using NUnit.Framework;
using MetraTech.Test;
using MetraTech.Adjustments;
using PC=MetraTech.Interop.MTProductCatalog;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using MetraTech.Interop.Rowset;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.DataAccess;

namespace MetraTech.Adjustments.test
{
	/// <summary>
	/// Summary description for Test.
	/// </summary>
	[TestFixture]
	public class ReassignTest
	{

		private PC.MTProductCatalog mPC;
		private AdjustmentCatalog mAC ;
		private PC.IMTSessionContext mCtx;
		 

		public ReassignTest()
		{
			mPC = new PC.MTProductCatalogClass();
			mAC = new AdjustmentCatalog();
			Auth.IMTLoginContext logincontext = new Auth.MTLoginContextClass();
			mCtx = (PC.IMTSessionContext) logincontext.Login( "su", "system_user", "su123");
			mAC.Initialize(mCtx);
			mPC.SetSessionContext(mCtx);
			MetraTech.Test.Common.Utils.TurnTraceOn();
		}

		[Test]
		public void TestBulkReassign()
		{
			PC.IMTCollection sessions = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
			sessions.Add(10000);
			sessions.Add(10011);
			sessions.Add(10022);
			sessions.Add(10033);
			sessions.Add(10044);
			sessions.Add(10055);
			IRebillTransactionSet trxset = mAC.CreateRebillTransactions(sessions);
			Assert.AreEqual(6, trxset.Count, "Number of input session ids has to match the output collection count");
			IMTRowSet errors = trxset.Save(null);
			DumpErrorRowset(errors);
		}

		[Test]
		public void TestIndividualReassign()
		{
			IRebillTransaction trx = mAC.CreateRebillTransaction(10000);
			trx.AccountID = 206;
			IMTRowSet errors = trx.Save(null);
			DumpErrorRowset(errors);
			Assert.AreEqual(0, errors.RecordCount, "there should not be any warnings returned from individual reassign operation");
		}

		public static void DumpErrorRowset(IMTRowSet rowset)
		{
			bool atleastone = false;
			while(System.Convert.ToBoolean(rowset.EOF) == false)
			{
				atleastone = true;
				object sess  = rowset.get_Value("id_sess");
				string description  = (string)rowset.get_Value("description");
				string msg = string.Format("Error Rowset Row: id_sess: {0}, Description: {1}", sess, description); 

				MetraTech.Test.Common.Utils.Trace(msg);

				rowset.MoveNext();
			}
			if(atleastone)
				rowset.MoveFirst();
		}
				
	}
}
