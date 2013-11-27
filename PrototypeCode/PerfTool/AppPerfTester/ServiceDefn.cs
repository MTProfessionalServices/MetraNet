using System.Collections.Generic;
using System.Data.Linq;
using System.IO;
using System.Linq;
using System.Xml;

namespace BaselineGUI
{

    public class ServiceDefn
    {

        public class Field
        {
            public string name;
            public string theType;
            public string enumSpace;
            public string enumType;
            public bool required;
            public string defaultValue;
            public int length;
            public string description;

            public string cstype;
            public bool lastField = false;

            public string columnName = "";
        }

        public class SvcDefProp
        {
            public string nm_name { set; get; }
            public string nm_column_name { set; get; }
        }


        //LiveStatus liveStatus;
        StreamWriter writer;

        public string fullName;
        public int id_service_def;

        public XmlDocument doc = new XmlDocument();
        public List<Field> fields = new List<Field>();


        public ServiceDefn()
        {
        }


        public string shortName()
        {
            string[] tokens = fullName.Split('/');
            return tokens[tokens.Length - 1];
        }


        public void loadFromDB(int id)
        {
            Dictionary<string, Field> dict = new Dictionary<string, Field>();

            foreach (Field f in fields)
            {
                dict.Add(f.name, f);
            }

            id_service_def = id;
            DataContext dc = new DataContext(Framework.conn);

            List<SvcDefProp> props = dc.ExecuteQuery<SvcDefProp>(string.Format("select nm_name, nm_column_name from t_service_def_prop where id_service_def={0}", id)).ToList<SvcDefProp>();
            foreach (SvcDefProp prop in props)
            {
                Field f = dict[prop.nm_name];
                f.columnName = prop.nm_column_name;
            }

        }


        public void getString(XmlElement elt, string name, ref string v)
        {
            XmlNode n = elt.SelectSingleNode(name);
            if (n != null)
            {
                v = n.InnerText;
            }
        }


        public void getInt(XmlElement elt, string name, ref int v)
        {
            try
            {
                XmlNode n = elt.SelectSingleNode(name);
                if (n != null)
                {
                    v = int.Parse(n.InnerText);
                }
            }
            catch
            {
            }

        }


        public void LoadFromXML(string fn)
        {

            doc.Load(fn);
            XmlElement root = doc.DocumentElement;
            XmlNode nameNode = root.SelectSingleNode("name");
            fullName = nameNode.InnerText;

            XmlNodeList nodes = root.SelectNodes("//ptype");
            foreach (XmlElement elt in nodes)
            {
                Field field = new Field();
                getString(elt, "dn", ref field.name);
                getString(elt, "type", ref field.theType);
                getInt(elt, "length", ref field.length);
                getString(elt, "defaultvalue", ref field.defaultValue);
                getString(elt, "description", ref field.description);

                if (field.theType == "enum")
                {
                    XmlNode n = elt.SelectSingleNode("type");

                    field.enumSpace = n.Attributes["EnumSpace"].InnerText;
                    field.enumType = n.Attributes["EnumType"].InnerText;
                }

                fields.Add(field);

                field.cstype = getCSharpType(field.theType);
            }

            // Mark the last field so we can adjust the MetraFlow delimeter
            fields[fields.Count - 1].lastField = true;
        }


        public void E(string s)
        {
            if (writer != null)
            {
                writer.WriteLine(s);
            }
         }

        public void F(string s, params object[] objs)
        {
            E(string.Format(s, objs));
        }


        public string getCSharpType(string s)
        {
            switch (s)
            {
                case "decimal":
                    return "double";
                case "varchar":
                    return "string";
                case "nvarchar":
                    return "string";
                case "int32":
                    return "int";
                case "timestamp":
                    return "DateTime";

                default:
                    return s;
            }

        }


        public void generateFieldInit(Field f)
        {
            switch (f.cstype)
            {
                case "string":
                    F("        {0} = \"\";", f.name);
                    break;
                case "int":
                    F("        {0} = 0;", f.name);
                    break;
                case "double":
                    F("        {0} = 0.0;", f.name);
                    break;
                case "DateTime":
                    F("        {0} = DateTime.Now;", f.name);
                    break;
                case "enum":
                    F("        initEnum(ref {0});", f.name);
                    break;
                default:
                    F("        // {0} = {1};", f.name, f.cstype);
                    break;
            }

        }

        public void generateDomainModel(StreamWriter writer)
        {
            this.writer = writer;

            E("using System;");
            E("using System.Collections.Generic;");
            E("using System.Linq;");
            E("using System.Text;");
            E("using MetraTech.DomainModel.Enums;");
            E("using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSM;");
            E("using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSMReference;");
            E("using System;");
            E("using System.Reflection;");
            E("using System.IO;");
            E("");
            E("namespace BaselineGUI");
            E("{");
            F("public class SvcDef{0}Base : SvcDefBase", shortName());
            E("{");
            foreach (Field f in fields)
            {
                string s = f.cstype;
                if (f.cstype == "enum")
                    s = f.enumType;
                E(string.Format("    public {0} {1}; // length:{2};", s, f.name, f.length));
            }

            E("  public void init()");
            E("  {");
            foreach (Field f in fields)
            {
                generateFieldInit(f);
            }
            E("  }");

            E("  public void print(TextWriter writer)");
            E("  {");
            bool needsDelim = false;
            foreach (Field f in fields)
            {
                if (needsDelim)
                {
                    E("      writer.Write(\"|\");");
                }
                needsDelim = true;

                string s;
                s = "    writer.Write(\"{0}\", ";
                if (f.cstype == "enum")
                {
                    s += string.Format("EnumHelper.GetEnumEntryName({0})", f.name);
                }
                else if (f.cstype == "DateTime")
                {
                    s += string.Format("FLS_ISO8601({0})", f.name);
                }
                else
                {
                    s += f.name;
                }
                s += ");";
                E(s);
            }
            E("      writer.WriteLine();");
            E("  }");


            E("}");

            E("}");

            this.writer = null;
        }


        public void generateMetraFlowRewrite(StreamWriter writer)
        {

            E("");
            E("udr_rename:rename [");

            foreach (Field f in fields)
            {
                F("  from=\"{0}\", to=\"{1}\",", f.name, f.columnName);
            }

            E("  mode=\"parallel\"");
            E("];");
        }


        public void generateMetraFlowMeter(StreamWriter writer)
        {
            E("");
            E("");
            F("udr_meter: meter[service = \"{0}\",", fullName);
            E("  collectionIDEncoded=$batchID,");
            E("  targetCommitSize = 1,");
            E("  targetMessageSize = 90,");
            E("  mode = \"parallel\"");
            E("];");
        }


        public void generateMetraFlowImport(StreamWriter writer)
        {
            E("");
            E("udr_import:import [");
            E("  mode=\"sequential\",");
            E("  filename=\"$(importFile)\",");
            E("  format=\"import_data(");
            foreach (Field f in fields)
            {
                string s = string.Format("/* {0} */", f.theType);

                string delim = "'|'";
                if (f.lastField)
                    delim = "crlf";

                string mods = string.Format("(delimiter={0}, null_value='')", delim);
                switch (f.theType)
                {
                    case "nvarchar":
                        s = "text_delimited_nvarchar";
                        break;
                    case "int32":
                        s = "text_delimited_base10_int32";
                        break;
                    case "int64":
                        s = "text_delimited_base10_int64";
                        break;
                    case "timestamp":
                        s = "iso8601_datetime";
                        break;
                    case "string":
                        s = "text_delimited_nvarchar";
                        break;
                    case "decimal":
                        s = "text_delimited_base10_decimal";
                        break;
                    case "enum":
                        s = "text_delimited_enum";
                        mods = string.Format("(enum_space='{0}', enum_type='{1}', delimiter={2})", f.enumSpace, f.enumType, delim);
                        break;
                }

                string comma = ",";
                if (f.lastField)
                    comma = "";

                F("    {0} {1}{2}{3}", f.name, s, mods, comma);
            }
            E("  )\"");
            E("];");
        }


        public void generateMetraFlowScript(StreamWriter writer)
        {
            this.writer = writer;

            generateMetraFlowImport(writer);
            generateMetraFlowRewrite(writer);
            generateMetraFlowMeter(writer);

            E("udr_import -> udr_rename -> udr_meter;");

            this.writer = null;
        }

    }


}
