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



public partial class AjaxServices_MetraOfferDashboardService : MTListServicePage
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
      //var random = new Random ();
	  
      //var queues = string.Format("{{\"x\":{0},\"t_message\":{1},\"rabbitmq\":{2},\"scheduler\":{3}}}", id, random.Next(1000), random.Next(1000), random.Next(1000));
      //var backlog = string.Format("{{\"x\":{0},\"pipeline_backlog\":{1},\"pipeline\":{2},\"rabbitmq\":{3},\"ramp_backlog\":{4},\"ramp\":{5}}}", id, random.Next(1000), random.Next(1000), random.Next(1000), random.Next(1000), random.Next(1000));
      //var tps = string.Format("{{\"x\":{0},\"pipeline\":{1},\"rabbitmq\":{2},\"ramp_usage\":{3},\"ramp_scheduler\":{4}}}", id, random.Next(1000), random.Next(1000), random.Next(1000), random.Next(1000));
	  
      //Logger.LogFatal("queues: " + queues);
      //Logger.LogFatal("backlog: " + backlog);
      //Logger.LogFatal("tps: " + tps);
	  
      //var res = string.Format ("{{\"queues\":[{0}],\"backlog\":[{1}],\"tps\":[{2}]}}", queues, backlog, tps );
      //Logger.LogFatal("res: " + res);

      //Response.Write ( res );

        Response.Write(@"[
        { ""productOfferingName"": ""Adobe Connect Monthly Fee"",
          ""productOfferingId"": 23473,
          ""currentMRR"": 104096.87,
          ""lastMRR"": 80000,
          ""changeMRR"": 20000,
          ""changePercent"": 20
        },
        { ""productOfferingName"": ""Monthly Service Fee"",
          ""productOfferingId"": 23473,
          ""currentMRR"": 14932.53,
          ""lastMRR"": 80000,
          ""changeMRR"": 20000,
          ""changePercent"": 20
        },
        { ""productOfferingName"": ""RCPlus Pack100K 2YR"",
          ""productOfferingId"": 23473,
          ""currentMRR"": 10830.00,
          ""lastMRR"": 80000,
          ""changeMRR"": 20000,
          ""changePercent"": 20
        }
       ]");

      Response.End ();
	}

  }

}
