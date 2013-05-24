using System;
using System.Reflection;
using System.Text;
using System.Web.Script.Serialization;

namespace MetraTech.Events
{
  /// <summary>
  /// Types of Event objects that can be sent.
  /// </summary>
  public enum EventType
  { 
    EventMessageBase, 
    InfoMessage,
    TimeMessage
  }

  /// <summary>
  /// Extension method to allow JavaScriptSerializer to work with the known object type.
  /// </summary>
  public static class JavaScriptSerializerExtensions
  {
    public static object Deserialize(this JavaScriptSerializer serializer, Type type, string data)
    {
      Type serializerType = typeof(JavaScriptSerializer);
      object[] args = new object[] { serializer, data, type, serializer.RecursionLimit, };
      return serializerType.InvokeMember("Deserialize", BindingFlags.Static | BindingFlags.NonPublic |
                                                        BindingFlags.InvokeMethod, Type.DefaultBinder, null, args);
    }
  }


  /// <summary>
  /// Base class for event messages, it implements the ToJson and FromJson methods.
  /// </summary>
  [Serializable]
  public class EventMessageBase
  {
    public string MessageId { get; set; }
    public string EventTime { get; set; }

    public string ToJson()
    {
      JavaScriptSerializer jss = new JavaScriptSerializer();
      StringBuilder sbJson = new StringBuilder();
      jss.Serialize(this, sbJson);
      return sbJson.ToString();
    }

    static public EventMessageBase FromJson(string json)
    {
      JavaScriptSerializer js = new JavaScriptSerializer(new SimpleTypeResolver());
      EventMessageBase emb = new EventMessageBase();
      emb = (EventMessageBase)js.Deserialize(emb.GetType(), json); 
      return emb;
    }
  }

  /// <summary>
  /// Event message used to send text information.
  /// </summary>
  [Serializable]
  public class InfoMessage : EventMessageBase
  {
    public InfoMessage(string label, string info)
    {
      MessageId = "INFO_MESSAGE";
      Label = label;
      Info = info;
    }

    public string Info { get; set;}
    public string Label { get; set;}
  }

  /// <summary>
  /// Event message to carry current time for testing...
  /// </summary>
  [Serializable]
  public class TimeMessage : EventMessageBase
  {
    public TimeMessage()
    {
      MessageId = "TIME_MESSAGE";
      CurrentTime = MetraTime.Now.ToLongTimeString();
    }

    public string CurrentTime { get; set;}
  }

}