using System;
using System.Globalization;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Web;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.Enums;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;

namespace MetraNet.AjaxServices
{
  public partial class LoadQuotesList : MTListServicePage
  {
    private const int MaxRecordsPerBatch = 50;

    protected void Page_Load(object sender, EventArgs e)
    {
      using (new HighResolutionTimer("LoadQuoteList", 5000))
      {
        try
        {
          var items = new MTList<EntityInstance>();

          SetPaging(items);
          SetSorting(items);
          SetFilters(items);

          //unable to extract data
          if (!ExtractData(ref items))
          {
            return;
          }

          if (items.Items.Count == 0)
          {
            Response.Write("{\"TotalRows\":\"0\",\"Items\":[]}");
            HttpContext.Current.ApplicationInstance.CompleteRequest();
            return;
          }

          if (Page.Request["mode"] != "csv")
          {
            //convert adjustments into JSON
            //var jss = new JavaScriptSerializer();
            string json = SerialiseItemsToJason(items);
            json = FixJsonDate(json);
            json = FixJsonBigInt(json);
            Response.Write(json);
          }
        }
        catch
          (Exception ex)
        {
          Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
          throw;
        }
        finally
        {
          Response.End();
        }

      }
    }

    protected bool ExtractData(ref MTList<EntityInstance> items)
    {
      if (Page.Request["mode"] == "csv")
      {
        Response.BufferOutput = false;
        Response.ContentType = "application/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=export.csv");
        Response.BinaryWrite(BOM);
      }

      //if there are more records to process than we can process at once, we need to break up into multiple batches
      if ((items.PageSize > MaxRecordsPerBatch) && (Page.Request["mode"] == "csv"))
      {
        int advancePage = (items.PageSize%MaxRecordsPerBatch != 0) ? 1 : 0;

        int numBatches = advancePage + (items.PageSize/MaxRecordsPerBatch);
        for (int batchID = 0; batchID < numBatches; batchID++)
        {
          ExtractDataInternal(ref items, batchID + 1, MaxRecordsPerBatch);

          string strCSV = ConvertObjectToCSV(items, (batchID == 0));
          Response.Write(strCSV);
        }
      }
      else
      {
        ExtractDataInternal(ref items, items.CurrentPage, items.PageSize);
        if (Page.Request["mode"] == "csv")
        {
          string strCSV = ConvertObjectToCSV(items, true);
          Response.Write(strCSV);
        }
      }

      return true;
    }

    protected bool ExtractDataInternal(ref MTList<EntityInstance> items, int batchID, int limit)
    {
      items.Items.Clear();
      items.PageSize = limit;
      items.CurrentPage = batchID;
      try
      {
        var accountsFilterValue = Request["Accounts"];
        if (accountsFilterValue != "ALL" && UI.Subscriber.SelectedAccount != null)
        {
          var accountId = UI.Subscriber.SelectedAccount._AccountID.GetValueOrDefault();
          GetQuotesByAccountId(ref items, accountId);
        }
        else
          GetQuotes(ref items);
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        Response.StatusCode = 500;
        Logger.LogError(ex.Detail.ErrorMessages[0]);
        Response.End();
        return false;
      }
      catch (Exception ex)
      {
        Response.StatusCode = 500;
        Logger.LogError(ex.Message);
        Response.End();
        return false;
      }

      return true;
    }

    private void GetQuotesByAccountId(ref MTList<EntityInstance> items, int accountId)
    {
      var filter1 = new MTFilterElement("AccountID", MTFilterElement.OperationType.Equal, accountId);
      var client1 = new EntityInstanceService_LoadEntityInstances_Client
        {
          UserName = UI.User.UserName,
          Password = UI.User.SessionPassword,
          In_entityName = "Core.Quoting.AccountForQuote",
          InOut_entityInstances = new MTList<EntityInstance>()
        };
      client1.InOut_entityInstances.Filters.Add(filter1);
      client1.Invoke();

      var ids = client1.InOut_entityInstances.Items.Select(item => item.ForeignKeyProperties[0].Value).ToArray();
      items.TotalRows = ids.Length;
      var end = items.CurrentPage*items.PageSize;
      var begin = end - items.PageSize;
      if (end > ids.Length) end = ids.Length;
      for (var i = begin; i < end; i++)
      {
        var filter2 = new MTFilterElement("Id", MTFilterElement.OperationType.Equal, ids[i]);
        var client2 = GetClientQuote();
        client2.InOut_entityInstances = new MTList<EntityInstance>();
        client2.InOut_entityInstances.Filters.AddRange(items.Filters);
        client2.InOut_entityInstances.Filters.Add(filter2);
        client2.Invoke();
        items.Items.AddRange(client2.InOut_entityInstances.Items);
      }
    }

    private void GetQuotes(ref MTList<EntityInstance> items)
    {
      var client = GetClientQuote();
      client.InOut_entityInstances = items;
      client.Invoke();
      items = client.InOut_entityInstances;
    }

    private EntityInstanceService_LoadEntityInstances_Client GetClientQuote()
    {
      return new EntityInstanceService_LoadEntityInstances_Client
        {
          UserName = UI.User.UserName,
          Password = UI.User.SessionPassword,
          In_entityName = "Core.Quoting.QuoteHeader"
        };
    }

    //for BME entity
    private string SerialiseItemsToJason(MTList<EntityInstance> items)
    {
      var json = new StringBuilder();

      json.Append("{\"TotalRows\":");
      // ReSharper disable SpecifyACultureInStringConversionExplicitly
      json.Append(items.TotalRows.ToString());
      json.Append(", \"Items\":[");

      int j = 0;
      foreach (var entityInstance in items.Items)
      {
        if (!(j == 0 || j == items.Items.Count))
        {
          json.Append(",");
        }

        json.Append("{");

        // add internalId to each row
        json.Append("\"internalId\":");
        json.Append("\"");
        json.Append(entityInstance.Id);
        json.Append("\",");

        int i = 0;
        foreach (PropertyInstance propertyInstance in entityInstance.Properties)
        {
          if (!(i == 0 || i == entityInstance.Properties.Count))
          {
            json.Append(",");
          }

          json.Append("\"");
          json.Append(propertyInstance.Name);
          json.Append("\":");

          object dispalyValue = null;

          if (propertyInstance.Value == null || string.IsNullOrEmpty(propertyInstance.Value.ToString()))
          {
            json.Append("null");
          }
          else
          {
            dispalyValue = (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum
                              ? EnumHelper.GetEnumEntryName(propertyInstance.Value)
                              : propertyInstance.Value.ToString()).EncodeForJavaScript();

            if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Decimal)
            {
              dispalyValue = ProcessDecimalValue(dispalyValue.ToString());
            }

            if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.String ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.DateTime ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Decimal ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Guid)
            {
              json.Append("\"");
            }

            if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Boolean)
            {
              // boolean is lowercase in javascript
              json.Append(propertyInstance.Value.ToString().ToLower());
            }
            else
            {
              json.Append(dispalyValue);
            }

            if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.String ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.DateTime ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Decimal ||
                propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Guid)
            {
              json.Append("\"");
            }
          }

          // Display Name
          json.Append(",");
          json.Append("\"");
          json.Append(propertyInstance.Name.EncodeForJavaScript());
          json.Append("DisplayName");
          json.Append("\":");
          json.Append("\"");
          json.Append(propertyInstance.Name.EncodeForJavaScript()); // TODO:  KAB: Localized label
          json.Append("\"");

          // Value Display Name for enums
          if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum)
          {
            json.Append(",");
            json.Append("\"");
            json.Append(propertyInstance.Name.EncodeForJavaScript());
            json.Append("ValueDisplayName");
            json.Append("\":");
            json.Append("\"");

            if (dispalyValue != null)
            {
              json.Append(dispalyValue); // TODO:  KAB: Localized label
            }

            json.Append("\"");
          }

          i++;
        }

        json.Append("}");
        j++;
      }

      json.Append("]");
      json.Append(", \"CurrentPage\":");
      json.Append(items.CurrentPage.ToString());
      json.Append(", \"PageSize\":");
      json.Append(items.PageSize.ToString());
      //json.Append(", \"Filters\":");
      //json.Append(jss.Serialize(items.Filters));
      json.Append(", \"SortProperty\":");
      if (items.SortCriteria == null || items.SortCriteria.Count == 0)
      {
        json.Append("null");
        json.Append(", \"SortDirection\":\"");
        json.Append(SortType.Ascending.ToString());
      }
      else
      {
        json.Append("\"");
        json.Append(items.SortCriteria[0].SortProperty);
        json.Append("\"");
        json.Append(", \"SortDirection\":\"");
        json.Append(items.SortCriteria[0].SortDirection.ToString());

      }
      json.Append("\"}");
      return json.ToString();
    }

    private static object ProcessDecimalValue(string dispalyValue)
    {
      var separator = CultureInfo.CurrentCulture.NumberFormat.NumberDecimalSeparator;
      dispalyValue = Math.Round(Decimal.Parse(dispalyValue), 2).ToString();
      if (dispalyValue.StartsWith(String.Format("0{0}00", separator)))
      {
        return "0";
      }
      return dispalyValue.IndexOf(separator, StringComparison.Ordinal) == -1? dispalyValue + separator + "00" : dispalyValue;
    }
  }
}