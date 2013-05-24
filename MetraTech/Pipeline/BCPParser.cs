using System;
using System.Collections;
using System.Runtime.InteropServices;
using System.Data; 
using System.IO; 
using System.Data.OleDb; 
using System.Data.SqlTypes; 
using System.Diagnostics;
using System.Text;

using MetraTech.DataAccess;

namespace MetraTech.Pipeline
{
	[Flags]
	enum BCPColumnType
	{
		INT4 = bcp.SQLINT4,
		VARCHAR = bcp.SQLVARCHAR,
		NVARCHAR = bcp.SQLNVARCHAR,
		NUMERIC = bcp.SQLNUMERIC,
		DATETIME = bcp.SQLDATETIME,
		VARBINARY = bcp.SQLVARBINARY,
		CHARACTER = bcp.SQLCHARACTER,

		NULL = 0x000000,
		NOT_NULL = 0x100000,

		TYPE_MASK = 0x0FFFFF,
		NULL_MASK = 0x100000
	}

	enum SpecialProps
	{
		SessionUID = -2,
		ParentUID = -3
	}

	[ComVisible(false)]
	public interface IPropertyParser
	{
		void ParseProperty(BinaryReader reader, PipelineSession session, int index);
	}

	[ComVisible(false)]
	public class OptInt32PropertyParser : IPropertyParser
	{
		public void ParseProperty(BinaryReader reader, PipelineSession session, int index)
		{
			int intVal = reader.ReadInt32();
			session.SetPropertyUnsync(index, intVal);
		}
	}

	[ComVisible(false)]
	public class Int32PropertyParser : IPropertyParser
	{
		public void ParseProperty(BinaryReader reader, PipelineSession session, int index)
		{
			bool exists = reader.ReadByte() != 0xFF;
			if (exists)
			{
				int intVal = reader.ReadInt32();
				session.SetPropertyUnsync(index, intVal);
			}
		}
	}

	struct BCPColumn
	{
		public BCPColumn(BCPColumnType colType, string colName, int colNameID, int propIndex)
		{
			mType = colType;
			mColumnName = colName;
			mNameID = colNameID;
			mIndex = propIndex;
		}

		public int NameID
		{
			get { return mNameID; }
		}

		public BCPColumnType ColumnType
		{
			get { return mType; }
		}

		public int Index
		{
			get { return mIndex; }
		}

		private BCPColumnType mType;
		private string mColumnName;
		private int mNameID;
		private int mIndex;
	}

	[ComVisible(false)]
	public class BCPParser
	{
		public void ReadMetaData(string tableName, string tempFileName,
															string errFileName, string serviceName)
		{
			mTableName = tableName;
			mTempFileName = tempFileName;
			mErrorFileName = errFileName;
			mServiceName = serviceName;

			int serviceID;
			int serviceProps;
			
			ArrayList bcpColumns = new ArrayList();

			MetraTech.Interop.MTPipelineLib.IMTSystemContext mSysContext = (MetraTech.Interop.MTPipelineLib.IMTSystemContext)
				new MetraTech.Interop.SysContext.MTSystemContext();

			MetraTech.Interop.MTPipelineLib.IMTNameID mNameID = mSysContext.GetNameID();
			serviceID = mNameID.GetNameID(serviceName);
			mServiceIndex = PipelinePropIDManager.GetIndexForService(serviceID);

			int propCount = 0;
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
				DataTable table = conn.DescribeTable(tableName);

				foreach (DataRow row in table.Rows)
				{
					string columnName = (string) row["ColumnName"];
					int ordinal = (int) row["ColumnOrdinal"];
					System.Type dataType = (System.Type) row["DataType"];
					OleDbType providerType = (OleDbType) (int) row["ProviderType"];
					bool allowNull = (bool) row["AllowDBNull"];

					BCPColumnType colType;
					switch (providerType)
					{
					case OleDbType.VarBinary:
						colType = BCPColumnType.VARBINARY;
						break;
					case OleDbType.VarWChar:
						colType = BCPColumnType.NVARCHAR;
						break;
					case OleDbType.Integer:
						colType = BCPColumnType.INT4;
						break;
					case OleDbType.DBTimeStamp:
						colType = BCPColumnType.DATETIME;
						break;
					case OleDbType.Numeric:
						colType = BCPColumnType.NUMERIC;
						break;
					default:
						Debug.Assert(false);
						colType = BCPColumnType.INT4;
						break;
					}

					if (allowNull)
						colType = colType | BCPColumnType.NULL;
					else
						colType = colType | BCPColumnType.NOT_NULL;

					
					int nameID;
					if (columnName.StartsWith("c_"))
					{
						columnName = columnName.Substring(2);
						nameID = mNameID.GetNameID(columnName);
					}
					else
					{
						if (columnName == "tx_UID")
							nameID = (int) SpecialProps.SessionUID;
						else if (columnName == "tx_parent_UID")
							nameID = (int) SpecialProps.ParentUID;
						else
							nameID = -1;
					}
																				 
					int index;
					if (nameID >= 0)
						index = PipelinePropIDManager.GetIndexForNameID(mServiceIndex, nameID);
					else
						index = -1;
					BCPColumn col = new BCPColumn(colType, columnName, nameID, index);

					if (nameID >= 0)
						propCount++;

					/*
					Console.WriteLine("column = {0}, {1}, {2}, {3}, {4}",
																	 columnName,
																	 ordinal,
																	 dataType.ToString(),
																	 providerType.ToString(),
																	 allowNull);
					*/
					bcpColumns.Add(col);
				}
				serviceProps = propCount;
			}

			mBCPColumns = (BCPColumn []) bcpColumns.ToArray(typeof(BCPColumn));
		}

		public void BCPInit(string dsn)
		{
			//
			// connect
			//

			Int16 result;

			// Allocate environment handle
			result = bcp.SQLAllocHandle((short) OdbcHandleType.Env, (IntPtr) null, out mEnvHandle);
			OdbcException.ThrowOnError(result, OdbcHandleType.Env, (IntPtr) null);

			// Set environment attributes to ODBC v3
			result = bcp.SQLSetEnvAttr(mEnvHandle, (ushort) OdbcEnv.OdbcVersion, (IntPtr) 3UL,
																 (-6));
			OdbcException.ThrowOnError(result, OdbcHandleType.Env, mEnvHandle);

			// Allocate connection handle
			result = bcp.SQLAllocHandle((short) OdbcHandleType.Dbc, mEnvHandle, out mDBCHandle);
			OdbcException.ThrowOnError(result, OdbcHandleType.Env, mEnvHandle);

			// Turn bcp on in connection attributes
			result = bcp.SQLSetConnectAttr(mDBCHandle, bcp.SQL_COPT_SS_BCP, (IntPtr) bcp.SQL_BCP_ON, (-6));
			OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);

			//result = bcp.SQLConnect(mDBCHandle, dsn, -3, "nmdbo", -3, "nmdbo", -3);
			StringBuilder outBuffer = new StringBuilder(new string(' ', 1024));
			Int16 outBufferLength;
			result = bcp.SQLDriverConnect(mDBCHandle, (IntPtr)null, dsn, -3, outBuffer, (Int16) outBuffer.Length, out outBufferLength, (UInt16) 0);
			OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);

			// initialize bcp
			result = bcp.bcp_init(mDBCHandle, mTableName, mTempFileName,
														 mErrorFileName, bcp.DB_OUT);
			OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);

			result = bcp.bcp_columns(mDBCHandle, mBCPColumns.Length);
			OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);

			int colNum = 1;
			foreach (BCPColumn col in mBCPColumns)
			{
				switch (col.ColumnType)
				{
				case BCPColumnType.INT4:
				case BCPColumnType.INT4|BCPColumnType.NOT_NULL:
					result = bcp.bcp_colfmt(mDBCHandle,
																	colNum, // file column
																	bcp.SQLINT4,
																	-1, // length/null indicator
																	4, // max length,
																	null,
																	0,
																	colNum);
					OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);
					break;

				case BCPColumnType.VARCHAR:
				case BCPColumnType.VARCHAR|BCPColumnType.NOT_NULL:
					result = bcp.bcp_colfmt(mDBCHandle,
																	colNum, // file column
																	bcp.SQLVARCHAR,
																	2, // length/null indicator
																	-1, // max length,
																	null,
																	0,
																	colNum);
					OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);
					break;

				case BCPColumnType.NVARCHAR:
				case BCPColumnType.NVARCHAR|BCPColumnType.NOT_NULL:
					result = bcp.bcp_colfmt(mDBCHandle,
																	colNum, // file column
																	bcp.SQLNVARCHAR,
																	2, // length/null indicator
																	-1, // max length,
																	null,
																	0,
																	colNum);
					OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);
					break;
				case BCPColumnType.NUMERIC:
				case BCPColumnType.NUMERIC|BCPColumnType.NOT_NULL:
					result = bcp.bcp_colfmt(mDBCHandle,
																	colNum, // file column
																	bcp.SQLNUMERIC,
																	-1, // length/null indicator
																	-1, // max length,
																	null,
																	0,
																	colNum);
					OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);
					break;
				case BCPColumnType.DATETIME:
				case BCPColumnType.DATETIME|BCPColumnType.NOT_NULL:
					result = bcp.bcp_colfmt(mDBCHandle,
																	colNum, // file column
																	bcp.SQLDATETIME,
																	-1, // length/null indicator
																	-1, // max length,
																	null,
																	0,
																	colNum);
					OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);
					break;
				case BCPColumnType.VARBINARY:
				case BCPColumnType.VARBINARY|BCPColumnType.NOT_NULL:
					result = bcp.bcp_colfmt(mDBCHandle,
																	colNum, // file column
																	bcp.SQLVARBINARY,
																	-1, // length/null indicator
																	-1, // max length,
																	null,
																	0,
																	colNum);
					OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);
					break;
				case BCPColumnType.CHARACTER:
				case BCPColumnType.CHARACTER|BCPColumnType.NOT_NULL:
					// TODO: use a max length here?
					result = bcp.bcp_colfmt(mDBCHandle,
																	colNum, // file column
																	bcp.SQLCHARACTER,
																	-1, // length/null indicator
																	1, // max length,
																	null,
																	0,
																	colNum);
					OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);
					break;
				}
			}
		}

		public int Transfer()
		{
			short rows;
			Int16 result;
			result = bcp.bcp_exec(mDBCHandle, out rows);
			OdbcException.ThrowOnError(result, OdbcHandleType.Dbc, mDBCHandle);

			bcp.bcp_done(mDBCHandle);
			mRows = (int) rows;
			return mRows;
		}

		public ArrayList Parse()
		{
			//bool exists;
			//ushort ushortLen;
			//int intVal;
			//string strVal;
			//DateTime dateVal;
			//byte [] varBinVal;
			//decimal decVal;
			//char charVal;
			System.Text.UnicodeEncoding unicode = new System.Text.UnicodeEncoding();


			ArrayList sessions = new ArrayList();

			//using (FileStream stream = new FileStream(File.Open(tempFileName, FileMode.Open, FileAccess.Read, FileShare.Read, 64 * 1024 * 1024))
			//			using (FileStream stream = new FileStream(tempFileName, FileMode.Open, FileAccess.Read, FileShare.Read, 64 * 1024 * 1024))
			using (FileStream stream = new FileStream(mTempFileName, FileMode.Open, FileAccess.Read, FileShare.Read))
			{
				using (BinaryReader reader = new BinaryReader(stream))
				{
					for (int i = 0; i < mRows; i++)
					{
						PipelineSession session = new PipelineSession();
						sessions.Add(session);
						session.ServiceIndex = mServiceIndex;
						session.Synchronize();

						// create the session object
						//byte [] uid = MetraTech.MSIXUtils.DecodeUID(MetraTech.MSIXUtils.CreateUID());
						//string uidStr = MetraTech.MSIXUtils.CreateUID();
						//int serviceID = 7;

						//						MetraTech.Interop.MTPipelineLib.IMTSession session = null;

						/*
						foreach (BCPColumn col in mBCPColumns)
						{
							switch (col.ColumnType)
							{
							case BCPColumnType.INT4:
								exists = reader.ReadByte() != 0xFF;
								if (exists)
								{
									intVal = reader.ReadInt32();
									session.SetPropertyUnsync(col.Index, col.NameID,
																			intVal);
								}
								else
									// TODO:
									intVal = -1;
								break;

							case BCPColumnType.INT4|BCPColumnType.NOT_NULL:
								intVal = reader.ReadInt32();

								session.SetPropertyUnsync(col.Index, col.NameID,
																		intVal);
								break;

							case BCPColumnType.VARCHAR:
								ushortLen = reader.ReadUInt16();
								if (ushortLen != 0xFFFF)
								{
									char [] chars = reader.ReadChars((int) ushortLen);
									strVal = new string(chars);
									session.SetPropertyUnsync(col.Index, col.NameID,
																			strVal);
								}
								break;

							case BCPColumnType.VARCHAR|BCPColumnType.NOT_NULL:
								ushortLen = reader.ReadUInt16();
								{
									char [] chars = reader.ReadChars((int) ushortLen);
									strVal = new string(chars);
								}

								session.SetPropertyUnsync(col.Index, col.NameID,
																		strVal);
								break;

							case BCPColumnType.NVARCHAR:
								ushortLen = reader.ReadUInt16();
								if (ushortLen != 0xFFFF)
								{
									byte [] nvarCharBytes = reader.ReadBytes(ushortLen);
									strVal = new string(unicode.GetChars(nvarCharBytes));
									session.SetPropertyUnsync(col.Index, col.NameID,
																			strVal);
								}
								break;

							case BCPColumnType.NVARCHAR|BCPColumnType.NOT_NULL:
								{
									ushortLen = reader.ReadUInt16();
									byte [] nvarCharBytes = reader.ReadBytes(ushortLen);
									strVal = new string(unicode.GetChars(nvarCharBytes));
								}
								session.SetPropertyUnsync(col.Index, col.NameID,
																		strVal);
								break;


							case BCPColumnType.NUMERIC:
								exists = (reader.ReadByte() != 0xFF);
								if (exists)
								{
									//int unknown = reader.ReadByte();
									byte precision = reader.ReadByte();
									byte scale = reader.ReadByte();
									int sign = reader.ReadByte();

									int d1 = reader.ReadInt32();
									int d2 = reader.ReadInt32();
									int d3 = reader.ReadInt32();
									int d4 = reader.ReadInt32();

									decVal = (decimal) new SqlDecimal(precision, scale, sign == 1, d1, d2, d3, d4);
									session.SetPropertyUnsync(col.Index, col.NameID,
																			decVal);
								}
								break;

							case BCPColumnType.NUMERIC|BCPColumnType.NOT_NULL:
								{
									// TODO: re-test this.  do we need the unknown byte?
									int unknown = reader.ReadByte();
									byte precision = reader.ReadByte();
									byte scale = reader.ReadByte();
									int sign = reader.ReadByte();

									int d1 = reader.ReadInt32();
									int d2 = reader.ReadInt32();
									int d3 = reader.ReadInt32();
									int d4 = reader.ReadInt32();

									decVal = (decimal) new SqlDecimal(precision, scale, sign == 1, d1, d2, d3, d4);
								}
								session.SetPropertyUnsync(col.Index, col.NameID,
																		decVal);
								break;

							case BCPColumnType.DATETIME:
								// see DBDATETIME
								exists = (reader.ReadByte() != 0xFF);
								if (exists)
								{
									int days = reader.ReadInt32();
									uint units = reader.ReadUInt32();
									dateVal = (DateTime) new SqlDateTime(days, (int) units);
									session.SetPropertyUnsync(col.Index, col.NameID,
																			dateVal);
								}
								break;

							case BCPColumnType.DATETIME|BCPColumnType.NOT_NULL:
								{
									int days = reader.ReadInt32();
									uint units = reader.ReadUInt32();
									dateVal = (DateTime) new SqlDateTime(days, (int) units);
								}
								session.SetPropertyUnsync(col.Index, col.NameID,
																		dateVal);
								break;

							case BCPColumnType.VARBINARY:
								ushortLen = reader.ReadUInt16();
								if (ushortLen != 0xFFFF)
									varBinVal = reader.ReadBytes((int) ushortLen);
								else
									varBinVal = null;
								break;

							case BCPColumnType.VARBINARY|BCPColumnType.NOT_NULL:
								ushortLen = reader.ReadUInt16();
								varBinVal = reader.ReadBytes((int) ushortLen);

								if (col.NameID == (int) SpecialProps.SessionUID)
								{
									//session = (MetraTech.Interop.MTPipelineLib.IMTSession) mSessionServer.CreateSession(varBinVal, serviceID);
									session.UID = varBinVal;
								}
								break;

							case BCPColumnType.CHARACTER:
								exists = (reader.ReadByte() != 0xFF);
								if (exists)
									charVal = reader.ReadChar();
								else
									charVal = '\0';
								break;

							case BCPColumnType.CHARACTER|BCPColumnType.NOT_NULL:
								charVal = reader.ReadChar();
								break;
							}
						}
						*/
						//Marshal.ReleaseComObject(session);
					}
				}
			}
			return sessions;
		}

		private BCPColumn [] mBCPColumns;
		private IntPtr mEnvHandle;
		private IntPtr mDBCHandle;

		private string mTableName;
		private string mTempFileName;
		private string mErrorFileName;
		private string mServiceName;
		private int mRows;
		private int mServiceIndex;
	}
}

