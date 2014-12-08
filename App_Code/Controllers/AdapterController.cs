using System;
using System.Web.Mvc;
using MetraTech.DataAccess;
using MetraTech.UI.Common;
using Newtonsoft.Json;

namespace ASP.Controllers
{
  public class AdapterController : Controller
  {
    [Authorize]
    [HttpPost]
    public string GetRunDetails(string runId)
    {
      int paramValue;
      Int32.TryParse(runId, out paramValue);
      var sqi = new SQLQueryInfo { QueryName = "__GET_ADAPTER_INSTANCE_RUN_DETAILS__" };
      var param = new SQLQueryParam { FieldName = "%%ID_RUN%%", FieldValue = paramValue };
      sqi.Params.Add(param);
      var qsParam = SQLQueryInfo.Compact(sqi);
      var batchCount = GetBatchCount(paramValue);
      return JsonConvert.SerializeObject(new { Urlparam_q = qsParam, BatchCount = batchCount});
    }

    private static int GetBatchCount(int paramValue)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (var stmt = conn.CreateAdapterStatement(@"..\config\SqlCore\Queries\mom", "__GET_ADAPTER_RUN_INFORMATION__"))
        {
          stmt.AddParam("%%ID_RUN%%", paramValue);
          var batchCount = 0;
          using (var reader = stmt.ExecuteReader())
          {
            while (reader.Read())
            {
              batchCount = reader.IsDBNull("BatchCount") ? 0 : reader.GetInt32("BatchCount");
            }
          }
          return batchCount;
        }
      }
    }
  }
}
