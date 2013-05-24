using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;
using System.Xml.Serialization;
using System.IO;

using MetraTech.DataAccess;
using MetraTech.Interop.NameID;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.ImportExport.CSV;
using MetraTech.BusinessEntity.ImportExport.Metadata;

namespace MetraTech.BusinessEntity.ImportExport.Persistence
{

  class TableExporter
  {
    private MetraTech.Logger Logger = new MetraTech.Logger("[Export]");

    public TableExporter()
    {

    }

    TableMetadata Table = null;
    String OutputDirectory = "";

    public void ExportTable(TableMetadata table, string Directory)
    {
      if (table == null) throw new ArgumentNullException("TableMetadata is null");
      if (Directory == null) throw new ArgumentNullException("Directory is null");
      Logger.LogInfo("Exporting table {0}", table.Name);
      try
      {
        this.Table = table;
        this.OutputDirectory = Directory;
        table.SaveMetadataToFile(Directory);
        DoExport();
      }
      catch (Exception ex)
      {
        Logger.LogException("Exception when exporting table.", ex);
        string Msg = string.Format("Unable to export table {0},", table.Name);
        throw new Exception(Msg, ex);
      }
    }

    private bool isOracle;

    protected void DoExport()
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        isOracle = conn.ConnectionInfo.IsOracle;
        StatementBuilder statementBuilder = StatementBuilderFactory.GetStatementBuilder(conn.ConnectionInfo.IsOracle);
        string selectStr = statementBuilder.BuildSelectStatement(Table);
        IMTStatement selectSTMT = conn.CreateStatement(selectStr);
        try
        {
          //IMTPreparedStatement pstmt = conn.CreatePreparedStatement("select * from dual");
          using (IMTDataReader selectReader = selectSTMT.ExecuteReader())
          {
            CreateOutputFile();
            try
            {
              while (selectReader.Read())
              {
                WriteRow(selectReader);
              }
            }
            finally
            {
              CloseOutputFile();
            }
          }
        }
        catch (Exception ex)
        {
          Logger.LogException(string.Format("Error when executing statement:\n{0}\n" + 
            "Make sure your BME match what is in the database by running the BME hook", selectStr), ex);
          throw;
        }
      }
    }

    private void CloseOutputFile()
    {
      if (csvWriter != null) csvWriter.Close();
    }

    private void WriteRow(IMTDataReader selectReader)
    {
      List<string> values = new List<string>();
      foreach (FieldMetadata field in Table.Fields)
      {
        object o = selectReader.GetValue(field.Name);
        string str;
        if (field.Type == PropertyType.Guid)
        {
          str = GuidToString(o);
        }
        else
        {
          str = o.ToString();
        }
        //string str = selectReader.GetConvertedString(field.Name);
        if (field.Type == PropertyType.Enum)
        {
          str = EnumIdToString(str);
        }
        values.Add(str);
      }
      //Console.WriteLine(string.Join(",", values.ToArray()));
      csvWriter.WriteRow(values);
    }

    private string GuidToString(object o)
    {
      string str;
      if (isOracle)
      {
        Guid g = new Guid(o as byte[]);
        str = g.ToString();
      }
      else
      {
        str = o.ToString();
      }
      return str;
    }

    private string EnumIdToString(string str)
    {
      if (string.IsNullOrEmpty(str)) return "";
      IMTNameID nameID = new MTNameIDClass();
      int id = int.Parse(str);
      string enumStr = nameID.GetName(id);
      return enumStr;
    }

    private CSVWriter csvWriter;

    private void CreateOutputFile()
    {
      string csvFileName = string.Format(@"{0}\{1}.csv", OutputDirectory, Table.FileName);
      csvWriter = new CSVWriter(csvFileName);
      List<string> header = new List<string>();
      foreach (FieldMetadata field in Table.Fields)
      {
        header.Add(field.Name);
      }
      csvWriter.WriteHeader(header);
    }

  }
}
