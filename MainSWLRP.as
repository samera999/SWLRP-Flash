/** This is the Secret World Legends Roleplay Profile Add-on
 * ...
 * @author Samera (AKA Lord Dave) - Coder
 * @author Spellsmith - Front End Website
 */

import GUI.SWLRP.PingMeWindow;
import GUI.SWLRP.PingMe;
import GUI.SWLRP.SWLRPBrowserContent;
import GUI.SWLRP.SWLRPBrowserWindow;
import com.Components.Window;
import com.Components.WindowComponent;
import com.Components.WindowComponentContent;
import com.GameInterface.CharacterData;
import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.Utils.ImageLoader;
import gfx.controls.UILoader;
import mx.utils.Delegate;
import com.Components.WinComp;
import com.Utils.Signal;
import com.GameInterface.Game.Character; 
import com.GameInterface.Game.CharacterBase;
import com.Utils.GlobalSignal;
import com.Utils.Archive;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.Components.RightClickMenu;
import com.Components.RightClickItem;
import com.Utils.ID32;
import com.GameInterface.Browser.Browser;


class MainSWLRP 
{
		
	public static var Button_Container:MovieClip; //The button that displays in the top bar and lets you edit your own profile
	public static var RPButton:MovieClip;
	public static var _Flash; //So we can manipulate the swfRoot in other functions without having to pass it all over the place
	public static var GUILocked:Boolean; //To record if the gui lock toggle is on or off.
	static public var Version:String; //For Version Number
	public static var m_Tooltip:TooltipInterface;
	public static var dataProviderRP:Array;
	public static var m_VTIOIsLoadedMonitor:DistributedValue;
	public static var VTIOAddonInfo:String;
	var m_OptionWindowState:DistributedValue;
	public static var SWLWindow_x:DistributedValue;
	public static var SWLWindow_y:DistributedValue;
	public static var SWLRP_Debug:DistributedValue;
	public static var SWLRPWindowOpen:DistributedValue;	

		
	public static function main(swfRoot:MovieClip):Void 
	{
		//Entry point
		_Flash = MovieClip(swfRoot); 
		var swl = new MainSWLRP(swfRoot); //getting out of the main entry point.
		Version = "1.1.0"; //Current Version
		//swfRoot.OnModuleActivated = function(archive:Archive){
			//This wokrs!
		//}
		//swfRoot.onModuleDeactivated = function(){
	
	}
	
	public function MainSWLRP(swfRoot:MovieClip) 
	{
		Object.registerClass("SWLRPBrowserWindow", GUI.SWLRP.SWLRPBrowserWindow);//The window object registering/linking with a class
		Object.registerClass("SWLRPBrowserContent", GUI.SWLRP.SWLRPBrowserContent); //The window holding the content registering/linking with a class
		Object.registerClass("CloseButton", gfx.controls.Button); //The close button in the window as a button.
		var visibleRect = Stage["visibleRect"];
		swfRoot._width = visibleRect._x;
		swfRoot._height = visibleRect._y;
		SWLRPBrowserWindow.SignalShowSWLRPWindow.Connect(showSWLWindow,swfRoot); //Signals let you call functions from anywhere in any swf file.  This is to show the window.
		GlobalSignal.SignalSetGUIEditMode.Connect(ToggleGUI, swfRoot);
		GlobalSignal.SignalShowFriendlyMenu.Connect(addRPItem, swfRoot); 
		GlobalSignal.SignalShowFriendlyMenu.Disconnect(_root.friendlymenu.SlotShowFriendlyMenu);
		

		Button_Container = swfRoot.createEmptyMovieClip("RPButton_Container", swfRoot.getNextHighestDepth());
		RPButton =  Button_Container.attachMovie("RPProfile2", "m_rpbutton", Button_Container.getNextHighestDepth());  //Attaches the RP button to the top of the window by the compass
		SWLWindow_x = DistributedValue.Create("SWLRP_X");
		SWLWindow_y = DistributedValue.Create("SWLRP_Y");
		SWLRP_Debug = DistributedValue.Create("SWLRP_Debug");
		
		//For VTIO
		VTIOAddonInfo = "SWLRP|SWLRP|2.0|SWLRPWindowOpen|_root.swlrp\\swlrp.RPButton_Container";
		
		
		m_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
		m_VTIOIsLoadedMonitor.SignalChanged.Connect(SlotCheckVTIOIsLoaded, this);
		RPButton.onRelease = Delegate.create(this, onRelease);
		RPButton.onPress = Delegate.create(this, onPress);
		RPButton.onMouseUp = Delegate.create(this, onMouseUp);
		RPButton.onRollOver = Delegate.create(this, onRollOver);
		RPButton.onRollOut = Delegate.create(this, onRollOut);
		
		
		if (m_VTIOIsLoadedMonitor)
		{
			SlotCheckVTIOIsLoaded();
		}
		
		m_OptionWindowState = DistributedValue.Create("SWLRPWindowOpen");
		m_OptionWindowState.SignalChanged.Connect(SlotOptionWindowState, this);
		
		
		SWLRP_Debug.SetValue(false);
		
		var FullScreenWidth = Stage["visibleRect"].width;
		
		CharacterBase.SignalCharacterEnteredReticuleMode.Connect(SlotEnteredReticuleMode, swfRoot);
		
		//Check the X value is past the window on either side
		if (SWLWindow_x.GetValue() > FullScreenWidth || SWLWindow_x.GetValue()<0)
		{
			Button_Container._x = FullScreenWidth - Button_Container._width - 265; // 265 accounts for lock, clock, signal, AP, SP, and mail icons.
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
		
	}

				
		function onPress()  //To start dragging
		{
			if (MainSWLRP.GUILocked == false)
			{
				Button_Container.startDrag();
			}
		}

		
		function onMouseUp()  //to stop dragging
		{
			Button_Container.stopDrag();
			SWLWindow_x.SetValue(Button_Container._x);
			SWLWindow_y.SetValue(Button_Container._y);
		}
		
		function onRollOver() //Tooltip
		{
			if (MainSWLRP.m_Tooltip != undefined)
        {
            MainSWLRP.m_Tooltip.Close();
        }
        
        var tooltipData:TooltipData = new TooltipData();
        tooltipData.m_Descriptions.push("SWLRP Add-On v"+ MainSWLRP.Version);
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 150;
        
        MainSWLRP.m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, DistributedValue.GetDValue("HoverInfoShowDelay"), tooltipData);
		}
		
		function onRollOut() //Tooltip close
		{
			if (MainSWLRP.m_Tooltip != undefined)
			{
			MainSWLRP.m_Tooltip.Close();
			}
		}
		
		//for when you press the RP button at the top of the screen
		function onRelease()
		{
			if (MainSWLRP.GUILocked) //If True, then you are not in edit mode and you will open a window. 
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
			else 
			{
				Button_Container.stopDrag();
				SWLWindow_x.SetValue(Button_Container._x);
				SWLWindow_y.SetValue(Button_Container._y);
			}
		}
	
	function SlotOptionWindowState() 
	{
		var isOpen:Boolean = DistributedValue.GetDValue("SWLRPWindowOpen");

		onRelease();
		
	}
	
	//VTIO Function
	function SlotCheckVTIOIsLoaded() 
	{
		if (m_VTIOIsLoadedMonitor) 
		{
			DistributedValue.SetDValue("VTIO_RegisterAddon", VTIOAddonInfo);
		}
		
	}
	
	
	function SlotEnteredReticuleMode()
	{
			if (MainSWLRP.m_Tooltip != undefined)
			{
			MainSWLRP.m_Tooltip.Close();
			}
				
	}
	//Function that adds RP item to FriendlyMenu
	function addRPItem( m_CharID:ID32, name:String, showAtMouse )
	{
		dataProviderRP = new Array;
		
		//.SlotShowSWLRP doesn't exist in the function so this will create it and add it in dynamically
		_root.friendlymenu.SlotShowSWLRP = function()
		{
			GUI.SWLRP.SWLRPBrowserWindow.SignalShowSWLRPWindow.Emit(m_CharID);
		}
		_root.friendlymenu.SlotShowFriendlyMenu(m_CharID, name, showAtMouse); //Run friendlyMenu with the parameters since we killed the original.
		var SlotShowSWLRP: Function;
		var item = new RightClickItem("RP Profile", false, RightClickItem.LEFT_ALIGN);
        item.SignalItemClicked.Connect(_root.friendlymenu.SlotShowSWLRP, this);
		//Pushes the item to the dataProvider stack then sets it equal to itself, which will result in a refresh.
		_root.friendlymenu.m_RightClickMenu.dataProvider.push(item);
		_root.friendlymenu.m_RightClickMenu.dataProvider = _root.friendlymenu.m_RightClickMenu.dataProvider;
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
	public static var m_Window:SWLRPBrowserWindow;
		
}