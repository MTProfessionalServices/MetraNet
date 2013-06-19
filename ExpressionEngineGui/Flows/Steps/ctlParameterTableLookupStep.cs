using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlParameterTableLookupStep : ctlBaseStep
    {
        #region Properties
        private ParameterTableLookupStep Step { get { return (ParameterTableLookupStep)_step; } }
        #endregion

        #region Constructor
        public ctlParameterTableLookupStep()
        {
            InitializeComponent();
        }
        #endregion
    }
}
