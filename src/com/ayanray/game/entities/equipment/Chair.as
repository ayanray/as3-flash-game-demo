package com.ayanray.game.entities.equipment
{
	import as3isolib.display.primitive.IsoBox;
	
	import com.ayanray.game.entities.characters.Patient;

	/**
	 * Basic equipment type for Chair. 
	 * TODO: Should create a basic equipment object type, then start subclassing for plants, etc.
	 * 
	 * @author Ayan Ray
	 * 
	 */	
	public class Chair extends IsoBox
	{
		public var patient:Patient;
		
		public function Chair()
		{
			super();
		}
	}
}