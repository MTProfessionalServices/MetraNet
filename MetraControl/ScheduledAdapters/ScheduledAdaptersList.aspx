<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ScheduledAdaptersList.aspx.cs" Inherits="ScheduledAdaptersList" Title="MetraNet - Scheduled Adapters Event List"
  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="MTTitle1" Text="Scheduled Adapters Event List" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <br />
  <MT:MTFilterGrid runat="Server" ID="ScheduledAdaptersListGrid" ExtensionName="Core"
    TemplateFileName="ScheduledAdaptersList.xml" />
  <style type="text/css">
    td div {
      white-space: inherit !important;
    }
  </style>
  <script type="text/javascript">
    var StrScheduleName = "";
    OverrideRenderer_<%= ScheduledAdaptersListGrid.ClientID %> = function(cm) {
      cm.setRenderer(cm.getIndexById('schedule'), ScheduleRenderer);
      cm.setRenderer(cm.getIndexById('ispaused'), NextRunRenderer);
      cm.setRenderer(cm.getIndexById('displayname'), DisplayNameRenderer);
      cm.setRenderer(cm.getIndexById('description'), DescriptionRenderer);
    };

    function ScheduleRenderer(value, meta, record, rowIndex, colIndex, store) {
      switch (record.data.intervaltype.toLowerCase()) {
      case "daily":
        StrScheduleName = String.format('<%=GetLocalResourceObject("TEXT_SCHEDULE_DAY")%>', record.data.interval, getCorrectTime(record.data.executiontimes));
        break;
      case "monthly":
        StrScheduleName = String.format('<%=GetLocalResourceObject("TEXT_SCHEDULE_MONTH")%>', record.data.interval, getCorrectTime(record.data.executiontimes), getCorrectMonthlyDay(record.data.daysofmonth));
        break;
      case "weekly":
        StrScheduleName = String.format('<%=GetLocalResourceObject("TEXT_SCHEDULE_WEEK")%>', record.data.interval, getCorrectTime(record.data.executiontimes), getCorrectWeekDay(record.data.daysofweek));
        break;
      case "minutely":
        StrScheduleName = String.format('<%=GetLocalResourceObject("TEXT_SCHEDULE_MINUTES")%>', record.data.interval);
        break;
      case "manual":
        StrScheduleName = '<%=GetLocalResourceObject("TEXT_SCHEDULE_MANUAL")%>';
        break;
      }

      var link = "<a href='/MetraNet/MetraControl/ScheduledAdapters/RecurrencePattern.aspx?EventID=" +
                  record.data.eventid + "&amp;ScheduleName=" + StrScheduleName + "&amp;AdapterName=" + record.data.displayname + "'>" + StrScheduleName + "</a>";
      return link;
    }

    function NextRunRenderer(value, meta, record, rowIndex, colIndex, store) {
      var nextRunText;
      var isPaused;

      if (record.data.ispaused == null) {
        isPaused = "N";
      } else
        isPaused = record.data.ispaused;
      if (isPaused == "N") {
        if (record.data.overridedate == null) {
          nextRunText = '<%=GetLocalResourceObject("TEXT_ON_SCHEDULE")%>';
        } else
          nextRunText = record.data.overridedate;
      } else
        nextRunText = '<%=GetLocalResourceObject("TEXT_PAUSED")%>';

      var nextRunLink = String.format("/MetraNet/MetraControl/ScheduledAdapters/OverrideSchedule.aspx?EventID={0}&ScheduleName={1}&AdapterName={2}", record.data.eventid, StrScheduleName, record.data.displayname);
      var link = String.format("<a href='{0}'>{1}</a>", nextRunLink, nextRunText);

      return link;
    }
    
    function DisplayNameRenderer(value, meta, record) {
      var displayNameText = String.format("<img src='/Res/Images/adapter_scheduled.gif' align='absmiddle' border='0'><b>{0}</b>", record.data.displayname);
      var displayNameLink = String.format("ScheduledAdaptersInstanceList.aspx?ID={0}&AdapterName={1}", record.data.eventid, encodeURIComponent(btoa(displayNameText)));
      var link = String.format("<a href=\"{0}\">{1}</a>", displayNameLink, displayNameText);
      return link;
    }
    
    function DescriptionRenderer(value, meta, record) {
      return record.data.description;
    }

    function getCorrectTime(time) {
      var d = new Date("01/01/2001, " + time);
      var res = d.toLocaleTimeString(CURRENT_LOCALE, "hh:mm:ss");

      return res;
    }

    //Getting localize week days
    function getCorrectWeekDay(enWeekDays) {
      
      var dayList = enWeekDays.split(',');
      var res = "";
      for (var i = 0; i < dayList.length; i++) {
        
        var d = new Date("01/01/2001");
        
        //looking for a match of the day in en-US culture                                                     
        for (var j = 0; j < 7; j++) {
          //if match found exit the loop 
          if (d.toLocaleString("en-US", { weekday: 'short' }).localeCompare(dayList[i].replace(" ", "")) == 0) {
            break;
          }
          d.setDate(d.getDate() + 1);
        }
        //if we have several day we separated by commas
        if (res.length > 1) res += ',';
        //localize week day
        res += d.toLocaleString(CURRENT_LOCALE, { weekday: 'short' });
      }
      return res;
    }

     function getLocaleWeekDay(weekDay) {
      var d = new Date("01/01/2001");
        
        //looking for a match of the day in en-US culture                                                     
        for (var j = 0; j < 7; j++) {
          //if match found exit the loop 
          if (d.toLocaleString("en-US", { weekday: 'long' }).localeCompare(weekDay.replace(" ", "")) == 0) {
            break;
          }
          d.setDate(d.getDate() + 1);
        }
      
      return d.toLocaleString(CURRENT_LOCALE, { weekday: 'long' });
    }


    function getCorrectMonthlyDay(enMonthlyDays) {
      var dayOfMonthList = enMonthlyDays.split(',');
      var res = "";
      
      for (var i = 0; i < dayOfMonthList.length; i++) {
        var strDay = dayOfMonthList[i].trim().split(' ');
        if (res.length > 1) res += ", ";
        if (strDay.length > 1) {
          res += window["TEXT_" + strDay[0].toUpperCase()];
          res += " " + getLocaleWeekDay(strDay[1]);
        } else {
          res += dayOfMonthList[i];
        }
      }
      
      return res;
    }

  </script>
</asp:Content>
