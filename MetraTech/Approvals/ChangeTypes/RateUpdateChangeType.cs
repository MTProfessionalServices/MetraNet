
using System;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTProductCatalog;
using PC = MetraTech.Interop.MTProductCatalog;

namespace MetraTech.Approvals.ChangeTypes
{
  class RateUpdateChangeType: IApprovalFrameworkApplyChange 
  {
    Logger mLogger = new Logger("[Approvals RateUpdate]");

    void IApprovalFrameworkApplyChange.ApplyChange(Change change, string commment, Interop.MTAuth.IMTSessionContext sessionContext)
    {
      mLogger.LogDebug("ApplyChange called");

      //Unbundle the change
      ChangeDetailsHelper incommingChangeDetails = new ChangeDetailsHelper();
      incommingChangeDetails.FromBuffer(change.ChangeDetailsBlob);

      if (incommingChangeDetails.ContainsKey("UpdatedRuleSet"))
      {
        int idParameterTable; 
        int idRateSchedule; 
        string updatedRulesXml; 

        try
        {
          idParameterTable = (int)incommingChangeDetails["ParameterTableId"];
          idRateSchedule = (int)incommingChangeDetails["RateScheduleId"];
          updatedRulesXml = incommingChangeDetails["UpdatedRuleSet"].ToString();
        }
        catch (Exception ex)
        {
          throw new ArgumentException("Change must specify ParameterTableId, RateScheduleId and UpdatedRuleSet", ex);
        }

        MTProductCatalog productCatalog = new MTProductCatalog();
        productCatalog.SetSessionContext(sessionContext as PC.IMTSessionContext);

        IMTParamTableDefinition paramTable = productCatalog.GetParamTableDefinition(idParameterTable);
        IMTRateSchedule rateScheduleToUpdate = paramTable.GetRateSchedule(idRateSchedule);

        MetraTech.Interop.PropSet.IMTConfig propset = new MetraTech.Interop.PropSet.MTConfig();
        bool checksumsMatch;
        MetraTech.Interop.PropSet.IMTConfigPropSet configSetIn = propset.ReadConfigurationFromString(updatedRulesXml, out checksumsMatch);

        rateScheduleToUpdate.RuleSet.ReadFromSet((PC.IMTConfigPropSet)configSetIn);

        rateScheduleToUpdate.SaveWithRules();
      }

    }

  }
}
