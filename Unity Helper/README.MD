Unity Mono Helper for Cheat Engine | By Zupremacy

Params : Setup the values after your investigation of Mono Instances
Hotkey : Default hotkey is F5 you can change is or add multiple executions with different Hotkeys

local assemblyName = "Assembly-CSharp"
local classNamespace = ""
local className = "WorldManager"
local staticFieldName = "_instance"
local methodName = "RPC_AddMoney" 	| While setting multiple methods you need to create multiple methodname fileds (LUA) 
local methodArgs = {999} 			| And this line also, you can setup a dictionnary of arguments  {***} to run your method
local methodReturnType = "System.Void"
local methodParamTypes = { "System.Int32" }


I hope this will make it easy for you to hack your favorites Unity Games.

Zed
