using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech;
using MetraTech.Accounts.Ownership;
using MetraTech.DomainModel.Billing;
using MetraTech.Interop.MTAuth;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.UI.Common;

public partial class Usage : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    Session[SiteConstants.ActiveMenu] = "Reports";

    var billManager = new BillManager(UI);
    billManager.SetChargeViewType(PanelCurrentCharges, PanelCurrentChargesByFolder);

    if ((string)Session[SiteConstants.View] == "details")
    {
      ListItem listItem = new ListItem(UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount._AccountID.ToString());
      ddOwnedAccounts.Items.Add(listItem);
      OwnershipMgr manager = new OwnershipMgr();

      YAAC.IMTYAAC yaac = new YAAC.MTYAAC();
      yaac.InitAsSecuredResource((int)UI.Subscriber.SelectedAccount._AccountID, (YAAC.IMTSessionContext)UI.SessionContext, MetraTime.Now);

      IMTSQLRowset rowset = (MetraTech.Interop.MTAuth.IMTSQLRowset)yaac.GetOwnedFolderList();
      if (rowset != null)
      {
        PanelOwnedAccounts.Visible = rowset.Count > 1;

        while (!Convert.ToBoolean(rowset.EOF))
        {
          string username = rowset.get_Value("displayname").ToString();
          string id = rowset.get_Value("id_acc").ToString();
          ListItem itm = new ListItem(username, id);
          if (Session[SiteConstants.OwnedAccount] != null)
          {
            if (Session[SiteConstants.OwnedAccount].ToString() == id)
            {
              itm.Selected = true;
            }
          }
          ddOwnedAccounts.Items.Add(itm);
          rowset.MoveNext();
        }
      }
    }

    if (!IsPostBack)
    {
      if (Request.QueryString[SiteConstants.StartDate] != null)
      {
        DateTime d;
        if (!DateTime.TryParse(Request.QueryString[SiteConstants.StartDate], out d))
        {
          Response.Redirect(SiteConfig.Settings.RootUrl + "/Logout.aspx"); // give us bad data an we log you out
        }
      }
      if (Request.QueryString[SiteConstants.EndDate] != null)
      {
        DateTime d;
        if (!DateTime.TryParse(Request.QueryString[SiteConstants.EndDate], out d))
        {
          Response.Redirect(SiteConfig.Settings.RootUrl + "/Logout.aspx"); // give us bad data an we log you out
        }
      }

      var interval = billManager.GetOpenIntervalWithoutSettingItAsCurrentOnTheUI();

      // SECENG: added check for NULLs
      //if (Request.QueryString["view"] == null)
      if (Request.QueryString["view"] == null && interval != null)
      {
        startDate.Text = Request.QueryString[SiteConstants.StartDate] ?? interval.StartDate.ToShortDateString();
        endDate.Text = Request.QueryString[SiteConstants.EndDate] ?? interval.EndDate.ToShortDateString();

        billManager.ReportParams.DateRange = GetDateRange();
        billManager.ReportParamsLocalized.DateRange = GetDateRange();
      }
      else
      {
        SetDataRangeDates(billManager.ReportParams.DateRange, billManager);
        SetDataRangeDates(billManager.ReportParamsLocalized.DateRange, billManager);
      }

      billManager.ReportParams.ReportView = ReportViewType.Interactive;
      billManager.ReportParams.UseSecondPassData = false;  // show first pass data on usage page

      billManager.ReportParamsLocalized.ReportView = ReportViewType.Interactive;
      billManager.ReportParamsLocalized.UseSecondPassData = false;  // show first pass data on usage page

      billManager.GetInvoiceReport(true);
    }
  }

  private void SetDataRangeDates(TimeSlice dateRange, BillManager billManager)
  {
    if (dateRange == null) return;

    if (dateRange is DateRangeSlice)
    {
      startDate.Text = ((DateRangeSlice)dateRange).Begin.ToShortDateString();
      endDate.Text = ((DateRangeSlice)dateRange).End.ToShortDateString();
    }
    else
    {
      Interval curInterval = billManager.GetCurrentInterval() ??
                             billManager.GetOpenIntervalWithoutSettingItAsCurrentOnTheUI();

      startDate.Text = curInterval.StartDate.ToShortDateString();
      endDate.Text = curInterval.EndDate.ToShortDateString();
    }
  }

  private DateRangeSlice GetDateRange()
  {
    return new DateRangeSlice
      {
        Begin = DateTime.Parse(startDate.Text),
        End = DateTime.Parse(endDate.Text).AddDays(1).AddMilliseconds(-1)
      };
  }

  protected void BtnLoadUsageClick(object sender, EventArgs e)
  {
    var billManager = new BillManager(UI);
    billManager.ReportParams.DateRange = new DateRangeSlice
                                           {
                                             Begin = DateTime.Parse(startDate.Text),
                                             End = DateTime.Parse(endDate.Text).AddDays(1).AddMilliseconds(-1)
                                           };
    Response.Redirect(UI.DictionaryManager["UsagePage"] + "?StartDate=" + Server.UrlEncode(startDate.Text) + "&EndDate=" +
                      Server.UrlEncode(endDate.Text));
  }

  protected void ddOwnedAccounts_SelectedIndexChanged(object sender, EventArgs e)
  {
    Session[SiteConstants.OwnedAccount] = ddOwnedAccounts.SelectedValue;
    Response.Redirect(UI.DictionaryManager["UsagePage"] + "?StartDate=" + Server.UrlEncode(startDate.Text) + "&EndDate=" +
                      Server.UrlEncode(endDate.Text));
  }
}
