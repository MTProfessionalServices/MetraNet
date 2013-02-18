
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public interface IExpressionEngineTreeNode
    {
        string Name { get; set; }
        string TreeNodeLabel { get; }
        string ToolTip { get; }
        string Image { get; }
        string ToExpressionSnippet { get; }
    }
}
