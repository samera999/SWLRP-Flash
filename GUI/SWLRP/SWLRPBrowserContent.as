import GUI.SWLRP.SWLRPBrowserWindow;
import com.GameInterface.Browser.Browser;
import com.Utils.Signal;
import com.GameInterface.Game.Character;
import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
class GUI.SWLRP.SWLRPBrowserContent extends com.Components.WindowComponentContent
{
    //Properties
    private var m_MouseListener:Object;
    private var m_Loader:gfx.controls.UILoader;
    private var m_Browser:Browser;
    private static var SCROLL_AMOUNT:Number = 32;
	var Char;
	
	
   function SWLRPBrowserContent()
   {
      super();
   }
   function configUI()
   {
      super.configUI();
	  
	  Char = SWLRPBrowserWindow.m_CharID; //Gets the CharID of the target.
      
      this.m_Browser = new com.GameInterface.Browser.Browser(5.0000, this.m_Loader._width, this.m_Loader._height); //Loads browser. The 5.000 is a browser ID state and I think it's unused from TSW.
	  
	    var CharID = Character.GetCharacter(Char).GetID().GetInstance().valueOf();
	    var Nic = Character.GetCharacter(Char).GetName(); //Character Nick
        var FName = Character.GetCharacter(Char).GetFirstName(); //First Name
        var LName = Character.GetCharacter(Char).GetLastName(); //Last Name
		var SWLRP_Debug:DistributedValue = DistributedValue.Create("SWLRP_Debug"); //Check Debug value
	//If The target is the player's character or if you clicked the button with no target.  
	if (Character.GetCharacter(Char).IsClientChar())
	{
		//For editing: https://profile.swlrp.com/edit/12345?first=Chuck&nick=TexasRanger&last=Norris
		
		//Title is First name "Nick" Last name
		if (SWLRP_Debug.GetValue())
		{
			this.m_Browser.OpenURL("http://swlrp.incertitu.de/edit/" + CharID + "?first=" + FName + "&nick=" + Nic + "&last=" + LName +"&clientVer=" + MainSWLRP.Version); //Testing
		}
		else
		{
		this.m_Browser.OpenURL("http://profile.swlrp.com/edit/" + CharID+ "?first=" + FName + "&nick=" + Nic + "&last="+ LName +"&clientVer=" + MainSWLRP.Version); //Live
		}
		
	}
	else if (Character.GetCharacter(Char).GetID().IsPlayer())
	{
		//For viewing: https://profile.swlrp.com/view/12345?nick=TexasRanger
		if (SWLRP_Debug.GetValue())
		{
			this.m_Browser.OpenURL("http://swlrp.incertitu.de/view/" + CharID+ "?nick=" + Nic + "&clientVer=" + MainSWLRP.Version); //Testing
		}
		else
		{
		this.m_Browser.OpenURL("http://profile.swlrp.com/view/" + CharID + "?nick=" + Nic + "&clientVer=" + MainSWLRP.Version); //Live
		}
    }
	//Loading the web page content into the window as "content"
	  this.m_Loader.loadMovie("img://browsertexture/" + this.m_Browser.GetBrowserName());
      this.onMouseMove = mx.utils.Delegate.create(this,this.MouseMoveEventHandler);
      this.onMouseDown = mx.utils.Delegate.create(this,this.MouseDownEventHandler);
      this.onMouseUp = mx.utils.Delegate.create(this,this.MouseUpEventHandler);
      this.m_MouseListener = new Object();
      this.m_MouseListener.onMouseWheel = mx.utils.Delegate.create(this,this.MouseWheelEventHandler);
      Mouse.addListener(this.m_MouseListener);
      this.m_Browser.SetFocus(true);
      Selection.setFocus(this);
	  
   }
   

   function onUnload()
   {
      super.onUnload();
      this.onMouseMove = undefined;
      this.onMouseDown = undefined;
      this.onMouseUp = undefined;
      Mouse.removeListener(this.m_MouseListener);
      Selection.setFocus(null);
	  Char = null;
   }
   function MouseMoveEventHandler()
   {
      if(this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
      {
         this.m_Browser.MouseMove(this.GetBrowserMouseLocation().x,this.GetBrowserMouseLocation().y);
      }
   }
   function MouseDownEventHandler()
   {
      if(this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
      {
         this.m_Browser.MouseDown(this.GetBrowserMouseLocation().x,this.GetBrowserMouseLocation().y);
      }
   }
   function MouseWheelEventHandler(delta)
   {
      if(this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
      {
         this.m_Browser.MouseWheel(delta * GUI.SWLRP.SWLRPBrowserContent.SCROLL_AMOUNT);
      }
   }
   function MouseUpEventHandler()
   {
      if(this.m_Loader != undefined && this.m_Loader.hitTest(_root._xmouse,_root._ymouse,true) /*&& Mouse.IsMouseOver(this.m_Loader)*/)
      {
         this.m_Browser.SetFocus(true);
         Selection.setFocus(this);
         this.m_Browser.MouseUp(this.GetBrowserMouseLocation().x,this.GetBrowserMouseLocation().y);
      }
      else
      {
         this.m_Browser.SetFocus(false);
         Selection.setFocus(null);
      }
   }
   function GetBrowserMouseLocation()
   {
      var _loc3_ = new flash.geom.Point();
      _loc3_.x = _root._xmouse - this._parent._x - this._x;
      _loc3_.y = _root._ymouse - this._parent._y - this._y;
      return _loc3_;
   }
   

}
