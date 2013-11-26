using System;
using System.IO;
using System.Runtime.Serialization;
using System.Text;
using System.Xml.Linq;

namespace MetraTech.Basic
{

  /// <summary>
  /// Serialization helper methods
  /// </summary>
  public static class SerializationHelper
  {
    /// <summary>
    /// Serialize object to XML using DataContractSerializer
    /// </summary>
    /// <returns>xml with serialized entity</returns>
    public static XElement SerializeDataContractXml<T>(object sourceObject)
    {
      if (sourceObject == null)
        throw new ArgumentNullException("sourceObject");

      var serializer = new DataContractSerializer(typeof(T));
      using (var stream = new MemoryStream())
      {
        serializer.WriteObject(stream, sourceObject);
        stream.Position = 0;
        return XElement.Load(stream);
      }
    }

    /// <summary>
    /// Deserialization object from string as XML using DataContractSerializer
    /// </summary>
    /// <typeparam name="T">type of object</typeparam>
    /// <param name="xml">string as XML with serialized object</param>
    /// <returns></returns>
    public static T DeserializeDataContractXml<T>(string xml)
    {
      if (string.IsNullOrEmpty(xml))
        throw new ArgumentNullException("xml");

      var serializer = new DataContractSerializer(typeof(T));
      using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(xml)))
        return (T)serializer.ReadObject(stream);
    }
  }
}
