using MetraTech.ExpressionEngine.Mvm.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class AggregateItem
    {
        #region properties
        public string TargetProperty { get; set; }
        public AggregateAction Action { get; set; }
        public string SourceProperty { get; set; }
        public string Filter { get; set; }
        #endregion
    }
}
