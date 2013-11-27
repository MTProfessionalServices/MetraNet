package com.metratech.sdk.base;

import java.net.*;
import java.io.*;
import java.util.*;
import java.lang.Exception;
import com.jclark.xml.*;
import com.jclark.xml.parse.*;
import com.jclark.xml.parse.io.*;

/**
 * {internal}
 */
class MTMSIXParser implements com.jclark.xml.parse.io.Application, MSIXObject
{
  protected MTMSIXParser ()
  {
    mInputStream = null;
    mObjects = new Stack();
  }
  protected MTMSIXParser (InputStream inStream)
  {
    mInputStream = inStream;
    mObjects = new Stack();
  }
	
  public synchronized void setStream (InputStream inStream)
  {
    mInputStream = inStream;
  }
	
  public MTMSIXMessage doParse() throws IOException, MTException
  {
    try 
    {
      mObjects.push (this);
      OpenEntity myEntity = new OpenEntity (mInputStream,
					    "",
					    new URL ("http://www.msix.org"));
      Parser parser = new ParserImpl();
      parser.setApplication (this);		
      parser.parseDocument(myEntity);
      return mMessage;
    }
    catch (MalformedURLException e)
    {
    }

    return null;
  }

  /**
   * Reports the start of the document.
   * This is called once per well-formed document before any other methods.
   */
  public void startDocument() {}
  /**
   * Reports the end of the prolog.
   * Called before the start of the first element.
   */
  public void endProlog(EndPrologEvent event) {}

  /**
   * Reports the start of an element.
   * This includes both start-tags and empty elements.
   */
  public void startElement(StartElementEvent event) throws IOException
  {
    try
    {	
      // Get the current object from the stack
      MSIXObject current = (MSIXObject)mObjects.peek();
		
      // Create a sub object from it
      MSIXObject newObject = current.create (event.getName());
		
      if (null == newObject)
	throw new IOException ("Unrecognized tag " + event.getName());
		
      // Make this object the current one
      mObjects.push (newObject);
    }
    catch (Exception e)
    {
      throw new IOException ("Unexpected error processing " + event.getName() + ". " + e.getMessage());
    }
  }

  /**
   * Reports character data.
   */
  public void characterData(CharacterDataEvent event) throws IOException
  {
    try
    {
      // grab the data
      int dataLen = event.getLength();
      char[] Data = new char[dataLen];
      event.copyChars(Data, 0);
		
      // route it to the current object
      MSIXObject current = (MSIXObject)mObjects.peek();
      // TODO: hack for now!!
      String theString = new String(Data);
      String newString = theString.trim();
      if (newString.length() > 0)
	current.parse(theString);
      // TODO: end hack!!
    }
    catch (Exception e)
    {
      throw new IOException ("Unexpected error processing data. " + e.getMessage());					
    }
  }
  /**
   * Reports the end of a element.
   * This includes both end-tags and empty elements.
   */
  public void endElement(EndElementEvent event)  throws IOException
  {
    try
    {
      // notify the current object that it's done
      MSIXObject top = (MSIXObject)mObjects.pop();
      top.complete(top);
		
      // Notify the parent that its child is done
      MSIXObject parent = (MSIXObject)mObjects.peek();
      parent.complete (top);
    }
    catch (Exception e)
    {
      throw new IOException ("Unexpected error processing end tag : " + event.getName() + e);								
    }
  }

  /**
   * Reports a processing instruction.
   * Note that processing instructions can occur before or after the
   * document element.
   */
  public void processingInstruction(ProcessingInstructionEvent event)  {}

  /**
   * Reports the end of the document.
   * Called once per well-formed document, after all other methods.
   * Not called if the document is not well-formed.
   */
  public void endDocument()  {}

  /**
   * Reports a comment.
   * Note that comments can occur before or after the
   * document element.
   */
  public void comment(CommentEvent event)  {}

  /**
   * Reports the start of a CDATA section.
   */
  public void startCdataSection(StartCdataSectionEvent event)  {}
  
  /**
   * Reports the end of a CDATA section.
   */
  public void endCdataSection(EndCdataSectionEvent event)  {}

  /**
   * Reports the start of an entity reference.
   * This event will be followed by the result of parsing
   * the entity's replacement text.
   * This is not called for entity references in attribute values.
   */
  public void startEntityReference(StartEntityReferenceEvent event)  {}

  /**
   * Reports the start of an entity reference.
   * This event follow's the result of parsing
   * the entity's replacement text.
   * This is not called for entity references in attribute values.
   */
  public void endEntityReference(EndEntityReferenceEvent event)  {}

  /**
   * Reports the start of the document type declaration.
   */
  public void startDocumentTypeDeclaration(StartDocumentTypeDeclarationEvent event) {}

  /**
   * Reports the end of the document type declaration.
   */
  public void endDocumentTypeDeclaration(EndDocumentTypeDeclarationEvent event)  {}

  /**
   * Reports a markup declaration.
   */
  public void markupDeclaration(MarkupDeclarationEvent event)  {}


  public MSIXObject create (String type) throws MTException
  {
    MSIXObject obj = null;
    if (type.equalsIgnoreCase(MSIXObject.MSIX_TAG_MESSAGE))
    {
      MTMSIXMessage msg = new MTMSIXMessage();
      obj = (MSIXObject)msg;
    }
    else //Todo: handle this better
      return null;
			
    return obj;
  }
	
  public void parse (String type)
  {
    // this should never be called
  }

  public void complete (MSIXObject obj) throws MTException
  {
    // could do some checking here for valid message
    mMessage = (MTMSIXMessage)obj;
  }
	
  public void toStream (OutputStream stream)
  {
    //this should never be called
  }
	
  private InputStream mInputStream;
  private MTMSIXMessage mMessage;
  private Stack mObjects;
}

