# darcAiMover
An Arma 3 AI mover to headless clients


## Once you've logged in as admin to your server, run this as SERVER EXEC in your debug window

	private _u = 4;	//Units
	private _g = 5;	//Groups
	private _side = EAST;
	private _pos = getpos ((allPlayers - entities "HeadlessClient_F") select 0);	
	private _type = "C_scientist_F";

	for "_j" from 1 to _g do
	{
		private _group = creategroup [_side, TRUE];
		for "_i" from 1 to _u do
		{
			_unit = _group createUnit [_type, _pos, [], 0, "NONE"]; 
		};
	};
