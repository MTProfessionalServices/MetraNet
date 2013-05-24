using System;
using ProdCat = MetraTech.Interop.MTProductCatalog;
using System.Runtime.InteropServices;

namespace MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for TypeConverter.
	/// </summary>
	/// 
  [ComVisible(false)]
	public class TypeConverter
	{
		public TypeConverter()
		{
			//
			// TODO: Add constructor logic here
			//
		}
    public static Int32 ConvertInteger(object obj)
    {
      if(obj == null || obj.GetType().Equals(typeof(System.Reflection.Missing)))
        return 0;
      return System.Convert.ToInt32(obj);
    }
    public static Int64 ConvertLong(object obj)
    {
      if(obj == null || obj.GetType().Equals(typeof(System.Reflection.Missing)))
        return 0;
      return System.Convert.ToInt64(obj);
    }
    public static double ConvertDouble(object obj)
    {
      if(obj == null || obj.GetType().Equals(typeof(System.Reflection.Missing)))
        return 0.0;
      else return System.Convert.ToDouble(obj);

    }
    public static decimal ConvertDecimal(object obj)
    {
      if(obj == null || obj.GetType().Equals(typeof(System.Reflection.Missing)))
        return 0.0M;
      else return System.Convert.ToDecimal(obj);

    }
    public static string ConvertString(object obj)
    {
      if(obj == null || obj.GetType().Equals(typeof(System.Reflection.Missing)))
        return "";
      else return System.Convert.ToString(obj);
    }
    public static bool ConvertBoolean(object obj)
    {
      return System.Convert.ToBoolean(obj);
    }
    public static ProdCat.PropValType ConvertStringToMSIX(string dt)
    {
      if (dt.ToLower().CompareTo("int32") == 0 || 
        dt.ToLower().CompareTo("int") == 0 ||
        dt.ToLower().CompareTo("integer") == 0)
        return ProdCat.PropValType.PROP_TYPE_INTEGER;
      if (dt.ToLower().CompareTo("double")== 0)
        return ProdCat.PropValType.PROP_TYPE_DOUBLE;
      if (dt.ToLower().CompareTo("string")== 0 ||
        dt.ToLower().CompareTo("varchar2") == 0)
        return ProdCat.PropValType.PROP_TYPE_STRING;
      if (dt.ToLower().CompareTo("timestamp")== 0 ||
        dt.ToLower().CompareTo("date") == 0)
        return ProdCat.PropValType.PROP_TYPE_DATETIME;
      if (dt.ToLower().CompareTo("boolean")== 0)
        return ProdCat.PropValType.PROP_TYPE_BOOLEAN;
      if (dt.ToLower().CompareTo("object")== 0)
        return ProdCat.PropValType.PROP_TYPE_SET;
      if (dt.ToLower().CompareTo("variant")== 0)
        return ProdCat.PropValType.PROP_TYPE_OPAQUE;
      if (dt.ToLower().CompareTo("enum")== 0)
        return ProdCat.PropValType.PROP_TYPE_ENUM;
      if (dt.ToLower().CompareTo("decimal")== 0 ||
        dt.ToLower().CompareTo("number") == 0)
        return ProdCat.PropValType.PROP_TYPE_DECIMAL;
      if (dt.ToLower().CompareTo("int64")== 0)
        return ProdCat.PropValType.PROP_TYPE_BIGINTEGER;
      else
        throw new AdjustmentException(System.String.Format("Unknown Data Type: <{0}>", dt));
    }

    public static AdjustmentStatus ConvertAdjustmentStatus(string status)
    {
      //NOT_ADJUSTED == 'NA'
      //APPROVED == 'A'
      //PENDING == 'P'
      //DELETED == 'D'
      //AUTODELETED == 'AD'
      //ORPHAN == 'O'
      if (status.ToUpper().CompareTo("NA") == 0)
        return AdjustmentStatus.NOT_ADJUSTED;
      if (status.ToUpper().CompareTo("A") == 0)
        return AdjustmentStatus.APPROVED;
      if (status.ToUpper().CompareTo("P") == 0)
        return AdjustmentStatus.PENDING;
      if (status.ToUpper().CompareTo("D") == 0)
        return AdjustmentStatus.DELETED;
      if (status.ToUpper().CompareTo("AD") == 0)
        return AdjustmentStatus.AUTODELETED;
      if (status.ToUpper().CompareTo("O") == 0)
        return AdjustmentStatus.ORPHAN;
      if (status.ToUpper().CompareTo("REBILL") == 0)
        return AdjustmentStatus.PREBILL_REBILL;
      else
        throw new AdjustmentException(System.String.Format("Unknown Adjustment Type: <{0}>", status));
    }

    public static string ConvertAdjustmentStatus(AdjustmentStatus status)
    {
      //NOT_ADJUSTED == 'NA'
      //APPROVED == 'A'
      //PENDING == 'P'
      //DELETED == 'D'
      //AUTODELETED == 'AD'
      //ORPHAN == 'O'
      switch(status)
      {
        case AdjustmentStatus.NOT_ADJUSTED:{return "NA";}
        case AdjustmentStatus.APPROVED:{return "A";}
        case AdjustmentStatus.PENDING:{return "P";}
        case AdjustmentStatus.DELETED:{return "D";}
        case AdjustmentStatus.AUTODELETED:{return "AD";}
        case AdjustmentStatus.ORPHAN:{return "O";}
        case AdjustmentStatus.PREBILL_REBILL:{return "REBILL";}
        default:
          throw new AdjustmentException(System.String.Format("Unknown Adjustment Type: <{0}>", status));
      }
    }


	}
}
