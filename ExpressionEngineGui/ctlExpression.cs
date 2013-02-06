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
        }
        #endregion

        #region Methods

        public void Init(Context context, ContextMenuStrip mnuContext)
        {
            Context = context;

            ContextMenuStrip = mnuContext;
            Multiline = true;

            if (Context.Expression.Type == Expression.ExpressionTypeEnum.Message)
                WordWrap = true;
            else
                WordWrap = false;

            ScrollBars = System.Windows.Forms.ScrollBars.Both;
            Text = Context.Expression.Content;
        }

        public void HandleTreeEvent(IExpressionEngineTreeNode item)
        {
            if (item is Function)
                EditFunction((Function)item);
            else
                Paste(item.ToExpression);
        }

        public void EditFunction()
        {
            var name = SelectedText;
            var func = Context.TryGetFunction(name);
            if (func == null)
            {
                MessageBox.Show(string.Format("Unable to find Function '{0}'", name));
                return;
            }
            EditFunction(func);
        }

        public void EditFunction(Function func)
        {
            string str = null;
            switch (func.Name)
            {   
                case "In":
                    var frmIn = new frmFuncIn();
                    frmIn.Init(Context, null, null);
                    if (DialogResult.OK == frmIn.ShowDialog())
                        str = frmIn.GetValue();
                    break;
                default:
                    var frmFunc = new frmFunctionBinder();
                    frmFunc.Init(Context, func);
                    if (DialogResult.OK == frmFunc.ShowDialog())
                        str = frmFunc.GetExpression();
                    break;
            }
            if (str != null)
                Paste(str);
        }
        #endregion
    }
}
