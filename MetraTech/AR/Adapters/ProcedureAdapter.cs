using System;
using System.Xml;
using System.Diagnostics;
using System.Collections;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;

namespace MetraTech.AR.Adapters
{
	/// <summary>
  /// Runs an A/R procedure, such as ApplyCredits or RunAging.
  /// 
  /// Dependencies:
  /// This adapter should be run after payments, adjustments, and invoices have been exported.
  ///
  /// Back out:
  /// Back out is not supported.

	/// </summary>
  public class ProcedureAdapter : MetraTech.UsageServer.IRecurringEventAdapter
  {
    // data
    private Logger mLogger = new Logger("[ARProcAdapter]");
    private string mARMethod;
    private object mARConfigState;

    // adapter capabilities
    public bool SupportsScheduledEvents     { get { return true; }}
    public bool SupportsEndOfPeriodEvents   { get { return true; }}
    public ReverseMode Reversibility        { get { return ReverseMode.NotNeeded; }}
    public bool AllowMultipleInstances      { get { return false; }}

    public ProcedureAdapter()
    {
    }

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      if (limitedInit)
      {
        mLogger.LogDebug("Intializing adapter (limited)");
      }
      else
      {
        mLogger.LogDebug("Intializing Adapter");

        ReadConfig (configFile); 

        //configure ARInterface
        IMTARConfig ARConfig = new MTARConfigClass();
        mARConfigState = ARConfig.Configure("");
      }
    }

    public string Execute(IRecurringEventRunContext context)
    {
			string detail;
      mLogger.LogDebug("executing ProcedureAdapter in context: {0}",  context);

      switch(mARMethod)
      {
        case "ApplyCredits":
          ApplyCredits();
          break;

        case "RunAging":
          RunAging();
          break;

        default:
          throw new ARException("Invalid method. Only 'ApplyCredits' and 'RunAging' are supported.");
      }

      detail = "";
			
			return detail;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      throw new ARException("not implemented");
    }

    public void Shutdown()
    {
    }


    private void ReadConfig(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      mARMethod = doc.GetNodeValueAsString("//Method");
    }

    private void ApplyCredits()
    {
      mLogger.LogDebug("Applying Credits");

      IMTARWriter writer = new MTARWriterClass();
      writer.ApplyCredits(mARConfigState);
    }

    private void RunAging()
    {
      ArrayList arrAccountNameSpaces = ARConfiguration.GetInstance().AccountNameSpaces;
      string    sAccountNameSpace;

      for (int i = 0; i < arrAccountNameSpaces.Count; i++)
      {
        sAccountNameSpace = arrAccountNameSpaces[i].ToString();

        mLogger.LogDebug("Running Aging for {0}", sAccountNameSpace);

        //construct a doc to pass in MetraTime
        MTXmlDocument doc = new MTXmlDocument();

        doc.LoadXml(@"
        <ARDocuments ExtNamespace='" + sAccountNameSpace + @"'>" + @"
          <ARDocument>
            <RunAging>
              <AgingDate/>
            </RunAging>
          </ARDocument>
        </ARDocuments>");

        doc.SetNodeValue("//AgingDate", MetraTech.MetraTime.Now);

        //call the interface
        IMTARWriter writer = new MTARWriterClass();
        writer.RunAging(doc.OuterXml, mARConfigState);
      }
    }
  }
}
