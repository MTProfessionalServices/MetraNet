// run with
// nunit-console.exe /assembly:BatchTest.dll

namespace MetraTech.Batch.Test
{
	using System;
	using NUnit.Framework;
	using MetraTech.Pipeline.Batch;
	using System.Web.Services.Protocols;
	using MetraTech.Interop.MTAuth;

  [Category("NoAutoRun")]
  [TestFixture]
  [Category("NoAutoRun")]
	public class BatchTest
	{
	  protected int ID;
	  protected string BatchName;
	  protected string Namespace;
	  protected string UID;

		[SetUp] public void Init()
		{
			ID = -1;
			BatchName = "";
			Namespace = "";
			UID = "";
		}

		[Test]
		public void TestMe()
		{
			// --------------------------------------------------------
			// new test really
			BatchObject batchobject = new BatchObject();

			batchobject.Name                = (System.Environment.TickCount).ToString();
			batchobject.Namespace           = "BatchTest";
			batchobject.Status              = "A";
			batchobject.SourceCreationDate  = System.DateTime.Now;
			batchobject.Source              = "Batch Test Program";
			batchobject.CompletedCount      = 10;
			batchobject.ExpectedCount       = 10;
			batchobject.SequenceNumber      = batchobject.Name;

			try
			{
				batchobject.Save();
			}
			catch (BatchException e)
			{
				Console.WriteLine("Creation of Batch Failed! {0}", e.Message);
				return;
			}

			DumpBatch(batchobject);

			UID = batchobject.UID;
			ID = batchobject.ID;
			BatchName = batchobject.Name;  
			Namespace = batchobject.Namespace;  

			// --------------------------------------------------------
			// new test really
			BatchObject batch_loadbyname = new BatchObject();
			try
			{
				batch_loadbyname.LoadByName (BatchName, Namespace, BatchName);
			}
			catch (BatchException e)
			{
				Console.WriteLine("Load By Name Failed!", e.ToString());
				return;
			}

			DumpBatch (batchobject);
			
			// --------------------------------------------------------
			// new test really
			BatchObject batch_loadbyUID = new BatchObject();
			try
			{
				batch_loadbyUID.LoadByUID (UID);
			}
			catch (BatchException e)
			{
				Console.WriteLine("Load By UID Failed!", e.ToString());
				return;;
			}

			// --------------------------------------------------------
			// new test really
			BatchObject batch_markasfailed = new BatchObject();
			batch_markasfailed.LoadByUID(UID);
			batch_markasfailed.SetSessionContext(GetSessionContext());
			batch_markasfailed.Status = "F";

			try 
			{
				batch_markasfailed.MarkAsFailed(UID, "Marking it failed");
			}
			catch (BatchException e)
			{
				Console.WriteLine("Mark As Failed Failed!", e.ToString());
				return;;
			}

			// verify
			BatchObject newbatch_markasfailed = new BatchObject();
  		newbatch_markasfailed.LoadByUID(UID);
			if (newbatch_markasfailed.Status == "F")
				Console.WriteLine("Mark As Failed succeeded!");
			else
				Console.WriteLine("Mark As Failed failed!");

			// --------------------------------------------------------
			// new test really
			BatchObject batch_markascompleted = new BatchObject();
			batch_markascompleted.LoadByUID(UID);
			batch_markascompleted.SetSessionContext(GetSessionContext());
			batch_markascompleted.Status = "C";

			try
			{
				batch_markascompleted.MarkAsCompleted(UID, "Marking it completed");
			}
			catch (BatchException e)
			{
				Console.WriteLine("Mark As Completed Failed!", e.ToString());
				return;;
			}

			// verify
			BatchObject newbatch_markascompleted = new BatchObject();
  		newbatch_markascompleted.LoadByUID(UID);
			if (newbatch_markascompleted.Status == "C")
				Console.WriteLine("Mark As Completed succeeded!");
			else
				Console.WriteLine("Mark As Completed failed!");

			// --------------------------------------------------------
			// new test really
			BatchObject batch_markasfailed2 = new BatchObject();
			batch_markasfailed2.LoadByUID(UID);
			batch_markasfailed2.SetSessionContext(GetSessionContext());
			batch_markasfailed2.Status = "F";

			try 
			{
				batch_markasfailed2.MarkAsFailed(UID, "Marking it failed again");
			}
			catch (BatchException e)
			{
				Console.WriteLine("Mark As Failed Failed!", e.ToString());
				return;;
			}

			// verify
			BatchObject newbatch_markasfailed2 = new BatchObject();
  		newbatch_markasfailed2.LoadByUID(UID);
			if (newbatch_markasfailed2.Status == "F")
				Console.WriteLine("Mark As Failed succeeded!");
			else
				Console.WriteLine("Mark As Failed failed!");

			// --------------------------------------------------------
			// new test really
			BatchObject batch_markasbackout = new BatchObject();
			batch_markasbackout.LoadByUID(UID);
			batch_markasbackout.SetSessionContext(GetSessionContext());
			batch_markasbackout.Status = "B";

			try
			{
				batch_markasbackout.MarkAsBackout(UID, "Marking it Backout");
			}
			catch (BatchException e)
			{
				Console.WriteLine("Mark As Backout Failed!", e.ToString());
				return;;
			}

			// verify
			BatchObject newbatch_markasbackout = new BatchObject();
  		newbatch_markasbackout.LoadByUID(UID);
			if (newbatch_markasbackout.Status == "B")
				Console.WriteLine("Mark As Backout succeeded!");
			else
				Console.WriteLine("Mark As Backout failed!");

			// --------------------------------------------------------
			// new test really
			BatchObject batch_markasdismissed = new BatchObject();
			batch_markasdismissed.LoadByUID(UID);
			batch_markasdismissed.SetSessionContext(GetSessionContext());
			batch_markasdismissed.Status = "D";

			try
			{
				batch_markasdismissed.MarkAsDismissed(UID, "Marking it Dismissed");
			}
			catch (BatchException e)
			{
				Console.WriteLine("Mark As Dismissed Failed!", e.ToString());
				return;;
			}

			// verify
			BatchObject newbatch_markasdismissed = new BatchObject();
  		newbatch_markasdismissed.LoadByUID(UID);
			if (newbatch_markasdismissed.Status == "D")
				Console.WriteLine("Mark As Dismissed succeeded!");
			else
				Console.WriteLine("Mark As Dismissed failed!");

			// --------------------------------------------------------
			// new test really
			BatchObject batch_updatemeteredcount = new BatchObject();
			batch_updatemeteredcount.LoadByUID(UID);

			try
			{
				batch_updatemeteredcount.UpdateMeteredCount(UID, 95);
			}
			catch (BatchException e)
			{
				Console.WriteLine("Update Metered Count Failed!", e.ToString());
				return;
			}

			// verify
			BatchObject newbatch_updatemeteredcount = new BatchObject();
  		newbatch_updatemeteredcount.LoadByUID(UID);
			if (newbatch_updatemeteredcount.Status == "D")
				Console.WriteLine("Update Metered Count succeeded!");
			else
				Console.WriteLine("Update Metered Count failed!");

			return;
		}

		protected void DumpBatch(BatchObject batchobject)
		{
			Console.WriteLine("---------------------------------------");
			Console.WriteLine("Batch ID = {0}", batchobject.ID);
			Console.WriteLine("Batch UID Encoded = {0}", batchobject.UID);
			Console.WriteLine("Name = {0}", batchobject.Name);
			Console.WriteLine("Namespace = {0}", batchobject.Namespace);
			Console.WriteLine("Status = {0}", batchobject.Status);
			Console.WriteLine("Creation Date = {0}", batchobject.CreationDate);
			Console.WriteLine("Source = {0}", batchobject.Source);
			Console.WriteLine("Sequence # = {0}", batchobject.SequenceNumber);
			Console.WriteLine("Completed Count = {0}", batchobject.CompletedCount);
			Console.WriteLine("Expected Count = {0}", batchobject.ExpectedCount);
			Console.WriteLine("Failure Count = {0}", batchobject.FailureCount);
			Console.WriteLine("---------------------------------------");

			return;
		}
		
		private MetraTech.Interop.MTAuth.MTSessionContext GetSessionContext()
		{
			MTLoginContext login = new MTLoginContext();
			MetraTech.Interop.MTAuth.MTSessionContext context =
				(MetraTech.Interop.MTAuth.MTSessionContext) login.Login("su", "system_user", "su123");
			return context;
		}
	}
}
