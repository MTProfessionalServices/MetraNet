

namespace MetraTech.DataAccess
{
	using System;

	public interface IBulkInsert : System.IDisposable
	{
		void Connect(ConnectionInfo connInfo);
		void Connect(ConnectionInfo connInfo, object txn);

		void PrepareForInsert(string tableName, int rowsPerInsert);
		void PrepareForInsertWithStatement(string insertStatement,
																			 int rowsPerInsert);

		void SetValue(int column, MTParameterType type, object value);
		void SetWideString(int column, string value);
		void SetDecimal(int column, decimal value);
		void SetDateTime(int column, DateTime value);

		void AddBatch();

		void ExecuteBatch();

		int BatchCount();
	}


	public class NullBulkInsert : IBulkInsert
	{
		public void Connect(ConnectionInfo connInfo)
		{ }
		public void Connect(ConnectionInfo connInfo, object txn)
		{ }

		public void PrepareForInsert(string tableName, int rowsPerInsert)
		{ }
		public void PrepareForInsertWithStatement(string insertStatement,
																			 int rowsPerInsert)
		{ }

		public void SetValue(int column, MTParameterType type, object value)
		{ }

		public void SetWideString(int column, string value)
		{ }
		public void SetDecimal(int column, decimal value)
		{ }
		public void SetDateTime(int column, DateTime value)
		{ }

		public void AddBatch()
		{ }

		public void ExecuteBatch()
		{ }

		public int BatchCount()
		{ return 0; }

		public void Dispose()
		{ }
	}

}
