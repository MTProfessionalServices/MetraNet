using System;
using System.ServiceModel;
using System.Web;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using System.Web.UI.WebControls;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class IntervalStatisticsParameters : MTPage
{
    #region Properties

    public string RefererUrl
    {
        get { return ViewState["RefererURL"] as string; }
        set { ViewState["RefererURL"] = value; }
    }

    public string ReturnUrl
    {
        get { return ViewState["ReturnURL"] as string; }
        set { ViewState["ReturnURL"] = value; }
    }

    #endregion

    #region Variables
    private string internalId = "";
    private string reportName = "";
    private string queryName = "";
    private string extension = "";
    private string gridLayoutName = "";
    #endregion

    protected override void OnLoad(EventArgs e)
    {
        internalId = Request["InternalId"];
        reportName = Request["Name"];
        queryName = Request["QueryName"];
        extension = Request["Extension"];
        gridLayoutName = Request["GridLayoutName"];

        //MTPanel1.Text = string.Format("{0} - {1}", MTPanel1.Text, reportName);
        MTPanel1.Text = reportName;

        base.OnLoad(e);
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        // Obtain Billing Cycles and populate dropdown
        ListItem defaultLi = new ListItem("", "");
        defaultLi.Selected = true;
        ddBillingCycle.Items.Add(defaultLi);

        System.Collections.Generic.List<MetraTech.DomainModel.BaseTypes.EnumData> enumDataList = null;
        try
        {
            enumDataList = MetraTech.DomainModel.BaseTypes.BaseObject.GetEnumData(typeof(MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle.UsageCycleType));
            foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enumDataList)
            {
                string name = enumData.DisplayName;

                object curValue = MetraTech.DomainModel.Enums.EnumHelper.GetValueByEnum(enumData.EnumInstance);
                string value = curValue.ToString();
                ListItem li = new ListItem(name, value);
                ddBillingCycle.Items.Add(li);
            }

            ddIntervalId.Items.Add(new ListItem("", ""));
            ddBillGroupId.Items.Add(new ListItem("", ""));
        }
        catch (Exception ex)
        {
            SetError(ex.Message);
        }

        base.OnLoadComplete(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            RefererUrl = Encrypt(Request.Url.ToString());
            ResolveReturnURL();
        }
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
        //string intervalId = ddIntervalId.SelectedValue;
        //string billGroupId = ddBillGroupId.SelectedValue;
        string intervalId = txtIntervalId.Value;
        string billGroupId = txtBillGroupId.Value;
        string url = null;

        try
        {
            url = string.Format("ShowConfiguredReport.aspx?InternalId={0}&Name={1}&Extension={2}&QueryName={3}&GridLayoutName={4}&IntervalId={5}&BillGroupId={6}", 
                internalId, reportName, extension, queryName, gridLayoutName,
                intervalId, billGroupId);
        }
        catch (Exception exp)
        {
            Session[MetraTech.UI.Common.Constants.ERROR] = exp.Message;
        }

        if (!String.IsNullOrEmpty(url))
        {
            Response.Redirect(url);  // we redirect outside of exception
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect(ReturnUrl);
    }

    private void ResolveReturnURL()
    {
        if (String.IsNullOrEmpty(Request["ReturnURL"]))
        {
            if (Request.UrlReferrer != null)
            {
                if (Request.UrlReferrer.ToString().ToLower().Contains("login.aspx") ||
                    Request.UrlReferrer.ToString().ToLower().Contains("default.aspx"))
                {
                    ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
                }
                else
                {
                    ReturnUrl = Request.UrlReferrer.ToString();
                }
            }
            else
            {
                ReturnUrl = UI.DictionaryManager["DashboardPage"].ToString();
            }
        }
        else
        {
            ReturnUrl = Request["ReturnURL"].Replace("'", "").Replace("|", "?").Replace("**", "&");
        }
    }
}
