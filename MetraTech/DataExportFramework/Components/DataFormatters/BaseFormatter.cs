using System;
using System.Collections;
using System.IO;
using System.Text;
//using MetraTech;

namespace MetraTech.DataExportFramework.Components.DataFormatters
{
	
	public abstract class BaseFormatter  
	{

		protected Logger __logger;
		protected ArrayList __arSpecialFormatInfo = new ArrayList();
		protected bool __printHeaderFields = false;
		protected bool __isAFileCurrentlyOpen = false;
		protected string __outFileName;
		protected bool __includeNonListedFields = true;
		protected bool __useQuotedIdentifiers = true;

		protected string __delimiter = "";

		public BaseFormatter() { }

		public ArrayList SpecialFormatInfo { get { return __arSpecialFormatInfo; } set { __arSpecialFormatInfo = value; } } 

		public Logger MTLogger { set { __logger = value; } }

		public bool IsAFileCurrentlyOpen { get { return this.__isAFileCurrentlyOpen; } set { this.__isAFileCurrentlyOpen = value; } }

		public bool PrintHeaderFields { get { return __printHeaderFields; } set { __printHeaderFields = value; } }

		public string Delimiter { get { return __delimiter; } set { __delimiter = value; } }
	
		public bool IncludeNonListedFields { get { return __includeNonListedFields; } set { __includeNonListedFields = value; } }

		public bool UseQuotedIdentifiers { get { return __useQuotedIdentifiers; } set { __useQuotedIdentifiers = value; } }

		protected abstract int WriteToOutFile(MetraTech.DataAccess.IMTDataReader oReader, bool bPrintHeaderFields, bool bAppendToExistingFile);

//		public virtual void ProcessHeaderTemplate(ArrayList fieldDefs, string templateText, MetraTech.DataAccess.IMTDataReader reader)
//		{
//			string _temp = templateText;
//			IEnumerator _enFields = fieldDefs.GetEnumerator();
//			while (_enFields.MoveNext())
//			{
//				FieldDefinition _fd = (FieldDefinition)_enFields.Current;
//				//
//				if (_fd.Tag.Length > 0 && (_fd.Tag.StartsWith("%%") && _fd.Tag.EndsWith("%%")))
//				{
//					switch (_fd.Tag.ToUpper())
//					{
//						case "%%DATE%%":
//							 _fd.FormatThis(DateTime.Now);
//							break;
////						case "%%PAGE%%":
//							
//					}
//				}
//				
//			}
//		}

		protected void UpdateFieldDefintionWithNonListedFields(MetraTech.DataAccess.IMTDataReader oReader)
		{
			System.Data.DataTable _t = oReader.GetSchema();
			for (int _iCol=0;_iCol<oReader.FieldCount;_iCol++)
			{
				string _colName = oReader.GetName(_iCol);
				if (!IsFieldInSpecialFormatList(_colName))
				{
					FieldDefinition _fld = new FieldDefinition(_colName, _colName);
					_fld.Datatype = "string";
					_fld.PadCharacter = "";
					this.__arSpecialFormatInfo.Add(_fld);
				}
			}
		}
		
		protected bool IsFieldInSpecialFormatList(string fieldName)
		{
			IEnumerator _enFields = this.__arSpecialFormatInfo.GetEnumerator();
			while (_enFields.MoveNext())
			{
				if (((FieldDefinition)_enFields.Current).FieldName.ToLower() == fieldName.ToLower())
					return true;
			}
			return false;
		}

		public virtual void DoWriteFile(ArrayList fieldDefs)
		{
			StringBuilder oData = new StringBuilder();
			IEnumerator enheaderFields = fieldDefs.GetEnumerator();
			while (enheaderFields.MoveNext())
			{
				FieldDefinition fldDef = (FieldDefinition)enheaderFields.Current;
				if (fldDef.FieldName.ToLower() == "filler")
				{
					oData.Append("".PadRight(fldDef.Length, fldDef.PadCharacter.ToCharArray()[0]));
				}
				else
				{
					oData.Append(fldDef.FormatThis(fldDef.Value));
				}
			}

			StreamWriter oWriter = new StreamWriter(this.__outFileName, this.__isAFileCurrentlyOpen, System.Text.Encoding.GetEncoding(1252));
			oWriter.WriteLine(oData.ToString());
			oWriter.Flush();
			oWriter.Close();
		}

		public virtual void DoWriteFile(ArrayList fieldDefs, string delimiter)
		{
			StringBuilder oData = new StringBuilder();
			IEnumerator enheaderFields = fieldDefs.GetEnumerator();
			while (enheaderFields.MoveNext())
			{
				FieldDefinition fldDef = (FieldDefinition)enheaderFields.Current;
				if (fldDef.FieldName.ToLower() == "filler")
				{
					oData.Append("".PadRight(fldDef.Length, fldDef.PadCharacter.ToCharArray()[0]) + delimiter);
				}
				else
				{
					oData.Append(fldDef.FormatThis(fldDef.Value) + delimiter);
				}
			}

			StreamWriter oWriter = new StreamWriter(this.__outFileName, this.__isAFileCurrentlyOpen, System.Text.Encoding.GetEncoding("iso-8859-1"));
			oWriter.WriteLine(oData.ToString());
			oWriter.Flush();
			oWriter.Close();
		}
		
		public virtual int GenerateOutFile(MetraTech.DataAccess.IMTDataReader oReader, string sOutFile, bool bPrintHeaderFields)
		{
			try
			{
				this.__outFileName = sOutFile;
				return WriteToOutFile(oReader, bPrintHeaderFields, false);
			}
			catch (Exception ex)
			{
				throw (ex);
			}
		}

		public void BeginFileWrite(string sOutFile, bool bPrintHeaderFields)
		{
			this.__outFileName = sOutFile;
			this.__printHeaderFields = bPrintHeaderFields;
			this.__isAFileCurrentlyOpen = true;
		}

		public virtual int DoWriteFile(MetraTech.DataAccess.IMTDataReader oReader, bool bPrintHeaderFields)
		{
			try
			{
				return WriteToOutFile(oReader, bPrintHeaderFields, true);
			}
			catch (Exception ex)
			{
				throw (ex);
			}
		}

		public virtual void DoWriteFile(string sData)
		{
			StreamWriter _writer = null;
			try 
			{
				_writer = new StreamWriter(this.__outFileName, true, System.Text.Encoding.GetEncoding("iso-8859-1"));
				_writer.WriteLine(sData);
				_writer.Flush();
			}
			catch (Exception ex)
			{
				throw (ex);
			}
			finally
			{
				if (_writer != null)
					_writer.Close();
			}

		}

		public void EndFileWrite()
		{
			this.__isAFileCurrentlyOpen = false;
		}
	}
}
