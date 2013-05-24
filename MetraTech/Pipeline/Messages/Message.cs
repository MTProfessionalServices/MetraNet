
using System.Runtime.InteropServices;

[assembly: GuidAttribute("c3e5f3a2-d2d5-4e07-92c1-b05ba7ebb561")]


namespace MetraTech.Pipeline.Messages
{
	using System;
	using System.Text;
	using System.Xml;
	using System.Diagnostics;
	using System.EnterpriseServices;
	using MetraTech.PipelineInterop;
	using MetraTech.DataAccess;
	using MetraTech;
	using QueryAdapter = MetraTech.Interop.QueryAdapter;

	[Guid("37b657dc-25d3-46ef-acab-0c97ae095d82")]
	public interface IMessageUtils
	{
		/// <summary>
		/// Return true if the message is encoding and would need decoding.
		/// </summary>
		bool IsEncoded(string source);

		/// <summary>
		/// Encode a message.  If compress and encrypt are both true,
		/// the original message is returned unchanged.
		/// </summary>
		string EncodeMessage(string source, string sourceUid,
												 bool compress, bool encrypt);

		/// <summary>
		/// Decode a message.  The message original UID and the UID of the message
		/// contained inside are returned.  If the message was not encrypted
		/// or compressed, the message is returned unchanged.  sourceUid and
		/// sourceMessageUid will be empty strings in this case.
		/// </summary>
		string DecodeMessage(string encoded,
												 out string sourceUid,
												 out string sourceMessageUid);
	}

	[Guid("f0313b7d-4031-49fa-a08c-351f48699df3")]
	public interface IFailedMSIXMessageUtils
	{
		// store a failed transaction message in the database
		void SaveFailedTransactionMessage(string sessionID, string message);

		// load a failed transaction message from the database
		string LoadFailedTransactionMessage(string sessionID);

		// return true if the given session is stored in the database
		bool HasSavedFailedTransactionMessage(string sessionID);

		// delete the saved version of a failed transaction from the database
		void DeleteFailedTransactionMessage(string sessionID);
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("f812d42d-92ab-464f-95ef-6ab7e815bf4a")]
	public class MessageUtils : IMessageUtils
	{
		/// <summary>
		/// Return true if the message is encoding and would need decoding.
		/// </summary>
		public bool IsEncoded(string source)
    {
			string beginning;
			if (source.Length < 128)
				beginning = source.Substring(0, source.Length);
			else
				beginning = source.Substring(0, 128);

			if (beginning.IndexOf("<msixenvelope") >= 0)
				return true;
			else
				return false;
		}


		// <msixenvelope uid="">
		//   <message uid="" compression="zlib" encrypted="true">
		//     <sessionuids>
		//       <id>wKgB2eCjlAnJGFGocptPXw==</id>
		//       <id>wKgB1Ki9mYhnHjQwU965Xw==</id>
		//     <sessionids>
		//   </message>
		//   <message uid="" compression="true" encrypted="true">
		//   </message>
		// </msixenvelope>
		public string EncodeMessage(string source, string sourceUid,
												 bool compress, bool encrypt)
		{
			// <beginsession>
			//   <uid>wKgB2ZiBIOYUMFBIUe//Vw==</uid>
			XmlDocument xmldoc = new XmlDocument();
			xmldoc.LoadXml(source);


			XmlDocument doc = new XmlDocument();

			// determine the list of session IDs contained in the
			// message.
			// NOTE: this is very expensive since we have to parse 


			XmlElement envelope = doc.CreateElement("msixenvelope");
			envelope.SetAttribute("uid", sourceUid);

			doc.AppendChild(envelope);

			int ids = 0;
			XmlElement sessionuids = doc.CreateElement("sessionuids");
			foreach (XmlNode uidNode in xmldoc.SelectNodes("/msix/beginsession/uid"))
			{
				XmlElement sessionuid = doc.CreateElement("id");
				sessionuid.InnerText = uidNode.InnerText;
				sessionuids.AppendChild(sessionuid);
				ids++;
			}
			Debug.Assert(ids > 0);
			envelope.AppendChild(sessionuids);

			byte [] bytes = MessageToBytes(source);

			int originalLength = bytes.Length;

			if (compress)
			{
				int compressedLen;
				byte [] compressedBytes = DataUtils.Compress(bytes, out compressedLen);

				// TODO: we use the array length as the length of the data,
				// so we need to copy the compressed data into a new array that
				// exactly fits it.
				byte [] compressedBuffer = new byte[compressedLen];
				Array.Copy(compressedBytes, compressedBuffer, compressedLen);
				bytes = compressedBuffer;
			}

			if (encrypt)
			{
				byte [] encryptedBytes = DataUtils.Encrypt(bytes);
				bytes = encryptedBytes;
			}

			string encoded = System.Convert.ToBase64String(bytes);


			XmlElement message = doc.CreateElement("message");
			if (compress)
			{
				message.SetAttribute("compression", "zlib");
				message.SetAttribute("uncompressed_length", originalLength.ToString());
			}

			if (encrypt)
				message.SetAttribute("encrypted", "true");


			message.InnerText = encoded;

			envelope.AppendChild(message);

			return doc.OuterXml;
		}

		public string DecodeMessage(string encoded,
																out string sourceUid,
																out string sourceMessageUid)
		{
			XmlDocument doc = new XmlDocument();
			doc.LoadXml(encoded);


			XmlElement root = doc.DocumentElement;

			XmlNode attr = root.Attributes.GetNamedItem("uid");

			if (attr == null)
				sourceUid = string.Empty;
			else
				sourceUid = attr.Value;

		//   <message uid="" compression="zlib" encrypted="true">
		//   </message>

			XmlElement message = (XmlElement) root.SelectSingleNode("message");
			if (message == null)
				throw new ApplicationException("encoded MSIX does not contain the mesage tag");

			attr = message.Attributes.GetNamedItem("uid");

			if (attr == null)
				sourceMessageUid = string.Empty;
			else
				sourceMessageUid = attr.Value;

			bool encrypted;
			bool compressed;
			int uncompressedLength = -1;

			attr = message.Attributes.GetNamedItem("encrypted");
			if (attr == null)
				encrypted = false;
			else
			{
				if (attr.Value == "true")
					encrypted = true;
				else if (attr.Value == "false")
					encrypted = false;
				else
					throw new ApplicationException("value of encrypted attribute is not 'true' or 'false'");
			}

			attr = message.Attributes.GetNamedItem("compression");
			if (attr == null)
				compressed = false;
			else
			{
				if (attr.Value == "zlib")
				{
					compressed = true;
					uncompressedLength = System.Convert.ToInt32(message.Attributes["uncompressed_length"].Value);
				}
				else
					throw new ApplicationException("unrecognized value for compression attribute");
			}

			string encodedMessage = message.InnerText;

			// convert from base 64 into the raw bytes
			byte [] bytes = System.Convert.FromBase64String(encodedMessage);
			// track the length separately since it might change if we decrypt
			// or decompress
			int bytesLength = bytes.Length;

			// decrypt
			if (encrypted)
			{
				int clearLength;
				DataUtils.Decrypt(bytes, out clearLength);
				// the data is decrypted in place but the length might change
				bytesLength = clearLength;
			}

			// decompress
			if (compressed)
			{
				Debug.Assert(uncompressedLength > 0);
				int testLen = uncompressedLength;
				byte [] decompressed = DataUtils.Decompress(bytes, out testLen);
				Debug.Assert(testLen == uncompressedLength);
				Debug.Assert(decompressed.Length == uncompressedLength);
				bytes = decompressed;
				bytesLength = uncompressedLength;
			}

			// convert the byte stream of UTF8 bytes into a normal string
			UTF8Encoding encoding = new UTF8Encoding();
			int charlen = encoding.GetCharCount(bytes, 0, bytesLength);
			char [] chars = new char[charlen];
			int len = encoding.GetChars(bytes, 0, bytesLength, chars, 0);
			Debug.Assert(len == charlen);

			string decoded = new string(chars);

			return decoded;
		}

		// convert an XML message into its raw bytes
		private byte [] MessageToBytes(string sourceMessage)
		{
			UTF8Encoding encoder = new UTF8Encoding();
			byte [] messageBytes = encoder.GetBytes(sourceMessage);
			return messageBytes;
		}

		private DataUtils DataUtils
		{
			get
			{
				// construct the data utilities class only when we need it
				if (mDataUtils == null)
					mDataUtils = new DataUtils();

				return mDataUtils;
			}
		}
		DataUtils mDataUtils;
	}

	[ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Supported, Isolation=TransactionIsolationLevel.Any)]
	[Guid("c47419b6-05fe-459c-a6f3-699a670a8cfa")]
	public class FailedMSIXMessageUtils : ServicedComponent, IFailedMSIXMessageUtils
	{
		public FailedMSIXMessageUtils()
		{
			mQueryAdapter.Init("Queries\\Pipeline");
		}

		// store a failed transaction message in the database
		public void SaveFailedTransactionMessage(string sessionID, string message)
		{
			try
			{
				using(IMTConnection conn = ConnectionManager.CreateConnection())
				{
					ConnectionInfo connInfo = conn.ConnectionInfo;

					int id_tran = FindFailedTransactionID(conn, sessionID);

					DeleteFailedTransactionByID(conn, id_tran);

					using (MetraTech.DataAccess.IBulkInsert bulkInsert =
									 new MetraTech.DataAccess.ArrayBulkInsert())
					{
						// TODO: do we need to pass in the current transaction?
						bulkInsert.Connect(connInfo);

						int rowsPerBatch = 100;

						bulkInsert.PrepareForInsert("t_failed_transaction_msix", rowsPerBatch);
						int fragmentLength = 2000;

						int index = 0;
						int len = message.Length;

						int row = 0;
						while (index < len)
						{
							int substrLen;
							if (index + fragmentLength > len)
								substrLen = len - index;
							else
								substrLen = fragmentLength;

							string substr = message.Substring(index, substrLen);

							bulkInsert.SetValue(1, MTParameterType.Integer, id_tran);
							bulkInsert.SetValue(2, MTParameterType.Integer, row++);
							bulkInsert.SetValue(3, MTParameterType.String, substr);
							bulkInsert.AddBatch();

							if (row % rowsPerBatch == 0)
								bulkInsert.ExecuteBatch();

							index += substrLen;

						}
						bulkInsert.ExecuteBatch();
					}
				}
			}
			catch (System.Exception err)
			{
				logger.LogError(err.ToString());
				throw;
			}
		}

		// load a failed transaction message from the database
        public string LoadFailedTransactionMessage(string sessionID)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                int id_tran = FindFailedTransactionID(conn, sessionID);

                using (IMTStatement stmt =
                    conn.CreateStatement(
                        string.Format("select tx_text from t_failed_transaction_msix where id_failed_transaction = {0} order by n_row",
                                                    id_tran)))
                {

                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        StringBuilder buffer = new StringBuilder();

                        while (reader.Read())
                        {
                            string substr = reader.GetString(0);
                            buffer.Append(substr);
                        }

                        return buffer.ToString();
                    }
                }
            }
        }

		// return true if the given session is stored in the database
		public bool HasSavedFailedTransactionMessage(string sessionID)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                int id_tran = FindFailedTransactionID(conn, sessionID);

                string find = "select 1 from "
                    + "t_failed_transaction_msix where id_failed_transaction = "
                    + id_tran;

                using (IMTStatement findstmt =
                    conn.CreateStatement(find))
                {

                    using (IMTDataReader reader = findstmt.ExecuteReader())
                    {
                        if (reader.Read())
                            return true;
                        else
                            return false;
                    }
                }
            }
		}

		// delete the saved version of a failed transaction from the database
		public void DeleteFailedTransactionMessage(string sessionID)
		{
			try
			{
				using(IMTConnection conn = ConnectionManager.CreateConnection())
				{
					ConnectionInfo connInfo = conn.ConnectionInfo;

					DeleteFailedTransactionByUID(conn, sessionID);
				}
			}
			catch (System.Exception err)
			{
				logger.LogError(err.ToString());
				throw;
			}
		}

        private int FindFailedTransactionID(IMTConnection conn, string sessionID)
        {
            string findID = "select id_failed_transaction from "
                + "t_failed_transaction where tx_FailureCompoundID_encoded = '"
                + sessionID + "' and State != 'R' and State != 'D'";

            using (IMTStatement findIDstmt =
                conn.CreateStatement(findID))
            {

                using (IMTDataReader reader = findIDstmt.ExecuteReader())
                {
                    if (!reader.Read())
                        throw new ApplicationException(string.Format("Unable to find failed transaction ID for session {0}", sessionID));

                    return reader.GetInt32(0);
                }
            }
        }

		private void DeleteFailedTransactionByID(IMTConnection conn, int id_tran)
		{
            using (IMTStatement deleteStmt = conn.CreateStatement("delete from t_failed_transaction_msix where id_failed_transaction = " + id_tran))
            {
                deleteStmt.ExecuteNonQuery();
            }
		}


		private void DeleteFailedTransactionByUID(IMTConnection conn, string uid)
		{
			mQueryAdapter.SetQueryTag("__DELETE_FAILED_TRANSACTION_BY_UID__");

            using (IMTPreparedStatement stmt =
                conn.CreatePreparedStatement(mQueryAdapter.GetQuery()))
            {

                stmt.AddParam(MTParameterType.String, uid);

                stmt.ExecuteNonQuery();
            }
		}

		private QueryAdapter.IMTQueryAdapter mQueryAdapter = new QueryAdapter.MTQueryAdapter();
		Logger logger = new Logger("[Pipeline]");
	}

}
