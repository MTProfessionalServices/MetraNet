using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;

using MetraTech.Interop.RCD;
//using MetraTech.Interop.GenericCollection;
using MetraTech.Xml;
using System.Xml;
using MetraTech.Interop.MTProductCatalog;


namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for ApplicabilityRuleFileReader.
  /// </summary>
  /// 
  [Guid("fbae62ec-2c19-419a-b432-4d2b27a4478e")]
  public interface IApplicabilityRuleFileReader
  {
    IApplicabilityRule FindApplicabilityRuleByName(IMTSessionContext apCTX, string aName);
    MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRules(IMTSessionContext apCTX);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("268b046a-5c14-440a-b296-395807010605")]
  public class ApplicabilityRuleFileReader : IApplicabilityRuleFileReader
  {
    private IMTRcd mRcd;
    private MetraTech.Interop.GenericCollection.IMTCollection mRules;
   
    public ApplicabilityRuleFileReader()
    { 
      mRcd = new MTRcdClass();
      mRules = new MetraTech.Interop.GenericCollection.MTCollectionClass();
    }

    public MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRules(IMTSessionContext apCTX)
    {
      if(mRules.Count == 0)
        return GetApplicabilityRulesInternal(apCTX);
      else
        return mRules;

    }
    
    public IApplicabilityRule FindApplicabilityRuleByName(IMTSessionContext apCTX, string aName)
    {
      if(mRules.Count == 0)
        GetApplicabilityRulesInternal(apCTX);
      foreach(IApplicabilityRule code in mRules)
      {
        if(string.Compare(code.Name, aName, true) == 0)
          return code;
      }
      throw new AdjustmentException(string.Format("Applicability Rule {0} not found", aName));
    }
    
    
    protected MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRulesInternal(IMTSessionContext apCTX) 
    {
      try
      {
        MTRcdFileList files = (MTRcdFileList)MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("ApplicabilityRules.xml");
        MTXmlDocument doc = new MTXmlDocument();
        mRules = new MetraTech.Interop.GenericCollection.MTCollectionClass();

        foreach(string file in files)
        {
          doc.Load(file);
          XmlNodeList nodes = doc.SelectNodes("mt_config/applicabilityrule");
          foreach(XmlNode node in nodes)
          {
            IApplicabilityRule rule = new ApplicabilityRule();
            rule.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);
            rule.FromXML(node.OuterXml);
            mRules.Add(rule);
          }
        
        }
      }
      catch(System.Exception ex)
      {
        throw ex;
      }
      return mRules;
    }

    

   
  }

 
}
