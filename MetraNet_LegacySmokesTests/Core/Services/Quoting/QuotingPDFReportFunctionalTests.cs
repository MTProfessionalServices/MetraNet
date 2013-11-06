using MetraTech.Core.Services.Quoting;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using TestContext = NUnit.Framework.TestContext;

namespace MetraTech.Core.Services.Test.Quoting
{
  [TestClass]
  public class QuotingPDFReportFunctionalTests
  {
    #region Setup/Teardown

    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {

    }

    #endregion

    /// <summary>
    /// 
    /// </summary>
    [TestMethod, MTFunctionalTest(TestAreas.Quoting)]
    public void LoadQuoteReportingConfiguration()
    {
      //Quoting Configuration is needed to initialize
      QuoteReportingConfiguration quoteReportingConfiguration = QuoteReportingConfigurationManager.LoadConfiguration(null);

      //TODO: Determine what values to check as they will be different on smoke test machine
      Assert.IsTrue(quoteReportingConfiguration.ReportingServerFolder.Contains("MetraNet"), "After loading configuration the ReportingServerFolder was expected to contain the word MetraNet");

      Assert.AreEqual("NetMeter", quoteReportingConfiguration.ReportingDatabaseName);
    } 

    ///// <summary>
    ///// 
    ///// </summary>
    //[TestMethod, MTFunctionalTest(TestAreas.Quoting)]
    //public void GeneratePDFForQuote()
    //{
    //  int IdQuote = 20;

    //  QuoteReportingConfiguration quoteReportingConfiguration = QuoteReportingConfigurationManager.LoadConfiguration(null);

    //  QuotePDFReport quotePDFReport = new QuotePDFReport(quoteReportingConfiguration);

    //  quotePDFReport.CreatePDFReport(IdQuote, 999, "Quote Report", 840);
    //} 

  }
}
