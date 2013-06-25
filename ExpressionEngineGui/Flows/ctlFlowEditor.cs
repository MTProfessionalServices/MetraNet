using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.MTProperties;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlFlowEditor : UserControl
    {
        #region Properties
        private Context Context;
        private BaseFlow Flow;
        #endregion

        #region Constructor
        public ctlFlowEditor()
        {
            InitializeComponent();
            tabStep.SelectedTab = tabDetails;
        }
        #endregion

        #region Methods
        public void Init(Context context, BaseFlow flow)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (flow == null)
                throw new ArgumentException("flow is null");
            Context = context;
            Flow = flow;

            ctlFlowSteps.Init(Context, Flow, this, tabDetails, ctlToolbox);

            //Toolbox
            var info = new ExpressionInfo(ExpressionType.ProductView);
            info.SupportsProperties = false;
            info.SupportsAvailableProperties = true;
            

            ctlToolbox.Tree.AllowEnumExpand = false;
            ctlToolbox.Tree.AllowEntityExpand = true;
          
            ctlToolbox.Init(Context);
            ctlToolbox.SetModeOptions(info, MvcAbstraction.ViewModeType.AvailableProperties);
            ctlToolbox.OnInsertSnippet += OnInsertSnippet;
            ctlToolbox.OnS2DoubleClick += OnS2DoubleClick;
        }

        private void OnS2DoubleClick(object o, string value)
        {
            if (o is IExpressionEngineTreeNode)
            {
                string snippet;
                if (o is Property)
                    snippet = string.Format("USAGE.{0}", ((Property) o).DatabaseName);
                else
                    snippet = ((IExpressionEngineTreeNode) o).ToExpressionSnippet;
                if (ctlFlowSteps.CurrentStepControl != null)
                    ctlFlowSteps.CurrentStepControl.InsertSnippet(snippet);
            }
        }

        private void OnInsertSnippet(string snippet)
        {
            if (ctlFlowSteps.CurrentStepControl != null)
                ctlFlowSteps.CurrentStepControl.InsertSnippet(snippet);
        }

        public void SyncCommonFieldsToObject(BaseStep step)
        {
                step.UserLabel = txtLabel.Text;
                step.UserDescription = txtDescription.Text;
                step.ConditionalExpression = ctlConditionalExecution.Text;
        }

        public void SyncToForm()
        {

            ctlFlowSteps.SyncToForm();
            UpdateGui();
        }

        public void SyncCommonFieldsToForm(BaseStep step)
        {
            txtLabel.Text = step.UserLabel;
            txtDescription.Text = step.UserDescription;
            ctlConditionalExecution.Text = step.ConditionalExpression;
            UpdateGui();
        }


        public void SyncToObject()
        {
            ctlFlowSteps.SyncToObject();
        }

        public void UpdateGui()
        {
            ctlConditionalExecution.Visible = chkConditionalExecution.Checked;
        }
        #endregion

        private void chkConditionalExecution_CheckedChanged(object sender, EventArgs e)
        {
          UpdateGui();
        }
    }
}
