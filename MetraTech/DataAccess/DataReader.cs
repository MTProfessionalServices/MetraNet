using MetraTech.Xml;
using System.IO;
using System;
using System.Data;
using System.Data.Common;
using System.Diagnostics;
using System.Data.OleDb;
using System.Xml;
using System.Collections.Generic;

namespace MetraTech.DataAccess
{
	public class ReaderBase : IDisposable
	{
		protected IDataReader mReader;

		public virtual  bool IsClosed
		{
			get { return mReader.IsClosed; }
		}

		public virtual  void Close()
		{
			mReader.Close();
		}

    ~ReaderBase()
    {
      Dispose();
    }

		public virtual void Dispose()
		{
			if(!IsClosed) Close();
			mReader.Dispose();

      GC.SuppressFinalize(this);
		}

		public virtual  int GetOrdinal(String col)
		{
			return mReader.GetOrdinal(col);
		}

		public virtual  bool GetBoolean(String col)
		{
			return GetMTBoolean(col);
		}

		public virtual  DateTime GetDateTime(String col)
		{
			return GetDateTime(mReader.GetOrdinal(col));
		}

		public virtual  Decimal GetDecimal(String col)
		{
			return GetDecimal(mReader.GetOrdinal(col));
		}

		public virtual  int GetInt32(String col)
		{
			return GetInt32(mReader.GetOrdinal(col));
		}

		public virtual  long GetInt64(String col)
		{
			return GetInt64(mReader.GetOrdinal(col));
		}

		public virtual  String GetString(String col)
		{
			return GetString(mReader.GetOrdinal(col));
		}

		public virtual  String GetConvertedString(String col)
		{
			return GetConvertedString(mReader.GetOrdinal(col));
		}

		public virtual  byte [] GetBytes(String col)
		{
			return GetBytes(mReader.GetOrdinal(col));
		}


		public virtual  object GetValue(String col)
		{
			return GetValue(mReader.GetOrdinal(col));
		}

		public virtual  bool IsDBNull(String col)
		{
			return mReader.IsDBNull(mReader.GetOrdinal(col));
		}

		public virtual  Type GetType(String col)
		{
			return GetType(mReader.GetOrdinal(col));
		}

		public virtual  TypeCode GetTypeCode(String col)
		{
			return GetTypeCode(mReader.GetOrdinal(col));
		}

        public virtual Guid GetGuid(String col)
        {
            return GetGuid(mReader.GetOrdinal(col));
        }


		public virtual  bool GetBoolean(int idx)
		{
			return GetMTBoolean(idx);
		}

		public virtual  DateTime GetDateTime(int idx)
		{
			return mReader.GetDateTime(idx);
		}

		public virtual  Decimal GetDecimal(int idx)
		{
			return mReader.GetDecimal(idx);
		}

		public virtual int GetInt32(int idx)
		{
			return (int)mReader.GetInt32(idx);
		}

		public virtual  long GetInt64(int idx)
		{
			return mReader.GetInt64(idx);
		}

		public virtual  String GetString(int idx)
		{
			return mReader.GetString(idx);
		}

		public virtual  String GetConvertedString(int idx)
		{
			if (IsDBNull(idx))
				return "";

			switch(GetTypeCode(idx))
			{
				case TypeCode.Boolean:
					return GetBoolean(idx).ToString();
				case TypeCode.DateTime:
					return GetDateTime(idx).ToString("s") + "Z";
				case TypeCode.Decimal:
					return GetDecimal(idx).ToString();
				case TypeCode.Int32:
					return GetInt32(idx).ToString();
				case TypeCode.Int64:
					return GetInt64(idx).ToString();
				case TypeCode.String:
					return GetString(idx);
				case TypeCode.Object:
                    if (GetType(idx).Name == "Byte[]")
                        return Convert.ToBase64String(GetBytes(idx));
                    else if (GetType(idx).Name == "Guid")
                        return GetGuid(idx).ToString();
                    else
                        throw new DataAccessException("Unsupported Type: " + GetType(idx).Name);
				case TypeCode.DBNull:
					return "";
				case TypeCode.Empty:
					return "";
				default:
					throw new DataAccessException("Unsupported Type: " + GetType(idx).Name);
			}
		}

		/// <summary>
		/// Retrieve in a single array the entire contents of a VARBINARY or LOB column.
		/// <exception cref="MetraTech.DataAccess.DataAccessException">Thrown when the length of the data exceeds <code>System.Int32.MaxValue</code></exception>
		/// </summary>
		public virtual  byte [] GetBytes(int idx)
		{
			long len = mReader.GetBytes(idx, 0, null, 0, 0);
			if (len > Int32.MaxValue) 
			{
				throw new DataAccessException("Cannot read binary data with length greater than " + Int32.MaxValue);
			}
			byte [] buf = new byte [len];
			len = mReader.GetBytes(idx, 0, buf, 0, (int) buf.Length);
			return buf;
		}

		public virtual  object GetValue(int idx)
		{
			return mReader.GetValue(idx);
		}

		public virtual  String GetName(int idx)
		{
			// oracle returns columns names all caps. existing code
			// expects the lower cased columns returned by sqlsvr.
			return mReader.GetName(idx).ToLower();
		}


		public virtual  bool IsDBNull(int idx)
		{
			return mReader.IsDBNull(idx);
		}

		public virtual  Type GetType(int idx)
		{
			return mReader.GetFieldType(idx);
		}

		public virtual  TypeCode GetTypeCode(int idx)
		{
			return Type.GetTypeCode(GetType(idx));
		}

        public virtual Guid GetGuid(int idx)
        {
            return mReader.GetGuid(idx);
        }

		public virtual  bool Read()
		{
			return mReader.Read();
		}

		public int FieldCount
		{
			get
			{
				return mReader.FieldCount;
			}
		}

    public virtual String ToXml(String rowTag)
    {
      return ToXml(rowTag, null, null);
    }

    public virtual String ToXml(String rowTag, Dictionary<string,string> propertyNameMapping)
    {
      return ToXml(rowTag, propertyNameMapping, null);
    }

    public virtual String ToXml(String rowTag, Dictionary<string, string> propertyNameMapping, String xmlAppendBeforeClosingTag)
    {
      TextWriter stringWriter = new StringWriter();
      XmlTextWriter xmlWriter = new XmlTextWriter(stringWriter);
      xmlWriter.WriteStartElement(rowTag);
      for (int i = 0; i < FieldCount; i++)
      {
        string tagName = "";
        if ((propertyNameMapping==null) || (!propertyNameMapping.TryGetValue(GetName(i), out tagName)))
        {
          tagName = GetName(i);
        }
        xmlWriter.WriteElementString(tagName, GetConvertedString(i));
      }
      if (xmlAppendBeforeClosingTag != null)
      {
        xmlWriter.WriteRaw(xmlAppendBeforeClosingTag);
      }
      xmlWriter.WriteEndElement();
      xmlWriter.Close();

      return stringWriter.ToString();
    }

		public virtual  String ReadToXml(String rootTag, String rowTag)
		{
			int rowsRead;
			return ReadToXml(rootTag, rowTag, "", 0, out rowsRead);
		}

		public virtual  String ReadToXml(String rootTag, String rowTag, int maxRows, out int rowsRead)
		{
			return ReadToXml(rootTag, rowTag, "", maxRows, out rowsRead);
		}
  
		public virtual  String ReadToXml(String rootTag, String rowTag, String rowTagInner)
		{
			int rowsRead;
			return ReadToXml(rootTag, rowTag, rowTagInner, 0, out rowsRead);
		}

    /// <remarks>see interface for full description<remarks>
    /// <param name="rowTagInner">"" if not provided</param>
    /// <param name="maxRows">0  if not provided</param>
    public virtual String ReadToXml(String rootTag, String rowTag, String rowTagInner, int maxRows, out int rowsRead)
    {
      return ReadToXml(rootTag, rowTag, rowTagInner, maxRows, out rowsRead, null);
    }


    /// <remarks>see interface for full description<remarks>
    /// <param name="rowTagInner">"" if not provided</param>
    /// <param name="maxRows">0  if not provided</param>
    public virtual String  ReadToXml(String rootTag, String rowTag, String rowTagInner, int maxRows, out int rowsRead, Dictionary<string, string> propertyNameMapping)
    {
	    rowsRead = 0;

	    System.Text.StringBuilder xml = new System.Text.StringBuilder();
	    xml.Append("<");
	    xml.Append(rootTag);
	    xml.Append(">");

	    // read up to maxRows rows (if maxRows > 0)
	    for (int numRows = 0; maxRows <= 0 || numRows < maxRows; numRows++)
	    {
		    if (!Read())
			    break;

		    rowsRead++;

		    if( rowTagInner.Length == 0)
          xml.Append(ToXml(rowTag, propertyNameMapping));
		    else
		    {
			    xml.Append("<");
			    xml.Append(rowTag);
			    xml.Append(">");
          xml.Append(ToXml(rowTagInner, propertyNameMapping));
			    xml.Append("</");
			    xml.Append(rowTag);
			    xml.Append(">");
		    }
	    }

	    xml.Append("</");
	    int pos;
	    if ((pos=rootTag.IndexOf(' '))!=-1)
	    {
		    xml.Append(rootTag.Substring(0,pos));
	    }
	    else
	    {
		    xml.Append(rootTag);
	    }
	    xml.Append(">");

	    return xml.ToString();
    }

 		protected ReaderBase(IDataReader reader)
		{
			mReader = reader;
		}

		public virtual  bool GetMTBoolean(int aIdx)
		{
			//convert MT "boolean" DB representation
			//which is 'Y'/'1' or 'N'/'0' into real boolean
			string val = mReader.GetString(aIdx).ToUpper();
            char[] bools = { 'Y', 'N', '1', '0' };
			int idx = val.IndexOfAny(bools);
			if (val.Length != 1 || (idx == -1) )
				throw new DataAccessException(String.Format("Boolean field has to be 'Y' or 'N', not <{0}>", val));
            return (val[0] == 'Y' || val[0] == '1') ? true : false;
		}
    
		public virtual  bool GetMTBoolean(string col)
		{
			return GetMTBoolean(mReader.GetOrdinal(col));
		}

		/// <summary>
		/// Return the meta data of the query
		/// </summary>
		public virtual  DataTable GetSchema()
		{
			return mReader.GetSchemaTable();
		}
  
    /// <summary>
    /// Fills a DataTable from a Reader
    /// </summary>
    public virtual DataTable GetDataTable()
    {

      //Debug.Assert(false, "ReaderBase.GetDataTable() doesn't have a defaul impl.  Must override.");
      DataTable dt = new DataTable();
      MTDataAdapter da = new MTDataAdapter();
      int numRows = da.FillFromReader(dt, mReader);
      return dt;
    }

    public virtual bool NextResult()
    {
        return mReader.NextResult();
    }
  }

  /// <summary>
  /// Constructs a DataTable from a DataReader
  /// </summary>
  public class MTDataAdapter : DbDataAdapter
  {
    public int FillFromReader(DataTable dataTable, IDataReader dataReader)
    {
      return this.Fill(dataTable, dataReader);
    }

    protected override RowUpdatedEventArgs CreateRowUpdatedEvent(
      DataRow dataRow,
      IDbCommand command,
      StatementType statementType,
      DataTableMapping tableMapping
      )
    {
      return null;
    }

    protected override RowUpdatingEventArgs CreateRowUpdatingEvent(
      DataRow dataRow,
      IDbCommand command,
      StatementType statementType,
      DataTableMapping tableMapping
      )
    {
      return null;
    }

    protected override void OnRowUpdated(RowUpdatedEventArgs value){}
    
    protected override void OnRowUpdating(RowUpdatingEventArgs value){}
	}
}

  /// <remarks>
  /// The MTDataReader is a layer on top of System.Data.IDataReader.  The MTDataReader
  /// exposes field access by both name and index (unlike IDataReader which only exposes
  /// access by index).
  /// </remarks>
namespace MetraTech.DataAccess.OleDb
{
	public class MTOleDbDataReader : ReaderBase, IMTDataReader, IDisposable
	{
		public MTOleDbDataReader(IDataReader reader) : base(reader){}

    ~MTOleDbDataReader()
    {
      Dispose();
    }

    public override void Dispose()
    {
      base.Dispose();

      GC.SuppressFinalize(this);
    }
	}
}

namespace MetraTech.DataAccess.Oracle
{
	public class MTOracleDataReader : ReaderBase, IMTDataReader, IDisposable
	{
		public MTOracleDataReader(IDataReader reader) : base(reader){}

    ~MTOracleDataReader()
    {
      Dispose();
    }

    public override void Dispose()
    {
      base.Dispose();

      GC.SuppressFinalize(this);
    }

		public override int GetInt32(int idx)
		{
			//BP: NOTE!!!! 
			//Seems like ADP.NET returns
			//NUMBER(10) as Int64
			//NUMBER(38) as Decimal
			//until all the numbers are consistent, 
			//examine RT type
			object val = mReader.GetValue(idx);
			if(val is System.Int64)
				return (int)mReader.GetInt64(idx);
			if(val is System.Decimal)
				return (int)mReader.GetDecimal(idx);
			else
			{
				string msg = string.Format("unhandled Oracle database data type {0} presumed to be integer", val.GetType().ToString());
				Debug.Assert(false, msg);
				throw new ApplicationException(msg);
			}
		}

		public override long GetInt64(int idx)
		{
			//BP: NOTE!!!! 
			//Seems like ADP.NET returns
			//NUMBER(10) as Int64
			//NUMBER(38) as Decimal
			//until all the numbers are consistent, 
			//examine RT type
			object val = mReader.GetValue(idx);
			if(val is System.Int64)
				return (long)mReader.GetInt64(idx);
			if(val is System.Decimal)
				return (long)mReader.GetDecimal(idx);
			else
			{
				string msg = string.Format("unhandled Oracle database data type {0} presumed to be long", val.GetType().ToString());
				Debug.Assert(false, msg);
				throw new ApplicationException(msg);
			}
		}

        // Oracle treat empty strings as NULL. To avoid this we use our own empty string rep[resentation
        // Hence, while reading string from DB we need to convert back to emtpy strings.
        public override String GetString(int idx)
        {
            String value = mReader.GetString(idx);
            if (value == MTEmptyString.Value)
                return "";
            else
                return value;
        }

        public override Guid GetGuid(int idx)
        {
            return new Guid(base.GetBytes(idx));
        }
	}
}