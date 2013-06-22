using System;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.Flows.Steps;

namespace MetraTech.ExpressionEngine.Flows
{
    public static class StepFactory
    {
        public static BaseStep Create(StepType flowItemType, BaseFlow flow)
        {
            switch (flowItemType)
            {
                case StepType.AccountLookup:
                    return new AccountLookupStep(flow);
                case StepType.Aggregate:
                    return new AggregationStep(flow);
                case StepType.CalculateEventCharge:
                    return new CalculateEventChargeStep(flow);
                case StepType.Expression:
                    return new ExpressionStep(flow);
                case StepType.Mtsql:
                    return new MtsqlStep(flow);
                case StepType.NewProperty:
                    return new NewPropertyStep(flow);
                case StepType.ParameterTableLookup:
                    return new ParameterTableLookupStep(flow);
                case StepType.Query:
                    return new QueryStep(flow);
                default:
                    throw new ArgumentException("unhandled flowItemType");
            }
        }
    }
}
