This code uploads a file to an ASP script using http post. It can be used to automatically uploading files without user interaction, e.g. when you want to publish some data to your Web site periodically.
There are lots of code excerpts around describing the receiving side but the sending side is mostly an HTML page containing <INPUT TYPE="File" ...>. Simulating this by code requires some knowledge of HTTP Post and Mime.
The project uses the XMLHTTPRequest object in Microsoft XML v2.6. The version 2.0 didn't work for this.
