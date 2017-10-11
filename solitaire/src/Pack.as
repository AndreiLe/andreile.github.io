package  {

public class Pack {
	//Типы колод и приоритет в  тоже время
	public static var DEF:int = 3
	public static var PLAY:int = 1
	public static var READY:int = 0
	public static var EMPTY:int = 2
	
	
	public var x:Number = 0
	public var y:Number = 0
	public var W:int = 0
	public var H:int = 0
	public var link:Array
	//Приоритет над другими
	public var prioritet:int = 0
	//Тип колоды
	public var kind:int = 0
	//Тип колоды по сдвиганию
	public var moveX:Number = 0
	public var moveY:Number = 0
	
	//Тип колоды
	public var suit:int = 0

public function Pack() {

}

}}