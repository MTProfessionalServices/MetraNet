using System.Globalization;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.MTProperties;

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

            lstAvailableProperties.BeginUpdate();
            lstAvailableProperties.Items.Clear();
            lstAvailableProperties.DisplayMember = "Name";
            foreach (var property in Step.AvailableProperties)
            {
                lstAvailableProperties.Items.Add(property);
            }
            lstAvailableProperties.EndUpdate();
        }
        public override void SyncToObject()
        {
            Step.PropertyName = cboProperty.Text;
            Step.Expression = txtExpression.Text;
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

        private void lstAvailableProperties_DoubleClick(object sender, System.EventArgs e)
        {
            if (lstAvailableProperties.SelectedItem != null)
            {
                var property = string.Format(CultureInfo.InvariantCulture, "USAGE.{0}",
                                             ((Property)lstAvailableProperties.SelectedItem).DatabaseName);
                txtExpression.Paste(property);
            }
        }

        private void lstFunctions_DoubleClick(object sender, System.EventArgs e)
        {
            if (lstAvailableProperties.SelectedItem != null)
                txtExpression.Paste(lstFunctions.Text);
        }

    }
}
