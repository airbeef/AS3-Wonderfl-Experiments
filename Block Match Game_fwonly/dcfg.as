/**
 * Copyright samegame ( http://wonderfl.net/user/samegame )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/dcfg
 */

/**
 * 終了時にリザルト画面を表示するようにした。
 * とりあえず、GAMEOVERの演出だけ。
 * あと目標スコア導入
 * 
 * 問題点：
 * 立ち上げたときに"+ 0"が出るのを何とかする
 * ステージの導入
 * デザインの調整
 **/
package
{
	import flash.display.Sprite;
	
	[SWF(backgroundColor = "0x0")]
	public class Main extends Sprite
	{
		public function Main()
		{
			// サムネの見栄え用
			graphics.beginFill(0x0);
			graphics.drawRect(0, 0, 465, 465);
			graphics.endFill();
			
			var panel:Panel = new Panel();
			addChild(panel);
		}
	}
}

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.filters.BevelFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Matrix;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;

class ScorePanel extends Sprite
{
	public var score:int = 0;
	public var scoreTF:TextField;
	public var scoreBitmap:Bitmap;
	public var targetScore:int = 100000;
	public var targetBitmap:Bitmap;
	
	public function ScorePanel()
	{
		var tf:TextField = Text.createTextField("Score", 30, 0xFFC700);
		tf.x = 40;
		addChild(tf);
		
		scoreTF = Text.createTextField("0", 23, 0x0);

		scoreBitmap = new Bitmap();
		scoreBitmap.x = tf.x;
		scoreBitmap.y = tf.y + 50;
		addChild(scoreBitmap);
		
		
		graphics.beginFill(0xED1A3D);
		graphics.drawRoundRect(30, 90, 100, 2, 10, 10);
		graphics.endFill();
		
		var bd:BitmapData = Text.getText(targetScore.toString(), 32, 0xFFFFFF, [0xFF9900, 0xFFDD00, 0xFF9900]);
		
		targetBitmap = new Bitmap(bd);
		targetBitmap.x = tf.x;
		targetBitmap.y = tf.y + 90;
		addChild(targetBitmap);
		
		incrementScore(0);
	}
	
	// スコアを増やす。引数は一度に消したブロックの数
	public function incrementScore(count:int):void
	{
		score += count * count * count * 10;
		scoreTF.text = score.toString();
		
		var bd:BitmapData = Text.getText(scoreTF.text, 32, 0xFFFFFF, [0xFF9900, 0xFFDD00, 0xFF9900]);
		scoreBitmap.bitmapData = bd;
		
		// "+ 200のような文字列を表示させる"
		var bd2:BitmapData = Text.getText("+ " + count * count * count * 10, 20, 0x0, [0xFF9900, 0xFFBB00, 0xFF9900]);
		var bitmap:Bitmap = new Bitmap(bd2);
		bitmap.x = 40;
		bitmap.y = 35;
		
		BetweenAS3.serial
		(
			BetweenAS3.addChild(bitmap, this), // "+ 200"のような文字を表示させる
			BetweenAS3.tween(bitmap, { x:bitmap.x + 20, alpha:0.2 }, null, 1.0), // 右に移動しながら透明度を下げる
			BetweenAS3.removeFromParent(bitmap) // 1秒経ったら消す
		).play();
	}
}

class Text
{
	public static function createTextField(text:String, size:int, color:int, align:String = "left"):TextField
	{
		var tf:TextField = new TextField();
		tf.defaultTextFormat = new TextFormat("typeWriter_", size, color, true, null, null, null, null, align);
		tf.text = text;
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.selectable = false;
		
		return tf;
	}
	
	// 文字をグラデーションにする
	public static function getText(text:String, size:int, color:int, gcolor:Array):BitmapData
	{
		var tf:TextField = Text.createTextField(text, size, color);
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(tf.width, tf.height, -45 * Math.PI / 180);
		var gradation:Sprite = new Sprite();
		gradation.graphics.beginGradientFill("linear", gcolor, [1.0, 1.0, 1.0], [0, 128, 255], matrix);
		gradation.graphics.drawRect(0, 0, tf.width, tf.height);
		gradation.graphics.endFill();
		
		
		var alphabd:BitmapData = new BitmapData(tf.width, tf.height, true, 0x0);
		alphabd.draw(tf);
		
		var sourcebd:BitmapData = new BitmapData(gradation.width, gradation.height, true, 0x00);
		sourcebd.draw(gradation);
		
		var bd:BitmapData = new BitmapData(tf.width, tf.height, true, 0x0);
		bd.copyPixels(sourcebd, sourcebd.rect, new Point(), alphabd, new Point(), true);
		
		return bd;
	}
}

class ResultPanel extends Sprite // 結果表示画面
{
	private const HEIGHT:int = 150;
	
	public function ResultPanel(panel:Panel)
	{
		// 画面は黒く
		graphics.beginFill(0x0);
		graphics.drawRect(0, 0, 465, HEIGHT);
		graphics.endFill();
		
		// アクセントとして上下に白線を入れておく
		graphics.lineStyle(3.0, 0xFFFFFF);
		graphics.moveTo(0, 0);
		graphics.lineTo(465, 0);
		graphics.moveTo(0, HEIGHT);
		graphics.lineTo(465, HEIGHT);
		
		// ベベルで質感を
		this.filters = [new BevelFilter(4, 90, 0xFFFFFF, 1, 0xFFFFFF, 1, 20, 20, 1, 3, "inner")];
		
		// 画面中央に配置
		this.y = (this.width - HEIGHT) / 2;
		
		// 残りブロック数
		var countBlock:TextField = Text.createTextField("残りブロック数: " + panel.countBlocks(), 20, 0xFFCC00);
		countBlock.x = (this.width - countBlock.width) / 2;
		countBlock.y = 10;
		
		//　スコア
		var scoreTF:TextField = Text.createTextField("スコア: " + panel.scorePanel.score, 20, 0xFF9900);
		scoreTF.x = countBlock.x;
		scoreTF.y = countBlock.y + countBlock.height + 10;
		
		// 結果
		var kekka:TextField = Text.createTextField("結果: ", 30, 0xFFBB00);
		kekka.x = countBlock.x - 2;
		kekka.y = scoreTF.y + 50;
		
		// 合否アニメーションテキスト
		var result:TextField = Text.createTextField("", 30, 0xFFBB00);
		result.x = countBlock.x + 90;
		result.y = scoreTF.y + 50;
		
		var t2:ITween = 
		BetweenAS3.parallel
		(
			BetweenAS3.tween(countBlock, { x: -countBlock.width } ),
			BetweenAS3.tween(scoreTF, { x:465 } ),
			BetweenAS3.tween(kekka, { x: -(kekka.width + 97) } ),
			BetweenAS3.tween(result, { x: -97 } )
		);
		
		var goukaku:Array;
		if (panel.scorePanel.targetScore < panel.scorePanel.score)
		{
			goukaku = ["g", "go", "gou", "合", "合k", "合ka", "合kak", "合kaku", "合格"];

		}
		else
		{
			goukaku = ["h", "hu", "不", "不g", "不go", "不gou", "不合", "不合k", "不合ka", "不合kak", "不合kaku", "不合格"];
			var gameover:Bitmap = new Bitmap(Text.getText("GAME OVER", 40, 0x0, [0xFFFFFF, 0xED1A3D, 0xFFFFFF]));
			gameover.x = (this.width - gameover.width) / 2;
			gameover.y = (this.height - gameover.height) / 2;
			gameover.alpha = 0.0;
			
			t2 = BetweenAS3.serial
			(
				t2,
				BetweenAS3.addChild(gameover, this),
				BetweenAS3.tween(gameover, { alpha:1.0 }, null, 2.0)
			)
		}
		
		var t:ITween = 
		BetweenAS3.serial
		(
			BetweenAS3.delay(BetweenAS3.addChild(result, this), 1),
			BetweenAS3.delay(BetweenAS3.func(function():void { result.text = goukaku[0]; } ), 0.1)
		);
		
		var index:int = 0; // クロージャ対策
		for (var i:int = index; i < goukaku.length; i++)
		{
			t = BetweenAS3.serial
			(
				t,
				BetweenAS3.delay(BetweenAS3.func(function():void { result.text = goukaku[index++]; } ), 0.1)
			)
		}
		
		t = BetweenAS3.serial
		(
			BetweenAS3.delay(BetweenAS3.tween(this, { x:0, y:y }, { x:470 } ), 2),
			BetweenAS3.addChild(countBlock, this),
			BetweenAS3.delay(BetweenAS3.addChild(scoreTF, this), 1),
			BetweenAS3.delay(BetweenAS3.addChild(kekka, this), 1),
			BetweenAS3.delay(t, 0, 1),
			t2
		);
		t.play();
	}
}

class Panel extends Sprite // ブロックはパネルに貼る
{
	public static const WIDTH:int = 10; 	// ブロックの数 - 横
	public static const HEIGHT:int = 10; 	// ブロックの数　- 縦
	
	private var blocks:Array; // ブロックが入っている配列(二次元配列
	public var countPanel:CountPanel; // 残りブロック表示数を貼り付けているパネル
	public var scorePanel:ScorePanel; // スコアのパネル
	public var deleteCount:int = 0; // ブロックが一度に消えた数を保持
	
	public function Panel()
	{
		createBlocks();
		
		scorePanel = new ScorePanel();
		scorePanel.x = Block.WIDTH * WIDTH + 10;
		scorePanel.y = 5;
		addChild(scorePanel);
		
		countPanel = new CountPanel(blocks);
		countPanel.y = Block.HEIGHT * HEIGHT; // 盤面の下へ配置 
		addChild(countPanel);
	}
	
	// 二次元配列を作る。その配列にブロックを代入。
	private function createBlocks():void
	{
		blocks = new Array(WIDTH);
		
		for (var y:int = 0; y < HEIGHT; y++)
		{
			blocks[y] = new Array(HEIGHT);
			
			for (var x:int = 0; x < WIDTH; x++)
			{
				var block:Block = new Block();
				block.x = x * Block.WIDTH;
				block.y = y * Block.HEIGHT;
				addChild(block);
				
				blocks[y][x] = block;
			}
		}
	}
	
	// 二次元配列から引数のブロック位置を検索。
	// 見つかったらPoint(x, y)で返却。
	// 見つからなかったらnullを返す
	public function searchBlock(block:Block):Point
	{
		for (var y:int = 0; y < HEIGHT; y++)
		{
			for (var x:int = 0; x < WIDTH; x++)
			{
				if (blocks[y][x] == block)
				{
					return new Point(x, y); // ブロックが見つかったので、Pointで返却。
				}
			}
		}
		
		return null; // 見つからなかったのでnullを返す。
	}
	
	// ブロックを消す処理
	// block[ty][tx].colorが引数で渡されたcolorと同じなら削除
	// 上下左右のブロックを調べる
	public function deleteBlock(tx:int, ty:int, color:int):void
	{
		if (tx < 0 || WIDTH <= tx || 
			ty < 0 || HEIGHT <= ty) return; // 配列外ならリターン
		
		if (blocks[ty][tx] == null) return; // nullだったらリターン
		if (blocks[ty][tx].color != color && blocks[ty][tx].color != color + Block.SPECIAL) return; // クリックしたブロックの色と違っていたらリターン
		
		// 条件は満たしたのでブロックを消す
		removeChild(blocks[ty][tx]);
		blocks[ty][tx] = null;
		countPanel.decrementValue(color);
		deleteCount++;
		
		// 周りの色を調べる
		deleteBlock(tx - 1, ty, color); // 左へ
		deleteBlock(tx + 1, ty, color); // 右へ
		deleteBlock(tx, ty - 1, color); // 上へ
		deleteBlock(tx, ty + 1, color); // 下へ
	}
	
	// ブロックを消すと隙間が空くので縦に詰める処理
	// 左から右へ、下から上へ走査する
	public function verticalPackBlock():void
	{
		for (var x:int = 0; x < WIDTH; x++)
		{
			for (var y:int = HEIGHT - 1; y >= 0; y--)
			{
				if (blocks[y][x] == null) // 隙間が空いているブロックを見つけた
				{
					for (var yy:int = y - 1; yy >= 0; yy--) // その一つ上から縦に走査
					{
						if (blocks[yy][x] != null) // ブロックを見つけたので[y][x]まで詰めなければならない
						{
							blocks[y][x] = blocks[yy][x]; // 配列の位置を変更
							blocks[yy][x] = null;	//　元にあった位置は削除しておく
							
							// 0.3秒かけて下にずらす。
							BetweenAS3.tween(blocks[y][x], {y:y * Block.HEIGHT}, null, 0.3).play();
							
							break;
						}
					}
				}
			}
		}
	}
	
	// ブロックを消したとき、まるまる縦に一列空いてしまったら横に詰めなければならない。その処理がこのメソッド。
	// 最下段の左から右へ走査する
	public function horizonPackBlock():void
	{
		var y:int = HEIGHT - 1; //　一番下の段だけ走査
		
		for (var x:int = 0; x < WIDTH; x++)
		{
			if (blocks[y][x] == null) // 一番下の段に何もないということは、ここに右のブロックを詰めなければならない(端の可能性もあるけど
			{
				for (var xx:int = x + 1; xx < WIDTH; xx++) // その一つ右から走査。
				{
					if (blocks[y][xx] != null) // ブロックを見つけた
					{
						for (var yy:int = HEIGHT - 1; yy >= 0; yy--) // 縦の一段をまるまる左に詰める処理
						{
							if (blocks[yy][xx] == null) break; // もうずらすブロックがねーよ、ということでbreak
							
							blocks[yy][x] = blocks[yy][xx]; // 配列の位置を変更
							blocks[yy][xx] = null; // 元の位置にnullを入れておく
							
							// 0.3秒かけて左にずらす。
							BetweenAS3.tween(blocks[yy][x], {x:x * Block.WIDTH}, null, 0.3).play();
						}
						
						break;
					}
				}
			}
		}
	}
	
	// 残っているブロック数を返します
	public function countBlocks():int
	{
		var count:int = 0;
		
		for (var y:int = 0; y < HEIGHT; y++)
		{
			for (var x:int = 0; x < WIDTH; x++)
			{
				if (blocks[y][x]) count++;
			}
		}
		
		return count;
	}
	
	// もう消せるブロックが無いならfalse, まだ消せるブロックがあるようならtrueを返す
	public function endCheck():Boolean
	{
		for (var y:int = 0; y < HEIGHT; y++)
		{
			for (var x:int = 0; x < WIDTH; x++)
			{
				if (blocks[y][x] == null) continue;
				
				// 通常ブロックの処理
				if (blocks[y][x].color < Block.SPECIAL)
				{
					if (colorCheck(x, y, blocks[y][x].color)) return true; // 周りに同じ色が一つでもあったら
				}
				// 特殊ブロックの処理
				else
				{
					if (0 <= x - 1 && blocks[y][x - 1] != null && blocks[y][x - 1].color < Block.SPECIAL) return true;
					else if (x + 1 < WIDTH && blocks[y][x + 1] != null && blocks[y][x + 1].color < Block.SPECIAL) return true;
					else if (0 <= y - 1 && blocks[y - 1][x] != null && blocks[y - 1][x].color < Block.SPECIAL) return true;
					else if (y + 1 < HEIGHT && blocks[y + 1][x] != null && blocks[y + 1][x].color < Block.SPECIAL) return true;
				}
			}
		}
		
		return false;
	}
	
	// 周りに自分の色と同じマスが1つでもあったらtrue, なかったらfalse.
	public function colorCheck(tx:int, ty:int, color:int):Boolean
	{
		var check:Boolean = false;
		
		if (0 <= tx - 1 && blocks[ty][tx - 1] != null && (blocks[ty][tx - 1].color == color || blocks[ty][tx - 1].color == color + Block.SPECIAL)) check = true;
		else if (tx + 1 < WIDTH && blocks[ty][tx + 1] != null && (blocks[ty][tx + 1].color == color || blocks[ty][tx + 1].color == color + Block.SPECIAL)) check = true;
		else if (0 <= ty - 1 && blocks[ty - 1][tx] != null && (blocks[ty - 1][tx].color == color || blocks[ty - 1][tx].color == color + Block.SPECIAL)) check = true;
		else if (ty + 1 < HEIGHT && blocks[ty + 1][tx] != null && (blocks[ty + 1][tx].color == color || blocks[ty + 1][tx].color == color + Block.SPECIAL)) check = true;
		
		return check;
	}
}

class CountPanel extends Sprite // 残りブロック数を表示するクラス
{
	private var blocks:Array; // パネルから受け取ったブロックが入っている
	public var texts:Array;  // 表示用テキスト
	public var values:Array; // 残りブロック数
	
	public function CountPanel(blocks:Array)
	{
		this.blocks = blocks;
		
		// ブロックのデザイン
		graphics.beginFill(0x393939);
		graphics.drawRoundRect(0, 50, 300, 50, 20, 20);
		graphics.endFill();
		this.filters = [new BevelFilter(4, 45, 0xFFFFFF, 1, 0x0, 1, 20, 20, 1, 3, "inner")];
		
		values = new Array(Color.COLORS.length); // 色数の長さで初期化
		
		for (var i:int = 0; i < Color.COLORS.length; i++)
		{
			values[i] = 0;
		}
		
		for (var y:int = 0; y < Panel.HEIGHT; y++)
		{
			for (var x:int = 0; x < Panel.WIDTH; x++)
			{
				if (Block.SPECIAL <= blocks[y][x].color)
				{
					values[blocks[y][x].color - Block.SPECIAL]++;
				}
				else
				{
					values[blocks[y][x].color]++;
				}
			}
		}
		
		texts = new Array();
		for (i = 0; i < Color.COLORS.length; i++)
		{
			// ブロックを描画
			graphics.beginFill(Color.COLORS[i]);
			graphics.drawRoundRect(Block.WIDTH * i * 2.5 + Block.CW, Block.HEIGHT * 2, Block.WIDTH - Block.CW, Block.HEIGHT - Block.CH, Block.RW, Block.RH);
			graphics.endFill();this.filters = [new BevelFilter(4, 45, 0xFFFFFF, 1, 0x0, 1, 20, 20, 1, 3, "inner")];
			
			// 残り数を表示
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("_typeWriter", 20, 0xFFFFFF, true);
			tf.text = values[i];
			tf.x = Block.WIDTH + 5 + Block.WIDTH * i * 2.5;
			tf.y = Block.HEIGHT * 2 + 2;
			tf.selectable = false;
			addChild(tf);
			
			texts.push(tf);
		}
	}
	
	// 色番号を受け取りその色の残り数を減らす
	public function decrementValue(color:int):void
	{
		values[color]--;
		texts[color].text = values[color];
	}
	
	// 色番号を受け取りその色の残り数を増やす
	public function incrementValue(color:int):void
	{
		values[color]++;
		texts[color].text = values[color];
	}
}

class Block extends Sprite
{
	public static const WIDTH:int = 30; 	// ブロックの横幅
	public static const HEIGHT:int = 30; 	// ブロックの縦幅
	
	public static const CW:int = 2;			// 補正幅 - ブロック同士がくっつかないように
	public static const CH:int = 2;			// 補正縦
	
	public static const RW:int = 15;		// drawRoundRect()のellipseWidth
	public static const RH:int = 15;		// drawRoundRect()のellipseHeight
	
	public static const SPECIAL:int = 100;  // 特殊ブロックの番号
	
	public var color:int;					// 自分自身の色。といってもColorクラスのCOLORS配列indexをいれる。ブロック識別用。
	
	public function Block()
	{	
		this.color = Math.random() * Color.COLORS.length; // colorは色番号を保持しておく。
		//this.color = 1;
		
		if (0.05 >= Math.random())
		{
			graphics.beginFill(Color.COLORS[this.color]); // ランダムで色を選ぶ
			graphics.drawCircle(Block.WIDTH / 2 + Block.CW / 2, Block.HEIGHT / 2 + Block.CH / 2, Block.WIDTH / 2.2);
			graphics.endFill();
			
			this.color += Block.SPECIAL;
		}
		else
		{
			graphics.beginFill(Color.COLORS[this.color]); // ランダムで色を選ぶ
			graphics.drawRoundRect(CW, CH, WIDTH - CW, HEIGHT - CH, RW, RH);
			graphics.endFill();
		}
		
		this.filters = [new BevelFilter(4, 45, 0xFFFFFF, 1, 0x0, 1, 20, 20, 1, 3, "inner")]; // ベベルフィルターでブロックに質感を持たせる
		
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown); // ブロックをクリックしたらonMouseDown()を呼ぶ
	}
	
	private function onMouseDown(event:MouseEvent):void
	{
		var panel:Panel = this.parent as Panel; // ブロックはパネルに貼り付けるので、ブロックの親がパネルになる。this.parentで取得できる。
		
		var point:Point = panel.searchBlock(this); // ブロックの位置を検索
		if (point)
		{
			// 周りに自分と同じ色が無かったらクリックしたブロックを消すことが出来ないのでreturn
			if (this.color < Block.SPECIAL && !panel.colorCheck(point.x, point.y, this.color))
			{
				return;
			}
			
			if (this.color < Block.SPECIAL)
			{
				// 自分自身と周りのブロックを消す処理。
				// removeChild()と二次元配列から削除。
				// 上のparent.removeChild()を消して、panelに消す処理をまかせることにした。
				panel.deleteCount = 0; // 一度に消える数を数えたいので初期化
				panel.deleteBlock(point.x, point.y, this.color) // 自分自身の位置から削除スタート。
				panel.scorePanel.incrementScore(panel.deleteCount);
				
				panel.verticalPackBlock(); // ブロックを消すと隙間が空くので縦に詰める処理
				panel.horizonPackBlock(); // 同じく横に詰める処理
				if (!panel.endCheck())
				{
					panel.addChild(new ResultPanel(panel));
				}
			}
			else
			{
				changeColor();
			}
		}
	}
	
	// 特殊ブロックの色を変える
	private function changeColor():void
	{
		var panel:Panel = this.parent as Panel;
		panel.countPanel.decrementValue(this.color - 100);
		panel.countPanel
		this.color = ((this.color - Block.SPECIAL + 1) % Color.COLORS.length) + Block.SPECIAL;
		panel.countPanel.incrementValue(this.color - 100);
		
		graphics.clear();
		graphics.beginFill(Color.COLORS[this.color - Block.SPECIAL]);
		graphics.drawCircle(Block.WIDTH / 2 + Block.CW / 2, Block.HEIGHT / 2 + Block.CH / 2, Block.WIDTH / 2.2);
		graphics.endFill();
	}
}

// ブロックの色を保持している
class Color
{
	public static const COLORS:Array = [0xED1A3D, 0x00B16B, 0x007DC5, 0xf39800];
}