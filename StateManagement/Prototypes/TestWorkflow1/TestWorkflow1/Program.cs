#region Using directives

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Workflow.Runtime;
using System.Workflow.Runtime.Hosting;
using System.Workflow.Activities;

#endregion

namespace TestWorkflow1
{
    class Program
    {
      static public Guid instanceid;
      static ExternalEvent1Service svc1 = new ExternalEvent1Service();
      static ExternalEvent2Service svc2 = new ExternalEvent2Service();

        static void Main(string[] args)
        {
            using(WorkflowRuntime workflowRuntime = new WorkflowRuntime())
            {
                AutoResetEvent waitHandle = new AutoResetEvent(false);
                workflowRuntime.WorkflowCompleted += delegate(object sender, WorkflowCompletedEventArgs e) {waitHandle.Set();};
                workflowRuntime.WorkflowTerminated += delegate(object sender, WorkflowTerminatedEventArgs e)
                {
                    Console.WriteLine(e.Exception.Message);
                    waitHandle.Set();
                };

                ExternalDataExchangeService exSvc = new ExternalDataExchangeService();

                workflowRuntime.AddService(exSvc);

                exSvc.AddService(svc1);
                exSvc.AddService(svc2);

                WorkflowInstance instance = workflowRuntime.CreateWorkflow(typeof(TestWorkflow1.Workflow1));
              
                instanceid = instance.InstanceId;
                
                instance.Start();

                Thread.Sleep(500);
                svc1.SendEvent("This is a test of event 1");
                svc2.SendEvent("This is a test of event 2");

                waitHandle.WaitOne();
            }
        }
    }
}
