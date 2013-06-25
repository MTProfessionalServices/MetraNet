using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlEnforce : ctlBaseStep
    {
        #region Properties
        private EnforceStep Step { get { return (EnforceStep)_step; } }
        #endregion

        #region Constructor
        public ctlEnforce()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, Context context)
        {
            base.Init(step, context);
            ctlProperty.Init(Step.AvailableProperties, TypeFactory.CreateAny());
        }

        public override void SyncToForm()
        {
            ctlProperty.Text = Step.PropertyName;
            ctlDefaultExpression.Text = Step.DefaultExpression;
        }

        public override void SyncToObject()
        {
            Step.PropertyName = ctlProperty.Text;
            Step.DefaultExpression = ctlDefaultExpression.Text;
        }
        #endregion
    }
}
