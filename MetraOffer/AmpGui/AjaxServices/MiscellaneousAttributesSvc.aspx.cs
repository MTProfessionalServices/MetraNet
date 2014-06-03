using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;
using System.Threading;
using MetraTech.UI.MetraNet.App_Code;


// This Ajax service loads a Decision and shows all of the Decision's Miscellaneous Attributes in the grid.
public partial class AjaxServices_MiscellaneousAttributesSvc : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    private Logger logger = new Logger("[AmpWizard]");

    private string ampDecisionName = "";

    protected bool ExtractDataInternal(AmpServiceClient client, ref MTList<AmpDecisionMiscellaneousAttribute> items, int batchID, int limit)
    {
        try
        {
            items.Items.Clear();
            items.PageSize = limit;
            items.CurrentPage = batchID;

            PopulateData(client, ref items, batchID, limit);
        }
        catch (Exception ex)
        {
          Response.StatusCode = 500; // right status code?
          logger.LogException("An error occurred while loading Decision data.  Please check system logs.", ex);
          return false;
        }

        return true;
    }

    private class AscendingNameComparer : IComparer<AmpDecisionMiscellaneousAttribute>
    {
      public int Compare(AmpDecisionMiscellaneousAttribute x, AmpDecisionMiscellaneousAttribute y)
      {
        return String.Compare(x.Name, y.Name);
      }
    }

    private class DescendingNameComparer : IComparer<AmpDecisionMiscellaneousAttribute>
    {
      public int Compare(AmpDecisionMiscellaneousAttribute x, AmpDecisionMiscellaneousAttribute y)
      {
        return String.Compare(y.Name, x.Name);
      }
    }

    private class AscendingHardCodedValueComparer : IComparer<AmpDecisionMiscellaneousAttribute>
    {
      public int Compare(AmpDecisionMiscellaneousAttribute x, AmpDecisionMiscellaneousAttribute y)
      {
        return String.Compare(x.HardCodedValue, y.HardCodedValue);
      }
    }

    private class DescendingHardCodedValueComparer : IComparer<AmpDecisionMiscellaneousAttribute>
    {
      public int Compare(AmpDecisionMiscellaneousAttribute x, AmpDecisionMiscellaneousAttribute y)
      {
        return String.Compare(y.HardCodedValue, x.HardCodedValue);
      }
    }

    private class AscendingColumnNameComparer : IComparer<AmpDecisionMiscellaneousAttribute>
    {
      public int Compare(AmpDecisionMiscellaneousAttribute x, AmpDecisionMiscellaneousAttribute y)
      {
        return String.Compare(x.ColumnName, y.ColumnName);
      }
    }

    private class DescendingColumnNameComparer : IComparer<AmpDecisionMiscellaneousAttribute>
    {
      public int Compare(AmpDecisionMiscellaneousAttribute x, AmpDecisionMiscellaneousAttribute y)
      {
        return String.Compare(y.ColumnName, x.ColumnName);
      }
    }


    protected void PopulateData(AmpServiceClient client, ref MTList<AmpDecisionMiscellaneousAttribute> items, int batchID, int limit)
    {
      Decision decisionInstance;
      client.GetDecision(ampDecisionName, out decisionInstance);
      logger.LogInfo("Loaded the Decision: '" + ampDecisionName + "'");

      // Get the display values for all the parameter table columns for the Decision's Parameter table
      List<KeyValuePair<String, String>> tableColumnNames;
      AmpWizardBasePage basePage = new AmpWizardBasePage();
      basePage.GetParameterTableColumnNamesWithClient(decisionInstance.ParameterTableName, out tableColumnNames);

      // Push each Miscellaneous error found onto the list that will be displayed by the grid
      int currentID = 0;
      foreach (KeyValuePair<string, DecisionAttributeValue> otherAttribute in decisionInstance.OtherAttributes)
      {
        /*By default when a new Decision is created using the AMP Service, the following two other attributes are included in the Decison, but
         they don't appear to be used by anything: "Continue Counting" and "Product View To Amount Chain Mapping". If these two attributes from 
         the OtherAttributes are deleted, they cause the AMP Service to fail to load the Decision, so we are going to suppress them from the page
         that allows you to edit and delete Miscellaneous attributes.*/
        if (otherAttribute.Key == "Continue Counting" || otherAttribute.Key == "Product View To Amount Chain Mapping")
          continue;
        AmpDecisionMiscellaneousAttribute item = new AmpDecisionMiscellaneousAttribute();
        item.ID = currentID.ToString();
        item.Name = otherAttribute.Key;
        item.HardCodedValue = otherAttribute.Value.HardCodedValue;

        // swap out the database column name and swap in the display value for that column name to show in the grid
        if (!String.IsNullOrEmpty(otherAttribute.Value.ColumnName))
        {
          foreach (var column in tableColumnNames)
          {
            if (column.Key == otherAttribute.Value.ColumnName)
            {
              item.ColumnName = column.Value;
            }
          }   
        }

        // Apply Filtering
        Boolean addToList = true;
        foreach (MTFilterElement filterElement in items.Filters)
        {
          switch (filterElement.PropertyName)
          {
            case "Name":
              if (item.Name != null)
              {
                Regex regex = new Regex(filterElement.Value.ToString().Replace("%",".*"));
                if (!regex.IsMatch(item.Name))
                {
                  addToList = false;
                }
              }
              else
              {
                addToList = false;
              }
              break;
            case "HardCodedValue":
              if (item.HardCodedValue != null)
              {
                Regex regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                if (!regex.IsMatch(item.HardCodedValue))
                {
                  addToList = false;
                }
              }
              else
              {
                addToList = false;
              }
              break;
            case "ColumnName":
              if (item.ColumnName != null)
              {
                Regex regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                if (!regex.IsMatch(item.ColumnName))
                {
                  addToList = false;
                }
              }
              else
              {
                addToList = false;
              }
              break;
          }
        }
        if (addToList)
        {
          items.Items.Add(item);
          currentID++;
        }
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
            case "Name":
              switch (criteria.SortDirection)
              {
                case SortType.Ascending:
                  AscendingNameComparer myAscendingNameComparer = new AscendingNameComparer();
                  items.Items.Sort(myAscendingNameComparer);
                  break;
                case SortType.Descending:
                  DescendingNameComparer myDescendingNameComparer = new DescendingNameComparer();
                  items.Items.Sort(myDescendingNameComparer);
                  break;
              }       
              break;
            case "HardCodedValue":
              switch (criteria.SortDirection)
              {
                case SortType.Ascending:
                  AscendingHardCodedValueComparer myAscendingHardCodedValueComparer = new AscendingHardCodedValueComparer();
                  items.Items.Sort(myAscendingHardCodedValueComparer);
                  break;
                case SortType.Descending:
                  DescendingHardCodedValueComparer myDescendingHardCodedValueComparer = new DescendingHardCodedValueComparer();
                  items.Items.Sort(myDescendingHardCodedValueComparer);
                  break;
              }       
              break;
            case "ColumnName":
              switch (criteria.SortDirection)
              {
                case SortType.Ascending:
                  AscendingColumnNameComparer myAscendingColumnNameComparer = new AscendingColumnNameComparer();
                  items.Items.Sort(myAscendingColumnNameComparer);
                  break;
                case SortType.Descending:
                  DescendingColumnNameComparer myDescendingColumnNameComparer = new DescendingColumnNameComparer();
                  items.Items.Sort(myDescendingColumnNameComparer);
                  break;
              }       
              break;
          }
        }
      }
      #endregion
      
      #region Apply Pagination
      // step through filtered, sorted list and pass only the data for current page
      int start = (items.CurrentPage-1) * items.PageSize;
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

    protected bool ExtractData(AmpServiceClient client, ref MTList<AmpDecisionMiscellaneousAttribute> items)
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

      using (new HighResolutionTimer("DecisionSvcAjax", 5000))
      {
        if (Request["ampDecisionName"] != null)
        {
          ampDecisionName = Request["ampDecisionName"];
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

          MTList<AmpDecisionMiscellaneousAttribute> items = new MTList<AmpDecisionMiscellaneousAttribute>();


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

    } // Page_Load

}
