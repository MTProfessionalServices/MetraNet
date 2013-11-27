
//using System.Xml;
//using System.Xml.Schema;		// for Schema validation
using System.Xml.Serialization;		// for XML attribs controlling Serialization



namespace BaselineGUI.Blaster
{
    public class RowSpecA
    {
        [XmlAttribute]
        public string name;

        [XmlAttribute]
        public string datatype;

        [XmlAttribute]
        public string datagentype;

        [XmlAttribute]
        public string value;

        [XmlAttribute]
        public string sqlquoted;
    }
}
