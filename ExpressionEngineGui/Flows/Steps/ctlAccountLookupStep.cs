using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using PropertyGui.Flows.Enumerations;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlAccountLookupStep : ctlBaseStep
    {
        #region Properties
        private AccountLookupStep Step { get { return (AccountLookupStep)_step; } }
        #endregion

        #region Constructor
        public ctlAccountLookupStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, MetraTech.ExpressionEngine.Context context)
        {
            base.Init(step, context);
            GuiHelper.LoadEnum<AccountLookupMode>(cboAccountLookupMode);
        }
        public override void SyncToForm()
        {
            cboAccountLookupMode.SelectedItem = Step.LookupMode;
            chkFailIfNotFound.Enabled = Step.FailIfNotFound;

            lstAccountViews.BeginUpdate();
            lstAccountViews.Items.Clear();
            lstAccountViews.Sorted = true;
            foreach (var propertyBag in Context.PropertyBagManager.PropertyBags)
            {
                if (((PropertyBagType) propertyBag.Type).Name == PropertyBagConstants.AccountView)
                    lstAccountViews.Items.Add(propertyBag.FullName);
            }
            lstAccountViews.EndUpdate();
        }

        public override void SyncToObject()
        {
            Step.LookupMode = (AccountLookupMode)cboAccountLookupMode.SelectedItem;
            Step.FailIfNotFound = chkFailIfNotFound.Enabled;

            //Account views
            Step.AccountViews.Clear();
            foreach (string avName in lstAccountViews.CheckedItems)
            {
                Step.AccountViews.Add(avName);
            }

        }

        private void UpdateGui()
        {
            SyncToObject();
            lblNamespace.Visible = Step.LookupMode == AccountLookupMode.ExternalId;
            ctlNamespace.Visible = Step.LookupMode == AccountLookupMode.ExternalId;
        }
        #endregion

        #region Events
        private void cboAccountLookupMode_SelectedValueChanged(object sender, System.EventArgs e)
        {
            UpdateGui();
        }
        #endregion

        private void button1_Click(object sender, System.EventArgs e)
        {
            SyncToObject();
            lstProperties.BeginUpdate();
            lstProperties.Sorted = true;
            lstProperties.Items.Clear();
            foreach (var property in Step.GetPossibleAccountViewProperties())
            {
                lstProperties.Items.Add(property.Name);
            }
            lstProperties.EndUpdate();
        }
    }
}
