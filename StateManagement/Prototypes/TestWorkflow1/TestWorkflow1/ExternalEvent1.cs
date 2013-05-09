using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Activities;

namespace TestWorkflow1
{
  [Serializable]
	public class ExternalEvent1Args : ExternalDataEventArgs
	{
    private Guid m_Guid;
    private string m_Text;

    public ExternalEvent1Args(Guid guid, string text) : base(guid)
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
  public interface IExternalEvent1
  {
    void FireEvent(Guid guid, string text);

    event EventHandler<ExternalEvent1Args> EventFired;
  }

  public class ExternalEvent1Service : IExternalEvent1
  {
    public ExternalEvent1Service() { }

    public void FireEvent(Guid guid, string text)
    {
    }

    private event EventHandler<ExternalEvent1Args> newEvent;

    public event EventHandler<ExternalEvent1Args> EventFired
    {
      add { newEvent += value; }
      remove { newEvent -= value; }
    }

    public void SendEvent(string msg)
    {
      newEvent(null, new ExternalEvent1Args(Program.instanceid, msg));
    }
  }
}
