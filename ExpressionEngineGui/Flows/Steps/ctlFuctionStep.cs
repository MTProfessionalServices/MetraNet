using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlFuctionStep : ctlBaseStep
    {
        #region Properties
        private FunctionStep Step { get { return (FunctionStep)_step; } }
        #endregion

        #region Constructor
        public ctlFuctionStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, Context context)
        {
            base.Init(step, context);
            ctlProperty.Init(Step.AvailableProperties, TypeFactory.CreateAny());

            //Load the CDE specific functions
            cboFunction.BeginUpdate();
            cboFunction.Items.Clear();
            cboFunction.Sorted = true;
            cboFunction.DisplayMember = "Name";
            foreach (var function in Context.Functions)
            {
                if (function.Category == "CDE")
                    cboFunction.Items.Add(function);
            }
            cboFunction.EndUpdate();
        }

        public override void SyncToForm()
        {
            ctlProperty.Text = Step.PropertyName;
            cboFunction.Text = Step.FunctionName;
        }

        public override void SyncToObject()
        {
            Step.PropertyName = ctlProperty.Text;
            Step.FunctionName = cboFunction.Text;
            Step.ParameterValues = ctlPropertyCollectionBinder.GetValues();
        }
        #endregion

        #region Events
        private void cboFunction_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            var function = (Function) cboFunction.SelectedItem;
            ctlPropertyCollectionBinder.Init(Context, function.FixedParameters, Step.ParameterValues, Step.AvailableProperties);
        }
        #endregion
    }
}
