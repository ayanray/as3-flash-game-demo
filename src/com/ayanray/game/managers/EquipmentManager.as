package com.ayanray.game.managers
{
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoScene;
	
	import com.ayanray.game.entities.World;
	import com.ayanray.game.entities.equipment.Chair;

	/**
	 * The equipment manager creates and draws equipment objects into the scene.
	 * These equipment objects could be desks, plants, chairs, beds, or other similar objects. 
	 * @author Ayan Ray
	 * 
	 */
	public class EquipmentManager
	{
		/**
		 * Reference to World (aka owner) 
		 */		
		private var _owner:World;
		/**
		 * Reference to World Scene 
		 */		
		private var _scene:IsoScene;
		/**
		 * Array that keeps track of equipment. 
		 * TODO: This become a dictionary class so I can find all chairs, desks, etc. 
		 */		
		private var _equipment:Array = new Array(); // object, occupied
		/**
		 * Deprecate this and use dictionary for equipment. Create value object instead of bland object. 
		 */		
		private var _chairs:Array = new Array(); // object, patient
		
		// TODO: Move to Enum class?
		public static const DESK:String 		= "desk";
		public static const CHAIR:String 		= "chair";
		public static const BED:String 			= "bed";
		
// --------------------------------------------------------------------------------	
		public function EquipmentManager(scene:IsoScene, owner:World)
		{
			this._scene = scene;
			this._owner = owner;
		}

// --------------------------------------------------------------------------------	
		/**
		 * Creates an equipment object and places it in the scene. 
		 * @param type Type of equipment object.
		 * @param style Style of equipment object (currently unused).
		 * @param x Grid position X
		 * @param y Grid position Y
		 * @param walkable Can you walk through it?
		 * @return 
		 * 
		 */		
		public function addObject( type:String, style:int, x:int, y:int, walkable:Boolean = false ):Object
		{
			var object:*;
			if(type == DESK)
			{
				object = new IsoBox();
				object.setSize(World.CELL_SIZE * 2, World.CELL_SIZE, World.CELL_SIZE);
				
				// Can't walk through desks
				this._owner.buildingManager.pathGrid.setWalkable(x,y,false);
				this._owner.buildingManager.pathGrid.setWalkable(x+1,y,false);
			}
			else if(type == CHAIR)
			{
				object = new Chair();
				object.setSize(World.CELL_SIZE, World.CELL_SIZE, World.CELL_SIZE / 2);
				this._chairs.push(object);
			}
			else if(type == BED)
			{
				object = new IsoBox();
				object.setSize(World.CELL_SIZE, World.CELL_SIZE * 2, World.CELL_SIZE);
			}
			else
			{
				object = new IsoBox();
				object.setSize(World.CELL_SIZE, World.CELL_SIZE, World.CELL_SIZE);
			}
			
			// Set Position
			object.x = this._owner.getPosition(x);
			object.y = this._owner.getPosition(y);
			this._scene.addChild(object);
			
			// Add Reference
			this._equipment.push({object:object, occupied:false});
			
			// Return it in case they want it
			//TODO: Return an EquipmentObject ?
			return object;
		}
		
// --------------------------------------------------------------------------------	
// Getters and setters
		
		public function get equipment():Array { return this._equipment };
		public function get chairs():Array { return this._chairs };
		
	}
}