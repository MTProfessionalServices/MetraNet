using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Reflection;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;

namespace TestWorkflow1
{
    partial class Workflow1
    {
		#region Designer generated code
        
        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCode]
        private void InitializeComponent()
        {
          this.CanModifyActivities = true;
          this.codeActivity5 = new System.Workflow.Activities.CodeActivity();
          this.codeActivity2 = new System.Workflow.Activities.CodeActivity();
          this.setStateActivity3 = new System.Workflow.Activities.SetStateActivity();
          this.codeActivity4 = new System.Workflow.Activities.CodeActivity();
          this.handleExternalEventActivity2 = new System.Workflow.Activities.HandleExternalEventActivity();
          this.setStateActivity1 = new System.Workflow.Activities.SetStateActivity();
          this.codeActivity3 = new System.Workflow.Activities.CodeActivity();
          this.handleExternalEventActivity1 = new System.Workflow.Activities.HandleExternalEventActivity();
          this.setStateActivity2 = new System.Workflow.Activities.SetStateActivity();
          this.codeActivity1 = new System.Workflow.Activities.CodeActivity();
          this.stateInitializationActivity3 = new System.Workflow.Activities.StateInitializationActivity();
          this.stateInitializationActivity2 = new System.Workflow.Activities.StateInitializationActivity();
          this.eventDrivenActivity2 = new System.Workflow.Activities.EventDrivenActivity();
          this.eventDrivenActivity1 = new System.Workflow.Activities.EventDrivenActivity();
          this.stateInitializationActivity1 = new System.Workflow.Activities.StateInitializationActivity();
          this.stateActivity2 = new System.Workflow.Activities.StateActivity();
          this.stateActivity1 = new System.Workflow.Activities.StateActivity();
          this.Workflow1InitialState = new System.Workflow.Activities.StateActivity();
          // 
          // codeActivity5
          // 
          this.codeActivity5.Name = "codeActivity5";
          this.codeActivity5.ExecuteCode += new System.EventHandler(this.codeActivity5_ExecuteCode);
          // 
          // codeActivity2
          // 
          this.codeActivity2.Name = "codeActivity2";
          this.codeActivity2.ExecuteCode += new System.EventHandler(this.codeActivity2_ExecuteCode);
          // 
          // setStateActivity3
          // 
          this.setStateActivity3.Name = "setStateActivity3";
          this.setStateActivity3.TargetStateName = "stateActivity1";
          // 
          // codeActivity4
          // 
          this.codeActivity4.Name = "codeActivity4";
          this.codeActivity4.ExecuteCode += new System.EventHandler(this.codeActivity4_ExecuteCode);
          // 
          // handleExternalEventActivity2
          // 
          this.handleExternalEventActivity2.EventName = "EventFired";
          this.handleExternalEventActivity2.InterfaceType = typeof(TestWorkflow1.IExternalEvent2);
          this.handleExternalEventActivity2.Name = "handleExternalEventActivity2";
          this.handleExternalEventActivity2.Invoked += new System.EventHandler<System.Workflow.Activities.ExternalDataEventArgs>(this.handleExternalEventActivity2_Invoked);
          // 
          // setStateActivity1
          // 
          this.setStateActivity1.Name = "setStateActivity1";
          this.setStateActivity1.TargetStateName = "stateActivity2";
          // 
          // codeActivity3
          // 
          this.codeActivity3.Name = "codeActivity3";
          this.codeActivity3.ExecuteCode += new System.EventHandler(this.codeActivity3_ExecuteCode);
          // 
          // handleExternalEventActivity1
          // 
          this.handleExternalEventActivity1.EventName = "EventFired";
          this.handleExternalEventActivity1.InterfaceType = typeof(TestWorkflow1.IExternalEvent1);
          this.handleExternalEventActivity1.Name = "handleExternalEventActivity1";
          this.handleExternalEventActivity1.Invoked += new System.EventHandler<System.Workflow.Activities.ExternalDataEventArgs>(this.handleExternalEventActivity1_Invoked);
          // 
          // setStateActivity2
          // 
          this.setStateActivity2.Name = "setStateActivity2";
          this.setStateActivity2.TargetStateName = "stateActivity1";
          // 
          // codeActivity1
          // 
          this.codeActivity1.Name = "codeActivity1";
          this.codeActivity1.ExecuteCode += new System.EventHandler(this.codeActivity1_ExecuteCode);
          // 
          // stateInitializationActivity3
          // 
          this.stateInitializationActivity3.Activities.Add(this.codeActivity5);
          this.stateInitializationActivity3.Name = "stateInitializationActivity3";
          // 
          // stateInitializationActivity2
          // 
          this.stateInitializationActivity2.Activities.Add(this.codeActivity2);
          this.stateInitializationActivity2.Name = "stateInitializationActivity2";
          // 
          // eventDrivenActivity2
          // 
          this.eventDrivenActivity2.Activities.Add(this.handleExternalEventActivity2);
          this.eventDrivenActivity2.Activities.Add(this.codeActivity4);
          this.eventDrivenActivity2.Activities.Add(this.setStateActivity3);
          this.eventDrivenActivity2.Name = "eventDrivenActivity2";
          // 
          // eventDrivenActivity1
          // 
          this.eventDrivenActivity1.Activities.Add(this.handleExternalEventActivity1);
          this.eventDrivenActivity1.Activities.Add(this.codeActivity3);
          this.eventDrivenActivity1.Activities.Add(this.setStateActivity1);
          this.eventDrivenActivity1.Name = "eventDrivenActivity1";
          // 
          // stateInitializationActivity1
          // 
          this.stateInitializationActivity1.Activities.Add(this.codeActivity1);
          this.stateInitializationActivity1.Activities.Add(this.setStateActivity2);
          this.stateInitializationActivity1.Name = "stateInitializationActivity1";
          // 
          // stateActivity2
          // 
          this.stateActivity2.Activities.Add(this.stateInitializationActivity3);
          this.stateActivity2.Name = "stateActivity2";
          // 
          // stateActivity1
          // 
          this.stateActivity1.Activities.Add(this.eventDrivenActivity1);
          this.stateActivity1.Activities.Add(this.eventDrivenActivity2);
          this.stateActivity1.Activities.Add(this.stateInitializationActivity2);
          this.stateActivity1.Name = "stateActivity1";
          // 
          // Workflow1InitialState
          // 
          this.Workflow1InitialState.Activities.Add(this.stateInitializationActivity1);
          this.Workflow1InitialState.Name = "Workflow1InitialState";
          // 
          // Workflow1
          // 
          this.Activities.Add(this.Workflow1InitialState);
          this.Activities.Add(this.stateActivity1);
          this.Activities.Add(this.stateActivity2);
          this.CompletedStateName = null;
          this.DynamicUpdateCondition = null;
          this.InitialStateName = "Workflow1InitialState";
          this.Name = "Workflow1";
          this.CanModifyActivities = false;

        }

        #endregion

      private SetStateActivity setStateActivity3;
      private SetStateActivity setStateActivity1;
      private SetStateActivity setStateActivity2;
      private EventDrivenActivity eventDrivenActivity2;
      private EventDrivenActivity eventDrivenActivity1;
      private StateInitializationActivity stateInitializationActivity1;
      private StateActivity stateActivity2;
      private StateActivity stateActivity1;
      private HandleExternalEventActivity handleExternalEventActivity1;
      private HandleExternalEventActivity handleExternalEventActivity2;
      private CodeActivity codeActivity1;
      private CodeActivity codeActivity2;
      private StateInitializationActivity stateInitializationActivity2;
      private CodeActivity codeActivity4;
      private CodeActivity codeActivity5;
      private StateInitializationActivity stateInitializationActivity3;
      private CodeActivity codeActivity3;
      private StateActivity Workflow1InitialState;



















      }
}
