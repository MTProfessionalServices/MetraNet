using System;
using System.Text;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.ComponentModel;

namespace WebAnalyze
{
	/// <summary>
	/// Summary description for GanttChart.
	/// </summary>
	[DefaultProperty("Text"), 
		ToolboxData("<{0}:GanttChart runat=server></{0}:GanttChart>")]
	public class GanttChart : System.Web.UI.WebControls.WebControl
	{
		private string text;
	
		[Bindable(true), 
			Category("Appearance"), 
			DefaultValue("")] 
		public string Text 
		{
			get
			{
				return text;
			}

			set
			{
				text = value;
			}
		}

		private string BuildControl()
		{
			StringBuilder ctrl = new StringBuilder();
			ctrl.Append(@"			  <style>");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    DIV.gantt");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	border-bottom:#00008b solid 1px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	border-left:#eee8aa solid 1px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	border-right:#00008b solid 1px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	border-top:#eee8aa solid 1px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	padding:2px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	background-color:navy;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	color:whitesmoke;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	height:14px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	font-family:Tahoma;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	font-size:9px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	position:absolute;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	overflow:hidden;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        cursor:hand;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	z-index:101;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    DIV.hashed");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	color:black;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	background-image:url(hash.gif);");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	background-repeat:repeat-x;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      DIV.green  { background-color:#2e8b57; }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      DIV.red    { background-color:#800000; }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      DIV.orange { background-color:#ff7f50; }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      DIV.blue   { background-color:navy;    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    DIV.gridLine");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	top:0;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	height:100%;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	color:#008080;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	font-size:9px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	border-left: 1px dashed black;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	position:absolute;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	z-index:100;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    DIV.gridHeader");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	top:0;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	left:0;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	background-color:silver;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	width:100%;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	height:20px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	border-bottom:solid black 1px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	position:absolute;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    	z-index:99;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      Div.popup");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        border:solid black 1px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        padding:5px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        position:absolute;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        top:0;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        left:0;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        background-color:#ffffe0;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        color:black;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        display:none;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        z-index:110;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      Div.key");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        BORDER-RIGHT: black 1px solid;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        BORDER-TOP: black 1px solid;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        BORDER-LEFT: black 1px solid;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        BORDER-BOTTOM: black 1px solid;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        POSITION: absolute;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        TOP: 500px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        LEFT: 0px;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        BACKGROUND-COLOR: #d3d3d3;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        filter: alpha(opacity=80); ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"        z-index:120;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"</style>");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"<style>");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"	v\:* { behavior:url(#default#VML); }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"</style>");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"  <script language=""javascript"">");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    // connect bar1 to bar2");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    function connect(bar1, bar2)");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     var strRelationships;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     var Bar1Left");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     var Bar1Top;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     var Bar2Left;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     var Bar2Top;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     Bar1Left = parseInt(document.getElementById(bar1).style.left) + parseInt(document.getElementById(bar1).style.width) + 1;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     Bar1Top = parseInt(document.getElementById(bar1).style.top) + 7;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     Bar2Left = parseInt(document.getElementById(bar2).style.left) - 1;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     Bar2Top = parseInt( document.getElementById(bar2).style.top) + 7;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     strRelationships = ""<v:line stye='x-index:105' strokecolor='black' strokeweight='2pt' from='"" + Bar1Left + "","" + Bar1Top + ""' to='"" + Bar2Left + "","" + Bar2Top + ""'><v:stroke endarrow='classic'/></v:line>"";");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"     document.write(strRelationships);");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    // plot bar");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    function plot(name, description, startpx, endpx, startval, endval, row, type)");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      var width;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      width = endpx - startpx;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"            ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      document.write(""<div onClick=\""showPopup('description', '"" + description + ""', "" + startval + "", "" + endval + "")\"" id='"" + name + ""' class='gantt "" + type + ""' title='"" + description + ""' style=width:"" + width + "";top:"" + parseInt((row * 15) + 10) + "";left:"" + startpx + "";'>"" + name + ""</div>"");");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    // add grid line");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    function addTick(tick, label)");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      document.write(""<div id='grid' class='gridLine' style='left:"" + tick + "";'>"" + label + ""</div>"");");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    // show description in popup");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    function showPopup(name, text, start, end)");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      var obj;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj = document.getElementById(name);");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj.style.pixelLeft = window.event.clientX + document.body.scrollLeft;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj.style.pixelTop = window.event.clientY + document.body.scrollTop;");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj.innerHTML = text + ""<br><br><a style='text-decoration:none;color:navy;' href=\""JavaScript:hide('"" + name + ""');\""><small>.:Hide:.</small></a>"";");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj.innerHTML += ""&nbsp;&nbsp;<a style='text-decoration:none;color:navy;' href=\""WebForm1.aspx?Start="" + start + ""&End="" + end + ""\""><small>.:Zoom:.</small></a>"";");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj.style.display = ""block"";");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    ");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    // hide popup");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    function hide(name)");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    {");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      var obj");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj = document.getElementById(name);");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"      obj.style.display = ""none"";");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"    }");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"  </script>");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"  <div id=""header"" class=""gridHeader""></div>");
			ctrl.Append(System.Environment.NewLine);
			ctrl.Append(@"  <div id=""description"" class=""popup""></div>");
			ctrl.Append(System.Environment.NewLine);

			ctrl.Append("<script>");
			foreach (Tick tick in mTicks)
			{
				ctrl.Append(@"    addTick(");
				ctrl.Append(tick.TickPosition);
				ctrl.Append(@", """);
				ctrl.Append(tick.Label);
				ctrl.Append(@""");");
				ctrl.Append(System.Environment.NewLine);
			}
			// plot("bar1", "Bar - 1 Test", 10, 80, 1, "blue");
			foreach (Bar bar in mBars)
			{
				ctrl.Append(@"plot(""");
				ctrl.Append(bar.Name);
				ctrl.Append(@""", """);
				ctrl.Append(bar.Description);
				ctrl.Append(@""", ");
				ctrl.Append(bar.StartPx);
				ctrl.Append(",");
				ctrl.Append(bar.EndPx);
				ctrl.Append(",");
				ctrl.Append(bar.StartVal);
				ctrl.Append(",");
				ctrl.Append(bar.EndVal);
				ctrl.Append(",");
				ctrl.Append(bar.Row);
				ctrl.Append(@", """);
				ctrl.Append(bar.Type);
				ctrl.Append(@""");");
				ctrl.Append(System.Environment.NewLine);
			}
			ctrl.Append("</script>");
			ctrl.Append(System.Environment.NewLine);
			return ctrl.ToString();
		}

		private class Tick
		{
			public Tick(int tick, string label)
			{
				mTick = tick;
				mLabel = label;
			}

			public int TickPosition
			{
				get { return mTick; }
			}

			public string Label
			{
				get { return mLabel; }
			}

			private int mTick;
			private string mLabel;
		}

		private class Bar
		{
			public Bar(string name, string description, int startpx, int endpx, long startval, long endval, int row, string type)
			{
				mName = name;
				mDescription = description;
				mStartPx = startpx;
				mEndPx = endpx;
				mStartVal = startval;
				mEndVal = endval;
				mRow = row;
				mType = type;
			}
			public string Name
			{
				get { return mName; }
			}
			public string Description
			{
				get { return mDescription; }
			}
			public int StartPx
			{
				get { return mStartPx; }
			}
			public int EndPx
			{
				get { return mEndPx; }
			}
			public long StartVal
			{
				get { return mStartVal; }
			}
			public long EndVal
			{
				get { return mEndVal; }
			}
			public int Row
			{
				get { return mRow; }
			}
			public string Type
			{
				get { return mType; }
			}

			private string mName;
			private string mDescription;
			private int mStartPx;
			private int mEndPx;
			private long mStartVal;
			private long mEndVal;
			private int mRow;
			private string mType;
		}

		private ArrayList mTicks = new ArrayList();
		private ArrayList mBars = new ArrayList();
		public void AddTick(int tick, string label)
		{
			mTicks.Add(new Tick(tick, label));
		}

		public void Plot(string name, string description, int startpx, int endpx, long startval, long endval, int row, string type)
		{
			mBars.Add(new Bar(name, description, startpx, endpx, startval, endval, row, type));
		}
		/// <summary> 
		/// Render this control to the output parameter specified.
		/// </summary>
		/// <param name="output"> The HTML writer to write out to </param>
		protected override void Render(HtmlTextWriter output)
		{
			string ctrlText = BuildControl();
			output.Write(ctrlText);
		}
	}
}
