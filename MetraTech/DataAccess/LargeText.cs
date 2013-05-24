
namespace MetraTech.DataAccess
{
  using System;
  using System.Text;
	using System.Diagnostics;
	using System.Runtime.InteropServices;

	[Guid("eb84604e-1322-421f-aaaa-cba1f0eb88bb")]
	[ComVisible(true)]
	public interface ILargeTextManager
	{
		/// <summary>
		/// insert a large string of data into the database
		/// <summary>
		void Insert(IBulkInsert bulkInsert,
								int id, string text);
		/// <summary>
		/// retrieve a large string of data from the database
		/// <summary>
		string Retrieve(IMTConnection conn, string tableName,
										int id);

		/// <summary>
		/// delete a large string of data from the database
		/// <summary>
		void Delete(IMTConnection conn, string tableName,
								int id);
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("47473b12-a8b9-48c5-9b78-454d2f1bfd01")]
	[ComVisible(true)]
	public class LargeTextManager : ILargeTextManager
	{
		/// <summary>
		/// insert a large string of data into the database
		/// <summary>
		public void Insert(IBulkInsert bulkInsert,
											 int id, string text)
    {
			// TODO: need to verify that this is transactional

			int fragmentLength = 2000;

			int index = 0;
			int len = text.Length;

			int row = 0;
			while (index < len)
			{
				int substrLen;
				if (index + fragmentLength > len)
					substrLen = len - index;
				else
					substrLen = fragmentLength;

				string substr = text.Substring(index, substrLen);

				bulkInsert.SetValue(1, MTParameterType.Integer, id);
				bulkInsert.SetValue(2, MTParameterType.Integer, row++);
				bulkInsert.SetValue(3, MTParameterType.String, substr);
				bulkInsert.AddBatch();

				if (row % 1000 == 0)
					bulkInsert.ExecuteBatch();

				index += substrLen;

			}
			bulkInsert.ExecuteBatch();
		}

		/// <summary>
		/// retrieve a large string of data from the database
		/// <summary>
        public string Retrieve(IMTConnection conn, string tableName,
                                                     int id)
        {
            using (IMTStatement stmt =
                conn.CreateStatement(
                    String.Format("select tx_text from {0} where id = {1} order by n_row",
                                                tableName, id)))
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

		/// <summary>
		/// delete a large string of data from the database
		/// <summary>
        public void Delete(IMTConnection conn, string tableName,
                                             int id)
        {
            using (IMTStatement stmt =
                conn.CreateStatement(
                    String.Format("delete from {0} where id = {1}", tableName, id)))
            {

                stmt.ExecuteNonQuery();
            }
        }

	}
}
