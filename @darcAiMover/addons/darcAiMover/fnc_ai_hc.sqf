//----------------------------------------------------------------
// fn_get_hcList; 
//
// Get a list of _actual_ headless clients that are in game. 
// NOTE: entities "HeadlessClient_F" returns a list of HC slots in a mission.
//
// Example: 	
// 	_hcList = call fn_get_hcList;
//----------------------------------------------------------------
fn_get_hcList =
{
	_hcList = allPlayers - (allPlayers - entities "HeadlessClient_F");
	_hcList
};

//----------------------------------------------------------------
// fn_ai_groups; 
//
// List of groups with only AI.
//
//----------------------------------------------------------------
fn_ai_groups =
{
	private _plr_grp = []; 
	{_plr_grp pushBackUnique group _x} forEach allPlayers;
	_ai_grp = allGroups - _plr_grp;
	_ai_grp
};

//----------------------------------------------------------------
// fn_countAIonHC
//
// [HC1] spawn fnc_countAIonHC; 
//
// Count the amount of AI on certain HC
//
// Example: 	
// 	[] spawn fnc_countAIonHC; 
//----------------------------------------------------------------
fn_countAIonHC =  
{ 
	_hc = param [0, ""]; 
	_hc_owner = owner _hc;
	
	_c = 0;
	_c = count ((allUnits - allPlayers) select {(owner _x == _hc_owner)} ); 
	_c 
}; 

//----------------------------------------------------------------
// fn_countAIonHC_arr
//
// [] spawn fn_countAIonHC_arr; 
//
// Count the amount of AI on all HCs
//
// Example: 	
// 	_list = call fn_countAIonHC_arr; 
//----------------------------------------------------------------
fn_countAIonHC_arr =  
{ 
	//Count the AI amount on each HC
	_hcList = call fn_get_hcList;
	
	_hcAIcount = [];
	{_hcAIcount pushback 0} foreach _hcList;
	//1000 is set so that when sorting, these will be at the end. Stupid code...
//	_hcAIcount = [1000,1000,1000,1000,1000,1000]; 
	 
	for "_i" from 0 to ((count _hcList) - 1) step 1 do  
	{ 
//		_hcx = owner (_hcList select _i); 
		_hcx = (_hcList select _i); 
		_c = _hcx call fn_countAIonHC;  
		_hcAIcount set [_i, _c];  
	}; 
	_hcAIcount
}; 

//----------------------------------------------------------------
// fn_ai_to_hc; 
//
// This will move the 
//
// Example: 	
// 	[] spawn fn_ai_to_hc; 
//----------------------------------------------------------------
fn_ai_to_hc =
{
	//Parameters
	_timeout = 20;
	_group_cnt_to_send = 4;
	
	//---------------

	_hcList = call fn_get_hcList;
	_ai_groups = call fn_ai_groups;
	diag_log format ["@darcAiMover: Headless client process running. (%1)", _hcList];
	
	if ( count _hcList > 0) then
	{
		//Count AI on HCs
		_hcAIcount = call fn_countAIonHC_arr;

		//Find the HC with lowest amount AI
		_small_idx = 0;
		_smallest = _hcAIcount select _small_idx;
		{if (_x < _smallest) then {_small_idx = _foreachindex;};} forEach _hcAIcount;
		_HC = owner (_hcList select _small_idx);
		diag_log format ["@darcAiMover: AI on HC: %1 . Sending to %2.", _hcAIcount, (_hcList select _small_idx)];
//		diag_log format ["@darcAiMover: (%1) is smallest %2", _small_idx, _hcAIcount];

		//Check if chosen HC is ready
		if (_HC > 0) then
		{	
			_g_fr = [];
			_g_nonfr = [];
			{
				//Read timeBorn from groups
				private _timeBorn = _x getVariable ["timeBorn", -1];
				if (_timeBorn isEqualTo -1) then
				{
					//If timeBorn does not exist, create one
//					diag_log format ["@darcAiMover: Group %1 set timeBorn=%2", _x, time];
					_x setVariable ["timeBorn", time, true];
				}
				else
				{	
					//A group can only be moved after a minimum of 20 secs in game
					//Find the groups that are still on server and collect to _g_fr.
					if ( ( (_timeborn + _timeout) < time ) AND ( groupOwner _x == 2 ) ) then
					{		
//						diag_log format ["@darcAiMover: Group %1 (o: %4) timeBorn=%2 (< %3)", _x, (_timeborn + 20), time, groupOwner _x];
						_g_fr pushback _x;
					}
					else
					{
//						diag_log format ["@darcAiMover: Group %1 (o: %4) timeBorn=%2 (< %3) - nonmovable", _x, (_timeborn + 20), time, groupOwner _x];
						_g_nonfr pushback _x;
					};
				};
			} foreach _ai_groups;

			diag_log format ["@darcAiMover: %1 movable groups. %2 non movable groups.", count _g_fr, count _g_nonfr];

			if (count _g_fr > _group_cnt_to_send) then 
			{
				//We move _group_cnt_to_send groups at a time. This will share the load more evenly.
				_g_fr resize _group_cnt_to_send;
			};
			
			{
				diag_log format ["@darcAiMover: Group %1 moved to HC %2 from %3", _x, _HC, groupOwner _x];
				_x setGroupOwner _HC;
			} foreach _g_fr;
		};
	}
	else
	{
		diag_log format["@darcAiMover: No headless clients in use."];
	};
};

//----------------------------------------------------------------
// fn_ai_to_hc_now; 
//
// Move all AI to random HC immediately. This is for debugging.
//
// Example: 	
// 	[] spawn fn_ai_to_hc_now; 
//----------------------------------------------------------------
fn_ai_to_hc_now =
{
	_hcList = call fn_get_hcList;
	systemChat format ["@darcAiMover: Moving all to HC. (%1)", _hcList];

	if ( count _hcList > 0 ) then
	{
		{
			private _timeBorn = _x getVariable "timeBorn";
			
			if ( (_timeborn + 20) < time ) then
			{
				_HC = selectRandom _hcList;			
				diag_log format ["@darcAiMover: Group %1 moved to HC %2 from %3", _x, _HC, groupOwner _x];
				_x setGroupOwner (owner _HC);
			}
			else
			{
				diag_log format ["@darcAiMover: Group %1 is too young (%2 < %3).", _x, (_timeborn + 20), time];
			};
		} foreach allGroups;
	};
};
