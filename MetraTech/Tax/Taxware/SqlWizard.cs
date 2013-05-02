using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech;
using System.IO;
using MetraTech.DataAccess;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Taxware.Test;

namespace MetraTech.Tax.MetraTax.Test
{
    /// <summary>
    /// This class knows the details of the MetraTax parametertables t_pt_taxBand and t_pt_taxRate.
    /// </summary>
    class SqlWizard
    {
      static private string ConvertToOracle(string sqlServerString)
      {
        string result = "";
        Regex rgx = new Regex("\\[");
        result = rgx.Replace(sqlServerString, "");

        rgx = new Regex("\\]");
        result = rgx.Replace(result, "");

        rgx = new Regex(" NetMeter.dbo.");
        result = rgx.Replace(result, " ");

        rgx = new Regex("dbo.");
        result = rgx.Replace(result, "");

        rgx = new Regex(" int ");
        result = rgx.Replace(result, " number(10,0) ");

        rgx = new Regex(" bigint ");
        result = rgx.Replace(result, " number(20,0) ");

        rgx = new Regex(" decimal ");
        result = rgx.Replace(result, " number(22,10) ");

        rgx = new Regex(" numeric");
        result = rgx.Replace(result, " number");

        rgx = new Regex(" datetime ");
        result = rgx.Replace(result, " timestamp ");

        rgx = new Regex(" varchar");
        result = rgx.Replace(result, " nvarchar2");

          // '3/15/2012 8:00:00 AM'
        //rgx = new Regex("'\d\d*/\d\d*/\d\d\d\d \d\d*:\d\d:\d\d ..'");
        //result = rgx.Replace(result, " nvarchar2");
         // TO_TIMESTAMP(:ts_val, 'YYYY-MM-DD HH24:MI:SS')



        return result;
      }

      static public void RemoveTable(string tableName, bool isSqlServer)
      {
        if (isSqlServer)
        {
          SqlWizard.execute(
            String.Format("use netmeter; if object_id('{0}') is not null drop table {1}", tableName, tableName),
            isSqlServer);
        }
        else
        {
          SqlWizard.execute(String.Format(
            "begin " +
            "   if table_exists('{0}') then" +
            "       execute immediate 'drop table {1}';" +
            "   end if;" +
            "end;", tableName, tableName),
                            isSqlServer);
        }
      }

      static public void RemoveAllRowsFromTable(string tableName, bool isSqlServer)
      {
        if (isSqlServer)
        {
          SqlWizard.execute(
            String.Format("use netmeter; delete from {0}", tableName),
            isSqlServer);
        }
        else
        {
          SqlWizard.execute(String.Format("delete from {0}", tableName),
                            isSqlServer);
        }
      }

      static public void execute(string sqlStatement, bool isSqlServer)
        {
            IMTConnection dbConnection = null;

            if (!isSqlServer)
            {
              sqlStatement = ConvertToOracle(sqlStatement);
            }

            try
            {
                IMTAdapterStatement statement;
                IMTDataReader reader;

                // Set up the connection and the query
                dbConnection = ConnectionManager.CreateConnection();
                statement = dbConnection.CreateAdapterStatement(sqlStatement);

                // Execute the query and read the results
                reader = statement.ExecuteReader();
                //while (reader.Read());
            }
            catch (Exception e)
            {
                Console.WriteLine(string.Format("An error occurred attempting to execute '{0}': {1}", sqlStatement, e.Message));
                throw new TaxException(e.Message);
            }

            // Silently, close the database connection
            finally
            {
                try
                {
                    if (dbConnection != null)
                        dbConnection.Close();
                }
                catch (Exception)
                {
                }
            }
        }

        static public void executeSqlInFile(string filename)
        {
            string sqlStatement = "starting statement";
            StreamReader reader = new StreamReader(filename);

            while (reader.Peek() >= 0)
            {
                sqlStatement = reader.ReadLine();
                execute(sqlStatement, true);
            }
        }

        static public string getSelectAsXml(string selectStatement)
        {
            DataView usageDataView = TestDataAccess.Instance.Execute(selectStatement); 
            DataTable usageDataTable = usageDataView.ToTable();
            StringWriter receivedWriter = new StringWriter();
            usageDataTable.WriteXml(receivedWriter);
            return receivedWriter.ToString();
        }
    }
}

