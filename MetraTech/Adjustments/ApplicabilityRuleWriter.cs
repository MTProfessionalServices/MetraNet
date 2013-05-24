
using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.MTSQL;
using MetraTech.Interop.MTProductCatalog;




namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for ApplicabilityRuleWriter.
  /// </summary>
  /// 
  
  [Guid("8ed5717d-ac6e-4a67-9caa-911ca0928fb1")]
  public interface IApplicabilityRuleWriter
  {
    int Create(IMTSessionContext apCTX, IApplicabilityRule pRule);
    void Update(IMTSessionContext apCTX, IApplicabilityRule pRule);
    void Remove(IMTSessionContext apCTX, IApplicabilityRule pRule);
    void CreateMapping(IMTSessionContext apCTX, IApplicabilityRule pRule, IAdjustmentType aType);
    void RemoveMapping(IMTSessionContext apCTX, IApplicabilityRule pRule, IAdjustmentType aType);
    void RemoveMappings(IMTSessionContext apCTX, IAdjustmentType aType);
  }

	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("7bf31599-b247-4362-9342-df31506fdf01")]
  public class ApplicabilityRuleWriter : ServicedComponent, IApplicabilityRuleWriter
  {
    protected IMTSessionContext mCTX;

    // looks like this is necessary for COM+?
    public ApplicabilityRuleWriter() { }

    [AutoComplete]
    public int Create(IMTSessionContext apCTX, IApplicabilityRule pRule)
    {
      BasePropsWriter basewriter = new BasePropsWriter();
      FormulaWriter formulaWriter = new FormulaWriter();
      int FormulaID = formulaWriter.Create(apCTX, pRule.Formula);
      
      int formulaID = basewriter.CreateWithDisplayName(
        apCTX,
        (int)MTPCEntityType.PCENTITY_TYPE_ADJUSTMENT_APPLIC_RULE,
        pRule.Name, pRule.Description, pRule.DisplayName);

      // set the type ID in the adjustment
      pRule.ID = formulaID;
    
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        //delete adjustment properties first
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__CREATE_APPLICABILITY_RULE__"))
          {
              stmt.AddParam("%%ID_PROP%%", pRule.ID);
              stmt.AddParam("%%GUID%%", "0xABCD");//Rule.ID); TODO: Fix me
              stmt.AddParam("%%ID_FORMULA%%", FormulaID);
              stmt.ExecuteNonQuery();
          }
      }
    
      
      return formulaID;
    }
    
    
    [AutoComplete]
    public void Update(IMTSessionContext apCTX, IApplicabilityRule pRule)
    {
      //check if the rule is used and return error (?)
      FormulaWriter formulaWriter = new FormulaWriter();
      formulaWriter.Update(apCTX, pRule.Formula);
      BasePropsWriter basewriter = new BasePropsWriter();
      basewriter.UpdateWithDisplayName(
        apCTX,
        pRule.Name, pRule.Description, pRule.DisplayName,pRule.ID);
      
    }
    [AutoComplete]
    public void Remove(IMTSessionContext apCTX, IApplicabilityRule pRule)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_APPLICABILITY_RULE__"))
          {
              stmt.AddParam("%%ID_PROP%%", pRule.ID);
              stmt.ExecuteNonQuery();
          }
      }
      BasePropsWriter basewriter = new BasePropsWriter();
      basewriter.Delete(apCTX, pRule.ID);
    }
    [AutoComplete]
    public void CreateMapping(IMTSessionContext apCTX, IApplicabilityRule pRule, IAdjustmentType aType)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__CREATE_APPLIC_MAPPING__"))
          {
              stmt.AddParam("%%ID_ADJUSTMENT_TYPE%%", aType.ID);
              stmt.AddParam("%%ID_APPLIC_RULE%%", pRule.ID);
              stmt.ExecuteNonQuery();
          }
      }
    }

    [AutoComplete]
    public void RemoveMapping(IMTSessionContext apCTX, IApplicabilityRule pRule, IAdjustmentType aType)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_APPLIC_MAPPING__"))
          {
              stmt.AddParam("%%ID_ADJUSTMENT_TYPE%%", aType.ID);
              stmt.AddParam("%%ID_APPLIC_RULE%%", pRule.ID);
              stmt.ExecuteNonQuery();
          }
      }
    }

    [AutoComplete]
    public void RemoveMappings(IMTSessionContext apCTX,IAdjustmentType aType)
    {
      //check if it's used and return error
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REMOVE_APPLIC_MAPPINGS__"))
          {
              stmt.AddParam("%%ID_ADJUSTMENT_TYPE%%", aType.ID);
              stmt.ExecuteNonQuery();
          }
      }
    }

    


  }
  

 
}

