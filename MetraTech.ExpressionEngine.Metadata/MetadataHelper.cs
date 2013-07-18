using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace MetraTech.ExpressionEngine.Metadata
{
  public static class MetadataHelper
  {
    public static string RetrieveJsonMetadata()
    {
      var metadata = 5;

      var jsonSerializerSettings = new JsonSerializerSettings();
      jsonSerializerSettings.ReferenceLoopHandling = ReferenceLoopHandling.Ignore;
      jsonSerializerSettings.Converters.Add(new IsoDateTimeConverter());
      jsonSerializerSettings.Converters.Add(new StringEnumConverter());

      return JsonConvert.SerializeObject(metadata, jsonSerializerSettings);      
    }
  }
}
