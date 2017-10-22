import GUI.SWLRP.SWLRPBrowserContent;
import com.Components.WinComp
import com.GameInterface.Chat;
import com.Utils.LDBFormat;
import com.GameInterface.DistributedValue;
import com.Utils.Signal;
import com.GameInterface.CharacterData;
import com.GameInterface.Targeting;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.CharacterBase;
import com.Utils.Archive;
import com.GameInterface.UtilsBase;



class GUI.SWLRP.SWLRPBrowserWindow extends com.Components.WinComp
{
	static var SignalShowSWLRPWindow = new com.Utils.Signal(); //The signal which runs two functions.
	
	
	
	function SWLRPBrowserWindow()
	{
		super();
		SignalShowSWLRPWindow.Connect(showSWLRPWindow, this); // Sets a signal to run when called.
		CharacterBase.SignalCharacterEnteredReticuleMode.Connect(SlotEnteredReticuleMode, this);
		
	}
	
	function configUI()
	{
		super.configUI();
	}
	
	function onLoad()
	{
		super.configUI();
		
		var SWLRP_Debug:DistributedValue = DistributedValue.Create("SWLRP_Debug"); //Check Debug value
		//Title is First name "Nick" Last name
		
		if (SWLRP_Debug.GetValue())
		{
			SetTitle(Character.GetCharacter(m_CharID).GetFirstName() + " \"" + Character.GetCharacter(m_CharID).GetName() + "\" " + Character.GetCharacter(m_CharID).GetLastName() + " TESTING");
		}
		else 
		{
		SetTitle(Character.GetCharacter(m_CharID).GetFirstName() + " \"" + Character.GetCharacter(m_CharID).GetName() + "\" " + Character.GetCharacter(m_CharID).GetLastName());
		}
		
		var visibleRect = Stage["visibleRect"];
		_x = visibleRect.x;
		_y = visibleRect.y;
		SetPadding(10);
		SetContent("SWLRPBrowserContent");
		SignalClose.Connect(CloseWindowHandler,this);
		ShowCloseButton(true);
		ShowStroke(false);
		ShowResizeButton(false);    
		ShowFooter(false);

		_x = Math.round((visibleRect.width / 2) - (m_Background._width / 2));
		_y = Math.round((visibleRect.height / 2) - (m_Background._height / 2));
		
		
	}	
	
	
	function showSWLRPWindow(t_CharID)
	{
	m_CharID = t_CharID; //All this does is set the charID emitted to a lcoal variable so it can be read.
	
	}	
	
	function CloseWindowHandler()
{
	removeMovieClip();
	m_Window = null;
	MainSWLRP.WindowOpen = false;
	MainSWLRP.m_Window = null; //Sets the main variable to null so we can reuse the web browser variable.
	
     
}

function SlotEnteredReticuleMode()
{
	removeMovieClip();
	m_Window = null;
	MainSWLRP.WindowOpen = false;
}

   function onUnload()
   {
      super.onUnload();

      Selection.setFocus(null);
   }

	var m_Window;
	public static var m_CharID;
}