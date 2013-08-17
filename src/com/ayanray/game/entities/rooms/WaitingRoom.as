package com.ayanray.game.entities.rooms
{
	import com.ayanray.game.entities.World;
	import com.ayanray.game.entities.characters.Patient;
	import com.ayanray.game.entities.equipment.Chair;
	import com.ayanray.game.managers.BuildingManager;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.ConsoleChannel;

	/**
	 * Manager and drawer for waiting room. 
	 * @author Ayan Ray
	 * 
	 */	
	public class WaitingRoom extends Room
	{
		/**
		 * Array of patients who are sitting in the waiting room 
		 */		
		private var _patientsInWaitingRoom:Array = new Array();
		/**
		 * Debug Console 
		 */		
		private var _channel:ConsoleChannel = new ConsoleChannel('Waiting Room');
		
// --------------------------------------------------------------------------------
		public function WaitingRoom(owner:BuildingManager, area:Array)
		{
			super(owner, area);
		}
		
// --------------------------------------------------------------------------------		
		override public function acceptPatient(patient:Patient):Boolean
		{
			// Temporarily set area to be unwalkable to control the movement of the patient 
			// to simulate a guided rope
			// FPO: Find a way to incorporate this into the passthrough on instantiation
			this._owner.pathGrid.setWalkable(15, 3, false);
			this._owner.pathGrid.setWalkable(14, 3, false);
			this._owner.pathGrid.setWalkable(16, 3, false);
			this._owner.pathGrid.setWalkable(17, 3, false);
			
			var i:int, x:int, y:int;
			var chair:Chair;
			var len:int = this._owner.owner.equipmentManager.chairs.length;
			for(i = 0; i < len; i++)
			{
				// If the chair is empty
				chair = this._owner.owner.equipmentManager.chairs[i];
				if(chair.patient == null)
				{
					chair.patient = patient;
					x = Math.floor(chair.x / World.CELL_SIZE);
					y = Math.floor(chair.y / World.CELL_SIZE);
					break;
				}
			}
			
			var pathFound:Boolean = patient.moveToSpot(x, y, this.update);
			if(pathFound) 
			{
				_channel.log("Patient", patient.uid, "has been accepted.");
				this._patientsInWaitingRoom.push(patient);
				patient.status = Patient.WAITING;
			}
			
			// FPO: Find a way to incorporate this into the passthrough on instantiation
			// Set walkable again (now that AStar has completed)
			this._owner.pathGrid.setWalkable(17, 3, true);
			this._owner.pathGrid.setWalkable(16, 3, true);
			this._owner.pathGrid.setWalkable(15, 3, true);
			this._owner.pathGrid.setWalkable(14, 3, true);
			
			return pathFound;
		}
		
// --------------------------------------------------------------------------------	
		/**
		 * Main update loop for the waiting room 
		 * (will immediatel move patients to patient rooms as availability increases) 
		 * 
		 */		
		public function update():void
		{
			if(this._patientsInWaitingRoom.length == 0) return;
			
			var i:int,len:int;
			var patientRoom:PatientRoom;
			var patient:Patient;
			
			patientRoom = this._owner.getAvailablePatientRoom();
			if(patientRoom == null) return;
			
			len = this._patientsInWaitingRoom.length;
			for( i = 0; i < len; i++)
			{
				patient = this._patientsInWaitingRoom[i];
				patientRoom.acceptPatient(patient);
				this._patientsInWaitingRoom.splice(i,1);
				break;
			}
			
			// Clean Waiting Room References
			len = this._owner.owner.equipmentManager.chairs.length;
			var chair:Chair;
			for(i = 0; i < len; i++)
			{
				chair = this._owner.owner.equipmentManager.chairs[i];
				if(chair.patient == patient) 
				{
					chair.patient = null;
					break;
				}
			}
		}
		
// --------------------------------------------------------------------------------
		public function get patientsInWaitingRoom():Array { return _patientsInWaitingRoom };
	}
}