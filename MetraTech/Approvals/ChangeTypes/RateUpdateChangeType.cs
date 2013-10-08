using System.IO;
using System.Xml;
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
		
		
		//ESR-5906
	        //check for existing rule in the schedule
	        bool ruleExists;
	
	        try
	        {
	          XmlReaderSettings settings = new XmlReaderSettings();
	          settings.IgnoreWhitespace = true;
	          settings.IgnoreComments = true;
	          using (XmlReader reader = XmlReader.Create(new StringReader(updatedRulesXml)))
	          {
	            reader.MoveToContent();
	            string content = reader.ReadInnerXml();
            ruleExists = !String.IsNullOrEmpty(content);
	          }
	        }
	        catch (Exception ex)
	        {
	          throw new ArgumentException("Could not parse UpdatedRuleSet", ex);
	        }
	
	        if (ruleExists)
        {
        bool checksumsMatch;
        MetraTech.Interop.PropSet.IMTConfigPropSet configSetIn = propset.ReadConfigurationFromString(updatedRulesXml, out checksumsMatch);

        rateScheduleToUpdate.RuleSet.ReadFromSet((PC.IMTConfigPropSet)configSetIn);
 }
        else
	        {
	          rateScheduleToUpdate.RuleSet.ReadFromSet(null);
	        }
		
        rateScheduleToUpdate.SaveWithRules();
      }

    }

  }
}
