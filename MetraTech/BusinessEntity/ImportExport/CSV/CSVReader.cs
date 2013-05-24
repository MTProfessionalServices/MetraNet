using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Data.OleDb;
using System.Transactions;

namespace MetraTech.BusinessEntity.ImportExport.CSV
{
  public class CSVReader:IDisposable
  {
    private OleDbConnection cn = null;
    private OleDbCommand cmd = null;
    private OleDbDataReader reader = null; 
    private string mFilename = "";

    public CSVReader(string FileName)
    {
      try
      {
        if (!File.Exists(FileName))
          throw new Exception(string.Format("file {0} does not exist", FileName));
        mFilename = FileName;

        string full = Path.GetFullPath(FileName);
        string file = Path.GetFileName(full);
        string dir = Path.GetDirectoryName(full);

        //create the "database" connection string 
        string connString = "Provider=Microsoft.Jet.OLEDB.4.0;" +
            "Extended Properties='text;HDR=Yes;FMT=Delimited;characterset=65001';" +
            "Data Source=" + dir + "\\;";

        //create the database query
        string query = string.Format("SELECT * FROM [{0}]", file);

        //if called within transaction scope we need to supress it, as OleDB does not
        //support transactions for CSV file and will throw ugly exception
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress))
        {
          cn = new OleDbConnection(connString);
          cn.Open();
        }
        cmd = new OleDbCommand(query, cn);
        reader = cmd.ExecuteReader();

      }
      catch (Exception ex)
      {
        throw new Exception(string.Format("Unable to read csv file {0}", FileName), ex);
      }
    }

    /// <summary>
    /// get column headers from CSV file
    /// </summary>
    /// <returns>string list with column headers</returns>
    public List<string> ReadHeader()
    {
      List<string> header = new List<string>();
      for (int i = 0; i < reader.FieldCount; i++)
      {
        header.Add(reader.GetName(i));
      }
      Header = header;
      return header;
    }

    public List<string> Header;

    public void Close()
    {
      if (reader != null)
      {
        reader.Close();
        reader = null;
      }
      if (cn != null)
      {
        cn.Close();
        cn = null;
      }
    }

    #region IDisposable Members

    public void Dispose()
    {
      Close();
    }

    public List<string> Row;

    public Dictionary<string, string> Fields = new Dictionary<string,string>();

    public bool ReadNextRow()
    {
      List<string> row = new List<string>();
      Fields.Clear();
      if (!reader.Read())
      {
        Row = null;
        return false;
      }
      for (int i = 0; i < reader.FieldCount; i++)
      {
        string value = reader.GetValue(i).ToString();
        row.Add(value);
        Fields.Add(Header[i], value);
      }
      Row = row;
      return true;
    }

    #endregion

    ~CSVReader()
    {
      Dispose();
    }

  }
}
