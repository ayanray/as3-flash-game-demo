package com.ayanray.game.entities.rooms
{
	import as3isolib.display.primitive.IsoRectangle;
	import as3isolib.enum.IsoOrientation;
	import as3isolib.graphics.BitmapFill;
	
	import com.ayanray.game.entities.World;
	import com.ayanray.game.entities.characters.Patient;
	import com.ayanray.game.managers.BuildingManager;
	
	import flash.geom.Rectangle;
	/**
	 * Main base class for all rooms. Provides basic functionality for drawing and storing owner info.
	 *  
	 * @author Ayan Ray
	 * 
	 */	
	public class Room
	{
		// Assets
		// TODO: Resource Bundle this stuff
		[Embed(source="./assets/tiles/floor.jpg")]
		private var FloorTile:Class;
		
		/**
		 * Reference to Building Manager (aka owner) 
		 */		
		protected var _owner:BuildingManager;
		
// --------------------------------------------------------------------------------
		public function Room(owner:BuildingManager, area:Array)
		{
			this._owner = owner;
			
			// Draw Area
			var i:int, len:int;
			var rect:Rectangle;
			len = area.length;
			for(i = 0; i < len; i++)
			{
				rect = area[i] as Rectangle;
				this._drawArea(rect.x, rect.y, rect.width, rect.height);
			}
			
			// Draw Walls
			// TODO: Currently, it's a little complicated to draw walls of rooms without knowing in advance where 
			// the next room is. For now, the Draw Walls function will exist only in the building manager.
		}
		
// --------------------------------------------------------------------------------
		/**
		 * Function determines whether or not the room will accept the patient.  
		 * @param patient
		 * @return True if accepted, false if they can't enter room
		 * 
		 */		
		public function acceptPatient( patient:Patient ):Boolean
		{
			return false;
		}
		
// --------------------------------------------------------------------------------	
// Drawing Functions
		
		/**
		 * Draws the floor tiles for a specified area.
		 *  
		 * @param startX Start grid number (not measured in pixels)
		 * @param countX Number of grid squares to draw (along X axis).
		 * @param startY Start grid number (not measured in pixels)
		 * @param countY Number of grid squares to draw (along Y axis)
		 * 
		 */		
		protected function _drawArea(startX:int, countX:int, startY:int, countY:int):void
		{
			var i:int, j:int;
			var tile:IsoRectangle;
			var bf:BitmapFill;
			
			for(i = startX; i < startX+countX; i++)
			{
				for(j = startY; j < startY+countY; j++)
				{
					tile = new IsoRectangle();
					tile.setSize(World.CELL_SIZE,World.CELL_SIZE,0); 
					bf = new BitmapFill(new FloorTile(), IsoOrientation.XY); 
					tile.fills = [bf];
					tile.moveTo(i * World.CELL_SIZE, j * World.CELL_SIZE, 0);//places the box
					
					this._owner.owner.scene.addChild(tile);
					this._owner.pathGrid.setWalkable(i, j, true);
				}
			}
		}
	}
}