/******************************************************************************
*
*   File:   GenericApp.cpp
*
*   Date:   February 13, 1998
*
*   Description:   This file contains the functions and data members necessary
*               to initialize a Win32 application.  It is designed as a 
*               framework in which to insert example code for testing
*               and demonstration.  It is heavily commented to facilitate
*               changes for specific applications.
*
*   Modifications:
*
******************************************************************************/
//standard Windows #include file... not for MFC use
#include <windows.h>
//contains definitions for IDI_GENERIC and IDC_EXIT
#include "resource.h"

#include "comdef.h"
#include "initguid.h"
#include "ScriptedFrame.h"

//The WINAPI macro defines the way the compiler should construct the call stack
//and the relationship between caller and callee.  Currently, this relationship
//is defined by the _stdcall compiler directive.

//Function prototypes:
LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
LRESULT On_WM_CREATE(HWND hWnd);
LRESULT On_WM_COMMAND(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

/******************************************************************************
*   WinMain -- Initializes the application, displays its main window and runs
*   a message loop that comprises the top-level control structure for the 
*   rest of the application.
*   Parameters:   HINSTANCE hInstance -> an instance handle that determines if
*               there is another instance of this application already 
*               running.
*            HINSTANCE hPrevInstance -> an instance handle to the last 
*               created instance of this application.  It is used to ensure
*               that only one instance of the application is running at a 
*               time.
*            LPSTR lpszCmdLine -> a pointer to a character string containing
*               command line arguments for the application.
*            int nCmdShow -> the state that the main window is in.
*   Returns:   The application quits on receipt of a WM_QUIT message, and 
*               returns the value passed by that message.
******************************************************************************/
CScriptedFrame* theScriptHost;

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, 
               LPSTR lpszCmdLine, int nCmdShow)
{
   //We need two strings, one for the class name of the app, and one for the 
   //title of the window.
   static char lpszAppName[] = "GENERIC_APP";   //window class name
   static char lpszAppTitle[] = "Generic";      //window title

   //We need a menu with resource name "GENERIC_MENU"
   static char lpszAppMenu[] = "GENERIC_MENU";   //window menu name

   //We need several data members to setup this application.
   WNDCLASS wc;   //This is a handle we need to register the app with Win95
   HWND hWnd;      //This is a handle to the actual window object created by
               //CreateWindow();
   MSG msg;      //This is handle to a message used by the window message
               //dispatcher

   //Check to make sure that only one instance of the application is running 
   //at a time.  This WIN32 compatible function returns either a handle to 
   //another instance of the application or NULL if there is no such instance.
   hWnd = FindWindow(lpszAppName, lpszAppTitle);

   //If we come up with another instance already running, show that instance
   //instead of launching another instance
   if (hWnd)
   {
      //Check to see if the other instance has been minimized
      if (IsIconic(hWnd))
         ShowWindow(hWnd, SW_RESTORE);

      //Bring the original instance to the foreground and end this process.
      SetForegroundWindow(hWnd);
      return 0;
   }

   //If hPrevInstance is NULL, then this is the first time this application 
   //has been run on this machine.  We need to register some things with the 
   //OS so that message handling and so forth will be handled correctly.
   if (!hPrevInstance)
   {
      wc.style = 0;                  //the style of the Window
      wc.lpfnWndProc = (WNDPROC) WndProc;   //the function that will process 
                                 //messages
      wc.cbClsExtra = 0;               //not used, should be set to 0
      wc.cbWndExtra = DLGWINDOWEXTRA;      //sets up some extra bytes for the
                                 //dialog window
      wc.hInstance = hInstance;         //the application instance where 
                                 //this window is resident.
      //icon for the new application
      wc.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_GENERIC));
      wc.hCursor = LoadCursor(NULL, IDC_ARROW);   //the app's cursor style
      wc.hbrBackground = NULL;         //the color of the background
      wc.lpszMenuName = lpszAppMenu;      //the name of the menu resource
      wc.lpszClassName = lpszAppName;      //the name of the application

      //Register all these newfound goodies with the OS so it will know 
      //all about us.
      RegisterClass(&wc);
   }

   //Okay, this is the only instance of the application running, 
   //so create a window for it.
   hWnd = CreateWindow(lpszAppName,   //give it the class name
                  lpszAppTitle,   //and the app title
                  WS_VISIBLE,      //make it visible
                  0,0,         //start it in the top, left corner
                  480, 320,      //make it 480x320 in size
                  NULL,         //give it no parent window
                  NULL,         //and no children
                  hInstance,      //attach it to the application
                  NULL);         //and give it no special creation info

   //check and make sure the window got created alright
   if (hWnd == NULL)
   {
      //something went wrong, so inform the user with a message box, and 
      //quit the program.
      MessageBox(NULL,                     //no owner for this message
         "Could not create application window.",   //message for user
         "Error",                        //caption for the message
         MB_OK);                           //type of message box
   }

   //We're done building the window, so show the window
   ShowWindow(hWnd, SW_SHOW);
   //Update the display   
   UpdateWindow(hWnd);

   OleInitialize(NULL);
   /********** ActiveX Script Hosting Support ***********/
   //Create a new, local instance of the script hosting class
   theScriptHost = new CScriptedFrame();
   theScriptHost->AddRef();

   //If initialization of the script host is successful, run the script
   if (theScriptHost->InitializeScriptFrame())
      theScriptHost->RunScript();
   /********** End ActiveX Script Hosting Support **********/

   //Now we need to start the message loop so the application can deal 
   //with things that might happen to it.  GetMessage pulls messages from 
   //msg and returns non-zero on all messages except for WM_QUIT.
    while (GetMessage (&msg, NULL, 0, 0)){
      //IsDialogMessage determines if the message is intended for the window
      //(ie. \t to select the next control in the window), and handles the 
      //message if it is.
        if (!IsDialogMessage (hWnd, &msg))
         //The message isn't involved with the window, so send it to the app
         //and try to handle it there.  DispatchMessage send the message to 
         //WndProc for an attempt at processing.
            DispatchMessage (&msg);
   }
   
   //When we exit the while loop, we've received the WM_QUIT message, so 
   //return the value in the wParam of the message, and exit the process.
    return msg.wParam;                      
}

/******************************************************************************
*   WndProc -- Handles messages that are sent to the application window via 
*   DispatchMessage().
*   Parameters:   HWND hWnd -> the handle to the window that sent a message
*            UINT uMsg -> the message that was sent by the window
*            LPARAM lParam -> contains specific parameter information for 
*               the message that was passed.  Generally used by WM_COMMAND.
*            WPARAM wParam -> contains specific parameter information for 
*               the message that was passed.  Generally used by WM_COMMAND.
*   Returns:   Returns 0 if the message was handled successfully, non-zero if 
*            the message was not handled or if an error occurred while 
*            processing.
******************************************************************************/
LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
   //use a switch statement to determine what message was passed to the window
   switch(uMsg)
   {
   case WM_CREATE:
      return On_WM_CREATE(hWnd);   //Call the WM_CREATE message handler
      break;
   case WM_COMMAND:
      On_WM_COMMAND(hWnd, uMsg, wParam, lParam);   //call the WM_COMMAND 
                                       //message cracker
      break;
   case WM_CLOSE:
      DestroyWindow(hWnd);   //destroy the window
      break;
   case WM_DESTROY:
      PostQuitMessage(0);      //terminate the application
      break;
   default:
      //none of the cases matched, so pass the message on to the default 
      //message handler.
      return DefDlgProc(hWnd, uMsg, wParam, lParam);
      break;
   }
   //if any case caught the message, return 0 to indicate success.
   return (0L);
}

/******************************************************************************
*   On_WM_CREATE -- handles any special activities required at creation time.
*   Parameters:   HWND hWnd -> a handle to the window that spawned the WM_CREATE 
*            message.
*   Returns:   returns 0 if successful, and -1 if something goes wrong.
******************************************************************************/
LRESULT On_WM_CREATE(HWND hWnd)
{
   //In the generic case, this does nothing, so return 0.
   return 0;
}

/******************************************************************************
*   On_WM_COMMAND -- handles any commands that are passed from the application.
*   Parameters:   HWND hWnd -> a handle to the window that spawned WM_COMMAND
*            UINT uMsg -> identifies the message that was sent
*            LPARAM lParam -> contains specific parameter information for 
*               the message that was passed.
*            WPARAM wParam -> contains specific parameter information for 
*               the message that was passed.
*   Returns:   Returns 0 if the message was handled successfully, non-zero if 
*               something went wrong.
******************************************************************************/
LRESULT On_WM_COMMAND(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
   //this switch is similar to the other message handlers, but commands come 
   //packed with info, so they must be cracked into useful parts.
   switch (LOWORD(wParam))
   {
   case IDC_EXIT:
	  theScriptHost->QuitScript();
	  theScriptHost->Release();
	  OleUninitialize();
      DestroyWindow(hWnd);
      break;
   case IDC_EVENT:
      theScriptHost->FireEvent();
	  theScriptHost->QuitScript();
	  theScriptHost->Release();
      OleUninitialize();
      PostQuitMessage(0);
      break;
   case IDC_RELOAD:
	   theScriptHost->ReloadScript();
	   break;

   //add other command message handlers here.

   //message not handled by our application, so pass up to Windows
   default:
      return DefDlgProc(hWnd, uMsg, wParam, lParam);
   }

   //if any of the command handlers caught the message, then return 0 to 
   //indicate success.
   return (0L);
}
