using System;
using MTSQL = MetraTech.MTSQL;
using System.Runtime.InteropServices;

namespace MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for AdjustmentEngineManager.
	/// </summary>
	/// 
  
  [ComVisible(false)]
	public class AdjustmentEngineManager
	{
   
		private AdjustmentEngineManager()
		{
			//
			// TODO: Add constructor logic here
			//
		}
    public static MTSQL.IExecutionEngine CreateEngine(EngineType aEngineType)
    {
      switch(aEngineType)
      {
        case EngineType.MTSQL:
					return new MTSQL.ExecutionEngine();
        //case EngineType.CSHARP:
        //  return new CSharpAdjustmentEngine();
        default:
          throw new AdjustmentException(String.Format("Unsupported Engine Type: <{0}>", aEngineType));
      }
    }
	}
}
