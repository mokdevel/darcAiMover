# darcAiMover
An Arma 3 AI mover to headless clients. This is only needed on server and NOT on headless clients.

## How to test
In short - no guide here. :-)
- Setup a dedicated Arma 3 server with a mission in virtual reality (player and up to 6 headless client entities)
- Setup headless client(s) (up to 6)
- Run Arma server with the mod -servermod=@darcAiMover . This is *NOT* needed on the HCs
- Spawn as many AI you want on the server side. The mod will slowly move the AI to the HCs.
- Benefit: _NO_ naked guys.

Once you've logged in as admin to your server, run this as SERVER EXEC in your debug window

	private _u = 4;	//Units per group
	private _g = 5;	//Groups to spawn. The values here will spawn 20 AI on the server.
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
