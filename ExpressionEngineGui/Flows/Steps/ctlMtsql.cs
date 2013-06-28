using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlMtsql :ctlBaseStep
    {
        #region Properties
        private MtsqlStep Step { get { return (MtsqlStep) _step; } }
        #endregion

        #region Constructor
        public ctlMtsql()
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
