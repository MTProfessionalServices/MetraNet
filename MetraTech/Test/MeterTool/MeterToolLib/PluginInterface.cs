using System;

namespace MetraTech.Test.MeterTool.MeterToolLib
{
  /// <summary>
  /// Generic plugin interface
  /// </summary>
  public interface IPlugin
  {
    string Run(MTMeterProp prop);
    string Name{get;set;}
    IPluginHost Host{get;set;}
  }

  /// <summary>
  /// The host
  /// </summary>
  public interface IPluginHost
  {
    bool Register(IPlugin ipi);
  }

}
