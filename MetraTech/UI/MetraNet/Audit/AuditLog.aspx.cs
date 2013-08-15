using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.UI.Common;

public partial class Audit_AuditLog : MTPage
{
  protected override void OnLoadComplete(EventArgs e)
  {
    string userMode = Request["SubscriberMode"]; // SubscriberMode=TRUE means show only for managed user, otherwise show all

    if ((!String.IsNullOrEmpty(userMode)) && (userMode.ToLower() == "true"))
    {
      ConfigureAuditLogForUser();
    }
    else
    {
        if (!UI.CoarseCheckCapability("Manage System Wide Authorization Policies"))
        {
            Response.End();
            return;
        }
      ConfigureAuditLogForEntityType();
    }

    base.OnLoadComplete(e);
  }
  

  protected void ConfigureAuditLogForEntityType()
  {
    SQLQueryInfo sqi = new SQLQueryInfo();
    sqi.QueryName = "__SELECT_AUDIT_LOG_BY_ENTITY_TYPE__";
    sqi.QueryDir = "Queries\\Audit";

    //SQLQueryParam param = new SQLQueryParam();
   // param.FieldName = "%%ENTITY_TYPE%%";
    //param.FieldValue = "1";

    //sqi.Params.Add(param);

    string qsParam = SQLQueryInfo.Compact(sqi);
    MyGrid1.DataSourceURLParams.Add("q", qsParam);
  }
  protected void ConfigureAuditLogForUser()
  {
    SQLQueryInfo sqi = new SQLQueryInfo();
    sqi.QueryName = "__SELECT_AUDIT_LOG_FOR_ENTITY__";
    sqi.QueryDir = "Queries\\Audit";

    SQLQueryParam param = new SQLQueryParam();
    //param.FieldName = "%%ENTITY_TYPE%%";
   // param.FieldValue = "1";

   // sqi.Params.Add(param);

    param = new SQLQueryParam();
    param.FieldName = "%%ENTITY_ID%%";
    if ((UI.Subscriber != null) && (UI.Subscriber.SelectedAccount != null) && (UI.Subscriber.SelectedAccount._AccountID.HasValue))
    {
      param.FieldValue = UI.Subscriber.SelectedAccount._AccountID.Value;
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
