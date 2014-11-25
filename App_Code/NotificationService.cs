using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.NotificationEvents.EventHandler.Entities;
using MetraTech.UI.Common;
using MetraTech.NotificationEvents.EventHandler;


/// <summary>
/// This class is responsible for getting all notifications for the logged in user.
/// </summary>
public class NotificationService
{
  private const string _sqlQueriesPath = @"..\config\SqlCore\Queries\NotificationEvents";
  private static readonly Logger _logger = new Logger(String.Format("[{0}]", typeof(NotificationService)));

  public static List<NotificationEventMetaDataDB> GetExisitingNotificationEventNames(int langcode = -1)
  {
    return NotificationEventMetaDataSyncHandler.GetExistingNotificationEventsMetaData(langcode);
  }

  public static Dictionary<string, string> GetExisitingNotificationEventsTemplates(int langcode = 820)
  {
    return NotificationEventMetaDataSyncHandler.GetExistingNotificationEventsTemplates(langcode);
  }

  public static void GetNotificationEvents(ref MTList<SQLRecord> notificationEvents, int accountID, int langID)
  {
    _logger.LogDebug("Getting notification events for {0}", accountID);

    MTList<SQLRecord> notificationEventPropValues = new MTList<SQLRecord>();
    notificationEventPropValues.PageSize = notificationEvents.PageSize;
    notificationEventPropValues.CurrentPage = notificationEvents.CurrentPage;
    notificationEventPropValues.SortCriteria = notificationEvents.SortCriteria;
    notificationEventPropValues.Filters = notificationEvents.Filters;
    GetNotificationEventPropertyValuesXml(ref notificationEventPropValues, accountID, langID);

    PopulateNotificationEvents(notificationEventPropValues, notificationEvents);
  }


  private static void PopulateNotificationEvents(MTList<SQLRecord> notificationEventPropValues, MTList<SQLRecord> notificationEvents)
  {
    _logger.LogDebug("Populate notification event data from xml");

    SQLRecord record;
    foreach (SQLRecord item in notificationEventPropValues.Items)
    {
      record = new SQLRecord();
      foreach (SQLField field in item.Fields)
      {
        if (field.FieldName.Equals("notification_event_prop_values"))
        {
          record.Fields.AddRange(GetFieldsFromXml(field.FieldValue));
        }
        else
        {
          record.Fields.Add(field);
        }
      }
      notificationEvents.Items.Add(record);
    }
    notificationEvents.TotalRows = notificationEventPropValues.TotalRows;
  }


  private static List<SQLField> GetFieldsFromXml(object xml)
  {
    SQLField field;
    List<SQLField> propertyFields = new List<SQLField>();
    XElement propertyNameElement, propertyValueElement;
    XAttribute propertyTypeAttribute;

    string notificationEventPropValuesXml = Convert.ToString(xml).Replace("\\\"", "\"");
    XDocument propValuesXml = XDocument.Parse(notificationEventPropValuesXml, LoadOptions.None);

    foreach (XElement prop in propValuesXml.Root.Elements("NotificationEventPropertyValueMap"))
    {
      propertyNameElement = prop.Element("Property");
      propertyValueElement = prop.Element("Value");

      if (propertyNameElement != null && propertyValueElement != null)
      {
        propertyTypeAttribute = propertyValueElement.Attributes().FirstOrDefault(x => (x.Value.ToLower().Contains("date")));
        
        field = new SQLField { FieldDataType = typeof(string), FieldName = (propertyNameElement != null) ? propertyNameElement.Value : ""};
        if (propertyTypeAttribute != null)
        {
          field.FieldValue = Convert.ToDateTime(propertyValueElement.Value).ToString("d");
        }
        else
        {
          field.FieldValue = propertyValueElement.Value;
        }
        
        propertyFields.Add(field);
      }
    }
    return propertyFields;
  }

  private static void GetNotificationEventPropertyValuesXml(ref MTList<SQLRecord> notificationEventPropValuesXml, int accountID, int langID)
  {
    using (IMTConnection conn = ConnectionManager.CreateConnection())
    {
      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(_sqlQueriesPath, "__GET_NOTIFICATION_EVENTS_FOR_LOGGED_IN_USER__"))
      {
        stmt.AddParam("%%ID_ACC%%", accountID);
        stmt.AddParam("%%ID_LANG%%", langID);
        using (IMTPreparedFilterSortStatement filterSortStmt =
            conn.CreatePreparedFilterSortStatement(stmt.Query))
        {
          MTListFilterSort.ApplyFilterSortCriteria(filterSortStmt, notificationEventPropValuesXml);
          using (IMTDataReader reader = filterSortStmt.ExecuteReader())
          {
            ConstructItems(reader, ref notificationEventPropValuesXml);
          }
          notificationEventPropValuesXml.TotalRows = filterSortStmt.TotalRows;
        }
      }
    }
  }

  private static void ConstructItems(IMTDataReader rdr, ref MTList<SQLRecord> items)
  {
    items.Items.Clear();

    while (rdr.Read())
    {
      var record = new SQLRecord();
      for (int i = 0; i < rdr.FieldCount; i++)
      {
        var field = new SQLField { FieldDataType = rdr.GetType(i), FieldName = rdr.GetName(i) };

        if (!rdr.IsDBNull(i))
        {
          field.FieldValue = rdr.GetValue(i);
        }
        record.Fields.Add(field);
      }
      items.Items.Add(record);
    }
  }

}