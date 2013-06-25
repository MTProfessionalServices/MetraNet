using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
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
        }

        public override void SyncToForm()
        {
            //ctlProperty.Text = Step.PropertyName;
        }

        public override void SyncToObject()
        {
            //Step.PropertyName = ctlProperty.Text;
        }
        #endregion
    }
}
