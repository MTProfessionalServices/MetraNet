using System;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using System.Collections.Generic;
using System.Configuration;
using MetraTech.Pipeline;

public partial class FailedTransactionViewFromBatch : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    //Extra check that user has permission to work with failed transactions
    //Eventually would be good to move this to configuration
    if (!UI.CoarseCheckCapability("Update Failed Transactions"))
      Response.End();
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    //CORE-3678: Add dropdowns to stage and servicename
    //Dictionary<string,string> serviceList = new Dictionary<string, string>();
    //ServiceDefinitionCollection serviceDefinitionCollection = new ServiceDefinitionCollection();
    //foreach (string name in serviceDefinitionCollection.SortedNames)
    //  serviceList.Add(name, name);

    //GridRenderer.AddFilterListToElement(FailedTransactionList, "failureservicename", serviceList);
    //Backing out the above change; at this point using wildcards with service name is more useful than having to pick only from the list.
    //In the future, it would be nice if the fitler dropdown 1) Matched on partial names anywhere in the drop down string 2) allowed values not in the list (i.e. if the user typed it, use if) as an option so that wildcards can be used

    SetPageTitleFromQueryString();
    SetDefaultFilterFromQueryString(FailedTransactionList);

    base.OnLoadComplete(e);
  }

  protected void SetPageTitleFromQueryString()
  {
    string sTitle = Request["PageTitle"];
    if (!string.IsNullOrEmpty(sTitle))
      try
      {
        Page.Header.Title = Server.HtmlEncode(sTitle);
      }
      catch (Exception)
      {
        // continue rendering the grid anyway
      }
  }

  protected void SetDefaultFilterFromQueryString(MTFilterGrid grid)
  {
    if (grid == null)
      return;

    string sFilterSerialized = Request["Filter_" + grid.ID];
    if (!string.IsNullOrEmpty(sFilterSerialized))
      try
      {
        MTGridDataElement el = grid.FindElementByID("status");
        if (el != null)
        {
          el.ElementValue = sFilterSerialized;
        }
      }
      catch (Exception)
      {
        // continue rendering the grid anyway
      }

    sFilterSerialized = Request["Filter_" + grid.ID + "_BatchId"];
    if (!string.IsNullOrEmpty(sFilterSerialized))
      try
      {
        MTGridDataElement el = grid.FindElementByID("batchid");
        if (el != null)
        {
          el.ElementValue = sFilterSerialized;
        }
      }
      catch (Exception)
      {
        // continue rendering the grid anyway
      }
  }
}