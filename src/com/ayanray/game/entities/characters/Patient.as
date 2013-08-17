package com.ayanray.game.entities.characters
{
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.graphics.SolidColorFill;
	
	import bit101.AStar;
	
	import com.ayanray.game.entities.World;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.junkbyte.console.ConsoleChannel;
	
	import flash.geom.Point;
	/**
	 * The Patient class represents a patient character within the game.
	 * This class manages their basic movement with pathfinding and contains
	 * properties used throughout the game (time value, cash, anger).
	 *  
	 * @author Ayan Ray
	 * 
	 */	
	public class Patient extends IsoBox
	{
		/**
		 * Unique ID for patient
		 * TODO: This is currently just randomized with the chance of being the same as another. Should be error checked. 
		 */		
		private var _uid:int;
		/**
		 * Reference to World (aka owner) 
		 */		
		private var _owner:World;
		/**
		 * Value for patient service 
		 */		
		private var _cashValue:int;
		/**
		 * Time it takes for the doctor to see patient 
		 */		
		private var _timeValue:int;
		/**
		 * How angry the patient is becoming for having to wait, etc. 
		 */
		private var _anger:int;
		/**
		 * Current status of the patient (are they in reception, etc?)
		 */		
		private var _status:String = RECEPTION;
		/**
		 * Callback for movement -- called when the patient reaches target grid point
		 */		
		private var _currentCallBack:Function;
		/**
		 * Debug channel
		 */
		private var _channel:ConsoleChannel = new ConsoleChannel('Patient');
		/**
		 * Walk speed from one square to another. I.e. 0.2 seconds to get from square A to neighbor square B
		 */		
		private var _walkSpeed:Number = 0.2; // 0.5
		
		// Statuses
		// TODO: Enum class? Eventually maybe...
		public static const RECEPTION:String = "reception";
		public static const WAITING:String = "waiting";
		public static const PATIENT_ROOM:String = "patientRoom";
		
// --------------------------------------------------------------------------------	
		
		public function Patient( owner:World, cash:int, time:int )
		{
			this._uid = Math.random() * 10000;
			this._owner = owner;
			this._cashValue = cash;
			this._timeValue = time;
			
			// FPO: Set Default Appearance
			super.setSize(World.CELL_SIZE,World.CELL_SIZE,World.CELL_SIZE);
			this.fills = [
				new SolidColorFill(0x0000ff, .5),
				new SolidColorFill(0x0000ff, .5),
				new SolidColorFill(0x0000ff, .5),
				new SolidColorFill(0x0000ff, .5),
				new SolidColorFill(0x0000ff, .5),
				new SolidColorFill(0x0000ff, .5)
			];
		}
// --------------------------------------------------------------------------------
		/**
		 * Wayfinding algorithm. Uses AStar to get from current spot to x,y 
		 * @param x End square X
		 * @param y End square Y
		 * @param callBack Function to call after reaching square
		 * @return Did we find a viable route to get there? If not, no movement will occur
		 * 
		 */		
		public function moveToSpot(x:int, y:int, callBack:Function):Boolean
		{
			// Set Callback
			this._currentCallBack = callBack == null? function():void{} : callBack;
			
			// Stop patient movement
			TweenLite.killTweensOf(this);
			
			// Get and Set End Nodes (where are we going)
			// TODO: This pathGrid needs to be copied or moved here so that two patients simultaneously don't interupt.
			var xpos:int = x;
			var ypos:int = y;
			this._owner.buildingManager.pathGrid.setEndNode(x, y);
			
			// Get and Set Start Node (where are we now)
			xpos = Math.floor(this.x / World.CELL_SIZE);
			ypos = Math.floor(this.y / World.CELL_SIZE);
			this._owner.buildingManager.pathGrid.setStartNode(xpos, ypos);
			
			// Set Old Position as Walkable
			this._owner.buildingManager.pathGrid.setWalkable(xpos,ypos, true);
			
			// Using AStar Pathfinding method
			var astar:AStar = new AStar();
			if( astar.findPath(this._owner.buildingManager.pathGrid) )//if there is a path between the two nodes...
			{
				// Save Path
				var path:Array = astar.path; 
				
				var delay:Number = 0;
				var interval:Number = _walkSpeed;
				var len:int = path.length;
				var targetX:int, targetY:int;
				
				// Create Animation from start point to end point using the returned path from AStar
				for (var i:int = 1; i < len; i++)
				{
					targetX = path[i].x * World.CELL_SIZE;
					targetY = path[i].y * World.CELL_SIZE;//for every spot on our waypoint, tween it through every point					
					if(i == (len-1))	
					{
						TweenLite.to( this, interval, {	
							ease:Linear.easeNone, 
							x: targetX, 
							y: targetY, 
							delay: delay, 
							overwrite: false, 
							onComplete: this._onPatientReachEndOfPath 
						} );
					}
					else 
					{
						TweenLite.to( this, interval, {
							ease:Linear.easeNone, 
							x: targetX, 
							y: targetY, 
							delay: delay, 
							overwrite: false 
						} );
					}
					delay += interval;
				}	
				
				return true;
			} 
			else 
			{
//				Cc.log("Patient:", "No path available at:", xpos, ypos);
				
				// Stay on spot
				this._owner.buildingManager.pathGrid.setWalkable(xpos,ypos, false);
				
				return false;
			}
		}
		/**
		 * Called by default when the patient reaches the end of the path 
		 * 
		 */		
		private function _onPatientReachEndOfPath():void
		{
			// Stop Walkable
			var xPos:int = Math.floor(this.x / World.CELL_SIZE);
			var yPos:int = Math.floor(this.y / World.CELL_SIZE);
			this._owner.buildingManager.pathGrid.setWalkable(xPos,yPos, false);
			
			this._currentCallBack();
		}
		
// --------------------------------------------------------------------------------
		/**
		 * Cleans up memory before being destroyed by patient manager 
		 */		
		public function dispose():void
		{
			// Set Walkable
			var xPos:int = Math.floor(this.x / World.CELL_SIZE);
			var yPos:int = Math.floor(this.y / World.CELL_SIZE);
			this._owner.buildingManager.pathGrid.setWalkable(xPos,yPos, true);
			
			_owner = null;
			_currentCallBack = null;
			_channel.clear();
		}

// --------------------------------------------------------------------------------
		public function get uid():int { return _uid; };
		public function get cashValue():int { return _cashValue; };
		public function get timeValue():int { return _timeValue; };
		public function get anger():int { return _anger; };
		public function get status():String { return _status; };
		public function set status(value:String):void
		{
			if(value == Patient.RECEPTION)
				_status = value;
			else if(value == Patient.WAITING)
				_status = value;
			else if(value == Patient.PATIENT_ROOM)
				_status = value;	
		}
		public function get gridPoint():Point { 
			return new Point(Math.floor(this.x / World.CELL_SIZE), Math.floor(this.y / World.CELL_SIZE));
		}
	}
}