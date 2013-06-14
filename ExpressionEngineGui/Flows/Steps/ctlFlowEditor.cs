using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlFlowEditor : UserControl
    {
        #region Properties
        private Flow Flow;
        #endregion

        #region Constructor
        public ctlFlowEditor()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(Flow flow)
        {
            if (flow == null)
                throw new ArgumentException("flow is null");
            Flow = flow;

            ctlFlowSteps.Init(Flow, splitContainer.Panel2);
        }

        public void SyncToForm()
        {
            ctlFlowSteps.SyncToForm();
        }

        public void SyncToObject()
        {
            ctlFlowSteps.SyncToObject();
        }
        #endregion
    }
}
