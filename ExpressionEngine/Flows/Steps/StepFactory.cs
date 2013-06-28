using System;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.Flows.Steps;

namespace MetraTech.ExpressionEngine.Flows
{
    public static class StepFactory
    {
        public static BaseStep Create(StepType stepType, BaseFlow flow)
        {
            switch (stepType)
            {
                case StepType.AccountLookup:
                    return new AccountLookupStep(flow);
                case StepType.Aggregate:
                    return new AggregationStep(flow);
                case StepType.CalculateEventCharge:
                    return new CalculateEventChargeStep(flow);
                case StepType.Container:
                    return new ContainerStep(flow);
                case StepType.Else:
                    return new ElseStep(flow);
                case StepType.ElseIf:
                    return new ElseIfStep(flow);
                case StepType.Enforce:
                    return new EnforceStep(flow);
                case StepType.Expression:
                    return new ExpressionStep(flow);
                case StepType.Function:
                    return new FunctionStep(flow);
                case StepType.If:
                    return new IfStep(flow);
                case StepType.Mtsql:
                    return new MtsqlStep(flow);
                case StepType.NewProperty:
                    return new NewPropertyStep(flow);
                case StepType.ParameterTableLookup:
                    return new ParameterTableLookupStep(flow);
                case StepType.ProcessList:
                    return new ProcessChildrenStep(flow);
                case StepType.SubscriptionLookup:
                    return new SubscriptionLookupStep(flow);
                case StepType.Query:
                    return new QueryStep(flow);
                default:
                    throw new ArgumentException("unhandled stepType");
            }
        }
    }
}
