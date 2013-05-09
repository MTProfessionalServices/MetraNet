package com.metratech.sdk.base;

import java.io.*;
import java.util.*;
import java.text.*;

// Add these lines to import the JAXP APIs you'll be using
import javax.xml.parsers.DocumentBuilder; 
import javax.xml.parsers.DocumentBuilderFactory;  
import javax.xml.parsers.FactoryConfigurationError;  
import javax.xml.parsers.ParserConfigurationException;

// Add these lines for the exceptions that can be thrown when the XML 
// document is parsed: 
import org.xml.sax.SAXException;  
import org.xml.sax.SAXParseException;

// Add these lines to read the sample XML file and identify errors: 
import java.io.File;
import java.io.IOException;

// Finally, import the W3C definition for a DOM and DOM exceptions:
import org.w3c.dom.*;

/**
 * {internal}
 */
class MTSOAPParser
{
	protected MTSOAPParser ()
	{
		mFactory = DocumentBuilderFactory.newInstance();
	}

	public MTSOAPMessage parse (InputStream inStream, String responseTag) throws MTParseException, MTException
	{
		MTSOAPMessage message = new MTSOAPMessage();

		try 
		{
			DocumentBuilder builder = mFactory.newDocumentBuilder();
			Document document = builder.parse(inStream);

			if (responseTag == SOAPObject.CREATE_RESULT_TAG)
			{
				Node nUID = findNode(document, responseTag);
				String UID = nUID.getFirstChild().getNodeValue();
				message.setUID(UID);
			}
			else if ((responseTag == SOAPObject.LOADBYNAME_RESULT_TAG) ||
							 (responseTag == SOAPObject.LOADBYUID_RESULT_TAG))
			{
				Node nID = findNode(document, "ID");
      	Node nName = findNode(document, "Name");
      	Node nNamespace = findNode(document, "Namespace");
      	Node nStatus = findNode(document, "Status");
      	Node nCreationDate = findNode(document, "CreationDate");
      	Node nSource = findNode(document, "Source");
      	Node nCompletedCount = findNode(document, "CompletedCount");
      	Node nExpectedCount = findNode(document, "ExpectedCount");
      	Node nFailureCount = findNode(document, "FailureCount");
      	Node nSequenceNumber = findNode(document, "SequenceNumber");
      	Node nSourceCreationDate = findNode(document, "SourceCreationDate");
      	Node nUID = findNode(document, "UID");
      	Node nMeteredCount = findNode(document, "MeteredCount");

      	//initial all variable
      	String ID  = nID.getFirstChild().getNodeValue();
      	String Name = nName.getFirstChild().getNodeValue();
      	String Namespace = nNamespace.getFirstChild().getNodeValue();
      	String Status = nStatus.getFirstChild().getNodeValue();
      	String CreationDate = nCreationDate.getFirstChild().getNodeValue();
      	String Source = nSource.getFirstChild().getNodeValue();
      	String CompletedCount = nCompletedCount.getFirstChild().getNodeValue();
      	String ExpectedCount = nExpectedCount.getFirstChild().getNodeValue();
      	String FailureCount = nFailureCount.getFirstChild().getNodeValue();
      	String SequenceNumber = nSequenceNumber.getFirstChild().getNodeValue();
      	String SourceCreationDate = nSourceCreationDate.getFirstChild().getNodeValue();
      	String UID = nUID.getFirstChild().getNodeValue();
      	String MeteredCount = nMeteredCount.getFirstChild().getNodeValue();

				/*
				System.out.println("---- ID = " + ID);
				System.out.println("---- Name = " + Name);
				System.out.println("---- Namespace = " + Namespace);
				System.out.println("---- Status = " + Status);
				System.out.println("---- CreationDate = " + CreationDate);
				System.out.println("---- Source = " + Source);
				System.out.println("---- CompletedCount = " + CompletedCount);
				System.out.println("---- ExpectedCount = " + ExpectedCount);
				System.out.println("---- FailureCount = " + FailureCount);
				System.out.println("---- SequenceNumber = " + SequenceNumber);
				System.out.println("---- SourceCreationDate = " + SourceCreationDate);
				System.out.println("---- UID = " + UID);
				System.out.println("---- MeteredCount = " + MeteredCount);
				*/

				Long LongID = new Long(ID);
				message.setID(LongID.longValue());
				
				message.setName(Name);
				message.setNamespace(Namespace);
				message.setStatus(Status);
				
				SimpleDateFormat txtDate = new SimpleDateFormat(
					"yyyy-MM-dd'T'HH:mm:ss");
				try
				{
					message.setCreationDate(txtDate.parse(CreationDate));
				}
				catch (ParseException e)
				{
					throw new MTParseException ("Error parsing timestamp " + e);
				}
				
				message.setSource(Source);
				
				Long LongCompletedCount = new Long(CompletedCount);
				message.setCompletedCount(LongCompletedCount.longValue());
				
				Long LongExpectedCount = new Long(ExpectedCount);
				message.setExpectedCount(LongExpectedCount.longValue());
				
				Long LongFailureCount = new Long(FailureCount);
				message.setFailureCount(LongFailureCount.longValue());
				
				message.setSequenceNumber(SequenceNumber);

				try
				{
					message.setSourceCreationDate(txtDate.parse(SourceCreationDate));
				}
				catch (ParseException e)
				{
					throw new MTParseException ("Error parsing timestamp " + e);
				}
				
				message.setUID(UID);
				
				Long LongMeteredCount = new Long(MeteredCount);
				message.setMeteredCount(LongMeteredCount.longValue());
			}
			else if (responseTag == SOAPObject.MARKASACTIVE_RESPONSE_TAG)
			{
				message.setStatus("A");
			}
			else if (responseTag == SOAPObject.MARKASBACKOUT_RESPONSE_TAG)
			{
				message.setStatus("B");
			}
			else if (responseTag == SOAPObject.MARKASFAILED_RESPONSE_TAG)
			{
				message.setStatus("F");
			}
			else if (responseTag == SOAPObject.MARKASCOMPLETED_RESPONSE_TAG)
			{
				message.setStatus("C");
			}
			else if (responseTag == SOAPObject.MARKASDISMISSED_RESPONSE_TAG)
			{
				message.setStatus("D");
			}
			else
			{
				// TODO -- return ERROR
			}
		}
		catch (SAXException sxe) 
		{
      // Error generated during parsing
      Exception  x = sxe;
      if (sxe.getException() != null)
        x = sxe.getException();
      x.printStackTrace();
    } 
		catch (ParserConfigurationException pce) 
		{
       // Parser with specified options can't be built
       pce.printStackTrace();
    } 
		catch (IOException ioe) 
		{
			// I/O error
      //ioe.printStackTrace();
			System.out.println ("MTSOAPParser: IOEXceptoin = " + ioe.getMessage());
    }

		return message;
	}

	public MTSOAPMessage parseSOAPException (InputStream exceptionStream)
	{
		MTSOAPMessage message = null;
		try 
		{
			message = new MTSOAPMessage();

			DocumentBuilder builder = mFactory.newDocumentBuilder();
			Document document = builder.parse(exceptionStream);

			Node nExceptionString = findNode(document, SOAPObject.SOAP_FAULTSTRING_TAG);
			String exceptionString = nExceptionString.getFirstChild().getNodeValue();

			// If it is MT message, there is code encapsulated in it
			// --------------------------------------------------------
			// MetraTech Error Code [E4020001]! Batch with name [xxx], 
			// namespace [MT] and sequence [xxx] already exists in the 
			// database
			// --------------------------------------------------------
			// For the JavaSDK case, return the MTSOAPMessage object
			String strErrorCode = exceptionString.substring(22, 30);
			String strErrorMessage = exceptionString.substring(33);

			message.setMTErrorCode(strErrorCode);
			message.setMTErrorMessage(strErrorMessage);

			return message;
		}
		catch (SAXException sxe) 
		{
      // Error generated during parsing
      Exception  x = sxe;
      if (sxe.getException() != null)
        x = sxe.getException();
      x.printStackTrace();
    } 
		catch (ParserConfigurationException pce) 
		{
       // Parser with specified options can't be built
       pce.printStackTrace();
    } 
		catch (IOException ioe) 
		{
			// I/O error
      //ioe.printStackTrace();
			System.out.println (ioe.getMessage());
    }
		catch (MTException e) 
		{
			System.out.println (e.getMessage());
		}

		return message;
	}
	
	public static Node findNode(Node node, String name) 
	{
		if (node.getNodeName().equals(name))
     	return node;
    if (node.hasChildNodes()) 
    {
      NodeList list = node.getChildNodes();
      int size = list.getLength();
      for (int i = 0; i<size ; i++) 
     	{
       	Node found = findNode(list.item(i), name);
        if (found != null) return found;
      }
    }
    return null;
  }

	public String stripSOAPException(String SOAPException)
	{
		// we have to strip of everything that starts with Fusion log because
		// there is the Fusion Log Viewer stuff that we are not interested in
		// showing it the user
		int start = SOAPException.indexOf("Fusion log");
		if (start != -1)
		{		
			int end = SOAPException.length() - start;
			return SOAPException.substring(start, end);
		}
		else
			return SOAPException;
	}

	// Obtain an instance of a factory that can give us a document builder
	private DocumentBuilderFactory mFactory;
}
