using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using MetraTech.Security;
using MetraTech;
//using MetraTech.Test.Common;
using MetraTech.DomainModel.Common;
using MetraTech.Core.Services;
using System.Runtime.Serialization;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using System.Collections;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using System.Linq;
using System.Reflection;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Approvals;

using YAAC = MetraTech.Interop.MTYAAC;
using Auth = MetraTech.Interop.MTAuth;
using System.ServiceProcess;





//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.UnitTests.ApprovalManagementServiceUnitTests /assembly:O:\debug\bin\MetraTech.Core.Services.UnitTests.dll
//
namespace MetraTech.Core.Services.UnitTests
{
    


    [TestClass]
  public class ApprovalManagementServiceUnitTests
  {
      [ClassInitialize]
		public static void InitTests(TestContext testContext)
      {
		  MetraTech.Core.Services.UnitTests.ApprovalManagementServiceUnitTests ut = 
			  new ApprovalManagementServiceUnitTests();
		  ut.MakeSureServiceIsStarted("ActivityServices");
      }



        public Auth.IMTSessionContext SessionContext { get; set; }
        
        #region ApprovalUnitTests

        public static IMTSessionContext LoginAsSU()
        {
            // sets the SU session context on the client
            IMTLoginContext loginContext = new MTLoginContextClass();
            string suName = "su";
            string suPassword = "su123";
            return loginContext.Login(suName, "system_user", suPassword);
        }

        /// <summary>
      /// Tests assignment of Allow ApprovalsView capability
      /// </summary>
      [TestMethod]
      public void TestAssigningAllApprovalFrameworksCapabilities()
      {
          var ctx = LoginAsSU();
          IMTSecurity sec = new MTSecurityClass();
          YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
          cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
          
          //csr1,jcsr,scsr test system accounts

          YAAC.IMTYAAC updaterateuser = cat.GetAccountByName("csr1", "system_user", DateTime.Now);
          YAAC.IMTYAAC updateaccountuser = cat.GetAccountByName("jcsr", "system_user", DateTime.Now);
          YAAC.IMTYAAC viewapprovals = cat.GetAccountByName("scsr", "system_user", DateTime.Now);


          IMTYAAC cap1 = sec.GetAccountByID((MTSessionContext)ctx, updaterateuser.AccountID, DateTime.Now);
          IMTYAAC cap2 = sec.GetAccountByID((MTSessionContext)ctx, updateaccountuser.AccountID, DateTime.Now);
          IMTYAAC cap3 = sec.GetAccountByID((MTSessionContext)ctx, viewapprovals.AccountID, DateTime.Now);
          
          
          IMTCompositeCapability cap1_ura = sec.GetCapabilityTypeByName("Approve RateUpdates").CreateInstance();
          IMTCompositeCapability cap1_aac = sec.GetCapabilityTypeByName("Approve AccountChanges").CreateInstance();
          IMTCompositeCapability cap1_aav = sec.GetCapabilityTypeByName("Allow ApprovalsView").CreateInstance();

          IMTCompositeCapability cap2_ura = sec.GetCapabilityTypeByName("Approve RateUpdates").CreateInstance();
          IMTCompositeCapability cap2_aac = sec.GetCapabilityTypeByName("Approve AccountChanges").CreateInstance();
          IMTCompositeCapability cap2_aav = sec.GetCapabilityTypeByName("Allow ApprovalsView").CreateInstance();


          IMTCompositeCapability cap3_ura = sec.GetCapabilityTypeByName("Approve RateUpdates").CreateInstance();
          IMTCompositeCapability cap3_aac = sec.GetCapabilityTypeByName("Approve AccountChanges").CreateInstance();
          IMTCompositeCapability cap3_aav = sec.GetCapabilityTypeByName("Allow ApprovalsView").CreateInstance();

          //Assing the approval framework capabilities
          cap1.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap1_ura);
          cap1.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap1_aac);
          cap1.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap1_aav);
          cap1.GetActivePolicy((MTSessionContext)ctx).Save();


          cap2.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap2_ura);
          cap2.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap2_aac);
          cap2.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap2_aav);
          cap2.GetActivePolicy((MTSessionContext)ctx).Save();
          
          
          cap3.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap3_ura);
          cap3.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap3_aac);
          cap3.GetActivePolicy((MTSessionContext)ctx).AddCapability(cap3_aav);
          cap3.GetActivePolicy((MTSessionContext)ctx).Save();
          
      }
 
      
      [TestMethod]
    [TestCategory("SubmitChangeScenaio")]
    public void SubmitChange()
    {
        ApprovalManagementServiceClient client = null;

        client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";

        try
        {
            ////Create the change
            Change mysampleUpdateChange = new Change();
            mysampleUpdateChange.ChangeType = "SampleUpdate";

            mysampleUpdateChange.UniqueItemId = "1702627707";//GenerateRandomNumber(100, 10000).ToString(); 
            mysampleUpdateChange.ItemDisplayName = "This is Test 1";
            mysampleUpdateChange.Comment = "Simple Submit Change Test Scenario By Core";
            ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
            changeDetails["UpdatedValue"] = 1000;
            mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

            int newchangeId; 
            client.SubmitChange(mysampleUpdateChange, out newchangeId);

        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            foreach (string e in fe.Detail.ErrorMessages)
            {
                Console.WriteLine("Error: {0}", e);
            }

            client.Abort();
            throw;
        }
        catch (Exception e)
        {
            client.Abort();
            throw e;
        }
    }

      [TestMethod]
      [TestCategory("ApproveChangeScenaio")]
      public void ApproveChange()
      {

        int newchangeId;
        Change mysampleUpdateChange = new Change();

        ApprovalManagementServiceClient client = null;

        client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";

        try
        {
          // First submit the change
          ////Create the change
          mysampleUpdateChange.ChangeType = "SampleUpdate";
          mysampleUpdateChange.UniqueItemId = "Approval4";
          mysampleUpdateChange.ItemDisplayName = "This is Test 4";
          mysampleUpdateChange.SubmitterId = 129;
          mysampleUpdateChange.SubmittedDate = DateTime.Now;
          mysampleUpdateChange.CurrentState = ChangeState.Pending;
          mysampleUpdateChange.Comment = "Simple Submit Change Test Scenario By Core";

          ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
          changeDetails["UpdatedValue"] = 1001;
          mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

          client.SubmitChange(mysampleUpdateChange, out newchangeId);
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          foreach (string e in fe.Detail.ErrorMessages)
          {
            Console.WriteLine("Error: {0}", e);
          }

          client.Abort();
          throw;
        }
        catch (Exception)
        {
          client.Abort();
          throw;
        }

        // Need a different login to approve, so client 2 is here

        ApprovalManagementServiceClient client2 = null;

        client2 = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client2.ClientCredentials.UserName.UserName = "csr1";
        client2.ClientCredentials.UserName.Password = "csr123";

        try
        {
          // First submit the change
          mysampleUpdateChange.Id = newchangeId;
          mysampleUpdateChange.Comment = "Approve this change";
          client2.ApproveChange(mysampleUpdateChange.Id, mysampleUpdateChange.Comment);

        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
          foreach (string e in fe.Detail.ErrorMessages)
          {
            Console.WriteLine("Error: {0}", e);
          }

          client2.Abort();
          throw;
        }
        catch (Exception)
        {
          client2.Abort();
          throw;
        }

      }

      
      [TestMethod]
    [TestCategory("DenyChangeScenaio")]
    public void DenyChange()
    {
        ApprovalManagementServiceClient client = null;

        client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";

        try
        {
            ////Create the change
            Change mysampleUpdateChange = new Change();

            mysampleUpdateChange.ChangeType = "SampleUpdate";
            mysampleUpdateChange.UniqueItemId = 123.ToString();// GenerateRandomNumber(100, 10000).ToString(); 
            mysampleUpdateChange.ItemDisplayName = "This is Test 1";
            mysampleUpdateChange.Comment = "Simple Submit and then Deny Change Test Scenario";
            ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
            changeDetails["UpdatedValue"] = 1000;
            mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

            int newchangeId;
            client.SubmitChange(mysampleUpdateChange, out newchangeId);

            //GetChangeDetails before denying 

            string detailsOfThisParticularChange="";
            client.GetChangeDetails(newchangeId, ref detailsOfThisParticularChange);

            //Get All changes we have in the system today
            MTList<ChangeHistoryItem> list = new MTList<ChangeHistoryItem>();

            client.GetChangeHistory(newchangeId, ref list);

            Assert.IsNotNull(list);

            mysampleUpdateChange.Id = newchangeId;
            mysampleUpdateChange.Comment = "Denying this change";

            client.DenyChange(mysampleUpdateChange.Id, mysampleUpdateChange.Comment);

        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            foreach (string e in fe.Detail.ErrorMessages)
            {
                Console.WriteLine("Error: {0}", e);
            }

            client.Abort();
            throw;
        }
        catch (Exception e)
        {
            client.Abort();
            throw e;
        }
    }

    [TestMethod]
    [TestCategory("DismissChangeScenaio")]
    public void DismissChange()
    {
        ApprovalManagementServiceClient client = null;

        client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";

        try
        {
            ////Create the change
            Change mysampleUpdateChange = new Change();

            mysampleUpdateChange.ChangeType = "SampleUpdate";
            mysampleUpdateChange.UniqueItemId = 123.ToString();// GenerateRandomNumber(100, 10000).ToString();
            mysampleUpdateChange.ItemDisplayName = "This is Test 1";
            mysampleUpdateChange.Comment = "Simple Submit Change and then dismiss Test Scenario";
            ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
            changeDetails["UpdatedValue"] = 1000;
            mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

            int newchangeId;
            client.SubmitChange(mysampleUpdateChange, out newchangeId);
            
            mysampleUpdateChange.Id = newchangeId;
            mysampleUpdateChange.Comment = "Dismissing this change as it is not required anymore..";

            client.DismissChange(mysampleUpdateChange.Id, mysampleUpdateChange.Comment);
            
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            foreach (string e in fe.Detail.ErrorMessages)
            {
                Console.WriteLine("Error: {0}", e);
            }

            client.Abort();
            throw;
        }
        catch (Exception e)
        {
            client.Abort();
            throw e;
        }
    }

    
      [TestMethod]
    [TestCategory("DenyChangeScenaio")]
    public void UpdateChangeDetails()
    {
        ApprovalManagementServiceClient client = null;

        client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";

        try
        {
            ////Create the change
            Change mysampleUpdateChange = new Change();

            mysampleUpdateChange.ChangeType = "SampleUpdate";
            mysampleUpdateChange.UniqueItemId = 123.ToString();// GenerateRandomNumber(100, 10000).ToString();
            mysampleUpdateChange.ItemDisplayName = "This is Test 1";
            mysampleUpdateChange.Comment = "Simple Submit and then Update Change Test Scenario";
            ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
            changeDetails["UpdatedValue"] = 1000;
            mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

            int newchangeId;
            client.SubmitChange(mysampleUpdateChange, out newchangeId);

            //GetChangeDetails before denying 

            string detailsOfThisParticularChange = "";
            client.GetChangeDetails(newchangeId, ref detailsOfThisParticularChange);

            //Get All changes we have in the system today
            MTList<ChangeHistoryItem> list = new MTList<ChangeHistoryItem>();

            client.GetChangeHistory(newchangeId, ref list);

            Assert.IsNotNull(list);

            mysampleUpdateChange.Id = newchangeId;
            mysampleUpdateChange.Comment = "Updating this change";
            mysampleUpdateChange.ChangeDetailsBlob = "MetraTech Corp, Waltham";

            client.UpdateChangeDetails(mysampleUpdateChange.Id, mysampleUpdateChange.ChangeDetailsBlob, mysampleUpdateChange.Comment);

        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            foreach (string e in fe.Detail.ErrorMessages)
            {
                Console.WriteLine("Error: {0}", e);
            }

            client.Abort();
            throw;
        }
        catch (Exception e)
        {
            client.Abort();
            throw e;
        }
    }

       
    [TestMethod]
    [TestCategory("ApproveChange_ShouldFail_SubmitterApproverSame")]
    public void ApproveChange_ShouldFail_SubmitterApproverSame()
    {
        ApprovalManagementServiceClient client = null;

        client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        try
        {
            ////Create the change
            Change mysampleUpdateChange = new Change();

            mysampleUpdateChange.ChangeType = "SampleUpdate";
            mysampleUpdateChange.UniqueItemId = 123.ToString();// GenerateRandomNumber(100, 10000).ToString();
            mysampleUpdateChange.ItemDisplayName = "This is Test 1";
            mysampleUpdateChange.Comment = "Simple Submit and then Approve Change Test Scenario";
            ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
            changeDetails["UpdatedValue"] = 1000;
            mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

            int newchangeId;
            client.SubmitChange(mysampleUpdateChange, out newchangeId);

            //GetChangeDetails before denying 

            string detailsOfThisParticularChange = "";
            client.GetChangeDetails(newchangeId, ref detailsOfThisParticularChange);

            //Get All changes we have in the system today
            MTList<ChangeHistoryItem> list = new MTList<ChangeHistoryItem>();

            client.GetChangeHistory(newchangeId, ref list);

            Assert.IsNotNull(list);

            mysampleUpdateChange.Id = newchangeId;
            mysampleUpdateChange.Comment = "Denying this change";

            client.ApproveChange(mysampleUpdateChange.Id, mysampleUpdateChange.Comment);
            Assert.Fail("The submitter should not have been allowed to approve their submitted change.");
        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            foreach (string e in fe.Detail.ErrorMessages)
            {
                Console.WriteLine("Error: {0}", e);
            }

            client.Abort();
            //throw;
        }
        catch (Exception e)
        {
            client.Abort();
            throw e;
        }
    }


    [TestMethod]
    [TestCategory("SubChangeScenaio")]
    public void ApproveChange_ShouldPass_SubmitterApproverDifferent()
    {
        ApprovalManagementServiceClient client = null;

        client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";

        try
        {
            ////Create the change
            Change mysampleUpdateChange = new Change();

            mysampleUpdateChange.ChangeType = "SampleUpdate";
          mysampleUpdateChange.UniqueItemId = 123.ToString();// GenerateRandomNumber(100, 10000).ToString();
            mysampleUpdateChange.ItemDisplayName = "This is Test 1";
            mysampleUpdateChange.Comment = "Simple Submit and then Approve Change Test Scenario";
            ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
            changeDetails["UpdatedValue"] = 1000;
            mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

            int newchangeId;
            client.SubmitChange(mysampleUpdateChange, out newchangeId);

            //GetChangeDetails before denying 

            string detailsOfThisParticularChange = "";
            client.GetChangeDetails(newchangeId, ref detailsOfThisParticularChange);

            //Get All changes we have in the system today
            MTList<ChangeHistoryItem> list = new MTList<ChangeHistoryItem>();

            client.GetChangeHistory(newchangeId, ref list);

            Assert.IsNotNull(list);

            mysampleUpdateChange.Id = newchangeId;
            mysampleUpdateChange.Comment = "Denying this change";

            //Change the approver user

            ApprovalManagementServiceClient approvingclient = null;

            approvingclient = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
            approvingclient.ClientCredentials.UserName.UserName = "su";
            approvingclient.ClientCredentials.UserName.Password = "su123";

            approvingclient.ApproveChange(mysampleUpdateChange.Id, mysampleUpdateChange.Comment);

        }
        catch (FaultException<MASBasicFaultDetail> fe)
        {
            foreach (string e in fe.Detail.ErrorMessages)
            {
                Console.WriteLine("Error: {0}", e);
            }

            client.Abort();
            throw;
        }
        catch (Exception e)
        {
            client.Abort();
            throw e;
        }
    }




      [TestMethod]
    [TestCategory("SimpleReviewScenario")]
    public void GetAllChangesSummary()
    {

        ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";

          //Add a new change 
          SubmitChange();

        //Create a list that will be populated
        MTList<ChangeSummary> list = new MTList<ChangeSummary>();

        //Maybe want to filter them to retreive only sample update
        //list.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, "SampleUpdate"));

        //Get All changes we have in the system today
        client.GetChangesSummary(ref list);

        Assert.IsNotNull(list);

          int itemsinthelist;
          itemsinthelist = list.Items.Count;


          if (itemsinthelist == 0)
          {
          Assert.Fail("No Rows Returned");
          }

    }

    [TestMethod]
    [TestCategory("SimpleReviewScenario")]
    public void GetPendingChangesSummary()
    {

      ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();
      client.ClientCredentials.UserName.UserName = "admin";
      client.ClientCredentials.UserName.Password = "123";

      //Add a new change 
      SubmitChange();

      //Create a list that will be populated
      MTList<ChangeSummary> list = new MTList<ChangeSummary>();

      //Maybe want to filter them to retreive only sample update
      //list.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, "SampleUpdate"));

      //Get the pending changes that this user can work with and that match the filter criteria
      client.GetPendingChangesSummary(ref list);

      Assert.IsNotNull(list);

      int itemsinthelist;
      itemsinthelist = list.Items.Count;
        

      if (itemsinthelist == 0)
      {
          Assert.Fail("No Rows Returned");
      }

    }


    [TestMethod]
    [TestCategory("SimpleReviewScenario")]
    public void GetChangeHistory()
    //(int changeId, ref MTList<ChangeHistoryItem> changeHistoryItems)
    {

        ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();
        client.ClientCredentials.UserName.UserName = "admin";
        client.ClientCredentials.UserName.Password = "123";
        int mychangeid = 38; //Replace this change id with valid change id from your system

        //Create a list that will be populated
        MTList<ChangeHistoryItem> list = new MTList<ChangeHistoryItem>();

        //Maybe want to filter them to retreive only sample update
        //list.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, "SampleUpdate"));

        //Get All changes we have in the system today
        client.GetChangeHistory(mychangeid, ref list);

        Assert.IsNotNull(list);
        

        ////For each change do something with it, such as display it
        //foreach (pendingChange Change in list)
        //{

        //  //pendingChange.SubmitterDisplayName;
        //  //pendingChange.SubmittedDate;
        //  //pendingChange.UniqueItemId;
        //  //pendingChange.ItemDisplayName;

        //  //Maybe we want to see the details of the change
        //  string detailsOfThisParticularChange;
        //  client.GetChangeDetail(pendingChange.Id, ref detailsOfThisParticularChange);
        //}

        ////...
        ////Maybe the user later has selected to approve or deny the change
        //if (bUserApproved)
        //{
        //  client.ApproveChange(idOfTheChangeTheUserApproved);
        //}
        //else
        //{
        //  client.DenyChange(idOfTheChangeTheUserApproved, sCommentFromUserAsToWhyTheyDeniedTheChange);
        //}


    }

   private int GenerateRandomNumber(int min, int max)
      {
          Random random = new Random();
         int randomint;  
         randomint = random.Next(min, max);
         return randomint;
      }

     private void MakeSureServiceIsStarted(string serviceName)
     {
       MakeSureServiceIsStarted(serviceName, 120);
     }

     private void MakeSureServiceIsStarted(string serviceName, int timeoutSeconds)
     {
       ServiceController sc = new ServiceController(serviceName);
       Console.WriteLine("The " + serviceName + " service status is currently set to {0}",
                          sc.Status.ToString());

       if (sc.Status == ServiceControllerStatus.Stopped)
       {
         // Start the service if the current status is stopped.

         try
         {
           // Start the service, and wait until its status is "Running".
           sc.Start();
           sc.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromSeconds(timeoutSeconds));

           // Display the current service status.
           Console.WriteLine("The " + serviceName + " service status is now set to {0}.",
                              sc.Status.ToString());
         }
         catch (System.ServiceProcess.TimeoutException)
         {
           throw new Exception(string.Format("Timed out after {0} seconds waiting for {1} service to start", timeoutSeconds, serviceName));
         }
         catch (InvalidOperationException)
         {
           throw new Exception(string.Format("Unable to start the service {0}", serviceName));
         }
       }
     }


      }
}
#endregion
