using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;

public partial class MetraOffer_AmpGui_AjaxServices_AmpSvc : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    private readonly Logger _logger = new Logger("[AmpWizard]");

    private string _ampCommand = String.Empty;
    private string _currentDirectiveId = String.Empty;
    
    #region Common functions

    protected void ApplyPagination<T>(ref MTList<T> items, int batchID, int limit)
    {
        // step through filtered, sorted list and pass only the data for current page
        int start = (items.CurrentPage - 1) * items.PageSize;
        if (start > 0)
        {
            items.Items.RemoveRange(0, start);
        }
        if ((start + items.PageSize) < items.TotalRows)
        {
            items.Items.RemoveRange(items.PageSize, items.TotalRows - (start + items.PageSize));
        }
    }
    
    protected bool ConfigItems<T>(ref MTList<T> items)
    {
        if (Page.Request["mode"] == "csv")
        {
            Response.BufferOutput = false;
            Response.ContentType = "application/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
        }

        //if there are more records to process than we can process at once, we need to break up into multiple batches
        if ((items.PageSize > MAX_RECORDS_PER_BATCH) && (Page.Request["mode"] == "csv"))
        {
            int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

            int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
            for (int batchID = 0; batchID < numBatches; batchID++)
            {
                ApplyPagination(ref items, batchID + 1, MAX_RECORDS_PER_BATCH);
                string strCSV = ConvertObjectToCSV(items, (batchID == 0));
                Response.Write(strCSV);
            }
        }
        else
        {
            ApplyPagination(ref items, items.CurrentPage, items.PageSize);

            if (Page.Request["mode"] == "csv")
            {
                string strCSV = ConvertObjectToCSV(items, true);
                Response.Write(strCSV);
            }
        }

        return true;
    }

    //the final function
    private void BindToGrid<T>(MTList<T> items)
    {
        SetPaging(items);
        SetSorting(items);
        SetFilters(items);

        if (ConfigItems(ref items))
        {
            if (items.Items.Count == 0)
            {
                Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
                HttpContext.Current.ApplicationInstance.CompleteRequest();
            }
            else if (Page.Request["mode"] != "csv")
            {
                var jss = new JavaScriptSerializer();
                string json = jss.Serialize(items);
                Response.Write(json);
            }
        }
    }

    #endregion

    #region Sorting

    private void ApplySorting(ref MTList<KeyValuePair<string, string>> items)
    {
        if (items.SortCriteria != null && items.SortCriteria.Count > 0)
        {
            foreach (SortCriteria criteria in items.SortCriteria)
            {
                // apply the sort on the list in memory
                switch (criteria.SortProperty)
                {
                    case "FieldName":
                        switch (criteria.SortDirection)
                        {
                            case SortType.Ascending:
                                var myAscendingColumnStringComparer = new AscendingColumnStringComparer();
                                items.Items.Sort(myAscendingColumnStringComparer);
                                break;
                            case SortType.Descending:
                                var myDescendingColumnStringComparer = new DescendingColumnStringComparer();
                                items.Items.Sort(myDescendingColumnStringComparer);
                                break;
                        }
                        break;
                }
            }
        }
    }

    #region Comparers

    private class AscendingColumnStringComparer : IComparer<KeyValuePair<string, string>>
    {
        public int Compare(KeyValuePair<string, string> x, KeyValuePair<string, string> y)
        {
            return String.Compare(x.Key, y.Key);
        }
    }

    private class DescendingColumnStringComparer : IComparer<KeyValuePair<string, string>>
    {
        public int Compare(KeyValuePair<string, string> x, KeyValuePair<string, string> y)
        {
            return String.Compare(y.Key, x.Key);
        }
    }

    #endregion

    #endregion
    
    protected void Page_Load(object sender, EventArgs e)
    {
        // Extra check that user has permission to configure AMP decisions.
        if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
        {
            Response.End();
            return;
        }

        RetrieveAmpCommand();

        switch(_ampCommand)
        {
            case "DeleteDirective":
                ProcessingDirective();
                break;

            case "RaisePriorityDirective":
                ProcessingDirective();
                break;

            case "ReducePriorityDirective":
                ProcessingDirective();
                break;

            //note: This function is a quick sketch! It does not works, just shows the sequence of calling functions in my opinion.
            case "AppendGeneratedChargeGrid" :
                AppendGenChargeGrid();
                break;
        }

        Response.End();
    }

    #region Main methods

    private void ProcessingDirective()
    {
        var chargeName = Request["chargeName"];
        _currentDirectiveId = Request["directiveId"];

        ProcessingDirectiveWithClient(chargeName);
    }

    private void AppendGenChargeGrid()
    {
        using (new HighResolutionTimer("AmpSvc", 5000))
        {
            var items = GetGeneratedChargeItemsWithClient();

            //note: sort functions are non-generic, so they should be applied before calling BindToGrid()
            //ApplySorting(ref items);

            BindToGrid(items);
        }
    }

    #endregion

    #region Service client methods
    //processing directive
    private void ProcessingDirectiveWithClient(string name)
    {
        AmpServiceClient client = null;

        try
        {
            // Set up client.
            client = new AmpServiceClient();
            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            GeneratedCharge generatedCharge;
            client.GetGeneratedCharge(name, out generatedCharge);

            GeneratedChargeDirective directive = generatedCharge.GeneratedChargeDirectives.First(DirectiveWithCurrentId);
            if(directive == null)
            {
                SetRequestError(string.Format("Generated Charge Directive with id '{0}' not found.", _currentDirectiveId));
            }

            UpdateDirectiveDueToCommand(generatedCharge, directive);

            client.SaveGeneratedCharge(generatedCharge);

            // Clean up client.
            client.Close();
            client = null;
            Response.Write("OK");
        }
        catch (Exception ex)
        {
            Response.Write("Error");
            _logger.LogException("An error occurred while processing Generated Charge Directive. Please check system logs.", ex);
            throw;
        }
        finally
        {
            if (client != null)
            {
                client.Abort();
            }
        }
    }

    private void UpdateDirectiveDueToCommand(GeneratedCharge generatedCharge, GeneratedChargeDirective directive)
    {
      switch (_ampCommand)
      {
        case "DeleteDirective":
          generatedCharge.GeneratedChargeDirectives.Remove(directive);
          break;

        case "RaisePriorityDirective":
          // Move this directive earlier by decrementing its own Priority value and
          // incrementing any other directives that are already at that earlier-priority value.
          // (We support negative priority values and non-unique priority values.)
          int earlierPriorityLevel = directive.Priority - 1;
          foreach (var otherDirective in generatedCharge.GeneratedChargeDirectives)
          {
            if (otherDirective.Priority == earlierPriorityLevel)
            {
              otherDirective.Priority++;
            }
          }
          directive.Priority--;
          break;

        case "ReducePriorityDirective":
          // Move this directive later by incrementing its own Priority value and
          // decrementing any other directives that are already at that later-priority value.
          // (We support negative priority values and non-unique priority values.)
          int laterPriorityLevel = directive.Priority + 1;
          foreach (var otherDirective in generatedCharge.GeneratedChargeDirectives)
          {
            if (otherDirective.Priority == laterPriorityLevel)
            {
              otherDirective.Priority--;
            }
          }
          directive.Priority++;
          break;
      }
    }

  private MTList<GeneratedCharge> GetGeneratedChargeItemsWithClient()
    {
        var items = new MTList<GeneratedCharge>();

        AmpServiceClient client = null;

        try
        {
            client = new AmpServiceClient();
            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = UI.User.UserName;
                client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            client.GetGeneratedCharges(ref items);

            client.Close();
            client = null;
        }
        catch (Exception ex)
        {
            _logger.LogException("An error occurred while loading Generated Charge data.  Please check system logs.", ex);
            throw;
        }
        finally
        {
            if (client != null)
            {
                client.Abort();
            }
        }

        return items;
    }
    
    #endregion

    // Predicate that searches Directive by Id
    private bool DirectiveWithCurrentId(GeneratedChargeDirective directive)
    {
        return String.Compare(directive.UniqueId.ToString(), _currentDirectiveId) == 0;
    }

    private void SetRequestError(string message)
    {
        Response.Write("Error");
        _logger.LogException(message, new Exception(message));
        Response.End();
    }

    private void RetrieveAmpCommand()
    {
        _ampCommand = Request["ampCommand"];
        if(String.IsNullOrEmpty(_ampCommand))
        {
            SetRequestError("Command for AMP AJAX service wasn't specified");
        }
    }
}