using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlExpression : ctlFlowStepBase
    {
        #region Properties

        private ExpressionStep ExpressionStep
        {
            get { return (ExpressionStep) Step; }
        }

        #endregion

        #region Constructor
        public ctlExpression()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void SyncToForm()
        {
            cboProperty.Text = ExpressionStep.PropertyName;
            txtExpression.Text = ExpressionStep.Expression;
        }
        public override void SyncToObject()
        {
            ExpressionStep.PropertyName = cboProperty.Text;
            ExpressionStep.Expression = txtExpression.Text;
        }
        #endregion

        private void cboProperty_DropDown(object sender, System.EventArgs e)
        {
            cboProperty.BeginUpdate();
            cboProperty.DisplayMember = "Name";
            foreach (var property in ExpressionStep.AvailableProperties)
            {
                cboProperty.Items.Add(property);
            }
            cboProperty.EndUpdate();
        }
    }
}
