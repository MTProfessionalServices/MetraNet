using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;

using MetraTech.Interop.Rowset;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess;
using MetraTech.Interop.QueryAdapter;

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

    /// <summary>
    /// Helper method to load a particular query and return the text so it
    /// can be used in a parameterized query
    /// </summary>
    /// <param name="queryTag"></param>
    /// <returns></returns>
    private static string GetQueryText(string initFolder, string queryTag)
    {
        if (string.IsNullOrEmpty(initFolder))
        {
            throw new ArgumentException("The argument \"initFolder\" must not be null or empty.");
        } 
        
        if (string.IsNullOrEmpty(queryTag))
        {
            throw new ArgumentException("The argument \"queryTag\" must not be null or empty.");
        }

        using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
        {
            queryAdapter.Item = new MTQueryAdapterClass();
            queryAdapter.Item.Init(initFolder);
            queryAdapter.Item.SetQueryTag(queryTag);
            return queryAdapter.Item.GetRawSQLQuery(true);
        }
    }

    [AutoComplete]
    public void Update(IMTSessionContext apCTX, ICalculationFormula pFormula)
    {
      pFormula.Compile();
      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(FormulaWriter.GetQueryText("Queries\\\\Adjustments", "__UPDATE_CALC_FORMULA__")))
        {
          stmt.AddParam("TX_TEXT", MTParameterType.WideString, pFormula.Text);
          stmt.AddParam("ID_ENGINE", MTParameterType.Integer, (int)pFormula.EngineType);
          stmt.AddParam("ID_FORMULA", MTParameterType.Integer, pFormula.ID);
          stmt.ExecuteNonQuery();
        }
      }
    }

    [AutoComplete]
    public void UpdateByAdjustmentTypeID(IMTSessionContext apCTX, ICalculationFormula pFormula, int aAdjustmentTypeID)
    {
      pFormula.Compile();
      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(FormulaWriter.GetQueryText("Queries\\\\Adjustments", "__UPDATE_CALC_FORMULA_BY_ADJUSMENT_TYPE_ID__")))
        {
          stmt.AddParam("TX_TEXT", MTParameterType.WideString, pFormula.Text);
          stmt.AddParam("ID_ENGINE", MTParameterType.Integer, (int)pFormula.EngineType);
          stmt.AddParam("ID_AJ_TYPE", MTParameterType.Integer, aAdjustmentTypeID);
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
