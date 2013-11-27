using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;

namespace TestWorkflow1
{
	public sealed partial class Workflow1: StateMachineWorkflowActivity
	{
		public Workflow1()
		{
			InitializeComponent();
		}

    private string m_Msg1;
    private void handleExternalEventActivity1_Invoked(object sender, ExternalDataEventArgs e)
    {
      ExternalEvent1Args e1 = (ExternalEvent1Args)e;
      m_Msg1 = e1.Text;

      Console.WriteLine("in HandleExternalEventActivity1.Invoked");
    }

    private void codeActivity1_ExecuteCode(object sender, EventArgs e)
    {
      Console.WriteLine("Entered Initial State");
    }

    private void codeActivity2_ExecuteCode(object sender, EventArgs e)
    {
      Console.WriteLine("Entered State 1");
    }

    private void codeActivity3_ExecuteCode(object sender, EventArgs e)
    {
      Console.WriteLine("Handling event 1");

      System.Threading.Thread.Sleep(2000);

      Console.WriteLine("Event text is: {0}", m_Msg1);
    }

    private void codeActivity4_ExecuteCode(object sender, EventArgs e)
    {
      Console.WriteLine("Handling event 2");

      System.Threading.Thread.Sleep(2000);

      Console.WriteLine("Event text is: {0}", m_Msg2);
    }

    private void codeActivity5_ExecuteCode(object sender, EventArgs e)
    {
      Console.WriteLine("Entered State 2");
    }

    private string m_Msg2;
    private void handleExternalEventActivity2_Invoked(object sender, ExternalDataEventArgs e)
    {
      ExternalEvent2Args e2 = (ExternalEvent2Args)e;
      m_Msg2 = e2.Text;

      Console.WriteLine("in HandleExternalEventActivity2.Invoked");
    }
	}

}
