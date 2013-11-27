using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Xml;
using System.IO;


namespace NetMeterObj
{
    public class IdAllocatorBasic
    {
        // For ID's in one of the ID tables
        string tableName;
        string valColumn;
        string key;

        bool isAuto;

        Int64 nextValue;
        Int64 stayLessThanValue;
        Int64 blockSize = 1000;

        SqlConnection conn;
        SqlDataAdapter dataAdapter = new SqlDataAdapter();

        public IdAllocatorBasic(SqlConnection conn, string key, string tableName = "", string valColumn = "")
        {
            this.conn = conn;
            this.key = key;
            this.valColumn = "id_current";
            this.tableName = "t_current_id";
            this.isAuto = false;

            if (refreshFromDB())
                return;

            this.valColumn = "id_current";
            this.tableName = "t_current_long_id";

            if (refreshFromDB())
                return;

            isAuto = true;
            this.tableName = tableName;
            this.valColumn = valColumn;

            refreshFromDB();
        }



        public bool refreshFromDB()
        {
            DataTable table = new DataTable();

            string sql;
            if (isAuto)
            {
                sql = string.Format("select max({0}) as value from {1}", valColumn, tableName);
            }
            else
            {
                sql = string.Format("select {0} as value from {1} where nm_current='{2}'", valColumn, tableName, key);
            }

            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = sql;
            cmd.CommandType = CommandType.Text;
            dataAdapter.SelectCommand = cmd;
            dataAdapter.Fill(table);
            if (table.Rows.Count == 0)
                return false;

            DataRow row = table.Rows[0];
            Object cell = row[0];
            if (cell is Int64?)
            {
                nextValue = (Int64)cell;
            }
            else if (cell is Int32?)
            {
                nextValue = (Int32)cell;
            }
            else
            {
                throw new Exception("Can't convert");
            }

            // Values explicitly kept in the id tables are the next ID
            // auto generated has the highest, so fix that here
            if (isAuto)
                nextValue = nextValue + 1;
            stayLessThanValue = nextValue;
            return true;
        }


        public void getBlock()
        {
            // We use optimistic concurrency here to obtain a block of ID's
            // from the database

            int attempts = 10;
            while (attempts-- > 0)
            {
                try
                {
                    refreshFromDB();
                    stayLessThanValue += blockSize;

                    if (isAuto)
                        return;

                    string sql = string.Format("update {0} set {1}={2} where {1}={3} and nm_current='{4}'", tableName, valColumn, stayLessThanValue, nextValue, key);
                    SqlCommand cmd = conn.CreateCommand();
                    cmd.CommandText = sql;
                    cmd.CommandType = CommandType.Text;
                    int rowCount = cmd.ExecuteNonQuery();
                    if (rowCount == 1)
                        return;

                }
                catch
                {
                }
            }
            // TODO Add failure handler here
        }


        public Int32 getID32()
        {
            if (!isAuto && nextValue >= stayLessThanValue)
            {
                getBlock();
            }

            Int32 result = (Int32)nextValue++;
            return result;
        }

        public Int64 getID64()
        {
            if (!isAuto && nextValue >= stayLessThanValue)
            {
                getBlock();
            }

            Int64 result = nextValue++;
            return result;
        }

    }

}
