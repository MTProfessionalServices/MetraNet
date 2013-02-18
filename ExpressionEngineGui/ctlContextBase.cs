using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    public partial class ctlContextBase : UserControl
    {
        #region Properties
        protected Context Context;
        #endregion

        #region Constructor
        public ctlContextBase()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public virtual void Init(Context context)
        {
            Context = context;
        }

        public virtual void HandleTreeEvent(IExpressionEngineTreeNode item, string value)
        {
            throw new NotImplementedException();
        }
        public virtual void InsertSnippet(string snippet)
        {
            throw new NotImplementedException();
        }
        public virtual void EditFunction()
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}
