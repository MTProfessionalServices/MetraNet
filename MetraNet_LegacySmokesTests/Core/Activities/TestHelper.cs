using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.ComponentModel;
using System.Workflow.Runtime;
using System.Workflow.Runtime.Hosting;

namespace MetraTech.Core.Activities.Test
{
  /// <summary>
  ///   Helper class
  /// </summary>
  public class TestHelper
  {
    /// <summary>
    ///    Run the given activity with the given arguments.
    /// </summary>
    /// <typeparam name="ACTIVITY"></typeparam>
    /// <param name="namedArgumentValues"></param>
    /// <returns></returns>
    public static bool RunActivity<ACTIVITY>(Dictionary<string, object> namedArgumentValues)
                                             where ACTIVITY : Activity
    {
      using (WorkflowRuntime workflowRuntime = new WorkflowRuntime())
      {
        ManualWorkflowSchedulerService 
          manualWorkflowSchedulerService = new ManualWorkflowSchedulerService();

        workflowRuntime.AddService(manualWorkflowSchedulerService);

        WorkflowInstance workflowInstance = 
          workflowRuntime.CreateWorkflow(typeof(ACTIVITY), namedArgumentValues);

        workflowInstance.Start();

        return (manualWorkflowSchedulerService.RunWorkflow(workflowInstance.InstanceId));
      }
    }
  }
}
