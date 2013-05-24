using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Web.Script.Serialization;
using System.Runtime.Serialization;
using MetraTech.ActivityServices.Common;

namespace MetraTech.Approvals
{
    /// <summary>
  /// The main interface to the approvals client
  /// </summary>
  [Guid("E14EF56A-B280-4C8D-84BA-B1FFE66F9BA3")]
  [ComVisible(true)]
  public interface IChangeDetailsHelper
  {
    [DispId(0)]
    object this[string name] { get; set;}

  }


  [ClassInterface(ClassInterfaceType.None)]
  [Guid("34D9EACD-328D-4323-B726-FC236B89491F")]
  [ComVisible(true)]
  public class ChangeDetailsHelper /*: Dictionary<string, object>, IChangeDetailsHelper */
  {
    protected Dictionary<string, object> details = new Dictionary<string, object>();
    //protected Dictionary<string, string> detailsSerialized = new Dictionary<string, string>();

    protected List<Type> knownTypes = new List<Type>();

    protected virtual void InitializeKnownTypes()
    {
    }

    [ComVisible(false)]
    public List<Type> KnownTypes
    {
      //May eventually lock this down: return a copy and require call to special Add method
      get { return knownTypes; }
      set { knownTypes = value; }
    } 

    public enum SerializationType
    {
      Xml,
      Json
    };

    public SerializationType SerializeTo { get; set; }

    public ChangeDetailsHelper()
    {
      BaseInit();
    }

    public ChangeDetailsHelper(string buffer)
    {
      BaseInit();
      FromBuffer(buffer);
    }

    protected void BaseInit()
    {
      SerializeTo = SerializationType.Xml;
      InitializeKnownTypes();
    }

    [DispId(0)]
    public object this[string name]
    {
      [DispId(0)]
      get { return details[name]; }
      [DispId(0)]
        set { details[name] = value; if (value != null && !knownTypes.Contains(value.GetType())) knownTypes.Add(value.GetType()); }
    }

    public bool ContainsKey(string name)
    {
      return details.ContainsKey(name);
    }

    public Dictionary<string, object> ToDictionary()
    {
      //Create a shallow copy; dictionary is copied but values are not cloned
      return new Dictionary<string, object>(details);
    }

    public string ToBuffer()
    {
      switch (SerializeTo)
      {
        case SerializationType.Xml:
          return ToXml();
 
        case SerializationType.Json:
          return ToJson();

        default:
          throw new Exception("Unknown Serialization method for SerializeTo");
      }
      
    }

    public void FromBuffer(string buffer)
    {
      switch (SerializeTo)
      {
        case SerializationType.Xml:
          FromXml(buffer);
          break;

        case SerializationType.Json:
          FromJson(buffer);
          break;

        default:
          throw new Exception("Unknown Serialization method for SerializeTo");
      }
    }

    public string ToJson()
    {
      JavaScriptSerializer serializer = new JavaScriptSerializer(); //creating serializer instance of JavaScriptSerializer class
      string json = serializer.Serialize((object)details);
      return json;
    }

    public void FromJson(string json)
    {
      JavaScriptSerializer deserializer = new JavaScriptSerializer();

      //Dictionary<string,object> deserializedDictionary1 = (Dictionary<string,object>)deserializer.Deserialize(json, typeof(object));
      Dictionary<string, object> deserializedDictionary = deserializer.Deserialize<Dictionary<string, object>>(json);
      //object objDeserialized = deserializer.DeserializeObject(json);
      
      details = deserializedDictionary;
    }

    public string ToXml()
    {
      var serializer = new DataContractSerializer(details.GetType(), knownTypes);
      using (var backing = new System.IO.StringWriter())
      {
        using (var writer = new System.Xml.XmlTextWriter(backing))
        {
          serializer.WriteObject(writer, details);
          return backing.ToString();
        }
      }
    }

    //protected string SerializeObjectToXml(object o)
    //{
    //  var serializer = new DataContractSerializer(o.GetType());
    //  using (var backing = new System.IO.StringWriter())
    //  {
    //    using (var writer = new System.Xml.XmlTextWriter(backing))
    //    {
    //      serializer.WriteObject(writer, details);
    //      return backing.ToString();
    //    }
    //  }
    //}

    //protected object DeserializeObjectFromXml(string s)
    //{
    //  var serializer = new DataContractSerializer(typeof(object));
    //  using (var backing = new System.IO.StringWriter())
    //  {
    //    using (var writer = new System.Xml.XmlTextWriter(backing))
    //    {
    //      serializer.WriteObject(writer, details);
    //      return backing.ToString();
    //    }
    //  }
    //}

    public void FromXml(string xml)
    {
      //Attempt #1: Default
      var serializer = new DataContractSerializer(details.GetType(), knownTypes);
      using (var backing = new System.IO.StringReader(xml))
      {
        using (var reader = new System.Xml.XmlTextReader(backing))
        {
          details = serializer.ReadObject(reader) as Dictionary<string, object>;
        }
      }

      ////Attempt #2: Set Known Types Array
      //List<Type> knownTypes = new List<Type> { typeof(List<string>) };
      //DataContractSerializer serializer = new DataContractSerializer(typeof(Dictionary<string, object>), knownTypes);

      //var serializer = new DataContractSerializer(details.GetType());
      //using (var backing = new System.IO.StringReader(xml))
      //{
      //  using (var reader = new System.Xml.XmlTextReader(backing))
      //  {
      //    details = serializer.ReadObject(reader) as Dictionary<string, object>;
      //  }
      //}
    }
  }
}
