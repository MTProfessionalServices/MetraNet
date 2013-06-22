using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlExpression : ctlBaseStep
    {
        #region Properties
        private ExpressionStep Step { get { return (ExpressionStep) _step; } }
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
            cboProperty.Text = Step.PropertyName;
            txtExpression.Text = Step.Expression;
        }

        public override void SyncToObject()
        {
            Step.PropertyName = cboProperty.Text;
            Step.Expression = txtExpression.Text;
        }

        public override void InsertSnippet(string snippet)
        {
            txtExpression.Paste(snippet);
        }
        #endregion

        #region Events
        private void cboProperty_DropDown(object sender, System.EventArgs e)
        {
            cboProperty.BeginUpdate();
            cboProperty.Items.Clear();
            cboProperty.DisplayMember = "Name";
            foreach (var property in Step.AvailableProperties)
            {
                cboProperty.Items.Add(property);
            }
            cboProperty.EndUpdate();
        }
        #endregion
    }
}
