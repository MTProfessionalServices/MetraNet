using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlProcessList : ctlBaseStep
    {
        #region Properties
        private ProcessChildrenStep Step { get { return (ProcessChildrenStep)_step; } }
        #endregion

        #region Constructor
        public ctlProcessList()
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
            base.SyncToObject();
        }
        #endregion
    }
}

