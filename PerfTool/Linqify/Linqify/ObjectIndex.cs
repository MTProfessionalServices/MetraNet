using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Linqify
{
    public class ObjectIndex
    {
        // The description
        public string tableName;
        public List<string> colNames;
        public string column1;
        public string column2;
        public bool isUnique;

        // Calculated
        public int keyColCnt;
        public string keyType;
        public string valueType;
        public string indexType;
        public string templateClassName;
        public string fullClassName;
        public string instanceName;
        List<string> colBasicTypes;
        List<string> colTypes; 
        public List<bool> colIsNullable;

        public ObjectIndex(string tableName, bool isUnique, string column1, string column2 = "")
        {
            this.tableName = tableName;
            this.isUnique = isUnique;
            colNames = new List<string>();
            if (column1 != "")
                colNames.Add(column1);
            if (column2 != "")
                colNames.Add(column2);
        }

        public void deriveFields(Schemas schemas)
        {
            colTypes = new List<string>(); 
            colBasicTypes = new List<string>();
            colIsNullable = new List<bool>();

            foreach (string s in colNames)
            {
                // We want the non-nullable version when declaring
                colTypes.Add(schemas.getTypeName(tableName, s));
                colBasicTypes.Add(schemas.getBasicTypeName(tableName, s)); 
                colIsNullable.Add(schemas.isNullableColumn(tableName, s));
            }

            // Key Type

            if (colBasicTypes.Count == 1)
            {
                keyType = colBasicTypes[0];
            }
            else
            {
                string t = string.Join(",", colBasicTypes);
                keyType = string.Format("Tuple<{0}>", t);
            }

            // Value Type
            valueType = schemas.getClassName(tableName);

            templateClassName = "Dictionary";
            if (!isUnique)
            {
                templateClassName = "Lexicon";
            }

            fullClassName = string.Format("{0}<{1},{2}>", templateClassName, keyType, valueType);

            instanceName = string.Format("{0}By", valueType);
            foreach (string s in colNames)
            {
                instanceName += "_" + s;
            }
        }


        public void declare(StringBuilder sb)
        {
            sb.AppendFormat("    public static {0} {1};", fullClassName, instanceName);
            sb.AppendLine();
        }

        public string extractKey()
        {
            List<string> list = new List<string>();
            int ix = 0;
            foreach (string s in colNames)
            {
                string t = "item." + s;
                // Remove nullability
                if (colBasicTypes[ix] != colTypes[ix])
                    t = "(" + colBasicTypes[ix] + ")" + t;
                list.Add(t);
                ix++;
            }
            string fields = string.Join(",", list);
            if (colNames.Count == 1)
                return fields;

            return string.Format("new {0}( {1})", keyType, fields);
        }

        public void construct(StringBuilder sb)
        {
            sb.AppendFormat("      {0} = new {1}();", instanceName, fullClassName);
            sb.AppendLine();
            sb.AppendFormat("      foreach( var item in {0}List)", valueType);
            sb.AppendLine();
            sb.AppendLine("        {");
            int ix = 0;
            foreach (string s in colNames)
            {
                if (colIsNullable[ix])
                {
                    sb.AppendFormat("           if( item.{0} == null) continue;", s);
                    sb.AppendLine();
                }
                ix++;
            }
            sb.AppendFormat("          {0}.Add( {1}, item);", instanceName, extractKey());
            sb.AppendLine();
            sb.AppendLine("        }");
        }

    }
}
