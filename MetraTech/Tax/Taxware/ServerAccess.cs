using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml;
using System.Xml.Serialization;
using System.ComponentModel;

namespace MetraTech.Tax.Taxware.Test
{
    // TODO: Support encrypted passwords, and all fields possible in servers.xml

    [XmlRoot("xmlconfig")]
    public class ServerAccess
    {
        [XmlElement("server")]
        public List<Server> Servers = null;
        static private String m_rootDirectory = "R:\\";

        public ServerAccess()
        {
        }

        public static ServerAccess Load()
        {
            // Deserialization
            XmlSerializer s = new XmlSerializer(typeof(ServerAccess));
            ServerAccess sa;

            string configFile = m_rootDirectory + "\\config\\ServerAccess\\servers.xml";
            
            if (!File.Exists(configFile))
                throw new FileNotFoundException("The file servers.xml could not be found in the folder " + m_rootDirectory + "\\config\\ServerAccess");

            TextReader r = new StreamReader(configFile);
            sa = (ServerAccess)s.Deserialize(r);

            r.Close();
            return sa;
        }

        // Indexer on ServerType
        public Server this[string serverType]
        {
            get
            {
                foreach (Server s in Servers)
                {
                    if (s.ServerType.ToUpper() == serverType.ToUpper())
                    {
                        return s;
                    }
                }
                return null;
            }
        }

    }

    public class Server
    {
        [XmlElement("servertype")]
        public string ServerType;

        [XmlElement("servername")]
        public string ServerName;

        [XmlElement("databasename")]
        public string DatabaseName;

        [XmlElement("databasedriver")]
        public string DatabaseDriver;

        [XmlElement("databasetype")]
        public string DatabaseType;

        [XmlElement("username")]
        public string Username;

        [XmlElement("password")]
        public string Password;

        // [XmlElement("password")]
        // public PasswordProperty Password;

        public Server()
        {
        }
    }

    public class PasswordProperty
    {
        [XmlElement("password")]
        public string Password;

        [XmlAttribute("encrypted")]
        public string Encrypted;
    }
}
