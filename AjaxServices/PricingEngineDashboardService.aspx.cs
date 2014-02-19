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
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;
using System.Web.Script.Serialization;
using MetraTech.ActivityServices.Common;
using System.Collections.Generic;
using MetraTech.DataAccess;
using System.Text;



public partial class AjaxServices_PricingEngineDashboardService : MTListServicePage
{
    private static int id = 0;
  protected void Page_Load ( object sender, EventArgs e )
  {
      id++;
    using ( new HighResolutionTimer ( "PricingEngineDashboardService", 5000 ) )
    {
/*      using ( var conn = ConnectionManager.CreateConnection ( ) )
      {
        using ( var stmt = conn.CreateAdapterStatement ( "MetraControlDashboard", "__DASHBOARD_GET_QUEUES__" ) )
        {
          using ( var rdr = stmt.ExecuteReader () )
          {
            var decisions = new Dictionary<string, DecisionInstance> ();
            while ( rdr.Read () )
            {
            }
          }
        }
	  }
		*/
      var random = new Random ();
	  
	  var queues = string.Format("\"pipe_q\":{0},\"msgq_q\":{1},\"scheduler_q\":{2}", 9 +  random.Next(3), 8 +  random.Next(3), 6 +  random.Next(3));
	  var backlog = string.Format("\"pipe_backlog\":{0},\"pipe\":{1},\"msgq\":{2},\"ramp_backlog\":{3},\"ramp\":{4}", 9 +  random.Next(3), 8 +  random.Next(3), 6 +  random.Next(3), 6 +  random.Next(3), 6 +  random.Next(3));
	  var tps = string.Format("\"pipe_tps\":{0},\"msgq_tps\":{1},\"ramp_tps\":{2},\"scheduler_tps\":{3}", 9 +  random.Next(3), 8 +  random.Next(3), 6 +  random.Next(3), 6 +  random.Next(3));
	  
	  var res = string.Format ("{{\"Items\":[{{\"date\":\"{0}\",{1},{2},{3}}}]}}", DateTime.Now, queues, backlog, tps );
      Logger.LogFatal("res: " + res);

	  Response.Write ( res );

      Response.End ();
	}

  }

}
