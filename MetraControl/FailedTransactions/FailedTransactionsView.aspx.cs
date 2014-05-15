using System;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class FailedTransactionsView : MTPage
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
	  SetDefaultFilters();

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
  
  private void SetDefaultFilters()
  {
    string statusFilterValue = Request["Filter_" + FailedTransactionList.ID];
    if (!String.IsNullOrEmpty(statusFilterValue))
    {
      SetGridFilterByColumnValue(FailedTransactionList, "status", statusFilterValue);
    }

    string possiblePayerFilterValue = Request["Filter_" + FailedTransactionList.ID + "_PossiblePayer"];
    if (!String.IsNullOrEmpty(possiblePayerFilterValue))
    {
      SetGridFilterByColumnValue(FailedTransactionList, "possiblepayeraccountid", possiblePayerFilterValue);
    }

    string batchidFilterValue = Request["Filter_" + FailedTransactionList.ID + "_BatchId"];
    if (!String.IsNullOrEmpty(batchidFilterValue))
    {
      SetGridFilterByColumnValue(FailedTransactionList, "batchid", batchidFilterValue);
    }

    // Refine grid buttons
    // Since resubmitted transactions cannot be resubmitted twice, displaing these buttons doesn't make sence
    if (string.Compare(statusFilterValue, "R", StringComparison.InvariantCultureIgnoreCase) == 0)
    {
      FailedTransactionList.GridButtons.RemoveAll(p => p.ButtonID == "Resubmit" || p.ButtonID == "ResubmitAll");
    }
  }

  protected void SetGridFilterByColumnValue(MTFilterGrid grid, string columnId, string filterValue)
  {
    if (grid == null || string.IsNullOrEmpty(columnId) || string.IsNullOrEmpty(filterValue))
      return;

    MTGridDataElement el = grid.FindElementByID(columnId);
    if (el == null)
    {
      Session[Constants.ERROR] = String.Format("FilterField with id '{0}' not found.", columnId);
    }
    else
    {
      el.ElementValue = filterValue;
    }
  }
}
