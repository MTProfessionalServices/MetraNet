using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.IO;
using System.Xml.Linq;

namespace MetraTech.ExpressionEngine
{
    public static class IOHelpers
    {
        public static T CreateFromFile<T>(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString<T>(xmlContent);
        }

        public static T CreateFromString<T>(string xmlContent)
        {
            var xElement = XElement.Parse(xmlContent);
            var xmlReader = xElement.CreateReader();
            var ser = new DataContractSerializer(typeof(T));
            var function = (T)ser.ReadObject(xmlReader);
            xmlReader.Close();
            return function;
        }

        //public static void Save(string file, object theObject)
        //{
        //    var dirPath = Path.GetDirectoryName(file);
        //    if (string.IsNullOrEmpty(dirPath))
        //        throw new Exception("Unable to determine directory path from file: " + file);
           
        //    Helper.EnsureDirectoryExits(dirPath);

        //    using (var writer = new FileStream(file, FileMode.Create))
        //    {
        //        var ser = new DataContractSerializer(typeof(theObject));
        //        ser.WriteObject(writer, theObject);
        //    }
        //}
    }
}
