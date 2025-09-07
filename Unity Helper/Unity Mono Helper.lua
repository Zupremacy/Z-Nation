-- Unity Mono Helper for Cheat Engine | By Zupremacy 
-- Params : Setup the values after your investigation of Mono Instances
-- Hotkey : Default hotkey is F5 you can change is or add multiple executions with different Hotkeys

-- local assemblyName = "Assembly-CSharp"
-- local classNamespace = ""
-- local className = "WorldManager"
-- local staticFieldName = "_instance"
-- local methodName = "RPC_AddMoney" 	| While setting multiple methods you need to create multiple methodname fileds (LUA) 
-- local methodArgs = {999} 			| And this line also, you can setup a dictionnary of arguments  {***} to run your method
-- local methodReturnType = "System.Void"
-- local methodParamTypes = { "System.Int32" }

-- I hope this will make it easy for you to hack your favorites Unity Games.

-- Zed

[enable]
{$lua}

if syntaxcheck then return end

--Call Method
function callMonoMethod(assemblyName, classNamespace, className, staticFieldName, methodName, methodArgs, methodReturnType, methodParamTypes)
  mono_initialize()
  LaunchMonoDataCollector()

  local domains = mono_enumDomains()
  if not domains or #domains == 0 then
    print("[-] Mono domaines not found") return
  end
  local domain = domains[1]
  mono_setCurrentDomain(domain)

  -- Find class
  local classId = nil
  for _, asm in ipairs(mono_enumAssemblies()) do
    local img = mono_getImageFromAssembly(asm)
    if img ~= 0 and mono_image_get_name(img) == assemblyName then
      for _, cl in ipairs(mono_image_enumClasses(img)) do
        if cl.namespace == classNamespace and cl.classname == className then
          classId = cl.class
          break
        end
      end
    end
    if classId then break end
  end
  if not classId then
    print("[-] Class not found : " .. className) return
  end

  -- Find static field + class ID
  local fields = mono_class_enumFields(classId)
  local offset = nil
  for _, f in ipairs(fields) do
    if f.name == staticFieldName and f.isStatic then
      offset = f.offset
      break
    end
  end
  if not offset then
    print("[-] Static field '" .. staticFieldName .. "' not found") return
  end

  -- Get Instance adress
  local staticBase = mono_class_getStaticFieldAddress(domain, classId)
  local instAddr = readPointer(staticBase + offset)
  if not instAddr or instAddr == 0 then
    print("[-] Instance is null") return
  end

  -- Check class type
  local actualClassId, classNameCheck = mono_object_getClass(instAddr)
  if actualClassId ~= classId then
    print("[-] Unkown instance type (" .. tostring(classNameCheck) .. ")") return
  end

  -- Find Method
  local methodId = mono_class_findMethod(classId, methodName, #methodArgs, methodReturnType, table.unpack(methodParamTypes))
  if not methodId then
    print("[-] Method '" .. methodName .. "' not found") return
  end
  mono_compile_method(methodId)

  -- Invoke method
  local result = mono_invoke_method(domain, methodId, instAddr, methodArgs)
  print("[*] Method executed (retour = " .. tostring(result) .. ")")
end

-- Params
local assemblyName = "Assembly-CSharp"
local classNamespace = ""
local className = "WorldManager"
local staticFieldName = "_instance"
local methodName = "RPC_AddMoney"
local methodArgs = {999}
local methodReturnType = "System.Void"
local methodParamTypes = { "System.Int32" }


local methodName2 = "RPC_AddXP"
local methodArgs2 = {25}


-- Hotkey : Execute method when F5 is down
if f5hotkey then
  f5hotkey.destroy()
  f5hotkey = nil
end
-- Hotkey : Creation of the Hotkey

f5hotkey = createHotkey(function()
  callMonoMethod(
    assemblyName,
    classNamespace,
    className,
    staticFieldName,
    methodName,
    methodArgs,
    methodReturnType,
    methodParamTypes
  )
end, VK_F5)

print("[*] Hotkey F5 pressed : Invoke " .. methodName)

[disable]

{$lua}
if f5hotkey then
  f5hotkey.destroy()
  f5hotkey = nil
  print("[*] Hotkey F5 released")
end
