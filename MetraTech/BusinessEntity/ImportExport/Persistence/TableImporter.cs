using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using MetraTech.DataAccess;
using MetraTech.Interop.NameID;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.ImportExport.CSV;
using MetraTech.BusinessEntity.ImportExport.Metadata;

namespace MetraTech.BusinessEntity.ImportExport.Persistence
{
  public class TableImporter
  {
    private MetraTech.Logger Logger = new MetraTech.Logger("[TableImporter]");
    TableMetadata Table = null;
    String ExportDirectory = "";

    /// <summary>
    /// Import data for the table from Export directory
    /// </summary>
    /// <param name="table">Metadata of the table</param>
    /// <param name="Directory">directory where to look for data file</param>
    public void ImportTable(TableMetadata table, string Directory)
    {
      if (table == null) throw new ArgumentNullException("TableMetadata is null");
      if (Directory == null) throw new ArgumentNullException("Directory is null");
      this.Table = table;
      this.ExportDirectory = Directory;
      try
      {
        Logger.LogInfo("Importing table {0}", table.Name);
        DoImport();
      }
      catch (Exception ex)
      {
        string Msg = string.Format("Unable to import table {0},", table.Name);
        Logger.LogError(Msg, ex.Message);
        throw new Exception(Msg, ex);
      }

    }

    private bool isOracle;

    /// <summary>
    ///truncate table
    ///read record from file
    ///write record to table
    ///close data file
    /// </summary>
    protected void DoImport()
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        isOracle = conn.ConnectionInfo.IsOracle;
        StatementBuilder statementBuilder = StatementBuilderFactory.GetStatementBuilder(conn.ConnectionInfo.IsOracle);

        string insertStr = statementBuilder.BuildInsertStatement(Table);
        string csvFileName = BuildCsvFileName(ExportDirectory, Table);
        CSVReader csvReader = new CSVReader(csvFileName);
        List<string> header = csvReader.ReadHeader();

        while (csvReader.ReadNextRow())
        {
          using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement(insertStr))
          {
            foreach (FieldMetadata field in Table.Fields)
            {
              string val = null;
              if (csvReader.Fields.ContainsKey(field.Name))
              {
                val = csvReader.Fields[field.Name];
              }
              else
              {
                if (!Options.IgnoreMetadataDifferences) 
                  throw new Exception(string.Format("Field {0} not found.", field.Name));
              }

              AddParam(prepStmt, field, val);
            }
            try
            {
              prepStmt.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
              Logger.LogException(string.Format("Error when executing statement:\n{0}\n" +
                "Make sure your BME match what is in the database by running the BME hook", insertStr), ex);
              Logger.LogError("CSV record: {0}", string.Join(",", csvReader.Row.ToArray()));
              throw;
            }
            //Console.WriteLine(string.Format("Read from file: {0}", string.Join(",", csvReader.Row.ToArray())));
          }
        }
        csvReader.Close();
      }
    }

    private void AddParam(IMTPreparedStatement prepStmt, FieldMetadata field, string val)
    {
      // May be it is better to have different types here, not in the string builder
      switch (field.Type)
      {
        case PropertyType.Enum:
          if (string.IsNullOrEmpty(val))
          {
            prepStmt.AddParam(MTParameterType.Integer, null);
          }
          else
          {
            int id = StringToEnumId(val);
            prepStmt.AddParam(MTParameterType.Integer, id);
          }
          break;
        case PropertyType.DateTime:
          if (string.IsNullOrEmpty(val))
          {
            prepStmt.AddParam(MTParameterType.DateTime, null);
          }
          else
          {
            DateTime d = DateTime.Parse(val);
            prepStmt.AddParam(MTParameterType.DateTime, d);
          }
          break;
        default:
          if (string.IsNullOrEmpty(val))
          {
            prepStmt.AddParam(MTParameterType.String, null);
          }
          else
          {
            prepStmt.AddParam(MTParameterType.String, val);
          }
          break;
      }
    }

    /// <summary>
    /// does the lookup in t_enum_data table. inserts the entry there if it is missing.
    /// </summary>
    /// <param name="str">name from t_enum_data table</param>
    /// <returns>id from t_enum_data table</returns>
    private int StringToEnumId(string str)
    {
      IMTNameID nameID = new MTNameIDClass();
      int id = nameID.GetNameID(str);
      return id;
    }

    /// <summary>
    /// Test files for errors. Safer to do it upfront, before loading/deleting data from actual tables
    /// </summary>
    /// <param name="table"></param>
    /// <param name="dir"></param>
    public void TestDataFile(TableMetadata table, string dir)
    {
      string csvFileName = BuildCsvFileName(dir, table);
      Logger.LogDebug("Checking contents of csv file {0}", csvFileName);
      CSVReader csvReader = new CSVReader(csvFileName);
      List<string> header = csvReader.ReadHeader();

      int recordCount = 0;
      while (csvReader.ReadNextRow()) { recordCount++; }
      csvReader.Close();
      Logger.LogDebug("Found {1} records in file: {0}", csvFileName, recordCount);
    }

    private string BuildCsvFileName(string dir, TableMetadata table)
    {
      string csvFileName = string.Format(@"{0}\{1}.csv", dir, table.FileName);
      return csvFileName;
    }

    /// <summary>
    /// Compare the table structure reported by the entity with the
    /// metadata saved during export of the entity. Raise exception if there is a missmatch and log
    /// list of differences in to the log file
    /// </summary>
    /// <param name="table"></param>
    /// <param name="Directory"></param>
    public void CheckTableMetadata(TableMetadata table, string Directory)
    {
      if (table == null) throw new ArgumentNullException("TableMetadata is null");
      if (Directory == null) throw new ArgumentNullException("Directory is null");
      Logger.LogDebug("checking metadata for table {0}", table.Name);
      this.Table = table;
      this.ExportDirectory = Directory;
      try
      {
        TableMetadata tableOriginal = TableMetadata.ReadMetadataFromFile(Directory, table.EntityFullName);
        List<string> differences = new List<string>();
        if (!TableMetadata.Equals(tableOriginal, table, differences))
        {
          Logger.LogWarning("table {0} is different with metadata in the exported file.", table.Name);
          foreach (string diff in differences)
          {
            Logger.LogWarning(diff);
          }
          throw new Exception("Metadata missmatch");
        }
        else
        {
          Logger.LogDebug("Metadata match for table {0}", table.Name);
        }
      }
      catch (Exception ex)
      {
        if (Options.IgnoreMetadataDifferences)
        {
          Logger.LogWarning("Handled exception: {0} {1}", ex.Message, ex.StackTrace);
          Logger.LogWarning("Ignoring metadata differences for table {0}", table.Name);
        }
        else throw;
      }
    }

    public void TruncateTable(TableMetadata table, string dir)
    {
      Logger.LogInfo("Truncating table {0}", table.Name);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        StatementBuilder statementBuilder = StatementBuilderFactory.GetStatementBuilder(conn.ConnectionInfo.IsOracle);
        string deleteStr = statementBuilder.BuildDeleteStatement(table);
        using (IMTStatement deleteStmt = conn.CreateStatement(deleteStr))
        {
          deleteStmt.ExecuteNonQuery();
        }
      }
    }
  }
}
