local ffi = require("ffi")

ffi.cdef[[
typedef void* (__fastcall* RakSendType)(void* This, void* Stream, int Priority, int Reliability, int OrderingChannel, void* SystemAddress);
]]

-- Constants
local expected_vtable_size = 64 
local target_vtable_function_index = 11 

-- Helpers
function is_valid_vtable(vtable)
    local function is_executable(addr) -- gotta finish this func
      
        return true 
    end
    for i = 0, expected_vtable_size - 1 do
        local ptr = read_pointer(vtable + i * 8)
        if ptr == nil or ptr == 0 or not is_executable(ptr) then
            return false
        end
    end
    return true
end

function scan_for_instance()
    local start_address = get_module_base("RobloxPlayerBeta.exe")
    local module_size = get_module_size("RobloxPlayerBeta.exe")

    for address = start_address, start_address + module_size - 0x1000, 8 do
        local potential_ptr = read_pointer(address)
        if potential_ptr then
            local vtable = read_pointer(potential_ptr)
            if vtable and is_valid_vtable(vtable) then
                local send_func = read_pointer(vtable + target_vtable_function_index * 8)
                if send_func then
                    return vtable, send_func
                end
            end
        end
    end

    return nil, nil
end


local vtable, original_send_address = scan_for_instance()
assert(original_send_address, "Failed to locate ConcurrentRakPeer::Send")


local original_send = ffi.cast("RakSendType", original_send_address)

local function hooked_send(this, stream, priority, reliability, ordering_channel, system_address)
    print("[+] Hook Triggered: ConcurrentRakPeer::Send")
  
    return original_send(this, stream, priority, reliability, ordering_channel, system_address)
end


local hook_ptr = ffi.cast("RakSendType", hooked_send)
local hook_target = vtable + target_vtable_function_index * 8

unprotect(hook_target)
write_pointer(hook_target, ffi.cast("void*", hook_ptr))

print("[+] hook installed at:", string.format("0x%X", tonumber(ffi.cast("uintptr_t", original_send_address))))
