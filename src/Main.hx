package ;

import js.Browser;
import js.html.Event;
import js.html.Font;
import js.html.KeyboardEvent;
import managers.CharacterManager;
import managers.DrawManager;
import managers.FightManager;
import managers.HudManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import managers.PoolManager;
import managers.StateManager;
import managers.TimeManager;
import objects.Camera;
import objects.Options;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import pixi.core.renderers.Detector;
import pixi.core.renderers.webgl.WebGLRenderer;

//import managers.ZoomManager;

/**
 * ...
 * @author ToTos
 */

class Main 
{
	private static var instance: Main;
	
	private var Init:InitManager;
	public static var drawManager:DrawManager;	
	public static var mouseManager:MouseManager;	
	public static var stateManager:StateManager;
	public static var mapManager:MapManager;
	public static var timeManager:TimeManager;
	public static var characterManager:CharacterManager;
	public static var poolManager:PoolManager;
	public static var fightManager:FightManager;
	
	
	public static var camera:Camera;
	public static var gameOptions:Options;
	
	public var renderer:WebGLRenderer;

	public var fullStage:Container = new Container();
	public var tileCont:Container = new Container();
	public var gameCont:Container = new Container();
	public var hudCont:Container = new Container();
	public var effectCont:Container = new Container();
	public var debugCont:Container = new Container();
	
	public var renderMask:Graphics = new Graphics();
	
	public static var tileSize:Array<Float> = [0,0];
	public static var screenRatio:Array<Float> = [1,1]; // ratio of the scale from 1920x1080 screen
	
	public static var keysDown:Array<Int> = [];
	
	public static var DEBUGMODE:Bool = true;
	public static var GAMESTOPPED:Bool = false;
	
	static function main ():Void {
		Main.getInstance();
	}
	
	private function new () {
	
		gameOptions = Options.getInstance();
		gameOptions.loadOptions();
		
		var font = new Font();
		font.onload = function() { Browser.window.requestAnimationFrame(cast InitManager.getInstance); };
		font.fontFamily = "gastFont";
		font.src = "assets/fonts/Days.otf";
		
		
		renderer = Detector.autoDetectRenderer(1600, 900, {});
		renderer.backgroundColor = 0x171824;
		renderMask.beginFill();
		renderMask.drawRect(0, 0, renderer.width, renderer.height);
		renderMask.endFill();
		
		screenRatio = [renderer.width / 1920, renderer.height / 1080];
		
		fullStage.addChild(renderMask);
		
		tileCont.interactive = true;
		gameCont.interactive = true;
		hudCont.interactive = true;

		fullStage.mask = renderMask;
		Reflect.setField(tileCont, "isoSort", true);
		Reflect.setField(gameCont, "isoSort", true);
		Reflect.setField(hudCont, "isoSort", true);
		
		fullStage.addChildAt(tileCont, 0);
		fullStage.addChildAt(gameCont,1);
		fullStage.addChildAt(hudCont,2);
		fullStage.addChildAt(effectCont, 3);
		
		if (DEBUGMODE) {
			fullStage.addChildAt(debugCont, 4);
		}
		debugCont.name = "debugCont";
		
		renderer.render(fullStage);
		renderer.view.className = "gastCanvas";
		
		
		Browser.document.body.appendChild(renderer.view);
		Browser.window.addEventListener("keydown", keyDownListener);
		Browser.window.addEventListener("keyup", keyUpListener);
	}
	

	public static function getInstance (): Main {
		if (instance == null) instance = new Main();
		return instance;
	}
	
	/*
	 * called after json config recup in InitManager.hx
	 * access it with InitManager.data.config
	 * */
	
	public function Start() {
		poolManager = PoolManager.getInstance();
		drawManager = DrawManager.getInstance();
		timeManager = TimeManager.getInstance();
		mouseManager = MouseManager.getInstance();
		camera = Camera.getInstance();
		mapManager = MapManager.getInstance();
		characterManager = CharacterManager.getInstance();
		fightManager = FightManager.getInstance();
		stateManager = StateManager.getInstance();
		
		Browser.window.addEventListener("resize", resize);
		Browser.window.requestAnimationFrame(cast Update);
	}
	
	public function resize (pEvent:Event): Void {
		//renderer.resize(DeviceCapabilities.width, DeviceCapabilities.height);
		screenRatio = [renderer.width / 1920, renderer.height / 1080];
	}
	
	public function Update() {
		Browser.window.requestAnimationFrame(cast Update);
		if (GAMESTOPPED && DEBUGMODE)
			return;
			
		if(timeManager !=null)
			timeManager.Update();
			
		mouseUpdate();
		characterManager.Update();
		camera.Update();
		stateManager.Update();
	}
	
	public function Render():Void {
		drawManager.isometricSort(MapManager.getInstance().activeMap.mapContainer);
		renderer.render(fullStage);
	}
	
	public function mouseUpdate() {
		mouseManager.calledPerFrame = 0;
	}
	
	public function keyDownListener (e:KeyboardEvent):Void
	{
		if (String.fromCharCode(e.keyCode) == "A" && e.altKey) {
			GAMESTOPPED = !GAMESTOPPED;
		}
		if (keysDown.indexOf(e.keyCode) != -1)
			return;
		keysDown.push(e.keyCode);

		if (FightManager.status == StatusModes.fight)
		{
			var attackIndex:Int = 0;
			if (e.keyCode >= 48)
			{
				attackIndex = e.keyCode - 48;
				attackIndex = attackIndex == 0 ? 10 : attackIndex;
				
				if (HudManager.getInstance().buttonPosition[attackIndex] != null){
					HudManager.getInstance().buttonPosition[attackIndex].emit("mousedown");
					HudManager.getInstance().buttonPosition[attackIndex].emit("mouseup");
					HudManager.getInstance().buttonPosition[attackIndex].emit("mouseout");
				}
			}
		
		}
	}
	
	public function keyUpListener (e:KeyboardEvent):Void
	{
		keysDown.splice(keysDown.indexOf(e.keyCode) , 1);
	}
	
	

	
	public function destroy (): Void {
		instance = null;
	}
	
}

/*
 *	 TODO: 
 * 		
 * 	view angle (ranges)
 * 	====> ajouter ça au player, tester, tester, tester, tester, tester, et voir avec tout les points sur le tour de la range. ou de la range en elle meme. pute.
 * 
 * 
 *   IA ENEMY ZOMBIE
 * 		1 - rush player
 * 	 	2 - attack cac
 * 		3 - attack ranged
 * 	
 * 	new map survival
 * 	mode survival
 * 
 * 	server nodejs  !!!
 * 
 * 	mode normal vs mode fight
 * 	
 * 
 **/










