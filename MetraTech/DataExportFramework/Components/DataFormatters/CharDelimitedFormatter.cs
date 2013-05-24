using System;
using System.Collections;
using System.IO;
//using MetraTech;
using MetraTech.DataAccess;

namespace MetraTech.DataExportFramework.Components.DataFormatters
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	public class CharDelimitedFormatter : BaseFormatter
	{
		public CharDelimitedFormatter() : base() { __delimiter = ","; }

		protected override int WriteToOutFile(IMTDataReader oReader, bool bPrintHeaderFields, bool bAppendToExistingFile)
		{
			this.__printHeaderFields = bPrintHeaderFields;
			StreamWriter oWriter = null;
			int iCount;

			try
			{
				//If no special output field list is defined, create one with the query result fields
				if (this.__arSpecialFormatInfo.Count <= 0)
				{
					for(int i = 0; i < oReader.FieldCount; i++)
					{
						FieldDefinition fld = new FieldDefinition(oReader.GetName(i));
						fld.Datatype = "string";
						this.__arSpecialFormatInfo.Add(fld);
					}
				}
				else if (oReader.FieldCount > this.__arSpecialFormatInfo.Count)
				{
					//some fields are missing - on purpose? check the "__includeNonListedFields" attribute to confirm:
					if (this.__includeNonListedFields)
					{
						UpdateFieldDefintionWithNonListedFields(oReader);
					}
				}

				//Open the file and write the header
				oWriter = new StreamWriter(this.__outFileName, bAppendToExistingFile, System.Text.Encoding.GetEncoding(1252));

				//Write the headers
				if (this.__printHeaderFields)
				{
					string sFields = "";
					for(int i = 0; i < oReader.FieldCount; i++)
					{
						if(i == oReader.FieldCount - 1)
							sFields += oReader.GetName(i);
						else
							sFields += oReader.GetName(i) + __delimiter;
					}
					try 
					{
						CheckForInvalidFields(sFields);
					}
					catch (Exception ex)
					{
						throw (ex);
					}
					oWriter.WriteLine(FieldsToStreamOut(sFields));
				}

				//Loop through
				iCount = 0;
				System.Text.StringBuilder oCSVData = new System.Text.StringBuilder();
				while(oReader.Read())
				{
					oCSVData.Remove(0, oCSVData.Length);
					IEnumerator enO = this.__arSpecialFormatInfo.GetEnumerator();
					while (enO.MoveNext())
					{
						string sval = "";
						FieldDefinition def = (FieldDefinition)enO.Current;
						if (def.FieldName == "filler")
						{
							sval = "".PadRight(def.Length, def.PadCharacter.ToCharArray()[0]);
						}
						else
						{
							sval = def.FormatThis(oReader.GetValue(((FieldDefinition)enO.Current).FieldName));
						}
						if (def.Datatype.ToLower() == "string")
							if (this.__useQuotedIdentifiers)
								sval = "\"" + sval.Replace("\"", "\"\"") + "\"" + this.__delimiter;
							else
								sval += this.__delimiter;
						else
							sval += this.__delimiter;
						oCSVData.Append(sval);
						/*oCSVData.Append("\"" + oReader.GetValue(
							((FixedLengthDef)enO.Current).FieldName).ToString()
							.Replace("\"", "\"\"") + "\"" + __delimiter);*/
							
					}
					//remove the delimiter appended to the end of the data string
					if (oCSVData.ToString().Length > 0)
						oWriter.WriteLine(oCSVData.ToString().Substring(0, oCSVData.Length - 1));
					else
						oWriter.WriteLine(oCSVData.ToString());

					iCount++;
				}

				return iCount;
			}
			catch(System.Exception e)
			{
				this.__logger.LogError("An error occurred while exporting data to CSV. \n " + e.ToString());
				throw (e);
			}
			finally 
			{
				if (oWriter != null)
				{
					oWriter.Flush();
					oWriter.Close();
				}
			}
		}

		private bool CheckForInvalidFields(string sInFields)
		{
			IEnumerator enO = this.__arSpecialFormatInfo.GetEnumerator();
			while (enO.MoveNext())
			{
				string[] sFields = sInFields.Split(new Char[]{ Convert.ToChar(__delimiter) });
				bool bFound = false;
				foreach (string sField in sFields)
				{	
					if (sField.ToLower() == ((FieldDefinition)enO.Current).FieldName.ToLower())
						bFound = true;
				}
				if (!bFound)
					throw new Exception ("The field \"" + ((FieldDefinition)enO.Current).FieldName + " does not exist in the query");
			}
			return true;
		}

		private string FieldsToStreamOut(string sInFields)
		{
			string sOut = "";
			IEnumerator enO = this.__arSpecialFormatInfo.GetEnumerator();
			while (enO.MoveNext())
			{
				string[] sFields = sInFields.Split(new Char[]{Convert.ToChar(this.__delimiter)});
				foreach (string sField in sFields)
				{
					if (sField.ToLower() == ((FieldDefinition)enO.Current).FieldName.ToLower())
					{
						if (this.__useQuotedIdentifiers)
							sOut += "\"" + ((FieldDefinition)enO.Current).DisplayName + "\"" + this.__delimiter;
						else
							sOut += ((FieldDefinition)enO.Current).DisplayName + this.__delimiter;
					}
				}
			}
			if (sOut.Trim().Length > 0)
				return sOut.Substring(0, sOut.Length - 1);
			else
				return sOut;
		}

	}

	/*public sealed class CSVOutputFields
	{
		private string msFieldName;
		public string FieldName { get { return msFieldName; } set { msFieldName = value; } }

		private string msDisplayName;
		public string DisplayName { get { return msDisplayName; } set { msDisplayName = value; } }

		public CSVOutputFields()
		{
			//NULL CONSTRUCTOR
		}

		public CSVOutputFields(string fieldName)
		{
			msFieldName = fieldName;
			msDisplayName = fieldName;
		}

		public CSVOutputFields(string fieldName, string displayName)
		{
			msFieldName = fieldName;
			msDisplayName = displayName;
		}
	}*/

}
