using System;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public static class StepFactory
    {
        public static BaseStep Create(StepType flowItemType, BaseFlow flow)
        {
            switch (flowItemType)
            {
                default:
                    throw new ArgumentException("unhandled flowItemType");
            }
        }
    }
}
