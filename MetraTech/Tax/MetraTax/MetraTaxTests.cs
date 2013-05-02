using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.MetraTax;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Text;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.DomainModel.Enums;

namespace MetraTech.Tax.MetraTax.Test
{
  //
  // To run the this test:
  // c:\dev\MetraNetDEV\Source\Thirdparty\NUnit260\bin\nunit-console-x86.exe /run:MetraTech.Tax.MetraTax.Test.MetraTaxTests o:\debug\Bin\MetraTech.Tax.MetraTax.Test.dll
  //
  // Set these environmental variables:
  //    TESTSYSTEM=v:\TestSystem  (or to the location where TestSystem exists)
  //    TESTORACLE=1              (set TESTORACLE to 1 if you want ORACLE rather than SQL server)
  //
  // To run ncover, prefix the above with:
  //    ncover //x ncoveroutput.xml
  // or
  //    ncover.console //x ncoveroutput.xml
  //
  // To produce a MetraTax price list, use a command like this:
  //     pcimportexport -epl "MetraTaxDefault" -file "c:\temp\junk.xml" -username admin -password Admin123

  [TestClass]
  //[ComVisible(false)]
  public class MetraTaxTests
  {
    private static Logger m_Logger = new Logger("[MetraTaxTests]");
    static string m_testDir = "t:\\Development\\Core\\Tax\\MetraTax\\";
    private bool m_isSqlServer = true;
    private string m_testSystem = "";

    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {
      // Load the test price list
      m_Logger.LogDebug(" ");
      m_Logger.LogDebug("---------------------------------------");
      m_Logger.LogDebug(" Initializing Test Set Up");
      m_Logger.LogDebug("---------------------------------------");
      m_Logger.LogDebug("Caution: before running tests, make sure you ");
      m_Logger.LogDebug("have deleted all TaxBand and TaxRate parameter tables.");
      m_Logger.LogDebug("Make sure you've set environmental variable TESTSYSTEM.\n\n");

      MetraTech.Tax.MetraTax.Test.MetraTaxTests mt =
        new MetraTaxTests();
      mt.RetrieveConfigurationParams();
      
      m_Logger.LogDebug("Location of unit test data: " + m_testDir);
      m_Logger.LogDebug("Creating MetraTax price list.");
      mt.ExecuteBatFile(m_testDir + "test1.bat");

      // Creating the input table
      m_Logger.LogDebug("Creating the input tax table.");
      SqlWizard.executeSqlInFile(m_testDir + "createInputTable" + mt.GetDbExtensionForSqlFile());

      m_Logger.LogDebug(" ");
      m_Logger.LogDebug(" ");
    }

    /// <summary>
    /// Retrieve m_testDir and m_isSqlServer from SystemDrive/sessionconfig.xml 
    /// </summary>
    private void RetrieveConfigurationParams()
    {
      // First read c:/sessionconfig.xml to find out where the "testSystem" directory is located.
      // 
      string systemDrive = Environment.GetEnvironmentVariable("SystemDrive");
      if (systemDrive == null)
      {
        systemDrive = "c:";
      }

      string sessionConfigFile = systemDrive + "\\sessionconfig.xml";

      try
      {
        XmlDocument sessionConfigDoc = new XmlDocument();
        sessionConfigDoc.Load(sessionConfigFile);
        XmlNode node = sessionConfigDoc.SelectSingleNode("SessionConfig/coreQA");

        if (node != null)
        {
          string testSystemDir = node.Attributes["testSystemPath"].Value;

          if ((testSystemDir == null) || (testSystemDir.Length == 0))
          {
            throw new Exception(string.Format("failed to find testSystemPath in {0}", sessionConfigFile));
          }

          m_testSystem = testSystemDir;
          m_testDir = testSystemDir + "\\UnitTestData\\Tax\\MetraTax\\";
        }
        else
        {
          throw new Exception(string.Format("failed to find SessionConfig/coreQA within {0}", sessionConfigFile));
        }

        node = sessionConfigDoc.SelectSingleNode("SessionConfig/MTDBConfig");
        if (node != null)
        {
          string databaseType = node.Attributes["type"].Value;

          if ((databaseType == null) || (databaseType.Length == 0))
          {
            throw new Exception(string.Format("failed to find databaseType in {0}", sessionConfigFile));
          }

          if (String.Compare(databaseType, "SQLServer", true) == 0)
          {
            m_isSqlServer = true;
          }
          else
          {
            m_isSqlServer = false;
          }
        }
        else
        {
          throw new Exception(string.Format("failed to find SessionConfig/MTDBConfig within {0}", sessionConfigFile));
        }
      }
      catch (Exception e)
      {
        throw e;
      }
    }

    private String GetDbExtensionForSqlFile()
    {
      if (m_isSqlServer)
        return ".sql";

      return ".oracle";
    }

    private String GetDbExtensionForExpectedFile()
    {
      if (m_isSqlServer)
        return ".txt";

      return ".oracle.txt";
    }

    private void TestPrintoutHeader(int testNo, string description)
    {
      // Load the test price list
      m_Logger.LogDebug(" ");
      m_Logger.LogDebug("------------------------------------");
      m_Logger.LogDebug(" Test " + testNo + " - " + description);
      m_Logger.LogDebug("------------------------------------");
    }

    private void StandardTest(int testNo, string description, TaxAccountView accountView, bool isAuditingNeeded)
    {
      try
      {
        // Load the test price list
        TestPrintoutHeader(testNo, description);

        // Create the tax manager
        m_Logger.LogDebug("Creating the MetraTax tax manager.");
        MetraTaxSyncTaxManagerDBBatch taxManager = new MetraTaxSyncTaxManagerDBBatch();
        taxManager.TaxRunId = 3;
        taxManager.TaxDetailsNeeded = true;
        taxManager.IsAuditingNeeded = isAuditingNeeded;

        // Clean up an prior runs
        m_Logger.LogDebug("Deleting any output tax tables from a prior run.");
        taxManager.ReverseTaxRun();

        // Populating the input table
        m_Logger.LogDebug("Populating the input tax table.");
        SqlWizard.executeSqlInFile(m_testDir + "test" + testNo + GetDbExtensionForSqlFile());

        // Create the account parameters
        TaxAccountViewReader accountViewReader = new TaxAccountViewReader();
        accountViewReader.SetAccountHeldInCache(accountView);

        // Calculate Taxes
        m_Logger.LogDebug("Calculating taxes.");
        taxManager.CalculateTaxes(accountViewReader);

        // Check the results
        m_Logger.LogDebug("Comparing calculated taxes to expected amounts.");
        string saw = SqlWizard.getSelectAsXml("select * from t_tax_output_3");

        if (!compareToExpected("test" + testNo + ".expected_tax_output" + GetDbExtensionForExpectedFile(), saw))
        {
          m_Logger.LogDebug("Fail");
          throw new TaxException("Tax output didn't match.");
        }

        m_Logger.LogDebug("Comparing calculated taxes details to expected details.");
        saw =
            SqlWizard.getSelectAsXml(
                "select id_tax_charge, tax_amount, rate, tax_jur_name, tax_type_name, is_implied " +
                "from t_tax_details where id_tax_run=3");

        if (!compareToExpected("test" + testNo + ".expected_tax_details" + GetDbExtensionForExpectedFile(), saw))
        {
          m_Logger.LogDebug("Fail");
          throw new TaxException("Tax output didn't match.");
        }
      }
      catch (Exception e)
      {
        m_Logger.LogDebug("An exception occurred: " + e.InnerException +
                      "StackTrace: " + e.StackTrace);
        throw e;
      }

      m_Logger.LogDebug("Done.");
      m_Logger.LogDebug(" ");
      m_Logger.LogDebug(" ");
    }

    /// <summary>
    /// Test - straight tax, no overrides
    /// </summary>
    [TestMethod]
    public void Test1()
    {
      m_Logger.LogDebug("XXXXX Test1");
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = false;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      StandardTest(1, "Straight Tax, No Overrides", view, true);
    }



    /// <summary>
    /// Test - straight tax, no overrides
    /// </summary>
    [TestMethod]
    public void Test2()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = false;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      StandardTest(2, "Implied Tax, No Overrides", view, true);
    }

    /// <summary>
    /// Test - exempt
    /// </summary>
    [TestMethod]
    public void Test3()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = true;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      StandardTest(3, "Exempt", view, true);
    }

    /// <summary>
    /// Test - override band
    /// </summary>
    [TestMethod]
    public void Test4()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = true;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Reduce1;

      StandardTest(4, "Override Tax Band", view, true);
    }

    /// <summary>
    /// Test - an account with missing configuration values
    /// </summary>
    [TestMethod]
    public void Test5()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = true;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = true;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Reduce1;

      try
      {
        StandardTest(5, "An Account With Missing Configuration Values", view, true);
      }
      catch (TaxException)
      {

        m_Logger.LogDebug("Done.");
        m_Logger.LogDebug(" ");
        m_Logger.LogDebug(" ");
        return;
      }

      // We shouldn't reach this point.
      Exception e = new Exception("MetraTax Test5 failed.");
      throw e;
    }

    /// <summary>
    /// Test - tax date is too early to fall into any tax rate schedule.
    /// </summary>
    [TestMethod]
    public void Test6()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = false;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      try
      {
        StandardTest(6, "Tax Date is too early for rate schedule", view, true);
      }
      catch (TaxException)
      {

        m_Logger.LogDebug("Done.");
        m_Logger.LogDebug(" ");
        m_Logger.LogDebug(" ");
        return;
      }

      // We shouldn't reach this point.
      Exception e = new Exception("MetraTax Test6 failed.");
      throw e;
    }

    /// <summary>
    /// Test - tax date is too late to fall into any tax rate schedule.
    /// </summary>
    [TestMethod]
    public void Test7()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = false;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      try
      {
        StandardTest(7, "Tax Date is too late for rate schedule", view, true);
      }
      catch (TaxException)
      {

        m_Logger.LogDebug("Done.");
        m_Logger.LogDebug(" ");
        m_Logger.LogDebug(" ");
        return;
      }

      // We shouldn't reach this point.
      Exception e = new Exception("MetraTax Test6 failed.");
      throw e;
    }

    /// <summary>
    /// Test - tax date is too late to fall into any tax rate schedule.
    /// </summary>
    [TestMethod]
    public void Test8()
    {
      TestPrintoutHeader(8, "Infrastructure: Multi-Value Dictionary");
      MultiValueDictionary<string, int> d;

      d = new MultiValueDictionary<string, int>();

      d.Add("apple", 1);

      if (!d.ContainsValue("apple", 1))
      {
        Exception e = new Exception("MetraTax Test8 ContainsValue failed.");
        throw e;
      }

      d.Remove("apple", 1);


      if (d.ContainsValue("apple", 1))
      {
        Exception e = new Exception("MetraTax Test8 Remove failed.");
        throw e;
      }

      d.Add("banana", 1);
      d.Add("banana", 2);

      HashSet<int> hashSet = d.GetValues("banana", true);
      if (hashSet.Count != 2)
      {
        Exception e = new Exception("MetraTax Test8 GetValues failed. Expect count to be 2 was " + hashSet.Count);
        throw e;
      }

      hashSet = d.GetValues("carrot", true);
      if (hashSet.Count != 0)
      {
        Exception e = new Exception("MetraTax Test8 GetValues failed. Expect count to be 0 was " + hashSet.Count);
        throw e;
      }

    }

    /// <summary>
    /// Test - Tax Account View Reader test.
    /// </summary>
    [TestMethod]
    public void Test9()
    {
      TestPrintoutHeader(9, "Infrastructure: TaxAccountViewReader");
      TaxAccountViewReader accountViewReader = new TaxAccountViewReader();
      accountViewReader.GetView(123);

      // This is an account that is always there.
      // We don't expect an exception to be thrown.
    }

    /// <summary>
    /// Test - straight tax, no overrides, no auditing
    /// </summary>
    [TestMethod]
    public void Test10()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = false;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      StandardTest(10, "Straight Tax, No Overrides, No Auditing", view, false);
    }

    /// <summary>
    /// Test11 - straight tax, no overrides, null product_code
    /// </summary>
    [TestMethod]
    public void Test11()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = false;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.Germany);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      StandardTest(11, "Straight Tax, No Overrides, Null ProductCode", view, true);
    }

    /// <summary>
    /// Test - implied tax, non-standard algorithm, no overrides
    /// </summary>
    [TestMethod]
    public void Test12()
    {
      TaxAccountView view = new TaxAccountView();
      view.AccountId = 123;
      view.IsNullHasMetraTaxOverride = false;
      view.IsNullMetraTaxCountry = false;
      view.IsNullMetraTaxCountryZone = false;
      view.IsNullMetraTaxOverrideTaxBand = false;
      view.IsNullVendor = false;
      view.HasMetraTaxOverride = false;
      view.MetraTaxCountryCode = (int)EnumHelper.GetDbValueByEnum(CountryName.France);
      view.MetraTaxCountryZone = TaxZone.DefaultZone;
      view.MetraTaxOverrideTaxBand = TaxBand.Exempt;

      StandardTest(12, "Implied Tax, Non-Standard algorithm, No Overrides", view, true);
    }

    private void ExecuteBatFile(string batFileName)
    {
      System.Diagnostics.Process proc = new System.Diagnostics.Process();
      proc.EnableRaisingEvents = false;
      proc.StartInfo.UseShellExecute = false;
      proc.StartInfo.EnvironmentVariables.Add("TESTSYSTEM", m_testSystem);
      proc.StartInfo.FileName = batFileName;
      proc.Start();
      proc.WaitForExit();

    }

    private String removeWhitespace(string inputString)
    {
      char[] charsToRemove = new char[] { '\r', '\t', '\n', ' ' };
      string[] results = inputString.Split(charsToRemove);
      StringBuilder transformedString = new StringBuilder();

      foreach (string s in results)
      {
        transformedString.Append(s);
      }

      return transformedString.ToString();
    }

    private bool compareToExpected(string expectedFile, string saw)
    {
      StreamReader reader = new StreamReader(m_testDir + expectedFile);
      string expected = "";
      while (reader.Peek() >= 0)
      {
        expected = expected + reader.ReadLine() + "\n";
      }

      string expected2 = removeWhitespace(expected);
      string saw2 = removeWhitespace(saw);

      if (saw2 == expected2)
      {
        return true;
      }

      m_Logger.LogDebug("Expected: " + expected);
      m_Logger.LogDebug("Saw: " + saw);
      return false;
    }

  }
}

