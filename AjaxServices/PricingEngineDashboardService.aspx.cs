using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.IO;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using EasyNetQ.Management.Client.Model;
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
  private DateTime last = DateTime.MinValue;
  private string resp = string.Empty;
  private object loadLock = new object();
  protected void Page_Load ( object sender, EventArgs e )
  {
    using ( new HighResolutionTimer ( "PricingEngineDashboardService", 5000 ) )
    {
      if ((MetraTech.MetraTime.Now - last).TotalSeconds > 5)
      {
        var msgCount = 0;
        decimal schedulerCount = 0;
        decimal pipelineWaitCount = 0;
        decimal pipelineWaitSeconds = 0;
        decimal pipelineSeconds = 0;
        try
        {
          var sads = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSetClass();
          var sc = sads.FindAndReturnObject("RabbitMQMessagingServer");
          var client = new EasyNetQ.Management.Client.ManagementClient("http://" + sc.ServerName, sc.UserName, sc.Password);
          msgCount = client.GetQueue("usage", new Vhost(){Name = "/"}).Messages;
        }
        catch (Exception ex)
        {
          Logger.LogWarning("Unable to connect to rabbitMQ", ex);
        }

        var random = new Random();

        using ( var conn = ConnectionManager.CreateConnection ( ) )
        {
          using ( var stmt = conn.CreateAdapterStatement ( @"RMP\Extensions\SystemConfig", @"__GET_PRICING_DASHBOARD_STATS__" ) )
          {
            using ( var rdr = stmt.ExecuteReader () )
            {
              while ( rdr.Read () )
              {
                if (rdr.GetString("c_category").Equals("pipeline_wait_count"))
                {
                  pipelineWaitCount = rdr.GetDecimal("c_count");
                }
                else if (rdr.GetString("c_category").Equals("scheduler_wait_count"))
                {
                  schedulerCount = rdr.GetDecimal("c_count");
                }
                else if (rdr.GetString("c_category").Equals("pipeline_wait_seconds"))
                {
                  pipelineWaitSeconds = rdr.GetDecimal("c_count");
                }
                else if (rdr.GetString("c_category").Equals("pipeline_seconds"))
                {
                  pipelineSeconds = rdr.GetDecimal("c_count");
                }
              }
            }
          }
        }

        var queues = string.Format("\"pipe_q\":{0},\"msgq_q\":{1},\"scheduler_q\":{2}", pipelineWaitCount, msgCount, schedulerCount);
        var backlog = string.Format("\"pipe_backlog\":{0},\"pipe\":{1}", pipelineWaitSeconds, pipelineSeconds);
        var tps = string.Format("\"pipe_tps\":{0},\"msgq_tps\":{1},\"ramp_tps\":{2},\"scheduler_tps\":{3}", 9 + random.Next(3), 8 + random.Next(3), 6 + random.Next(3), 6 + random.Next(3));

        var now = MetraTech.MetraTime.Now;
        var res = string.Format("{{\"Items\":[{{\"date\":\"{0}\",{1},{2},{3}}}]}}", now, queues, backlog, tps);
        last = now;
        resp = res;
      }

	  Response.Write ( resp );

      Response.End ();
	}

  }

}
