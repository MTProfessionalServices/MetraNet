using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;



namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for ApplicabilityRuleReader.
  /// </summary>
  /// 
  [Guid("50260da6-2182-42ed-87a3-cb96328047db")]
  public interface IApplicabilityRuleReader
  {
    IApplicabilityRule FindApplicabilityRule(IMTSessionContext apCTX, int aID);
    IApplicabilityRule FindApplicabilityRuleByName(IMTSessionContext apCTX, string aName);
    MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRulesForAdjustmentType(IMTSessionContext apCTX, int ajTypeID);
  }

  // readers support transactions but do not require them
	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
  [Guid("c4dab158-4099-401a-a713-bcb89dd38711")]
  public class ApplicabilityRuleReader : ServicedComponent, IApplicabilityRuleReader
  {
    protected IMTSessionContext mCTX;

    // looks like this is necessary for COM+?
    public ApplicabilityRuleReader()
    { 
    }
    [AutoComplete]
    public IApplicabilityRule FindApplicabilityRuleByName(IMTSessionContext apCTX, string aName)
    {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_APPLICABILITY_RULES__"))
            {
                stmt.AddParam("%%PREDICATE%%", String.Format("AND base1.nm_name = N'{0}'", aName), true);
                // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    MetraTech.Interop.GenericCollection.IMTCollection coll =
          GetApplicabilityRulesInternal(apCTX, reader);
                    if (coll.Count == 0)
                        return null;
                    //throw new AdjustmentException(System.String.Format("Adjustment Type <{0}> not found", aName));
                    return (IApplicabilityRule)coll[1];
                }
            }
        }   
    }
    
    [AutoComplete]
    public IApplicabilityRule FindApplicabilityRule(IMTSessionContext apCTX, int aID)
    {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_APPLICABILITY_RULES__"))
            {
                stmt.AddParam("%%PREDICATE%%", String.Format("AND art.id_prop = {0}", aID));
                // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    MetraTech.Interop.GenericCollection.IMTCollection coll =
          GetApplicabilityRulesInternal(apCTX, reader);
                    if (coll.Count == 0)
                        return null;
                    //throw new AdjustmentException(System.String.Format("Adjustment Type with ID <{0}> not found", aID));
                    return (IApplicabilityRule)coll[1];
                }
            }
        }
    }

    [AutoComplete]
    public MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRulesForAdjustmentType(IMTSessionContext apCTX, int aAJTypeID)
    {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__LOAD_APPLIC_RULES_FOR_AJ_TYPE__"))
            {
                // g. cieplik CR 12683 use LanguageID of the session to add localization support for adjustments
                stmt.AddParam("%%ID_LANG_CODE%%", apCTX.LanguageID);
                stmt.AddParam("%%ID_AJ_TYPE%%", aAJTypeID);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    MetraTech.Interop.GenericCollection.IMTCollection coll =
                      GetApplicabilityRulesInternal(apCTX, reader);
                    return coll;
                }
            }
        }
    }

    protected MetraTech.Interop.GenericCollection.IMTCollection GetApplicabilityRulesInternal(IMTSessionContext apCTX, IMTDataReader reader) 
    {
      MetraTech.Interop.GenericCollection.IMTCollection mRetCol = new MetraTech.Interop.GenericCollection.MTCollectionClass();
      int previd = 0;
      while(reader.Read())
      {
        int ruleid = reader.GetInt32("RuleID");
        if(ruleid != previd)
        {
          IApplicabilityRule rule = new ApplicabilityRule();
          string rulename = reader.GetString("RuleName");
          string ruledesc = reader.IsDBNull("RuleDescription") ? string.Empty : reader.GetString("RuleDescription");
          string ruledispname = reader.GetString("RuleDisplayName");
          string formula = reader.GetString("RuleFormula");
          object guid = reader.IsDBNull("RuleGUID") ? null : reader.GetValue("RuleGUID");
          int idFormula = reader.GetInt32("RuleFormulaID");
          EngineType engine = (EngineType)reader.GetInt32("RuleFormulaEngine");

          rule.ID = ruleid;
          rule.Name = rulename;
          rule.DisplayName = ruledispname;
          rule.Description = ruledesc;
          rule.GUID = guid.ToString();
          IApplicabilityFormula oFormula = new ApplicabilityFormula();
          oFormula.ID = idFormula;
          oFormula.EngineType = engine;
          oFormula.Text = formula;
          oFormula.Name = rulename;
          rule.Formula = oFormula;
          rule.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)apCTX);
          mRetCol.Add(rule);
          previd = ruleid;
        }
      }
      return mRetCol;
    }

   
  }

 
}
