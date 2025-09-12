-- Unity Mono Helper v1.1 for Cheat Engine | By Zupremacy 
-- Params : Setup the values after your investigation of Mono Instances
-- local methodArgs = {999} | It could be dictionnary of arguments  {***} to run the method

-- Changelog : 1.1 More modulable and reusable code 

-- I hope this will make it easy for you to hack your favorites Unity Games.
-- More to come.

-- Zed

[enable]
{$lua}

if syntaxcheck then return end

function callMonoMethod(assemblyName, classNamespace, className, staticFieldName, methodName, methodArgs, methodReturnType, methodParamTypes)
  mono_initialize()
  LaunchMonoDataCollector()

  local domains = mono_enumDomains()
  if not domains or #domains == 0 then
    print("[-] No domain found") return
  end
  local domain = domains[1]
  mono_setCurrentDomain(domain)

  -- Find Class
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

  -- Find the static field "instance"
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

  -- Get static instance adress
  local staticBase = mono_class_getStaticFieldAddress(domain, classId)
  local instAddr = readPointer(staticBase + offset)
  if not instAddr or instAddr == 0 then
    print("[-] Instance is null") return
  end

  -- Check class type
  local actualClassId, classNameCheck = mono_object_getClass(instAddr)
  if actualClassId ~= classId then
    print("[!] Warning : Instance is not a (" .. tostring(classNameCheck) .. ")")

  end

  -- Find the method
  local args = methodArgs or {}             -- safe if nil
  local paramTypes = methodParamTypes or {} -- safe if nil
  local methodId = mono_class_findMethod(classId, methodName, #args, methodReturnType, table.unpack(paramTypes))
  if not methodId then
    print("[-] Method '" .. methodName .. "' not found") return
  end
  mono_compile_method(methodId)

  -- call the method
  local result = mono_invoke_method(domain, methodId, instAddr, args)
  print("[*] " .. methodName .. " executed! (return = " .. tostring(result) .. ")")
end

-- 🎯 Hotkeys
if f5hotkey then f5hotkey.destroy() f5hotkey=nil end
f5hotkey = createHotkey(function()
  callMonoMethod(
    "Assembly-CSharp",
    "",
    "WorldManager",
    "_instance",
    "RPC_AddMoney",
    {99999},              -- args
    "System.Void",        -- return type
    {"System.Int32"}      -- param types
  )
end, VK_F5)
print("[*] Hotkey F5 : Add Money 99999$")

if f6hotkey then f6hotkey.destroy() f6hotkey=nil end
f6hotkey = createHotkey(function()
  callMonoMethod(
    "Assembly-CSharp",
    "",
    "WorldManager",
    "_instance",
    "RPC_AddXP",
    {25},                 -- args
    "System.Void",        -- return type
    {"System.Int32"}      -- param types
  )
end, VK_F6)
print("[*] Hotkey F6 : Add XP 25")

if f7hotkey then f7hotkey.destroy() f7hotkey=nil end
f7hotkey = createHotkey(function()
  callMonoMethod(
    "Assembly-CSharp",
    "",
    "WorldManager",
    "_instance",
    "RPC_ResetHealth",
    nil,                  -- NO args
    "System.Void",        -- return type
    nil                   -- NO param types
  )
end, VK_F7)
print("[*] Hotkey F7  : Reset Health")


[disable]
{$lua}
if f5hotkey then f5hotkey.destroy() f5hotkey=nil print("[-] Hotkey F5 deactivated") end
if f6hotkey then f6hotkey.destroy() f6hotkey=nil print("[-] Hotkey F6 deactivated") end
if f7hotkey then f7hotkey.destroy() f7hotkey=nil print("[-] Hotkey F7 deactivated") end
