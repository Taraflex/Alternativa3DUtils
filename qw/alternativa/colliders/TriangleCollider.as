package qw.alternativa.colliders
{
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.resources.Geometry;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import alternativa.engine3d.core.VertexAttributes;
	
	public class TriangleCollider
	{
		[Embed(source="../../pb/RayTriangleKernel.pbj", mimeType="application/octet-stream")]
		private static const RayTriangleKernelClass:Class;
		
		private var _rayTriangleKernel:Shader;
		private var _indexBufferDims:Point;
		private var _kernelOutputBuffer:Vector.<Number>;
		private var _collisionUV:Point;
		private var _collisionTriangleIndex:uint;
		private var _breakOnFirstTriangleHit:Boolean = false;
		private var _object:Mesh;
		protected var _collisionExists:Boolean;
		protected var _rayPosition:Vector3D;
		protected var _rayDirection:Vector3D;
		protected var _collisionPoint:Vector3D;
		protected var _t:Number;
		protected var indices:Vector.<Number>;
		protected var uvs:Vector.<Number>;
		
		public function TriangleCollider(object:Mesh)
		{
			_object = object;
			_rayPosition = new Vector3D();
			_rayDirection = new Vector3D();
			_collisionPoint = new Vector3D();
			_kernelOutputBuffer = new Vector.<Number>();
			_rayTriangleKernel = new Shader(new RayTriangleKernelClass() as ByteArray);
			_collisionUV = new Point();
			var vertices:Vector.<Number> = _object.geometry.getAttributeValues(VertexAttributes.POSITION);
			var vertexBufferDims:Point = evaluateArrayAsGrid(vertices);
			_rayTriangleKernel.data.vertexBuffer.width = vertexBufferDims.x;
			_rayTriangleKernel.data.vertexBuffer.height = vertexBufferDims.y;
			_rayTriangleKernel.data.vertexBufferWidth.value = [vertexBufferDims.x];
			_rayTriangleKernel.data.vertexBuffer.input = vertices;
			// send indices to pb
			indices = Vector.<Number>(_object.geometry.indices);
			var q:int = int(Math.sqrt(indices.length / 3));
			_indexBufferDims = evaluateArrayAsGrid(indices);
			_rayTriangleKernel.data.indexBuffer.width = _indexBufferDims.x;
			_rayTriangleKernel.data.indexBuffer.height = _indexBufferDims.y;
			_rayTriangleKernel.data.indexBuffer.input = indices;
			
			uvs = _object.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
		}
		
		private function executeKernel():void
		{
			// run kernel.
			var rayTriangleKernelJob:ShaderJob = new ShaderJob(_rayTriangleKernel, _kernelOutputBuffer, _indexBufferDims.x, _indexBufferDims.y);
			rayTriangleKernelJob.start(true);
			// find a proper collision from pb's output
			var i:uint;
			var t:Number;
			var collisionTriangleIndex:int = -1;
			var len:uint = _kernelOutputBuffer.length;
			var smallestNonNegativeT:Number = Number.MAX_VALUE;
			if (_breakOnFirstTriangleHit)
			{
				for (i = 0; i < len; i += 3)
				{
					t = _kernelOutputBuffer[i];
					if (t > 0 && t < smallestNonNegativeT)
					{
						smallestNonNegativeT = t;
						collisionTriangleIndex = i;
						break;
					}
				}
			}
			else
			{
				for (i = 0; i < len; i += 3)
				{
					t = _kernelOutputBuffer[i];
					if (t > 0 && t < smallestNonNegativeT)
					{
						smallestNonNegativeT = t;
						collisionTriangleIndex = i;
					}
				}
			}
			_t = smallestNonNegativeT;
			_collisionTriangleIndex = collisionTriangleIndex;
			_collisionExists = collisionTriangleIndex >= 0;
		}
		
		public function get collisionPoint():Vector3D
		{
			if (!_collisionExists)
				return null;
			_t = _kernelOutputBuffer[_collisionTriangleIndex];
			_collisionPoint = _rayDirection.clone();
			_collisionPoint.scaleBy(_t);
			return _collisionPoint.add(_rayPosition);
		}
		
		public function get collisionUV():Point
		{
			if (!_collisionExists)
				return null;
			var index:uint = _collisionTriangleIndex;
			var v:Number = _kernelOutputBuffer[index + 1]; // barycentric coord 1
			var w:Number = _kernelOutputBuffer[index + 2]; // barycentric coord 2
			var u:Number = 1.0 - v - w;
			var uvIndex:uint = indices[index] * 2;
			var uv0:Vector3D = new Vector3D(uvs[uvIndex], uvs[uvIndex + 1]);
			index++;
			uvIndex = indices[index] * 2;
			var uv1:Vector3D = new Vector3D(uvs[uvIndex], uvs[uvIndex + 1]);
			index++;
			uvIndex = indices[index] * 2;
			var uv2:Vector3D = new Vector3D(uvs[uvIndex], uvs[uvIndex + 1]);
			_collisionUV.x = u * uv0.x + v * uv1.x + w * uv2.x;
			_collisionUV.y = u * uv0.y + v * uv1.y + w * uv2.y;
			return _collisionUV;
		}
		
		public function ray(position:Vector3D, direction:Vector3D):void
		{
			direction = _object.globalToLocal(position.add(direction));
			position = _object.globalToLocal(position);
			direction = direction.subtract(position);
			_rayTriangleKernel.data.rayStartPoint.value = [position.x, position.y, position.z];
			_rayTriangleKernel.data.rayDirection.value = [direction.x, direction.y, direction.z];
			_rayPosition = position;
			_rayDirection = direction;
			
			executeKernel();
		}
		
		static private function evaluateArrayAsGrid(array:Vector.<Number>):Point
		{
			var count:uint = array.length / 3;
			var w:uint = int(Math.sqrt(count));
			var h:uint = w;
			var i:uint;
			while (w * h < count)
			{
				for (i = 0; i < w; ++i)
				{
					array.push(0.0, 0.0, 0.0);
				}
				h++;
			}
			return new Point(w, h);
		}
		
		public function set breakOnFirstTriangleHit(value:Boolean):void
		{
			_breakOnFirstTriangleHit = value;
		}
		
		public function get breakOnFirstTriangleHit():Boolean
		{
			return _breakOnFirstTriangleHit;
		}
		
		public function get collisionExists():Boolean
		{
			return _collisionExists;
		}
		
		public function get collisionT():Number
		{
			return _t;
		}
	}
}

