using System;
using System.Runtime.InteropServices;
using System.Text;

namespace MetraTech
{
	/// <summary>
	/// Wrap the StringBuilder functionality for use in COM world...
	/// </summary>
  [Guid("23adce04-b2f8-4c26-8bb8-01eb09c95ecc")]
	public class MTStringBuilder
	{
    private StringBuilder mSB;

    /// <summary>
    /// Create a new StringBuilder
    /// </summary>
		public MTStringBuilder()
		{
			mSB = new StringBuilder();
		}

    /// <summary>
    /// Add text to StringBuilder
    /// </summary>
    /// <param name="str"></param>
    public void Append(string str)
    {
      mSB.Append(str);
    }

    /// <summary>
    /// Override our ToString method to output the current string in the StringBuilder
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
      return(mSB.ToString());
    }

    /// <summary>
    /// Remove text starting at index and going to length
    /// </summary>
    /// <param name="startIndex"></param>
    /// <param name="length"></param>
    public void Remove(int startIndex, int length)
    {
      mSB.Remove(startIndex, length);
    }

    /// <summary>
    /// Clear all the text
    /// </summary>
    public void Clear()
    {
      mSB.Remove(0, Length);
    }

    /// <summary>
    /// Replace old sting value with new string value
    /// </summary>
    /// <param name="oldValue"></param>
    /// <param name="newValue"></param>
    public void Replace(string oldValue, string newValue)
    {
      mSB.Replace(oldValue, newValue);
    }

    /// <summary>
    /// Insert string at index
    /// </summary>
    /// <param name="index"></param>
    /// <param name="str"></param>
    public void Insert(int index, string str)
    {
      mSB.Insert(index, str);
    }

    /// <summary>
    /// Length of current string
    /// </summary>
    public int Length
    {
      get { return(mSB.Length); }
    }

	}

}
