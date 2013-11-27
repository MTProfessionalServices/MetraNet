using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;
using System.Threading;
using System.Collections.Generic;
using System.Text;
using System.Globalization;

public partial class AjaxServices_RecurrencePatternSvc : MTListServicePage
{
   
    ArrayList monthlyPatternList = new ArrayList();
    ArrayList daysList = new ArrayList();
    ArrayList tmpList = new ArrayList();

    protected void Page_Load(object sender, EventArgs e)
    {      
        using (new HighResolutionTimer("WeekDaysSvcAjax", 5000))
        {
          string recPattern = Request.QueryString["RecurPattern"].ToString();

          string strSunday = GetLocalResourceObject("Sunday_Text").ToString();
          string strMonday = GetLocalResourceObject("Monday_Text").ToString();
          string strTuesday = GetLocalResourceObject("Tuesday_Text").ToString();
          string strWednesday = GetLocalResourceObject("Wednesday_Text").ToString();
          string strThursday = GetLocalResourceObject("Thursday_Text").ToString();
          string strFriday = GetLocalResourceObject("Friday_Text").ToString();
          string strSaturday = GetLocalResourceObject("Saturday_Text").ToString();
         
          daysList.Add(strSunday);
          daysList.Add(strMonday);
          daysList.Add(strTuesday);
          daysList.Add(strWednesday);
          daysList.Add(strThursday);
          daysList.Add(strFriday);
          daysList.Add(strSaturday);
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
        StringBuilder json = new StringBuilder();
        json.Append("{ Items:[");
        for (int i = 0; i < 7; i++)
        {
          json.Append("{\'id\':\"");
          json.Append(daysList[i].ToString().Substring(0,3));
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
        string strDay = GetLocalResourceObject("Day_Text").ToString();
        monthlyPatternList.Add(strDay);

        ArrayList ordinalList = new ArrayList();
        string strFirst = GetLocalResourceObject("First_Text").ToString();
        string strSecond = GetLocalResourceObject("Second_Text").ToString();
        string strThird = GetLocalResourceObject("Third_Text").ToString();
        string strFourth = GetLocalResourceObject("Fourth_Text").ToString();
        string strLast = GetLocalResourceObject("Last_Text").ToString();
        ordinalList.Add(strFirst);
        ordinalList.Add(strSecond);
        ordinalList.Add(strThird);
        ordinalList.Add(strFourth);
        ordinalList.Add(strLast);

        int i;
        StringBuilder json = new StringBuilder();
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
            tmpList.Add(ordinalList[m].ToString() + " " +  monthlyPatternList[n].ToString());
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
