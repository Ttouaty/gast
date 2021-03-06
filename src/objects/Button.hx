package objects;

import haxe.Constraints.Function;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import pixi.filters.dropshadow.DropShadowFilter;
import pixi.interaction.EventTarget;
import utils.Misc;
/**
 * ...
 * @author ToTos
 */
class Button extends MovieClip {

	private var arrayCallbacks:Dynamic = { };
	
	private var text:Text = new Text("", { "fill":"white", "font":"60px gastFont" } );
	private var isDown:Bool = false;
	private var isAbove:Bool = false;
	
	private var locked:Bool = false;
	
	/**
	 * basic button constructor
	 * 
	 * @param	name The name of the button (ex: 'pouet' will seek "pouet.png" for textures.)
	 * @param	customButtonTexture Are there custom "idle/hover/down" sprites made for the button (ex: "pouet_idle.png"...) (if == false, brightness is used instead)
	 */
	public function new(name:String, customButtonTexture:Bool = false) {
		var arrayTextures:Array<Texture>;

		if (!customButtonTexture)
			arrayTextures = Misc.generateButtonTextures(Texture.fromImage(name+".png"));
		else
		{
			arrayTextures = [];
			arrayTextures.push(Texture.fromImage(name+"_idle.png"));
			arrayTextures.push(Texture.fromImage(name+"_hover.png"));
			arrayTextures.push(Texture.fromImage(name+"_down.png"));
		}
		
		super(arrayTextures);
		
		interactive = true;
		buttonMode = true;
		defaultCursor = "pointer";
		
		anchor.set(0.5,0.5);
		
		arrayCallbacks.down 	= function():Void { };
		arrayCallbacks.up 		= function():Void { };
		arrayCallbacks.hover 	= function():Void { };
		arrayCallbacks.out 		= function():Void { };
		
		//Browser.window.addEventListener("gameMouseDown", p_onDown);
		//Browser.window.addEventListener("gameHover",p_onHover);
		//Browser.window.addEventListener("gameMouseUp", p_onUp);
		
		on("mousedown", p_onDown);
		on("mouseup", p_onUp);
		on("mouseover", p_onHover);
		on("mouseout", p_onOut);
		
		var shadow = new DropShadowFilter();
		shadow.color 	= 0x0000;
		shadow.distance = 5;
		shadow.alpha 	= 0.55;
		shadow.angle 	= 45;
		shadow.blur 	= 5;
	
		filters = [shadow];
		
		
	}
	
	public function setText(newText:String):Void {
		text.text = newText;
		text.visible = true;
		if (text.parent == null && newText.length != 0) {
			text.anchor.set(0.5, 0.5);
			text.scale.set(1 / scale.x, 1 / scale.y);
			addChild(text);
		}
		else if(newText.length == 0){
			text.visible = false;
		}
	};
	
	public function setSpecialTexture(actionName:String){
		if (actionName == "hover")
			gotoAndStop(1);
		else if (actionName == "down")
			gotoAndStop(2);
		else 
			gotoAndStop(0);
	}
	
	private function p_onDown	(e:EventTarget):Void { if (locked) return; isDown = true; setSpecialTexture("down"); arrayCallbacks.down(e); if(e != null)e.stopPropagation(); }
	private function p_onUp		(e:EventTarget):Void { if (locked) return; if (!isDown) return; isDown = false;  setSpecialTexture("hover"); arrayCallbacks.up(e); if(e != null) e.stopPropagation(); }
	private function p_onOut	(e:EventTarget):Void { if (locked) return; isDown = false; setSpecialTexture("idle"); arrayCallbacks.out(e); if(e != null) e.stopPropagation(); }
	private function p_onHover	(e:EventTarget):Void {
		if (locked) return;
		if(isDown)
			setSpecialTexture("down"); 
		else
			setSpecialTexture("hover"); 
		arrayCallbacks.hover(e); 
	}
	
	private function mouseIsAbove(e:EventTarget):Bool {
		return Misc.colliSquarePoint(this, untyped e.data.global);
	}
	
	public function Destroy():Void{
		destroy();
	}

	public function onDown	(newFunction:Function):Void { arrayCallbacks.down 	= newFunction; }
	public function onUp	(newFunction:Function):Void { arrayCallbacks.up 	= newFunction; }
	public function onHover	(newFunction:Function):Void { arrayCallbacks.hover 	= newFunction; }
	public function onOut	(newFunction:Function):Void { arrayCallbacks.out 	= newFunction; }
	
	public function lock():Void { isDown = false ; locked = true; tint = 0x666666; buttonMode = false; }
			
	public function unlock():Void { locked = false;  tint = 0xFFFFFF;  buttonMode = true;}
}