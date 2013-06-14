using System;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public static class FlowStepFactory
    {
        public static FlowStepBase Create(FlowStepType flowItemType, Flow flow)
        {
            switch (flowItemType)
            {
                case FlowStepType.Meter:
                    return new MeterStep(flow);
                default:
                    throw new ArgumentException("unhandled flowItemType");
            }
        }
    }
}
