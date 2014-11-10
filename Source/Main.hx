package;

import openfl.Lib;
import openfl.display.Loader;
import openfl.net.URLRequest;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;

import sys.io.File;
import sys.io.FileOutput;

class Main{
	var _PNGin:Loader;
	var _PNGdata:BitmapData;
	var _palletLoad:Array<UInt>;
	var _spriteMap:Array<Array<Int>>;

	public function new () {
		_PNGin = new Loader();
		_PNGin.load(new URLRequest("img.png"));
		Lib.current.stage.addChild(_PNGin.content);
		_PNGdata = new BitmapData(256, 136, false, 0xFFFFFF);
		_PNGdata.draw(_PNGin.content);

		_palletLoad = new Array<UInt>();
		for (__y in 0...2) {
			for (__x in 0...8) {
				_palletLoad.push(_PNGdata.getPixel(__x, __y + 128));
			}
		}


		_spriteMap = new Array<Array<Int>>();
		for (__y in 0...16) {
			for (__x in 0...32) {
				grabSpriteAt(__x, __y);
			}
		} 

		printOut();
	}

	public function grabSpriteAt(_x:Int, _y:Int) {
		var __sprite:Array<Int> = new Array<Int>();
		for (__y in 0...8) {
			for (__x in 0...8) {
				var _push:Int = -1;
				for (n in 0..._palletLoad.length) {
					if (_PNGdata.getPixel(__x + (_x * 8), __y + (_y * 8)) == _palletLoad[n] && _push == -1) {
						_push = n;
					}
				}
				__sprite.push(_push);
			}
		} 
		_spriteMap.push(__sprite);
	}

	public function printOut() {

		var _fileName = "spriteDump.c";
		var _pen = File.write(_fileName, false);

		_pen.writeString("unsigned int omegaSprite[" + 4096 + "] = {\n");
		var tick:Int = -1;
		for (_n in 0..._spriteMap.length) {
			for (_y in 0..._spriteMap[_n].length) {
				if (tick == -1) {
					_pen.writeString("\t(");
					tick = 0;
				}

				if (tick >= 0 && tick < 8) {
					_pen.writeString("(" + _spriteMap[_n][_y] + " << " + tick * 4 + ")");

					if (tick < 7) {
						_pen.writeString(" | ");
					}

					tick += 1;
				}

				if (tick >= 8) {
					_pen.writeString("),\n");
					tick = -1;
				}
			}
		}
		_pen.writeString("};\n");

		_pen.close();
		trace("Done!");
	}
}