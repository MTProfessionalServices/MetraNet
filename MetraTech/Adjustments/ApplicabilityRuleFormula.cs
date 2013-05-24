using System;
using System.Runtime.InteropServices;
using MetraTech.MTSQL;

namespace MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for ApplicabilityFormula.
  /// </summary>
  /// 

  [Guid("140afa6b-c6a7-474a-9807-6dd4a3b05c4d")]
  public interface IApplicabilityFormula : ICalculationFormula
  {
    string Name
    {
      get;set;
    }
  }
  [Guid("5579b74f-17a8-4ea6-a95e-cf87ba3efcbf")]
  [ClassInterface(ClassInterfaceType.None)]
  public class ApplicabilityFormula : CalculationFormula, IApplicabilityFormula //, ICalculationFormula
  {
    public ApplicabilityFormula()
    {
      //
      // TODO: Add constructor logic here
      //
    }
    public IAdjustmentType AdjustmentType
    {
      get
      {
        return mAJType;
      }
      set
      {
        mAJType = value;
      }
    }

    public override void Compile()
    {
      base.Compile();
      //MetraTech.Adjustments.MTSQL.MTSQLProgramParameter.
      //evaluate parameters
      if(Parameters == null || !Parameters.ContainsKey("IsApplicable") ||  
        ((MTSQL.Parameter)Parameters["IsApplicable"]).DataType != ParameterDataType.Boolean ||
        ((MTSQL.Parameter)Parameters["IsApplicable"]).Direction != ParameterDirection.Out )
      {
        throw new InvalidApplicabilityRule(Name);
      }
    }
    public string Name
    {
      get{return mName;}
      set{mName = value;}
    }

    private IAdjustmentType mAJType;
    private string mName;
  }
}
