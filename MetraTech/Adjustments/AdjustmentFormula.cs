using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.EnterpriseServices;
using MetraTech.MTSQL;
using ProdCat = MetraTech.Interop.MTProductCatalog;

namespace MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for AdjustmentFormula.
	/// </summary>
	/// 
  [Guid("720ebcd9-9c30-4c3d-8d99-96d77cfd743b")]
  [ClassInterface(ClassInterfaceType.None)]
  public class AdjustmentFormula : CalculationFormula, ICalculationFormula
	{
		public AdjustmentFormula()
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
      //evaluate parameter rules
      //1. TotalAdjustmentAmount has to be present
      if(Parameters == null || !Parameters.ContainsKey("TotalAdjustmentAmount") ||  
        ((MTSQL.Parameter)Parameters["TotalAdjustmentAmount"]).DataType != ParameterDataType.Decimal ||
        ((MTSQL.Parameter)Parameters["TotalAdjustmentAmount"]).Direction != ParameterDirection.Out )
      {
        string sAdjustmentType = AdjustmentType == null ? string.Empty : AdjustmentType.Name;
        throw new InvalidAdjustmentFormulaException
          (String.Format("{0} Adjustment Type Formula is missing 'TotalAdjustmentAmount DECIMAL OUTPUT' parameter", sAdjustmentType));
      }
      //2. Only DECIMAL outputs are supported
      foreach(object param in Parameters.Values)
      {
        if( ((MTSQL.Parameter)param).Direction == ParameterDirection.Out && 
          ((MTSQL.Parameter)param).DataType != ParameterDataType.Decimal)
          throw new InvalidAdjustmentFormulaException
            (String.Format("Only DECIMAL output parameters are supported. ({0} is {1})", 
            ((MTSQL.Parameter)param).Name, ((MTSQL.Parameter)param).DataType));
      }
      //3. now check if all charge related output properties were set.
      //this will not be supported for stand alone compilation (mtsqltest etc), because
      //there is no Adjustment/PI type at that point

      //Reenable this check if we decide to change Charge/PI Type API to where PI type owns and manages charges
      //Right now, if we hit this code from PI type hook, the charges are not in place yet, because
      //they are saved in VB AFTER PI type gets saved
      //Too complex to fix now. Besides, this kind of configuration is an SI job, adn they will catch the problem quickly
      /*
      if(AdjustmentType != null)
      {
        int piid = AdjustmentType.PriceableItemTypeID;
        ProdCat.IMTProductCatalog pc = null;
        pc = new ProdCat.MTProductCatalogClass();
        Debug.Assert(pc != null);
        ProdCat.IMTPriceableItemType pit = pc.GetPriceableItemType(piid);
        Debug.Assert(pit != null);
        ProdCat.IMTCollection charges = pit.GetCharges();
        foreach(ProdCat.IMTCharge charge in charges)
        {
          string name = charge.Name;
          string ajpropname = String.Format("AJ_{0}", name);
          if (!Parameters.ContainsKey(ajpropname))
            throw new InvalidAdjustmentFormulaException
              (String.Format("{0} Adjustment Type Formula is missing {1} parameter, required by {2} charge", 
              AdjustmentType.Name, ajpropname, charge.DisplayName));
        }
      }
      */
    }

    private IAdjustmentType mAJType;
	}
}
