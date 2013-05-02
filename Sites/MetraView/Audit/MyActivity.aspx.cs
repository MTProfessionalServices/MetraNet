using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class Audit_MyActivity : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    Session[SiteConstants.ActiveMenu] = "MyActivity";
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    ConfigureAuditLogForUser();
    base.OnLoadComplete(e);
  }

  protected void ConfigureAuditLogForUser()
  {
    SQLQueryInfo sqi = new SQLQueryInfo();
    sqi.QueryName = "__SELECT_AUDIT_LOG_FOR_ENTITY__";
    sqi.QueryDir = "Queries\\Audit";

    var param = new SQLQueryParam { FieldName = "%%ENTITY_ID%%" };
    if ((UI.Subscriber != null) && (UI.Subscriber.SelectedAccount != null) && (UI.Subscriber.SelectedAccount.PayerID != null))
    {
      param.FieldValue = UI.Subscriber.SelectedAccount._AccountID;
    }
    else
    {
      SetError(Resources.ErrorMessages.ERROR_SUBSCRIBER_NULL);
      return;
    }
    sqi.Params.Add(param);

    string qsParam = SQLQueryInfo.Compact(sqi);
    MyGrid1.DataSourceURLParams.Add("q", qsParam);
  }
}