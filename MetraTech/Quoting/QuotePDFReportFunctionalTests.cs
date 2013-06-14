using System;
using System.Diagnostics;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Shared.Test;
using Core.Quoting;

namespace MetraTech.Quoting.Test
{
  [TestClass]
  public class QuotePDFReportFunctionalTests
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
    [TestMethod]
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
    //[TestMethod]
    //public void GeneratePDFForQuote()
    //{
    //  int idQuote = 20;

    //  QuoteReportingConfiguration quoteReportingConfiguration = QuoteReportingConfigurationManager.LoadConfiguration(null);

    //  QuotePDFReport quotePDFReport = new QuotePDFReport(quoteReportingConfiguration);

    //  quotePDFReport.CreatePDFReport(idQuote, 999, "Quote Report", 840);
    //} 

  }
}
