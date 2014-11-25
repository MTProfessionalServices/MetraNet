using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.NotificationEvents.EventHandler.Entities;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class Notifications : MTPage
{
  protected Dictionary<string, string> NotificationEventsTemplates;
  protected string hiddenOut = "";
  protected void Page_Load(object sender, EventArgs e)
  {
    NotificationEventsTemplates =
      NotificationService.GetExisitingNotificationEventsTemplates(UI.SessionContext.LanguageID);
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    NotificationsGrid.DataSourceURL =
      @"/MetraNet/Notifications/AjaxServices/GetNotifications.aspx";
    PopulateNotificationTypesDropDown();

    // For Partition users, suppress the partition filter
    if (PartitionLibrary.IsPartition)
    {
      NotificationsGrid.FindElementByID("id_partition").DefaultFilter = false;
      NotificationsGrid.FindElementByID("id_partition").Filterable = false;
    }
    else
    {
      PopulatePartitionsDropDown();
    }

  }
  
  protected string defineJavaScriptDictionary()
  {
    string outstr= "var hashtable = {};\n";
    foreach (string notname in NotificationEventsTemplates.Keys)
    {
      outstr += "hashtable[\"";
      string tmp ="";
      outstr += notname;
      outstr += "\"] = \"";
      NotificationEventsTemplates.TryGetValue(notname, out tmp);
      outstr += tmp+"\";\n";
    }
    return outstr;
  }

  protected void PopulateNotificationTypesDropDown()
  {
    List<NotificationEventMetaDataDB> notificaitonTypes = NotificationService.GetExisitingNotificationEventNames(UI.SessionContext.LanguageID);

    foreach (NotificationEventMetaDataDB nmdb in notificaitonTypes)
    {
      var dropDownItem = new MTFilterDropdownItem();
      dropDownItem.Key = nmdb.NotificationEventName;
      dropDownItem.Value = nmdb.NotificationEventName;
      NotificationsGrid.FindElementByID("localized_event_name").FilterDropdownItems.Add(dropDownItem);
    }

  }

  protected void PopulatePartitionsDropDown()
  {
    Dictionary<string, Int32> partitions = PartitionLibrary.RetrieveAllPartitions();
    partitions = partitions.OrderByDescending(x => x.Value).ToDictionary(x => x.Key, x => x.Value);
    partitions.Add("Non-Partitioned", 1);
    foreach (string pname in partitions.Keys)
    {
      Int32 val;
      partitions.TryGetValue(pname, out val);
      var dropDownItem = new MTFilterDropdownItem();
      dropDownItem.Key = "" + val;
      dropDownItem.Value = pname;
      NotificationsGrid.FindElementByID("id_partition").FilterDropdownItems.Add(dropDownItem);
    }

  }

}