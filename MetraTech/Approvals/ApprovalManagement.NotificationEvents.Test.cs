using Microsoft.VisualStudio.TestTools.UnitTesting;

//using MetraTech.Security;

//using MetraTech.DomainModel.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
using MetraTech.DomainModel.BaseTypes;
using System.Collections.Generic;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.ApprovalManagementTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//
namespace MetraTech.Approvals.Test
{
  [TestClass]
  public class ApprovalNotificationEventsTest
  {

    private Logger m_Logger = new Logger("[ApprovalManagementTest]");

    #region tests

    [TestMethod]
    [TestCategory("SubmitApproveChangeNotification")]
    public void SubmitApproveChangeNotification()
    {
      string unitTestName = "SubmitUpdateApproveChangeScenario";

      //Turn on notifications in our test configuration
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["SampleUpdate"].Enabled = true; //SampleUpdate is usually enabled but best to make it explicit
      approvalsConfig["SampleUpdate"].NotifyOnSubmit.Enabled = true;
      approvalsConfig["SampleUpdate"].NotifyOnApproved.Enabled = true;

      ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation(approvalsConfig);

      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      Change myNewChange = new Change();
      myNewChange.ChangeType = "SampleUpdate";
      myNewChange.UniqueItemId = "1";

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["UpdatedValue"] = 1000;
      myNewChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      myNewChange.ItemDisplayName = "Sample Item 1";
      myNewChange.Comment = "Unit Test " + unitTestName + " on " + MetraTime.Now;

      int myChangeId;
      approvalFramework.SubmitChange(myNewChange, out myChangeId);

      //TODO: Check/Verify notification triggered

      //Login in as admin user and approve the change
      approvalFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanApproveSampleUpdate();

      approvalFramework.ApproveChange(myChangeId, "Approved by approval framework unit test");

      //TODO: Check/Verify notification triggered
    }

    #endregion

  }
}
