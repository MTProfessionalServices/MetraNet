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
	public class ConcurrentAdapterConfiguration 
	{
    const string mTestDir = @"t:\Development\Core\UsageServer\ConcurrentAdapters\";

		/// <summary>
		/// </summary>
		[Test]
		public void TestLoadingMachineRules()
		{
			MachineRules rules = new MachineRules();
      rules.ReadMachineRulesFromFile(mTestDir + "recurring_events_MachineRules.xml");

      if (rules.Count==0)
        Assert.Fail("Unable to load machine rules");
		}

    /// <summary>
    /// </summary>
    [Test]
    public void TestLoadingMachineRulesWithDefaultRule()
    {
      MachineRules rules = new MachineRules();
      rules.ReadMachineRulesFromFile(mTestDir + "recurring_events_MachineRulesWithDefault.xml");

      if (rules.Count == 0)
        Assert.Fail("Unable to load machine rules");

      if (rules.DefaultRule.MachineSpecifier != "Primary Billing Server")
        Assert.Fail("Unable to read default rule");

    }

    /// <summary>
    /// </summary>
    [Test]
    public void TestLoadingMachineRulesIntoDatabase()
    {
      MachineRules rules = new MachineRules();
      rules.ReadMachineRulesFromFile(mTestDir + "recurring_events_MachineRules.xml");

      if (rules.Count == 0)
        Assert.Fail("Unable to load machine rules");

      //MachineRuleManager manager 
    }


    /// <summary>
    /// </summary>
    [Test]
    public void TestLoadingConcurrencyRules()
    {
      ConcurrencyRules rules = new ConcurrencyRules();
      rules.ReadConcurrencyRulesFromFile(mTestDir + "recurring_events_ConcurrencyRules.xml");
      //rules.ReadMachineRulesFromFile(mTestDir + "recurring_events_MachineRules.xml");

      if (rules.Count == 0)
        Assert.Fail("Unable to load concurrency rules");
    }

    /// <summary>
    /// </summary>
    [Test]
    public void TestLoadingProcessingConfigFromProduct()
    {
      ProcessingConfig processConfig = ProcessingConfigManager.LoadFromFile();

      if (processConfig == null)
        Assert.Fail("Unable to load processing config");

    }
	}
}
