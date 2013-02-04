
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public interface IExpressionEngineTreeNode
    {
        string Name { get; set; }
        string ToolTip { get; }
        string Image { get; }
        string ToExpression { get; }
    }
}
