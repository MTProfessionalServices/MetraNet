using System;
using System.Xml;
using System.Runtime.InteropServices;
using System.Diagnostics;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.MTSQL;
using MetraTech.Xml;

namespace MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for ApplicabilityRule.
	/// </summary>
	/// 

  [Guid("29842550-60b7-4914-9eeb-b10366b8a901")]
  public interface IApplicabilityRule : IMTPCBase
  {
    void Initialize();
    //bool IsApplicable(IAdjustmentTransaction aTrx);
    bool IsApplicable(object aTrx);
    void FromXML(string xml);

    int Save();

    ICalculationFormula Formula
    {
      set; get;
    }
    
    //TODO: figure out attributes magic 
    //to  allow not to do it
    
    //INamedBaseProperty
    [DispId(0)]
    int ID
    {
      set; get;
    }
    string GUID
    {
      set; get;
    }
    string Name
    {
      set; get;
    }
    string Description
    {
      set; get;
    }
    string DisplayName
    {
      set; get;
    }
    
    //IMTPCBase
    new void SetSessionContext(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCtx);
    new MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContext();

    //IMTProperties
    MetraTech.Interop.MTProductCatalog.IMTProperties Properties
    {
      get;
    }
  }

  [Guid("186bee68-10cd-4b8e-b9b4-0491b588bdbe")]
  [ClassInterface(ClassInterfaceType.None)]
	public class ApplicabilityRule : NamedBaseProperty, IApplicabilityRule, IMTPCBase
	{
		public ApplicabilityRule() : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENT_APPLIC_RULE)
		{
			bInitialized = false;
		}
    public void Initialize()
    {
      Debug.Assert(Formula.Text.Length > 0);
      Formula.Compile();
      bInitialized = true;

    }

    public bool IsApplicable(object trx)//IAdjustmentTransaction aTrx)
    {
      IAdjustmentTransaction aTrx = (IAdjustmentTransaction)trx;
      if(!bInitialized)
        Initialize();
      Formula.Execute(aTrx);
      bool isapplicable = (bool)((MTSQL.Parameter)Formula.Parameters["IsApplicable"]).Value;
      return isapplicable == true;
    }
    public void FromXML(string xml)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.LoadXml(xml);

      string name = doc.GetNodeValueAsString("applicabilityrule/name");
      string description = doc.GetNodeValueAsString("applicabilityrule/description");
      string displayname = doc.GetNodeValueAsString("applicabilityrule/displayname");
      string formula = doc.GetNodeValueAsString("applicabilityrule/formula");
      EngineType engine = (EngineType)doc.GetNodeValueAsEnum(typeof(EngineType), 
                      "applicabilityrule/calculationengine");
      Name = name;
      Description = description;
      DisplayName = displayname;
      Formula.EngineType = engine;
      Formula.Text = formula;
    }
    public int Save()
    {
      IApplicabilityRuleWriter writer = new ApplicabilityRuleWriter();
      //for now try look it up by name and mark for update here
      IApplicabilityRuleReader reader = new ApplicabilityRuleReader();
      IApplicabilityRule existingrule = 
        reader.FindApplicabilityRuleByName
        ((IMTSessionContext)GetSessionContext(), this.Name);
      if (existingrule != null)
      {
        Formula.ID = existingrule.Formula.ID;
        ID = existingrule.ID;
      }
      if(HasID())
        return writer.Create((IMTSessionContext)GetSessionContext(), this);
      else
      {
        writer.Update((IMTSessionContext)GetSessionContext(), this);
        return GetID();
      }
    }
    public ICalculationFormula Formula
    {
      get 
      { 
        if(GetPropertyValue("Formula") == null)
          PutPropertyValue("Formula", 
            new ApplicabilityFormula());
        return (ICalculationFormula)GetPropertyValue("Formula");
      }
      set { PutPropertyValue("Formula", value); }
    }

    private bool bInitialized;

   
	}
}
