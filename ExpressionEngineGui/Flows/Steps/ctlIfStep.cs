using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlIfStep : ctlBaseStep
    {
        #region Properties
        private IfStep Step { get { return (IfStep) _step; } }
        #endregion

        #region Constructor
        public ctlIfStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, Context context)
        {
            base.Init(step, context);
            ctlExpression.Init(context, null);
        }

        public override void SyncToForm()
        {
            ctlExpression.Text = Step.Expression;
        }

        public override void SyncToObject()
        {
            Step.Expression = ctlExpression.Text;
        }
        #endregion
    }
}
