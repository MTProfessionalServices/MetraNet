using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using MetraTech;
using System.IO;
using MetraTech.DataAccess;
using MetraTech.Tax.Framework;

namespace MetraTech.Tax.MetraTax.Test
{
    /// <summary>
    /// This class knows the details of the MetraTax parametertables t_pt_taxBand and t_pt_taxRate.
    /// </summary>
    class SqlWizard
    {

        static public void execute(string sqlStatement)
        {
            IMTConnection dbConnection = null;

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
                Console.WriteLine("An error occurred attempting to read taxBand rate schedule: " + e.Message);
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
                execute(sqlStatement);
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

