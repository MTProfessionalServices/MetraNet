using System.Collections.Generic;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class StepInfo
    {
        public static Dictionary<StepType, StepInfo> Items = new Dictionary<StepType, StepInfo>();

        #region Properties
        public StepType Type { get; private set; }
        public bool SupportsChildren { get; private set; }
        public string Description { get; private set; }
        #endregion

        #region Static Constructor
        static StepInfo()
        {
            Add(StepType.AccountLookup, false, "Looks up an Account");
            Add(StepType.Aggregate, false, "Aggregates a child property into a parent property.");
            Add(StepType.CalculateEventCharge, false, "Calculates all charges and accumulates them into the EventCharge");
            Add(StepType.Container, true, "A container which simpwlifies the flow");
            Add(StepType.Else, true, "Directs flow if the preceeding if and else if conditions aren't met"); 
            Add(StepType.ElseIf, true, "Directs flow if the condition is met");
            Add(StepType.Enforce, false, "Enforces default values.");
            Add(StepType.Expression, false, "Assigns an expression to to a property");
            Add(StepType.Function, false, "Executes the specified function");
            Add(StepType.If, true, "Directs flow if the condition is met");
            Add(StepType.Mtsql, false, "Provides an MTSQL script");
            Add(StepType.NewProperty, false, "Creates a new property");
            Add(StepType.ParameterTableLookup, false, "Looks up Parameter Table");
            Add(StepType.ProcessList, true, "Processes the children");
            Add(StepType.Query, false, "Runs a Query");
            Add(StepType.Start, true, "Starts a flow");
            Add(StepType.SubscriptionLookup, false, "Looks up a subscription to an offering");

        }
        private static void Add(StepType type, bool supportsChildren, string description)
        {
            Items.Add(type, new StepInfo(type, supportsChildren, description));
        }
        #endregion

        #region Constructor
        public StepInfo(StepType type, bool supportsChildren, string description)
        {
            Type = type;
            SupportsChildren = supportsChildren;
            Description = description;
        }
        #endregion
    }
}
