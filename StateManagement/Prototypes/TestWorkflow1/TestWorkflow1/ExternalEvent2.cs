using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Activities;

namespace TestWorkflow1
{
  [Serializable]
	public class ExternalEvent2Args : ExternalDataEventArgs
	{
    private Guid m_Guid;
    private string m_Text;

    public ExternalEvent2Args(Guid guid, string text) : base(guid)
    {
      m_Guid = guid;
      m_Text = text;
    }

    public Guid Guid
    {
      get { return m_Guid; }
      set { m_Guid = value; }
    }

    public string Text
    {
      get { return m_Text; }
      set { m_Text = value; }
    }
	}

  [ExternalDataExchange]
  public interface IExternalEvent2
  {
    void FireEvent(Guid guid, string text);

    event EventHandler<ExternalEvent2Args> EventFired;
  }


  public class ExternalEvent2Service : IExternalEvent2
  {
    public ExternalEvent2Service() { }

    public void FireEvent(Guid guid, string text)
    {
    }

    private event EventHandler<ExternalEvent2Args> newEvent;

    public event EventHandler<ExternalEvent2Args> EventFired
    {
      add { newEvent += value; }
      remove { newEvent -= value; }
    }

    public void SendEvent(string msg)
    {
      newEvent(null, new ExternalEvent2Args(Program.instanceid, msg));
    }
  }
}
