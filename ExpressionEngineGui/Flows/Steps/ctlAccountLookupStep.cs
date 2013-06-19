using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlAccountLookupStep : ctlBaseStep
    {
        #region Properties
        private ExpressionStep Step { get { return (ExpressionStep)_step; } }
        #endregion

        #region Constructor
        public ctlAccountLookupStep()
        {
            InitializeComponent();
        }
        #endregion
    }
}
