package qw.math
{
	
	public class DiamondSquare
	{
		private var data:Array;
		private var size:int;
		private var roughness:Number;
		private var seed:int;
		
		/**
		 * Конструктор
		 * @param size размер карты
		 * @param roughness шероховатость
		 * @param seed номер ландшафта
		 */
		public function DiamondSquare(size:int, roughness:Number, seed:int)
		{
			this.size = size;
			this.roughness = roughness;
			this.seed = seed;
			data = [];
		}
		
		private var ten:Vector.<uint> = new <uint>[10, 100, 1000, 10000, 100000, 1000000];
		
		private function val3(x:int, y:int, v:Number):void
		{
			data[(y < 100) ? x * 1000 + y : (x * ten[String(y).length] + y)] = Math.max(0, Math.min(1, v));
		}
		
		public function clear():void
		{
			data.length = 0;
			data = null;
		}
		
		public function val2(x:int, y:int):Number
		{
			if (x <= 0 || x >= size || y <= 0 || y >= size)
			{
				return 0;
			}
			if (data[(y < 100) ? x * 1000 + y : (x * ten[String(y).length] + y)]==null)
			{
				var base:int = 1;
				while (((x & base) == 0) && ((y & base) == 0))
					base <<= 1;
				
				if (((x & base) != 0) && ((y & base) != 0))
					squareStep(x, y, base);
				else
					diamondStep(x, y, base);
			}
			return data[(y < 100) ? x * 1000 + y : (x * ten[String(y).length] + y)];
		}
		
		//
		private var i:int;
		private var xm7:int;
		private var xm13:int;
		private var xm1301081:int;
		private var ym8461:int;
		private var ym105467:int;
		private var ym105943:int;
		
		private function randFromPair(x:int, y:int):Number
		{
			for (i = 0; i < 80; i++)
			{
				xm7 = x % 7;
				xm13 = x % 13;
				xm1301081 = x % 1301081;
				ym8461 = y % 8461;
				ym105467 = y % 105467;
				ym105943 = y % 105943;
				y = x + seed;
				x += (xm7 + xm13 + xm1301081 + ym8461 + ym105467 + ym105943);
			}
			
			return (xm7 + xm13 + xm1301081 + ym8461 + ym105467 + ym105943) / 1520972;
		}
		
		private function displace(v:Number, blockSize:int, x:int, y:int):Number
		{
			return (v + (randFromPair(x, y) - 0.5) * blockSize * 2 / size * roughness);
		}
		
		private function squareStep(x:int, y:int, blockSize:int):void
		{
			if (data[(y < 100) ? x * 1000 + y : (x * ten[String(y).length] + y)]==null)
			{
				val3(x, y, displace((val2(x - blockSize, y - blockSize) + val2(x + blockSize, y - blockSize) + val2(x - blockSize, y + blockSize) + val2(x + blockSize, y + blockSize)) / 4, blockSize, x, y));
			}
		}
		
		private function diamondStep(x:int, y:int, blockSize:int):void
		{
			if (data[(y < 100) ? x * 1000 + y : (x * ten[String(y).length] + y)]==null)
			{
				val3(x, y, displace((val2(x - blockSize, y) + val2(x + blockSize, y) + val2(x, y - blockSize) + val2(x, y + blockSize)) / 4, blockSize, x, y));
			}
		}
	
	}

}