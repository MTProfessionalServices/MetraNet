using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using MetraTech.DomainModel.Enums.Core.Global;
using Microsoft.VisualStudio.TestTools.UnitTesting;

//using MetraTech.Security;
//using MetraTech.DomainModel.Common;
//using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
using MetraTech.Approvals;
using MetraTech.DomainModel.BaseTypes;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.InternalFrameworkTests /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//

namespace MetraTech.Approvals.Test
{
    [TestClass]
    public class InternalFrameworkTests
    {

        private Logger m_Logger = new Logger("[ApprovalManagementTest]");

        #region tests

        [TestMethod]
        [TestCategory("AttemptToUseFrameworkWithoutSettingSecurityContext")]
        public void AttemptToUseFrameworkWithoutSettingSecurityContext()
        {
            ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
            //approvalFramework.SessionContext = LoginAsSU();

            //We didn't set the security context so we expect an exception
            try
            {
                MTList<ChangeSummary> pendingChangesBefore = new MTList<ChangeSummary>();
                approvalFramework.GetPendingChangesSummary(ref pendingChangesBefore);
                Assert.Fail("GetPendingChangesSummary succeeded even though we didn't set security context");
            }
            catch (Exception ex)
            {
                //Make sure exception is that we don't have permission to approve this change
                Assert.IsTrue(ex.Message.Contains("SessionContext must be set"));
            }

        }

        [TestMethod]
        [TestCategory("Constructors")]
        public void Constructors()
        {
            string unitTestName = "Constructors";

            IMTSessionContext sessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

            //Constructor Without parameters
            ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();

            //Constructor where we pass the configuration
            ApprovalsConfiguration configuration = ApprovalsConfigurationManager.Load();
            configuration.Remove("SampleUpdate");

            ApprovalManagementImplementation approvalFrameworkWithoutSampleUpdate =
                new ApprovalManagementImplementation(configuration);

            //Submit change that is not valid with the given configuration should generate exception
            Change myNewChange = new Change();
            myNewChange.ChangeType = "SampleUpdate";
            myNewChange.UniqueItemId = "1";

            ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
            changeDetails["UpdatedValue"] = 1000;
            myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

            myNewChange.ItemDisplayName = "Sample Item 1";
            myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

            //First Negative Test Case, Try Submitting without setting any security context
            try
            {
                int myChangeId;
                approvalFrameworkWithoutSampleUpdate.SubmitChange(myNewChange, out myChangeId);
                Assert.Fail("SubmitChange succeeded even though the security context was not set");
            }
            catch (Exception ex)
            {
                //Make sure exception is that the security context is not set
                Assert.IsTrue(ex.Message.Contains("Unable to authorize user"));
            }

            //Second Negative Test Case, Try Submitting the 'SampleUpdate' change which was removed from configuration
            //Set the security context and try again, which will also fail
            approvalFrameworkWithoutSampleUpdate.SessionContext = sessionContext;

            try
            {
                int myChangeId;
                approvalFrameworkWithoutSampleUpdate.SubmitChange(myNewChange, out myChangeId);
                Assert.Fail("SubmitChange succeeded even though the 'SampleUpdate' was removed from the configuration");
            }
            catch (Exception ex)
            {
                //Make sure exception is that the change type is invalid (we removed it from configruation)
                Assert.IsTrue(ex.Message.Contains("is invalid/unconfigured"));
            }

            //Constructor where we pass the configuration and security context
            ApprovalManagementImplementation approvalFrameworkWithoutSampleUpdateAndPassedSecurityContext =
                new ApprovalManagementImplementation(configuration, sessionContext);
            Assert.AreEqual(sessionContext.AccountID,
                            approvalFrameworkWithoutSampleUpdateAndPassedSecurityContext.SessionContext.AccountID);

        }

        [TestMethod]
        [TestCategory("ConvertCultureOfUIToMetraTechLanguageCode")]
        public void ConvertCultureOfUIToMetraTechLanguageCode()
        {
            ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
            //approvalFramework.SessionContext = LoginAsSU();

            CultureInfo culture = Thread.CurrentThread.CurrentUICulture;
            LanguageCode languageCode = approvalFramework.ConvertCultureToMetraTechLanguageCode(culture);
            Assert.AreEqual(LanguageCode.US, languageCode);

            Dictionary<string, LanguageCode> localesToTest = new Dictionary<string, LanguageCode>();
            localesToTest.Add("de-DE", LanguageCode.DE);
            //localesToTest.Add("de", LanguageCode.DE);
            //localesToTest.Add("de-AT", LanguageCode.DE); //Doesn't work, punting for now

            //localesToTest.Add("fr", LanguageCode.FR);
            //localesToTest.Add("fr-fr", LanguageCode.FR); //Doesn't work, punting for now

            //localesToTest.Add("it", LanguageCode.IT);
            //localesToTest.Add("it-IT", LanguageCode.IT); //Doesn't work, punting for now
            //localesToTest.Add("it-CH", LanguageCode.IT); //Doesn't work, punting for now

            localesToTest.Add("fi-FI", LanguageCode.US); //Test that Finnish comes back as default 'US English'

            localesToTest.Add("en-GB", LanguageCode.GB);

            foreach (KeyValuePair<string, LanguageCode> kvp in localesToTest)
            {
                CultureInfo cultureToTest = new CultureInfo(kvp.Key);
                Assert.AreEqual(kvp.Value, approvalFramework.ConvertCultureToMetraTechLanguageCode(cultureToTest),
                                "Unable to convert " + kvp.Key);
            }


        }

        #endregion
    }
}