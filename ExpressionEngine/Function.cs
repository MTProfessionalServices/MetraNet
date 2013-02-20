using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Globalization;
using System.Runtime.Serialization;
using System.IO;
using System.Xml.Linq;

namespace MetraTech.ExpressionEngine
{
    [DataContract(Namespace = "MetraTech")]
    public class Function : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The function's name
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        /// <summary>
        /// The category. Used for filtering. Ensure that proper case is used.
        /// TODO Localize
        /// </summary>
        [DataMember]
        public string Category { get; set; }

        /// <summary>
        /// The data type that the function returns
        /// </summary>
        [DataMember]
        public DataTypeInfo ReturnType { get; set; }

        /// <summary>
        /// The description. Used in tool tips, online help, etc.
        /// This should be localized in future.
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// The parameters that are fixed.
        /// </summary>
        [DataMember]
        public PropertyCollection FixedParameters { get; set; }

        /// <summary>
        /// Some functions suport multiple arguments. For example, Min(a, b, c...). At this point, we require that they all be of the same 
        /// datatype which is set by this property. 
        /// </summary>
        [DataMember]
        public Property DynamicParameterPrototype { get; set; }

        /// <summary>
        /// The minimum number of dynamic parameters. Min, Max, Average would all be 2.
        /// </summary>
        [DataMember]
        public int DynamicParameterMin { get; set; }

        #endregion

        #region GUI Helper Properties (move in future)
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "Function.png"; } }
        #endregion

        #region Constructor
        public Function()
        {
        }

        public Function(string name, string category, string description)
        {
            Name = name;
            Category = category;
            Description = description;

            FixedParameters = new PropertyCollection(this);
            DynamicParameterPrototype = null;
        }
        #endregion
    
        #region Methods

        public string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}()", Name);
            }
        }
        #endregion

        #region XML Methods

        //public string GetXmlContent()
        //{
        //    var writer = new FileStream(filePath, FileMode.Create);
        //    var ser = new DataContractSerializer(typeof(Function));
        //    ser
        //    ser.WriteObject(writer, this);
        //}
        public void Save(string dirPath)
        {
            var filePath = string.Format(@"{0}\{1}.xml", dirPath, Name);
            var writer = new FileStream(filePath, FileMode.Create);
            var ser = new DataContractSerializer(typeof(Function));
            ser.WriteObject(writer, this);
            writer.Close();
        }

        //public static Function CreateFromFile(string file)
        //{
        //    var fs = new FileStream(file, FileMode.Open);
        //    var reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
        //    var ser = new DataContractSerializer(typeof(Function));
        //    var function = (Function)ser.ReadObject(reader, true);
        //    fs.Close();
        //    reader.Close();
        //    return function;
        //}

        public static Function CreateFromFile(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString(xmlContent);
        }

        public static Function CreateFromString(string xmlContent)
        {
            var xElement = XElement.Parse(xmlContent);
            var xmlReader = xElement.CreateReader();
            var ser = new DataContractSerializer(typeof(Function));
            var function = (Function)ser.ReadObject(xmlReader);
            xmlReader.Close();
            return function;
        }

        #endregion
    }
}
