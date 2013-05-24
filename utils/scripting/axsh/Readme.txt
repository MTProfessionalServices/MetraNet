ActiveX Script Hosting
----------------------------
ActiveX Script Hosting allows developers to add scripting capabilities to their applications.  Like the VBA macros of Microsoft Office 97, scripting gives users the ability to control their applications programmatically, automating common tasks.  However, ActiveX Script Hosting is not restricted to VBA as a scripting language.  It can support any scriptable language for which a scripting engine is available, such as JScript.  This document describes how to implement an ActiveX Script Host.

Step 1: Implement the IActiveScriptSite Interface
The first step in implementing an ActiveX Script Host is implementing the IActiveScriptSite interface.  This interface is required of all ActiveX Script Hosts.  Optionally, hosts may also implement the IActiveScriptSiteWindow interface if they wish to support a user interface on the same object as the IActiveScriptSite interface.  In the minimal application, none of the IActiveScriptSite methods need any significant code.  The methods, and their return values, are listed below.

IActiveScriptSite
* GetLCID - Returns the locale identifier of the host's user interface.  Can return E_NOTIMPL.
* GetItemInfo - Associates objects in the host with strings in the engine's namespace.  Can return TYPE_E_ELEMENTNOTFOUND.
* GetDocVersionString - Returns a script specific version string.  Can return E_NOTIMPL.
* OnScriptTerminate - Informs the host that the engine has completed running the script.  Should return S_OK.
* OnStateChange - Informs the host that the engine has changed modes.  Should return S_OK.
* OnScriptError - Informs the host that the engine has encountered and error in the script.  Should return S_OK.
* OnEnterScript - Informs the host that the engine has begun processing the script.  Should return S_OK.
* OnLeaveScript - Informs the host that the engine has suspended processing the script.  Should return S_OK.

At this step, these functions are little more than placeholders.  However, since the script engine may call these methods, they must be available.

Step 2: Initializing the Script Engine
It is the job of the ActiveX Script Host to create and initialize the script engine.  The following are the steps the host must take to do so.

* Call CoCreateInstance( ) with the CLSID of a script engine.  Using the OLE-COM Object Viewer that ships with Visual C++ 5.0, the CLSID's of valid script engines can be found in the "Active Scripting Engine with Parsing " category.
* Call the engine's IUnknown::QueryInterface( ) method to get a pointer to the IActiveScriptParse interface of the engine.  Both the original IActiveScript and the IActiveScriptParse pointers should be stored for later use.
* Call the engine's IActiveScript::SetScriptSite( ) method to give the engine an IActiveScriptSite pointer to the host.  This lets the engine communicate with the host using the methods listed in step 1.
* Call the engine's IActiveScriptParse::InitNew( ) method to get it ready to accept a new script.

Now the script engine has been initialized and is ready to run scripts
Step 3: Running the Script Engine
Once the script engine has been initialized, it needs to be given a script and started.  Doing so requires only two simple steps.

* Call the engine's IActiveScriptParse::ParseScriptText( ) method to load a script into the engine.
* Call the engine's IActiveScript::SetScriptState( SCRIPTSTATE_CONNECTED ) method to start the engine processing the script.

That's it; a minimally functional ActiveX Script Host in three steps.  At this point, the host can't do anything special, but the remaining steps significantly increase that functionality.

Step 4: Using Objects with the Script
In addition to the functionality the scripting language provides, the script engine can control and manipulate objects made available by the host.  Most of the functionality is already available through the scripting engine.  The work that remains is simply to associate the name in the script with the object in the host.  The steps to add this functionality are listed below.

* Define a class that implements the IDispatch interface, and create an instance of that class in the host.
* Select a name to refer to the instance in the script.
* Add a call to the engine's IActiveScript::AddNamedItem( ) method to add the chosen name to the namespace of the scripting engine.  The flag SCRIPTITEM_ISVISIBLE should be provided to tell the engine that the name could be referenced in the script.  This call should go after the call to IActiveScriptParse::InitNew( ) and before the call to IActiveScript::SetScriptState (SCRIPTSTATE_CONNECTED).
* Implement the host's IActiveScriptSite::GetItemInfo( ) method.  After checking to be sure the parameters are valid, this method should perform string comparisons to determine if an object corresponding to the pstrName parameter is available.  If none is found, return TYPE_E_ELEMENTNOTFOUND as before.  Otherwise, return the information requested by the dwMask parameter, either an IUnknown* or an ITypeInfo*.  Remember to insure that the interface pointers are non-null before writing to them!

At this point, the script is capable of invoking methods on the new class instance in the host.  By repeating this step, more objects can be made available to the script.

Step 5: Handling Events with the Script
Just as the script can invoke methods on objects in the host, those objects can also invoke methods in the script.  This requires only slight modification to the script host, additions to the objects that will be calling script methods, and a new dispinterface in the .ODL file.  Here are the steps to add this capability.

* Define a new dispinterface in the .ODL file.  This dispinterface should list only those methods that will be implemented in the script, and will be called from objects in the host.  It is important to maintain a list of the dispid's, because calls to invoke the methods must provide the dispid explicitly.
* Add the new dispinterface to the coclass entry of the object that will be calling the methods.  The attributes that should be specified are default and source.  The source attribute tells the MIDL compiler that these methods are outgoing events.
* Implement the IProvideClassInfo, IProvideClassInfo2, IProvideMultipleClassInfo, and IConnectionPointContainer interfaces in the object.  An example implementation of these interfaces can be seen in the ObjectFrame.cpp file of the example code.
* Implement the IConnectionPoint interface in the object.  This interface is the heart of the new functionality.  The script engine calls the object's IConnectionPoint::Advise( ) method in order to connect to the object as an event sink, and IConnectionPoint::Unadvise( ) to disconnect itself from the events.
* Add a new flag to the IActiveScript::AddNamedItem( ) call, SCRIPTITEM_ISSOURCE, which tells the engine that the object has outgoing interfaces it should connect to.
* When an object wishes to fire an event, it must retrieve the IDispatch pointer that was passed to it in IConnectionPoint::Advise( ), and call the IDispatch::Invoke( ) method on that pointer.  The dispid of the method to be called must be provided explicitly to this function.  It cannot be retrieved by calling IDispatch::GetIDsOfNames( ) because the script engine has no knowledge of the dispids.

At this point, all the functionality is in place for objects in the host to fire events to the script.

How It All Works
The example code provided is a simple application that demonstrates the fundamentals of ActiveX Script Hosting.  When run, the application puts up a message box with the canonical "Hello, World!" message, triggered by the script.  When the user selects "Fire Event" from the File pulldown menu, the application puts up a message box with the message "From Script: Hello, World!", cleans up after itself, and exits.  The code also contains tracing elements that allow the user to follow the execution path of the application when run in debug mode.  While simple, this application demonstrates the basic implementation of an ActiveX Script Host.  Inside, it is implemented exactly as described in the steps above.

* CScriptedFrame, the implementation of the ActiveX Script Host, initializes the script engine exactly as described in step 2.  It then creates an instance of CObjectFrame, a class that implements IDispatch, to run inside the host.  Then it adds the "MyObject" string to the engine's namespace with a call to IActiveScript::AddNamedItem( ).
* CScriptedFrame starts the script engine, passing it a script with a call to IActiveScriptParse::ParseScriptText( ), and setting it in motion with a call to IActiveScript::SetScriptState( SCRIPTSTATE_CONNECTED).  Step 3 is now complete.
* Now the script engine takes over.  It begins processing immediate script instructions, those that are not part of subroutines; specifically "MyObject.SayHi."  When it encounters the "MyObject" string, it calls the host's IActiveScriptSite::GetItemInfo( ) method to get the IUnknown pointer to the CObjectFrame object.  Then the script engine calls  IUnknown::QueryInterface( ) to get the IDispatch pointer to the CObjectFrame object, and IDispatch::Invoke( ) to invoke the SayHi( ) method.  "Hello, World!"  This is how step 4 works.
* When the script has finished running immediate script instructions, the engine stops and gets itself connected to events from CObjectFrame, triggering a call to IActiveScriptSite::OnLeaveScript( ) in the process.  It is important to note that no events will be connected before all the immediate instructions are completed, so be sure those immediate instructions don't depend on events. 
*  As before, the script engine gets the IUnknown pointer to the CObjectFrame object with a call to IActiveScriptSite::GetItemInfo( ), and uses IUnknown::QueryInterface( ) to get an IProvideMultipleClassInfo pointer.  With the IProvideMultipleClassInfo pointer, the engine is able to determine what outgoing interfaces CObjectFrame supports, determine that the event in the script is a method of that interface, and get a pointer to the IConnectionPointContainer interface.
* It calls the IConnectionPointContainer::FindConnectionPoint( ) method to get the IConnectionPoint interface it needs, and then calls IConnectionPoint::Advise( ) to tell the CObjectFrame object that it wishes to be notified when events are called.
* When the user selects "Fire Event" from the File pulldown menu, the CObjectFrame object uses the IDispatch pointer it stored in IConnectionPoint::Advise( ) to invoke the MyEvent( ) method in the script.  Note the explicit dispid.  
* From here, the behavior is exactly the same as that which called SayHi( ) in the immediate script instructions.  The script engine acquires the IDispatch pointer of the CObjectFrame object and calls IDispatch::Invoke( ) to invoke the SayHi2( ) method.
* At this point, the script engine once again stops, but this time it calls IConnectionPoint:: Unadvise() to tell the CObjectFrame object that it no longer wishes to be called when events are fired.  The host calls IActiveScript::Close( ) to tell the engine to uninitialize itself, and then calls IUnknown::Release( ) on all its interface pointers to release their memory.  The application is finished.


(c) Microsoft Corporation 1998, All Rights Reserved. Contributions by 
Joel Alley, Microsoft Corporation
