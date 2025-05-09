local old_namecall
old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()

    if method == "FireServer" or method == "InvokeServer" then
        print("[+] Hooked:", self:GetFullName())
        print("  Args:", ...)
        --  Set/Mod Ur Packets Here 
    end

    return old_namecall(self, ...)
end)

setreadonly(getrawmetatable(game), true)
