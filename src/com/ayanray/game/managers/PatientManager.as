package com.ayanray.game.managers
{
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoScene;
	
	import com.ayanray.game.entities.World;
	import com.ayanray.game.entities.characters.Patient;
	import com.ayanray.game.entities.rooms.Room;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.ConsoleChannel;
 
	/**
	 * The Patient Manager manages creating patients, moving them through the world, and then out.
	 * It also manages their happiness, cash, and other incentives that come with patients.
	 * @author Ayan Ray
	 * 
	 */	
	public class PatientManager
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
		 * Array of patients current in world
		 * TODO: Change to dictionary ordered by type or location (recep, waiting, room)
		 * TODO: Value objects for patient 
		 */		
		public var _patients:Array = new Array(); // {patient, cash, time, anger}

// --------------------------------------------------------------------------------
		public function PatientManager(scene:IsoScene, owner:World)
		{
			this._scene = scene;
			this._owner = owner;
		}
		
// --------------------------------------------------------------------------------
		/**
		 * Creates a patient and places them  
		 * @param cash Value patient provides if seen
		 * @param time Time they will wait to be seen (if reaches 0, they leave)
		 * @return Returns created patient (currently an IsoBox but should be PatientVO)
		 * 
		 */		
		public function createPatient( cash:int, time:int ):Patient
		{
			var patient:Patient = new Patient(this._owner, cash, time); 
			patient.x = this._owner.getPosition(this._owner.buildingManager.spawnLocation.x);
			patient.y = this._owner.getPosition(this._owner.buildingManager.spawnLocation.y);
			patients.push(patient);
			this._scene.addChild(patient);
			
			var ch:ConsoleChannel = new ConsoleChannel('Patient Manager');
			ch.info("Created patient(", patient.uid + ", $" + cash, ", " + time/1000 + "s ).", "Total Patients:", this._patients.length);
			
			return patient;
		}
		/**
		 * Removes character from world 
		 * @param patient
		 * @return Returns an end patient value object (which should be a VO) of it's cash and added exp
		 * 
		 */		
		public function removePatient( patient:Patient ):Object // experience, cash
		{
			var id:int = 0;
			for(var i:int = 0; i < patients.length; i++)
			{
				if(patients[i] == patient)
				{
					id = i;
					break;
				}
			}
			
			// Save Return Vars
			var obj:Object = {};
			obj.cash = patient.cashValue;
			obj.experience = 10 - patient.anger;
			
			// Remove References
			this.patients.splice(id,1);
			this._scene.removeChild(patient);
			patient.dispose();
			
			_owner.cash += patient.cashValue;
			return obj;
		}
		
// --------------------------------------------------------------------------------		
		public function movePatientToRoom( patient:Patient, room:Room ):Boolean
		{
			// Simple one liner for now, accept the patient into the room
			return room.acceptPatient( patient );
		}
		
// --------------------------------------------------------------------------------
// Getters and setters
		
		public function get patients():Array { return _patients; };
	}
}