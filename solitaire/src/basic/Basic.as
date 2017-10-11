package basic{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import basic.*;

public class Basic extends Sprite {
	
	public static const PI:Number = Math.PI
	//Работать при полном экране
	public static var enableFullScreen:Boolean = true
	//Минимальный размер сцены
	public static var minSW:Number
	public static var minSH:Number
	//Максимальный размер сцены
	public static var maxSW:Number
	public static var maxSH:Number
	//Половина минимального размера сцены
	public static var minSW2:Number
	public static var minSH2:Number
	//Размер полного экрана
	public static var SW:Number
	public static var SH:Number
	//Половина полного экрана
	public static var SW2:Number
	public static var SH2:Number
	//Ссылка на главный класс
	public static var myMain:Main
	// Ссылка на сцену
	public static var myStage:Stage
	//Менеджер Cursor
	public static var myCursor:cursorManager = new cursorManager()
	//Менеджер BitmapFilter
	public static var myBFilters:BitmapFilterManager = new BitmapFilterManager()
	//Менеджер ColorFilter
	public static var myCFilters:ColorFilterManager = new ColorFilterManager()
	//Менеджер ContextMenu
	public static var myContextMenu:ContextMenuManager = new ContextMenuManager()
	//ПЕРЕМЕННЫЕ ДЛЯ РАБОТЫ С ПУЛОМ
	private var myEventInfo:EventInfoPool = new EventInfoPool()
	
	private var myEventInfo2:EventInfoPool = new EventInfoPool()

public function get lengthEL():int {
	//Количество зарегестрированных прослушивателей
	return myEventInfo.keyLength
}

public function get poolLength():int {
	//Количество неиспользуемых контейнеров прослушивателей
	return myEventInfo.poolLength
}

public function get poolInUse():int {
	//Общее количество зарегестрированных прослушивателей всеми классами
	return myEventInfo.poolInUse
}

public function get allPoolAndKeys():int {
	//Общее количество созданных контейнеров
	return myEventInfo.allPoolAndKeys
}
/**
 * Заполняем данные класса параметрами
 * @param	stage
 * @param	main
 * @param	_minSW
 * @param	_minSH
 * @param	_SW
 * @param	_SH
 */
public static function initOnce(stage:Stage, main:Main):void {
	
	//Передаем параметры
	myStage = stage
	myMain = main
	
	//Размеры экрана для рисования страниц
	stageSize()
}

public static function stageSize():void {
	//Размеры свернутого экрана
	minSW = myStage.stageWidth
	minSH = myStage.stageHeight
	
	//Размеры раскрытого экрана
	maxSW = myStage.fullScreenWidth
	maxSH = myStage.fullScreenHeight
	
	//Размеры полного экрана
	SW = myStage.stageWidth
	SH = myStage.stageHeight

	//Половины размеров
	minSW2 = minSW>>1
	minSH2 = minSH>>1
	SW2 = SW>>1
	SH2 = SH>>1
}
/**
 * Ставим прослушиватель и метку
 * @param	container
 * @param	type
 * @param	listener
 * @param	useCapture
 * @param	priority
 * @param	useWeakReference
 */
public function addEL(container:Object, type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
	//Проверяем условия и добавляем прослушиватель, если проверка прошла успешно
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = type, 
		eventArg.listener = listener,
		eventArg.useCapture = useCapture,
		eventArg.priority = priority,
		eventArg.useWeakReference = useWeakReference
	
	myEventInfo.addOne(eventArg)
}
/**
 * Ставим прослушиватель в Mouse_Move_Manager и метку 
 * @param	container
 * @param	listener
 * @param	useCapture
 * @param	priority
 * @param	useWeakReference
 */
public function addELMove(container:Object, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
	//Проверяем условия и добавляем прослушиватель, если проверка прошла успешно
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = MouseEvent.MOUSE_MOVE, 
		eventArg.listener = listener,
		eventArg.manager = "Mouse_Move_Manager"
	
	myEventInfo.addOne(eventArg)
}
/**
 * Ставим прослушиватель в Enter_Frame_Manager и метку 
 * @param	container
 * @param	listener
 * @param	prioritet
 * @param	view
 * @param	endFlag
 */
public function addELFrame(container:Object, listener:Function, delay:int = 1, prioritet:int = 0, view:int = AppMode.ALL, endFlag:int = -1):void {
	//события получаемые listener(event:Event = null, count:int = 0, end:Boolean = true)
	//Проверяем условия и добавляем прослушиватель, если проверка прошла успешно
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = Event.ENTER_FRAME, 
		eventArg.listener = listener,
		eventArg.delay = delay,
		eventArg.manager = "Enter_Frame_Manager",
		eventArg.prioritet = prioritet,
		eventArg.view = view
		eventArg.endFlag = endFlag
	
	myEventInfo.addOne(eventArg)
}

public function addELTimer(container:Object, listener:Function, delay:int = 1, prioritet:int = 0, view:int = AppMode.ALL, endFlag:int = -1):void {
	//Промежуток 
	//события получаемые listener(event:Event = null, count:int = 0, end:Boolean = true)
	//Проверяем условия и добавляем прослушиватель, если проверка прошла успешно
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = TimerEvent.TIMER, 
		eventArg.listener = listener,
		eventArg.delay = delay,
		eventArg.manager = "Timer_Manager",
		eventArg.prioritet = prioritet,
		eventArg.view = view
		eventArg.endFlag = endFlag
	
	myEventInfo.addOne(eventArg)
}

public function addELSound(container:Object, item:int, index:int = -1, position:int = 0, startFade:int = 0, endFade:int = 0, view:int = AppMode.ALL):void {
	//Проверяем условия и добавляем прослушиватель, если проверка прошла успешно
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.item = item, 
		eventArg.index = index,
		eventArg.manager = "Sound_Manager",
		eventArg.position = position,
		eventArg.view = view
		eventArg.startFade = startFade
		eventArg.endFade = endFade
	
	myEventInfo.addOne(eventArg)
}
/**
 * Удаляем прослушиватель и метку 
 * @param	container
 * @param	type
 * @param	listener
 * @param	useCapture
 */
public function removeEL(container:Object, type:String, listener:Function, useCapture:Boolean = false):void {
	//Если такой прослушиватель есть у обьекта, то убираем его
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = type, 
		eventArg.listener = listener,
		eventArg.useCapture = useCapture,
	
	myEventInfo.removeOne(eventArg)
}

public function removeELMove(container:Object, listener:Function):void {
	//Если такой прослушиватель есть у обьекта, то убираем его
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = MouseEvent.MOUSE_MOVE, 
		eventArg.listener = listener,
		eventArg.manager = "Mouse_Move_Manager",
	
	myEventInfo.removeOne(eventArg)
}

public function removeELFrame(container:Object, listener:Function):void {
	//Если такой прослушиватель есть у обьекта, то убираем его
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = Event.ENTER_FRAME, 
		eventArg.listener = listener,
		eventArg.manager = "Enter_Frame_Manager",
	
	myEventInfo.removeOne(eventArg)
}

public function removeELTimer(container:Object, listener:Function):void {
	//Если такой прослушиватель есть у обьекта, то убираем его
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.type = TimerEvent.TIMER, 
		eventArg.listener = listener,
		eventArg.manager = "Timer_Manager",
	
	myEventInfo.removeOne(eventArg)
}

public function removeELSound(container:Object, item:int, index:int = -1, endFade:int = 0):void {
	//Если такой прослушиватель есть у обьекта, то убираем его
	var eventArg:EventArgument = new EventArgument()
		eventArg.container = container, 
		eventArg.item = item, 
		eventArg.manager = "Sound_Manager",
	
	myEventInfo.removeOne(eventArg)
}

public function removeSomeEL(values:Object = null,invert:Boolean = false):void {
	if (values == null) 
		return
	//Удаляем элементы
	myEventInfo.removeSome(values,invert,true)
}

public function removeAllEL():void {
	//Удаляем все прослушиватели из памяти и объекта
	myEventInfo.removeAll()
}

public function hasEL(type:String, container:Object = null):Boolean {
	(container == null)
		return false
	//Определяем класс полученного контейнера
	if (container is IEventDispatcher) {
		return container.hasEventListener(type)
	}
	return false
}

public function hasELinArray(values:Object = null,invert:Boolean = false):int {
	if (values == null) 
			return lengthEL
	//Пересчитываем все прослушиватели не удаляя
	return myEventInfo.removeSome(values,invert,false)
}
/**
 * Очистка контейнеров от данных
 * @param	container
 * @param	clearAll
 */
public function free(container:Object, clearAll:Boolean = false):void {
	if (container == null)
		return
	//Переменные для циклов
	var cLength:int = 0
	var p:String = ""
	var contClass:Class = Object(container).constructor;
	//Обрабатываем контейнер
	if (contClass == Array) {
		//Размер массива
		cLength = container.length
		//Очищаем массив от объектов
		while (cLength--) {
			free(container[cLength], true)
			container.splice(cLength, 1);
		}
	}
	if (contClass == Object) {
		//Очищаем контейнер от объектов
		for (p in container) {
			free(container[p], true)
			delete container[p]
		}
	}
	if (contClass == Dictionary) {
		//Очищаем контейнер от объектов
		for (p in container) {
			free(container[p], true)
			delete container[p]
		}
	}
	//Удаляем прослушиватели
	if (container is Basic) {
		//Удаляем все прослушиватели из памяти и объекта
		container.removeAllEL()
	}
	
	//Удаляем прослушиватели
	if (container is ReklamClip) {
		//var container:ReklamClip = new ReklamClip()
		//trace("stage = ", container.stage)
		//container.visible = false
		//Удаляем все прослушиватели из памяти и объекта
		//container.removeAllEL()
		//if (container is DisplayObject){
			//if (container.parent != null) {
				//container.parent.removeChild(container)	
			//}
		//}
		MochiManager.onShowed(container)
	}else if (container is DisplayObjectContainer) {
		//Очищаем контейнер от дочерних объектов
		//Колличество дочерних элементов
		//Так быстрее чем с L--
		while (container.numChildren) {
			var contChild:Object = container.getChildAt(0)
			if (contChild == null)
				break
			//Ощищаем и объекты входящие в данный объект
			free(container.getChildAt(0), true)
		}
	}
	//Удаляем сам контейнер
	if (clearAll) {
		if (container is DisplayObject){
			if (container.parent != null) {
				container.parent.removeChild(container)	
			}
		}
		//Очищаем Bitmap
		if (container is Bitmap) {
			if(container.bitmapData)
				container.bitmapData.dispose()
		}
		container = null
	}
}
/**
 * Заливка контейнера определенным изображением
 * @param	container
 * @param	img
 * @param	_w
 * @param	_h
 */
public static function paint(container:Sprite, img:Class, _w:int, _h:int):void {
	var newImg:Bitmap = new img() as Bitmap
	//Узнаем размеры фоновой картинки
	var IW:uint = newImg.width
	var IH:uint = newImg.height
	//Необходимо картинок
	var WLength:uint = Math.ceil((_w - IW) / IW)
	var HLength:uint = Math.ceil((_h - IH) / IH)
	//Точка начало отрисовки
	var StartX:int = 0
	var StartY:int = 0
	//Добавляем все картинки в контейнер
	var num:uint = 0
	var fon:Bitmap;
	for (var i:uint = 0; i < WLength + 1; i++) {
		for (var j:uint = 0; j < HLength + 1; j++) {
			fon = new img()
			fon.x = StartX + i*IW
			fon.y = StartY + j*IH
			container.addChild(fon);
		}
		num++
	}
}

}}