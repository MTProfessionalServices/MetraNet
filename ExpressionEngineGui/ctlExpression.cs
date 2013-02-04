using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    public class ctlExpression : TextBox
    {
        #region Properties
        private Context Context;
        #endregion

        #region Constructor
        public ctlExpression()
        {
            Init(Context);
        }
        #endregion

        #region Methods

        public void Init(Context context)
        {
            Context = context;

            Multiline = true;
            WordWrap = false;
            ScrollBars = System.Windows.Forms.ScrollBars.Both;
        }

        public void HandleTreeEvent(IExpressionEngineTreeNode item)
        {
            if (item is Function)
                HandleFunction(item.Name);
            else
                Paste(item.ToExpression);
        }

        public void HandleFunction(string name, string[] parameters= null)
        {
            string str;
            switch (name.ToLower())
            {   
                case "in":
                    var dialog = new frmFuncIn();
                    dialog.Init(Context, null, null);
                    if (DialogResult.OK == dialog.ShowDialog())
                        Paste(dialog.GetValue());
                    break;
                default:
                    str = string.Format("{0}()", name);
                    Paste(str);
                    break;
            }
        }
        #endregion
    }
}
