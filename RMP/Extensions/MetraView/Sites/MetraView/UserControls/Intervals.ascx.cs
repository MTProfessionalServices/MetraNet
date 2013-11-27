using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class UserControls_Intervals : System.Web.UI.UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  public string RedirectURL { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      var billManager = new BillManager(UI);
      var intervals = billManager.GetIntervals();

      ddIntervals.Items.Clear();
      foreach (var interval in intervals)
      {
        if(SiteConfig.Settings.BillSetting.ShowOnlyHardClosedIntervals.GetValueOrDefault(false))
        {
          if (interval.Status != IntervalStatusCode.HardClosed)
            continue;
        }

        var listItem = new ListItem();
        listItem.Text = String.Format("{0} - {1} {2}", interval.StartDate.ToShortDateString(),
                                      interval.EndDate.ToShortDateString(),
                                      String.IsNullOrEmpty(interval.InvoiceNumber)
                                        ? ""
                                        : GetLocalResourceObject(("Invoice.Text")) + interval.InvoiceNumber);
        //if (Session[SiteConstants.SelectedIntervalId].ToString() == interval.ID.ToString())
        //{
        //  listItem.Selected = true;
        //}
        listItem.Value = String.Format("{0}{1}", interval.ID.ToString(),
                                      String.IsNullOrEmpty(interval.InvoiceNumber)
                                        ? ""
                                        : "-" + interval.InvoiceNumber);
        ddIntervals.Items.Add(listItem);

       // string ddintervalitemvalue = string.IsNullOrEmpty(Session[SiteConstants.SelectedIntervalinvoice].ToString())
       //                                ? Session[SiteConstants.SelectedIntervalId].ToString()
       //                                : Session[SiteConstants.SelectedIntervalId].ToString() + "-" +
       //                                  Session[SiteConstants.SelectedIntervalinvoice].ToString();
       // ESR-5592 fix
        object SelectedIntervalinvoiceValue = Session[SiteConstants.SelectedIntervalinvoice];
        // object SelectedIntervalIdValue = Session[SiteConstants.SelectedIntervalId];        
		
		string ddintervalitemvalue = "";

        if (SelectedIntervalinvoiceValue.Equals(String.Empty))
        {
          ddintervalitemvalue = Session[SiteConstants.SelectedIntervalId].ToString();
        }
        else
        {
          ddintervalitemvalue = Session[SiteConstants.SelectedIntervalId].ToString() + "-" +
                                       Session[SiteConstants.SelectedIntervalinvoice].ToString();  
        }       

        if (ddintervalitemvalue == listItem.Value)
        {
          ddIntervals.SelectedIndex = ddIntervals.Items.IndexOf(ddIntervals.Items.FindByText(listItem.Text));
        
        }        
      }
    }
  }

  protected void OnIntervalChange(object sender, EventArgs e)
  {
    
    string intervalvalue="";
    string invoicenumber="";

    string url = RedirectURL;
    if (!string.IsNullOrEmpty(url))
    {
      if (url.Contains("?"))
      {
        url += "&";
      }
      else
      {
        url += "?";
      }

      if (ddIntervals.SelectedValue.ToString().Contains("-"))
      {
        //intervalvalue = ddIntervals.SelectedValue.Split('-')[0];
        //invoicenumber = ddIntervals.SelectedValue.Split('-')[1];
        string[] arrintervalinvoicesplit = ddIntervals.SelectedValue.Split('-');
        if (arrintervalinvoicesplit.Length > 1)
        {
          intervalvalue = arrintervalinvoicesplit[0];
          invoicenumber = arrintervalinvoicesplit[1];
        }
        else
        {
          intervalvalue = arrintervalinvoicesplit[0];

          invoicenumber = "";
        }
        Session[SiteConstants.SelectedIntervalId] = intervalvalue;
        Session[SiteConstants.SelectedIntervalinvoice] = invoicenumber;
      }
      else
      {
        intervalvalue = ddIntervals.SelectedValue;
        Session[SiteConstants.SelectedIntervalId] = intervalvalue;
        Session[SiteConstants.SelectedIntervalinvoice] = invoicenumber;
      }

      url += "interval=" + intervalvalue + "&invoiceno=" + invoicenumber;
    
      Response.Redirect(url);
    }
  }
}
