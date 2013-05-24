using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Activities;

namespace MetraTech.ActivityServices.Activities
{
  [ExternalDataExchange]
  public interface IMTMASCallService
  {
    void InvokeMASMethod(string fullTypeName, string methodName, ref Dictionary<string, object> inputsOutputs);
  }
}
