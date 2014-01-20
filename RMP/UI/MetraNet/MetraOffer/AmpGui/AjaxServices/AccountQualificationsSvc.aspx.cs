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

public partial class MetraOffer_AmpGui_AjaxServices_AccountQualificationsSvc : MTListServicePage
{
    private const int MAX_RECORDS_PER_BATCH = 50;

    private Logger logger = new Logger("[AmpWizard]");

    private String _ajaxSvcCommand = String.Empty;
    private String _acctGroupName = String.Empty;
    private String _acctQualId = String.Empty;
    private String _acctGroupDesc = null;


    protected void Page_Load(object sender, EventArgs e)
    {
        // Extra check that user has permission to configure AMP decisions.
        if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
        {
            Response.End();
            return;
        }

        using (new HighResolutionTimer("AccountQualificationsSvcAjax", 5000))
        {
            GetRequestParameters();

            switch (_ajaxSvcCommand)
            {
              case "MoveAccountQualificationEarlier":
              case "MoveAccountQualificationLater":
              case "DeleteAccountQualification":
              case "UpdateAccountGroupDescription":
                ModifyAccountGroup();
                break;

              case "LoadAcctQualificationsGrid":
                LoadGrid();
                break;
            }

            Response.End();
        } // using

    }

    private void GetRequestParameters()
    {
      _ajaxSvcCommand = String.Empty;
      _acctGroupName = String.Empty;
      _acctQualId = String.Empty;
      _acctGroupDesc = null;

      if (Request["command"] != null)
      {
        _ajaxSvcCommand = Request["command"];
      }
      if (String.IsNullOrEmpty(_ajaxSvcCommand))
      {
        SetRequestError("Command for AMP AJAX service wasn't specified");
      }

      if (Request["accountGroupName"] != null)
      {
        _acctGroupName = Request["accountGroupName"];
      }
      if (Request["accountQualificationId"] != null)
      {
        _acctQualId = Request["accountQualificationId"];
      }
      if (Request["accountGroupDescription"] != null)
      {
        _acctGroupDesc = Request["accountGroupDescription"];
      }
    }

    protected bool ExtractDataInternal(AmpServiceClient client, ref MTList<AccountQualification> items, int batchID, int limit)
    {
      try
      {
        items.Items.Clear();
        items.PageSize = limit;
        items.CurrentPage = batchID;

        AccountQualificationGroup acctGroup;
        client.GetAccountQualificationGroup(_acctGroupName, out acctGroup);

        int currentID = 0;
        foreach (AccountQualification qual in acctGroup.AccountQualifications)
        {
          #region Apply Filtering
          // Apply Filtering if it applies
          Boolean addToList = true;
          foreach (MTFilterElement filterElement in items.Filters)
          {
            Regex regex;
            switch (filterElement.PropertyName)
            {
              case "TableToInclude":
                if (qual.TableToInclude != null)
                {
                  regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                  if (!regex.IsMatch(qual.TableToInclude))
                  {
                    addToList = false;
                  }
                }
                else
                {
                  addToList = false;
                }
                break;
              case "MvmFilter":
                if (qual.MvmFilter != null)
                {
                  regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                  if (!regex.IsMatch(qual.MvmFilter))
                  {
                    addToList = false;
                  }
                }
                else
                {
                  addToList = false;
                }
                break;
              case "Mode":
                regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                if (!regex.IsMatch(qual.Mode.ToString()))
                {
                  addToList = false;
                }
                break;
              case "Priority":
                regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                if (!regex.IsMatch(qual.Priority.ToString()))
                {
                  addToList = false;
                }
                break;
              case "DbFilter":
                if (qual.DbFilter != null)
                {
                  regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                  if (!regex.IsMatch(qual.DbFilter))
                  {
                    addToList = false;
                  }
                }
                else
                {
                  addToList = false;
                }
                break;
              case "MatchField":
                if (qual.MatchField != null)
                {
                  regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                  if (!regex.IsMatch(qual.MatchField))
                  {
                    addToList = false;
                  }
                }
                else
                {
                  addToList = false;
                }
                break;
              case "OutputField":
                if (qual.OutputField != null)
                {
                  regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                  if (!regex.IsMatch(qual.OutputField))
                  {
                    addToList = false;
                  }
                }
                else
                {
                  addToList = false;
                }
                break;
              case "SourceField":
                if (qual.SourceField != null)
                {
                  regex = new Regex(filterElement.Value.ToString().Replace("%", ".*"));
                  if (!regex.IsMatch(qual.SourceField))
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
            items.Items.Add(qual);
            currentID++;
          }
          #endregion
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
              case "Priority":
                switch (criteria.SortDirection)
                {
                  case SortType.Ascending:
                    var myAscendingColumnPriorityComparer = new AscendingColumnPriorityComparer();
                    items.Items.Sort(myAscendingColumnPriorityComparer);
                    break;
                  case SortType.Descending:
                    var myDescendingColumnPriorityComparer = new DescendingColumnPriorityComparer();
                    items.Items.Sort(myDescendingColumnPriorityComparer);
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

    protected bool ExtractData(AmpServiceClient client, ref MTList<AccountQualification> items)
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

    private void LoadGrid()
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

        MTList<AccountQualification> items = new MTList<AccountQualification>();

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
        if (client != null)
        {
          client.Abort();
        }
      }
    }


    #region Comparers

    private class AscendingColumnPriorityComparer : IComparer<AccountQualification>
    {
        public int Compare(AccountQualification x, AccountQualification y)
        {
            if (x.Priority > y.Priority)
            {
                return 1;
            }
            else if (x.Priority < y.Priority)
            {
                return -1;
            }
            else
            {
                return 0;
            }
        }
    }

    private class DescendingColumnPriorityComparer : IComparer<AccountQualification>
    {
        public int Compare(AccountQualification x, AccountQualification y)
        {
            if (y.Priority > x.Priority)
            {
                return 1;
            }
            else if (y.Priority < x.Priority)
            {
                return -1;
            }
            else
            {
                return 0;
            }
        }
    }

    #endregion


    private void ModifyAccountGroup()
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

        AccountQualificationGroup acctGroup;
        AccountQualification acctQual;

        client.GetAccountQualificationGroup(_acctGroupName, out acctGroup);
        if (acctGroup != null)
        {
          // Update the account group's description from the textarea's contents.
          if (_acctGroupDesc != null)
          {
            acctGroup.Description = _acctGroupDesc;
          }

          if (_ajaxSvcCommand != "UpdateAccountGroupDescription")
          {
            // Update the account qualifications.
            acctQual = acctGroup.AccountQualifications.First(AcctQualificationWithCurrentId);
            if (acctQual != null)
            {
              UpdateAcctQualInAcctGroup(acctQual, acctGroup);
            }
            else
            {
              SetRequestError(string.Format("Account Qualification with id '{0}' not found.", _acctQualId));
            }
            
          }

          // Save the modified data to DB.
          client.SaveAccountQualificationGroup(acctGroup);
        }

        // Clean up client.
        client.Close();
        client = null;
        Response.Write("OK");
      }
      catch (Exception ex)
      {
        Response.Write("Error");
        logger.LogException(String.Format("An error occurred while processing Account Qualification Group '{0}'. Please check system logs.", _acctGroupName), ex);
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


    private void UpdateAcctQualInAcctGroup(AccountQualification acctQual, AccountQualificationGroup acctGroup)
    {
      switch (_ajaxSvcCommand)
      {
        case "DeleteAccountQualification":
          acctGroup.AccountQualifications.Remove(acctQual);
          break;

        case "MoveAccountQualificationEarlier":  
          // Move this AQ earlier by decrementing its own Priority value and
          // incrementing any other AQs that are already at that earlier-priority value.
          // (We support negative priority values and non-unique priority values.)
          int earlierPriorityLevel = acctQual.Priority - 1;
          foreach (var otherAccountQual in acctGroup.AccountQualifications)
          {
            if (otherAccountQual.Priority == earlierPriorityLevel)
            {
              otherAccountQual.Priority++;
            }
          }
          acctQual.Priority--;
          break;

        case "MoveAccountQualificationLater":  
          // Move this AQ later by incrementing its own Priority value and
          // decrementing any other AQs that are already at that later-priority value.
          // (We support negative priority values and non-unique priority values.)
          int laterPriorityLevel = acctQual.Priority + 1;
          foreach (var otherAccountQual in acctGroup.AccountQualifications)
          {
            if (otherAccountQual.Priority == laterPriorityLevel)
            {
              otherAccountQual.Priority--;
            }
          }
          acctQual.Priority++;
          break;
      }
    }


    // Predicate that searches for an Account Qualification by UniqueId
    private bool AcctQualificationWithCurrentId(AccountQualification acctQual)
    {
      return String.Compare(acctQual.UniqueId.ToString(), _acctQualId) == 0;
    }


    private void SetRequestError(string message)
    {
      Response.Write("Error");
      logger.LogException(message, new Exception(message));
      Response.End();
    }

}