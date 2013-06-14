using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlFlowStepBase : UserControl
    {
        #region Properties
        protected FlowStepBase Step;
        #endregion

        #region Constructor
        public ctlFlowStepBase()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public virtual void Init(FlowStepBase step)
        {
            if (step == null)
                throw new ArgumentException("step is null");
            Step = step;
        }
        public virtual void SyncToObject()
        {        
        }

        public virtual void SyncToForm()
        {        
        }
        #endregion
    }
}
