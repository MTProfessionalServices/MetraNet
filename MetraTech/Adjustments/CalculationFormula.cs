using System;

using MetraTech.Interop.Rowset;
using MTSQL = MetraTech.MTSQL;
using System.Runtime.InteropServices;
using System.Collections;
using System.Text.RegularExpressions;
using MetraTech.Interop.MTProductCatalog;

namespace MetraTech.Adjustments
{
  [Guid("7e7a7f9f-9803-4484-b72b-4aee1d1b3b79")]
  public enum EngineType {MTSQL=1, CSHARP, VBSCRIPT};

	[Guid("f314ded7-0df3-41b3-905b-93b396f0bd2a")]
	public interface ICalculationFormula
  {
    string Text
    {
      get;set;
    }

		string FormulaHeader
		{
			get;
		}
		string FormulaBody
		{
			get;
		}

    Hashtable Parameters
    {
      get;//set;
    }
    int  ID
    {
      get;set;
    }
    EngineType EngineType
    {
      get;set;
    }
    int Save();
    void Execute(IAdjustmentTransaction aTrx);
    void Compile();
  }
  /// <summary>
  /// Summary description for CalculationFormula.
  /// </summary>
  /// 
  [Guid("e8c19e92-a6da-40f7-bbe8-006b53b85ec4")]
  [ClassInterface(ClassInterfaceType.None)]
  public class CalculationFormula : PCBase, ICalculationFormula
  {
    public  CalculationFormula()
    {
      mEngineType = EngineType.MTSQL;
      mEngine = null;
    }
    public virtual string Text
    {
      //get { return GetPropertyValue("Text"); }
      //set { PutPropertyValue("Text", value); }
      get { return mText; }
      set 
			{ 
				mFormulaHeader = string.Empty;
				mFormulaBody = string.Empty;
				mText = value; 
			}
    }
    public virtual int ID
    {
      //get { return GetPropertyValue("ID"); }
      //set { PutPropertyValue("ID", value); }
      get { return mID; }
      set { mID = value; }
    }
    public virtual Hashtable Parameters
    {
      get
      {
        if(mEngine == null)
          return new Hashtable();
        return mEngine.ProgramParameters;
      }
			/*
			set
			{
				if(mEngine == null)
					mEngine = AdjustmentEngineManager.CreateEngine(mEngineType);
				mEngine.ProgramParameters = value;
			}
			*/
    }
    public virtual EngineType EngineType
    {
      get { return mEngineType; }
      set { mEngineType = value; }
    }
    public virtual int Save()
    {
      //compile formula for validation
      Compile();
      FormulaWriter writer = new FormulaWriter();
      return writer.Create
        ((IMTSessionContext)GetSessionContext(), this);
    }
		public void Execute()
		{
			mEngine.Execute();
		}
    public virtual void Execute(IAdjustmentTransaction aTrx)
    {
      //iterate through engine program parameters
      //for every param first try to get it from Inputs list on aTrx
      //and then (for optional, non-required parameters) try to fetch it from
      //source record rowset, and then execute
      try
      {
        AdjustmentCache.GetInstance().GetLogger().LogDebug(String.Format("Executing MTSQL formula for {0} Adjustment Type", 
          aTrx.AdjustmentType == null ? "<UNKNOWN>" : aTrx.AdjustmentType.Name));

        AdjustmentCache.GetInstance().GetLogger().LogDebug("Binding formula input parameters");
        foreach(MTSQL.Parameter param in mEngine.ProgramParameters.Values)
        {
          string name = param.Name;
          if(param.Direction == MTSQL.ParameterDirection.In)
          {
            if(!aTrx.Inputs.Exist(name) || aTrx.Inputs[name] == null)
            {
              //parameter not found on the list of input properties
              //attempt to get it from PV record
              //records come back as c_***. Append 'c_' to parameter name for now
              //if property is not internal

              object val;
              string colname = name.ToLower();

              if(!aTrx.UsageRecord.ContainsKey(colname))
              {
                colname = colname.Insert(0, "c_");
                if (!aTrx.UsageRecord.ContainsKey(colname))
                  throw new AdjustmentException(System.String.Format("Property {0} is required for formula to execute.", name));
              }
              
              val = aTrx.UsageRecord[colname];
              AdjustmentCache.GetInstance().GetLogger().LogDebug(String.Format("Setting {0} parameter value to {1}", name, val));
							//CR 11766 fix: convert DBNull to null
							if (val is System.DBNull)
							{
								val = null;
							}
              param.Value = val;
            }
            else
            {
              object val = null;
              switch( ((IMTProperty)aTrx.Inputs[name]).DataType)
              {
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
                {
                  val = TypeConverter.ConvertInteger(((IMTProperty)aTrx.Inputs[name]).Value);
                  break;
                }
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
                {
                  val = TypeConverter.ConvertDecimal(((IMTProperty)aTrx.Inputs[name]).Value);
                  break;
                }
                case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DOUBLE:
                {
                  val = TypeConverter.ConvertDouble(((IMTProperty)aTrx.Inputs[name]).Value);
                  break;
                }
                default:
                {
                  val = ((IMTProperty)aTrx.Inputs[name]).Value;
                  break;
                }
              }
              AdjustmentCache.GetInstance().GetLogger().LogDebug(String.Format("Setting {0} parameter value to {1}", name, val));
              param.Value = val;
            }
          }
        }
        mEngine.Execute();
        
      }
      catch(Exception ex)
      {
        System.Console.Out.WriteLine(ex.Message);
        System.Console.Out.WriteLine(ex.StackTrace);
        // ESR-5376 log the Exception to MTLOG and then throw the error 
        AdjustmentCache.GetInstance().GetLogger().LogError("Ex.Message : {0} ", ex.Message);
        AdjustmentCache.GetInstance().GetLogger().LogError("Ex.StackTrace : {0} ", ex.StackTrace);
        throw;
      }

    }

    public virtual void Compile()
    {
      try
      {
        if(mEngine == null)
          mEngine = AdjustmentEngineManager.CreateEngine(mEngineType);
        mEngine.Compile(mText);
      }
      catch(Exception ex)
      {
        //log
        throw ex;
      }
    }

		public string FormulaHeader
		{
			get
			{
				ParseText();
				return mFormulaHeader;
			}
			
		}
		public string FormulaBody
		{
			get
			{
				ParseText();
				return mFormulaBody;
			}
		}

		private void ParseText()
		{
			lock(typeof(CalculationFormula))
			{
				if(mFormulaHeader.Length == 0)
				{
					if(Text.Length == 0)
						throw new AdjustmentException("Formula Text not set");
					Regex regex = new Regex(@"(.+[^(\s+AS\s+)])\s+(AS)\s", RegexOptions.Singleline|RegexOptions.IgnoreCase);
					Match m = regex.Match(Text);
					if(m.Success == false)
					{
						throw new AdjustmentException(string.Format("Invalid MTSQL formula [{0}]", Text));
					}
					mFormulaHeader = (string)m.Value;
					mFormulaBody = Text.Substring(mFormulaHeader.Length);
				}
			}
		}
    
    private string mText;
		private string mFormulaHeader;
		private string mFormulaBody;
    private EngineType mEngineType;
    private MTSQL.IExecutionEngine mEngine;
    private int mID;
  }

}
