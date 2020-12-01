class CfgPatches
{
    class darcAiMover
    {
		units[] = {};
		weapons[] = {};
        version = 0.02;
    };
	author[]={"d'Arc"};   
};

class CfgFunctions {
	class darcAiMover {
		class main {			
			class darcAiMover_init
			{
				postInit = 1;
				file = "\x\addons\darcAiMover\fn_init.sqf";
			};
		};
	};
};