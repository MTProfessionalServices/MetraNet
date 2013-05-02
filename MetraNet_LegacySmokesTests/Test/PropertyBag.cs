namespace MetraTech.Test
{
	using System.Collections;
	using System.IO;

	public class PropertyBag : Hashtable
	{
		//Hashtable mProperties = new Hashtable();
		
		public void Initialize(string sName)
		{
			//mProperties.Clear();
			this.Clear();

			string filename = TestLibrary.TestDatabaseTempFolder + "\\" + sName + ".PropertyBag.txt";
			
			// Read contents of source file
			string sLine;
			//ArrayList szContents = new ArrayList ();
			FileStream fsInput = new FileStream (filename, FileMode.Open, FileAccess.Read);
			StreamReader srInput = new StreamReader (fsInput);
			string [] splitLine = null;
			while ((sLine = srInput.ReadLine ()) != null)
			{
				// Append to array
				splitLine = sLine.Split('=');
				if (splitLine.Length==2)
				{
					this.Add(splitLine[0],splitLine[1]);
				}
			}
			srInput.Close ();
			fsInput.Close ();
		}
	}
}
