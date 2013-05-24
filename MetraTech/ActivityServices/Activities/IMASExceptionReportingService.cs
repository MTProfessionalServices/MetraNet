using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Activities;

namespace MetraTech.ActivityServices.Activities
{
  [ExternalDataExchange]
  public interface IMASExceptionReportingService
  {
    void ReportException(Guid workflowId, Exception error);
  }
}
