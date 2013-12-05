
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
		/// Simple test of creation of usage intervals.
		/// </summary>
		[Test]
		public void T01TestAddUsageIntervals()
		{
			var manager = new UsageIntervalManager();
			manager.CreateUsageIntervals();
		}

		/// <summary>
		/// Simple test of closing usage intervals.
		/// </summary>
		[Test]
		public void T02TestCloseUsageIntervals()
		{
			// UsageIntervalManager manager = new UsageIntervalManager();
			// manager.SoftCloseUsageIntervals();
      var manager = new BillingGroupManager();
      manager.SoftCloseBillingGroups(false);
		}
	}
}

