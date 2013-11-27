using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;

namespace NetMeterObj
{
    public class AdapterWidget
    {
        SqlDataAdapter dataAdapter = new SqlDataAdapter();
        SqlConnection conn;

        public string tableName;
        public Int32 objectId;
        public DataTable table = new DataTable();
        public DataTable insertTable = new DataTable();
        public DataTable identityTable = new DataTable();
        public DataTable foreignTable = new DataTable();

        string[] insertCmds = new string[20];
        public bool hasIdentity = false;
        public bool hasForeign = false;
        public List<Int32> foreignObjects = new List<Int32>();
        DataRow referenceRow;

        public bool loadFromDb = true;
        bool doDbOps = true;
        bool bulkCopyMode = true;

        public void build(SqlConnection conn, string tableName, string whereClause = "")
        {
        }

        public void getObjectID()
        {
            string Sql = string.Format("select OBJECT_ID(N'[dbo].[{0}]') as value", tableName);
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = Sql;
            cmd.CommandType = CommandType.Text;
            dataAdapter.SelectCommand = cmd;
            DataTable tbl = new DataTable();
            dataAdapter.Fill(tbl);
            objectId = (Int32)tbl.Rows[0]["value"];
        }


        public void build(SqlConnection conn, string whereClause=null)
        {
            //this.tableName = tableName;
            this.conn = conn;

            getObjectID();

            string Sql = string.Format("select top 1 * FROM {0}", tableName);
            if (whereClause != null)
                Sql += whereClause;

            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = Sql;
            cmd.CommandType = CommandType.Text;
            dataAdapter.SelectCommand = cmd;
            dataAdapter.Fill(table);

            if (table.Rows.Count > 0)
            {
                referenceRow = table.Rows[0];
            }
            else
            {
                referenceRow = table.NewRow();
            }

            insertTable = table.Clone();

            // Check to see if we have any identity columns
            Sql = string.Format("select * from sys.identity_columns WHERE OBJECT_NAME(OBJECT_ID) = '{0}'", tableName);
            cmd = conn.CreateCommand();
            cmd.CommandText = Sql;
            cmd.CommandType = CommandType.Text;
            dataAdapter.SelectCommand = cmd;
            dataAdapter.Fill(identityTable);
            if (identityTable.Rows.Count > 0)
                hasIdentity = true;

            getForeignKeys();

            buildInsertCmds();
        }


        private void getForeignKeys()
        {
            // Check to see if we have any foreign keys
            string Sql = string.Format("select * from sys.foreign_keys WHERE parent_object_id = OBJECT_ID(N'[dbo].[{0}]')", tableName);
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = Sql;
            cmd.CommandType = CommandType.Text;
            dataAdapter.SelectCommand = cmd;
            dataAdapter.Fill(foreignTable);
            if (foreignTable.Rows.Count > 0)
            {
                hasForeign = true;
                foreach (DataRow row in foreignTable.Rows)
                {
                    foreignObjects.Add( (Int32)row["referenced_object_id"]);
                }
            }
        }

        public void buildInsertCmds()
        {

            List<string> cnames = new List<string>();
            foreach (DataColumn col in table.Columns)
            {
                cnames.Add(col.ColumnName);
            }
            string insertCols = string.Join(",", cnames);

            // Build the insert commands
            string sql = string.Format("insert into {0} ({1}) values ", tableName, insertCols);

            List<string> pnames = new List<string>();
            foreach (DataColumn col in table.Columns)
            {
                pnames.Add("@" + col.ColumnName);
            }
            sql += "(" + string.Join(",", pnames) + ")";
            Console.WriteLine(sql);

            insertCmds[1] = sql;
        }

        public void insertRow(DataRow row)
        {
            if (bulkCopyMode)
            {
                insertTable.Rows.Add(row);
            }
            else
            {
                SqlCommand cmd;
                cmd = conn.CreateCommand();

                if (hasIdentity)
                {
                    string pre = string.Format(" SET IDENTITY_INSERT {0} ON ", tableName);
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = pre;
                    cmd.ExecuteNonQuery();
                }

                cmd.CommandType = CommandType.Text;
                cmd.CommandText = insertCmds[1];
                foreach (DataColumn col in table.Columns)
                {
                    cmd.Parameters.AddWithValue("@" + col.ColumnName, row[col.Ordinal]);
                }
                if (doDbOps) cmd.ExecuteNonQuery();

                if (hasIdentity)
                {
                    string post = string.Format(" SET IDENTITY_INSERT {0} OFF ", tableName);
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = post;
                    cmd.ExecuteNonQuery();
                }

            }
        }

        public bool hasPendingInserts()
        {
            return (insertTable.Rows.Count > 0);
        }

        public void flush()
        {
            if (bulkCopyMode && hasPendingInserts())
            {
                // Make sure that our foreign keys have been written
                foreach( Int32 fo in foreignObjects)
                {
                    AdapterWidget aw = AdapterWidgetFactory.byObjectId(fo);
                    if (aw == null)
                        continue;
                    if (aw.hasPendingInserts())
                        return;
                }

                // Create the SqlBulkCopy object.  
                // Note that the column positions in the source DataTable  
                // match the column positions in the destination table so  
                // there is no need to map columns.  
                SqlBulkCopyOptions copyOptions = new SqlBulkCopyOptions();
                copyOptions = SqlBulkCopyOptions.CheckConstraints | SqlBulkCopyOptions.TableLock | SqlBulkCopyOptions.KeepIdentity;
                using (SqlBulkCopy bulkCopy = new SqlBulkCopy(conn, copyOptions, null))
                {
                    bulkCopy.DestinationTableName = tableName;
                    try
                    {
                        // Write from the source to the destination.
                        if (doDbOps) bulkCopy.WriteToServer(insertTable);
                        insertTable.Clear();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.Message);
                    }
                }
            }
        }


        public DataRow cloneReferenceRow()
        {
            DataRow row = insertTable.NewRow();

            foreach (DataColumn col in table.Columns)
            {
                int ix = col.Ordinal;
                row[ix] = referenceRow[ix];
            }

            return row;
        }

        public DataRow createRow()
        {
            return insertTable.NewRow();
        }

        public void DisplayReferenceRow()
        {
            foreach (DataColumn col in table.Columns)
            {
                Console.WriteLine("Name is {0} {1}", col.ColumnName, col.DataType);
                Console.WriteLine("  value: {0}", referenceRow[col.Ordinal]);
            }

        }


    }
}
