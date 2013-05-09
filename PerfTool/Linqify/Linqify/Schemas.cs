using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using System.Data.Linq;
using System.Data.SqlClient;
using System.IO;

namespace Linqify
{
    public class Schemas
    {
        public Dictionary<string, DataTable> allTables = new Dictionary<string, DataTable>();
        public Dictionary<string, DataTable> allSchemas = new Dictionary<string, DataTable>();

        public void readTable(string tableName)
        {
            SqlDataAdapter dataAdapter = new SqlDataAdapter();
            DataTable table = new DataTable();
            DataTable schemaTable = new DataTable();

            allTables.Add(tableName, table);
            allSchemas.Add(tableName, schemaTable);

            string whereClause = "";
            string Sql = string.Format("select top 1 * FROM {0} {1}", tableName, whereClause);
            SqlCommand cmd = Globals.conn.CreateCommand();
            cmd.CommandText = Sql;
            cmd.CommandType = CommandType.Text;
            dataAdapter.SelectCommand = cmd;
            dataAdapter.Fill(table);

            Sql = string.Format("select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='{0}'", tableName);
            cmd = Globals.conn.CreateCommand();
            cmd.CommandText = Sql;
            cmd.CommandType = CommandType.Text;
            dataAdapter.SelectCommand = cmd;
            dataAdapter.Fill(schemaTable);
        }

        public bool isNullableColumn(string tableName, string columnName)
        {
            DataTable table = allTables[tableName];
            DataTable schemaTable = allSchemas[tableName];
            DataColumn col = table.Columns[columnName];

            foreach (DataRow row in schemaTable.Rows)
            {
                if ((string)row["COLUMN_NAME"] == col.ColumnName)
                {
                    if ((string)row["IS_NULLABLE"] == "YES")
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        public string getBasicTypeName(string tableName, string columnName)
        {
            DataTable table = allTables[tableName];
            DataTable schemaTable = allSchemas[tableName];
            DataColumn col = table.Columns[columnName];

            string typeName = col.DataType.ToString();
            if (typeName.StartsWith("System."))
            {
                typeName = typeName.Substring(7);
            }
            return typeName;
        }


        public string getTypeName(string tableName, string columnName)
        {
            DataTable table = allTables[tableName];
            DataTable schemaTable = allSchemas[tableName];
            DataColumn col = table.Columns[columnName];

            string typeName = getBasicTypeName(tableName, columnName);
            if (isNullableColumn(tableName, columnName) && col.DataType.IsValueType)
            {
                typeName += "?";
            }
            return typeName;
        }

        public string Q(string s)
        {
            return '"' + s + '"';
        }


        public void processTable(StringBuilder sb, string tableName)
        {
            DataTable table = allTables[tableName];
            DataTable schemaTable = allSchemas[tableName];

            string className = getClassName(tableName);

            NetMeterCodeDom.workOnTableClass(className);

            sb.AppendLine();
            sb.AppendLine("  [DataContract]");
            sb.AppendFormat("  public partial class {0} : IDbObj", className);
            sb.AppendLine();

            sb.AppendLine("  {");
            foreach (DataColumn col in table.Columns)
            {
                string typeName = getTypeName(tableName, col.ColumnName);
                sb.AppendLine("  [DataMember]");
                sb.AppendFormat("    public {0} ", typeName);
                sb.AppendFormat("{0}", col.ColumnName);
                sb.Append(" {set; get;}");
                sb.AppendLine();

                bool isNullable = isNullableColumn(tableName, col.ColumnName);

                NetMeterCodeDom.addDataMember(col.ColumnName, col.DataType, isNullable);
            }

            // TableName
            sb.Append("     public string TableName() { ");
            sb.Append(string.Format("return {0}; ", Q(tableName)));
            sb.Append("}");
            sb.AppendLine();
            NetMeterCodeDom.addMethod_TableName(tableName);

            //AdapterWidget
            sb.AppendLine("      public static AdapterWidget adapterWidget;");
            NetMeterCodeDom.addField_AdapterWidget();

            // ToString
            sb.AppendLine();
            sb.AppendLine("      override public string ToString()");
            sb.AppendLine("      {");
            sb.AppendLine("        StringBuilder sb = new StringBuilder();");
            foreach (DataColumn col in table.Columns)
            {
                sb.AppendFormat("        sb.Append(\"{0}: \");", col.ColumnName);
                sb.AppendLine();
                sb.AppendFormat("        sb.Append({0});", col.ColumnName);
                sb.AppendLine();
                sb.AppendLine("        sb.AppendLine();");
            }
            sb.AppendLine("        return sb.ToString();");
            sb.AppendLine("      }");

            // ToRow

            List<FieldDesc> fieldDescs = new List<FieldDesc>();

            sb.AppendLine();
            sb.AppendLine("      public void ToRow(DataRow row)");
            sb.AppendLine("      {");
            foreach (DataColumn col in table.Columns)
            {
                sb.AppendFormat("        ");
                if (isNullableColumn(tableName, col.ColumnName))
                {
                    sb.AppendFormat("if(this.{1} != null) ", col.Ordinal, col.ColumnName);
                }
                sb.AppendFormat("row[{0}] = this.{1};", col.Ordinal, col.ColumnName);
                sb.AppendLine();

                FieldDesc fd = new FieldDesc();
                fd.name = col.ColumnName;
                fd.ordinal = col.Ordinal;
                fd.isNullable = isNullableColumn(tableName, col.ColumnName);
                fieldDescs.Add(fd);
            }
            sb.AppendLine("      }");

            NetMeterCodeDom.addMethod_ToRow(fieldDescs);

            // Insert
            sb.AppendLine();
            sb.AppendLine("      public void insert()");
            sb.AppendLine("      {");
            sb.AppendLine("        DataRow row = adapterWidget.createRow();");
            sb.AppendLine("        ToRow( row);");
            sb.AppendLine("        adapterWidget.insertRow( row);");
            sb.AppendLine("      }");

            NetMeterCodeDom.addMethod_Insert();

            // End of class
            sb.AppendLine("  }");

        }


        public string getClassName(string tableName)
        {
            string r = "";
            if (tableName.StartsWith("t_"))
            {
                tableName = tableName.Substring(2);
            }

            bool needsCap = true;
            foreach (char c in tableName)
            {
                char cc = c;
                if (cc == '_')
                {
                    needsCap = true;
                    continue;
                }
                if (needsCap)
                {
                    cc = char.ToUpper(c);
                    needsCap = false;
                }
                r += cc;
            }

            return r;
        }
    }
}
