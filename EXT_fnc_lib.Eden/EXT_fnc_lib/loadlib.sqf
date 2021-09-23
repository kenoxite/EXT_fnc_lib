comment{
	LOAD EXTENDED FUNCTION LIBRARY
	*** It requires CWA ***
	
	by kenoxite
};
EXT_fl_on=true;

private ["_path"];
_path=if(count _this>0)then{_this select 0}else{"\EXT_fnc_lib\"};

EXT_fl_debug=true;

EXT_fl_trigger="EmptyDetector" camCreate [0,0,0];
if(format ["%1",EXT_fl_logic] == "scalar bool array string 0xfcffffef")then{EXT_fl_logic="logic" createVehicle [0,0,0]};

EXT_fl_nAIv=["EmptyDetector","Track","Mark","SmokeSource","ObjectDestructed","Explosion","Crater","CraterOnVehicle","Slop","Smoke","DynamicSound","StreetLamp","StreetLampWood","StreetLampMetal","SoundOnVehicle","ThunderBolt","EditCursor","ObjView","Temp","SeaGull","Camera","ProxyWeapon","ProxySecWeapon"];

call loadfile format["%1common.sqf",_path];
call loadfile format["%1terrain.sqf",_path];
call loadfile format["%1groups.sqf",_path];
call loadfile format["%1spawn.sqf",_path];
comment{if(EXT_fl_debug)then{call loadfile format["%1test.sqf",_path]};};

call loadfile format["%1dictionary.sqf",_path];
