using System;
using System.Collections;
using MetraTech.UI.Common;
using MetraTech.Debug.Diagnostics;
using System.Text;
using System.Globalization;

public partial class AjaxServices_RecurrencePatternSvc : MTListServicePage
{
  readonly ArrayList monthlyPatternList = new ArrayList();
  readonly ArrayList daysList = new ArrayList();
  readonly ArrayList shortDaysList = new ArrayList();
  readonly ArrayList tmpList = new ArrayList();

  protected void Page_Load(object sender, EventArgs e)
  {
    using (new HighResolutionTimer("WeekDaysSvcAjax", 5000))
    {
      string recPattern = Request.QueryString["RecurPattern"];
      daysList.AddRange(CultureInfo.CurrentCulture.DateTimeFormat.DayNames);
      shortDaysList.AddRange(CultureInfo.CurrentCulture.DateTimeFormat.AbbreviatedDayNames);
      monthlyPatternList.AddRange(daysList);

      if (recPattern == "weekly")
      {
        getWeekDaysJson();
      }
      else if (recPattern == "monthly")
      {
        getMonthlyPatternJson();
      }
    }
  }

  protected void getWeekDaysJson()
  {
    try
    {
      var json = new StringBuilder();
      json.Append("{ Items:[");
      for (int i = 0; i < 7; i++)
      {
        json.Append("{\'id\':\"");
        json.Append(shortDaysList[i]);
        json.Append("\",");
        json.Append("\'day\':\"");
        json.Append(daysList[i]);
        json.Append("\"}");
        if (i <= 5)
        {
          json.Append(",");
        }
      }
      json.Append("]");
      json.Append("}");

      Response.Write(json.ToString());
    }
    catch (Exception ex)
    {
      Logger.LogException("An exception occurred.", ex);
    }
    finally
    {
      Response.End();
    }
  }

  protected void getMonthlyPatternJson()
  {
    try
    {
      var strDay = GetLocalResourceObject("Day_Text").ToString();
      monthlyPatternList.Add(strDay);

      var ordinalList = new ArrayList();
      var strFirst = GetLocalResourceObject("First_Text").ToString();
      var strSecond = GetLocalResourceObject("Second_Text").ToString();
      var strThird = GetLocalResourceObject("Third_Text").ToString();
      var strFourth = GetLocalResourceObject("Fourth_Text").ToString();
      var strLast = GetLocalResourceObject("Last_Text").ToString();
      ordinalList.Add(strFirst);
      ordinalList.Add(strSecond);
      ordinalList.Add(strThird);
      ordinalList.Add(strFourth);
      ordinalList.Add(strLast);

      int i;
      var json = new StringBuilder();
      json.Append("{ Items:[");
      for (i = 1; i <= 31; i++)
      {
        json.Append("{\'id\':");
        json.Append(i);
        json.Append(",");
        json.Append("\'pattern\':\"");
        json.Append(i);
        json.Append("\"}");
        json.Append(",");
      }

      for (int m = 0; m <= ordinalList.Count - 1; m++)
      {
        for (int n = 0; n <= monthlyPatternList.Count - 1; n++)
        {
          tmpList.Add(ordinalList[m] + " " + monthlyPatternList[n]);
        }
      }

      tmpList.Remove(strFirst + " " + strDay);
      tmpList.Remove(strSecond + " " + strDay);
      tmpList.Remove(strThird + " " + strDay);
      tmpList.Remove(strFourth + " " + strDay);

      for (int j = 0; j <= tmpList.Count - 1; j++)
      {
        i++;
        json.Append("{\'id\':\"");
        json.Append(tmpList[j]);
        json.Append("\",");
        json.Append("\'pattern\':\"");
        json.Append(tmpList[j]);
        json.Append("\"}");
        if (i < 68)
        {
          json.Append(",");
        }
      }

      json.Append("]");
      json.Append("}");

      Response.Write(json.ToString());
    }
    catch (Exception ex)
    {
      Logger.LogException("An exception occurred.", ex);
    }
    finally
    {
      Response.End();
    }
  }
}
