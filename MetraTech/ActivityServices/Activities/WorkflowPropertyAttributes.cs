using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.ActivityServices.Activities
{
  [AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
  public class EventInputArgAttribute : Attribute
  {
    private string m_EventName;

    public EventInputArgAttribute(string eventName)
    {
      m_EventName = eventName;
    }

    public string EventName
    {
      get { return m_EventName; }
    }
  }

  [AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
  public class EventOutputArgAttribute : Attribute
  {
    private string m_EventName;

    public EventOutputArgAttribute(string eventName)
    {
      m_EventName = eventName;
    }

    public string EventName
    {
      get { return m_EventName; }
    }
  }

  [AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
  public class InputAttribute : Attribute
  {
    public InputAttribute()
    {
    }
  }

  [AttributeUsage(AttributeTargets.Property, AllowMultiple = false)]
  public class OutputAttribute : Attribute
  {
    public OutputAttribute()
    {
    }
  }

  [AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
  public class StateInitOutputAttribute : Attribute
  {
    private string m_StateName;

    public StateInitOutputAttribute(string stateName)
    {
      m_StateName = stateName;
    }

    public string StateName
    {
      get { return m_StateName; }
    }
  }
}
