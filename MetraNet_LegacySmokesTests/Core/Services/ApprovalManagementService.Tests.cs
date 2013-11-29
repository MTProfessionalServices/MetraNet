using System;
using System.Collections.Generic;
using System.Diagnostics;
using NUnit.Framework;

using MetraTech.Security;
using MetraTech;
using MetraTech.Core.Services;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using System.Collections;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using System.Linq;
using System.Reflection;
using MetraTech.DomainModel.Enums.Core.Global;
//using MetraTech.ActivityServices.Services.Common;
using MetraTech.Approvals;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.ApprovalManagementServiceTest /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
  public class ApprovalManagementServiceTest
  {

    private Logger m_Logger = new Logger("[AppovalManagementFramework]");
    //private BasePriceableItemTemplate deleteTemplate = null;

    #region tests

    [Test]
    [Category("SubmitChangeScenaio")]
    public void SubmitChange()
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
        mysampleUpdateChange.UniqueItemId = "Approval1";
        mysampleUpdateChange.ItemDisplayName = "This is Test 1";
        mysampleUpdateChange.SubmitterId = 129;
        mysampleUpdateChange.SubmittedDate = DateTime.Now;
        mysampleUpdateChange.CurrentState = ChangeState.Pending;
        mysampleUpdateChange.Comment = "Simple Submit Change Test Scenario By Core";

        ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
        changeDetails["UpdatedValue"] = 1000;
        mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();
        //mysampleUpdateChange.ChangeDetailsBlob = "MetraTech Corp";

        int newchangeId;
        client.SubmitChange(mysampleUpdateChange, out newchangeId);
        m_Logger.LogDebug("The new change was submitted to the approval framework. refer to the id {0}", newchangeId.ToString());

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


    [Test]
    [Category("DenyChangeScenaio")]
    public void DenyChange()
    {
      ApprovalManagementServiceClient client = null;

      client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      try
      {
        // First submit the change
        ////Create the change
        Change mysampleUpdateChange = new Change();
        mysampleUpdateChange.ChangeType = "SampleUpdate";
        mysampleUpdateChange.UniqueItemId = "Approval2";
        mysampleUpdateChange.ItemDisplayName = "This is Test 2";
        mysampleUpdateChange.SubmitterId = 129;
        mysampleUpdateChange.SubmittedDate = DateTime.Now;
        mysampleUpdateChange.CurrentState = ChangeState.Pending;
        mysampleUpdateChange.Comment = "Simple Submit Change Test Scenario By Core";

        ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
        changeDetails["UpdatedValue"] = 1001;
        mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

        int newchangeId;
        client.SubmitChange(mysampleUpdateChange, out newchangeId);
        m_Logger.LogDebug("The new change was submitted to the approval framework. refer to the id {0}", newchangeId.ToString());


        //Denying the change
        mysampleUpdateChange.Id = newchangeId;
        mysampleUpdateChange.Comment = "Denying this change";
        client.DenyChange(mysampleUpdateChange.Id, mysampleUpdateChange.Comment);

        m_Logger.LogDebug("The existing change was denied for id {0}", mysampleUpdateChange.Id.ToString());

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

    [Test]
    [Category("DenyChangeScenaio")]
    public void DismissChange()
    {
      ApprovalManagementServiceClient client = null;

      client = new ApprovalManagementServiceClient("WSHttpBinding_IApprovalManagementService");
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      try
      {
        // First submit the change
        ////Create the change
        Change mysampleUpdateChange = new Change();
        mysampleUpdateChange.ChangeType = "SampleUpdate";
        mysampleUpdateChange.UniqueItemId = "Approval3";
        mysampleUpdateChange.ItemDisplayName = "This is Test 3";
        mysampleUpdateChange.SubmitterId = 129;
        mysampleUpdateChange.SubmittedDate = DateTime.Now;
        mysampleUpdateChange.CurrentState = ChangeState.Pending;
        mysampleUpdateChange.Comment = "Simple Submit Change Test Scenario By Core";

        ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
        changeDetails["UpdatedValue"] = 1002;
        mysampleUpdateChange.ChangeDetailsBlob = changeDetails.ToBuffer();

        int newchangeId;
        client.SubmitChange(mysampleUpdateChange, out newchangeId);
        m_Logger.LogDebug("The new change was submitted to the approval framework. refer to the id {0}", newchangeId.ToString());

        mysampleUpdateChange.Id = newchangeId;
        mysampleUpdateChange.Comment = "Dismissing this change as it is not required anymore..";

        client.DismissChange(mysampleUpdateChange.Id, mysampleUpdateChange.Comment);
        m_Logger.LogDebug("The existing change was dismissed for id {0}", mysampleUpdateChange.Id.ToString());

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

    [Test]
    [Category("SimpleReviewScenario")]
    public void SimpleSubmitScenario()
    {
      ////Involves RateUpdateUser, RateUpdateApproverUser

      //ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();
      //client.ClientCredentials.UserName.UserName = "RateUpdateApproverUserName";
      //client.ClientCredentials.UserName.Password = "password";

      ////Create the change
      //Change myRateUpdateChange = new Change();
      //myRateUpdateChange.ChangeType = 
      //myRateUpdateChange.UniqueItemId = myRateScheduleObject.Id;
      //myRateUpdateChange.ItemDisplayName = myRateScheduleObject.Name;

      //ChangeDetailsHelper myRateUpdateChangeDetails = new ChangeDetailsHelper();
      //myRateUpdateChangeDetails["RateSchedule"] = myRateScheduleObject

      //int changeId;
      //client.SubmitChangeForApproval(myRateUpdateChange, ref changeId);



      ////Create a list that will be populated
      //MTList<Change> list = new MTList<Change>();

      ////Maybe want to filter them to retreive only rate update
      //list.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, "RateUpdate"));

      ////Get the pending changes that this user can work with and that match the filter criteria
      //client.GetPendingChangesSummary(ref list);

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


    [Test]
    [Category("SimpleReviewScenario")]
    public void SimpleReviewScenario()
    {
      ////Involves RateUpdateUser, RateUpdateApproverUser

      ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      //Create a list that will be populated
      MTList<ChangeSummary> list = new MTList<ChangeSummary>();

      //Maybe want to filter them to retreive only rate update
      //list.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, "RateUpdate"));

      //Get the pending changes that this user can work with and that match the filter criteria
      client.GetPendingChangesSummary(ref list);

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

    [Test]
    [Category("SimpleOutsideApprovalPushPullScenario")]
    public void SimpleOutsideApprovalPushPullScenario()
    {
      ////Involves AutomatedApprovalToolUserName

      //ApprovalManagementServiceClient client = new ApprovalManagementServiceClient();
      //client.ClientCredentials.UserName.UserName = "RateUpdateApproverUserName";
      //client.ClientCredentials.UserName.Password = "password";

      ////Create a list that will be populated
      //MTList<ChangeSummary> list = new MTList<ChangeSummary>();

      ////Maybe want to filter them to retreive only rate update
      //list.Filters.Add(new MTFilterElement("ChangeType", MTFilterElement.OperationType.Equal, "RateUpdate"));

      ////Get the pending changes that this user can work with and that match the filter criteria
      //client.GetPendingChangesSummary(ref list);

      ////For each change do something with it, such as display it
      //foreach (pendingChange ChangeSummary in list)
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





    #region Internal Methods


    private void SaveUnitDepRecurringTemplate()
    {
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Unit_Dependent_Recurring_ChargePITemplate template = new Unit_Dependent_Recurring_ChargePITemplate();
      template.Description = string.Format("{0}-{1}", " UDRC Recur-Desc", GUIDHashCode);
      template.DisplayName = string.Format("{0}-{1}", " UDRC Recur-Disp", GUIDHashCode);
      //template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
      template.Name = string.Format("{0}-{1}", "UDRC  Recurring", GUIDHashCode);

      WeeklyUsageCycyleInfo wuci = new WeeklyUsageCycyleInfo();
      wuci.DayOfWeek = DayOfWeek.Thursday;
      template.Cycle = wuci;

      template.ChargeAdvance = true;
      template.ProrateOnActivation = true;
      template.ProrateInstantly = false;
      template.ProrateOnDeactivation = false;
      template.ChargePerParticipant = true;
      template.FixedProrationLength = false;



      template.PIKind = PriceableItemKinds.UnitDependentRecurring;

      List<ReasonCode> rsnCodes = new List<ReasonCode>();
      ReasonCode rsncode1 = new ReasonCode();
      rsncode1.Description = string.Format("reasoncode-{0}{1}", 1, template.Description);
      rsncode1.DisplayName = string.Format("reasoncode-{0}{1}", 1, template.DisplayName);
      rsncode1.Name = string.Format("reasoncode-{0}{1}", 1, template.Name);
      rsnCodes.Add(rsncode1);
      ReasonCode rsncode2 = new ReasonCode();
      rsncode2.Description = string.Format("reasoncode-{0}{1}", 2, template.Description);
      rsncode2.DisplayName = string.Format("reasoncode-{0}{1}", 2, template.DisplayName);
      rsncode2.Name = string.Format("reasoncode-{0}{1}", 2, template.Name);
      rsnCodes.Add(rsncode2);

      AdjustmentTemplate flatAdjTemplate = new AdjustmentTemplate();
      flatAdjTemplate.Description = string.Format("adjustment-flat-{0}", template.Description);
      flatAdjTemplate.DisplayName = string.Format("adjustment-flat-{0}", template.DisplayName);
      flatAdjTemplate.Name = string.Format("adjustment-flat-{0}", template.Name);

      AdjustmentTemplate percentAdjTemplate = new AdjustmentTemplate();
      percentAdjTemplate.Description = string.Format("adjustment-percent-{0}", template.Description);
      percentAdjTemplate.DisplayName = string.Format("adjustment-percent-{0}", template.DisplayName);
      percentAdjTemplate.Name = string.Format("adjustment-percent-{0}", template.Name);

      flatAdjTemplate.ReasonCodes = rsnCodes;
      percentAdjTemplate.ReasonCodes = rsnCodes;

      template.UnitDependentRecurringChargeFlatAdjustment = flatAdjTemplate;
      template.UnitDependentRecurringChargePercentAdjustment = percentAdjTemplate;

      template.AllowedUnitValues = new List<decimal>() { 10.00M, 11.00M, 12.00M };
      template.IntegerUnitValue = true;

      template.MaxUnitValue = 15.00M;
      template.MinUnitValue = 5.00M;

      template.RatingType = UDRCRatingType.Tiered;

      template.UnitDisplayName = string.Format("udisplyname:{0}", GUIDHashCode);
      template.UnitName = string.Format("unitname-{0}", GUIDHashCode);

      BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.SavePriceableItemTemplate(ref bpt);



      BasePriceableItemTemplate bpt1;

      client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

      Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

      template = bpt1 as Unit_Dependent_Recurring_ChargePITemplate;

      template.Description = "updated " + template.Description;
      template.DisplayName = "updated " + template.DisplayName;

      Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
      localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate UDrecurring  desc {IT}", GUIDHashCode));
      localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate UDrecurring desc {DE}", GUIDHashCode));

      Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
      localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate UDrecurring disp {IT}", GUIDHashCode));
      localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate UDrecurring disp {DE}", GUIDHashCode));

      template.LocalizedDisplayNames = localDisp1;
      template.LocalizedDescriptions = localDesc1;
      template.FixedProrationLength = true;
      template.MinUnitValue = 3.00M;
      template.RatingType = UDRCRatingType.Tapered;

      bpt1 = template as BasePriceableItemTemplate;
      client.SavePriceableItemTemplate(ref bpt1);
    }

    private void SaveRecurringTemplate()
    {
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Flat_Rate_Recurring_ChargePITemplate template = new Flat_Rate_Recurring_ChargePITemplate();
      template.Description = string.Format("{0}-{1}", " Recur-Desc", GUIDHashCode);
      template.DisplayName = string.Format("{0}-{1}", " Recur-Disp", GUIDHashCode);
      template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
      template.Name = string.Format("{0}-{1}", "Flat Rate  Recurring", GUIDHashCode);

      MonthlyUsageCycleInfo muci = new MonthlyUsageCycleInfo();
      muci.EndDay = 20;
      template.Cycle = muci;

      template.ChargeAdvance = true;
      template.ProrateOnActivation = true;
      template.ProrateInstantly = false;
      template.ProrateOnDeactivation = false;
      template.ChargePerParticipant = true;
      template.FixedProrationLength = false;



      template.PIKind = PriceableItemKinds.Recurring;

      List<ReasonCode> rsnCodes = new List<ReasonCode>();
      ReasonCode rsncode1 = new ReasonCode();
      rsncode1.Description = string.Format("reasoncode-{0}{1}", 1, template.Description);
      rsncode1.DisplayName = string.Format("reasoncode-{0}{1}", 1, template.DisplayName);
      rsncode1.Name = string.Format("reasoncode-{0}{1}", 1, template.Name);
      rsnCodes.Add(rsncode1);
      ReasonCode rsncode2 = new ReasonCode();
      rsncode2.Description = string.Format("reasoncode-{0}{1}", 2, template.Description);
      rsncode2.DisplayName = string.Format("reasoncode-{0}{1}", 2, template.DisplayName);
      rsncode2.Name = string.Format("reasoncode-{0}{1}", 2, template.Name);
      rsnCodes.Add(rsncode2);

      AdjustmentTemplate flatAdjTemplate = new AdjustmentTemplate();
      flatAdjTemplate.Description = string.Format("adjustment-flat-{0}", template.Description);
      flatAdjTemplate.DisplayName = string.Format("adjustment-flat-{0}", template.DisplayName);
      flatAdjTemplate.Name = string.Format("adjustment-flat-{0}", template.Name);

      AdjustmentTemplate percentAdjTemplate = new AdjustmentTemplate();
      percentAdjTemplate.Description = string.Format("adjustment-percent-{0}", template.Description);
      percentAdjTemplate.DisplayName = string.Format("adjustment-percent-{0}", template.DisplayName);
      percentAdjTemplate.Name = string.Format("adjustment-percent-{0}", template.Name);

      flatAdjTemplate.ReasonCodes = rsnCodes;
      percentAdjTemplate.ReasonCodes = rsnCodes;

      template.FlatRecurringChargeFlatAdjustment = flatAdjTemplate;
      template.FlatRecurringChargePercentAdjustment = percentAdjTemplate;


      BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.SavePriceableItemTemplate(ref bpt);


      BasePriceableItemTemplate bpt1;

      client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

      Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

      template = bpt1 as Flat_Rate_Recurring_ChargePITemplate;

      template.Description = "updated " + template.Description;
      template.DisplayName = "updated " + template.DisplayName;

      Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
      localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate recurring  desc {IT}", GUIDHashCode));
      localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate recurring desc {DE}", GUIDHashCode));

      Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
      localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate recurring disp {IT}", GUIDHashCode));
      localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate recurring disp {DE}", GUIDHashCode));

      template.LocalizedDisplayNames = localDisp1;
      template.LocalizedDescriptions = localDesc1;

      bpt1 = template as BasePriceableItemTemplate;
      client.SavePriceableItemTemplate(ref bpt1);

      BasePriceableItemTemplate rbpt;
      client.GetPriceableItemTemplate(new PCIdentifier(bpt1.ID.Value), out rbpt);

      Assert.AreEqual(bpt1.ID.Value, rbpt.ID.Value);
      Assert.AreEqual(bpt1.Name, rbpt.Name);
      Assert.AreEqual(bpt1.DisplayName, rbpt.DisplayName);
      Assert.AreEqual(bpt1.Description, rbpt.Description);
      Assert.AreEqual(bpt1.PIKind, rbpt.PIKind);
      Assert.IsNotNull(rbpt.LocalizedDescriptions);

      Assert.AreEqual(bpt1.LocalizedDescriptions.Count, rbpt.LocalizedDescriptions.Count);



    }

    private void SaveNonRecurringTemplate()
    {
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Flat_Rate_Non_Recurring_ChargePITemplate template = new Flat_Rate_Non_Recurring_ChargePITemplate();
      template.Description = string.Format("{0}-{1}", "Non Recur-Desc", GUIDHashCode);
      template.DisplayName = string.Format("{0}-{1}", "Non Recur-Disp", GUIDHashCode);
      template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
      template.Name = string.Format("{0}-{1}", "Flat Rate Non Recurring", GUIDHashCode);
      template.EventType = NonRecurringChargeEvents.Subscribe;
      template.PIKind = PriceableItemKinds.NonRecurring;

      List<ReasonCode> rsnCodes = new List<ReasonCode>();
      ReasonCode rsncode1 = new ReasonCode();
      rsncode1.Description = string.Format("reasoncode-{0}{1}", 1, template.Description);
      rsncode1.DisplayName = string.Format("reasoncode-{0}{1}", 1, template.DisplayName);
      rsncode1.Name = string.Format("reasoncode-{0}{1}", 1, template.Name);
      rsnCodes.Add(rsncode1);
      ReasonCode rsncode2 = new ReasonCode();
      rsncode2.Description = string.Format("reasoncode-{0}{1}", 2, template.Description);
      rsncode2.DisplayName = string.Format("reasoncode-{0}{1}", 2, template.DisplayName);
      rsncode2.Name = string.Format("reasoncode-{0}{1}", 2, template.Name);
      rsnCodes.Add(rsncode2);

      AdjustmentTemplate flatAdjTemplate = new AdjustmentTemplate();
      flatAdjTemplate.Description = string.Format("adjustment-flat-{0}", template.Description);
      flatAdjTemplate.DisplayName = string.Format("adjustment-flat-{0}", template.DisplayName);
      flatAdjTemplate.Name = string.Format("adjustment-flat-{0}", template.Name);

      AdjustmentTemplate percentAdjTemplate = new AdjustmentTemplate();
      percentAdjTemplate.Description = string.Format("adjustment-percent-{0}", template.Description);
      percentAdjTemplate.DisplayName = string.Format("adjustment-percent-{0}", template.DisplayName);
      percentAdjTemplate.Name = string.Format("adjustment-percent-{0}", template.Name);

      flatAdjTemplate.ReasonCodes = rsnCodes;
      percentAdjTemplate.ReasonCodes = rsnCodes;

      template.FlatNonRecurringChargeFlatAdjustment = flatAdjTemplate;
      template.FlatNonRecurringChargePercentAdjustment = percentAdjTemplate;


      BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.SavePriceableItemTemplate(ref bpt);


      BasePriceableItemTemplate bpt1;

      client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

      Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

      template = bpt1 as Flat_Rate_Non_Recurring_ChargePITemplate;

      template.Description = "updated " + template.Description;
      template.DisplayName = "updated " + template.DisplayName;

      template.EventType = NonRecurringChargeEvents.Unsubscribe;

      Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
      localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate non recurring  desc {IT}", GUIDHashCode));
      localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate non recurring desc {DE}", GUIDHashCode));

      Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
      localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate non recurring disp {IT}", GUIDHashCode));
      localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate non recurring disp {DE}", GUIDHashCode));

      template.LocalizedDisplayNames = localDisp1;
      template.LocalizedDescriptions = localDesc1;

      Assert.IsNotNull(template.FlatNonRecurringChargeFlatAdjustment);

      flatAdjTemplate = template.FlatNonRecurringChargeFlatAdjustment;
      flatAdjTemplate.Description = "updated " + flatAdjTemplate.Description;
      flatAdjTemplate.DisplayName = "updated " + flatAdjTemplate.DisplayName;

      flatAdjTemplate.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
      flatAdjTemplate.LocalizedDescriptions.Add(LanguageCode.FR, template.Description + "{FR}");
      flatAdjTemplate.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
      flatAdjTemplate.LocalizedDisplayNames.Add(LanguageCode.FR, template.Description + "{FR}");

      flatAdjTemplate.ReasonCodes.RemoveAt(0);
      ReasonCode rsnCode = flatAdjTemplate.ReasonCodes[0];
      rsnCode.Description = "updated " + rsnCode.Description;
      rsnCode.DisplayName = "updated " + rsnCode.DisplayName;
      rsnCode.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
      rsnCode.LocalizedDescriptions.Add(LanguageCode.FR, "local description {FR}");
      rsnCode.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
      rsnCode.LocalizedDisplayNames.Add(LanguageCode.FR, "local display name {FR}");
      flatAdjTemplate.ReasonCodes[0] = rsnCode;

      template.FlatNonRecurringChargeFlatAdjustment = flatAdjTemplate;

      bpt1 = template as BasePriceableItemTemplate;
      client.SavePriceableItemTemplate(ref bpt1);


      BasePriceableItemTemplate rbpt;
      client.GetPriceableItemTemplate(new PCIdentifier(bpt1.ID.Value), out rbpt);

      Assert.AreEqual(bpt1.ID.Value, rbpt.ID.Value);
      Assert.AreEqual(bpt1.Name, rbpt.Name);
      Assert.AreEqual(bpt1.DisplayName, rbpt.DisplayName);
      Assert.AreEqual(bpt1.Description, rbpt.Description);
      Assert.AreEqual(bpt1.PIKind, rbpt.PIKind);
      Assert.IsNotNull(rbpt.LocalizedDescriptions);

      Assert.AreEqual(bpt1.LocalizedDescriptions.Count, rbpt.LocalizedDescriptions.Count);

    }

    private void SaveDiscountTemplate()
    {

      //***********************************************************************/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Flat_DiscountPITemplate template = new Flat_DiscountPITemplate();
      template.Description = string.Format("{0}-{1}", " flat discount-Desc", GUIDHashCode);
      template.DisplayName = string.Format("{0}-{1}", " flat discount-Disp", GUIDHashCode);
      template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
      template.Name = string.Format("{0}-{1}", "flat discount", GUIDHashCode);

      SumOfOnePropertyCounter counter = new SumOfOnePropertyCounter();
      counter.Name = string.Format("{0}-{1}", "flat discount counter", GUIDHashCode);
      counter.Description = string.Format("{0}-{1}", "flat discount counter desc", GUIDHashCode);
      counter.DisplayName = string.Format("{0}-{1}", "flat discount counter displayname", GUIDHashCode);
      counter.A = "metratech.com/FlatDiscount/amount";

      template.Qualifier = counter;
      BiWeeklyUsageCycleInfo bwuci = new BiWeeklyUsageCycleInfo();
      bwuci.StartDay = 17;
      bwuci.StartMonth = 12;
      bwuci.StartYear = 2009;
      template.Cycle = bwuci;

      template.DistributionCounterPropName = string.Format("{0}-{1}", "MySum", GUIDHashCode);


      template.PIKind = PriceableItemKinds.Discount;

      Dictionary<LanguageCode, string> localDesc = new Dictionary<LanguageCode, string>();
      localDesc.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount  desc {IT}", GUIDHashCode));
      localDesc.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount desc {DE}", GUIDHashCode));
      localDesc.Add(LanguageCode.FR, string.Format("{0}-{1}", "flat discount desc {FR}", GUIDHashCode));
      localDesc.Add(LanguageCode.JP, string.Format("{0}-{1}", "flat discount desc {JP}", GUIDHashCode));

      Dictionary<LanguageCode, string> localDisp = new Dictionary<LanguageCode, string>();
      localDisp.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount-Disp {IT}", GUIDHashCode));
      localDisp.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount-Disp {DE}", GUIDHashCode));
      localDisp.Add(LanguageCode.FR, string.Format("{0}-{1}", "flat discount-Disp {FR}", GUIDHashCode));
      localDisp.Add(LanguageCode.JP, string.Format("{0}-{1}", "flat discount-Disp {JP}", GUIDHashCode));

      template.LocalizedDescriptions = localDesc;
      template.LocalizedDisplayNames = localDisp;


      BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.SavePriceableItemTemplate(ref bpt);

      BasePriceableItemTemplate bpt1;

      client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

      Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

      template = bpt1 as Flat_DiscountPITemplate;

      template.Description = "updated " + template.Description;
      template.DisplayName = "updated " + template.DisplayName;

      Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
      localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount  desc {IT}", GUIDHashCode));
      localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount desc {DE}", GUIDHashCode));

      Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
      localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount-Disp {IT}", GUIDHashCode));
      localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount-Disp {DE}", GUIDHashCode));

      template.LocalizedDisplayNames = localDisp1;
      template.LocalizedDescriptions = localDesc1;


      SumOfTwoPropertiesCounter counter1 = new SumOfTwoPropertiesCounter();
      counter1.Description = "updated " + template.Qualifier.Description;
      counter1.DisplayName = "updated " + template.Qualifier.DisplayName;
      counter1.Name = template.Qualifier.Name;
      counter1.ID = template.Qualifier.ID.Value;
      counter.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
      counter.LocalizedDescriptions.Add(LanguageCode.FR, counter1.Description + "{FR}");

      counter.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
      counter.LocalizedDisplayNames.Add(LanguageCode.FR, counter1.DisplayName + "{FR}");

      counter1.B = "metratech.com/FlatDiscount/price";
      counter1.A = "metratech.com/FlatDiscount/amount";

      template.Qualifier = counter1;




      bpt1 = template as BasePriceableItemTemplate;
      client.SavePriceableItemTemplate(ref bpt1);

      BasePriceableItemTemplate rbpt;
      client.GetPriceableItemTemplate(new PCIdentifier(bpt1.ID.Value), out rbpt);


      Assert.AreEqual(bpt1.ID.Value, rbpt.ID.Value);
      Assert.AreEqual(bpt1.Name, rbpt.Name);
      Assert.AreEqual(bpt1.DisplayName, rbpt.DisplayName);
      Assert.AreEqual(bpt1.Description, rbpt.Description);
      Assert.AreEqual(bpt1.PIKind, rbpt.PIKind);
      Assert.IsNotNull(rbpt.LocalizedDescriptions);

      Assert.AreEqual(bpt1.LocalizedDescriptions.Count, rbpt.LocalizedDescriptions.Count);

    }



    private void SaveAndVerifyUsagePITemplateFails()
    {
      //MTProductCatalogClass pc = new MTProductCatalogClass();
      //MTPriceableItemTypeClass piType = (MTPriceableItemTypeClass)pc.GetPriceableItemTypeByName("Flat Discount");
      //IMTPriceableItem pi = piType.CreateTemplate(true);

      //ProductCatalogServiceClient client = new ProductCatalogServiceClient();

    }

    private void SaveAndVerifyDiscountPITemplate()
    {
      #region Discount PI Template Test.

      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Flat_DiscountPITemplate discount = new Flat_DiscountPITemplate();

      string Description = string.Format("{0}-{1}", "Flat-Disc-Desc", GUIDHashCode);
      string DisplayName = string.Format("{0}-{1}", "Flat-disc-Disp", GUIDHashCode);
      string Name = string.Format("{0}-{1}", "Flat Discount", GUIDHashCode);
      string CounterName = string.Format("{0}-{1}", "flat discount counter", GUIDHashCode);
      string CounterDescription = string.Format("{0}-{1}", "flat discount counter desc", GUIDHashCode);
      string CounterDisplayName = string.Format("{0}-{1}", "flat discount counter disp", GUIDHashCode);

      discount.Name = Name;
      discount.Description = Description;
      discount.DisplayName = DisplayName;
      discount.PIKind = PriceableItemKinds.Discount;

      BiWeeklyUsageCycleInfo cycle = new BiWeeklyUsageCycleInfo();
      cycle.StartDay = 10;
      cycle.StartMonth = 11;
      cycle.StartYear = 2009;
      discount.Cycle = cycle;

      MTPropertyMetaData md = new MTPropertyMetaDataClass();

      SumOfOnePropertyCounter counter = new SumOfOnePropertyCounter();
      counter.Name = CounterName;
      counter.Description = CounterDescription;
      counter.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
      counter.LocalizedDescriptions.Add(LanguageCode.FR, CounterDescription + "{FR}");
      counter.DisplayName = CounterDisplayName;
      counter.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
      counter.LocalizedDisplayNames.Add(LanguageCode.FR, CounterDisplayName + "{FR}");


      counter.A = "metratech.com/FlatDiscount/amount";

      discount.Qualifier = counter;

      BasePriceableItemTemplate bpt = discount as BasePriceableItemTemplate;

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.Open();

      client.SavePriceableItemTemplate(ref bpt);

      discount = bpt as Flat_DiscountPITemplate;

      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

      list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));
      list.PageSize = 100;
      client.GetPriceableItemTemplates(ref list);

      Assert.IsNotNull(list);
      Assert.IsNotEmpty(list.Items);

      Flat_DiscountPITemplate template = list.Items.First() as Flat_DiscountPITemplate;

      Assert.AreEqual(discount.DisplayName, template.DisplayName);
      Assert.AreEqual(discount.Description, template.Description);

      BasePriceableItemTemplate bTemplateDetail = new Flat_DiscountPITemplate() as BasePriceableItemTemplate;

      client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
      Flat_DiscountPITemplate templateDetail = bTemplateDetail as Flat_DiscountPITemplate;


      Assert.IsNotNull(templateDetail.Cycle);
      Assert.IsInstanceOf(typeof(BiWeeklyUsageCycleInfo), templateDetail.Cycle);
      //StartYear and StartMonth are not relevant. It is converted and stored as Jan2000 in database.  
      //Assert.AreEqual((int)((BiWeeklyUsageCycleInfo)discount.Cycle).StartYear, (int)((BiWeeklyUsageCycleInfo)templateDetail.Cycle).StartYear);
      //Assert.AreEqual((int)((BiWeeklyUsageCycleInfo)discount.Cycle).StartMonth, (int)((BiWeeklyUsageCycleInfo)templateDetail.Cycle).StartMonth);
      //Assert.AreEqual((int)((BiWeeklyUsageCycleInfo)discount.Cycle).StartDay, (int)((BiWeeklyUsageCycleInfo)templateDetail.Cycle).StartDay);

      Counter c = (Counter)templateDetail.GetValue(templateDetail.GetProperties().First(p => p.Name.ToLower().Equals("qualifier")));
      Assert.AreEqual(CounterName, c.Name);
      Assert.AreEqual(CounterDescription, c.Description);


      foreach (PropertyInfo p in template.GetMTProperties())
      {
        //TODO: Fix needed for enumeration issues
        //if (p.Name.ToLower() == "pikind")
        //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
      }
      #endregion
    }

    private void SaveAndVerifyUnitDepRecurringPITemplate()
    {
      #region Unit Dependent Recurring Test.
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();

      Unit_Dependent_Recurring_ChargePITemplate rc = new Unit_Dependent_Recurring_ChargePITemplate();

      string GlName = string.Format("{0}-{1}", "GlName", GUIDHashCode);

      string Description = string.Format("{0}-{1}", "UDRecur-Desc", GUIDHashCode);
      string DisplayName = string.Format("{0}-{1}", "UDRecur-Disp", GUIDHashCode);
      string Name = string.Format("{0}-{1}", "Unit Dep Recurring", GUIDHashCode);
      string UnitName = string.Format("{0}-{1}", "Unit Name", GUIDHashCode);
      string UnitDisplayName = string.Format("{0}-{1}", "Unit Display Name", GUIDHashCode);

      rc.Name = Name;
      rc.Description = Description;
      rc.DisplayName = DisplayName;
      rc.PIKind = PriceableItemKinds.UnitDependentRecurring;

      WeeklyUsageCycyleInfo cycle = new WeeklyUsageCycyleInfo();
      cycle.DayOfWeek = System.DayOfWeek.Tuesday;
      rc.Cycle = cycle;
      rc.ChargeAdvance = false;
      rc.ProrateOnActivation = true;
      rc.ProrateInstantly = false;
      rc.ProrateOnDeactivation = false;
      rc.ChargePerParticipant = false;
      rc.FixedProrationLength = true;

      //foreach (MTProperty prop in rc.Properties)
      //{
      //  if (prop.Name.ToLower() == "glcode")
      //      prop.Value = GlName;
      //}


      rc.UnitName = UnitName;
      rc.UnitDisplayName = UnitDisplayName;
      rc.IntegerUnitValue = false;
      rc.MinUnitValue = 10.00M;
      rc.MaxUnitValue = 15.00M;
      rc.AllowedUnitValues.Add(11.00M);
      rc.AllowedUnitValues.Add(12.00M);
      rc.AllowedUnitValues.Add(13.00M);
      rc.AllowedUnitValues.Add(14.00M);
      rc.RatingType = UDRCRatingType.Tapered; ;

      BasePriceableItemTemplate bpt = rc as BasePriceableItemTemplate;


      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();

      client.SavePriceableItemTemplate(ref bpt);

      rc = bpt as Unit_Dependent_Recurring_ChargePITemplate;

      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

      list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));
      list.PageSize = 100;

      client.GetPriceableItemTemplates(ref list);

      Assert.IsNotNull(list);
      Assert.IsNotEmpty(list.Items);

      Unit_Dependent_Recurring_ChargePITemplate template = (Unit_Dependent_Recurring_ChargePITemplate)list.Items.First();

      Assert.AreEqual(rc.DisplayName, template.DisplayName);
      Assert.AreEqual(rc.Description, template.Description);

      BasePriceableItemTemplate bTemplateDetail = new Unit_Dependent_Recurring_ChargePITemplate() as BasePriceableItemTemplate;
      client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
      Unit_Dependent_Recurring_ChargePITemplate templateDetail = bTemplateDetail as Unit_Dependent_Recurring_ChargePITemplate;


      Assert.AreEqual(rc.UnitName, templateDetail.UnitName);
      Assert.AreEqual(rc.UnitDisplayName, templateDetail.UnitDisplayName);
      Assert.AreEqual(rc.IntegerUnitValue, templateDetail.IntegerUnitValue);
      Assert.AreEqual(rc.MinUnitValue, templateDetail.MinUnitValue);
      Assert.AreEqual(rc.MaxUnitValue, templateDetail.MaxUnitValue);
      //templateDetail.GetMTProperties().Find(p => p.Name.ToLower().Contains("glcode") && !p.Name.ToLower().Contains("dirty")).GetValue(templateDetail, null);

      Assert.IsNotNull(templateDetail.Cycle);
      Assert.IsInstanceOf(typeof(WeeklyUsageCycyleInfo), templateDetail.Cycle);
      Assert.AreEqual((int)((WeeklyUsageCycyleInfo)rc.Cycle).DayOfWeek, (int)((WeeklyUsageCycyleInfo)templateDetail.Cycle).DayOfWeek);

      Assert.AreEqual(rc.ChargeAdvance, templateDetail.ChargeAdvance, "ChargeAdvance property in Recurring Template does not match");
      Assert.AreEqual(rc.ProrateOnActivation, templateDetail.ProrateOnActivation);
      Assert.AreEqual(rc.ProrateInstantly, templateDetail.ProrateInstantly);
      Assert.AreEqual(rc.ProrateOnDeactivation, templateDetail.ProrateOnDeactivation);
      Assert.AreEqual(rc.ChargePerParticipant, templateDetail.ChargeAdvance);
      Assert.AreEqual(rc.FixedProrationLength, templateDetail.FixedProrationLength);


      Assert.AreEqual(rc.UnitName, templateDetail.UnitName);
      Assert.AreEqual(rc.UnitDisplayName, templateDetail.UnitDisplayName);
      Assert.AreEqual(rc.IntegerUnitValue, templateDetail.IntegerUnitValue);
      Assert.AreEqual(rc.MinUnitValue, rc.MinUnitValue);
      Assert.AreEqual(rc.MaxUnitValue, rc.MaxUnitValue);


      Assert.AreEqual(rc.AllowedUnitValues.Count, templateDetail.AllowedUnitValues.Count);


      var Query = from td in templateDetail.AllowedUnitValues
                  from id in rc.AllowedUnitValues
                  where td == id
                  select td;

      Assert.AreEqual(Query.Count(), templateDetail.AllowedUnitValues.Count());

      Assert.AreEqual((int)rc.RatingType, (int)templateDetail.RatingType);



      foreach (PropertyInfo p in template.GetMTProperties())
      {
        //TODO: Fix needed for enumeration issues
        //if (p.Name.ToLower() == "pikind")
        //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
      }
      #endregion
    }

    private void SaveAndVerifyRecurringPITemplate()
    {
      #region Recurring Test.
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Flat_Rate_Recurring_ChargePITemplate rc = new Flat_Rate_Recurring_ChargePITemplate();

      string Description = string.Format("{0}-{1}", "Recur-Desc", GUIDHashCode);
      string DisplayName = string.Format("{0}-{1}", "Recur-Disp", GUIDHashCode);
      string Name = string.Format("{0}-{1}", "Flat Rate Recurring", GUIDHashCode);
      string GlName = string.Format("{0}-{1}", "GlName", GUIDHashCode);

      rc.Name = Name;
      rc.Description = Description;
      rc.DisplayName = DisplayName;
      rc.PIKind = PriceableItemKinds.Recurring;

      rc.Glcode = GlName;

      MonthlyUsageCycleInfo cycle = new MonthlyUsageCycleInfo();
      cycle.EndDay = 20;

      rc.Cycle = cycle;

      rc.ChargeAdvance = true;
      rc.ProrateOnActivation = true;
      rc.ProrateInstantly = true;
      rc.ProrateOnDeactivation = true;
      rc.ChargePerParticipant = true;
      rc.FixedProrationLength = true;


      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.Open();

      BasePriceableItemTemplate bpt = rc as BasePriceableItemTemplate;
      client.SavePriceableItemTemplate(ref bpt);
      rc = bpt as Flat_Rate_Recurring_ChargePITemplate;

      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

      list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));
      list.PageSize = 100;
      client.GetPriceableItemTemplates(ref list);

      Assert.IsNotNull(list);
      Assert.IsNotEmpty(list.Items);

      Flat_Rate_Recurring_ChargePITemplate template = (Flat_Rate_Recurring_ChargePITemplate)list.Items.First();

      Assert.AreEqual(rc.DisplayName, template.DisplayName);
      Assert.AreEqual(rc.Description, template.Description);

      BasePriceableItemTemplate bTemplateDetail = new Flat_Rate_Recurring_ChargePITemplate() as BasePriceableItemTemplate;
      client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
      Flat_Rate_Recurring_ChargePITemplate templateDetail = bTemplateDetail as Flat_Rate_Recurring_ChargePITemplate;

      Assert.IsNotNull(templateDetail.Cycle);
      Assert.IsInstanceOf(typeof(MonthlyUsageCycleInfo), templateDetail.Cycle);
      Assert.AreEqual(((MonthlyUsageCycleInfo)rc.Cycle).EndDay, ((MonthlyUsageCycleInfo)templateDetail.Cycle).EndDay);
      Assert.AreEqual(rc.ChargeAdvance, templateDetail.ChargeAdvance, "ChargeAdvance property in Recurring Template does not match");
      Assert.AreEqual(rc.ProrateOnActivation, templateDetail.ProrateOnActivation);
      Assert.AreEqual(rc.ProrateInstantly, templateDetail.ProrateInstantly);
      Assert.AreEqual(rc.ProrateOnDeactivation, templateDetail.ProrateOnDeactivation);
      Assert.AreEqual(rc.ChargePerParticipant, templateDetail.ChargeAdvance);
      Assert.AreEqual(rc.FixedProrationLength, templateDetail.FixedProrationLength);

      Assert.AreEqual(rc.Glcode, templateDetail.Glcode);

      foreach (PropertyInfo p in template.GetMTProperties())
      {
        //TODO: Fix needed for enumeration issues
        //if (p.Name.ToLower() == "pikind")
        //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
      }
      #endregion
    }


    private int SaveAndVerifyNonRecurringPITemplate()
    {
      #region Non Recurring Test.
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();

      Flat_Rate_Non_Recurring_ChargePITemplate pi = new Flat_Rate_Non_Recurring_ChargePITemplate();

      string Description = string.Format("{0}-{1}", "DESC", GUIDHashCode);
      string DisplayName = string.Format("{0}-{1}", "DISP", GUIDHashCode);
      string Name = string.Format("{0}-{1}", "Flat Rate Non Recurring Charge", GUIDHashCode);

      pi.Name = Name;
      pi.Description = Description;
      pi.DisplayName = DisplayName;
      pi.PIKind = PriceableItemKinds.NonRecurring;
      pi.EventType = NonRecurringChargeEvents.Subscribe;

      BasePriceableItemTemplate bpt = pi as BasePriceableItemTemplate;

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.Open();

      client.SavePriceableItemTemplate(ref bpt);
      pi = bpt as Flat_Rate_Non_Recurring_ChargePITemplate;

      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

      list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));

      list.PageSize = 100;
      client.GetPriceableItemTemplates(ref list);


      Assert.IsNotNull(list);
      Assert.IsNotEmpty(list.Items);


      Flat_Rate_Non_Recurring_ChargePITemplate template = (Flat_Rate_Non_Recurring_ChargePITemplate)list.Items.First();

      Assert.AreEqual(pi.DisplayName, template.DisplayName);
      Assert.AreEqual(pi.Description, template.Description);

      foreach (PropertyInfo p in template.GetMTProperties())
      {
        //TODO: Fix needed for enumeration issues
        //if (p.Name.ToLower() == "pikind")
        //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
      }

      BasePriceableItemTemplate bTemplateDetail = new Flat_Rate_Non_Recurring_ChargePITemplate() as BasePriceableItemTemplate;
      client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
      Flat_Rate_Non_Recurring_ChargePITemplate templateDetail = bTemplateDetail as Flat_Rate_Non_Recurring_ChargePITemplate;


      //Assert.AreEqual(GlName, templateDetail.Glcode);

      Assert.AreEqual(pi.DisplayName, template.DisplayName);
      Assert.AreEqual(pi.Description, template.Description);

      return templateDetail.ID.Value;



      #endregion

    }

    private PriceableItemType GetPriceableItemType(PCIdentifier piTypeID)
    {

      ProductCatalogServiceClient prodCatClient = new ProductCatalogServiceClient();
      prodCatClient.ClientCredentials.UserName.UserName = "su";
      prodCatClient.ClientCredentials.UserName.Password = "su123";


      PriceableItemType pit;
      prodCatClient.Open();
      prodCatClient.GetPriceableItemType(piTypeID, out pit);

      Assert.IsNotNull(pit);
      Assert.AreEqual(piTypeID.Name, pit.Name);

      return pit;

    }

    private MTList<PriceableItemType> GetPriceableItemTypes()
    {

      ProductCatalogServiceClient prodCatClient = new ProductCatalogServiceClient();
      prodCatClient.ClientCredentials.UserName.UserName = "su";
      prodCatClient.ClientCredentials.UserName.Password = "su123";
      prodCatClient.Open();
      MTList<PriceableItemType> list = new MTList<PriceableItemType>();

      prodCatClient.GetPriceableItemTypes(ref list);

      return list;
    }
    #endregion

  }
}
    #endregion