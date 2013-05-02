namespace MetraTech.UsageServer.Test
{
	using System;
	using System.Runtime.InteropServices;
	using System.Collections;
 	using NUnit.Framework;

  using MetraTech.UsageServer.Service;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.UsageServer.Test.ConfigurationTests /assembly:O:\debug\bin\MetraTech.UsageServer.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class ConcurrentAdapterProcessingServiceTrackingTests 
	{
    const string mTestDir = @"t:\Development\Core\UsageServer\ConcurrentAdapters\";

    const string mMachineIdentifierToUseForSmokeTest = "vmSmokeTest";

		/// <summary>
		/// </summary>
		[Test]
		public void TestServiceTrackingStartingAndStopping()
		{
      string machineIdentifierForTest = mMachineIdentifierToUseForSmokeTest + "01";
      BillingServerServiceTracking serviceTracker = new BillingServerServiceTracking(machineIdentifierForTest);

      try
      {
        serviceTracker.RecordStart();
      }
      catch (ServiceTrackingException)
      {
        //Already online, call repair and try again
        serviceTracker.Repair();
        serviceTracker.RecordStart();
      }

      //Verify it is online

      serviceTracker.RecordStop();

		}

    /// <summary>
    /// </summary>
    [Test]
    public void TestServiceTrackingVerifyOnlineCheckingAndRepair()
    {
      string machineIdentifierForTest = mMachineIdentifierToUseForSmokeTest + "02";
      BillingServerServiceTracking serviceTracker1 = new BillingServerServiceTracking(machineIdentifierForTest);

      try
      {
        serviceTracker1.RecordStart();
      }
      catch (ServiceTrackingException)
      {
        //Already online, call repair and try again
        serviceTracker1.Repair();
        serviceTracker1.RecordStart();
      }

      BillingServerServiceTracking serviceTracker2 = new BillingServerServiceTracking(machineIdentifierForTest);
      bool gotExceptionThatThisMachineIsAlreadyOnline = false;
      try
      {
        serviceTracker2.RecordStart();
      }
      catch (ServiceTrackingException)
      {
        gotExceptionThatThisMachineIsAlreadyOnline = true;
      }

      Assert.IsTrue(gotExceptionThatThisMachineIsAlreadyOnline, "Didn't get an exception when trying to start tracking the same server twice");

      serviceTracker2.Repair();
      try
      {
        serviceTracker2.RecordStart();
      }
      catch (ServiceTrackingException)
      {
        Assert.Fail("RecordStart() failed after Repair() was called. Repair() is broken.");
      }
      
      //Verify it is online
      
      //Clean up
      serviceTracker1.RecordStop();

    }

	}
}
