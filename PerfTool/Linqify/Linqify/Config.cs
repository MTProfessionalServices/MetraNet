using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.IO;

namespace Linqify
{
    public static class Config
    {
        public static XmlDocument doc;

        static Config()
        {
            doc = new XmlDocument();
            doc.PreserveWhitespace = false;
            doc.Load(@"Assets\config.xml");
        }

        public static List<string> getUsings()
        {
            List<string> list = new List<string>();
            XmlNodeList nl = doc.SelectNodes("//config/usings/using");
            foreach (XmlNode n in nl)
            {
                string s = n.InnerText;
                list.Add(s.Trim());
            }
            return list;
        }

        public static List<string> getTableNames()
        {
            List<string> list = new List<string>();
            XmlNodeList nl = doc.SelectNodes("//config/tables/table/name");
            foreach (XmlNode n in nl)
            {
                string s = n.InnerText;
                list.Add(s.Trim());
            }
            return list;
        }

        public static List<List<string>> getIndicesForTable(string tableName)
        {
            List<List<string>> allIndices = new List<List<string>>();

            XmlNode n = doc.SelectSingleNode(string.Format("//config/tables/table/name[text()='{0}'] ", tableName));

            if (n != null)
            {
                XmlNodeList nl = n.SelectNodes("index");
                foreach (XmlNode idx in nl)
                {
                    List<string> colNames = new List<string>();
                    XmlNodeList cols = idx.SelectNodes("col");
                    foreach (XmlNode col in cols)
                    {
                        string cname = col.InnerText.Trim();
                        if (cname != "")
                        {
                            colNames.Add(cname);
                        }
                    }
                    if (colNames.Count > 0)
                    {
                        allIndices.Add(colNames);
                    }
                }
            }

            return allIndices;
        }

    }
}
