using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Schema;
using System.Xml.Serialization;
using System.Xml.XPath;
using MetraTech.SecurityFramework.Core.Detector.Engine;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.SecurityFrameworkUnitTests
{
    /// <summary>
    /// Used as configuration loder for testing some configurations elements
    /// </summary>
    public class ConfigurationLoaderForTesting
    {
        /// <summary>
        /// Try to deserialize data from XML file.
        /// </summary>
        /// <typeparam name="T">type of deserialize</typeparam>
        /// <param name="fullPathToConfiguration">full path to xml file</param>
        /// <param name="xPath">XPath for XML document</param>
        /// <returns></returns>
        public T GetDataFromXml<T>(string fullPathToConfiguration, string xPath)
        {
            T result;
            XDocument xmlDoc = null;
            using (Stream baseStream = File.Open(fullPathToConfiguration, FileMode.Open, FileAccess.Read, FileShare.Read))
            {
                xmlDoc = XDocument.Load(baseStream);
            } 

            IEnumerable<object> att = (IEnumerable<object>)xmlDoc.XPathEvaluate(xPath);
            XElement parentElement = (XElement)att.First();

            XmlSerializer xmlSerializer = new XmlSerializer(typeof(T));
            
            using (StringReader strReader = new StringReader(parentElement.ToString()))
            {
                using (XmlReader xmlReader = XmlReader.Create(strReader))
                    result = (T)xmlSerializer.Deserialize(xmlReader);
            }
            
            return result;
        }

        /// <summary>
        /// Try to serialize data to XML file.
        /// </summary>
        /// <typeparam name="T">type of serialize</typeparam>
        /// <param name="data">object to serialize</param>
        /// <param name="fullFilePath">full path to new xml file</param>
        public void WriteDataToXml<T>(T data, string fullFilePath)
        {
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(T));

            using (Stream baseStream = File.Open(fullFilePath, FileMode.Create, FileAccess.Write))
            {
                xmlSerializer.Serialize(baseStream, data);
            } 
        }
    }
}
