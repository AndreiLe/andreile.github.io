package  {
	import basic.AppMode;
	import basic.GamePreloader;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import basic.Basic;
	import flash.ui.Mouse;

public class Game extends Basic {
	//Сохранение истории
	public var historyArr:Array = []
	
	//Настройки поля
	public var deskContProp:MoveZoomPropities = new MoveZoomPropities()
	
	//Количество мастей 4
	public var suitTotal:int = 4
	//Количество карт 13
	public var cardsTotal:int = 13
	
	
	//Главная колода
	public var packDef:Array = []
	//Пустая колода
	public var emptyPack:Array = []
	
	//Игровые колоды
	//Количество игровых колод 
	public var playNum:int = 7
	//Количество строк в колоде для заполнения в начале
	public var playPackNum:Array = []
	public var playPackArr:Array = []
	
	//Готовые колоды, которые надо собрать. Равные количеству мастей в колоде
	public var readyNum:int = suitTotal
	//Массивы готовых колод
	public var readyPackArr:Array = []
	
	//Все колоды для расчетов
	public var allPackArr:Array = []

	private var activeCard:Card
	
	private var activeSprite:Sprite = new Sprite()
	public var activeProp:ActiveProp = new ActiveProp()
	public var activeArr:Array = []
	
	//Поле основной колоды
	public var mainPackCont:Sprite = new Sprite()
	//Кнопка назад
	public var historyButton:Sprite = new Sprite()
	//Счетчик истории
	public var historyStep:int = 0
	
	//Кнопка подсказки
	public var tipsButton:Sprite = new Sprite()
	//Массив доступных карт
	public var tipsArr:Array = []
	
	//Количество итераций прелоадера
	//Количество страниц для создания
	private var preloaderNum:int = 4		
	//Прелоадер игры
	private var gamePreloader:GamePreloader
	//Поле игры
	private var gameDesk:Sprite
	
	//Массив карт для перемещения
	private var moveCardArr:Array = []
	//Флаг анимации
	private var moveCardFlag:Boolean = true
	//Скорость анимации
	private var moveCardSpeed:Number = 10
	
	//Количество карт выходящих с основой колоды
	private var defCarfNum:int = 3
	
public function Game() {
	//Передаем ссылку на экземпляр
	Card.myGame = this
	
	//Создаем стол игры
	gameDesk = new Sprite()
	this.addChild(gameDesk)

	//Создаем страницу загрузки
	gamePreloader = new GamePreloader()
	this.addChild(gamePreloader)
	//Запускаем установку игры
	//+1 чтобы показать прелоадер без задержки
	addELFrame(this, start, 1, 0, AppMode.ALL, preloaderNum + 1)
}

private function prepareGame1():void {
	//Рисуем поле
	var g:Graphics = gameDesk.graphics
	g.lineStyle(1, 0x000000);	
	g.beginFill(0x515151);	
	g.drawRect(0, 0, SW, SH)
	g.endFill()
	
	//Добавляем элементы на поле
	gameDesk.addChild(activeSprite)
	gameDesk.addChild(mainPackCont)
	
	this.addChild(historyButton)
	paintSide(0, 0, 20, 20, historyButton)
	historyButton.x = 200
	historyButton.y = 0
	addEL(historyButton, MouseEvent.MOUSE_DOWN, backToHistory)
	
	this.addChild(tipsButton)
	paintSide(0, 0, 20, 20, tipsButton)
	tipsButton.x = 250
	tipsButton.y = 0
	addEL(tipsButton, MouseEvent.MOUSE_DOWN, showTips)
	//Показываем всегда подсказки после любого хода
	
	//Глобальные слушатели
	addEL(this, MouseEvent.MOUSE_UP, onGlobal)
	
	//Создаем колоду
	var L:int = suitTotal
	var L1:int = cardsTotal
	
	while (L--) {
		L1 = cardsTotal
		while (L1--) {
		//for (var L1 = 0; L1 < cardsTotal; L1++ ) {
			//Создаем карту
			var cardItem:Card = new Card()
			cardItem.suit = L
			cardItem.num = L1
			cardItem.arr = packDef
			cardItem.create()
			//Добавляем ее в колоду
			packDef.push(cardItem)
			//trace(L, L1)
		}
	}
	
	//Создаем игровые колоды
	//Необходимо карт всего
	var playPackTotal:int = 0
	//Количество игровых колод
	L = playNum
	while (L--) {
		//количество строк
		playPackNum[L] = L + 1
		//Новый массив
		playPackArr[L] = []
		//Счетчик
		playPackTotal++
	}
	
	//Создаем готовые колоды
	//Количество игровых колод
	L = readyNum
	while (L--) {
		//Новый массив
		readyPackArr[L] = []
	}
}

private function onGlobal(event:MouseEvent = null):void {
	//Показываем подсказки
	showTips(event)
	//Проверяем окончание игры
	//checkGameEnd()
	//Проверяем автозаполнение
	
}

private function checkGameEnd():void {
	//Находим колоду куда скидываем карты и откуда
	var emptyEnd:Boolean = false
	var defEnd:Boolean = false
	var playEnd:Boolean = false
	var bufArr:Array
	var bufPack:Pack
	var L:int = allPackArr.length
	while (L--) {
		bufPack = allPackArr[L] as Pack
		//Находим нужные нам колоды
		if (bufPack.kind == Pack.EMPTY || bufPack.kind == Pack.DEF || bufPack.kind == Pack.PLAY) {
			bufArr = bufPack.link
			if (bufArr.length > 0) {
				trace("gameEnd FALSE")
				return
			}
		}
	}
	
	trace("gameEnd TRUE")
}

private function prepareGame2():void {
	
	//return
	
	//Раскидываем карты по игровым колодам
	//Массив с номерами выбранными из списка
	var L:int = playNum
	while (L--) {
		
		//Количество строк для заполнения
		var L1:int = playPackNum[L]
		
		while (L1--) {
			//Выбираем номер из массива
			var rnd:int = Math.round(Math.random() * (packDef.length-1))
			//Берем число под данным номером, и удаляем из общего массива
			var newCard:Card = packDef.splice(rnd, 1)[0]
			//Проверяем карту
			if(newCard == null) break
			//Добавляем в массив данную карту
			var arr:Array = playPackArr[L] as Array
			arr.push(newCard)
			newCard.arr = arr
			newCard.packNum = L
			
			//newCard.packNum = L
			//newCard.packNum = L
			
			
			//Открываем последние карты в колоде
			if (L1 == 0) {
				newCard.lockCard(false)
				newCard.openCard(true)
			}else {
				newCard.lockCard(true)
				newCard.openCard(false)
			}
		}

	}
		
	//Перемешиваем колоду
	
	//Массив с номерами выбранными из списка
	L = packDef.length
	var bufArr:Array = []
	while (L--) {
		//Выбираем номер из массива
		rnd = Math.round(Math.random() * (packDef.length-1))
		//Берем число под данным номером, и удаляем из общего массива
		newCard = packDef.splice(rnd, 1)[0]
		//Добавляем в массив данную карту
		bufArr.push(newCard)
	}
	
	L = bufArr.length
	while (L--) {
		//Выбираем номер из массива
		rnd = Math.round(Math.random() * (bufArr.length-1))
		//Берем число под данным номером, и удаляем из общего массива
		newCard = bufArr.splice(rnd, 1)[0]
		//Добавляем в массив данную карту
		packDef.push(newCard)
	}


}

private function prepareGame3():void {
	
	var bufArr:Array = null
	
	var marginX:Number = 10
	var marginY:Number = 20
	
	var startX:Number = 50
	var startY:Number = 50
	
	//РАСТАВЛЯЕМ ПО ПОЛЮ КАРТЫ
	var newPack:Pack = new Pack()

	//Размеры карты
	var cardW:int = Card.cardW
	var cardH:int = Card.cardH
	var cardMoveX:int = Card.cardMarginX
	var cardMoveY:int = Card.cardMarginY
	
	//Готовые колоды
	var L:int = readyNum
	//Расположение последней карты
	var readyPoint:Point = new Point(startX, startY)
	while (L--) {
		newPack = new Pack()
		newPack.kind = Pack.READY
		newPack.x = readyPoint.x
		newPack.y = readyPoint.y
		newPack.W = cardW
		newPack.H = cardH
		newPack.moveX = 0
		newPack.moveY = -0.5
		newPack.suit = L //Тип колоды
		newPack.link = readyPackArr[L]
		newPack.prioritet = Pack.READY
		allPackArr.push(newPack)
		//Счетчик расположения
		readyPoint.x = newPack.x + cardW + marginX
		readyPoint.y = startY
		paintSide(newPack.x, newPack.y, newPack.W, newPack.H)
		
	}
	
	//Пустая колода
	var emptyPoint:Point = new Point(readyPoint.x, readyPoint.y)
	newPack = new Pack()
	newPack.kind = Pack.EMPTY
	newPack.x = emptyPoint.x
	newPack.y = emptyPoint.y
	newPack.W = cardW
	newPack.H = cardH
	newPack.moveX = 0
	newPack.moveY = 0
	newPack.link = emptyPack
	newPack.prioritet = Pack.EMPTY
	allPackArr.push(newPack)
	//paintSide(newPack.x, newPack.y, newPack.W, newPack.H)

	//Исходная колода
	var defPoint:Point = new Point(emptyPoint.x, emptyPoint.y)
	newPack = new Pack()
	newPack.kind = Pack.DEF
	newPack.x = defPoint.x + (cardW + marginX)*2
	newPack.y = defPoint.y
	newPack.W = cardW
	newPack.H = cardH
	newPack.moveX = 0
	newPack.moveY = -0.5
	newPack.link = packDef
	newPack.prioritet = Pack.DEF
	allPackArr.push(newPack)
	//paintSide(newPack.x, newPack.y, newPack.W, newPack.H)
	paintSide(0, 0, newPack.W, newPack.H, mainPackCont)
	mainPackCont.x = newPack.x
	mainPackCont.y = newPack.y
	addEL(mainPackCont, MouseEvent.MOUSE_DOWN, defOnClick)
	
	//return
	
	//Игровые колоды
	L = playNum
	//Расположение последней карты
	var playPoint:Point = new Point(startX, startY + cardH + marginY)
	for (var i:int = 0; i < L; i++ ) {
		newPack = new Pack()
		newPack.kind = Pack.PLAY
		newPack.x = playPoint.x
		newPack.y = playPoint.y
		newPack.W = cardW
		newPack.H = cardH
		newPack.moveX = 0
		newPack.moveY = cardMoveY
		newPack.link = playPackArr[i]
		newPack.prioritet = Pack.PLAY
		allPackArr.push(newPack)
		//Счетчик расположения
		playPoint.x = newPack.x + cardW + marginX
		playPoint.y = newPack.y
		paintSide(newPack.x, newPack.y, newPack.W, newPack.H)
	}
}

private function prepareGame4():void {
	
	//Раставляем карты
	//return
	var L:int = allPackArr.length
	var moveCard:Card
	while (L--) {
		//Берем колоду
		var movePack:Pack = allPackArr[L] as Pack
		
		//if (movePack == null || movePack.kind == Pack.DEF || movePack.kind == Pack.READY || movePack.kind == Pack.EMPTY) continue
		
		//Берем массив карт
		var newArr:Array = movePack.link
		var L1:int = newArr.length
		//Раставляем по порядку
		for (var i:int = 0; i < L1; i++ ) {
			//Разбираем новый массив
			moveCard = newArr[i] as Card
			moveCard.x = movePack.x
			moveCard.y = movePack.y
			
			moveCard.cardX = movePack.x
			moveCard.cardY = movePack.y
			
			moveCard.oldX = movePack.x
			moveCard.oldY = movePack.y
			//Новое положение карты
			moveCard.newX = movePack.x
			moveCard.newY = movePack.y
			
			moveCard.pack = movePack
			gameDesk.addChild(moveCard)
			
			//trace(movePack.x, movePack.y)
			//Смещаем
			movePack.x += movePack.moveX
			movePack.y += movePack.moveY
				
		}
	}

}

private function prepareGame5():void {
		
	//Ставим прослушиватели на кусочки
	addEL(this, MouseEvent.MOUSE_DOWN, cardOnDown, true)
	addEL(myStage, MouseEvent.MOUSE_UP, cardOnUp, true)
	addEL(this, MouseEvent.MOUSE_DOWN, cardOnClick, true)
	//addEL(this, MouseEvent.DOUBLE_CLICK, pieceOnDouble, true)
	addEL(myStage, Event.MOUSE_LEAVE, cardOnLeave)

	
	//Расчитываем расположение поля
	deskContProp.W = this.width
	deskContProp.H = this.height
	deskContProp.x = 0
	deskContProp.y = 0
	
	
	
		
	//Шаг истории
	makeHistoryStep()
	
	//trace(this.numChildren)
}


private function start(event:Event = null, count:int = 0, end:Boolean = true):void {

	//Меняем курсор при запуске прелоадера
	if (count == 1) {
		//Меняем куросор, чтобы показать загрузку
		myCursor.ChangeCursor(null, 1, "piece")
	}
	
	//Создаем страницы
	//Если все страницы созданы, то убираем прелоадер
	if (end) {
		//Удаляем прослушиватель
		removeELFrame(this, start)
		
		//Меняем курсор на стандартный
		myCursor.initDefaultCursor()
		
		//Удаляем прелоадер
		gamePreloader.complite()
	
		return
	}
	
	//Начинаем загрузку игры с 0, а не с -1
	//Чтобы дать возможность показать прелоадер без задержки
	if (count >= 1) {
		//Так как не сразу добавляется прелоадер
		var nC:int = this.numChildren
		//Даже позже, чем будет в переменную занесено numChildren
		if ( nC > 0) {
			//Создаем игру
			switch(count) {
            case 1: {
				prepareGame1()
			break}case 2: {
				prepareGame2()
			break}case 3: {
				prepareGame3()
			break}case 4: {
				prepareGame4()
			break}case 5: {
				prepareGame5()
			break }}
			//Показываем загрузку
			gamePreloader.progress(count)
		}

	}
}

public function paintSide(x:int, y:int, w:int, h:int, cont:Sprite = null):void {
	if(cont == null) cont = gameDesk
	var g:Graphics = cont.graphics
	g.lineStyle(1, 0x000000);	
	g.beginFill(0x008000);	
	g.drawRect(x, y, w, h)
	g.endFill()
}

private function cardOnDown(event:MouseEvent):void {
	//Проверяем подсветку
	var arrLength:int = tipsArr.length
	if (arrLength > 0 ) {
		//Убираем подсветку
		while (arrLength--) {
			(tipsArr[arrLength]as Card).showTip(false)
		}
		//Очищаем массив
		tipsArr.length = 0
	}
	
	
	
	if (event.target is Card) {
		activeCard = event.target as Card
		if (activeCard.pack.kind == Pack.DEF || activeCard.lock) return
		
		//Распологаем спрайт
		activeSprite.x = activeCard.x
		activeSprite.y = activeCard.y
		//Передаем положение кусочка
		activeProp.x = activeCard.x
		activeProp.y = activeCard.y
		//Сохраняем положение мышки
		activeProp.tempX = event.stageX
		activeProp.tempY = event.stageY 
		
		//Проверяем положение карты в колоде
		//Старый массив
		var oldArr:Array = activeCard.arr
		//Расположение карты в массиве
		var index:int = oldArr.indexOf(activeCard)
		arrLength = oldArr.length
		var delta:int = arrLength - index
		
		var dopNum:int = 0
		//Находим последующие карты
		if (delta > 0) {
			var L:int = delta
			while (L--) {
				var dopCard:Card = oldArr[index + dopNum] as Card
				//dopCard.oldX = dopCard.x
				//dopCard.oldY = dopCard.y
				activeSprite.addChild(dopCard)
				dopCard.x = (activeCard.pack.moveX * dopNum)
				dopCard.y = (activeCard.pack.moveY * dopNum)
				//Добавляем в массив
				activeArr.push(dopCard)
				dopNum++
			}
		}
		
		//Ставим приоритетный курсор, чтобы не было мигания мышки
		myCursor.ChangeCursor(event, 1, "HAND", true)
		
		//Добавляем прослушиватель передвижения мышки
		addELMove(gameDesk, mouseMove)

		//Выводим на первый план кусочек
		//this.setChildIndex(activeCard as DisplayObject, (this.numChildren - 1))
		gameDesk.setChildIndex(activeSprite, (gameDesk.numChildren - 1))
		
		//Добавляем подсветку
		activeSprite.filters = [myBFilters.Shadow2()]
		
		//Блокируем все остальные события
		event.stopPropagation()
	}
}

private function cardOnUp(event:MouseEvent):void {

	//trace("up")
	if (activeCard == null) return
	
	if (activeCard.pack.kind == Pack.DEF || activeCard.lock) return
	
	activeSprite.filters = myBFilters.PieceStatic()
	
	//Останавливаем таскание кусочка
	removeELMove(this, mouseMove)

	//Снимаем приоритет курсора с кусочка
	myCursor.ChangeCursor(event, -1)
	
	//Если кусочек выходит за пределы поля
	//if (activeSprite.x < 0) activeSprite.x = 0
	//if (activeSprite.y < 0) activeSprite.y = 0
	//
	//var deltaW:int = deskContProp.W - 0 - (activeSprite.x + activeCard.width)
	//var deltaH:int = deskContProp.H - 0 - (activeSprite.y + activeCard.height)
	//
	//if (deltaW < 0) activeSprite.x += deltaW		
	//if (deltaH < 0) activeSprite.y += deltaH	
	
	if (activeSprite.numChildren > 0) {
		//Количество элементов
		var L:int = activeSprite.numChildren
		
		while(L--){
			var spiteCard:Card = activeSprite.getChildAt(0) as Card
			//spiteCard.x = spiteCard.oldX
			//spiteCard.y = spiteCard.oldY
			gameDesk.addChild(spiteCard)
		}
	}
	
	//Проверяем на столкновения
	if (colision(activeCard)) {
		//Шаг истории
		makeHistoryStep()
	}else {
		if (activeArr.length > 0) {
			//Количество элементов
			L = activeArr.length
			
			while(L--){
				var dopCard:Card = activeArr.shift() as Card
				//Положение карты
				var oldPoint:Point = new Point(dopCard.x + activeSprite.x, dopCard.y + activeSprite.y)
				//Направление куда карта двигается
				var newPoint:Point = new Point(dopCard.oldX, dopCard.oldY)
				//Двигаем постепенно
				addMoveCard(dopCard, oldPoint, newPoint)
				
				//dopCard.x = dopCard.oldX
				//dopCard.y = dopCard.oldY
				
				//dopCard.x = activeSprite.x + dopCard.x
				//dopCard.y = activeSprite.y + dopCard.y
				
				//gameDesk.addChild(dopCard)
			}
		}
	}

	//Очищаем буфер
	this.activeCard = null
	activeArr.length = 0
	
	//Показываем подсказки
	//showTips(event)

}

private function checkAutoComplite():void {
	
	//autoComplite()
	//return
	
	//Проверяем, чтобы карты были только на игровых колодах
	var emptyEnd:Boolean = false
	var defEnd:Boolean = false
	var playEnd:Boolean = false
	var bufArr:Array
	var bufPack:Pack
	var L:int = allPackArr.length
	while (L--) {
		bufPack = allPackArr[L] as Pack
		//Находим нужные нам колоды
		if (bufPack.kind == Pack.EMPTY || bufPack.kind == Pack.DEF) {
			bufArr = bufPack.link
			if (bufArr.length > 0) {
				trace("checkAutoComplite FALSE")
				return
			}
		}
	}
	//Проверяю чтобы в игровых колодах все карты были разблокированы
	var L:int = allPackArr.length
	while (L--) {
		bufPack = allPackArr[L] as Pack
		//Находим нужные нам колоды
		if (bufPack.kind == Pack.PLAY) {
			bufArr = bufPack.link
			var L1:int = bufArr.length
			while (L1--) {
				var card:Card = bufArr[L1] as Card
				if (card.lock) {
					trace("checkAutoComplite 2 FALSE")
					return
				}
			}

		}
	}
	
	trace("checkAutoComplite TRUE")
	//Убираем автоподсветку
	//Проверяем подсветку
	var arrLength:int = tipsArr.length
	if (arrLength > 0 ) {
		//Убираем подсветку
		while (arrLength--) {
			(tipsArr[arrLength]as Card).showTip(false)
		}
		//Очищаем массив
		tipsArr.length = 0
	}
	//Автозаполнение
	autoComplite()
}

private function autoComplite():void {
	//=================================================
	//ПОВЕРЯЕМ НА СТОЛКНОВЕНИЯ С ДРУГИМИ КАРТАМИ
	//=================================================
	var newPack:Pack
	var newCard:Card
	var moveCard:Card
	//Сортируем по приоритету
	//От большего к меншему, так как проверка будет от большего к меньшему
	allPackArr.sortOn("prioritet", Array.NUMERIC | Array.DESCENDING)
	
	//Количество препятствий
	var arrLength:int = allPackArr.length;
	var L:int = arrLength
	var L1:int = arrLength
	while (L--) {
		//Берем колоду
		var movePack:Pack = allPackArr[L] as Pack
		//Тип колоды
		var packKind:int = movePack.kind
		
		//Пропускаем ненужные колоды
		if (packKind == Pack.DEF || packKind == Pack.EMPTY || packKind == Pack.READY) continue
		//Получаем массив карт
		var moveArr:Array = movePack.link
		//Получаем последнюю карту
		moveCard = moveArr[moveArr.length - 1] as Card
		//Пропускаем если карты нет
		if(moveCard == null) continue
		
		L1 = arrLength
		while (L1--) {
			//Берем колоду
			var newPack:Pack = allPackArr[L1] as Pack
			//Тип колоды
			var newpackKind:int = newPack.kind
			//Пропускаем ненужные колоды
			if (newpackKind == Pack.DEF || newpackKind == Pack.EMPTY || newpackKind == Pack.PLAY || packKind == newpackKind) continue
			//Проверка колоды
			activeSprite.x = 0
			activeSprite.y = 0
			if (checkPack(moveCard, newPack)) {
				trace("autoComplite")
				return 
			}
		}


	}

	return 
}

private function cardOnLeave(event:Event):void {
	
	//trace("Leave")
	
	if (activeSprite.numChildren > 0) {
		//Количество элементов
		var L:int = activeSprite.numChildren
		
		while(L--){
			var spiteCard:Card = activeSprite.getChildAt(0) as Card
			spiteCard.x = spiteCard.oldX
			spiteCard.y = spiteCard.oldY
			gameDesk.addChild(spiteCard)
		}
		
		//Снимаем приоритет курсора с кусочка
		myCursor.ChangeCursor(event, -1)
		
		//Останавливаем таскание кусочка
		removeELMove(this, mouseMove)
		
		//Убираем подстветку
		activeSprite.filters = myBFilters.PieceStatic()
		
	}

	//Очищаем буфер
	activeCard = null
	activeArr.length = 0
}


//Двигаем мышкой и двигается кусочек
public function mouseMove(event:MouseEvent):void { 

	//Получаем общие свойства
	var myProp:Object = deskContProp
	//Передаем маштаб поля
	activeProp.scale = myProp.scale
	//Изменяем буферную переменную
	//Буфер нужен, так как движение возможно только попиксельно и будет иначе терятся данные
	activeProp.x += (event.stageX  - activeProp.tempX) / activeProp.scale
	activeProp.y += (event.stageY - activeProp.tempY) / activeProp.scale
	//Сохраняем положение мышки
	activeProp.tempX = event.stageX
	activeProp.tempY = event.stageY
	//Передвигаем кусочек
	activeSprite.x = activeProp.x
	activeSprite.y = activeProp.y
	
}

private function cardOnClick(event:MouseEvent):void {
	//return
	if (event.target is Card) {
		activeCard = event.target as Card
		if (activeCard.pack.kind == Pack.DEF) {
			//trace("Берем 3 верхние карты")
			var num:int = defCarfNum
			
			//Находим колоду куда скидываем карты и откуда
			var L:int = allPackArr.length
			while (L--) {
				var newPack:Pack = allPackArr[L] as Pack
				if (newPack.kind == Pack.EMPTY) break
			}
			//var startX:int = newPack.x
			//var startY:int = newPack.y
			
			L = packDef.length
			if (num > L) num = L
			//trace(packDef.length)
			while (num--) {
				var getCard:Card = packDef[packDef.length - 1] as Card
				
				var par:DisplayObjectContainer = getCard.parent as DisplayObjectContainer
				if (par != null) par.setChildIndex(getCard, (par.numChildren - 1))

				
				//trace("3 верхние карты", getCard.oldX, getCard.oldY)
				
				getCard.oldX = getCard.x
				getCard.oldY = getCard.y
				
				

				
				
				

				//Перемещаем карту
				getCard.move(newPack)


			}
			//Выкладываем 3 верхние карты для доступа
			openEmptyCard()


			//Шаг истории
			makeHistoryStep()
		}

	}
	//Очищаем буфер
	//activeCard = null
	//activeArr.length = 0
	//Показываем подсказки
	//showTips(event)
}


private function defOnClick(event:MouseEvent):void {
	
	//Находим колоду куда скидываем карты и откуда
	var L:int = allPackArr.length
	while (L--) {
		var bufPack:Pack = allPackArr[L] as Pack
		//Находим нужные нам колоды
		if (bufPack.kind == Pack.EMPTY) {
			var oldPack:Pack = bufPack
			var oldPackArr:Array = oldPack.link as Array
		}else if (bufPack.kind == Pack.DEF){
			var newPack:Pack = bufPack
			var newPackArr:Array = newPack.link as Array
		}
	}
	//Перекидываем все карты с пустой в основную колоду
	//Сверха в низ
	L = oldPackArr.length
	while (L--) {
		var getCard:Card = oldPackArr[L] as Card
		var par:DisplayObjectContainer = getCard.parent as DisplayObjectContainer
		if (par != null) {
			par.setChildIndex(getCard, (par.numChildren - 1))
		}
		//Запоминаем карту
		//checkInHistory(getCard)
			
		var oldPoint:Point = new Point(getCard.oldX, getCard.oldY)
		//var oldPoint:Point = new Point(getCard.x, getCard.y)
		getCard.move(newPack)
		var newPoint:Point = new Point(getCard.newX, getCard.newY)
		//Двигаем постепенно карту
		addMoveCard(getCard,oldPoint, newPoint)
		getCard.lockCard(true)
		getCard.openCard(false)
	}
	
	//Шаг истории
	makeHistoryStep()
	
}

public function addMoveCard(card:Card, start:Point, end:Point):void {

	//Время перемещения
	var frameDelay:Number = moveCardSpeed
	//Минимальное расстояние для движения
	var minLength:int = 10
	
	//Находим расстояние между точками
	var countX:int = end.x - start.x
	var countY:int = end.y - start.y
	//Мода
	var countXMod:int = (countX < 0)? -countX : countX
	var countYMod:int = (countY < 0)? -countY : countY
	//Если растояние маленькое, то пропускаем
	if (countXMod < minLength && countYMod < minLength || moveCardFlag == false) {
		//Ставим карту на место
		card.x = end.x
		card.y = end.y
		//Сохраняем положение
		card.oldX = end.x
		card.oldY = end.y
		//Проверяем оконьчание игры
		checkGameEnd()
		//Проверяем автозаполнение
		checkAutoComplite()
		return
	}
	
	//Нахождение большего и вычисление счетчика итераций
/*	if (countXMod > countYMod) {
		var maxCount:int = countXMod / frameDelay
	}else {
		maxCount = countYMod / frameDelay
	}*/
	//Вычисление скорости перемещения
	var delayX:Number = countX / frameDelay
	var delayY:Number = countY / frameDelay
	
	//Ставим в начальное положение
	card.x = start.x
	card.y = start.y
	
	//trace(end.x, end.y)
		//trace("text")
		var par:DisplayObjectContainer = card.parent as DisplayObjectContainer
		if (par != null) par.setChildIndex(card, (par.numChildren - 1))
	
	//Добавляем в массив
	moveCardArr.push( new moveCardItem(card,start.x,start.y,end.x,end.y,delayX,delayY,0,frameDelay))
	
	//Добавляем прослушиватель
	this.addELFrame(this,moveCard)

}

private function moveCard(event:Event = null, count:int = 0, end:Boolean = true):void {
	
	var arrLength:int = moveCardArr.length
	if (arrLength <= 0 ) {
		//Удаляем прослушиватель
		this.removeELFrame(this, moveCard)
		//Разрешаем нажимать мышкой
		gameDesk.mouseEnabled = true
		gameDesk.mouseChildren = true

		return
	}
	
	var L:int = arrLength
	for (var i:int = 0; i < L; i++) {
		//Получаем объект
		var item:moveCardItem = moveCardArr[i] as moveCardItem
		//Ссылка на карту
		var myCard:Card = item.card as Card
		
		//Если счетчик максимальный, то убираем из массива. И если карты не существует
		if (item.totalCount >= item.maxCount || myCard == null) {
			//Расположение карты в массиве
			var index:int = moveCardArr.indexOf(item)
			//Убираем данную карту из старого массива
			moveCardArr.splice(index, 1)[0]
			//Ставим карту на место
			myCard.x = item.endX
			myCard.y = item.endY
			//Сохраняем положение
			myCard.oldX = item.endX
			myCard.oldY = item.endY
			
			//Проверяем оконьчание игры
			checkGameEnd()
			//Проверяем автозаполнение
			checkAutoComplite()
			
			//var par:DisplayObjectContainer = myCard.parent as DisplayObjectContainer
			//if (par != null) par.setChildIndex(myCard, (par.numChildren - 1))

			//trace(myCard.x, myCard.y)
			L--
			continue
		}
		if(item.totalCount == 1){
			var par:DisplayObjectContainer = myCard.parent as DisplayObjectContainer
			if (par != null) par.setChildIndex(myCard, (par.numChildren - 1))
			//Чтобы мышкой нельзя было нажать
			gameDesk.mouseEnabled = false
			gameDesk.mouseChildren = false
		}
		
		//Увеличиваем счетчик
		item.totalCount++
		//Передвигаем карту
		myCard.x = item.startX + item.delayX * item.totalCount
		myCard.y = item.startY + item.delayY * item.totalCount
		//trace()
	}
}



private function openEmptyCard():void {
	
	//return
	//Берем 3 верхние карты
	var getNum:int = defCarfNum
	
	//Находим колоду откуда берем карты
	var L:int = allPackArr.length
	while (L--) {
		var newPack:Pack = allPackArr[L] as Pack
		if (newPack.kind == Pack.EMPTY) break
	}
	var packArr:Array = newPack.link
	
	//Выстраиваем по порядку
	L = packArr.length
	//Проверка количества элементов в массиве
	var num:int = L - getNum
	if (num <= 0) {
		L = 0
	}else {
		L = num
	}
	
	//while (L--) {
	for (var i:int = 0; i < L; i++ ) {
		//Находим карту
		var getCard:Card = packArr[i] as Card
		
		//Положение карты
		var oldPoint:Point = new Point(getCard.x, getCard.y)
		
		//Сдвигаем карту
		//getCard.x = newPack.x
		//getCard.y = newPack.y
		//getCard.oldX = newPack.x
		//getCard.oldY  = newPack.y
		getCard.newX = newPack.x
		getCard.newY = newPack.y
		//Закрытые карты
		getCard.lockCard(true)
		//getCard.openCard(false)
		
		//Направление куда карта двигается
		var newPoint:Point = new Point(getCard.newX, getCard.newY)
		//Двигаем постепенно
		addMoveCard(getCard, oldPoint, newPoint)
	}
	
	
	//Выдвигаем 3 крайние карты
	L = packArr.length
	//Проверка количества элементов в массиве
	if (getNum > L) getNum = L
	var num:int = getNum
	
	var count:int = 0

	while(num--) {

		//Находим карту
		getCard = packArr[packArr.length - 1 - num] as Card
		
		//Положение карты
		var oldPoint:Point = new Point(getCard.oldX, getCard.oldY)
		
		//Сдвигаем карту
		//getCard.x = newPack.x + (count * Card.cardW / 2)
		//getCard.oldX = getCard.x
		//getCard.oldY  = getCard.y
		getCard.newX = newPack.x + (count * Card.cardW / 2)
		getCard.newY = newPack.y
		//Показываем карты
		getCard.openCard(true)
		//Открываем последнюю карту
		if (count == getNum - 1) {
			getCard.lockCard(false)
			getCard.openCard(true)
		}else {
			getCard.lockCard(true)
			getCard.openCard(true)
		}
		//trace(packArr.length , packArr.length - 1 - count, newPack.x + (num * Card.cardW / 2), getCard.num)
		//Счетчик
		count++
		

				//Направление куда карта двигается
				var newPoint:Point = new Point(getCard.newX, getCard.newY)
				//Двигаем постепенно
				addMoveCard(getCard, oldPoint, newPoint)
		
		//Запоминаем в историю
		//checkInHistory(getCard)

	}

}


private function openEmptyCard2():void {
	
	//return
	//Берем 3 верхние карты
	var getNum:int = defCarfNum
	
	//Находим колоду откуда берем карты
	var L:int = allPackArr.length
	while (L--) {
		var newPack:Pack = allPackArr[L] as Pack
		if (newPack.kind == Pack.EMPTY) break
	}
	var packArr:Array = newPack.link
	
	//Выстраиваем по порядку
	L = packArr.length
	//Проверка количества элементов в массиве
	var num:int = L - getNum
	if (num <= 0) {
		L = 0
	}else {
		L = num
	}
	
	while (L--) {
		//Находим карту
		var getCard:Card = packArr[L] as Card
		
		//Положение карты
		var oldPoint:Point = new Point(getCard.x, getCard.y)
		
		//Сдвигаем карту
		getCard.x = newPack.x
		getCard.y = newPack.y
		//getCard.oldX = newPack.x
		//getCard.oldY  = newPack.y
		getCard.newX = newPack.x
		getCard.newY = newPack.y
		//Закрытые карты
		getCard.lockCard(true)
		getCard.openCard(false)
		
		//Направление куда карта двигается
		var newPoint:Point = new Point(getCard.newX, getCard.newY)
		//Двигаем постепенно
		addMoveCard(getCard, oldPoint, newPoint)
	}
	var getCard:Card 
	
	//Выдвигаем 3 крайние карты
	L = packArr.length
	//Проверка количества элементов в массиве
	if (getNum > L) getNum = L
	var num:int = getNum
	
	var count:int = 0

	while(num--) {

		//Находим карту
		getCard = packArr[packArr.length - 1 - num] as Card
		
		//Положение карты
		var oldPoint:Point = new Point(getCard.x, getCard.y)
		
		//Сдвигаем карту
		getCard.x = newPack.x + (count * Card.cardW / 2)
		//getCard.oldX = getCard.x
		//getCard.oldY  = getCard.y
		getCard.newX = getCard.x
		getCard.newY = getCard.y
		//Показываем карты
		getCard.openCard(true)
		//Открываем последнюю карту
		if (count == getNum - 1) {
			getCard.lockCard(false)
			getCard.openCard(true)
		}else {
			getCard.lockCard(true)
			getCard.openCard(true)
		}
		//trace(getCard.lock, getCard.open)
		//trace(packArr.length , packArr.length - 1 - count, newPack.x + (num * Card.cardW / 2), getCard.num)
		//Счетчик
		count++
		

				//Направление куда карта двигается
				var newPoint:Point = new Point(getCard.newX, getCard.newY)
				//Двигаем постепенно
				addMoveCard(getCard, oldPoint, newPoint)
		
		//Запоминаем в историю
		//checkInHistory(getCard)
			var par:DisplayObjectContainer = getCard.parent as DisplayObjectContainer
			if (par != null) par.setChildIndex(getCard, (par.numChildren - 1))
	}

}

//Настройка свойства карты
public function minScale():void {
	//Берем размеры карты
	var scale:Object = {}
	scale.W = deskContProp.W
	scale.H = deskContProp.H
	//Находим отношения
	scale.WS = (minSW) / scale.W
	scale.HS = (minSH) / scale.H
	
	if (scale.WS > scale.HS) {
		deskContProp.MinScale = scale.WS
	}else {
		deskContProp.MinScale = scale.HS
	}
	//Возможно быть так, что минимальный размер больше максимального
	//На больших мониторах, тогда
	if (deskContProp.MinScale > deskContProp.MaxScale) {
		deskContProp.MaxScale = deskContProp.MinScale
	}else {
		deskContProp.MaxScale = deskContProp.MaxScale
	}
	
}

// Проверка карты
public function mapCorrection():void {
	//Блокируем черезмерное увеличение и уменьшение
	if (deskContProp.scale < deskContProp.MinScale) deskContProp.scale=deskContProp.MinScale
	if (deskContProp.scale > deskContProp.MaxScale) deskContProp.scale=deskContProp.MaxScale
	//Изменяем маштаб поля
	this.scaleX = deskContProp.scale
	this.scaleY = deskContProp.scale
	//проверка выхода карты за границы
	var dx:Number = this.width - SW
	var dy:Number = this.height - SH
	if (deskContProp.target == "w") {
		//Передвигаем поле, чтобы увеличение шло от координат мышки
		this.x = (int(deskContProp.wx) * this.scaleX) + deskContProp.sx
		this.y = (int(deskContProp.wy) * this.scaleY) + deskContProp.sy
	}else{
		//Передвигаем поле, чтобы увеличение шло от центра
		this.x = (int(deskContProp.x) * this.scaleX) + (SW * 0.5)
		this.y = (int(deskContProp.y) * this.scaleY) + (SH * 0.5)
	}
	//По верхнему краю
	if (this.x>0) this.x=0
	if (this.y>0) this.y=0
	//По нижнему краю
	if (this.x < -dx) this.x = -dx
	if (this.y < -dy) this.y = -dy
	
	//Меняем активные кнопки в настройках маштаба
	//OptPage.setZoomBotton(deskContProp.scale)
}

private function colision(myCard:Card):Boolean {
	//=================================================
	//ПОВЕРЯЕМ НА СТОЛКНОВЕНИЯ С ДРУГИМИ КАРТАМИ
	//=================================================
	var newPack:Pack
	var newCard:Card
	//Размер карты
	var cardW:int = Card.cardW
	var cardH:int = Card.cardH
	//Растояние между обьектами
	var disx:Number = 0
	var disy:Number = 0
	//Максимальное растояние
	var mx:Number = 0
	var my:Number = 0
	//Абсолютное растояние
	var ax:Number=0
	var ay:Number=0

	//Количество препятствий
	var L:int = allPackArr.length;
	//Сортируем по приоритету
	//От большего к меншему, так как проверка будет от большего к меньшему
	allPackArr.sortOn("prioritet", Array.NUMERIC | Array.DESCENDING)
	
	var moveCard:Card
	while (L--) {
		//Берем колоду
		var movePack:Pack = allPackArr[L] as Pack
		//Тип колоды
		var packKind:int = movePack.kind
		
		//Пропускаем ненужные колоды
		if (packKind == Pack.DEF || packKind == Pack.EMPTY || myCard.pack == movePack) continue
			
		disx = movePack.x - activeSprite.x;	
		mx = (cardW >> 1) + (cardW >> 1)
		ax = Math.abs(disx);
		
		//Проверяем на столкновение с внешним кругом
		if (ax < mx) {
			
			disy = movePack.y - activeSprite.y;
			my = (cardH >> 1) + (cardH >> 1)
			ay = Math.abs(disy);
			
			if (ay < my) {	

				//Проверка колоды
				if (checkPack(myCard, movePack)) return true

			}
		}
	}

	return false
}

private function checkPack(myCard:Card, myPack:Pack):Boolean {
	//Получаем масив новой колоды
	var packArr:Array = myPack.link
	//Последняя карта в новой колоде
	var lastCard:Card = packArr[packArr.length - 1]

	//Проверка готовых колод
	if (myPack.kind == Pack.READY) {
		if (lastCard == null) {
			//Параметры проверки
			//var suit:int = myPack.suit
			var suit:int = myCard.suit
			var num:int = 0
		}else {
			suit = myPack.suit
			num = lastCard.num + 1
		}
		
		//Проверка карт
		if (suit != myCard.suit || activeArr.length > 1) return false
		
		//trace("checkPack R", myCard.suit, suit, myCard.num, num - 1)
		if (myCard.num == num) {
			
			var oldPack:int = myCard.pack.kind
			//Ставим флаг, что данная колода будет данной масти
			myPack.suit = suit
			//Если удовлетворяем условиям,то ставим на новое место карту
			
			var oldPoint:Point = new Point(myCard.x + activeSprite.x, myCard.y + activeSprite.y)
			myCard.move(myPack)
			var newPoint:Point = new Point(myCard.newX, myCard.newY)
			//Двигаем постепенно карту
			addMoveCard(myCard,oldPoint, newPoint)
			
			//Закрываем последнюю карту
			if (lastCard != null) {
				lastCard.lockCard(true)
			}
			
			//Выдвигаем карты
			if (oldPack == Pack.EMPTY) openEmptyCard2()
			return true
		}
	}
	
	//Проверка игровых колод
	if (myPack.kind == Pack.PLAY) {
		
		if (lastCard == null) {
			suit = -1
			num = cardsTotal - 1
			var sideColor:int = -1
		}else {
			suit = lastCard.suit
			num = lastCard.num - 1
			sideColor = lastCard.sideColor
		}

		
		//Проверка карт
		if (suit == myCard.suit || sideColor == myCard.sideColor) return false

		if (myCard.num == num) {

			//Если удовлетворяем условиям,то ставим на новое место карту
			if (activeArr.length > 0) {
				//Количество элементов
				var L:int = activeArr.length
				oldPack = myCard.pack.kind
				for (var i:int = 0; i < L; i++ ) {
					var dopCard:Card = activeArr.shift() as Card
					oldPoint = new Point(dopCard.x + activeSprite.x, dopCard.y + activeSprite.y)
					//Перемещаем карту
					dopCard.move(myPack)
					newPoint = new Point(dopCard.newX, dopCard.newY)
					//Двигаем постепенно карту
					addMoveCard(dopCard,oldPoint, newPoint)
				}
			}
			//Выдвигаем карты
			if (oldPack == Pack.EMPTY) openEmptyCard2()
			
			return true
		}

	}
	//Если условия не выполнены
	return false
}


private function backToHistory(event:MouseEvent):void {
	
	var arrLength:int = historyArr.length
	//Проверка сохранений истории
	if (arrLength <= 0) {
		return
	}
	
	//Проверка шагов истории
	if (historyStep <= 1) {
		//Первое сохранение не стирается
		return
	}
	
/*	//Сортируем по приоритету
	//От большего к меншему, так как проверка будет от большего к меньшему
	allPackArr.sortOn("prioritet", Array.NUMERIC | Array.DESCENDING)
*/
	//Шаг назад по истории
	var deltaStep:int = historyStep
	historyStep--
	var backStep:int = historyStep - 1
	
	//Данные истории 
	var itemStep:int = 0
	//Счетчик
	var count:int = 0
	//Пересчитываем все ходы истории
	//Берем данные
	var L:int = arrLength
	//Условие оконьчания цикла
	if (L <= 0) return
	while (L--) {
		
		//if(arrlength <= 0) break
		var  historyItem:HistoryItem = historyArr[L]
		
		//Условие оконьчания цикла
		if (historyItem == null) break
		
		//Время сохранения
		itemStep = historyItem.historyStep
		
		//Условие оконьчания цикла
		if (itemStep < backStep) break
		
		//Убираем еденицу истории из массива
		if (itemStep > backStep) {
			index = historyArr.indexOf(historyItem)
			historyArr.splice(index, 1)[0]
			continue
		}else {
			//Увеличиваем счетчик
			count++
		}

		var myCard:Card = historyItem.card
		//Выдвигаем на передний план
		var par:DisplayObjectContainer = myCard.parent as DisplayObjectContainer
		if (par != null) par.setChildIndex(myCard, (par.numChildren - 1))
		//Меняем положение колоды
		myCard.newX = historyItem.oldX
		myCard.newY = historyItem.oldY
		
		
		
		//Меняем положение колоды
		//myCard.x = historyItem.oldX
		//myCard.y = historyItem.oldY
		
			var oldPoint:Point = new Point(myCard.x, myCard.y)
			var newPoint:Point = new Point(myCard.newX, myCard.newY)
			//Двигаем постепенно карту
			addMoveCard(myCard,oldPoint, newPoint)
		
		myCard.lockCard(historyItem.lock)
		myCard.openCard(historyItem.open)

		//Новая колода и ее массив
		var newPack:Pack = historyItem.oldPack
		var newArr:Array = newPack.link
		//Старая колода и ее массив
		var oldPack:Pack = myCard.pack
		var oldArr:Array = oldPack.link


		//Убираем карту из старого массива
		var index:int = oldArr.indexOf(myCard)
		oldArr.splice(index, 1)[0]
		
		//Двигаем старую колоду
		oldPack.x -= oldPack.moveX
		oldPack.y -= oldPack.moveY
		//Двигаем новую колоду
		//newPack.x = historyItem.oldPackX
		//newPack.y = historyItem.oldPackY
		newPack.x += newPack.moveX
		newPack.y += newPack.moveY
		//trace(myPack.x, myPack.y)

		//Меняем колоду и массив
		myCard.pack = newPack
		myCard.arr = newArr
		//Добавляем карту в массив новой колоды
		newArr.push(myCard)
	}
}


private function makeHistoryStep():void {
	//Сохраняем в истории
	//Запоминаем расположение всех карт
	var L:int = allPackArr.length
	while (L--) {
		//Берем колоду
		var myPack:Pack = allPackArr[L] as Pack
		//Берем массив карт
		var myArr:Array = myPack.link
		var L1:int = myArr.length
		//Раставляем по порядку
		while (L1--) {
			//Разбираем новый массив
			var myCard:Card = myArr[L1] as Card
			//Запоминаем карту
			historyArr.push(new HistoryItem(myCard, myPack, historyStep))
		}
	}
	//trace(historyStep)
	historyStep++
}


private function showTips(event:MouseEvent):void {
	//флаг свободного поля
	var freePackFlag:Boolean = false
	//Проверяем все карты
	//Запоминаем расположение всех карт
	var L:int =  allPackArr.length
	while (L--) {
		//Берем колоду
		var myPack:Pack = allPackArr[L] as Pack
		//Берем массив карт
		var myArr:Array = myPack.link
		var L1:int = myArr.length
		//Отмечаем, что есть свободное поле
		if (L1 == 0 && myPack.kind == Pack.PLAY) freePackFlag = true
		
		//Раставляем по порядку
		while (L1--) {
			//Разбираем новый массив
			var myCard:Card = myArr[L1] as Card
			
			//Если карта доступна и открыта
			if (!myCard.open || myCard.lock) continue
			//Сохраняем в массив
			tipsArr.push(myCard)
		}
	}
	
	//Запоминаем расположение всех карт
	var arrLength:int =  tipsArr.length
	L =  arrLength
	while (L--) {
		var item1:Card = tipsArr[L] as Card
	
		//Проверка готовых колод
		if (item1.pack.kind != Pack.READY) {
			
			//Если туз, то подсвечиваем
			if (item1.num == 0) {
				trace("нашлли туз")
				//Подсвечиваем карту
				item1.showTip(true)
				continue
			}
			
			//Если король и есть свободное поле, то подсвечиваем
			if (item1.num == cardsTotal - 1 && freePackFlag) {
				var itemArr:Array = item1.arr
				var index:int = itemArr.indexOf(item1)
				if (index > 0 || item1.pack.kind == Pack.EMPTY) {
					//Подсвечиваем карту
					trace("король", item1.num, cardsTotal,index)
					item1.showTip(true)
					continue
				}
			}
/*			
			var itemArr:Array = item1.arr
			var index:int = itemArr.indexOf(item1)
			
			//Если не первая, и предыдущая открыта, то не перекладываем
			if (index > 0 && index < itemArr.length-1) {
				//Получаем предыдущюю карту
				var prevCart:Card = itemArr[index - 1]
				//Если предыдущая открыта, то эту не трогаем
				if (!prevCart.lock && prevCart.open) {
					
					//trace("нашлли карту которую не надо лишний раз двигать")
					//continue
				}
			}*/
			
		}else {
			//Готовую колоду обратно не перекладываем
			continue
		}
		
		L1 = arrLength
		while (L1--) {
			var item2:Card = tipsArr[L1] as Card
			//Если равны то пропускаем сравнивание
			if (item1 == item2) continue
			//Проверка совместимиости
			if (!checkTips(item1, item2)) continue
			//Подсвечиваем карты
			item1.showTip(true)
			item2.showTip(true)
		}
	}
}

private function checkTips(item1:Card, item2:Card):Boolean {
	//Колода, которую двигаем
	var pack1:Pack = item1.pack
	var kind1:int = pack1.kind
	var suit1:int = item1.suit
	var sideColor1:int = item1.sideColor
	var num1:int = item1.num
	var arr1:Array = pack1.link
	var arrLength1:int = arr1.length
	var index1:int = arr1.indexOf(item1)
	//Колода куда двигаем
	var pack2:Pack = item2.pack
	var kind2:int = pack2.kind
	var suit2:int = item2.suit
	var sideColor2:int = item2.sideColor
	var num2:int = item2.num
	var arr2:Array = pack2.link
	var arrLength2:int = arr2.length
	var index2:int = arr2.indexOf(item2)
	
	//Проверка карт отдной колоды
	if (pack1 == pack2) return false
	
	//Проверка пустой колоды
	if (kind2 == Pack.EMPTY) return false


	//Проверка готовых колод
	if (kind2 == Pack.READY) {
		//trace("ready")
		//Если не последняя, то ее и не подсвечиваем для перемещения в готовую колоду
		if (kind1 == Pack.PLAY ) {
			//trace("PLAY",index2, )
			if (index1 < arrLength1-1 ) return false
		}

		//Проверка карт
		if (suit2 != suit1) return false		
		//Если большее по масти
		if (num2 + 1 == num1) return true
	}
	
	//Проверка игровых колод
	if (kind2 == Pack.PLAY) {
		//Если карта не последняя, то на нее нельзя двигать
		if (index2 < arrLength2 - 1 ) return false
		
		//Если карта, которую двигают уже стоит на открытой,
		//То нет смысла двигать ее в пределах игровых колод
		if (index1 > 0) {
			var lastCard:Card = arr1[index1 - 1]
			if(!lastCard.lock && lastCard.open) return false
		}
		
		//Проверка карт
		if (suit2 == suit1 || sideColor1 == sideColor2) return false
		//Если менше по масти
		if (num2 - 1 == num1) return true
	}
	
	//Если условия не выполнены
	return false
}

private function cloneArray(oldArr:Array):Array {
	//Клонируем массив
	var tempArr:Array = [];
	//tempArr = TempArr.concat(oldArr);
	
	//for each (var thing:* in oldArr) {
		//tempArray.push(thing);
	//}
	//trace(arrayToCopy.length + " of "+ tempArray.length +" items copied");
	//return tempArray;
	
	return tempArr
}

}}

class HistoryItem {
	
	/*public var allArr:Array*/
	
	public var card:Card
	public var oldX:Number
	public var oldY:Number
	public var lock:Boolean
	public var open:Boolean
	public var oldPack:Pack
	//public var oldPackX:Number
	//public var oldPackY:Number
	//Счетчик истории
	public var historyStep:int = 0
	
public function HistoryItem(/*allArr:Array*/ card:Card, pack:Pack, historyStep:int) {
	/*this.allArr = allArr*/
	this.card = card
	this.oldX = card.newX
	this.oldY = card.newY
	this.lock = card.lock
	this.open = card.open
	this.oldPack = pack
	//this.oldPackX = this.oldPack.x
	//this.oldPackY = this.oldPack.y
	
	this.historyStep = historyStep
	
	//Копируем все данные массива
	
	
	
}

}

class MoveZoomPropities {
	
	public var defX:int
	public var defY:int
	public var x:int
	public var y:int
	public var wx:int
	public var wy:int
	public var sx:int
	public var sy:int
	public var TY:int
	public var scale:Number
	public var MinScale:Number
	public var MaxScale:Number
	public var target:String
	public var tempX:Number
	public var tempY:Number
	public var W:int
	public var H:int
	
public function MoveZoomPropities (defX:int = -500, defY:int = -50, x:int = -500, y:int = 0, scale:Number = 1, MinScale:Number = 0.1, MaxScale:Number = 1.5, target:String = "c", tempX:Number = 0, tempY:Number = 0, W:int = 2000, H:int = 1000 ):void {
	this.defX = defX
	this.defY = defY
	this.x = x
	this.y = y
	this.scale = scale
	this.MinScale = MinScale
	this.MaxScale = MaxScale
	this.target = target
	this.tempX = tempX
	this.tempY = tempY
	this.W = W
	this.H = H
}

}


class ActiveProp {
	public var target:String
	public var tempX:Number
	public var tempY:Number
	public var x:Number
	public var y:Number
	public var scale:Number
	
public function ActiveProp ( tempX:int = 0, tempY:int = 0, target:String = "" ):void {
	this.target = target
	this.tempX = tempX
	this.tempY = tempY
}

}