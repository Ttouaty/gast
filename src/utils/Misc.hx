package utils;
import managers.InitManager;
import objects.Camera;
import pixi.core.sprites.Sprite;

/**
 * ...
 * @author ToTos
 */
class Misc {
/*
 * CLASS DE FONCTION DIVERSES !
 * 
 * Règle 1: 
 * 	Mettre toutes les fonctions en static pour pouvoir les appeller facilement
 * 
 * Règle 2: 
 * 	Essayer au maximum de mettre les fonctions spécialisées dans leurs classe respective
 * 	Ici c'est un peux la trousse a outil du jeu, on veux pas que ça devienne trop un bordel absolu.
 * 
 * */

	/**
	 * Fonction de calcul de distance entre 2 objects
	 * @return distance beteween obj1 / obj2
	 */ 
	public static function getDistance (x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var dx:Float = x1 - x2;
		var dy:Float = y1 - y2;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	/**
	 * Calcule l'angle an radian entre les objets S et T
	 * @return angle in radian between S and T 
	 */
	public static function angleBetween (sX:Float,sY:Float, tX:Float,tY:Float):Float {
		return Math.atan2(tX - sX, tY - sY);
	}
	
	/**
	 * convertie une position de tile de grid => en pixel
	 * @return absolute position in PIXELS of tilePosition
	 */
	public static function convertToAbsolutePosition (tilePosition:Array<Int>):Array<Int> {
		var configTileSize:Array<Int> = InitManager.data.config.tileSize;
		var returnPosition:Array<Float> = [];
		returnPosition[0] = tilePosition[0] * configTileSize[0] -1;		
		if (tilePosition[1] % 2 == 1)
			returnPosition[0] += configTileSize[0] * 0.5;		
		returnPosition[1] = tilePosition[1] * configTileSize[1] * 0.5 -1;
		return cast returnPosition;
	}
	
	
	/**
	 * convertie une position de pixel => en tile
	 */
	public static function convertToGridPosition (pixelPosition:Array<Float>):Array<Int> {
		return [Math.floor(pixelPosition[0] / InitManager.data.config.tileSize[0]), Math.floor(pixelPosition[1] / InitManager.data.config.tileSize[1] * 2)];
	}
	
	public static function colliSquarePoint(obj:Sprite, point:Array<Float>, ?cameraAffected:Bool):Bool {
		var offset:Array<Float> = cameraAffected ? Camera.getInstance().offset : [0,0];
		if (obj.x - (obj.width * obj.anchor.x)> point[0] + offset[0])
			return false;
		if (obj.y - (obj.height * obj.anchor.y) > point[1] + offset[1])
			return false;
		if (obj.x + obj.width - (obj.width * obj.anchor.x) < point[0] + offset[0])
			return false;
		if (obj.y + obj.height - (obj.height * obj.anchor.y) < point[1] + offset[1])
			return false;
		
		return true;
	} 
	
	public static function colliSquareSquare(obj1:Sprite,obj2:Sprite):Bool{
		if (obj1.x - obj1.width * obj1.anchor.x > obj2.x + obj2.width - obj2.width * obj2.anchor.x)
			return false;
		if (obj1.y - obj1.height * obj1.anchor.y > obj2.y + obj2.height - obj2.height * obj2.anchor.y)
			return false;
		if (obj1.x + obj1.width - (obj1.width * obj1.anchor.x) < obj2.x - obj2.width * obj2.anchor.x)
			return false;
		if (obj1.y + obj1.height - (obj1.height * obj1.anchor.y) < obj2.y - obj2.height * obj2.anchor.y)
			return false;
		
		return true;
	} 
	
	/**
	 * Clamps the value of Number between min and max,
	 * notes that it doesn't change the value straight away
	 * USE :
	 * number = Misc.Clamp(number, 0 , 5);
	 * @return the clamped value;
	 */
	public static function clamp(number:Float, min:Float, max:Float):Float {
		if (number < min)
			return min;
		if (number > max)
			return max;
		return number;
	}
}