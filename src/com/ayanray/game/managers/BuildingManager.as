package com.ayanray.game.managers
{
	import as3isolib.display.primitive.IsoRectangle;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.enum.IsoOrientation;
	import as3isolib.graphics.BitmapFill;
	
	import bit101.Grid;
	import bit101.Node;
	
	import com.ayanray.game.entities.World;
	import com.ayanray.game.entities.rooms.Hallway;
	import com.ayanray.game.entities.rooms.PatientRoom;
	import com.ayanray.game.entities.rooms.ReceptionRoom;
	import com.ayanray.game.entities.rooms.WaitingRoom;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * The BuildingManager is responsible for creating, drawing, and managing the building itself.
	 * This consists of the walls, floors, roofs, and outdoor ground. 
	 * @author Ayan Ray
	 */
	public class BuildingManager
	{
		// Assets
		// TODO: Resource Bundle this stuff
		[Embed(source="./assets/tiles/wall.jpg")]
		private var WallTile:Class;
		
		/**
		 * Reference to World (aka owner) 
		 */		
		private var _owner:World;
		/**
		 * Reference to World Scene 
		 */		
		private var _scene:IsoScene;
		/**
		 * A Grid of the world size (which is used for pathfinding) 
		 */		
		private var _pathGrid:Grid;
		/**
		 * Location at which new patients enter the building. 
		 */		
		private var _spawnLocation:Point;
		/**
		 * Location at which new patients enter the building. 
		 */		
		private var _exitLocation:Point;
		/**
		 * Location at which patients will talk to reception. 
		 * TODO: Ideally, this needs to be scaleable -- so that there can be unlimited reception desks and reception spots. 
		 */		
		private var _atReceptionLocation:Point;
		
		private var _patientRooms:Array = new Array();
		private var _waitingRooms:Array = new Array();
		private var _receptionRooms:Array = new Array();
		
// --------------------------------------------------------------------------------	
		public function BuildingManager(scene:IsoScene, owner:World)
		{
			this._scene = scene;
			this._owner = owner;
		}
		
// --------------------------------------------------------------------------------	
// Building World Functions
		
		/**
		 * This function is responsible for building the map from User data.
		 * For this demo, we will create a static design until this can be offloaded.
		 */
		public function buildMap():void
		{
			///////////////////////////////////////
			// Create Dummy Map
			
			// Create World Size
			this._pathGrid = new Grid(26, 16); // Floor Grid (x, y) -- so 26 wide, 16 long
			for(var i:int = 0; i < this._pathGrid.numCols; i++)
				for(var j:int = 0; j < this._pathGrid.numRows; j++) this._pathGrid.setWalkable(i, j, false);
			
			// Create Rooms
			this._createReceptionRooms();
			this._createWaitingRooms();
			this._createPatientRooms();
			
			// Create Spawn/End Location
			this._spawnLocation = new Point(25, 3);
			this._exitLocation = new Point(0, 7);
			
			// Create Reception Location
			this._atReceptionLocation = new Point(15, 2);
			
			// Draw Walls (quick func that handles much of the wall drawing around rooms)
			this._drawWalls();
			
			// Set custom unwalkables
			this._setCustomUnwalkables();
			
			// FPO: Create Flat Grid (could be replaced with grass or whatever)
			var grid:IsoGrid = new IsoGrid();
			grid.showOrigin = false;
			grid.cellSize = 20;
			grid.setGridSize(26,16)
			this._scene.addChild(grid);
		}
		
		private function _createReceptionRooms():void
		{
			// Create Dummy Reception Line
			var receptionLineSpots:Array = new Array();
			receptionLineSpots.push({x:15, y: 3});
			receptionLineSpots.push({x:16, y: 3});
			receptionLineSpots.push({x:17, y: 3});
			receptionLineSpots.push({x:18, y: 3});
			receptionLineSpots.push({x:19, y: 3});
			
			// Create Dummy Reception Room
			var receptionRoom:ReceptionRoom = new ReceptionRoom(this, new Array( 
				new Rectangle(13, 12, 0, 6), // 12x6 room
				new Rectangle(25, 1, 2, 2) // 1x2 entrance
			), receptionLineSpots);
			
			this._receptionRooms.push(receptionRoom);
		}
		
		private function _createWaitingRooms():void
		{
			// Create Dummy Waiting Room
			var waitingRoom:WaitingRoom = new WaitingRoom(this, new Array( 
				new Rectangle(11, 6, 6, 10) // 6x10 room
			));
			
			this._waitingRooms.push(waitingRoom);
		}
		
		private function _createPatientRooms():void
		{
			////////////////////////////////////////
			// Create Dummy Patient Roofs
			
			var patientRoomRoofs:Array = [new Array(), new Array()]; // Create container for the two rooms
			var i:int, j:int;
			var roofTile:IsoRectangle;
			var bf:BitmapFill;
			
			// room is 3x6 starting at 2,0
			for(i = 2; i < 5; i++)
			{
				for(j = 0; j < 6; j++)//go through each column, and then each row
				{
					roofTile = new IsoRectangle();
					roofTile.setSize(World.CELL_SIZE,World.CELL_SIZE,0); 
					bf = new BitmapFill(new WallTile(), IsoOrientation.XY); 
					roofTile.fills = [bf];
					roofTile.moveTo(i * World.CELL_SIZE, j * World.CELL_SIZE, World.CELL_SIZE);//places the box
					patientRoomRoofs[0].push(roofTile);
				}
			}
			
			// room is 3x6 starting at 3,9
			for(i = 3; i < 6; i++)
			{
				for(j = 9; j < 15; j++)//go through each column, and then each row
				{
					roofTile = new IsoRectangle();
					roofTile.setSize(World.CELL_SIZE,World.CELL_SIZE,0); 
					bf = new BitmapFill(new WallTile(), IsoOrientation.XY); 
					roofTile.fills = [bf];
					roofTile.moveTo(i * World.CELL_SIZE, j * World.CELL_SIZE, World.CELL_SIZE);//places the box
					patientRoomRoofs[1].push(roofTile);
				}
			}
			
			// Create Dummy Patient Rooms
			var patientRoom1:PatientRoom = new PatientRoom(this, new Array( 
				new Rectangle(2, 3, 0, 6) // 3x6 room
			), new Point(3, 1), patientRoomRoofs[0] );
			var patientRoom2:PatientRoom = new PatientRoom(this, new Array( 
				new Rectangle(3, 3, 9, 6) // 3x6 room
			), new Point(4, 12), patientRoomRoofs[1]);
			
			var hallway:Hallway = new Hallway(this, new Array(
				new Rectangle(0, 11, 6, 3) // 11x3 hallway
			));
			
			////////////////////////////////////////
			// Create Patient Room Walls for Doorway
			
			// Room 1
			this._drawWall(2, 5, "BL");
			this._drawWall(4, 5, "BL");
			
			// Room 2
			this._drawWall(3, 9, "TR");
			this._drawWall(5, 9, "TR");
			
			this._patientRooms.push(patientRoom1);
			this._patientRooms.push(patientRoom2);
		}

// --------------------------------------------------------------------------------	
// Drawing Functions
		
		/**
		 * Function that draws walls on a grid point. 
		 * @param x Grid point X
		 * @param y Grid point Y
		 * @param orientation Wall orientation based on position in a square. 
		 * Options: BR (bottom right), BL (bottom left), TR (top right), TL (top left)
		 *  
		 */		
		protected function _drawWall(x:int, y:int, orientation:String):void
		{
			var tile:IsoRectangle = new IsoRectangle();
			var bf : BitmapFill = new BitmapFill(new WallTile(), IsoOrientation.XY); 
			tile.fills = [bf];
			this._scene.addChild(tile);
			
			// TODO: ENUM Class needed?
			if(orientation == "BR") // Bottom Right
			{
				tile.setSize(0,World.CELL_SIZE,World.CELL_SIZE); 
				tile.moveTo((x+1) * World.CELL_SIZE, y * World.CELL_SIZE, 0);
			}
			else if (orientation == "BL")
			{
				tile.setSize(World.CELL_SIZE,0,World.CELL_SIZE); 
				tile.moveTo(x * World.CELL_SIZE, (y+1) * World.CELL_SIZE, 0);
			}
			else if (orientation == "TR")
			{
				tile.setSize(World.CELL_SIZE,0,World.CELL_SIZE); 
				tile.moveTo(x * World.CELL_SIZE, y * World.CELL_SIZE, 0);
			}
			else if (orientation == "TL")
			{
				tile.setSize(0,World.CELL_SIZE,World.CELL_SIZE); 
				tile.moveTo(x * World.CELL_SIZE, y * World.CELL_SIZE, 0);
			}
		}
		/**
		 * This function draws walls around all floor tiles (simpler than having to draw walls yourself). 
		 */		
		protected function _drawWalls():void
		{
			var i:int, j:int;
			var node:Node;
			var drawBottomLeft:Boolean, drawBottomRight:Boolean, drawTopLeft:Boolean, drawTopRight:Boolean;
			
			for(i = 0; i < this._pathGrid.numCols; i++)
			{
				for(j = 0; j < this._pathGrid.numRows; j++)//go through each column, and then each row
				{
					// reset
					node = this._pathGrid.getNode(i, j);//grab the current node (a.k.a. square) of the grid
					drawBottomLeft = drawBottomRight = drawTopLeft = drawTopRight = false;
					
					// 
					if(i == 0 && node.walkable) drawTopLeft = true;
					if(j == 0 && node.walkable) drawTopRight = true;
					
					if(!node.walkable)
					{
						if(i+1 < this._pathGrid.numCols)
						{
							node = this._pathGrid.getNode(i+1, j);
							if(node.walkable) drawBottomRight = true;
						} 
						
						if(j+1 < this._pathGrid.numRows)
						{
							node = this._pathGrid.getNode(i, j+1);
							if(node.walkable) drawBottomLeft = true;
						} 
						
						if(!drawBottomLeft && !drawBottomRight) continue;
						
					}
					else
					{
						if(i+1 < this._pathGrid.numCols)
						{
							node = this._pathGrid.getNode(i+1, j);
							if(!node.walkable) drawBottomRight = true;
						}
						else drawBottomRight = true;
						
						if(j+1 < this._pathGrid.numRows)
						{
							node = this._pathGrid.getNode(i, j+1);
							if(!node.walkable) drawBottomLeft = true;
						}
						else drawBottomLeft = true;
					}
					
					if(drawBottomRight) this._drawWall(i, j, "BR");
					if(drawBottomLeft) this._drawWall(i, j, "BL");
					if(drawTopRight) this._drawWall(i, j, "TR");
					if(drawTopLeft) this._drawWall(i, j, "TL");
				}
			}
		}
		
// --------------------------------------------------------------------------------		
		/**
		 * Required to run AFTER drawing walls. Draw walls uses walkable as the variable to 
		 * determine whether or not to draw a wall. After creating walls, you might want to 
		 * set certain spaces (i.e. desks and other floor vars like near entrances) to 
		 * control the flow of characters. This should be calculated dynamically and transparent
		 * to the user but stored in DB or calculated on demand but only once.  
		 * 
		 */		
		private function _setCustomUnwalkables():void
		{
			////////////////////////////////////////
			// Override Walkable Area (so that patients can't walk on beds and 
			// points to the left and right of patient as they enter room)
			
			// Room 1
			this._pathGrid.setWalkable(2, 5, false);
			this._pathGrid.setWalkable(2, 6, false);
			this._pathGrid.setWalkable(4, 5, false);
			this._pathGrid.setWalkable(4, 6, false);
			
			// Room 2
			this._pathGrid.setWalkable(3, 8, false);
			this._pathGrid.setWalkable(3, 9, false);
			this._pathGrid.setWalkable(5, 8, false);
			this._pathGrid.setWalkable(5, 9, false);
		}
		
// --------------------------------------------------------------------------------	
		public function getReceptionRoom( id:int ):ReceptionRoom
		{
			return this._receptionRooms[id];
		}
		public function getWaitingRoom( id:int ):WaitingRoom
		{
			return this._waitingRooms[id];
		}
		public function getPatientRoom( id:int ):ReceptionRoom
		{
			return this._patientRooms[id];
		}
		public function getAvailablePatientRoom():PatientRoom
		{
			var i:int, len:int;
			var patientRoom:PatientRoom;
			len = _patientRooms.length;
			for( i = 0; i < len; i++)
			{
				patientRoom = _patientRooms[i] as PatientRoom;
				if(patientRoom.isOpen()) return patientRoom;
			}
			return null;
		}
// --------------------------------------------------------------------------------	
		public function update():void
		{
			var i:int, j:int, len:int;
			var waitingRoom:WaitingRoom;
			len = _waitingRooms.length;
			for( i = 0; i < len; i++)
			{
				waitingRoom = _waitingRooms[i];
				waitingRoom.update();
			}	
			
			len = _receptionRooms.length;
			for( i = 0; i < len; i++)
			{
				ReceptionRoom(_receptionRooms[i]).update();
			}
		}
// --------------------------------------------------------------------------------
		public function get owner():World { return this._owner };
		public function get pathGrid():Grid { return this._pathGrid };
		public function get spawnLocation():Point { return this._spawnLocation };
		public function get exitLocation():Point { return this._exitLocation };
		public function get atReceptionLocation():Point { return this._atReceptionLocation };
	}
}