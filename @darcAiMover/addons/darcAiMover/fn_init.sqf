/*
  ~ fn_init.sqf
  - d'Arc

  Init script

*/

diag_log format ["@darcAiMover: Starting"];

[] execVm "\x\addons\darcAiMover\fnc_ai_hc.sqf";

if !(isServer) exitWith {};	//Runs only on server

_handle = [] spawn 
{
	while {true} do
	{
		sleep 10;
		call fn_ai_to_hc;
	};
};
