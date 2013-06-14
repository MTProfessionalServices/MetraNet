using System;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace PropertyGui.Flows.Steps
{
    public static class StepFactory
    {
        public static ctlFlowStepBase Create(FlowStepBase step)
        {
            ctlFlowStepBase control;
            switch (step.FlowStepType)
            {
                case FlowStepType.NewProperty:
                    control = new ctlNewPropertyStep();
                    break;
                case FlowStepType.Expression:
                    control = new ctlExpression();
                    break;
                default:
                    throw new ArgumentException("Unhandled type");
            }
            control.Init(step);
            return control;
        }
    }
}
