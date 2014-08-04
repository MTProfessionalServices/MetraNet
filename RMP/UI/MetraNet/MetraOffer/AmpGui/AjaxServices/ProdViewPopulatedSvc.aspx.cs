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

public partial class MetraOffer_AmpGui_AjaxServices_ProdViewPopulatedSvc : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    private Logger logger = new Logger("[AmpWizard]");
    
    private string ampGeneratedChargeName = "";
    private string ampProductViewName = "";
    private string currentFieldName = "";

    protected bool ExtractDataInternal(AmpServiceClient client, ref MTList<KeyValuePair<string, string>> items, int batchID, int limit)
    {
        try
        {
            items.Items.Clear();
            items.PageSize = limit;
            items.CurrentPage = batchID;

            var stringItems = new MTList<string>();
            GeneratedCharge generatedChargeInstance;

            client.GetAccUsageColumnNames(ref stringItems);
            client.GetProductViewColumnNames(ampProductViewName, ref stringItems);

            client.GetGeneratedCharge(ampGeneratedChargeName, out generatedChargeInstance);
            
            int currentID = 0;
            foreach(var item in stringItems.Items)
            {
                currentFieldName = item;
                string populated = generatedChargeInstance.GeneratedChargeDirectives.Exists(HasCurrentFieldName) ? "Yes" : "No";

                var pair = new KeyValuePair<string, string>(item, populated);
                items.Items.Add(pair);
                currentID++;
            }
            items.TotalRows = currentID;

            #region Apply Sorting
            //add sorting info if applies
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
                        case "Populated":
                            switch (criteria.SortDirection)
                            {
                                case SortType.Ascending:
                                var myAscendingColumnStringComparer = new AscendingPopulatedColumnStringComparer();
                                    items.Items.Sort(myAscendingColumnStringComparer);
                                    break;
                                case SortType.Descending:
                                    var myDescendingColumnStringComparer = new DescendingPopulatedColumnStringComparer();
                                    items.Items.Sort(myDescendingColumnStringComparer);
                                    break;
                            }
                            break;
                    }
                }
            }
            #endregion

            #region Apply Pagination
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
            #endregion
            
        }
        catch (Exception ex)
        {
            Response.StatusCode = 500; // right status code?
            logger.LogException("An error occurred while loading Decision data.  Please check system logs.", ex);
            return false;
        }

        return true;
    }

    protected bool ExtractData(AmpServiceClient client, ref MTList<KeyValuePair<string, string>> items)
    {
        if (Page.Request["mode"] == "csv")
        {
            Response.BufferOutput = false;
            Response.ContentType = "application/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
            Response.BinaryWrite(BOM);
        }

        //if there are more records to process than we can process at once, we need to break up into multiple batches
        if ((items.PageSize > MAX_RECORDS_PER_BATCH) && (Page.Request["mode"] == "csv"))
        {
            int advancePage = (items.PageSize % MAX_RECORDS_PER_BATCH != 0) ? 1 : 0;

            int numBatches = advancePage + (items.PageSize / MAX_RECORDS_PER_BATCH);
            for (int batchID = 0; batchID < numBatches; batchID++)
            {
                if (!ExtractDataInternal(client, ref items, batchID + 1, MAX_RECORDS_PER_BATCH))
                {
                    //unable to extract data
                    return false;
                }

                string strCSV = ConvertObjectToCSV(items, (batchID == 0));
                Response.Write(strCSV);
            }
        }
        else
        {
            if (!ExtractDataInternal(client, ref items, items.CurrentPage, items.PageSize))
            {
                //unable to extract data
                return false;
            }

            if (Page.Request["mode"] == "csv")
            {
                string strCSV = ConvertObjectToCSV(items, true);
                Response.Write(strCSV);
            }
        }

        return true;
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        // Extra check that user has permission to configure AMP decisions.
        if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
        {
            Response.End();
            return;
        }

        using (new HighResolutionTimer("ProdViewPopulatedSvc", 5000))
        {
            if (Request["ampGeneratedChargeName"] != null)
            {
                ampGeneratedChargeName = Request["ampGeneratedChargeName"];
            }

            if (Request["ampProductViewName"] != null)
            {
                ampProductViewName = Request["ampProductViewName"];
            }

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

                MTList<KeyValuePair<string, string>> items = new MTList<KeyValuePair<string, string>>();

                SetPaging(items);
                SetSorting(items);
                SetFilters(items);

                if (ExtractData(client, ref items))
                {
                    if (items.Items.Count == 0)
                    {
                        Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
                        HttpContext.Current.ApplicationInstance.CompleteRequest();
                    }
                    else if (Page.Request["mode"] != "csv")
                    {
                        JavaScriptSerializer jss = new JavaScriptSerializer();
                        string json = jss.Serialize(items);
                        Response.Write(json);
                    }
                }

                // Clean up client.
                client.Close();
                client = null;
            }
            catch (Exception ex)
            {
                logger.LogException("An error occurred while loading Decision data.  Please check system logs.", ex);
                throw;
            }
            finally
            {
                Response.End();
                if (client != null)
                {
                    client.Abort();
                }
            }
        } // using

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

    private class AscendingPopulatedColumnStringComparer : IComparer<KeyValuePair<string, string>>
    {
      public int Compare(KeyValuePair<string, string> x, KeyValuePair<string, string> y)
      {
        return String.Compare(x.Value, y.Value);
      }
    }

    private class DescendingPopulatedColumnStringComparer : IComparer<KeyValuePair<string, string>>
    {
      public int Compare(KeyValuePair<string, string> x, KeyValuePair<string, string> y)
      {
        return String.Compare(y.Value, x.Value);
      }
    }
    #endregion

    // Search predicate returns true if currentFieldName euqal to directive's FieldName.
    private bool HasCurrentFieldName(GeneratedChargeDirective directive)
    {
        return directive.FieldName == currentFieldName;
    }
}