CLASS CMAMProto30

    PUBLIC FUNCTION Main()
       ''TestPopUpMenu
       TestDragAndDrop
    END FUNCTION

    PUBLIC FUNCTION GotoWeb()

        Page.URL = "http://localhost/prototypes/mam/"
        Page.WaitForDownLoad "http://localhost/prototypes/mam/"
    END FUNCTION

    PUBLIC FUNCTION SelectKevinUser()

        Dim x,y

        Page.MoveMouseCursor = TRUE

        Page.Controls("SearchOn","ComboBox","fmeNavBar").Value = "UserName"
        Page.Controls("SearchValue","TextBox","fmeNavBar").Text = "Kevin"

        Page.Controls("Find Account","Image","fmeNavBar").Click
        Page.WaitForDownLoad "menu.asp"

        Page.ClearTrace

        Page.Controls("Scott","TableCell","fmeNavBar").SetFocus
        Page.Wait 1
        Page.CurrentX = Page.CurrentX - 60
        x = Page.CurrentX
        y = Page.CurrentY
        Page.Trace "Scott pos " & x & " " & y
        Page.Wait 1

        Page.Controls("Kevin","TableCell","fmeNavBar").SetFocus
        Page.Wait 1
        Page.CurrentX = Page.CurrentX - 40
        Page.Wait 1

        Page.MoveMouseCursor = FALSE
        Page.Trace "WM_MOUSE_DOWN"
        Page.Controls("Kevin","TableCell","fmeNavBar").Click 1 ,1 ,frITEM_CLICK_FLAG_WM_MOUSE_DOWN
        Page.Trace "..."
        Page.Wait 1
        Page.CurrentX = x
        Page.CurrentY = y

        'Page.Wait 3
        'Page.Trace "..."
        'Page.Trace "WM_MOUSE_MOVE"
        'Page.Controls("Kevin","TableCell","fmeNavBar").Click 11+10,-10-10,frITEM_CLICK_FLAG_CURRENT_POSITION+frITEM_CLICK_FLAG_WM_MOUSE_MOUVE+frITEM_CLICK_FLAG_WM_MOUSE_DOWN



   END FUNCTION

   PUBLIC FUNCTION TestDragAndDrop()

        GotoWeb
        SelectKevinUser
   END FUNCTION


   PUBLIC FUNCTION TestPopUpMenu

        GotoWeb
        SelectKevinUser

        Page.Controls("Kevin","TableCell","fmeNavBar").SetFocus
        Page.Wait .5
        Page.Controls("Kevin","TableCell","fmeNavBar").Click ,,frITEM_CLICK_FLAG_CURRENT_POSITION+frITEM_CLICK_FLAG_RIGHT_CLICK
        Page.CurrentY = Page.CurrentY + 10
        Page.CurrentX = Page.CurrentX + 10

        Page.Wait 1

        Page.Controls("divManageAccount","Div","fmeNavBar").CLick
        Page.WaitForDownLoad "menu.asp"

    END FUNCTION 
END CLASS

PUBLIC FUNCTION Main()

  Dim objMAMProto30
  Set objMAMProto30 = New CMAMProto30

  objMAMProto30.Main

END FUNCTION

