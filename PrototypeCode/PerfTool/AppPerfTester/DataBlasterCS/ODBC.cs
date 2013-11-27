using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Data;
using System.Data.Odbc;

namespace DataBlasterCS
{
	public class ODBCUtil 
	{
		private static log4net.ILog log4NetLogger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

		public System.Data.Odbc.OdbcConnection conn
		{
			get { return _conn; }
			set { _conn = value; }
		}
		private System.Data.Odbc.OdbcConnection _conn;

		public string connString
		{
			get { return _connString; }
			set { _connString = value; }
		}
		private string _connString;

		public int DriverConnect()
		{
			int ret = 0;
			if (conn == null)
			{
				conn = new System.Data.Odbc.OdbcConnection(connString);
				conn.Open();
			}

			return ret;
		}

		public int Disconnect()
		{
			int ret = 0;
			if (conn != null)
			{
				conn.Close();
			}

			return ret;
		}

		public void Execute(string sql)
		{
			OdbcCommand odbcCommand = new OdbcCommand(sql, conn);
			odbcCommand.ExecuteNonQuery();
		}

		public ConnectionState GetState()
		{
			return conn.State;
		}

		public void ReaderExecute(string sql)
		{
			OdbcCommand odbcCommand = new OdbcCommand(sql, conn);
			OdbcDataReader reader = odbcCommand.ExecuteReader();

			try
			{
				while (reader.Read())
				{
					//Console.WriteLine(reader.GetInt32(0) + ", " + reader.GetString(1));
					object[] values = new object[6];
					Console.WriteLine(reader.GetValues(values));
				}
			}
			finally
			{
				// always call Close when done with connection.
				reader.Close();
			}
		}
	}
}
