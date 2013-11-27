using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Messages
{
  [Serializable]
  public class SimulatorDesiredOutcome
  {
    public SimulatorOutcome DesiredResult { get; set; }
    public int TimeToProcessInMilliSeconds { get; set; }

    public SimulatorDesiredOutcome()
    {
      DesiredResult = SimulatorOutcome.Succeed;
      TimeToProcessInMilliSeconds = 0;
    }
  }

  [Serializable]
  public enum SimulatorOutcome
  {
    Succeed,
    Fail,
    ThrowException,
    TakeMessageButDoNotDoAnything
  }
}
