package ;

import js.Browser;
import js.html.Event;
import js.html.Font;
import managers.CharacterManager;
import managers.DrawManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import managers.StateManager;
import managers.TimeManager;
import objects.Camera;
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
	
	private var Init:InitManager = InitManager.getInstance();
	public static var drawManager:DrawManager;	
	public static var mouseManager:MouseManager;	
	public static var stateManager:StateManager;
	public static var mapManager:MapManager;
	public static var timeManager:TimeManager;
	public static var characterManager:CharacterManager;
	public static var camera:Camera;
	
	public var renderer:WebGLRenderer;

	public var fullStage:Container = new Container();
	public var tileCont:Container = new Container();
	public var gameCont:Container = new Container();
	public var hudCont:Container = new Container();
	public var effectCont:Container = new Container();
	public var debugCont:Container = new Container();
	
	public var renderMask:Graphics = new Graphics();
	
	public static var DEBUGMODE:Bool = true;
	
	static function main ():Void {
		Main.getInstance();
	}
	
	private function new () {
		renderer = Detector.autoDetectRenderer(1280, 720, {});
		renderer.backgroundColor = 0x171824;
		renderMask.beginFill();
		renderMask.drawRect(0, 0, renderer.width, renderer.height);
		renderMask.endFill();
		
		fullStage.addChild(renderMask);
		
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
		drawManager = DrawManager.getInstance();
		mouseManager = MouseManager.getInstance();
		camera = Camera.getInstance();
		mapManager = MapManager.getInstance();
		characterManager = CharacterManager.getInstance();
		timeManager = TimeManager.getInstance();
		
		stateManager = StateManager.getInstance();
		Browser.window.addEventListener("resize", resize);

		
		var font = new Font();
		font.onload = function() { Browser.window.requestAnimationFrame(cast Update); };
		font.fontFamily = "gastFont";
		font.src = "assets/fonts/CharlemagneStd-Bold.otf";
		
	}
	
	public function resize (pEvent:js.html.Event = null): Void {
		//renderer.resize(DeviceCapabilities.width, DeviceCapabilities.height);
	}
	
	public function Update() {
		Browser.window.requestAnimationFrame(cast Update);
		timeManager.Update();
		mouseUpdate();
		characterManager.update();
		stateManager.Update();
	}
	
	public function Render():Void {
		drawManager.isometricSort(MapManager.getInstance().activeMap.mapContainer);
		drawManager.isometricSort(gameCont);
		renderer.render(fullStage);
	}
	
	public function mouseUpdate() {
		mouseManager.calledPerFrame = 0;
	}
	
	public function destroy (): Void {
		instance = null;
	}
	
}











