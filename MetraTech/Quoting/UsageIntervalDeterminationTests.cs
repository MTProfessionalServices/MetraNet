using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Shared.Test;

namespace MetraTech.Quoting.Test
{
   

  [TestClass]
  public class UsageIntervalDeterminationTests
  {
    
    #region Setup/Teardown

    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
    }

    #endregion

    [TestMethod]
    public void DetermineUsageIntervalForQuote()
    {
      #region Prepare
      string testShortName = "Q_DetInt"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      // Create account
      CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
      corpAccountHolder.Instantiate();

      Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
      int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;


      QuotingImplementation quotingImplementation = QuotingTestScenarios.GetDefaultQuotingImplementationForTestRun(new QuotingRepository());
      #endregion

      #region Test

      DateTime successfulEffectiveDate = MetraTime.Now;

      int idUsageInterval = quotingImplementation.GetUsageIntervalForQuote(successfulEffectiveDate, idAccountToQuoteFor);

      DateTime nonExistantEffectiveDate = successfulEffectiveDate.AddYears(10);
      string expectedErrorMessagePartialText = "Usage interval to use for quoting not found";

      try
      {
        int idNonExistantUsageInterval = quotingImplementation.GetUsageIntervalForQuote(nonExistantEffectiveDate, idAccountToQuoteFor);
        Assert.Fail("Although arbitrary, test expected that no usage interval would exist for the date of {0} and account id {1} and yet a usage interval was found {2}", nonExistantEffectiveDate, idAccountToQuoteFor, idNonExistantUsageInterval);

      }
      catch (Exception ex)
      {
        //Expected usage interval to not exist
        Assert.IsTrue(ex.Message.Contains(expectedErrorMessagePartialText), string.Format("Expected error message containing '{0}' but instead got exception: {1} ", expectedErrorMessagePartialText, ex.Message));
      }

      #endregion

    }

 

  }
}
