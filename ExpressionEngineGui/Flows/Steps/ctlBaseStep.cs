using System;
using System.Drawing;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlBaseStep : UserControl
    {
        #region Properties

        /// <summary>
        /// The underlying step. Each subclass has a Step accessor that casts this to the appropriate type.
        /// </summary>
        protected BaseStep _step;
        protected Context Context;
        #endregion

        #region Constructor
        public ctlBaseStep()
        {
            InitializeComponent();
            BackColor = Color.Silver;
        }
        #endregion

        #region Methods
        public virtual void Init(BaseStep step, Context context)
        {
            if (step == null)
                throw new ArgumentException("step is null");
            if (context == null)
                throw new ArgumentException("context is null");
            _step = step;
            Context = context;
        }
        public virtual void SyncToObject()
        {        
        }

        public virtual void SyncToForm()
        {        
        }

        public virtual void InsertSnippet(string snippet)
        {
        }
        #endregion
    }
}
