using System;
using System.Collections;
using System.IO;
using System.Text;
//using Metratech;
using MetraTech.DataAccess;

namespace MetraTech.DataExportFramework.Components.DataFormatters
{
	/// <summary>
	/// Summary description for FixedLengthFormatter.
	/// </summary>
	public class FixedLengthFormatter : BaseFormatter
	{
		public FixedLengthFormatter() : base() { __delimiter = ""; }

		protected override int WriteToOutFile(IMTDataReader oReader, bool bPrintHeaderFields, bool bAppendToExistingFile)
		{
			this.__printHeaderFields = bPrintHeaderFields;
			StreamWriter oWriter = null;
			try 
			{
				StringBuilder oData = new StringBuilder();
          
				//Open the file and write the header
				IEnumerator enFields = this.__arSpecialFormatInfo.GetEnumerator();
				
				oWriter = new StreamWriter(this.__outFileName, bAppendToExistingFile, System.Text.Encoding.GetEncoding(1252));
				
				if (__printHeaderFields)
				{
					while (enFields.MoveNext())
					{
						FieldDefinition oFdl = (FieldDefinition)enFields.Current;						
						if (oFdl.FieldName.ToLower() == "filler")
						{
							oData.Append("".PadRight(oFdl.Length, oFdl.PadCharacter.ToCharArray()[0]));
						}
						else
						{
							oData.Append(oFdl.FormatHeader(oFdl.FieldName));
						}
					}
					oWriter.WriteLine(oData.ToString());
				}
				//Loop through
				int iCount = 0;
				while(oReader.Read())
				{
					oData.Remove(0, oData.Length);
					enFields.Reset();
					while (enFields.MoveNext())
					{
						FieldDefinition oFdl = (FieldDefinition)enFields.Current;						
						if (oFdl.FieldName.ToLower() == "filler")
						{
							oData.Append("".PadRight(oFdl.Length, oFdl.PadCharacter.ToCharArray()[0]) + this.__delimiter);
						}
						else
						{
							oData.Append(oFdl.FormatThis(oReader.GetValue(oFdl.FieldName)) + this.__delimiter);
						}
					}

					oWriter.WriteLine(oData.ToString());	
					iCount++;
				}

				oWriter.Flush();
				return iCount;

			}
			catch(System.Exception e)
			{
				this.__logger.LogError("An error occurred while exporting data to FixedLength Format file \n" + e.ToString());
				throw (e);
			}
			finally
			{
				if (oWriter != null)
				{
					oWriter.Close();
				}
			}
		}



	}

	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	/// <summary>
	/// This class instance will hold special field definitions for a field for Fixedlength Data Feed Export Adapter.
	/// Once instance can hold one field's defintions
	/// </summary>
	public sealed class FieldDefinition 
	{

		/// <summary>
		/// Name of the field thats been picked up for export.
		/// </summary>
		private string msName;

		private string msTag = "";

		private string msDisplayName = "";
		
		private object mobjvalue;

		/// <summary>
		/// Total allocated length of the this data field
		/// </summary>
		private int miLength = 0;

		/// <summary>
		/// Data Type of the data for this field.
		/// Values that can be used are:
		///		- string
		///		- int
		///		- decimal
		///		- bool/boolean
		///		- datetime
		/// </summary>
		private string msDatatype = "none";

		/// <summary>
		/// Direction in which the data should be aligned.
		/// Vlaues that can be used are:
		///		- left
		///		- right
		/// </summary>
		private string msAlign = "left";

		/// <summary>
		/// Character that needs be used for the padding.
		/// Value can be any valid character.
		/// </summary>
		private string msPadCharacter = " ";

		private bool mbNoPadding = false;

		/// <summary>
		/// Index of the current Field Definition object instance.
		/// </summary>
		private int miIndex;

		/// <summary>
		/// Format that should be used when processing the data for this Field Definition object instance.
		/// Following formats are supported:
		///		string  - no formatting is required
		///		int		- no formatting is required
		///		decimal - N&lt;Num digits to the right of decimal point&gt;
		///				examples
		///					- N1 = would be 1 digits to the right of decimal point
		///					- N2 = would be 2 digits to the right of decimal point...etc...
		///		datetime
		///			mmddyyyy
		///			ddmmyyyy
		///			mmddyy
		///			ddmmyy
		///			mm-dd-yyyy
		///			dd-mm-yyyy
		///			dd-mm-yy
		///			mm-dd-yy
		///			mm/dd/yyyy
		///			dd/mm/yyyy
		///			mm/dd/yy
		///			dd/mm/yy
		///		bool/boolean
		///			y/n
		///			0/1
		///			true/false
		/// </summary>
		private string msFormat;

		private bool mbDecimalPoint = true;

		public FieldDefinition(){ }
		public FieldDefinition(string fieldName){ this.msName = fieldName; }
		public FieldDefinition(string fieldName, string displayName){ this.msName = fieldName; this.DisplayName = displayName; }

		/// <summary>
		/// Determines if a decimal point is streamed out with the output for decimal data type.
		/// </summary>
		public bool DecimalPoint { get { return mbDecimalPoint; } set { mbDecimalPoint = value; } }

		/// <summary>
		/// Data Type of the data for this field.
		/// Values that can be used are:
		///		- string
		///		- int
		///		- decimal
		///		- bool/boolean
		///		- datetime
		/// </summary>
		public string Datatype { get{ return msDatatype; } set{ msDatatype = value; } }

		public object Value { get{ return mobjvalue; } set{ mobjvalue = value; } }

		/// <summary>
		/// Total allocated length of the this data field
		/// </summary>
		public int Length { get{ return miLength; } set{ miLength = value; } }

		/// <summary>
		/// Name of the field thats been picked up for export.
		/// </summary>
		public string FieldName { get { return msName; } set{ msName = value; } }

		public string Tag { get { return msTag; } set { msTag = value; } }

		public string DisplayName 
		{ 
			get 
			{
				if (msDisplayName.Length == 0)
					return msName;
				else
					return msDisplayName;
			}
			set { msDisplayName = value; }
		}

		/// <summary>
		/// Character that needs be used for the padding.
		/// Value can be any valid character.
		/// </summary>
		public string PadCharacter { get { return msPadCharacter; } set{ msPadCharacter = value; } }

		public bool NoPadding { get { return mbNoPadding; } set { mbNoPadding = value; } }

		/// <summary>
		/// Direction in which the data should be aligned.
		/// Vlaues that can be used are:
		///		- left
		///		- right
		/// </summary>
		public string Align { get{ return msAlign; } set{ msAlign = value; } }

		/// <summary>
		/// Index of the current Field Definition object instance.
		/// </summary>
		public int Index { get { return miIndex; } set { miIndex = value; } }

		/// <summary>
		/// Format that should be used when processing the data for this Field Definition object instance.
		/// Following formats are supported:
		///		string  - no formatting is required
		///		int		- no formatting is required
		///		decimal - N&lt;Num digits to the right of decimal point&gt;
		///				examples
		///					- N1 = would be 1 digits to the right of decimal point
		///					- N2 = would be 2 digits to the right of decimal point...etc...
		///		datetime
		///			mmddyyyy
		///			ddmmyyyy
		///			mmddyy
		///			ddmmyy
		///			mm-dd-yyyy
		///			dd-mm-yyyy
		///			dd-mm-yy
		///			mm-dd-yy
		///			mm/dd/yyyy
		///			dd/mm/yyyy
		///			mm/dd/yy
		///			dd/mm/yy
		///		bool/boolean
		///			y/n
		///			0/1
		///			true/false
		/// </summary>
		public string DataFormat { get { return msFormat; } set { msFormat = value; } }

		/// <summary>
		/// Accepts an object type, based on the current field definition datatype
		/// converts and formats the object to the specified format.
		/// </summary>
		/// <param name="oData"></param>
		/// <returns></returns>
		public string FormatThis(object oData)
		{	
			switch (this.msDatatype.ToLower())
			{
				case "string":
					if (oData == null || oData == System.DBNull.Value)
						return FormatThis("");
					else
						return FormatThis(Convert.ToString(oData));
				case "decimal":
					if (oData == null || oData == System.DBNull.Value)
						return FormatThis("0");
					else
						return FormatThis(Convert.ToDecimal(oData));
				case "int":
					if (oData == null || oData == System.DBNull.Value)
						return FormatThis(0);
					else
						return FormatThis(Convert.ToString(oData));
				case "datetime":
					if (oData == null || oData == System.DBNull.Value)
						return FormatThis("");
					else
						return FormatThis(Convert.ToDateTime(oData));
				case "bool":
				case "boolean":
					try 
					{
						if (oData == null || oData == System.DBNull.Value)
							return FormatThis(false);
						else
							return FormatThis(Convert.ToBoolean(oData));
					}
					catch 
					{
						return FormatThis(false);
					}
				default:
					if (oData == null || oData == System.DBNull.Value)
						return FormatThis("");
					else
						return FormatThis(Convert.ToString(oData));
			}
		}

		/// <summary>
		/// Formats a bool data to the specified format for this field definition object instance
		/// </summary>
		/// <param name="bData"></param>
		/// <returns></returns>
		public string FormatThis(bool bData)
		{	
			switch (this.msFormat)
			{
				case "y/n":
					return FormatThis(bData?"y":"n");
				case "Y/N":
					return FormatThis(bData?"Y":"N");
				case "true/false":
					return FormatThis(bData?"true":"false");
				case "TRUE/FALSE":
					return FormatThis(bData?"TRUE":"FALSE");
				case "0/1":
					return FormatThis(bData?"1":"0");
				default:
					return FormatThis(bData?"1":"0");
			}

		}

		/// <summary>
		/// Formats a string data to the specified format for this field definition object instance
		/// </summary>
		/// <param name="bData"></param>
		/// <returns></returns>
		public string FormatThis(string sData)
		{
			sData = (sData == null)?"":sData;
			
			if (this.miLength == 0)	//No length given - just return the data as is.
				return sData;

			if (mbNoPadding)
				return sData;

			int iLen = sData.Length;
			if (iLen > this.miLength)	//length less than provided data length - trim it before returning
			{
				return sData.Substring(0, this.miLength);
			}
			else if (iLen == this.miLength)
				return sData;
			else 
			{
				for (int i=0;i<(this.miLength - iLen);i++)
				{
					if (this.msAlign == "right")
						return sData.PadLeft(this.miLength, PadCharacter.ToCharArray()[0]);
					else
						return sData.PadRight(this.miLength, PadCharacter.ToCharArray()[0]);
				}
			}
			return sData;
		}

		/// <summary>
		/// Format the header fields of the export file.
		/// </summary>
		/// <param name="sHeader"></param>
		/// <returns></returns>
		public string FormatHeader(string sHeader)
		{
			sHeader = (sHeader == null)?"":sHeader;
			int iLen = sHeader.Length;
			if (iLen > this.miLength)
			{
				return sHeader.Substring(1, this.miLength);
			}
			else if (iLen == this.miLength)
				return sHeader;
			else 
			{
				return sHeader.PadRight(this.miLength, ' ');
			}
		}

		/// <summary>
		/// Formats a decimal data to the specified format for this field definition object instance
		/// </summary>
		/// <param name="bData"></param>
		/// <returns></returns>
		public string FormatThis(decimal dcData)
		{
			try 
			{
				if (this.mbDecimalPoint)
					return FormatThis(dcData.ToString(this.msFormat).Replace(",", ""));
				else
					return FormatThis(dcData.ToString(this.msFormat).Replace(",", "").Replace(".",""));
			}
			catch 
			{
				return dcData.ToString().Replace(",", "").Replace(".", "");
			}
		}

		/// <summary>
		/// Formats a datetime data to the specified format for this field definition object instance
		/// </summary>
		/// <param name="bData"></param>
		/// <returns></returns>
		public string FormatThis(DateTime dtData)
		{
			if (this.msFormat.Length > 0)
			{
				this.msFormat = this.msFormat.ToLower();
				this.msFormat =  this.msFormat.Replace("m", "M");	//for the month. needs to be MM or MMM
				this.msFormat =  this.msFormat.Replace("hh:", "HH:"); //for the hour - needs to be HH: for military time
				//rollback capitalization done above to fix the minutes. Needs to be mm: 
				this.msFormat =  this.msFormat.Replace("MM:", "mm:");
				return FormatThis(dtData.ToString(this.msFormat));
			}
			else
				return FormatThis(dtData.ToString("MM/dd/yyyy HH:mm:ss"));	//default if no format provided.
			}
		}
	}

	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


