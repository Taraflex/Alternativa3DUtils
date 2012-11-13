package qw.alternativa.utils
{
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.alternativa3d;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author QW01_01
	 */
	public final class MeshUtils
	{
		
		public static function combine(meshes:Vector.<Mesh>, material:Material = null):Mesh
		{
			var res:Mesh;
			
			var indices:Vector.<uint> = new Vector.<uint>();
			var vert:Vector.<Number> = new Vector.<Number>();
			var norm:Vector.<Number> = new Vector.<Number>();
			var tex:Vector.<Number> = new Vector.<Number>();
			
			var i:int, il:uint, nil:uint, vec:Vector3D,vecn:Vector3D, transf:Matrix3D,vt:Vector.<Number>, v:Vector.<Number>,vn:Vector.<Number>,tempind:Vector.<uint>;
			
			for each (res in meshes)
			{		
				v = res.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
				il = v.length;
				for (i = 0; i < il; i += 2)
				{
					tex.push(v[i], v[i + 1]);
				}
				
				v = res.geometry.getAttributeValues(VertexAttributes.POSITION);
				vn = res.geometry.getAttributeValues(VertexAttributes.NORMAL);
				il = v.length;
				for (i = 0; i < il; i += 3)
				{
					vec = new Vector3D(v[i], v[i + 1], v[i + 2]);
					vecn = new Vector3D(vn[i], vn[i + 1], vn[i + 2]);
					vecn.incrementBy(vec);
					
					vec = res.localToGlobal(vec);
					vecn = res.localToGlobal(vecn);
					
					vert.push(vec.x, vec.y, vec.z);
										
					vecn.decrementBy(vec);
					vecn.normalize();
					
					norm.push(vecn.x, vecn.y, vecn.z);
				}
				
				tempind = res.geometry.indices;
				il = tempind.length;
				for (i = 0; i < il; i++)
				{
					indices.push(nil + tempind[i])
				}
				nil += v.length / 3;
				
			}
			
			res = new Mesh();
			
			var geometry:Geometry = new Geometry(vert.length / 3);
			geometry._indices = indices;
			var attributes:Array = [];
			attributes[0] = VertexAttributes.POSITION;
			attributes[1] = VertexAttributes.POSITION;
			attributes[2] = VertexAttributes.POSITION;
			attributes[3] = VertexAttributes.TEXCOORDS[0];
			attributes[4] = VertexAttributes.TEXCOORDS[0];
			attributes[5] = VertexAttributes.NORMAL;
			attributes[6] = VertexAttributes.NORMAL;
			attributes[7] = VertexAttributes.NORMAL;
			attributes[8] = VertexAttributes.TANGENT4;
			attributes[9] = VertexAttributes.TANGENT4;
			attributes[10] = VertexAttributes.TANGENT4;
			attributes[11] = VertexAttributes.TANGENT4;
			
			geometry.addVertexStream(attributes);
			geometry.setAttributeValues(VertexAttributes.POSITION, vert);
			geometry.setAttributeValues(VertexAttributes.NORMAL, norm);
			geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], tex);
			geometry.calculateTangents(0);
			
			res.geometry = geometry;
			res.addSurface(material, 0, indices.length / 3);
			res.calculateBoundBox();
			
			return res;
		}
	}

}