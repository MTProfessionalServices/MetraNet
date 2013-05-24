using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SampleAspNetApp
{
	public partial class GZipCompress : System.Web.UI.Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{

		}

		protected void btnEncode_Click(object sender, EventArgs e)
		{
			if (file.HasFile)
			{
				using (MemoryStream ms = new MemoryStream())
				{
					using (GZipStream compressor = new GZipStream(ms, CompressionMode.Compress))
					{
						int val;
						while ((val = file.FileContent.ReadByte()) != -1)
						{
							compressor.WriteByte((byte)val);
						}
					}

					ms.Flush();
					byte[] bytes = ms.ToArray();
					repCompressed.DataSource = bytes;
					repCompressed.DataBind();

					lblCompressed.Text = Convert.ToBase64String(bytes);
				}
			}
		}
	}
}