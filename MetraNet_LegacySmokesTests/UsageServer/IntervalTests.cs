
namespace MetraTech.UsageServer.Test
{
	using System.Runtime.InteropServices;
	using NUnit.Framework;
	using UsageServer;

	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class IntervalTests
	{
		/// <summary>
		/// Test creation of reference intervals.
		/// </summary>
		[Test]
		public void T01TestReferenceIntervals()
		{
			UsageIntervalManager manager = new UsageIntervalManager();
			manager.CreateReferenceIntervals();
		}

		/// <summary>
		/// Simple test of creation of usage intervals.
		/// </summary>
		[Test]
		public void T02TestAddUsageIntervals()
		{
			UsageIntervalManager manager = new UsageIntervalManager();
			manager.CreateUsageIntervals();
		}

		/// <summary>
		/// Simple test of closing usage intervals.
		/// </summary>
		[Test]
		public void T03TestCloseUsageIntervals()
		{
			// UsageIntervalManager manager = new UsageIntervalManager();
			// manager.SoftCloseUsageIntervals();
      BillingGroupManager manager = new BillingGroupManager();
      manager.SoftCloseBillingGroups(false);
		}
	}
}

