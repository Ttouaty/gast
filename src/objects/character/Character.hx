package objects.character;
import haxe.Constraints.Function;
import haxe.Json;
import js.Browser;
import managers.CharacterManager;
import managers.DrawManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import objects.Animation;
import pixi.core.graphics.Graphics;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import utils.Id;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */

typedef Stats = {
	var health 			: Float;
	var strength 		: Float;
	var endurance 		: Float;
	var moveSpeed 		: Float;
	var regeneration 	: Float;
	var precision 		: Float;
	var luck 			: Float;
	var AP 				: Float;
}


class Character extends MovieClip{

	public var ID:Id;

	public var tilePos:Array<Int> = [0,0];
	public var directionFacing:Int = 0;
	
	public var inFight:Bool = false;
	
	public var stats:Stats = {
		health 		: 100,
		strength 	: 10,
		endurance 	: 10,
		regeneration: 10,
		moveSpeed	: 2.5,
		precision 	: 10,
		luck 		: 10,
		AP 			: 10
	};
	
	private var activePath:Array<Dynamic> = [];
	private var pathIndex:Int = 1;
	private var activePathPoint:Dynamic;
	
	public var refreshSpeed:Float = 1;
	
	public var charaName:String;
	public var attacks:Map<String,Function>;
	
	public var animations:Map<String,Animation> = new Map.Map();
	public var activeAnimation:Animation;
	public var activeAnimationName:String;
	
	public var config:Dynamic;
	
	public var z:Float = 0;
	public var depth:Float = 0;
	
	/*#################
	*		NEW	 
	* ################# */
	public function new(newName:String) {
		charaName = newName;
		config = InitManager.data[untyped newName];
		super(generateTextures(charaName));
		generateAnimations();
		loop = true;
		
		anchor.set(0.5, 1);
		CharacterManager.getInstance().addCharacter(this);
	}
	
	
	private function generateTextures(newName:String):Array<Texture>{
		var returnArray:Array<Texture> = [];
		var textureData:Array<String> = config.texturesUrls;

		if (textureData == null)
			Browser.window.console.warn("NO TEXTUREDATA FOUND FOR: "+newName);
		
		for (i in textureData.iterator()) {
			returnArray.push(Texture.fromImage(i));
		}
		
		return returnArray;
	}
	
	private function generateAnimations():Void {
		for (i in Reflect.fields(config.animations)) {
			addAnimation(i, Reflect.field(config.animations,i));
		}	
		setAnimation("idle");
	}
	
	public function addAnimation(newName:String, data:Dynamic, ?endCallback){
		animations.set(newName, new Animation(newName,data, endCallback));
	}
		
	public function damage(amount:Float):Void{
		stats.health -= amount;
		if(stats.health <= 0){
			stats.health = 0;
			kill();
		}
	};
	
	/*#################
			UPDATE
	  #################*/
	public function _selfUpdate():Void {
		manageAnim();
		managePathFinding();
		customUpdate();
	}
	
	private function manageAnim():Void {
		if (activeAnimation == null) {
			return;
		}		
		if (currentFrame - activeAnimation.getLastIndex() >= activeAnimation.getFrames(directionFacing).length - 1) {
			if (!activeAnimation.loop) {
				stop();
				activeAnimation.endAction();
			}
			else {
				if (activeAnimation.getFrames(directionFacing).length == 1)
					gotoAndStop(activeAnimation.getFrames(directionFacing)[0]);
				else
					gotoAndPlay(activeAnimation.getFrames(directionFacing)[0]);
			}
		}
	}
	
	private function managePathFinding():Void {
		if (activePath.length != 0) {
			if (activePathPoint == null)
				getNextPathPoint();
			if (tilePos[0] != activePath[activePath.length - 1].x || tilePos[1] != activePath[activePath.length - 1].y){
				var arrayPos = [activePathPoint.x, activePathPoint.y];
				
				//trace(Misc.getDistance(x,y,Misc.convertToAbsolutePosition(arrayPos)[0],Misc.convertToAbsolutePosition(arrayPos)[1]));
				setAbsolutePosition(x + Math.cos(Misc.angleBetweenTiles(tilePos, arrayPos)) * stats.moveSpeed, y - Math.sin(Misc.angleBetweenTiles(tilePos, arrayPos)) * stats.moveSpeed);
				if(Misc.getDistance(x,y,Misc.convertToAbsolutePosition(arrayPos)[0],Misc.convertToAbsolutePosition(arrayPos)[1] + Main.tileSize[1] * 0.5) < stats.moveSpeed)
				{
					// new Point
					setTilePosition(arrayPos);
					pathIndex++;
					if(pathIndex <= activePath.length -1)
						getNextPathPoint();
					else
					{
						activePath = [];
						activePathPoint = null;
					}
				}
			}
		}
	}
	
	private function getNextPathPoint():Void{
		activePathPoint = activePath[pathIndex];
		setDirection(Misc.getDirectionToPoint(tilePos, [activePathPoint.x,activePathPoint.y]));
	}
	
	public function customUpdate():Void{
	
	}
	
	public function setAnimation(animName:String):Void {
		if (!animations.exists(animName)){
			Browser.window.console.warn("anim not found: "+animName);
			return;
		}
		activeAnimation = animations.get(animName);
		activeAnimationName = activeAnimation.name;	
		
		if (activeAnimation.getFrames(directionFacing).length == 1)
			gotoAndStop(activeAnimation.getFrames(directionFacing)[0]);
		else
			gotoAndPlay(activeAnimation.getFrames(directionFacing)[0]);
		animationSpeed = activeAnimation.fps / 60;
	}
	
	public function setDirection(newDir:Int):Void{
		directionFacing = newDir % 4;
		setAnimation(activeAnimationName);
	}
	
	
	
	public function kill():Void{
		trace("TARGET '" + charaName+"' is dead !");
		setAnimation("death");
		/* callback of death animation */  Destroy();
		
		
		// penser a anim de mort
		// penser aux callback sur les anims
	}
	
	
	
	/**
	 * modifie la position du character,
	 * ### /!\ prend en compte le décalage due a l'iso /!\ ###
	 */ 
	public function setTilePosition(position:Array<Int>):Void {
		CharacterManager.getInstance().updateCharacterCoordinatesFromTo(this, position);
	
		tilePos[0] = position[0];
		x = position[0] * Main.tileSize[0] + MapManager.getInstance().activeMap.OffsetX;
		
		tilePos[1] =  position[1];
		y = position[1] * Main.tileSize[1] * 0.5 + MapManager.getInstance().activeMap.OffsetY;
		if (Math.abs(tilePos[1] % 2) == 1)
			x += Main.tileSize[0] * 0.5;
			
		setZ(z);
	}
	

	public function getAbsolutePosition ():Array<Float> {
		var arrayToReturn:Array<Float> = [];
		arrayToReturn[0] = tilePos[0] * Main.tileSize[0];
		arrayToReturn[1] = tilePos[1] * Main.tileSize[1]*0.5;
		if(Math.abs(tilePos[1] % 2) == 1)
			arrayToReturn[0] += Main.tileSize[0] * 0.5;
		return arrayToReturn;
	}
	
	public function setAbsolutePosition (newX:Float, newY:Float):Void {
		x = newX;
		y = newY;
		setZ(z);
	}
	
	public function setZ(newZ:Float):Void{
		z = newZ;
		depth = y + z;
	}
	
	public function findPathTo(target:Array<Int>):Void
	{
		MapManager.finder.setColliTile(tilePos[0], tilePos[1], true);
		followPath(MapManager.getInstance().activeMap.findPath(getPathFindingPoint(), target));
		MapManager.finder.setColliTile(tilePos[0], tilePos[1], false);
	}
	
	public function followPath(path:Array<Dynamic>):Void{
		if (path.length == 0)
			return;
		activePath = path;
		
		pathIndex = activePathPoint != null ? 0 : 1;
		setAnimation("run");
	}
	
	public function launchAttack(targetPosition:Array<Int>):Void{
		if (CharacterManager.getInstance().findCharacterAtTilePos(targetPosition)) {
			// launch attack	
			CharacterManager.getInstance().findCharacterAtTilePos(targetPosition).damage(stats.strength);
		}
	};
	
	public function getPathFindingPoint():Array<Int> {
		if(activePathPoint != null)
			return [activePathPoint.x, activePathPoint.y];
		return tilePos;
	}
	
	public function newTick(tickNumber:Int):Void { 
		
	}
	

	/**
	 * destroy to call for removing a character
	 */
	public function Destroy():Void{
		CharacterManager.getInstance().removeCharacter(this);
		DrawManager.removeFromDisplay(this);
		destroy();
	}

		
}