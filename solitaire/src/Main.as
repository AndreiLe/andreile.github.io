package {
	import basic.*
	import flash.display.Sprite;
	import flash.events.Event;

//[Frame(factoryClass="Preloader")]
public class Main extends Basic {

public function Main():void {
	if (stage) init();
	else addEventListener(Event.ADDED_TO_STAGE, init);
}

private function init(e:Event = null):void {
	removeEventListener(Event.ADDED_TO_STAGE, init);
	// entry point
	//ИНИЦИАЛИЗИРУЕМ
	//Класс Basic
	Basic.initOnce(stage, this)
	//Пользовательские курсоры
	myCursor.init(stage)
	//Событие
	mouseMoveManager.init(stage)
	//Событие
	enterFrameManager.init(stage)
	//ContextMenu или профайлер
	//Инициализируем профайлер
	SWFProfiler.init(stage, this)
	//myContextMenu.init(myMain)
	//Сохранение параметров на локальном диске
	ShareObjectManager.initOnce()
	//Звуки
	SoundManager.initOnce()
	//Таймер
	TimerManager.init()
	//Проверка спонсора
	SponsorManager.initOnce(stage)
	//Реклама
	MochiManager.initOnce(stage)
	
	
	//Игра
	var game:Game = new Game()
	addChild(game)
}

}

}