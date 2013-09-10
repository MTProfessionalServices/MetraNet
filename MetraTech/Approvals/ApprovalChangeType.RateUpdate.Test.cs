using Microsoft.VisualStudio.TestTools.UnitTesting;

//using MetraTech.Security;
//using MetraTech.DomainModel.Common;
//using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
using MetraTech.DomainModel.BaseTypes;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.PropSet;
using MetraTech.Interop.MTRuleSet;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.RateUpdateTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
// Note: This test that works with rate schedules requires some rate schedule to run with/against
// Run T:\Development\Core\MTProductCatalog\SimpleSetup.vbs to get some basic rates that this unit test will copy and use as its own
namespace MetraTech.Approvals.Test
{
  [TestClass]
  //[Ignore("Rate update tests not ready for prime time")]
  public class RateUpdateTest
  {
    PC.MTProductCatalog mPC;

    private Logger m_Logger = new Logger("[ApprovalManagementTest.RateUpdate]");

    #region tests

    [TestMethod]
    [TestCategory("VerifyWeCanSerializeRateSchedule")]
    public void VerifyWeCanSerializeRateSchedule()
    {
      mPC = new PC.MTProductCatalogClass();
      IMTSessionContext sessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();
      mPC.SetSessionContext((PC.IMTSessionContext)sessionContext);

      PC.IMTRateSchedule rateSchedule = GetRateScheduleForUpdateTest();
      rateSchedule.SaveWithRules();

      //Update the ruleset on this rate schedule to double all the decimal values
      for (int i = 1; i <= rateSchedule.RuleSet.Count; i++)
      {
        MTRule rule = (MTRule)rateSchedule.RuleSet[i];

        foreach (MTAssignmentAction action in rule.Actions)
        {
          string dummy = string.Format("{0}={1} [{2}]", action.PropertyName, action.PropertyValue.ToString(), action.PropertyType.ToString());
          if (action.PropertyType == Interop.MTRuleSet.PropValType.PROP_TYPE_DECIMAL)
            action.PropertyValue = Convert.ToInt32(action.PropertyValue) * 2;
        }
      }
      rateSchedule.SaveWithRules();

      //Bundle up the change
      PC.IMTConfigPropSet configSet = rateSchedule.RuleSet.WriteToSet();

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["PricelistId"] = rateSchedule.PriceListID;
      changeDetails["ParameterTableId"] = rateSchedule.ParameterTableID;
      changeDetails["RateScheduleId"] = rateSchedule.ID;
      changeDetails["UpdatedRules"] = configSet.WriteToBuffer();
      
      string changeDetailsBuffer = changeDetails.ToBuffer();

      //Unbundle the change
      ChangeDetailsHelper incommingChangeDetails = new ChangeDetailsHelper();
      incommingChangeDetails.FromBuffer(changeDetailsBuffer);

      string updatedRulesXml = incommingChangeDetails["UpdatedRules"].ToString();

      PC.IMTParamTableDefinition paramTable = mPC.GetParamTableDefinition((int)incommingChangeDetails["ParameterTableId"]);
      PC.IMTRateSchedule rateScheduleToUpdate = paramTable.GetRateSchedule((int)incommingChangeDetails["RateScheduleId"]);

      MetraTech.Interop.PropSet.IMTConfig propset = new MetraTech.Interop.PropSet.MTConfig();
      bool checksumsMatch;
      MetraTech.Interop.PropSet.IMTConfigPropSet configSetIn = propset.ReadConfigurationFromString(updatedRulesXml, out checksumsMatch);

      rateScheduleToUpdate.RuleSet.ReadFromSet((PC.IMTConfigPropSet)configSetIn);


      //rateSchedule.RuleSet
      rateScheduleToUpdate.SaveWithRules();

    }

    [TestMethod]
    [TestCategory("VerifyWeCanCreateUpdateRateScheduleIndependentOfApprovals")]
    public void VerifyWeCanCreateUpdateRateScheduleIndependentOfApprovals()
    {
      mPC = new PC.MTProductCatalogClass();
      mPC.SetSessionContext((PC.IMTSessionContext)SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges());

      PC.IMTRateSchedule rateSchedule = GetRateScheduleForUpdateTest();
      rateSchedule.SaveWithRules();

      //Update the ruleset on this rate schedule to double all the decimal values
      for (int i = 1; i <= rateSchedule.RuleSet.Count; i++)
      {
        MTRule rule = (MTRule)rateSchedule.RuleSet[i];

        foreach (MTAssignmentAction action in rule.Actions)
        {
          string dummy = string.Format("{0}={1} [{2}]", action.PropertyName, action.PropertyValue.ToString(), action.PropertyType.ToString());
          if (action.PropertyType == Interop.MTRuleSet.PropValType.PROP_TYPE_DECIMAL)
              action.PropertyValue = Convert.ToInt32(action.PropertyValue) * 2;
        }
      }
      rateSchedule.SaveWithRules();

      //Bundle up the change
      PC.IMTConfigPropSet configSet = rateSchedule.RuleSet.WriteToSet();

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["PricelistId"] = rateSchedule.PriceListID;
      changeDetails["ParameterTableId"] = rateSchedule.ParameterTableID;
      changeDetails["RateScheduleId"] = rateSchedule.ID;
      changeDetails["UpdatedRuleSet"] = configSet.WriteToBuffer();

      string changeDetailsBuffer = changeDetails.ToBuffer();

      //Unbundle the change
      ChangeDetailsHelper incommingChangeDetails = new ChangeDetailsHelper();
      incommingChangeDetails.FromBuffer(changeDetailsBuffer);

      string updatedRulesXml = incommingChangeDetails["UpdatedRuleSet"].ToString();

      PC.IMTParamTableDefinition paramTable = mPC.GetParamTableDefinition((int)incommingChangeDetails["ParameterTableId"]);
      PC.IMTRateSchedule rateScheduleToUpdate = paramTable.GetRateSchedule((int)incommingChangeDetails["RateScheduleId"]);

      MetraTech.Interop.PropSet.IMTConfig propset = new MetraTech.Interop.PropSet.MTConfig();
      bool checksumsMatch;
      MetraTech.Interop.PropSet.IMTConfigPropSet configSetIn = propset.ReadConfigurationFromString(updatedRulesXml, out checksumsMatch);

      rateScheduleToUpdate.RuleSet.ReadFromSet((PC.IMTConfigPropSet)configSetIn);


      //rateSchedule.RuleSet
      rateScheduleToUpdate.SaveWithRules();

    }

    [TestMethod]
    [TestCategory("ApplyRateScheduleUpdate")]
    public void ApplyRateScheduleUpdate()
    {
      mPC = new PC.MTProductCatalogClass();
      mPC.SetSessionContext((PC.IMTSessionContext)SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges());

      PC.IMTRateSchedule rateSchedule = GetRateScheduleForUpdateTest();
      rateSchedule.SaveWithRules();

      //Update the ruleset on this rate schedule to double all the decimal values
      for (int i = 1; i <= rateSchedule.RuleSet.Count; i++)
      {
        MTRule rule = (MTRule)rateSchedule.RuleSet[i];

        foreach (MTAssignmentAction action in rule.Actions)
        {
          string dummy = string.Format("{0}={1} [{2}]", action.PropertyName, action.PropertyValue.ToString(), action.PropertyType.ToString());
          if (action.PropertyType == Interop.MTRuleSet.PropValType.PROP_TYPE_DECIMAL)
              action.PropertyValue = Convert.ToInt32(action.PropertyValue) * 2;
        }
      }
      rateSchedule.SaveWithRules();

      //Bundle up the change
      PC.IMTConfigPropSet configSet = rateSchedule.RuleSet.WriteToSet();

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["ParameterTableId"] = rateSchedule.ParameterTableID;
      changeDetails["RateScheduleId"] = rateSchedule.ID;
      changeDetails["UpdatedRuleSet"] = configSet.WriteToBuffer();


      //Make sure approvals are not enabled for RateUpdate so we can apply immediately
      ApprovalsConfiguration approvalsConfig = ApprovalsConfigurationManager.Load();
      approvalsConfig["RateUpdate"].Enabled = false;

      ApprovalManagementImplementation approvalsFramework = new ApprovalManagementImplementation(approvalsConfig);
      approvalsFramework.SessionContext = SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges();

      //Make sure approvals are not enabled for RateUpdate so we can apply immediately
      Change newChange = new Change();
      newChange.ChangeType = "RateUpdate";
      newChange.UniqueItemId = rateSchedule.ID.ToString();
      newChange.ItemDisplayName = "Pricelist [" + rateSchedule.GetPriceList().Name + "] Parameter Table [" + rateSchedule.GetParameterTable().Name + "]";
      newChange.ChangeDetailsBlob = changeDetails.ToBuffer();

      int newChangeId;
      approvalsFramework.SubmitChange(newChange, out newChangeId);


    }

    [TestMethod]
    [TestCategory("SubmitApproveRateScheduleUpdateScenario")]
    public void SubmitApproveRateScheduleUpdateScenario()
    {
      #region Prepare

      mPC = new PC.MTProductCatalogClass();
      mPC.SetSessionContext((PC.IMTSessionContext)SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges());

      PC.IMTRateSchedule rateSchedule = GetRateScheduleForUpdateTest();
      rateSchedule.SaveWithRules();

      //Update the ruleset on this rate schedule to double all the decimal values
      for (int i = 1; i <= rateSchedule.RuleSet.Count; i++)
      {
        MTRule rule = (MTRule)rateSchedule.RuleSet[i];

        foreach (MTAssignmentAction action in rule.Actions)
        {
          string dummy = string.Format("{0}={1} [{2}]", action.PropertyName, action.PropertyValue.ToString(), action.PropertyType.ToString());
          if (action.PropertyType == Interop.MTRuleSet.PropValType.PROP_TYPE_DECIMAL)
              action.PropertyValue = Convert.ToInt32(action.PropertyValue) * 2;
        }
      }
      rateSchedule.SaveWithRules();

      //Bundle up the change
      PC.IMTConfigPropSet configSet = rateSchedule.RuleSet.WriteToSet();

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["ParameterTableId"] = rateSchedule.ParameterTableID;
      changeDetails["RateScheduleId"] = rateSchedule.ID;
      changeDetails["UpdatedRuleSet"] = configSet.WriteToBuffer();
 

      //Create/Populate the change to be submitted for approval
      Change newChange = new Change();
      newChange.ChangeType = "RateUpdate";
      newChange.UniqueItemId = rateSchedule.ID.ToString();
      newChange.ItemDisplayName = "Pricelist [" + rateSchedule.GetPriceList().Name + "] Parameter Table [" + rateSchedule.GetParameterTable().Name + "]";
      newChange.ChangeDetailsBlob = changeDetails.ToBuffer();
      #endregion

      ApprovalTestScenarios.MoveChangeThroughSubmitApproveScenario("SubmitApproveRateScheduleUpdateScenario",
        newChange,
        SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges(),
        SharedTestCodeApprovals.LoginAsUserWhoCanApproveRateUpdate(),
        VerifyRateScheduleHasNotBeenUpdated,
        VerifyRateScheduleHasBeenUpdated,
        rateSchedule);
    }

    [TestMethod]
    [TestCategory("SubmitRateScheduleUpdateScenario")]
    public void SubmitRateScheduleUpdateScenario()
    {
      #region Prepare

      mPC = new PC.MTProductCatalogClass();
      mPC.SetSessionContext((PC.IMTSessionContext)SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges());

      PC.IMTRateSchedule rateSchedule = GetRateScheduleForUpdateTest();
      rateSchedule.SaveWithRules();

      //Update the ruleset on this rate schedule to double all the decimal values
      for (int i = 1; i <= rateSchedule.RuleSet.Count; i++)
      {
        MTRule rule = (MTRule)rateSchedule.RuleSet[i];

        foreach (MTAssignmentAction action in rule.Actions)
        {
          string dummy = string.Format("{0}={1} [{2}]", action.PropertyName, action.PropertyValue.ToString(), action.PropertyType.ToString());
          if (action.PropertyType == Interop.MTRuleSet.PropValType.PROP_TYPE_DECIMAL)
              action.PropertyValue = Convert.ToInt32(action.PropertyValue) * 2;
        }
      }
      rateSchedule.SaveWithRules();

      //Bundle up the change
      PC.IMTConfigPropSet configSet = rateSchedule.RuleSet.WriteToSet();

      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["ParameterTableId"] = rateSchedule.ParameterTableID;
      changeDetails["RateScheduleId"] = rateSchedule.ID;
      changeDetails["UpdatedRuleSet"] = configSet.WriteToBuffer();


      //Create/Populate the change to be submitted for approval
      Change newChange = new Change();
      newChange.ChangeType = "RateUpdate";
      newChange.UniqueItemId = rateSchedule.ID.ToString();
      newChange.ItemDisplayName = "Pricelist [" + rateSchedule.GetPriceList().Name + "] Parameter Table [" + rateSchedule.GetParameterTable().Name + "]";
      newChange.ChangeDetailsBlob = changeDetails.ToBuffer();
      newChange.Comment = "SubmitRateScheduleUpdateScenario doubled decimal values";
      #endregion

      ApprovalTestScenarios.MoveChangeThroughSubmitScenario("SubmitRateScheduleUpdateScenario",
        newChange,
        SharedTestCodeApprovals.LoginAsUserWhoCanSubmitChanges(),
        VerifyRateScheduleHasNotBeenUpdated,
        rateSchedule);
    }
    #endregion

    #region Internal
    public static bool VerifyRateScheduleHasBeenUpdated(Change change, object myUserDefinedObject)
    {
      //TODO: Add verification of rate schedule update
      return true;
    }

    public static bool VerifyRateScheduleHasNotBeenUpdated(Change change, object myUserDefinedObject)
    {
      //TODO: Add verification of rate schedule update
      return true;
    }


    /// <summary>
    /// Returns a rate schedule (copy of a rate schedule) that can be updated/used for testing
    /// Approvals test is agnostic in terms of what rate schedule is returned but because the
    /// test update doubles any rates, conceptually the rate schedule should have at least
    /// one decimal value
    /// </summary>
    /// <returns></returns>
    public PC.IMTRateSchedule GetRateScheduleForUpdateTest()
    {
      PC.IMTRateSchedule sched = null;
      try
      {
      PC.IMTPriceList pl = mPC.CreatePriceList();
      pl.Name = "Approvals Rate Update Test " + DateTime.Now.ToString();
      pl.Description = pl.Name;
      pl.CurrencyCode = "USD";
      pl.Type = PC.MTPriceListType.PRICELIST_TYPE_REGULAR;
      pl.Save();

      // Add song downloads and song session rates.
      // Configure rates onto non-shared pricelist
      PC.IMTPriceableItem piTemplate = mPC.GetPriceableItemByName("Song Downloads");
      int idPriceList = pl.ID;
        PC.IMTParamTableDefinition pt = mPC.GetParamTableDefinitionByName("metratech.com/songdownloads");
        
        sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("12/29/2010");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");
      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
                                       "songdownloads1.xml"));
      sched.SaveWithRules();
      }
      catch (Exception ex)
      {
        throw new Exception(@"GetRateScheduleForUpdateTest Failed to find existing rates in the system. Has T:\Development\Core\MTProductCatalog\SimpleSetup.vbs been run at least once after the database install?:" + ex.Message);
      }

      return sched;

    }
    #endregion
  }
}