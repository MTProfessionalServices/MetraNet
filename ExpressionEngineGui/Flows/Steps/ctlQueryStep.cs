using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlQueryStep : ctlBaseStep
    {
        #region Properties
        private QueryStep Step { get { return (QueryStep)_step; } }
        #endregion

        #region Constructor
        public ctlQueryStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void SyncToForm()
        {
            txtQuery.Text = Step.Query;
        }
        public override void SyncToObject()
        {
            Step.Query = txtQuery.Text;
        }
        #endregion
    }
}
