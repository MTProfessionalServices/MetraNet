using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;

using MetraTech.Interop.Rowset;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess;



namespace  MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for FormulaWriter.
	/// </summary>
	/// 

  [Guid("1afcce4d-7aaf-485f-8890-7fca6e3a2e30")]
  public interface IFormulaWriter
  {
    int Create(IMTSessionContext apCTX, ICalculationFormula pFormula);
    void Update(IMTSessionContext apCTX, ICalculationFormula pFormula);
    void Remove(IMTSessionContext apCTX, IAdjustment pAdjustment);
		void UpdateByAdjustmentTypeID(IMTSessionContext apCTX, ICalculationFormula pFormula, int aAdjustmentTypeID);
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("a63653f9-040a-40c7-9647-5f548d64c5d8")]
  public class FormulaWriter : ServicedComponent, IFormulaWriter
  {
    protected IMTSessionContext mCTX;

    // looks like this is necessary for COM+?
    public FormulaWriter() { }
    
    [AutoComplete]
    public int Create(IMTSessionContext apCTX, ICalculationFormula pFormula)
    {
      int FormulaID = 0;
      //compile first
      pFormula.Compile();
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {

          using (IMTCallableStatement stmt = conn.CreateCallableStatement(
            "CreateCalculationFormula"))
          {

              stmt.AddParam("p_tx_formula", MTParameterType.WideString, pFormula.Text);
              stmt.AddParam("p_id_engine", MTParameterType.Integer, (int)pFormula.EngineType);// TODO fix me pAdjustmentType.GUID);
              stmt.AddOutputParam("op_id_prop", MTParameterType.Integer);
              stmt.ExecuteNonQuery();
              FormulaID = (int)stmt.GetOutputValue("op_id_prop");
              if (FormulaID == -99)
                  throw new ApplicationException("CreateCalculationFormula stored proc returned -99");
          }
      }
      return FormulaID;
    }
    
    [AutoComplete]
    public void Update(IMTSessionContext apCTX, ICalculationFormula pFormula)
    {
			//CR 11770
			//compile first
			pFormula.Compile();
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__UPDATE_CALC_FORMULA__"))
          {
              stmt.AddParam("%%TX_TEXT%%", pFormula.Text);
              stmt.AddParam("%%ID_ENGINE%%", (int)pFormula.EngineType);
              stmt.AddParam("%%ID_FORMULA%%", pFormula.ID);
              stmt.ExecuteNonQuery();
          }
      }
    
    }

		[AutoComplete]
		public void UpdateByAdjustmentTypeID(IMTSessionContext apCTX, ICalculationFormula pFormula,  int aAdjustmentTypeID)
		{
			//CR 11770
			//compile first
			pFormula.Compile();
			using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
			{
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__UPDATE_CALC_FORMULA_BY_ADJUSMENT_TYPE_ID__"))
                {
                    stmt.AddParam("%%TX_TEXT%%", pFormula.Text);
                    stmt.AddParam("%%ID_ENGINE%%", (int)pFormula.EngineType);
                    stmt.AddParam("%%ID_AJ_TYPE%%", aAdjustmentTypeID);
                    stmt.ExecuteNonQuery();
                }
			}
    
		}

    [AutoComplete]
    public void Remove(IMTSessionContext apCTX, IAdjustment pAdjustment)
    {
      //remove is done by adjustment type
      
    }

   }

 
}
