namespace MetraTech.UsageServer.Test
{
	using System;
	using System.Runtime.InteropServices;
	using System.Collections;
 	using NUnit.Framework;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.UsageServer.Test.ConfigurationTests /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class ConcurrentAdapterProcessingObjects 
	{
    const string mTestDir = @"t:\Development\Core\UsageServer\ConcurrentAdapters\";

		/// <summary>
		/// </summary>
		[Test]
		public void TestCreatingWorkResults()
		{
      WorkResults result1 = new WorkResults();
      result1.RecordFailure(RecurringEventAction.Execute);
      result1.RecordSuccess(RecurringEventAction.Execute);
      result1.RecordSuccess(RecurringEventAction.Execute);

      //Expect 3 Executions: 1 Failure and 2 Successes
      Assert.AreEqual(result1.Executions, 3);
      Assert.AreEqual(result1.ExecutionFailures, 1);
      Assert.AreEqual(result1.ExecutionSuccesses, 2);

      Assert.AreEqual(result1.Failures, 1);
      Assert.AreEqual(result1.Successes, 2);

      //No reversals yet
      Assert.AreEqual(result1.Reversals, 0);

      //Add 4 Reversal failures
      result1.RecordFailure(RecurringEventAction.Reverse);
      result1.RecordFailure(RecurringEventAction.Reverse);
      result1.RecordFailure(RecurringEventAction.Reverse);
      result1.RecordFailure(RecurringEventAction.Reverse);

      //Add 6 Reversal successes
      result1.RecordSuccess(RecurringEventAction.Reverse);
      result1.RecordSuccess(RecurringEventAction.Reverse);
      result1.RecordSuccess(RecurringEventAction.Reverse);
      result1.RecordSuccess(RecurringEventAction.Reverse);
      result1.RecordSuccess(RecurringEventAction.Reverse);
      result1.RecordSuccess(RecurringEventAction.Reverse);

      //Expect 3 Executions, 10 Reversals 5 Failures and 8 Successes
      Assert.AreEqual(result1.Executions, 3);
      Assert.AreEqual(result1.Reversals, 10);

      Assert.AreEqual(result1.Failures, 5);
      Assert.AreEqual(result1.Successes, 8);

      Assert.AreEqual(result1.ReversalFailures, 4);
      Assert.AreEqual(result1.ReversalSuccesses, 6);
      
      //Expect ExecutionSuccesses and ExecutionFailures have stayed the same
      Assert.AreEqual(result1.ExecutionFailures, 1);
      Assert.AreEqual(result1.ExecutionSuccesses, 2);

      //Create an additional work results using constructor and test adding
      WorkResults result2 = new WorkResults(100,200,400,800);

      WorkResults resultAdded = result1 + result2;

      //Expect 100+200+3=303 Executions, 400+800+10=1210 Reversals, 200+800+5=1005 Failures and 100+400+8=508 Successes
      Assert.AreEqual(resultAdded.Executions, 303);
      Assert.AreEqual(resultAdded.Reversals, 1210);
      Assert.AreEqual(resultAdded.Failures, 1005);
      Assert.AreEqual(resultAdded.Successes, 508);

      //Expect 100+2 ExecutionSuccesses, 200+1 ExecutionFailures
      Assert.AreEqual(resultAdded.ExecutionSuccesses, 102);
      Assert.AreEqual(resultAdded.ExecutionFailures, 201);
      
      //Expect 400+6=406 ReversalSuccesses, 800+4=804 ReversalFailures
      Assert.AreEqual(resultAdded.ReversalSuccesses, 406);
      Assert.AreEqual(resultAdded.ReversalFailures, 804);

      string temp = resultAdded.ToString();

		}


	}
}
