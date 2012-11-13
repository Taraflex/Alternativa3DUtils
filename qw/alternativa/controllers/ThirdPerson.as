package qw.alternativa.controllers
{
	import alternativa.engine3d.collisions.EllipsoidCollider;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.Box;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import com.greensock.TweenNano;
	import alternativa.engine3d.alternativa3d;
	
	/**
	 * ...
	 * @author QW01_01
	 */
	public class ThirdPerson
	{
		private var _ellipsoidCollider:EllipsoidCollider;
		private var _boxcontroller:Object3D = new Box(100,100,100,1,1,1,false,new FillMaterial(0xFF00FF,0.5))//new Object3D;
		private var _camera:Camera3D;
		private var _hero:Object3D;
		private var _position:Vector3D;
		private var _oldCameraPosition:Vector3D;
		private var _nowCameraPosition:Vector3D;
		private var _barrier:Object3D;
		private var _stage:Stage;
		private var rotX:Number = 0;
		private var rotY:Number = 0;
		private var target:Point;
		private var nullVector:Vector3D = new Vector3D();
		private var _speed:Number = 1 / 200;
		
		public var delta:Number = 30;
		public var duration:Number = 2;
		
		public function ThirdPerson(camera:Camera3D, hero:Object3D, barrier:Object3D, stage:Stage, position:Vector3D, colliderVector:Vector3D, lookPosition:Vector3D)
		{
			_camera = camera;
			_hero = hero;
			_barrier = barrier;
			_stage = stage;
			_position = position;
			_hero.addChild(_boxcontroller);
			setVector(_boxcontroller, lookPosition);
			_ellipsoidCollider = new EllipsoidCollider(colliderVector.x, colliderVector.y, colliderVector.z);
			_nowCameraPosition = _camera.parent.globalToLocal(_hero.localToGlobal(_position));
			_oldCameraPosition = setVector(camera, _nowCameraPosition);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onPress);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		public function set speed(v:Number):void {
			_speed = 1 / v;
		}
		
		private var tempVector:Vector3D = new Vector3D;
		
		public function update():void
		{
			if (target != null)
			{
				_boxcontroller.rotationZ = (target.x - _stage.mouseX) * _speed + rotX;
				_boxcontroller.rotationY = (target.y - _stage.mouseY) * _speed + rotY;
			}
			_nowCameraPosition = _camera.parent.globalToLocal(_boxcontroller.localToGlobal(_position));
			tempVector = _nowCameraPosition.subtract(_oldCameraPosition);
			if (tempVector.length > delta)
			{
				_oldCameraPosition = setVector(_camera, _ellipsoidCollider.calculateDestination(_oldCameraPosition, tempVector, _barrier));
			}
		}
		
		private function look():void
		{
			tempVector = _camera.parent.globalToLocal(_boxcontroller.localToGlobal(nullVector));
			_camera.lookAt(tempVector.x, tempVector.y, tempVector.z);
		}
		
		private function onPress(e:MouseEvent):void
		{
			target = new Point(e.localX, e.localY);
		}
		
		private function onUp(e:MouseEvent):void
		{
			target = null;
			rotX = _boxcontroller.rotationZ;
			rotY = _boxcontroller.rotationY;
		}
		
		private function setVector(a:Object3D, b:Vector3D):Vector3D
		{
			TweenNano.to(a, duration, {x: b.x, y: b.y, z: b.z, onUpdate: look});
			return b;
		}
		
		private var m:Matrix3D = new Matrix3D;
	}

}