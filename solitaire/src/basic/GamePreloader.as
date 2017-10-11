package basic {
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

public class GamePreloader extends Basic{
	//Окно загрузки
	private var progressBar:Shape = new Shape()
	
public function GamePreloader() {
	//Создаем прелоадер
	var g:Graphics = this.graphics
	g.beginFill(0x000000)
	g.drawRect(0, 0, SW, SH)
	//Создаем окно закрузки
	//Окно закрузки
	var progressCont:Sprite = new Sprite()
	//FonManager.makeFon9(progressCont, 12, 1, new Rectangle(0, 0, 224, 40), false, false)
	progressCont.x = (SW - progressCont.width) >> 1
	progressCont.y = (SH - progressCont.height) >> 1
	
	this.addChild(progressCont)
	//Добавляем контейнер для отрисовки полосы загрузки
	progressCont.addChild(progressBar)
}

public function progress(count:Number = 0):void {
	//Показываем загрузку
	var g:Graphics = this.progressBar.graphics
	g.clear()
	g.beginFill(0x00FF40)
	g.drawRect(12, 12, count * 40, 16)	
}

public function complite():void {
	//Постепенно удаляем прелоадер
	this.addELFrame(this,movePreloader, 1, 0, AppMode.ALL, 8)
}

private function movePreloader(event:Event = null, count:int = 0, end:Boolean = true):void {
	//Скрываем прелоадер
	this.alpha -= 0.1
	//Если вывод закончился, то останавливаем функцию
	if (end) {
		removeELFrame(this, movePreloader)
		free(this,true)
	}
}


}}