--/lua/ui/game/chat.lua hook
--Chat extensions by Mithy
-- * Persistent, preferences-saved ignore list with shortcuts
-- * Overhauled slash command system with several new commands added and easy extensibility
-- * Improved text display for non-chat messages, including wrapping, window size adjustment, etc
--Type '/?' in the chat window for a list of available commands


local Prefs = import('/lua/ui/prefs.lua')


--New function for better handling of non-chat message display
--Wraps text, shows history, and adjusts width like ReceiveChat
function DisplayMessage(msg, wrap)
    local textBoxWidth = bg.history.Right() - bg.history.Left()
    local wrappedText = {msg}
    if wrap then
        wrappedText = import('/lua/maui/text.lua').WrapText(msg, textBoxWidth, function(text) return bg.history:GetStringAdvance(text) end)
    end
    for i, textLine in wrappedText do
        bg.history:AddItem(textLine)
    end
    bg.history:ScrollToBottom()
    local numItems = bg.history:GetItemCount()
    local longest = 0
    for i = numItems - 10, numItems do
        if i < 0 or i >= numItems then
            continue
        end
        local textLine = bg.history:GetItem(i)
        local length = import('/lua/maui/text.lua').GetTextWidth(textLine, function(text) return bg.history:GetStringAdvance(text) end)
        if length > longest then
            longest = length
        end
    end
    bg.historyBackMid.Width:Set(longest - 76)
    if bg:IsHidden() then
        ShowHistory()
    end
end

--Forked by CreateChat to handle delayed ignore list auto-population
function AutoIgnore()
    WaitSeconds(5)
    --Auto-ignore from preferences
    local ignoreList = IgnoreList:Get()
    for name, val in ignoredPlayers do
        if ignoreList[name] and not val then
            HandleIgnore(name)
        end
    end
end


local prevCreateChat = CreateChat
function CreateChat()
    prevCreateChat()
    --Override OnEnterPressed to:
    -- allow proper handling of commands without parameters
    -- improve command function table and allow for help text (see ChatCommands table)
    -- show the chat window after performing a command
    -- add commands to the up/down arrow history
    bg.edit.OnEnterPressed = function(self, text)
        if text ~= "" then
            if string.sub(text, 1, 1) == '/' then
                local a, b, comKey, param = string.find(text, '^/([^%s]+)%s*(.*)$')
                if comKey and ChatCommands:GetCommand(comKey) then
                    ChatCommands:Execute(comKey, param)
                else
                    DisplayMessage(LOCF("<LOC chatui_0008>Unknown command: %s", comKey or '?'), true)
                end
                table.insert(commandhistory, { text = text })
                ToggleChat()
                ShowHistory()
            else
                msg = { to = chatTo, text = text }
                if chatTo == 'allies' then
                    SessionSendChatMessage(FindClients(), msg)
                else
                    SessionSendChatMessage(msg)
                end
                table.insert(commandhistory, msg)
                ToggleChat()
            end
        else
            ToggleChat()
        end
    end
    --Set chat font size from profile
    local fontsize = tonumber(Prefs.GetFromCurrentProfile('chat_font_size'))
    if fontsize and fontsize >= 10 and fontsize <= 24 then
        bg.history:SetFont(UIUtil.bodyFont, fontsize)
    end
    --Set chat inactivity timeout from profile
    local timeout = tonumber(Prefs.GetFromCurrentProfile('chat_inactivity_timeout'))
    if timeout and timeout >= 2 and timeout <= 30 then
        CHAT_INACTIVITY_TIMEOUT = timeout
    end

    ForkThread(AutoIgnore)
end


--Ignore list handling
IgnoreList = {
    Get = function(self)
        return GetPreference('IgnoreList') or {}
    end,

    Save = function(self, list)
        SetPreference('IgnoreList', table.copy(list))
        SavePreferences()
    end,

    Add = function(self, name)
        local list = self:Get()
        if not list[name] then
            list[name] = true
            self:Save(list)
        end
    end,

    Remove = function(self, name)
        local list = self:Get()
        if list[name] then
            list[name] = nil
            self:Save(list)
        end
    end,
}


--[[ New slash command handling with alias and help text support.

To add a new function as a command, use something like the following syntax:
    ChatCommands:AddCommand('name', data)

..where name is the primary command alias, and data is a table containing at least an Action function, e.g.:
    local data = {
        Action = ExampleFunction,
        Aliases = {
            'alias1',
            'alias2',
        },
        HelpText = 'Description of the command',
    }

HelpText can be set to false if for whatever reason you don't want the command to show up in the help display at all.

Any names in Aliases (optional) can also be used to trigger the command in the chat box, and will be listed in the help display.
Action is a defined function to which a single string parameter (all of the text following the command, minus any leading spaces)
will be passed.  The function does not need to accept use the parameter, and the system now fully supports slash commands without
any following text (this would break the old system).  See the various uses of the system below for examples.

Additional aliases for existing commands can be added using the AddAlias and AddAliases methods, e.g.:
    ChatCommands:AddAlias('mycommand', 'myalias')
    -or-
    ChatCommands:AddAliases('mycommand', {'alias1', 'alias2'})


If you want your mod to work without being dependent on this one, simply do a check for ChatCommands before proceeding.  You can
still support the old system as well, by inserting subtables into specialCommands (which will have no effect with this mod running),
keeping in mind the limitations of the GPG implementation.--]]
ChatCommands = {
    Commands = {},
    HelpText = {},

    GetCommand = function(self, name)
        return self.Commands[name]
    end,

    Execute = function(self, name, param)
        local command = self:GetCommand(name)
        if command and command.Action then
            command.Action(param)
        end
    end,

    AddCommand = function(self, name, data)
        if name and data and type(data) == 'table' and data.Action and type(data.Action) == 'function' then
            if not self.Commands[name] then
                self.Commands[name] = {
                    Action = data.Action,
                    Name = name,
                }
                self:AddAliases(name, data.Aliases or {})
                self.HelpText[name] = data.HelpText or 'no description'
            end
        else
            WARN("ChatCommands: AddCommand: Incomplete data table for command '"..repr(name).."'; data table must contain at least an Action function")
        end
    end,

    AddAlias = function(self, name, alias)
        local cmd = self.Commands[name]
        if cmd then
            if not self.Commands[alias] then
                self.Commands[alias] = cmd
                if not cmd.Aliases then
                    cmd.Aliases = {}
                end
                table.insert(cmd.Aliases, alias)
            else
                LOG("ChatCommands: AddAlias: Alias '"..repr(alias).."' already refers to command '"..repr(self.Commands[alias].Name).."'")
            end
        else
            WARN("ChatCommands: AddAlias: Command '"..repr(name).."' not found")
        end
    end,

    AddAliases = function(self, name, aliases)
        if self.Commands[name] then
            for k, alias in aliases do
                self:AddAlias(name, alias)
            end
        else
            WARN("ChatCommands: AddAliases: Command '"..repr(name).."' not found")
        end
    end,

    ShowHelp = function(self)
        DisplayMessage('Available commands:')
        local cmds = {}
        for name, text in self.HelpText do
            if text then
                table.insert(cmds, name)
            end
        end
        table.sort(cmds)
        for _, name in cmds do
            DisplayMessage(' /'..name..':  '..self.HelpText[name])
            if self.Commands[name].Aliases then
                local msg = '     Aliases: '
                for k, alias in self.Commands[name].Aliases do
                    msg = msg..'   /'..alias
                end
                DisplayMessage(msg)
            end
        end
    end,
}
--Chat command help text
ChatCommands:AddCommand('?', {Action=function() ChatCommands:ShowHelp() end,Aliases={'help'},HelpText='Displays command help'})

--Chat history clear
ChatCommands:AddCommand('clear', {Action=function() bg.history:DeleteAllItems() end,Aliases={'cls'},HelpText='Clears chat history'})



--List player indexes for ignore shortcuts
function ListPlayers()
    DisplayMessage('Player indexes:')
    for id, army in GetArmiesTable().armiesTable do
        if army.human and ignoredPlayers[string.lower(army.nickname)] ~= nil then
            DisplayMessage(' '..string.format('%2d', id)..': '..army.nickname)
        end
    end
end
ChatCommands:AddCommand('playerlist', {Action=ListPlayers,Aliases={'pl'},HelpText='Lists player indexes for use with /ignore'})


--New ignore handling to improve message display and save to preferences
--Also now accepts army indexes
function HandleIgnore(param)
    if param != "" then
        local playerName = string.lower(param)
        local index = tonumber(param)
        if index and index <= 10 then
            local army = GetArmiesTable().armiesTable[index]
            if army and army.human then
                playerName = string.lower(army.nickname)
            end
        end
        if ignoredPlayers[playerName] != nil then
            ignoredPlayers[playerName] = not ignoredPlayers[playerName]
            if ignoredPlayers[playerName] then
                DisplayMessage(LOCF("<LOC chatui_0005>Ignoring %s", playerName))
                IgnoreList:Add(playerName)
            else
                DisplayMessage(LOCF("<LOC chatui_0006>No longer ignoring %s", playerName))
                IgnoreList:Remove(playerName)
            end
        else
            DisplayMessage(LOCF("<LOC chatui_0007>Player not found: %s", playerName))
        end
    end
end
ChatCommands:AddCommand('ignore', {Action=HandleIgnore,Aliases={'squelch','s','i'},HelpText='Toggles ignore/squelch for the specified player name or index'})


--Display ignore list
function DisplayIgnore()
    local ignoreList = IgnoreList:Get()
    if not table.empty(ignoreList) then
        DisplayMessage('Ignored player names:')
    else
        DisplayMessage('Ignore list is empty')
        return
    end
    local ingame = {}
    local saved = {}
    for name, val in ignoreList do
        if ignoredPlayers[name] then
            table.insert(ingame, name)
        else
            table.insert(saved, name)
        end
    end
    --in the current game
    if not table.empty(ingame) then
        for k, name in ingame do
            DisplayMessage('[*]'..name)
        end
    end
    --saved names
    if not table.empty(saved) then
        for k, name in saved do
            DisplayMessage('    '..name)
        end
    end
    if bg:IsHidden() then
        ShowHistory()
    end
end
ChatCommands:AddCommand('ignorelist', {Action=DisplayIgnore,Aliases={'squelchlist','sl','il'},HelpText='Shows squelched/ignored player names'})

--Change font size
function FontSize(size)
    size = tonumber(size)
    if size and size >= 10 and size <= 24 then
        bg.history:SetFont(UIUtil.bodyFont, size)
        DisplayMessage('New font size '..size..' saved to profile')
        Prefs.SetToCurrentProfile('chat_font_size', size)
    else
        DisplayMessage('Font size must be between 10 and 24 (default 18)')
    end
end
ChatCommands:AddCommand('size', {Action=FontSize,HelpText='Sets chat history font size (10-24 default 18)'})

--Change history window timeout
function HideTime(time)
    time = tonumber(time)
    if time and time >= 2 and time <= 30 then
        CHAT_INACTIVITY_TIMEOUT = time
        DisplayMessage('New chat inactivity timeout '..time..' saved to profile')
        Prefs.SetToCurrentProfile('chat_inactivity_timeout', time)
    else
        DisplayMessage('Chat inactivity timeout must be between 2 and 30 (default 5)')
    end
end
ChatCommands:AddCommand('time', {Action=HideTime,HelpText='Sets chat history timeout in seconds (2-30, default 5)'})