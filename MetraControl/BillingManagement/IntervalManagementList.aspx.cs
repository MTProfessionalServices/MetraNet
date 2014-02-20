using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class MetraControl_BillingManagement_IntervalManagementList : MTPage
{
    
    protected void Page_Load(object sender, EventArgs e)
    {
      //string statusFilterValue = Request["Intervals"];

      //if (!String.IsNullOrEmpty(statusFilterValue))
      //{
      //  switch (statusFilterValue)
      //  {
      //    case "Active":
      //      SetGridFilterByColumnValue(IntervalListGrid, "DBStatus", "O");
      //      break;
      //    case "Billable":
      //      SetGridFilterByColumnValue(IntervalListGrid, "DBStatus", "B");
      //      break;
      //    case "Completed":
      //      SetGridFilterByColumnValue(IntervalListGrid, "DBStatus", "H");
      //      break;

       // }

     // }
    }


    protected void SetGridFilterByColumnValue(MTFilterGrid grid, string columnId, string filterValue)
    {
  
      if (grid == null || string.IsNullOrEmpty(columnId) || string.IsNullOrEmpty(filterValue))
        return;

      MTGridDataElement el = grid.FindElementByID(columnId);
      if (el == null)
      {
        Session[Constants.ERROR] = String.Format("FilterField with id '{0}' not found.", columnId);
      }
      else
      {
        el.ElementValue = filterValue;
      }
    }

}