using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlNewPropertyStep : ctlFlowStepBase
    {
        #region Properties
        private NewPropertyStep PropertyStep { get { return (NewPropertyStep) Step; } }
        #endregion

        #region Constructor
        public ctlNewPropertyStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(FlowStepBase step)
        {
            base.Init(step);
            ctlProperty.Init(step.Flow.Context, new ProductViewEntity(null, null, null));
        }

        public override void SyncToForm()
        {
            ctlProperty.SyncToForm(PropertyStep.Property);
        }
        #endregion
    }
}
