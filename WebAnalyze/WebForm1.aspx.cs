using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Diagnostics;
using System.Web;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using MetraTech.Performance;

namespace WebAnalyze
{
	/// <summary>
	/// Summary description for WebForm1.
	/// </summary>
	public class WebForm1 : System.Web.UI.Page
	{
		protected WebAnalyze.GanttChart GanttChart1;
	
		private int mPixels;
		private CallProfile mProfile;
		private long mStart;
		private long mEnd;


		private void Page_Load(object sender, System.EventArgs e)
		{
			// Put user code to initialize the page here
			long start;
			if (Request.Params["Start"] != null)
				start = System.Convert.ToInt64(Request.Params["Start"]);
			else
				start = System.Int64.MinValue;

			long end;
			if (Request.Params["End"] != null)
				end = System.Convert.ToInt64(Request.Params["End"]);
			else
				end = System.Int64.MaxValue;

			PlotSummary(start, end);
			// Plot(start, end);
		}

		private int CountToPixel(long count)
		{
			return (int) (((count - mStart) * mPixels) / (mEnd - mStart));
		}

		private string [] mColors = { "red", "green", "orange", "blue" };

		private int NextColor(int color)
		{
			return (color + 1) % mColors.Length;
		}

		private int AddBars(FunctionCall call, WebAnalyze.GanttChart chart, int row, int color)
		{
			 // Ignore call values, but process children.
			long callEnd = call.IsComplete ? call.End : call.Start;

			// Check if this call is in the specified range.
			if (callEnd < mStart || call.Start > mEnd)
				return row;  // outside range

			// This call maybe incomplete, but it may have children.
			int childColor = color;
			if (call.IsComplete)
			{
				long start = Math.Max(call.Start, mStart);
				long end = Math.Min(call.End, mEnd);

				int startPixel = CountToPixel(start);
				int endPixel = CountToPixel(end);

				chart.Plot(call.Region,
							string.Format("{0}({6}): {1}ms, {2}-{3} {4}-{5}",
							call.Region,
							call.DurationMs(mProfile.Frequency),
							call.Start,
							call.End,
							startPixel,
							endPixel, call.ThreadID),
							startPixel, endPixel, call.Start, call.End, row, mColors[color]);

				childColor = NextColor(color);
			}

			int maxRow = row;
			foreach (FunctionCall childCall in call)
			{
				int max = AddBars(childCall, chart, row + 1, childColor);
				childColor = NextColor(childColor);
				if (childColor == color)
					NextColor(childColor);
				
				if (max > maxRow)
					maxRow = max;
			}

			return maxRow;
		}

		internal class DescendingComparer : IComparer
		{
			public int Compare(object x, object y)
			{
				IComparable xcomp = (IComparable) x;
				IComparable ycomp = (IComparable) y;
				return - xcomp.CompareTo(ycomp);
			}
		}

		private int AddSummaryBars(FunctionCall call, WebAnalyze.GanttChart chart, int row, long offset, int color)
		{
			// This call maybe incomplete, but it may have children.
			int childColor = color;
			if (call.IsComplete)
			{
				long start = offset;
				long end = start + (long) call.TotalDuration;
				//long end = start + (long) call.AverageDuration;

				int startPixel = (int) ((start * mPixels) / (mEnd - mStart));
				int endPixel = (int) ((end * mPixels) / (mEnd - mStart));

				chart.Plot(call.Region,
					string.Format("{0}({1}): {2:f2}ms ave, {3:f2}ms total, {4} calls",
					call.Region,
					call.ThreadID,
					call.AverageDurationMs(mProfile.Frequency),
					call.TotalDurationMs(mProfile.Frequency),
					call.Calls),
					startPixel, endPixel, call.Start, call.End, row, mColors[color]);
			
				childColor = NextColor(color);
			}

			int maxRow = row;
			if (call.ChildCalls > 0)
			{
				long childOffset = offset;
				SortedList summaries = new SortedList(new DescendingComparer());
				foreach (FunctionCall childCall in call)
					//summaries.Add(childCall.AverageDuration, childCall);
					summaries.Add(childCall.TotalDuration, childCall);

				foreach (FunctionCall childCall in summaries.Values)
				{
					int max = AddSummaryBars(childCall, chart, row + 1, childOffset, childColor);
					childColor = NextColor(childColor);
					if (childColor == color)
						NextColor(childColor);
				
					//childOffset += (long) childCall.AverageDuration;
					childOffset += (long) childCall.TotalDuration;

					if (max > maxRow)
						maxRow = max;
				}
			}
			return maxRow;
		}

		private void PlotSummary(long start, long end)
		{
			WebAnalyze.GanttChart chart = GanttChart1;

			LogParser parser = new LogParser("c:\\temp\\perflog.txt", true);
			//LogParser parser = new LogParser("e:\\public\\perfresults\\perflog-test1.txt", true);
			mProfile = parser.Parse();

			mPixels = 1000;

			long longest = System.Int64.MinValue;
			SortedList summaries = new SortedList(new DescendingComparer());
			foreach (Hashtable threads in mProfile.ProcessInfo.Values)
			{
				foreach (ThreadInfo threadInfo in threads.Values)
				{
					foreach (FunctionCall call in threadInfo)
					{
						if (call.ChildCalls > 0)
						{
							//double itemValue = call.AverageDuration;
							double itemValue = call.TotalDuration;
							summaries.Add(itemValue, call);
							if (itemValue > longest)
								longest = (long) itemValue;
						}
					}
				}
			}


			mStart = 0;
			mEnd = longest;

			int startPix = CountToPixel(mStart);
			int endPix = CountToPixel(mEnd);

			int lines = 10;
			int msStart = (int) ((1000 * (mStart)) / mProfile.Frequency);
			int msEnd = (int) ((1000 * (mEnd)) / mProfile.Frequency);
			int msPerLine = (msEnd - msStart) / lines;
			int ms = msStart;
			while (ms < msEnd)
			{
				int pixel = (int) (((ms - msStart) * mPixels) / (msEnd - msStart));
				chart.AddTick(pixel, string.Format("{0}ms", ms));
				ms += msPerLine;
			}

			int row = 2;
			int maxRow = row;
			foreach (FunctionCall call in summaries.Values)
			{
				Debug.Assert(call != null);
				int max = AddSummaryBars(call, chart, row, 0, 0);
				if (max > maxRow)
					maxRow = max;
					
				// +3 because we leave two extra rows between processes
				row = maxRow + 3;
			}
		}

		private void Plot(long start, long end)
		{
			WebAnalyze.GanttChart chart = GanttChart1;

			LogParser parser = new LogParser("c:\\temp\\perflog.txt", true);
			mProfile = parser.Parse();

			mPixels = 1000;

			if (start == System.Int64.MinValue)
				mStart = mProfile.Start;
			else
				mStart = start;

			if (end == System.Int64.MaxValue)
				mEnd = mProfile.End;
			else
				mEnd = end;

			int startPix = CountToPixel(mStart);
			int endPix = CountToPixel(mEnd);



			int lines = 10;
			int msStart = (int) ((1000 * (mStart - mProfile.Start)) / mProfile.Frequency);
			int msEnd = (int) ((1000 * (mEnd - mProfile.Start)) / mProfile.Frequency);
			int msPerLine = (msEnd - msStart) / lines;
			int ms = msStart;
			while (ms < msEnd)
			{
				int pixel = (int) (((ms - msStart) * mPixels) / (msEnd - msStart));
				chart.AddTick(pixel, string.Format("{0}ms", ms));
				ms += msPerLine;
			}

			int row = 2;
			foreach (Hashtable threads in mProfile.ProcessInfo.Values)
			{
				int maxRow = row;
				foreach (ThreadInfo threadInfo in threads.Values)
				{
					foreach (FunctionCall call in threadInfo)
					{
						Debug.Assert(call != null);
						int max = AddBars(call, chart, row, 0);
						if (max > maxRow)
							maxRow = max;
							
						// +3 because we leave two extra rows between processes
						row = maxRow + 3;
					}
				}
			}

			/*
			SortedList summaries = new SortedList();
			foreach (Hashtable threadInfo in mProfile.ProcessInfo.Values)
			{
				foreach (FunctionCall threadCall in threadInfo.Values)
				{
					foreach (FunctionCall call in threadCall)
					{
						if (call.ChildCalls > 0)
						{
							double average = call.AverageDuration;
							summaries.Add(average, call);
						}
					}
				}
			}


			int row = 2;
			int maxRow = row;
			foreach (FunctionCall call in summaries.Values)
			{
				Debug.Assert(call != null);
				//int max = AddBars(call, chart, row, 0);
				int max = AddSummaryBars(call, chart, row, 0, 0);
				if (max > maxRow)
					maxRow = max;
					
				// +3 because we leave two extra rows between processes
				row = maxRow + 3;
			}
			*/


		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);

		}
		#endregion
	}
}
