package com.ayanray.game.entities
{
	import as3isolib.display.IsoView;
	import as3isolib.display.scene.IsoScene;
	
	import com.ayanray.game.entities.characters.Patient;
	import com.ayanray.game.managers.BuildingManager;
	import com.ayanray.game.managers.EmployeeManager;
	import com.ayanray.game.managers.EquipmentManager;
	import com.ayanray.game.managers.PatientManager;
	import com.junkbyte.console.Cc;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * Represents the entire world for the game. 
	 * This includes the managers, scene, viewport, and rendering.
	 * 
	 * TODO: Is it possible to have multiple worlds on the same screen?
	 * 
	 * @author Ayan Ray
	 * 
	 */	
	public class World extends Sprite
	{
		/**
		 * Size of each grid 'square' 
		 */	
		public static const CELL_SIZE:int = 20;
		/**
		 * AS3Iso Scene 
		 */		
		private var _scene:IsoScene;
		/**
		 * AS3Iso Viewport 
		 */		
		private var _viewport:IsoView;
		
		////////////////////////////////////////
		// Managers
		private var _buildingManager:BuildingManager;
		private var _patientManager:PatientManager;
		private var _employeeManager:EmployeeManager;
		private var _equipmentManager:EquipmentManager;
		
		// Panning with Mouse
		protected var isPanning:Boolean = false;
		protected var lastX:int = 0;
		protected var lastY:int = 0;
		
		/**
		 * World cash (based on patients seen) 
		 */		
		public var cash:int = 0;
		/**
		 * Set to publish for the demo
		 * TODO: Use an update loop instead. 
		 */		
		public var createPatientTimer:Timer;
		
// --------------------------------------------------------------------------------		
		public function World(stage:Stage)
		{
			this.addEventListener( Event.ADDED_TO_STAGE, _onAddedToStage );
			// Create Scene
			this._scene = new IsoScene();
						
			// Create Managers
			this._buildingManager 	= new BuildingManager(	this._scene, 	this);			
			this._patientManager 	= new PatientManager(	this._scene, 	this);
			this._employeeManager 	= new EmployeeManager(	this._scene, 	this);
			this._equipmentManager 	= new EquipmentManager(	this._scene, 	this);
			 
			////////////////////////////////////////
			// Create Map
			this._buildingManager.buildMap();
			
			// Create a timer that creates patients at a specified rate (which should increase over time)
			this.createPatientTimer = new Timer(60*1000 / 20, 1);
			this.createPatientTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this._createPatient);
			
			// Create AS3ISO View
			this._viewport = new IsoView();
			this._viewport.clipContent = false;
			this._viewport.showBorder = false;
			this._viewport.y = 50;
			this._viewport.setSize(150, 100);
			this._viewport.addScene(this._scene); //look in the future to be able to add more scenes
			this.addChild(_viewport);
			
			// Equipment
			this._equipmentManager.addObject(EquipmentManager.DESK,		1,15,1); 
			this._equipmentManager.addObject(EquipmentManager.CHAIR,	1,15,15);
			this._equipmentManager.addObject(EquipmentManager.CHAIR,	1,13,15);
			this._equipmentManager.addObject(EquipmentManager.CHAIR,	1,11,15);
			this._equipmentManager.addObject(EquipmentManager.BED,		1,2,0); 
			this._equipmentManager.addObject(EquipmentManager.BED,		1,3,13); 
			
			// Employees: Doctors
			this._employeeManager.addEmployee(EmployeeManager.DOCTOR, 	100, 2, 3);
			this._employeeManager.addEmployee(EmployeeManager.DOCTOR, 	100, 3, 11);
			
			// Employees: Others
			this._employeeManager.addEmployee(EmployeeManager.RECEPTIONIST, 100, 15, 0);
			
			// Start Game ? 
			// TODO: For now, start game... need to tell demo when it's ready and then show world when appropriate
			this.startGame();
		}
		
// --------------------------------------------------------------------------------	
		public function _onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			// Set default position (center)
			this._viewport.pan(-this.stage.stageWidth/3, -this.stage.stageHeight/8);
		}

// --------------------------------------------------------------------------------
		/**
		 * Main function to start the game (as in it becomes visible to user) 
		 * 
		 */		
		public function startGame():void
		{
			this.createPatientTimer.start();
			
			// Panning
			this.addEventListener(MouseEvent.MOUSE_DOWN, 	this.onWorldMouseDown);
			this.addEventListener(MouseEvent.MOUSE_MOVE, 	this.onWorldMouseMove);
			this.addEventListener(MouseEvent.MOUSE_UP, 		this.onWorldMouseUp);
		}
// --------------------------------------------------------------------------------
		/**
		 * Create Patient -- main function that creates patients that enter the world 
		 * @param event 
		 * 
		 */		
		private function _createPatient(event:TimerEvent = null):void
		{
			// Restart Timer
			this.createPatientTimer.reset();
			this.createPatientTimer.start();
			
			// TODO: Logic does not exist in move to reception queue if line is full, so let's not make any more patients until it exists.
			if(this._buildingManager.getReceptionRoom(0).isLineFull(0)) 
			{
				Cc.log("World:", "Reception line is full. Total Patients:", _patientManager.patients.length); 
				return;
			}
			
			// Random for now
			var time:int = Math.max( Math.random()*10000, 1000); // min 1 second
			var cash:int = Math.max(time/10000*100,10);
			var patient:Patient = this._patientManager.createPatient( cash, time );	
			
			// Move Patient to Reception
			this._patientManager.movePatientToRoom(patient, this._buildingManager.getReceptionRoom(0));
		}		
		
		public function _removePatient(patient:Patient):void
		{
			var returnObj:Object = _patientManager.removePatient(patient);
			cash += returnObj.cash;
			
			Cc.log("World:", "Removed patient. Cash increased by:", returnObj.cash);
		}
		
// --------------------------------------------------------------------------------	
// Render Cycle
		
		public function update():void
		{
			_buildingManager.update();
		}
		
		public function render():void
		{
			_scene.render();
		}
		
// --------------------------------------------------------------------------------	
// Unload
		
		public function unload():void
		{
			
		}
		
// --------------------------------------------------------------------------------	
// Panning
		
		private function onWorldMouseDown(event:MouseEvent):void
		{
			isPanning = true;
			lastX = stage.mouseX;
			lastY = stage.mouseY;
		}
		private function onWorldMouseMove(event:MouseEvent):void
		{
			if (isPanning) 
			{
				_viewport.pan(lastX - stage.mouseX, lastY - stage.mouseY);
				lastX = stage.mouseX;
				lastY = stage.mouseY;
			}	
		}
		private function onWorldMouseUp(event:MouseEvent):void
		{
			isPanning = false;
		}
		
// --------------------------------------------------------------------------------		
// Helpful World Calculations (transformations, etc)
// TODO: Helper class? Global?
		
		/**
		 *  A function the returns the pixel position of a specific grid point.
		 * @param value	Grid Number (0,0 is top most grid point on visible grid)
		 * @return Returns a value in pixels of what that grid point represents (based on current Cell size). 
		 * This is a function as it could change in the future.
		 * 
		 */		
		public function getPosition( value:int ):int
		{
			return CELL_SIZE * value;
		}	
		
// --------------------------------------------------------------------------------	
// Getters and Setters
		
		public function get scene():IsoScene { return _scene; }
		public function get buildingManager():BuildingManager { return _buildingManager; }
		public function get characterManager():PatientManager { return _patientManager; }
		public function get employeeManager():EmployeeManager { return _employeeManager; }
		public function get equipmentManager():EquipmentManager { return _equipmentManager; }
		public function get patientManager():PatientManager { return _patientManager; }
		
	}
}