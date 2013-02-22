using System.Runtime.Serialization;
using System.Collections.ObjectModel;
using System.IO;
using System.Xml;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    [DataContract]
    public class EmailTemplate
    {
        #region Properties
        [DataMember]
        public string Name { get; set; }

        /// <summary>
        /// The name of the available entities
        /// </summary>
        [DataMember]
        public Collection<string> EntityParameters { get; private set; }

        [DataMember]
        public string Description { get; set; }

        #endregion

        #region Constructor
        public EmailTemplate()
        {
            EntityParameters = new Collection<string>();
        }
        #endregion

        #region Methods
        public static EmailTemplate CreateFromFile(string file)
        {
            using (var fs = new FileStream(file, FileMode.Open))
            {
                using (var reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas()))
                {
                    var ser = new DataContractSerializer(typeof (EmailTemplate));
                    var template = (EmailTemplate) ser.ReadObject(reader, true);
                    return template;
                }
            }
        }

        public void Save(string dirPath)
        {
            var filePath = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.xml", dirPath, Name);
            using (var writer = new FileStream(filePath, FileMode.Create))
            {
                var ser = new DataContractSerializer(typeof (EmailTemplate));
                ser.WriteObject(writer, this);
            }
        }
        #endregion
    }
}
