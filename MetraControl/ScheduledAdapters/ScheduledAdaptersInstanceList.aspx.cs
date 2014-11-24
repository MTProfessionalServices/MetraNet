using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.Enums;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums.Core.Metratech_com_Events;
using System.Text;

public partial class MetraControl_ScheduledAdapters_ScheduledAdaptersInstanceList : MTPage
{
  private const string QueryName = "__GET_ADAPTER_INSTANCE_LIST_FOR_EVENT__";

  public string IdAdapter
  {
    get; private set;
  }

  public string AdapterName
  {
    get; private set;
  }

  public string AdapterNameBase64
  {
    get; private set;
  }

  protected override void OnLoad(EventArgs e)
  {
    IdAdapter = Request["ID"] ?? String.Empty;

    AdapterNameBase64 = Request["AdapterName"];

    if (AdapterNameBase64 != null)
    {
      AdapterName = Encoding.UTF8.GetString(Convert.FromBase64String(AdapterNameBase64));
    }
    else
    {
      AdapterNameBase64
        = AdapterName
          = String.Empty;
    }

    lblTitle.Text = String.Format("{0} <a href=\"ScheduledAdaptersList.aspx\" title=\"Return To Adapter List\">{1}</a>"
      , GetLocalResourceObject("PageTitle"), AdapterName);

    base.OnLoad(e);
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    SQLQueryInfo sqi = new SQLQueryInfo();
    sqi.QueryName = QueryName;
    sqi.QueryDir = "dummy"; // No longer required by Query Manager

    if (!string.IsNullOrEmpty(IdAdapter))
    {
      int idAdapter = int.Parse(IdAdapter);
      SQLQueryParam param = new SQLQueryParam();
      param.FieldName = "%%ID_EVENT%%";
      param.FieldValue = idAdapter;
      sqi.Params.Add(param);

      param = new SQLQueryParam();
      param.FieldName = "%%ID_LANGUAGE%%";
      param.FieldValue = UI.SessionContext.LanguageID;
      sqi.Params.Add(param);
      
    }

    

    string qsParam = SQLQueryInfo.Compact(sqi);
    ScheduledAdaptertGrid.DataSourceURLParams.Clear();
    ScheduledAdaptertGrid.DataSourceURLParams.Add("q", qsParam);

    base.OnLoadComplete(e);
  }
}