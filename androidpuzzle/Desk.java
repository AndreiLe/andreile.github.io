package com.mygdx.game.mask;

import static java.lang.Math.ceil;
import static java.lang.Math.round;

import java.util.Random;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Pixmap;
import com.badlogic.gdx.graphics.Pixmap.Format;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.Texture.TextureWrap;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.utils.ByteArray;
import com.badlogic.gdx.utils.IntArray;
import com.badlogic.gdx.utils.ObjectMap;

public class Desk implements Screen {

	private OrthographicCamera camera;
	private SpriteBatch batch;
	private Texture pixmapTexture;
	private TextureRegion region;
	private int displayW;
	private int displayH;
	private int dpi;

	private PuzzleOptions o;
	// Массив показывающий сколько замков исходя из процента замков разных
	// видов
	private ByteArray pieceLocsArr;
	// Общий генератор случайных чисел
	// Надо будет создавать в зависимости от времени,
	// чтобы был элемент случайности
	private Random rnd;
	private Pixmap pieceAtlas;

	private IntArray atlasXYWHArray;
	private IntArray pieceXYArray;
	private int col;
	private int row;
	private int lockSize;
	private int moveX = -1;
	private int delta;
	private float zoom = 1f;
	private OrthographicCamera camera2;
	private SpriteBatch batch2;
	private long gameRND;
	private long totalMemory;
	private long freeMemory;
	private long maxMemory;
	private int atlasMaxSize;
	private int pieceX2;
	private float deltaScale;
	private float minPiece;
	private int imgMinPieceW;
	private int imgMinPieceH;
	private float displayMargin;
	private int deskW;
	private int deskH;
	private int imgW;
	private int imgH;
	private int minPieceSize;
	private int pieceMinW;
	private int pieceMinH;
	private int pieceBorderCol;
	private int pieceBorderRow;
	private int pieceLocsIn;
	private IntArray tableArray;
	private ByteArray pieceSideArray;
	private Texture pixmap2Texture;
	private Pixmap templateAtlas;
	private ObjectSizer sizer;
	private int iterator;

	public Desk() {
	}

	private void getDeviceData() {
		GameMain main = GameMain.getInstance();
		this.atlasMaxSize = main.atlasMaxSize;
		this.displayW = main.displayW;
		this.displayH = main.displayH;
		this.totalMemory = main.totalMemory;
		this.freeMemory = main.freeMemory;
		this.maxMemory = main.maxMemory;
		this.dpi = main.dpi;
	}

	@Override
	public void show() {

		// создаем хранилище для данных уровня
		// получаем данные по уровню игры
		byte level = 1;
		o = new PuzzleOptions(level);
		// получаем данные о уровне
		getLevelData();
		// получаем данные из главного класса
		getDeviceData();
		// Адаптируем картинку к размеру экрана и свободную память
		getLevelDimensions();
		// размеры картинки к 1/2 экрана
		getMinImgToDisplaySize();
		// размеры мин картинки к кусочкам пазла, получаем мин размеры пазла
		getMinImgToMinPiece();

		scaleImg(deltaScale);
		// получаем замок и растяжение
		setLockColRowBorder();
		// Передаем данные в хранилище
		saveData();

		// создаем массив замков исходя из процента замков разных видов
		createPieceLocsArr();
		// ОПРЕДЕЛЯЕМ НОМЕРА КУСОЧКОВ С БОНУСАМИ
		createPieceX2Map();

		// Прямой многомерный массив с параметрами таблицы
		// Размеры столбцов и строк [colBW,colBW,...],[rowBH, rowBH,...]
		tableArray = o.createTableArray();
		// Прямой многомерный массив с расположением кусочков [x,y],[x,y],...
		pieceXYArray = o.createPieceXYArray();
		// Прямой многомерный массив с типом и форматом замков [[side1,
		// formatside1],[side2, formatside2]..],...
		pieceSideArray = o.createPieceSideArray();

		// Заполняем массив размеров сторон кусочков
		setTableArray();
		// Получаем координаты каждого кусочка Х и У и сохраняем их и
		// Обсчитываем стороны кусочка
		setPieceXYandSideArray();

		// находим максимальный размер маски

		// XXX получаем кусочки
		// Piece atlas = Piece.getInstance(options);
		// Piece2 atlas1 = Piece2.getInstance(options);
		Piece3 pieceManager = Piece3.getInstance(o).init();
		// img = atlas.create();
		// img = atlas1.create();
		pieceAtlas = pieceManager.atlasPixmap;
		templateAtlas = pieceManager.templatePixmap;

		// XXX Рисуем картинку. Качество можно регулировать от характеристик
		// устройства
		pixmapTexture = new Texture(pieceAtlas, Format.RGBA8888, false);
		pixmap2Texture = new Texture(templateAtlas, Format.RGBA8888, false);
		pixmap2Texture.setWrap(TextureWrap.Repeat, TextureWrap.Repeat);

		// Создаем камеру
		camera = new OrthographicCamera(displayW, displayH);
		camera.setToOrtho(true);
		// camera.translate(400, 300);
		batch = new SpriteBatch();

		// Создаем камеру2
		camera2 = new OrthographicCamera(displayW, displayH);
		camera2.setToOrtho(true);
		batch2 = new SpriteBatch();

		Gdx.input.setInputProcessor(new MyInputListener());
		// Gdx.input.setInputProcessor(null);

	}

	private void setPieceXYandSideArray() {
		long pieceX = 0;
		long pieceY = 0;
		for (int r = 0; r < row; r++) {
			for (int c = 0; c < col; c++) {
				// XXX Получаем координаты каждого кусочка Х и У и сохраняем их
				// в
				// массиве х,у
				// Х
				if (c == 0) {
					pieceX = 0;
				} else {
					pieceX = pieceXYArray.get(col * r * 2 + c * 2 - 2)
							+ pieceMinW + tableArray.get(c - 1);
				}
				// Y
				if (r == 0) {
					pieceY = 0;
				} else {
					pieceY = pieceXYArray.get(col * (r - 1) * 2 + c * 2 + 1)
							+ pieceMinH + tableArray.get(col + r - 1);
				}
				// Сохраняем данные X и У
				pieceXYArray.add((int) pieceX);
				pieceXYArray.add((int) pieceY);

				// XXX Обсчитываем стороны кусочка
				// Кусочки
				// row1++++++col1+col2+col3
				// row2++++++col1+col2+col3
				// row3++++++col1+col2+col3

				// Стороны
				// --0--
				// 3 X 1
				// --2--

				// Начало данных кусочка
				int startSide = c * 4 + r * col * 4;
				int reverse0 = c * 4 + (r - 1) * col * 4 + 2;
				int reverse3 = (c - 1) * 4 + r * col * 4 + 1;

				// 0 сторона
				if (r == 0) {
					// верхняя кромка
					pieceSideArray.add((byte) 0);
				} else {
					byte data = pieceSideArray.get(reverse0);
					pieceSideArray.add((byte) (data * (-1)));
				}
				// 1 сторона
				if (c == col - 1) {
					// правая кромка
					pieceSideArray.add((byte) 0);
				} else {
					byte data = getRandomSideLock();
					pieceSideArray.add((byte) data);
				}
				// 2 сторона
				if (r == row - 1) {
					// нижняя кромка
					pieceSideArray.add((byte) 0);
				} else {
					byte data = getRandomSideLock();
					pieceSideArray.add((byte) data);
				}
				// 3 сторона
				if (c == 0) {
					// левая кромка
					pieceSideArray.add((byte) 0);
				} else {
					byte data = pieceSideArray.get(reverse3);
					pieceSideArray.add((byte) (data * (-1)));
				}
			}
		}
	}

	private void setTableArray() {
		// Заполняем массив размеров сторон кусочков
		// Длинна столбца
		int countW = 0;
		int colBW = 0;
		int rowBH = 0;
		for (int c = 0; c < col; c++) {
			// Расчитываем длинну колонки
			if (c % 2 == 0) {
				// Плавающий размер каждой первой колонки
				// Учитываем последнюю колонку
				if (c == col - 1) {
					colBW = pieceBorderCol;
				} else {
					colBW = Math.round(pieceBorderCol * 2 * rnd.nextFloat());
				}

			} else {
				colBW = pieceBorderCol * 2 - tableArray.get(c - 1);
			}

			// Прибавляем остаток
			countW += colBW + pieceMinW;
			if (c == col - 1) {
				colBW += imgW - countW;
			}
			// Сохраняем переменные
			tableArray.add(colBW);

		}

		// Высота строки
		int countH = 0;
		for (int r = 0; r < row; r++) {
			// Расчитываем высоту строки
			if (r % 2 == 0) {
				// Учитываем последнюю колонку
				if (r == row - 1) {
					rowBH = pieceBorderRow;
				} else {
					rowBH = Math.round(pieceBorderRow * 2 * rnd.nextFloat());
				}
			} else {
				rowBH = pieceBorderRow * 2 - tableArray.get(col + r - 1);
			}
			// Прибавляем остаток
			countH += rowBH + pieceMinH;
			if (r == row - 1) {
				rowBH += imgH - countH;
			}
			// Сохраняем переменные
			tableArray.add(rowBH);
		}
	}

	private void createPieceX2Map() {
		// ОПРЕДЕЛЯЕМ НОМЕРА КУСОЧКОВ С БОНУСАМИ
		// Всего бонусов, получаем из настроек уровня
		// Передаем данные в переменные
		int x2 = pieceX2;
		// Массив с номерами кусочков бонусов
		IntArray pieceTotalArray = new IntArray(pieceLocsIn);
		// Размер массива, size еще равно 0 поэтому pieceLocsIn
		int L = pieceLocsIn;
		// Заполняем массив
		while (L-- > 0) {
			pieceTotalArray.add(pieceLocsIn - L - 1);
		}
		// Массив с номерами выбранными из списка
		L = x2;
		// Массив, длинною равной количеству внутренних замков
		ObjectMap<Integer, Float> pieceX2Map = o.pieceX2Map;

		while (L-- > 0) {
			int size = pieceTotalArray.size;
			if (size < 1)
				break;
			// Получаем случайное число в массиве
			int randomX2 = rnd.nextInt(size);
			// Берем число под данным номером, и удаляем из общего массива
			int index = pieceTotalArray.removeIndex(randomX2);
			// Добавляем в массив данный номер
			pieceX2Map.put(index, 2f);
		}
		// Вычищаем массив из памяти
		pieceTotalArray.clear();
		pieceTotalArray = null;

	}

	private void createPieceLocsArr() {
		// Количество каждого из видов замков
		// Процент каждого из видов замков
		ObjectMap<Byte, Integer> pieceLocsPros = o.pieceLocsPros;
		// Массив показывающий сколько замков исходя из процента замков разных
		// видов
		pieceLocsArr = new ByteArray(pieceLocsIn);
		int pieceLocsNum = 0;
		int countTotal = 0;
		// А это перебор словаря
		for (byte key : pieceLocsPros.keys()) { // пробегаемся по ключам
			int value = pieceLocsPros.get(key); // значению по ключу
			pieceLocsNum = (int) ceil(value * pieceLocsIn * 0.01f);
			// Заполняем массив
			int count = 0;
			while (count < pieceLocsNum) {
				// Ограничиваем и от ошибки защищаем
				if (countTotal >= pieceLocsIn)
					break;
				pieceLocsArr.add(key);
				count++;
				countTotal++;
			}
		}

		// Перемешиваем массив
		int L = pieceLocsArr.size;
		gameRND = o.getGameRND();
		rnd = new Random(gameRND);
		int counter = 0;
		while (counter < L) {
			// Получаем случайное число в массиве
			int index = rnd.nextInt(L);
			// Если равно счетчику, то пропускаем
			if (counter == index)
				continue;
			// Меняем данные счетчика и нового номера в массиве
			byte tmp = pieceLocsArr.get(index);
			pieceLocsArr.set(index, pieceLocsArr.get(counter));
			pieceLocsArr.set(counter, tmp);
			counter++;
		}
	}

	private void saveData() {
		// Передаем данные в хранилище
		// Активируем сохранение всех параметров в отдельном классе
		sizer = new ObjectSizer();
		o.W = imgW;
		o.H = imgH;
		o.pieceMinW = pieceMinW;
		o.pieceMinH = pieceMinH;
		o.lockSize = lockSize;
		o.atlasMaxSize = atlasMaxSize;
		o.pieceX2 = pieceX2;
	}

	private void setLockColRowBorder() {
		// Находим какая сторона наименьшая и по ней находим размер замочков, он
		// будет одинаковый для всех сторон
		int minPieceSize = (pieceMinW < pieceMinH) ? pieceMinW : pieceMinH;
		// Размеры замочков
		lockSize = round(minPieceSize / 5);
		// Размер плавающих границ по горизонтали и вертикали
		pieceBorderCol = (int) (ceil((imgW - pieceMinW * col) / col));
		pieceBorderRow = (int) (ceil((imgH - pieceMinH * row) / row));
	}

	private void scaleImg(float deltaScale) {

		// проверяем новый размер атласа
		if (checkDeltaScale(deltaScale)) {
			// Новый размер
			imgW = round(imgW * deltaScale);
			imgH = round(imgH * deltaScale);
		}

		// изменяем изображения исходя из новых размеров
		o.mainImgFormatPix(imgW, imgH);
	}

	private boolean checkDeltaScale(float deltaScale) {
		// Расчитываем максимальный размер атласа
		// Больший размер кусочка
		int pieceNum = (col > row) ? col : row;
		// Большая сторона картинки
		int imgMaxSize = (imgW > imgH) ? imgW : imgH;
		imgMaxSize *= deltaScale;
		// размер кусочка
		int lockSize = imgMaxSize / pieceNum / 5;
		int atlasSize = imgMaxSize + (lockSize * 2) * (pieceNum - 1)
				+ (pieceNum - 1) - lockSize * (pieceNum - 1);

		// проверка атласа
		if (atlasSize >= atlasMaxSize) {
			return false;
		}
		return true;
	}

	private void getMinImgToMinPiece() {
		// Проверяем чтобы новый размер был больше минимального размера по
		// замочкам
		if (imgMinPieceW > imgW || imgMinPieceH > imgH) {
			// Для масшабирования полученной картинки
			float imgToPieceW = (float) imgMinPieceW / imgW;
			float imgToPieceH = (float) imgMinPieceH / imgH;
			// Принимаем коэф. который меньше и увеличиваем исходное изображение
			float pieceScale = imgToPieceW > imgToPieceH ? imgToPieceW
					: imgToPieceH;
			imgW = round(imgW * pieceScale);
			imgH = round(imgH * pieceScale);
		}
		// размер кусочков
		pieceMinW = (int) ceil(imgW / col);
		pieceMinH = (int) ceil(imgH / row);
	}

	private void getMinImgToDisplaySize() {
		// Находим минимальное соотношение, по которому ориентируемся
		// Для масшабирования полученной картинки
		float deskW2 = deskW / 2;
		float deskH2 = deskH / 2;
		float imgToDisplayW = (float) deskW2 / imgW;
		float imgToDisplayH = (float) deskH2 / imgH;
		// Принимаем коэф. который меньше и уменьшаем исходное изображение
		float displayScale = imgToDisplayW < imgToDisplayH ? imgToDisplayW
				: imgToDisplayH;
		imgW = round(imgW * displayScale);
		imgH = round(imgH * displayScale);
	}

	private void getLevelDimensions() {
		// наименьшая сторона экрана
		int minImgSize = (imgW > imgH) ? imgH : imgW;
		// наименьшая сторона экрана
		int minDisplaySize = (displayW > displayH) ? displayH : displayW;
		// размеры экрана в дюймах
		float standartSize = 2;
		// эталонное размер кусочка
		minPieceSize = 48;
		// соотношения экрана эталонное
		float standartDelta = standartSize / (320f / minPieceSize);
		// мин размер экрана в дюймах
		float minInchSize = minDisplaySize / dpi;
		// размеры кусочка исходя из пикселей на дюйм
		float minPieceInch = standartDelta * dpi;
		// соотношение размеров экрана в дюймах
		float deltaInch = minInchSize / standartSize;
		// мин размер кусочка исходя из размеров экрана
		float minPieceDisplay = minPieceInch * deltaInch;
		// находим какая сторона делится на большее кол-во кусочков
		float sideW = imgW / col;
		float sideH = imgH / row;
		// мин размер кусочка по изображению
		int minPieceImg = (int) ((sideW > sideH) ? sideH : sideW);

		// берем наименьший размер
		minPiece = (minPieceImg > minPieceDisplay) ? minPieceDisplay
				: minPieceImg;
		// проверяем размеры атласа, чтобы он был меньше макс
		minPiece = checkMinPiece(minPiece);
		// Узнаем минимальный размер по кусочкам
		imgMinPieceW = round(col * minPiece);
		imgMinPieceH = round(row * minPiece);
		// Расчитываем размеры картинки относительно экрана. Размеры без
		// маштабирования. 0.98f отступы от края
		// float displayMargin = 0.98f;
		displayMargin = 1f;
		deskW = round(displayW * displayMargin);
		deskH = round(displayH * displayMargin);

	}

	private float checkMinPiece(float minPiece2) {
		// Расчитываем максимальный размер атласа
		// Больший размер кусочка
		int pieceMaxNum = (col > row) ? col : row;
		// Большая сторона картинки
		int imgMaxSize = (int) (pieceMaxNum * minPiece2);
		// размер кусочка
		int lockSize = (int) (minPiece2 / 5);
		int atlasSize = imgMaxSize + (lockSize * 2) * (pieceMaxNum - 1)
				+ (pieceMaxNum - 1) - lockSize * (pieceMaxNum - 1);

		// проверка атласа
		float pieceScale1 = (float) atlasMaxSize / (float) atlasSize;

		if (pieceScale1 < 1) {
			return checkMinPiece(minPiece2 * pieceScale1);
		}
		return minPiece2;
	}

	private void getLevelData() {
		this.col = o.col;
		this.row = o.row;
		this.pieceX2 = o.pieceX2;
		// размеры картинки
		this.imgW = o.mainImgW();
		this.imgH = o.mainImgH();
		// увеличиваем размеры минимальной картинки, для разнообразия кусочков
		this.deltaScale = 1.5f;
		// deltaScale = 2f;
		// deltaScale = 1f;
		// Количество внутренних замков
		this.pieceLocsIn = (col - 1) * row + (row - 1) * col;
	}

	private Byte getRandomSideLock() {
		// Длинна массива
		int L = pieceLocsArr.size;
		// Выбираем один из типов замков
		int random = rnd.nextInt(L);
		// Передаем тип
		// byte side = pieceLocsArr.removeIndex(random);
		byte side = (byte) pieceLocsArr.removeIndex(random);
		// Случайная инверсия
		if (rnd.nextFloat() < 0.5) {
			side *= -1;
		}
		return side;
	}

	@Override
	public void dispose() {
		batch.dispose();
		pixmapTexture.dispose();
		// System.out.println("dispose");
	}

	@Override
	public void pause() {
		pixmapTexture.dispose();
		System.out.println("pause");
	}

	@Override
	public void render(float deltaTime) {
		// передаем массив кусочков
		if (atlasXYWHArray == null) {
			atlasXYWHArray = o.atlasXYWHArray;
		}

		// XXX render
		Gdx.gl.glClearColor(1, 1, 1, 1);
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

		batch.setProjectionMatrix(camera.combined);

		batch.begin();

		for (int r = 0; r < row; r++) {
			for (int c = 0; c < col; c++) {
				int x = atlasXYWHArray.get((r * col + c) * 4);
				int y = atlasXYWHArray.get((r * col + c) * 4 + 1);
				int w = atlasXYWHArray.get((r * col + c) * 4 + 2);
				int h = atlasXYWHArray.get((r * col + c) * 4 + 3);

				region = new TextureRegion(pixmapTexture, x, y, w, h);
				region.flip(false, true);

				float x2 = x - (lockSize) * c - c;
				float y2 = y - (lockSize) * r - r;

				// Пробуем отследить уменьшение масштаба
				float deltaSW = (displayW - displayW * zoom) / 2;
				float deltaSH = (displayH - displayH * zoom) / 2;
				// x2 += deltaSW;
				// y2 += deltaSH;

				x2 += moveX / 10 * c;
				y2 += moveX / 10 * r;
				batch.draw(region, x2, y2);

				// batch.setColor(1, 0, 0, 0.1f);
				// batch.maxSpritesInBatch = 1;
				// batch.draw(region, x2, y2, w >> 1, h >> 1, w, h, 1, 1,
				// (0 - moveX));

				// region.setRegion(x, y, w, h);
				// break;
			}
			// break;
		}

		// batch.draw(pixmapTexture, 0, 0);
		batch.end();

		// System.out.println("renderCalls: " + batch.renderCalls);

		batch2.setProjectionMatrix(camera2.combined);
		batch2.begin();
		region = new TextureRegion(pixmap2Texture, 0, 0,
				pixmap2Texture.getWidth() / 2, pixmap2Texture.getHeight() / 2);
		region.flip(false, true);

		// pixmap2Texture.setWrap(TextureWrap.Repeat, TextureWrap.Repeat);
		// batch2.draw(pixmap2Texture, 0, 0,800,600, 0, 0,2,2);

		// region.setRegion(0, 0, 100, 100);
		// region.
		// region.setRegion(0, 0, 100, 100);
		// pixmap2Texture = region.getTexture();
		// pixmap2Texture.setWrap(TextureWrap.Repeat, TextureWrap.Repeat);
		// batch2.draw(pixmap2Texture, 0, 0,800,600, 0, 0,2,2);
		// TiledDrawable tiled = new TiledDrawable(region);

		 batch2.draw(region, 0, 0);
		// tiled.draw(batch2, 0, 0, 600, 600);

		batch2.end();

		moveX++;

		// camera.rotate(0.6f);
		// zoom -= 0.01f;
		if (zoom < 0.1f) {
			zoom = 0.1f;
			// moveX = 0;
		}
		// System.out.println("zoom: " + zoom);
		// zoom += 0.01f;
		zoom -= 0.01f;
		camera.zoom = zoom;

		// camera.update();
		// Делаем время отрисовки 25 кадров
		float timeMax = 1 / 25f;
		float deltaF = timeMax - deltaTime;
		delta = (int) ((deltaF * 1000) + delta);
		// System.out.println(timeMax + " - " + deltaTime + " - " + delta);
		if (delta > 0) {
			try {
				Thread.sleep(delta);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} else {
			delta = 0;
		}

		// float l = Gdx.graphics.getFramesPerSecond();
		// System.out.println(l);

		// System.out.println("render");
		
		if (iterator > 10) {
			GameMain.getInstance().setScreen(0);
		}

		iterator++;
	}

	@Override
	public void resize(final int width, final int height) {
		// System.out.println("resize");
		// Размеры экрана
		// SW = Gdx.graphics.getWidth();
		// SH = Gdx.graphics.getHeight();
		// camera.viewportHeight = SH;
		// camera.viewportWidth = SW;
		// camera.update();
	}

	@Override
	public void resume() {
		pixmapTexture = new Texture(pieceAtlas, Format.RGBA8888, false);
		// System.out.println("resume");
	}

	@Override
	public void hide() {
		// TODO Auto-generated method stub

	}

}
