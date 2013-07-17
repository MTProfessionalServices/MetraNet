using System.IO;
using System.Runtime.Serialization;
using System.Text;
using System.Xml.Linq;

namespace MetraTech.Domain.DataAccess
{
  public static class SerializationHelper
  {
    /// <summary>
    /// Object deserialization
    /// </summary>
    public static T Deserialize<T>(string xml)
    {
      var dcs = new DataContractSerializer(typeof(T));
      using (var stream = new MemoryStream(Encoding.UTF8.GetBytes(xml)))
        return (T)dcs.ReadObject(stream);
    }

    /// <summary>
    /// Object serialization
    /// </summary>
    public static string Serialize<T>(this T objectToSerialize)
    {
      var xs = new DataContractSerializer(typeof(T));
      using (var ms = new MemoryStream())
      {
        xs.WriteObject(ms, objectToSerialize);
        ms.Position = 0;
        return XElement.Load(ms).ToString();
      }
    }
  }
}
