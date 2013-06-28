using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlSubscriptionLookup : ctlBaseStep
    {
        #region Properties
        private SubscriptionLookupStep Step { get { return (SubscriptionLookupStep)_step; } }
        #endregion

        #region Constructor
        public ctlSubscriptionLookup()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, Context context)
        {
            base.Init(step, context);
        }

        public override void SyncToForm()
        {
        }

        public override void SyncToObject()
        {
        }
        #endregion
    }
}
