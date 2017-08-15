/** This is the Secret World Legends Roleplay Profile Add-on
 * ...
 * @author Samera (AKA Lord Dave) - Coder
 * @author Spellsmith - Front End Website
 */

import GUI.Achievement.AchievementItem;
import GUI.SWLRP.SWLRPBrowserContent;
import GUI.SWLRP.SWLRPBrowserWindow;
import com.Components.Window;
import com.Components.WindowComponent;
import com.Components.WindowComponentContent;
import com.GameInterface.BrowserImageMetadata;
import com.GameInterface.Browser.Browser;
import com.GameInterface.CharacterData;
import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.Utils.ImageLoader;
import gfx.controls.UILoader;
import mx.utils.Delegate;
import com.Components.WinComp;
import com.Utils.Signal;
import com.GameInterface.Game.Character; 
import com.Utils.GlobalSignal;
import com.Utils.Archive;

class Main 
{
		
	var RPButton; //The button that displays in the top bar and lets you edit your own profile
	public static var _Flash; //So we can manipulate the swfRoot in other functions without having to pass it all over the place
	public static var GUILocked:Boolean; //To record if the gui lock toggle is on or off.
	static public var Version:String; //For Version Number
	
	
	public static function main(swfRoot:MovieClip):Void 
	{
		//Entry point
		_Flash = MovieClip(swfRoot); 
		var swl = new Main(swfRoot); //getting out of the main entry point.
		Version = "1.0";
	}
	
	

	public function Main(swfRoot:MovieClip) 
	{
		Object.registerClass("SWLRPBrowserWindow", GUI.SWLRP.SWLRPBrowserWindow);//The window object registering/linking with a class
		Object.registerClass("SWLRPBrowserContent", GUI.SWLRP.SWLRPBrowserContent); //The window holding the content registering/linking with a class
		Object.registerClass("CloseButton", gfx.controls.Button); //The close button in the window as a button.
		
		
		SWLRPBrowserWindow.SignalShowSWLRPWindow.Connect(showSWLWindow,swfRoot); //Signals let you call functions from anywhere in any swf file.  This is to show the window.
		GlobalSignal.SignalSetGUIEditMode.Connect(ToggleGUI, swfRoot);
		var Button_Container:MovieClip=swfRoot.createEmptyMovieClip("RPButton_Container", swfRoot.getNextHighestDepth());
		var RPButton:MovieClip =  Button_Container.attachMovie("RPProfile2", "m_rpbutton", Button_Container.getNextHighestDepth());  //Attaches the RP button to the top of the window by the compass
		
		
		var SWLWindow_x:DistributedValue = DistributedValue.Create("SWLRP_X");
		var SWLWindow_y:DistributedValue = DistributedValue.Create("SWLRP_Y");
		
		var FullScreenWidth = Stage["visibleRect"].width;
		
		//Check the X value is past the window on either side
		if (SWLWindow_x.GetValue() > FullScreenWidth || SWLWindow_x.GetValue()<0)
		{
			Button_Container._x = FullScreenWidth - Button_Container._width - 250;
			SWLWindow_x.SetValue(Button_Container._x);
			SWLWindow_y.SetValue(0);
		}
		else
		{
			Button_Container._x = SWLWindow_x.GetValue(); //sets the X location
		}
		Button_Container._y = SWLWindow_y.GetValue(); //sets the Y location.
		WindowOpen = false; 
	
		GUILocked = true;
		
		//for when you press the RP button at the top of the screen
		RPButton.onRelease = function()
		{
			if (Main.GUILocked) //If True, then you are not in edit mode and you will open a window. 
			{
				if (Character.GetClientCharacter().GetDefensiveTarget().IsNull() || Character.GetClientCharacter().GetDefensiveTarget().IsNpc()) //If the defensive target is null OR an NPC (so not a player)
				{
					SWLRPBrowserWindow.SignalShowSWLRPWindow.Emit(Character.GetClientCharacter().GetID()); //Sends a signal and the current character's unique ID to the below thread as wellas one other.
				}
				else
				{
					SWLRPBrowserWindow.SignalShowSWLRPWindow.Emit(Character.GetClientCharacter().GetDefensiveTarget());
				}
				
			}	
		};
				
		RPButton.onPress = function() //To start dragging
		{
			if (Main.GUILocked == false)
			{
				Button_Container.startDrag();
				
			}
		}

		
		RPButton.onMouseUp = function() //to stop dragging
		{
			Button_Container.stopDrag();
			SWLWindow_x.SetValue(Button_Container._x);
			SWLWindow_y.SetValue(Button_Container._y);
		}
				
		Mouse.addListener(RPButton);
	}
	
	 function showSWLWindow(m_CharID)
	{
		//If the window is not open already, open a new one then set it to true.  Else, it's open and display a warning that it's open.
		//Try to figure out how to auto-update the window so a new profile pops up or a new window.
		//Because as of now, if you have two windows open, it messes it up.
		if (WindowOpen == false)
		{
			m_Window = new SWLRPBrowserWindow(_Flash.attachMovie("SWLRPBrowserWindow", "m_Window_", _Flash.getNextHighestDepth()), m_CharID);
			
			WindowOpen = true;
		}
		else
		{
			Chat.SignalShowFIFOMessage.Emit("You must close the open profile before opening another.",1);
		}

		
	}
	
	function ToggleGUI(Toggle)
	{
		if (Toggle)
		{
			GUILocked = false;
		}
		if (!Toggle)
		{
			GUILocked = true;
		}
	}
	
	
	public static var WindowOpen; //Tells if the window is open or not.  Could make bool.  Should make bool.
	var m_Window:SWLRPBrowserWindow;
		
}