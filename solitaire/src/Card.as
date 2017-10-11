package  {
	import adobe.utils.XMLUI;
	import basic.Basic;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

public class Card extends Basic {
	
	public static var myGame:Game
	
	//public var pieceProp:PieceProp = new PieceProp()
	//Цвет
	public var  sideColor:int = 0
	//Масть
	public var suit:int = 0
	//Номер
	public var num:int = 0
	//Стандартные размеры карты
	public static var cardW:int = 50
	public static var cardH:int = 75
	//Насколько карты выходят одна из другой в колоде
	public static var cardMarginX:int = cardW / 2
	public static var cardMarginY:int = cardH / 5
	//В зависимости от масти
	public static var cardColor:Array = [0x000000, 0x232323, 0xFF0000, 0x800000]
	//Расположение карты на поле
	public var cardX:Number = 0
	public var cardY:Number = 0
	//Открыта или закрыта
	public var opened:Boolean = false
	//Доступна
	private var locked:Boolean = true
	//Задняя часть
	private var backSide:Sprite = new Sprite()
	//Подсветка
	private var tipSprite:Sprite = new Sprite()
	//Старая позиция карты, куда она может вернуться
	public var oldX:int = 0
	public var oldY:int = 0
	//Новая позиция карты куда она двигается
	public var newX:int = 0
	public var newY:int = 0
	//Ссылка на массив которому принадлежит карта
	public var arr:Array
	public var packNum:int
	public var pack:Pack
	
public function Card() {


}

public function create():void {
	//Фон
	var g:Graphics = this.graphics
	g.lineStyle(1, 0x0000FF);	
	g.beginFill(cardColor[suit]);	
	g.drawRect(0, 0, cardW, cardH)
	g.endFill()
	//Текст
	var label:TextField = new TextField();
	label.text = String(num)
	label.autoSize = TextFieldAutoSize.LEFT;
	label.background = true;
	label.border = true;

	var format:TextFormat = new TextFormat();
	format.font = "Verdana";
	format.color = 0xFF0000;
	format.size = 10;
	format.underline = true;

	label.defaultTextFormat = format;
	addChild(label);
	
	//Задняя часть
	//Фон 
	g = backSide.graphics
	g.lineStyle(1,0xFF0000);	
	g.beginFill(0x008040);	
	g.drawRect(0, 0, cardW, cardH)
	g.endFill()
	//Добавляем на поле
	addChild(backSide)
	backSide.mouseEnabled = false
	
	var tipMargin:int = cardW / 20
	//Подсказка
	//Фон 
	g = tipSprite.graphics
	g.lineStyle(2,0x00FF00);	
	//g.beginFill(0x008040);	
	g.drawRect(0, 0, cardW, cardH)
	
	g.drawRoundRect(-tipMargin,-tipMargin, cardW + tipMargin*2, cardH + tipMargin*2, tipMargin, tipMargin)
	g.endFill()
	//Добавляем на поле
	addChild(tipSprite)
	tipSprite.mouseEnabled = false
	tipSprite.visible = false
	
	//Определяем цвет
	setSuit(suit)
	//lock = false
}

public function get lock():Boolean {
	return locked
}

public function get open():Boolean {
	return opened
}

public function setSuit(suit:int):void {
	this.suit = suit
	//Определяем цвет
	//0,1 = черные
	//2,3 = красные
	if (suit <= 1) {
		sideColor = 0
	}else {
		sideColor = 1
	}
}

public function lockCard(param:Boolean = true):void {
	locked = param
	//backSide.visible = param
	
}

public function openCard(param:Boolean = true):void {
	opened = param
	backSide.visible = (param)? false : true
	
}

public function move(myPack:Pack):void {
	//Меняем положение колоды
	//trace("move", myPack.x, myPack.y)
	
	
	//Двигаем постепенно карту
	//myGame.addMoveCard(this, new Point(this.x, this.y), new Point(myPack.x, myPack.y))
	
	//this.x = myPack.x
	//this.y = myPack.y
	//Новое положение карты
	this.newX = myPack.x
	this.newY = myPack.y
	//Меняем массив и колоду
	var newArr:Array = myPack.link
	newArr.push(this)
	
	//Старый массив
	var oldArr:Array = this.arr
	//Расположение карты в массиве
	var index:int = oldArr.indexOf(this)
	//Убираем данную карту из старого массива
	var test:Card = oldArr.splice(index, 1)[0]
	
	//Старая колода
	var oldPack:Pack = this.pack
	
	//Двигаем новую колоду
	myPack.x += myPack.moveX
	myPack.y += myPack.moveY
	//Двигаем старую колоду
	oldPack.x -= oldPack.moveX
	oldPack.y -= oldPack.moveY
	//trace(myPack.x, myPack.y)
	
	//Меняем колоду и массив
	this.pack = myPack
	this.arr = newArr
	
	//Открываем последнюю карту
	unlockLastCard(oldPack)
}

public function unlockLastCard(oldPack:Pack):void {
	//Проверяем тип
	if (oldPack.kind != Pack.PLAY && oldPack.kind != Pack.READY) return
	//Получаем массив
	var packArr:Array = oldPack.link
	//Размер оставшейся колоды
	var L:int = packArr.length
	if (L <= 0 ) return
	//Открываем последнюю карту в колоде
	var lastCard:Card = packArr[L - 1] as Card
	//Запоминаем положение
	//lastCard.oldX = lastCard.x
	//lastCard.oldY = lastCard.y
	//Запоминаем
	//myGame.checkInHistory(lastCard)
	//trace("unlockLastCard",lastCard.oldX, lastCard.oldY)
	
	lastCard.lockCard(false)
	lastCard.openCard(true)
}

public function showTip(param:Boolean):void {
	tipSprite.visible = param
}

}}
/*
class PieceProp {
	public var target:String
	public var tempX:Number
	public var tempY:Number
	public var x:Number
	public var y:Number
	public var scale:Number
	
public function PieceProp ( tempX:int = 0, tempY:int = 0, target:String = "" ):void {
	this.target = target
	this.tempX = tempX
	this.tempY = tempY
}

}*/