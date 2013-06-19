using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;

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

            ctlFlowSteps.Init(Context, Flow, splitContainer.Panel2);
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
