using System;
using System.Collections;
using System.IO;
using System.Xml;
using System.Runtime.InteropServices;

using MetraTech.Utils;
using MetraTech.Interop.MTPipelineLib;

namespace MetraTech.Pipeline.Plugins.Test
{
	/// <summary>
	/// Summary description for Plugin.
	/// </summary>
	public class Plugin
	{
    public Plugin(PluginTestLib pluginTestLib, IMTPipelinePlugIn pipelinePlugIn) 
    {
      this.pluginTestLib = pluginTestLib;
      this.pipelinePlugIn = pipelinePlugIn;
      this.sessionSet = pluginTestLib.CreateSessionSet();
    }

    public void Shutdown() 
    {
      pipelinePlugIn.Shutdown();
      Marshal.ReleaseComObject(pipelinePlugIn);
    }

    public void ProcessSessions() 
    {
      if (sessionSet == null || sessionSet.Count == 0) 
      {
        throw new ApplicationException("No sessions have been created");
      }
      
      pipelinePlugIn.ProcessSessions(sessionSet);
    }

    public void CreateSessionSet(string sessionData) 
    {
      if (sessionSet != null) 
      {
        Marshal.ReleaseComObject(sessionSet);
        sessionSet = null;
      }

      sessionSet = pluginTestLib.CreateSessionSet(sessionData);
    }

    public PluginSession CreateSession() 
    {
      PluginSession pluginSession = null;

      IMTSession session = pluginTestLib.CreateSession(sessionSet);

      pluginSession = new PluginSession(this, session);

      return pluginSession;
    }

    public PluginTestLib PluginTestLib 
    {
      get 
      {
        return pluginTestLib;
      }
    }

    // Data
    private PluginTestLib pluginTestLib;
    private IMTPipelinePlugIn pipelinePlugIn;
    private IMTSessionSet sessionSet;
	}

  public class PluginSession
  {
    public PluginSession(Plugin plugin, IMTSession session) 
    {
      this.plugin = plugin;
      this.session = session;
    }

    public void SetProperty(string name, 
                            object propertyValue, 
                            PropertyType propertyType) 
    {
      plugin.PluginTestLib.SetSessionProperty
        (session, name, propertyValue, propertyType);
    }

    public object GetProperty(string name,
                              PropertyType propertyType)
    {
      return plugin.PluginTestLib.GetSessionProperty(session, name, propertyType);
    }

    // Data
    private Plugin plugin;
    private IMTSession session;
  }
}
