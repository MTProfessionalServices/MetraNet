
//using System.Xml;
//using System.Xml.Schema;		// for Schema validation
// for XML attribs controlling Serialization

namespace BaselineGUI.Blaster
{
    public class RowSpec
    {
        public string FieldName
        {
            get { return _FieldName; }
            set { _FieldName = value; }
        }
        private string _FieldName;

        public string DataType
        {
            get { return _datatype; }
            set { _datatype = value; }
        }
        private string _datatype;

        public DataGenType DataGenType
        {
            get { return _DataGenType; }
            set { _DataGenType = value; }
        }
        private DataGenType _DataGenType;

        public string Value
        {
            get { return _Value; }
            set { _Value = value; }
        }
        private string _Value;

        public bool ConvertToBinary
        {
            get { return _ConvertToBinary; }
            set { _ConvertToBinary = value; }
        }
        private bool _ConvertToBinary;

        public bool SqlQuoted
        {
            get { return _SqlQuoted; }
            set { _SqlQuoted = value; }
        }
        private bool _SqlQuoted;

    }

}
