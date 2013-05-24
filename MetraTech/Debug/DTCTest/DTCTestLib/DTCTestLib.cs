using System;
using System.EnterpriseServices;
using System.Data;
using System.Data.OleDb;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: Guid("A58EE5A7-4B26-4828-9ECD-8590DA879B0F")]

namespace MetraTech.Debug.DTCTest
{

	[Guid("f4c4eb1f-c503-4bec-ae70-f6274ee4e868")]
  public interface IDTCTest
  {
		string Server
		{
			set; 
		}
		string UserName
		{
			set;
		}

		string Password
		{
			set;
		}

    void Test();
  }
  
	/// <summary>
	/// Serviced component to test DTC configuration 
	/// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("816bfd4f-b4d9-4624-b6c4-95d77900703d")]
  public class DTCTestLib : ServicedComponent, IDTCTest
	{
		public string Server
		{
			get
			{
				return mServer;
			}
			set 
			{
				mServer = value;
			}
		}

		public string UserName
		{
			get
			{
				return mUserName;
			}
			set 
			{
				mUserName = value;
			}
		}

		public string Password
		{
			get
			{
				return mPassword;
			}
			set 
			{
				mPassword = value;
			}
		}
		
		public void Test()
		{
			Console.WriteLine("Testing connectivity to DB server...");
			using (OleDbConnection connection = CreateConnection())	
			{ 
				Console.WriteLine("Connectivity successfully established!");
			
				Console.WriteLine("Creating test table in '{0}' database...", mCatalog);
				ExecuteQuery(connection, "IF OBJECT_ID('tmp_dtc_test') IS NOT NULL DROP TABLE tmp_dtc_test");
				ExecuteQuery(connection, "CREATE TABLE tmp_dtc_test (a INT)");
				Console.WriteLine("Table successfully created\n");

				Console.WriteLine("Populating test table...");
				ExecuteQuery(connection, "INSERT INTO tmp_dtc_test VALUES (1)");
				Console.WriteLine("Table successfully populated\n");

				Console.WriteLine("Querying test table...");
				ExecuteQuery(connection, "SELECT * FROM tmp_dtc_test");
				Console.WriteLine("Table successfully queried\n");

				Console.WriteLine("Dropping test table in '{0}' database...", mCatalog);
				ExecuteQuery(connection, "DROP TABLE tmp_dtc_test");
				Console.WriteLine("Table successfully dropped");
			}
		}

		private OleDbConnection CreateConnection()
		{
      string connectionString = 
        String.Format("Provider=SQLOLEDB.1;Data Source={0};UID={1};PWD={2};Initial Catalog={3}",
											mServer, mUserName, mPassword, mCatalog);
      OleDbConnection connection;
      connection = new OleDbConnection(connectionString.ToString());
      connection.Open();
			return connection;
		}

    private void ExecuteQuery(OleDbConnection connection, string query)
    {
			ExecuteQueryDTC(connection, query);
      Console.WriteLine("  DTC transaction successfully committed!");
    }

    [AutoComplete]
    private void ExecuteQueryDTC(OleDbConnection connection, string query)
    {
      using(IDbCommand command = connection.CreateCommand())
			{
				command.CommandText = query;
				command.ExecuteNonQuery();
				Console.WriteLine("  ContextUtil.IsInTransaction == {0}", ContextUtil.IsInTransaction);
				Console.WriteLine("  committing DTC transaction...");
			}
    }


		private string mServer;
		private string mUserName;
		private string mPassword;
		private string mCatalog = "master";
	}


}
