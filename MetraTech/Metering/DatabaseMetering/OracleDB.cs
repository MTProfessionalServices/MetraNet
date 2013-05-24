using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.OracleClient;
using System.Diagnostics.CodeAnalysis;
using System.Text;

namespace MetraTech.Metering.DatabaseMetering
{
	public class OracleDB
	{
		public static OracleDB GetInstance()
		{
			return instance;
		}

		/// <summary>
		///   Given a tableName and columnName, return the width of the column.
		/// </summary>
		/// <param name="tableName"></param>
		/// <param name="columnName"></param>
		/// <returns></returns>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public int GetColumnWidth(string tableName, string columnName)
		{
			int columnWidth = -1;

			using (OracleConnection connection = new OracleConnection(connectionString))
			{
				string queryString = "select data_length from user_tab_cols where table_name = '" +
									 tableName.ToUpper() +
									 "' and column_name = '" +
									 columnName.ToUpper() +
									 "'";

				OracleCommand command = new OracleCommand(queryString, connection);
				connection.Open();

				using (OracleDataReader reader = command.ExecuteReader())
				{
					while (reader.Read())
					{
						if (!reader.IsDBNull(0))
						{
							columnWidth = reader.GetInt32(0);
						}
						break;
					}
				}
			}

			return columnWidth;
		}

		/// <summary>
		///   Return true, if a table with the given name exists. False, otherwise.
		/// </summary>
		/// <param name="tableName"></param>
		/// <returns></returns>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public bool TableExists(string tableName)
		{
			bool exists = false;

			using (OracleConnection connection = new OracleConnection(connectionString))
			{
				string queryString = "select count(1) from user_tab_cols where table_name = '" +
									 tableName.ToUpper() +
									 "'";

				OracleCommand command = new OracleCommand(queryString, connection);
				connection.Open();

				using (OracleDataReader reader = command.ExecuteReader())
				{
					while (reader.Read())
					{
						if (!reader.IsDBNull(0))
						{
							int value = reader.GetInt32(0);
							if (value > 0)
							{
								exists = true;
							}
						}
						break;
					}
				}
			}

			return exists;
		}

		/// <summary>
		///   Return true if the given tableName exists and contains no rows. Otherwise, return false.
		/// </summary>
		/// <param name="tableName"></param>
		/// <returns></returns>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public bool IsTableEmpty(string tableName)
		{
			bool tableIsEmpty = true;

			if (TableExists(tableName))
			{
				using (OracleConnection connection = new OracleConnection(connectionString))
				{
					string queryString = "select count(1) from " + tableName.ToUpper();

					OracleCommand command = new OracleCommand(queryString, connection);
					connection.Open();

					using (OracleDataReader reader = command.ExecuteReader())
					{
						while (reader.Read())
						{
							if (!reader.IsDBNull(0))
							{
								int value = reader.GetInt32(0);
								if (value > 0)
								{
									tableIsEmpty = false;
								}
							}
							break;
						}
					}
				}
			}

			return tableIsEmpty;
		}

		/// <summary>
		///   Drop the given table.
		/// </summary>
		/// <param name="tableName"></param>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public void DropTable(string tableName)
		{
			using (OracleConnection connection = new OracleConnection(connectionString))
			{
				string queryString = "drop table" + tableName.ToUpper();

				OracleCommand command = new OracleCommand(queryString, connection);
				connection.Open();

				command.ExecuteNonQuery();
			}
		}

		/// <summary>
		///   Status table contains the following columns:
		///   (1) Primary key columns from the given table name specified in primaryKeyColumnNames.
		///       All column names in primaryKeyColumnNames must be UPPER CASED.
		///   (2) Columns from the given table name which matches the given columnNames.
		///       All column names in columnNames must be UPPER CASED.
		/// 
		/// </summary>
		/// <param name="tableName"></param>
		/// <param name="columnNames"></param>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public void CreateStatusTable(string serviceTableName,
									  string statusTableName,
									  List<string> primaryKeyColumnNames,
									  List<string> columnNames)
		{

			Dictionary<string, ColumnData> serviceTableColumnDataDictionary = GetColumnData(serviceTableName);

			ColumnData columnData = null;
			string queryLine = String.Empty;
			StringBuilder createTableQuery = new StringBuilder("CREATE TABLE " + statusTableName.ToUpper() + " ( ");

			// Create primary key columns
			foreach (string columnName in primaryKeyColumnNames)
			{
				serviceTableColumnDataDictionary.TryGetValue(columnName, out columnData);
				if (columnData == null)
				{
					throw new Exception("Error in CreateStatusTable: PK column '" +
									  columnName +
									  "' not present in the main table '" +
									  serviceTableName +
									  "'.");
				}

				queryLine = GetCreateTableQueryLine(columnData);
				createTableQuery.Append(queryLine);
			}

			// Create the other columns
			foreach (string columnName in columnNames)
			{
				serviceTableColumnDataDictionary.TryGetValue(columnName, out columnData);
				if (columnData == null)
				{
					throw new Exception("Error in CreateStatusTable: status column '" +
										columnName +
										"' not present in the main table '" +
										serviceTableName +
										"'.");
				}

				queryLine = GetCreateTableQueryLine(columnData);
				createTableQuery.Append(queryLine);
			}

			// Create the primary key, if necessary
			if (primaryKeyColumnNames.Count > 0)
			{
				// Create the line:
				// CONSTRAINT "PK_1" PRIMARY KEY (c_ConferenceID, c_Payer)
				StringBuilder primaryKeyString = new StringBuilder("CONSTRAINT ");
				string primaryKeyName = "PK_" +
										DateTime.Now.Hour.ToString() +
										DateTime.Now.Minute.ToString() +
										DateTime.Now.Second.ToString() +
										DateTime.Now.Millisecond.ToString();

				primaryKeyString.Append(primaryKeyName);
				primaryKeyString.Append(" ");
				primaryKeyString.Append("PRIMARY KEY");
				primaryKeyString.Append(" ");
				primaryKeyString.Append("(");
				primaryKeyString.Append(GetCommaSeparatedNames(primaryKeyColumnNames, String.Empty));
				primaryKeyString.Append(")");
				createTableQuery.Append(primaryKeyString);
			}
			else
			{
				// Remove that last comma
				createTableQuery.Replace(",", "", createTableQuery.Length - 1, 1);
			}

			createTableQuery.Append(" )");

			using (OracleConnection connection = new OracleConnection(connectionString))
			{
				// Run the query
				connection.Open();
				OracleCommand command = new OracleCommand(createTableQuery.ToString(), connection);
				logger.LogString(Log.LogLevel.DEBUG, createTableQuery.ToString());
				command.ExecuteNonQuery();
			}
		}

		/// <summary>
		///    (1) Validate the given statusTableName contains the primary key columns specified
		///        in primaryKeyColumns.
		///    (2) The other columns specified in columnNames exist.
		/// </summary>
		/// <param name="serviceTableName"></param>
		/// <param name="statusTableName"></param>
		/// <param name="primaryKeyColumnNames"></param>
		/// <param name="columnNames"></param>
		public void ValidateStatusTable(string serviceTableName,
										string statusTableName,
										List<string> primaryKeyColumnNames,
										List<string> columnNames)
		{
			// Get Column Data for tableName1
			Dictionary<string, ColumnData> serviceTableColumnDataDictionary = GetColumnData(serviceTableName);
			// Get Column Data for tableName2
			Dictionary<string, ColumnData> statusTableColumnDataDictionary = GetColumnData(statusTableName);

			// Validate the primary keys
			foreach (string columnName in primaryKeyColumnNames)
			{
				ValidateColumn(columnName,
							   serviceTableName,
							   serviceTableColumnDataDictionary,
							   statusTableName,
							   statusTableColumnDataDictionary);
			}

			// Validate the other columns
			foreach (string columnName in columnNames)
			{
				ValidateColumn(columnName,
							   serviceTableName,
							   serviceTableColumnDataDictionary,
							   statusTableName,
							   statusTableColumnDataDictionary);
			}

		}

		/// <summary>
		///   For the given tableName, populate the given dateColumns hashtable
		///   key [ColumnName] --> 1 (if it's a date) or 0
		/// 
		///   Legacy from ServiceDef code.
		/// </summary>
		/// <param name="dateColumns"></param>
		/// <param name="tableName"></param>
		public void MarkDateColumns(Hashtable dateColumns, string tableName)
		{
			// Get Column Data for tableName1
			Dictionary<string, ColumnData> dictionary = GetColumnData(tableName);
			ColumnData columnData = null;
			foreach (string columnName in dictionary.Keys)
			{
				columnData = dictionary[columnName];
				if (columnData.DataType.ToUpper() == "DATE")
				{
					dateColumns.Add(columnName, 1);
				}
				else
				{
					dateColumns.Add(columnName, 0);
				}
			}
		}

		/// <summary>
		///    Update the serviceTableName with the column values (specified in columnNames)
		///    from statusTableName. Match the tables on primary key columns - which should
		///    be the same for the statusTableName and the serviceTableName.
		/// </summary>
		/// <param name="statusTableName"></param>
		/// <param name="serviceTableName"></param>
		/// <param name="columnNames"></param>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		public void UpdateServiceTable(string serviceTableName,
									   string statusTableName,
									   List<string> primaryKeyColumnNames,
									   List<string> columnNames)
		{
			/* This is what the query should look like.
			update mt_audioconfcall au
			 set (au.c_meteringstatus, au.c_mtsenttime, au.c_MTErrorMesg) = 
			   (select aus.c_meteringstatus, aus.c_mterrormesg, aus.c_mtsenttime
				from mt_audioconfcall_status aus
				where aus.c_conferenceId = au.c_conferenceId)
			 where exists (select 1 
						   from mt_audioconfcall_status aus
						   where aus.c_conferenceId = au.c_conferenceId)
			*/

			string serviceTablePrefix = "main"; // au
			string statusTablePrefix = "status"; // aus

			// au.c_meteringstatus, au.c_mtsenttime, au.c_MTErrorMesg
			string setList = GetCommaSeparatedNames(columnNames, serviceTablePrefix + ".");

			// aus.c_meteringstatus, aus.c_mtsenttime, aus.c_MTErrorMesg
			string innerSelectList = GetCommaSeparatedNames(columnNames, statusTablePrefix + ".");

			// from mt_audioconfcall_status aus (inner and outer from)
			string fromClause = " from " + statusTableName + " " + statusTablePrefix;

			// where clause
			string whereClause = GetWhereClause(primaryKeyColumnNames, statusTablePrefix, serviceTablePrefix);

			string queryString = "update " + serviceTableName + " " + serviceTablePrefix + // update mt_audioconfcall au
								 " set (" + setList + ") =" + // set (au.c_meteringstatus, au.c_mtsenttime, au.c_MTErrorMesg) = 
								 " (select " + innerSelectList + // (select aus.c_meteringstatus, aus.c_mterrormesg, aus.c_mtsenttime
								 fromClause + // from mt_audioconfcall_status aus
								 " " + whereClause + ")" + // where aus.c_conferenceId = au.c_conferenceId)
								 " where exists (select 1" + // where exists (select 1
								 fromClause + " " + // from mt_audioconfcall_status aus
								 whereClause + ")"; // where aus.c_conferenceId = au.c_conferenceId)

			using (OracleConnection connection = new OracleConnection(connectionString))
			{
				OracleCommand command = new OracleCommand(queryString, connection);
				connection.Open();

				command.ExecuteNonQuery();
			}
		}

		[SuppressMessage("Microsoft.Security", "CA2100")]
		public void TruncateTable(string tableName)
		{
			string queryString = "truncate table " + tableName;

			using (OracleConnection connection = new OracleConnection(connectionString))
			{
				OracleCommand command = new OracleCommand(queryString, connection);
				connection.Open();
				command.ExecuteNonQuery();
			}
		}

		/// <summary>
		///    Validate that the given columnName exists in both tableName1 and tableName2 and
		///    that the data types and data lengths are the same in both tables.
		/// </summary>
		/// <param name="columnName"></param>
		/// <param name="tableName1"></param>
		/// <param name="tableName2"></param>
		private void ValidateColumn(string columnName,
									string tableName1,
									Dictionary<string, ColumnData> table1ColumnDataDictionary,
									string tableName2,
									Dictionary<string, ColumnData> table2ColumnDataDictionary)
		{
			ColumnData table1ColumnData = null;
			ColumnData table2ColumnData = null;

			// Error if the column is not found in tableName1
			table1ColumnDataDictionary.TryGetValue(columnName, out table1ColumnData);
			if (table1ColumnData == null)
			{
				throw new Exception("Error in ValidateStatusTable: PK column '" +
									columnName +
									"' not present in the main table '" +
									tableName1 +
									"'.");
			}

			// Error if the column is not found in tableName2
			table2ColumnDataDictionary.TryGetValue(columnName, out table2ColumnData);
			if (table2ColumnData == null)
			{
				throw new Exception("Error in ValidateStatusTable: PK column '" +
									columnName +
									"' not present in the status table '" +
									tableName2 +
									"'.");
			}

			// Error if the data types are different
			if (table1ColumnData.DataType != table2ColumnData.DataType)
			{
				throw new Exception("Error in ValidateStatusTable: Mismatched data types. The PK column '" +
									columnName +
									"' has a data type of '" +
									table1ColumnData.DataType +
									"' in the first table '" +
									tableName1 +
									"' and has a data type of '" +
									table2ColumnData.DataType +
									"' in the second table '" +
									tableName2 +
									"'.");
			}

			// Error if the data lengths are different
			if (table1ColumnData.Length != table2ColumnData.Length)
			{
				throw new Exception("Error in ValidateStatusTable: Mismatched data lengths. The PK column '" +
									columnName +
									"' has a data length of '" +
									table1ColumnData.Length +
									"' in the first table '" +
									tableName1 +
									"' and has a data length of '" +
									table2ColumnData.Length +
									"' in the second table '" +
									tableName2 +
									"'.");
			}
		}

		private string GetCommaSeparatedNames(List<string> names, string prefix)
		{
			StringBuilder commaSeparatedString = new StringBuilder();

			bool firstId = true;

			foreach (string name in names)
			{
				if (firstId)
				{
					commaSeparatedString.Append(prefix + name);
					firstId = false;
				}
				else
				{
					commaSeparatedString.Append(",");
					commaSeparatedString.Append(prefix + name);
				}
			}

			return commaSeparatedString.ToString();
		}

		/// <summary>
		///    Return a where clause of the following form:
		///      where aus.column1 = au.column1 and
		///            aus.column2 = au.column2
		/// 
		///    aus = prefix1
		///    au = prefix2
		/// 
		///    column1 and column2 are members of columnNames
		/// </summary>
		/// <param name="primarKeyNames"></param>
		/// <param name="prefix1"></param>
		/// <param name="prefix2"></param>
		/// <returns></returns>
		private string GetWhereClause(List<string> columnNames, string prefix1, string prefix2)
		{
			StringBuilder whereClause = new StringBuilder("where ");
			bool first = true;

			foreach (string columnName in columnNames)
			{
				if (first)
				{
					whereClause.Append(prefix1 + "." + columnName + " = " + prefix2 + "." + columnName);
					first = false;
				}
				else
				{
					whereClause.Append(" and ");
					whereClause.Append(prefix1 + "." + columnName + " = " + prefix2 + "." + columnName);
				}
			}

			return whereClause.ToString();
		}

		/// <summary>
		///   Do not change the position of this reader!
		/// 
		///   Reader has the following columns in the given order:
		///    column_name (string), 
		///    data_type (string), 
		///    data_length (int), 
		///    data_precision (int), 
		///    nullable (string = Y/N)
		/// 
		///   Return a line of the form:
		///    c_ConferenceID nvarchar2 (15)  NOT NULL,
		/// </summary>
		/// <param name="reader"></param>
		/// <returns></returns>
		private string GetCreateTableQueryLine(ColumnData columnData)
		{
			// Create c_ConferenceID
			StringBuilder queryLine = new StringBuilder(columnData.Name);

			// Create nvarchar2
			queryLine.Append(" ");
			queryLine.Append(columnData.DataType);
			queryLine.Append(" ");

			// Create (15) or (15, x) where x is the precision
			if (columnData.Length.HasValue)
			{
				queryLine.Append("(");
				queryLine.Append(columnData.Length);

				if (columnData.Precision.HasValue)
				{
					queryLine.Append(", ");
					queryLine.Append(columnData.Precision);
				}

				queryLine.Append(")");
				queryLine.Append(" ");
			}

			// Create the NOT NULL or NULL
			if (columnData.IsNullable)
			{
				queryLine.Append("NULL, ");
			}
			else
			{
				queryLine.Append("NOT NULL, ");
			}

			return queryLine.ToString();
		}

		private string GetDBDateString(DateTime date)
		{
			return "to_date('" + date.ToString("yyyy'-'MM'-'dd") + "', 'YYYY-MM-DD')";
		}

		/// <summary>
		///    Return column data for the given tableName.
		/// </summary>
		/// <param name="tableName"></param>
		/// <returns></returns>
		[SuppressMessage("Microsoft.Security", "CA2100")]
		private Dictionary<string, ColumnData> GetColumnData(string tableName)
		{
			Dictionary<string, ColumnData> columnDataDictionary = new Dictionary<string, ColumnData>();

			using (OracleConnection connection = new OracleConnection(connectionString))
			{
				string queryString =
				  "select utc.column_name, " +
				  "       utc.data_type, " +
				  "       utc.char_col_decl_length, " +
				  "       utc.data_precision, " +
				  "       utc.nullable, " +
				  "       utc1.constraint_type " +
				  "from user_tab_cols utc " +
				  "left outer join " +
				  "(select utc.table_name, " +
				  "        utc.column_name, " +
				  "        uc.constraint_type constraint_type " +
				  "from user_tab_cols utc " +
				  "inner join user_constraints uc " +
				  "on uc.table_name = utc.table_name " +
				  "inner join user_cons_columns ucc " +
				  "on ucc.constraint_name = uc.constraint_name and " +
				  "   ucc.column_name = utc.column_name " +
				  "where utc.table_name = '" + tableName.ToUpper() + "' and " +
				  "      uc.constraint_type = 'P'" +
				  ") utc1 on utc1.column_name = utc.column_name " +
				  " where utc.table_name = '" + tableName.ToUpper() + "'";

				OracleCommand command = new OracleCommand(queryString, connection);
				connection.Open();

				using (OracleDataReader reader = command.ExecuteReader())
				{
					ColumnData columnData = null;
					while (reader.Read())
					{
						columnData = new ColumnData();
						// Name
						columnData.Name = reader.GetString(0).ToUpper();
						// DataType
						columnData.DataType = reader.GetString(1);
						// Length
						if (!reader.IsDBNull(2))
						{
							columnData.Length = reader.GetInt32(2);
						}

						// Precision
						if (!reader.IsDBNull(3))
						{
							columnData.Precision = reader.GetInt32(3);
						}

						// Nullable
						if (reader.GetString(4) == "Y")
						{
							columnData.IsNullable = true;
						}

						// PrimaryKey column
						if (!reader.IsDBNull(5))
						{
							columnData.IsPrimaryKeyColumn = true;
						}

						columnDataDictionary.Add(columnData.Name, columnData);
					}
				}
			}

			return columnDataDictionary;
		}

		private string connectionString;
		public string ConnectionString
		{
			get { return connectionString; }
			set { connectionString = value; }
		}

		private Log logger;
		public Log Logger
		{
			set { logger = value; }
			get { return logger; }

		}

		// Private constructor
		private OracleDB()
		{
		}

		private static readonly OracleDB instance = new OracleDB();
	}

	public class ColumnData
	{
		public ColumnData()
		{
			IsPrimaryKeyColumn = false;
			IsNullable = false;
		}

		public string Name;
		public string DataType;
		public int? Length;
		public int? Precision;
		public bool IsNullable;
		public bool IsPrimaryKeyColumn;
	}
}
