using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Activities;

namespace MetraTech.ActivityServices.Activities
{
  [ExternalDataExchange]
  public interface IMASLoggingService
  {
    //
    // FATAL
    // 
    void LogFatal(string str);

    //
    // ERROR
    //
    void LogError(string str);

    //
    // WARNING
    //
    void LogWarning(string str);

    //
    // INFO
    //
    void LogInfo(string str);

    //
    // DEBUG
    //
    bool WillLogDebug
    { get; }

    void LogDebug(string str);


    void LogException(string str, Exception e);
  }
}
