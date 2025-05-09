typedef void(__fastcall* RakSendType)(void*, void*, int, int, int, void*);
RakSendType original_send;

void __fastcall HookedSend(void* this_ptr, void* stream, int priority, int reliability, int ordering_channel, void* system_address) {
    CallGlobalLuaFunction("_G.OnRakPeerSend", stream, priority, reliability, ordering_channel, system_address);
    return original_send(this_ptr, stream, priority, reliability, ordering_channel, system_address);
}
// what this will do is desync ur roblox player(for roblox)
// not for idiots
