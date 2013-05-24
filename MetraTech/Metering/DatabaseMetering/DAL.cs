using System;
using System.Data;
using System.Reflection;
using System.Collections;
using System.Data.OleDb;
using System.Net;
using System.Diagnostics.CodeAnalysis;

namespace MetraTech.Metering.DatabaseMetering
{
    // SECENG: Fixing SQL injections issue.
    /// <summary>
    /// Represents a database query parameter.
    /// </summary>
    internal class MTDbParameter
    {
        /// <summary>
        /// Gets or sets a parameter value.
        /// </summary>
        internal object Value
        {
            get;
            set;
        }

        /// <summary>
        /// Creates and initialises an instance of <see cref="MTDbParameter"/> class.
        /// </summary>
        /// <param name="name">Indicates a parameter name.</param>
        /// <param name="value">Indicates a parameter value.</param>
        internal MTDbParameter(object value)
        {
            this.Value = value;
        }
    }

	/// <summary>
	///This class is used for making a connection with the database based on the parameters passed. 
	///It also executes SQL queries to return data and updates database.
	/// </summary>
	public class DAL
	{
		private enum ExecEnum
		{
			NonQuery,
			DataTable,
			DataReader
		}

		private string strConnString;

		/// <summary>
		/// Stores the Connection string for creating the Sql connection.
		/// </summary>
		protected string ConnString
		{
			get
			{
				return strConnString;
			}
		}

		/// <summary>
		/// Stores the Sql Connection objects in used.		
		/// </summary>			
		private ArrayList arrConnections;

		/// <summary>
		/// Log object used for logging
		/// </summary>
		Log objLog = null;

		public DAL(ConfigInfo objConfigInfo)
		{
			Init(objConfigInfo.strDBType, objConfigInfo.strDBDataSource, objConfigInfo.Provider, objConfigInfo.strDBServer,
				 objConfigInfo.strDBName, objConfigInfo.strDBUsername, objConfigInfo.strDBPassword, objConfigInfo.strAppendToConnectionString);
		}

		/// <summary>
		/// Constructor. Creates the Connection string.
		/// </summary>
		/// <param name="strDBType">Type of the Database. Possible values are “MSSQL”, “ORACLE”, “MS EXCEL”)</param>
		/// <param name="strDSN">Data Source Name</param>
		/// <param name="strDBServer">Database server</param>
		/// <param name="strDBName">Name of the database</param>
		/// <param name="strUser">Database username</param>
		/// <param name="strPwd">Password for the database user</param>
		public DAL(string dbType, string dsn, string provider, string dbServer, string dbName,
				string user, string pwd, string extraParameters)
		{
			Init(dbType, dsn, provider, dbServer, dbName, user, pwd, extraParameters);
		}

		public void Init(string dbType, string dsn, string provider, string dbServer, string dbName,
						 string user, string pwd, string extraParameters)
		{
			try
			{
				string hostname = Dns.GetHostName();
				arrConnections = new ArrayList();
				if (dbType.ToUpper() == "MSSQL")
					strConnString = "Provider=" + provider + ";Data Source=" + dbServer + ";Initial Catalog=" + dbName + ";User Id=" + user + ";Password=" + pwd + ";Pooling=false;App=Database Metering Program;HostName=" + hostname;
				else if (dbType.ToUpper() == "SYBASE")
					strConnString = "Provider=" + provider + ";Server Name=" + dbServer + ";Database=" + dbName + ";User Id=" + user + ";Password=" + pwd + ";Pooling=false;App=Database Metering Program;HostName=" + hostname;
				else if (dbType.ToUpper() == "ORACLE")
				{
					strConnString = "Data Source=" + dbServer +
									";Provider=" + provider +
									";User Id=" + user +
									";Password=" + pwd +
									";Pooling=false;";
				}
				else
					throw new ApplicationException("Wrong DBType passed.");

				if (extraParameters.Length != 0)
				{
					strConnString = strConnString + ";" + extraParameters;
				}

				objLog = Log.GetInstance();
				if (objLog == null)
					throw new ApplicationException("Couldn't get the instance of the Log");
			}
			catch (Exception exp)
			{
				throw new Exception("Following error occured in the DAL Constructor: " + exp.Message);
			}
		}


		/// <summary>
		/// Executes the update/insert/delete queries.
		/// </summary>
		/// <param name="strSqlQuery">query to be executed</param>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public void Run(string strSqlQuery)
		{
			objLog.LogString(Log.LogLevel.INFO, "[DAL] " + strSqlQuery);
			try
			{
				OleDbConnection objOleDbConn = null;

				OleDbConnection conn = new OleDbConnection();
				objOleDbConn = new OleDbConnection(strConnString);
				objOleDbConn.Open();
				OleDbCommand objSqlCmd = new OleDbCommand(strSqlQuery, objOleDbConn);
				objSqlCmd.CommandTimeout = ConfigInfo.commandTimeout;
				objSqlCmd.CommandType = CommandType.Text;
				objSqlCmd.ExecuteNonQuery();
				objOleDbConn.Close();
				objOleDbConn.Dispose();
			}
			catch (Exception ex)
			{
				string s = ex.Message;
				throw;
			}
		}

		/// <summary>
		/// Executes the query and returns the object of SQLDataReader.
		/// </summary>
		/// <param name="OleDbDataReader">The datareader object connected to the data source</param>
		/// <param name="strSqlQuery">Query (Select) to be executed</param>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public void Run(ref OleDbDataReader objReader, string strSqlQuery)
		{
			objLog.LogString(Log.LogLevel.INFO, "[DAL] " + strSqlQuery);
			OleDbConnection objOleDbConn = null;

			objOleDbConn = new OleDbConnection(strConnString);
			objOleDbConn.Open();
			OleDbCommand objOleDbCmd = new OleDbCommand(strSqlQuery, objOleDbConn);
			objOleDbCmd.CommandTimeout = ConfigInfo.commandTimeout;
			objOleDbCmd.CommandType = CommandType.Text;
			objReader = objOleDbCmd.ExecuteReader(CommandBehavior.SingleResult);
			arrConnections.Add(objOleDbConn);

		}

		/// <summary>
		/// Executes the query and returns the object of DataTable.
		/// </summary>
		/// <param name="objTable">The datatable object containing the data</param>
		/// <param name="strSqlQuery">Query (Select) to be executed</param>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public void Run(DataTable objTable, string strSqlQuery)
		{
			objLog.LogString(Log.LogLevel.INFO, "[DAL] " + strSqlQuery);
			OleDbConnection objOleDbConn = null;
			objOleDbConn = new OleDbConnection(strConnString);
			objOleDbConn.Open();
			OleDbCommand objOleDbCmd = new OleDbCommand(strSqlQuery, objOleDbConn);
			objOleDbCmd.CommandType = CommandType.Text;
			objOleDbCmd.CommandTimeout = ConfigInfo.commandTimeout;
			OleDbDataAdapter adapter = new OleDbDataAdapter();
			adapter.SelectCommand = objOleDbCmd;
			adapter.Fill(objTable);
			adapter.Dispose();
			objOleDbCmd.Dispose();
			objOleDbConn.Dispose();

		}

        internal void RunExecuteNonQuery(string strSqlQuery, MTDbParameter[] parameterList)
		{
			Run(strSqlQuery, parameterList, ExecEnum.NonQuery);
		}

        internal DataTable RunGetDataTable(string strSqlQuery, MTDbParameter[] parameterList)
		{
			return ((DataTable)Run(strSqlQuery, parameterList, ExecEnum.DataTable));
		}

        internal OleDbDataReader RunGetDataReader(string strSqlQuery, MTDbParameter[] parameterList)
		{
			return ((OleDbDataReader)Run(strSqlQuery, parameterList, ExecEnum.DataReader));
		}

		[SuppressMessage("Microsoft.Security", "CA2100")]
        private object Run(string strSqlQuery, MTDbParameter[] parameterList, ExecEnum execType)
		{
		    if (string.IsNullOrEmpty(strSqlQuery))
		    {
		        throw new Exception("Command string is null or empty!");
		    }

		    object result = null;

		    OleDbConnection dbConnection = new OleDbConnection(ConnString);
		    try
		    {
		        dbConnection.Open();
		        using (OleDbCommand queryCommand = new OleDbCommand(strSqlQuery, dbConnection))
		        {
		            if (parameterList != null)
		            {
		                for (int i = 0; i < parameterList.Length; i++)
		                {
		                    object val = parameterList[i].Value != null ? parameterList[i].Value : DBNull.Value;

		                    if (val.GetType() != typeof (string))
		                    {
		                        queryCommand.Parameters.Add(val);
		                    }
		                    else
		                    {
		                        OleDbParameter par = queryCommand.CreateParameter();
		                        par.DbType = DbType.String;
		                        par.Direction = ParameterDirection.InputOutput;
		                        par.Value = val;
		                        par.Size = val.ToString().Length;

		                        queryCommand.Parameters.Add(par);
		                    }
		                }
		            }

		            switch (execType)
		            {
		                case ExecEnum.NonQuery:
		                    queryCommand.ExecuteNonQuery();
		                    break;
		                case ExecEnum.DataTable:
		                    using (OleDbDataAdapter adapter = new OleDbDataAdapter())
		                    {
		                        adapter.SelectCommand = queryCommand;
		                        DataTable objTable = new DataTable();
		                        adapter.Fill(objTable);
		                        result = objTable;
		                    }
		                    break;
		                case ExecEnum.DataReader:
		                    result = queryCommand.ExecuteReader(CommandBehavior.CloseConnection);
		                    break;
		            }
		        }
		    }
		    finally
		    {
		        if (execType != ExecEnum.DataReader)
		        {
		            dbConnection.Close();
		        }
		    }

	        return result;
		}

		/// <summary>
		/// This function is called to close the open connections.
		/// </summary>
		public void Close()
		{
			for (int iCount = 0; iCount < arrConnections.Count; iCount++)
			{
				OleDbConnection objOleDbConn = (OleDbConnection)arrConnections[iCount];
				if (objOleDbConn != null)
				{
					objOleDbConn.Close();
					objOleDbConn.Dispose();
				}
			}
			arrConnections.Clear();
		}
	}
}
