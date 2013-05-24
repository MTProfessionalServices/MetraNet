using System;

namespace MetraTech.Metering.DatabaseMetering
{
	/// <summary>
	/// This structure is used to create the object for the starting primary keys and 
	/// ending primary keys.
	/// </summary>
	public struct FieldFilter
	{
		/// <summary>
		/// Field Name
		/// </summary>
		public string strFieldName;

		/// <summary>
		/// Type of the field
		/// </summary>			
		public string strFieldType;

		/// <summary>
		/// Value of the field
		/// </summary>
		public string strFieldValue;						

		/// <summary>
		/// Returns the delimiter based on the datatype.
		/// </summary>
		/// <returns>delimiter string</returns>
		public string Delimiter()
		{
			string strReturnVal ="'";
			string fieldtype = strFieldType.ToLower();
			if( (fieldtype == "string") || (fieldtype.IndexOf("varchar")>=0) || (fieldtype=="timestamp") )
				strReturnVal = "'";
			else if ( (fieldtype.StartsWith("int")) || (fieldtype=="double") || (fieldtype.StartsWith("bool")) )
				strReturnVal = "";
			return strReturnVal;
		}
	}
}
