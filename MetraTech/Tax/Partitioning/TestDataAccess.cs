using System;
using System.Data;
using System.Data.SqlClient;

// using Oracle.TestDataAccess.Client;  // The Oracle Client Dll should be in ICE\Source\MetraTech\Ref directory

namespace MetraTech.Tax.MetraTax.Test
{
  public sealed class TestDataAccess
  {
    public enum DbType { SqlServer, Oracle }

    private static readonly TestDataAccess m_instance = new TestDataAccess();
   

    public static TestDataAccess Instance
    {
      get 
      {
         return m_instance; 
      }
    }

    // Current database type
    private DbType databaseType;
    public DbType DatabaseType
    {
      get { return databaseType; }
    }

    // Current connection string
    private string connectionString;
    public string ConnectionString
    {
      get { return connectionString; }
    }

    private TestDataAccess ()
    {
      // Load server access configuration from servers.xml
      // TODO:  We don't support encrypted passwords, and no caching is done.
      ServerAccess serverAccess = ServerAccess.Load ();
      Server server = serverAccess [ "NetMeter" ];

      SetupConnection ( server );
    }

    /// <summary>
    /// SetupConnection can be called to change the database server on the fly.
    /// Initially, TestDataAccess will go against the NetMeter server setup in servers.xml
    /// </summary>
    /// <param name="server">ICE.Server located in ServerAccess.cs</param>
    private void SetupConnection ( Server server )
    {
      // Setup Database Type
      if ( server.DatabaseType.ToUpper () == "{SQL SERVER}" )
      {
        databaseType = DbType.SqlServer;
      }
      else if ( server.DatabaseType.ToUpper () == "{ORACLE}" )
      {
        databaseType = DbType.Oracle;
      }
      else
      {
        throw new ApplicationException ( "Unknown database type (" + server.DatabaseType +
                                       ") specified in servers.xml" );
      }

      if ( databaseType == DbType.SqlServer )
      {
        connectionString = "Server=" + server.ServerName + ";" +
                           "uid=" + server.Username + ";" +
                           "pwd=" + server.Password + ";" +
                           "database=" + server.DatabaseName + ";";
        connectionString = "Server=" + server.ServerName + ";" +
                           "uid=" + server.Username + ";" +
                           "pwd=" + "MetraTech1" + ";" +
                           "database=" + server.DatabaseName + ";";
      }
      else
      {
        connectionString = "Data Source=" + server.ServerName + ";" +
                           "User ID=" + server.Username + ";" +
                           "Password=" + server.Password + ";";
      }
    }

    /// <summary>
    /// Executes a SQL string against the NetMeter database specified in servers.xml
    /// </summary>
    /// <param name="SQL"></param>
    /// <returns>DataView of results</returns>
    public DataView Execute ( string SQL )
    {
      if ( databaseType == DbType.SqlServer )
      {
        // SQL Server
        //Console.WriteLine ( connectionString );
        using ( SqlConnection connection = new SqlConnection ( connectionString ) )
        {
          connection.Open ();
          DataSet dataSet = new DataSet ();
          SqlCommand command = new SqlCommand ();
          command.Connection = connection;
          command.CommandText = SQL;

          SqlDataAdapter dataAdapter = new SqlDataAdapter ();
          dataAdapter.SelectCommand = command;
          dataAdapter.Fill ( dataSet );

          DataView dataView = new DataView();
          if ( dataSet.Tables.Count > 0 )
          {
            DataTable dataTable = dataSet.Tables [ 0 ];
            dataView = new DataView ( dataTable );
          }

          return dataView;
        }
      }
      else
      {
        DataView dataView = new DataView ();
        return dataView;
        // ORACLE
        //using ( OracleConnection connection = new OracleConnection ( connectionString ) )
        //{
          //connection.Open ();
          //DataSet dataSet = new DataSet ();
          //OracleCommand command = new OracleCommand ();
          //command.Connection = connection;
          //command.CommandText = SQL;

          //OracleDataAdapter dataAdapter = new OracleDataAdapter ();
          //dataAdapter.SelectCommand = command;
          //dataAdapter.Fill ( dataSet );

          //DataTable dataTable = dataSet.Tables [ 0 ];
          //DataView dataView = new DataView ( dataTable );

          //return dataView;
        //}
      }

      //TODO:  Add support here for stored procs, execute non-query, 
      //       parameters, and %%% replacements 
    }

  }
}
