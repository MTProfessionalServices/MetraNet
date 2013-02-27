using System;
using System.Runtime.Serialization;
using System.IO;
using System.Xml;
using System.Xml.Linq;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    public static class IOHelper
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
            var newObject = (T)ser.ReadObject(xmlReader);
            xmlReader.Close();
            return newObject;
        }

        public static void Save<T>(string file, T theObject)
        {
          var dirPath = Path.GetDirectoryName(file);
          if (string.IsNullOrEmpty(dirPath))
            throw new ArgumentException("Unable to determine directory path from file: " + file);

          dirPath.EnsureDirectoryExits();

          var writerSettings = new XmlWriterSettings {Indent = true};
          using (var writer = XmlWriter.Create(file, writerSettings))
          {
            var ser = new DataContractSerializer(typeof(T));
            ser.WriteObject(writer, theObject);
          }
        }

        public static string GetMetraNetConfigPath(string extensionsDir, string extension, string elementDirName)
        {
            return string.Format(CultureInfo.InvariantCulture, @"{0}\{1}\Config\{2}", extensionsDir, extension, elementDirName);
        }
        public static DirectoryInfo GetMetraNetConfigPathAndEnsureExists(string extensionsDir, string extension, string elementDirName)
        {
            var dirPath = GetMetraNetConfigPath(extensionsDir, extension, elementDirName);
            return EnsureDirectoryExits(dirPath);
        }

        public static DirectoryInfo EnsureDirectoryExits(this string dirPath)
        {
            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                dirInfo.Create();
            return dirInfo;
        }
    }
}
