using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlAggregateStep : ctlBaseStep
    {
        #region Properties
        private AggregationStep Step { get { return (AggregationStep)_step; } }
        #endregion

        #region Constructor
        public ctlAggregateStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, Context context)
        {
            base.Init(step, context);
            //var grdItems =
        }

        public override void SyncToForm()
        {
            foreach (var item in Step.Items)
            {
                
            }
        }

        public override void SyncToObject()
        {
            //Step.Items.Clear();
         
        }
        #endregion

        private void ctlAggregateStep_Load(object sender, System.EventArgs e)
        {

        }
    }
}
