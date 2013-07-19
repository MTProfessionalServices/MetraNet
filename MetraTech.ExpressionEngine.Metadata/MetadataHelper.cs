using MetraTech.Basic;
using MetraTech.DataAccess;
using MetraTech.Interop.QueryAdapter;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace MetraTech.ExpressionEngine.Metadata
{
  public static class MetadataHelper
  {
    private static string _jsonMetadata = string.Empty;

    public static string RetrieveJsonMetadata()
    {
      if (!string.IsNullOrEmpty(_jsonMetadata))
        return _jsonMetadata;

      var metadataSerialized = string.Empty;

      var queryAdapter = new MTQueryAdapter();
      queryAdapter.Init("Queries\\ExpressionEngine");
      queryAdapter.SetQueryTag("__GET_METADATA_LATEST__");
      var txInfo = queryAdapter.GetQuery();
      using (var conn = ConnectionManager.CreateConnection())
        using (var stmt = conn.CreatePreparedStatement(txInfo))
          using (var dataReader = stmt.ExecuteReader())
            if (dataReader.Read())
              metadataSerialized = dataReader.GetString("content");

      if (string.IsNullOrEmpty(metadataSerialized))
        return string.Empty;

      var metadata = SerializationHelper.DeserializeDataContractXml<ContextMetadata>(metadataSerialized);

      var jsonSerializerSettings = new JsonSerializerSettings();
      jsonSerializerSettings.ReferenceLoopHandling = ReferenceLoopHandling.Ignore;
      jsonSerializerSettings.Converters.Add(new IsoDateTimeConverter());
      jsonSerializerSettings.Converters.Add(new StringEnumConverter());

      _jsonMetadata = JsonConvert.SerializeObject(metadata, jsonSerializerSettings);

      return _jsonMetadata;
    }
  }
}
