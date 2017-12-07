--[[
Copyright © 2017, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of SkillChains nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.author = 'Ivaar'
_addon.command = 'sc'
_addon.name = 'SkillChains'
_addon.version = '2.2017.12.06'

require('luau')
require('pack')
texts = require('texts')
skills = require('skills')

_static = S{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'}

default = {}
default.Show = {burst=_static, pet=S{'BST','SMN'}, props=_static, spell=S{'SCH','BLU'}, step=_static, timer=_static, weapon=_static}
default.UpdateFrequency = 0.2
default.aeonic = false
default.color = false
default.display = {text={size=12,font='Consolas'},pos={x=0,y=0}}--,bg={visible=false}}

settings = config.load(default)
skill_props = texts.new('',settings.display,settings)
buff_dur = {[163]=40,[164]=30,[470]=60}
info = {}

colors = {}            -- Color codes by Sammeh
colors.Light =         '\\cs(255,255,255)'
colors.Dark =          '\\cs(0,0,204)'
colors.Ice =           '\\cs(0,255,255)'
colors.Water =         '\\cs(0,0,255)'
colors.Earth =         '\\cs(153,76,0)'
colors.Wind =          '\\cs(102,255,102)'
colors.Fire =          '\\cs(255,0,0)'
colors.Lightning =     '\\cs(255,0,255)'
colors.Gravitation =   '\\cs(102,51,0)'
colors.Fragmentation = '\\cs(250,156,247)'
colors.Fusion =        '\\cs(255,102,102)'
colors.Distortion =    '\\cs(51,153,255)'
colors.Darkness =      colors.Dark
colors.Umbra =         colors.Dark
colors.Compression =   colors.Dark
colors.Radiance =      colors.Light
colors.Transfixion =   colors.Light
colors.Induration =    colors.Ice
colors.Reverberation = colors.Water
colors.Scission =      colors.Earth
colors.Detonation =    colors.Wind
colors.Liquefaction =  colors.Fire
colors.Impaction =     colors.Lightning

skillchain = {'Light','Darkness','Gravitation','Fragmentation','Distortion','Fusion','Compression','Liquefaction','Induration','Reverberation','Transfixion','Scission','Detonation','Impaction','Radiance','Umbra'}

prop_info = {
    Radiance = {elements={'Fire','Wind','Lightning','Light'},lvl=4},
    Umbra = {elements={'Earth','Ice','Water','Dark'},lvl=4},
    Light = {elements={'Fire','Wind','Lightning','Light'},Light='Light',aeonic='Radiance',lvl=3},
    Darkness = {elements={'Earth','Ice','Water','Dark'},Darkness='Darkness',aeonic='Umbra',lvl=3},
    Gravitation = {elements={'Earth','Dark'},Distortion='Darkness',Fragmentation='Fragmentation',lvl=2},
    Fragmentation = {elements={'Wind','Lightning'},Fusion='Light',Distortion='Distortion',lvl=2},
    Distortion = {elements={'Ice','Water'},Gravitation='Darkness',Fusion='Fusion',lvl=2},
    Fusion = {elements={'Fire','Light'},Fragmentation='Light',Gravitation='Gravitation',lvl=2},
    Compression = {elements={'Darkness'},Transfixion='Transfixion',Detonation='Detonation',lvl=1},
    Liquefaction = {elements={'Fire'},Impaction='Fusion',Scission='Scission',lvl=1},
    Induration = {elements={'Ice'},Reverberation='Fragmentation',Compression='Compression',Impaction='Impaction',lvl=1},
    Reverberation = {elements={'Water'},Induration='Induration',Impaction='Impaction',lvl=1},
    Transfixion = {elements={'Light'},Scission='Distortion',Reverberation='Reverberation',Compression='Compression',lvl=1},
    Scission = {elements={'Earth'},Liquefaction='Liquefaction',Reverberation='Reverberation',Detonation='Detonation',lvl=1},
    Detonation = {elements={'Wind'},Compression='Gravitation',Scission='Scission',lvl=1},
    Impaction = {elements={'Lightning'},Liquefaction='Liquefaction',Detonation='Detonation',lvl=1},
    }

initialize = function(text, settings)
    if not windower.ffxi.get_info().logged_in then
        return
    end
    if not info.job then
        local player = windower.ffxi.get_player()
        info.job = player.main_job
        info.player = player.id
    end
    local properties = L{}
    if settings.Show.timer[info.job] then
        properties:append('${timer}')
    end
    if settings.Show.step[info.job] then
        properties:append('Step: ${step} >> ${en}')
    end
    if settings.Show.props[info.job] then
        properties:append('${props} ${elements}')
    end
    properties:append('${disp_info}')
    text:clear()
    text:append(properties:concat('\n'))
end
skill_props:register_event('reload', initialize)

function update_weapon(bag, ind)
    if not settings.Show.weapon[info.job] then
        return
    end
    local main_weapon = windower.ffxi.get_items(bag,ind).id
    if main_weapon ~= 0 then
        info.aeonic = L{20515,20594,20695,20843,20890,20935,20977,21025,21082,21147,21485,21694,21753,22117}:contains(main_weapon)
        return
    end
    if not check_weapon or coroutine.status(check_weapon) ~= 'suspended' then
        check_weapon = coroutine.schedule(update_weapon-{bag,ind}, 10)
    end
end

function aeonic_am(step)
    if info.aeonic then
        for x=270,272 do
            if buffs[x] then
                return 272-x < step
            end
        end
    end
    return false
end

function aeonic_prop(ability, actor)
    if not ability.aeonic or not info.aeonic and actor == info.player or not settings.aeonic and info.player ~= actor then
        return ability.skillchain
    end
    return {ability.skillchain[1],ability.skillchain[2],ability.aeonic}
end

function check_props(old, new)
    local n = #old < 4 and #new or 1
    for k=1,#old do
        for i=1,n do local v = prop_info[old[k]][new[i]]
            if v then
                return prop_info[v].lvl == 3 and old[k] == new[i] and 4 or prop_info[v].lvl, v
            end
        end
    end
end

function add_color(str)
    if str and settings.color then
        return '%s%s\\cr':format(colors[str], str)
    end
    return str
end

function string.pad(str, len)
    return #str < len and str..' ':rep(len-#str) or str
end

function add_skills(abilities, active, cat, aeonic)
    local t = {}
    for k=1,#abilities do local ability = skills[cat][abilities[k]]
        if ability then
            local lvl,prop = check_props(active, aeonic_prop(ability, info.player))
            if prop then
                table.insert(t, {'%s>> Lv':format(ability.en:pad(17)),lvl, add_color(aeonic and lvl == 4 and prop_info[prop].aeonic or prop):pad(14)})
            end
        end
    end
    return table.sort(t, function(a, b) return a[2] > b[2] end)
                 
                                     
       
                               
end

function check_results(reson)
    local temp = {}
    if settings.Show.spell[info.job] and info.job == 'SCH' then
        table.insert(temp, add_skills({1,2,3,4,5,6,7,8}, reson.active, 20))
    elseif settings.Show.spell[info.job] and info.job == 'BLU' then
        table.insert(temp, add_skills(windower.ffxi.get_mjob_data().spells, reson.active, 4))
    elseif settings.Show.pet[info.job] and windower.ffxi.get_mob_by_target('pet') then
        table.insert(temp, add_skills(windower.ffxi.get_abilities().job_abilities, reson.active, 13))
    end
    if settings.Show.weapon[info.job] then
        table.insert(temp, add_skills(windower.ffxi.get_abilities().weapon_skills, reson.active, 3, aeonic_am(reson.step)))
    end
    local results = {}
    for x=1,#temp do
        for k=1,#temp[x] do
            table.insert(results, table.concat(temp[x][k],' '))
        end
    end
    return table.concat(results,'\n')
end

function do_stuff()
    local targ = windower.ffxi.get_mob_by_target('t','bt')
    local now = os.time()
    for k,v in pairs(resonating) do
        if v.ts and now-v.ts > v.dur then
            resonating[k] = nil
        end
    end
    if targ and targ.hpp > 0 and resonating[targ.id] and resonating[targ.id].dur-(now-resonating[targ.id].ts) > 0 then
        local timediff = now-resonating[targ.id].ts
        local timer = resonating[targ.id].dur-timediff
        if not resonating[targ.id].closed then
            resonating[targ.id].disp_info = resonating[targ.id].disp_info or check_results(resonating[targ.id])
            resonating[targ.id].timer = timediff < resonating[targ.id].wait and 
                '\\cs(255,0,0)Wait  %d\\cr':format(resonating[targ.id].wait-timediff) or
                '\\cs(0,255,0)Go!   %d\\cr':format(timer)
        elseif settings.Show.burst[info.job] then
            resonating[targ.id].disp_info = ''
            resonating[targ.id].timer = 'Burst %d':format(timer)
        else
            resonating[targ.id] = nil
            return
        end
        if not resonating[targ.id].props then
            if not resonating[targ.id].bound then
                local a,b,c = unpack(resonating[targ.id].active)
                resonating[targ.id].props = L{add_color(a),add_color(b),add_color(c)}
            else
                resonating[targ.id].props = '[Chainbound Lv.%d]':format(resonating[targ.id].bound)
            end
        end
        if resonating[targ.id].step > 1 and settings.Show.burst[info.job] then
            if not resonating[targ.id].elements then
                local a,b,c,d = unpack(prop_info[resonating[targ.id].active[1]].elements)
                resonating[targ.id].elements = S{add_color(a),add_color(b),add_color(c),add_color(d)}
            end
        else
            resonating[targ.id].elements = ''
        end
        skill_props:update(resonating[targ.id])
        skill_props:show()
    elseif not visible then
        skill_props:hide()
    end
end

function chain_buff(actor)
    if not ja_flag[actor] then 
        return false
    end
    if ja_flag[actor].ts - os.time() < 1 then
        ja_flag[actor] = nil
        return false
    end
    if ja_flag[actor].buff > 163 then
        ja_flag[actor] = nil
    end
    return true
end

windower.register_event('incoming chunk', function(id, data)
    if id == 0x28 then
        local actor,targets,category,param = data:unpack('Ib10b4b16',6)
        local ability = skills[category] and skills[category][param]
        local effect = data:unpack('b17',27,6)
        local prop = skillchain[data:unpack('b6',35)]
        if ability and (category ~= 4 or chain_buff(actor) or prop) then
            local mob = data:unpack('b32',19,7)
            local msg = data:unpack('b10',29,7)
            if prop then
                local reson = resonating[mob]
                local step = (reson and reson.step or 1) + 1
                local lvl = prop_info[prop].lvl == 3 and reson and check_props(reson.active, aeonic_prop(ability, actor)) or prop_info[prop].lvl
                resonating[mob] = {en=ability.en, active={prop}, ts=os.time(), dur=11-step, wait=3, step=step, closed=lvl == 4 or step > 5}
            elseif L{2,110,161,162,185,187,317}:contains(msg) then
                resonating[mob] = {en=ability.en, active=aeonic_prop(ability, actor), ts=os.time(), dur=10, wait=3, step=1}
            elseif msg == 529 then
                resonating[mob] = {en=ability.en, active=ability.skillchain, ts=os.time(), dur=ability.dur, wait=1, step=1, bound=effect}
            end
        elseif category == 6 and buff_dur[effect] then
            ja_flag[actor] = {buff = effect, ts = buff_dur[effect] + os.time()}
        end
    elseif id == 0x29 and data:unpack('H',25) == 206 and data:unpack('I',9) == info.player then
        local buff = data:unpack('I',13)
        buffs[buff] = nil
        if buff_dur[buff] and ja_flag[info.player] and buff == ja_flag[info.player].buff then
            ja_flag[info.player] = nil
        end
    elseif id == 0x50 and data:byte(6) == 0 then
        update_weapon(data:byte(7),data:byte(5))
    elseif id == 0x63 and data:byte(5) == 9 then
        local set_buff = {}
        for n=1,32 do
            set_buff[data:unpack('H', n*2+7)] = true
        end
        buffs = set_buff
    end
end)

windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower()
    if cmd == 'move' then
        visible = not visible
        if visible and not skill_props:visible() then
            skill_props:update({disp_info='     --- SkillChains ---\n\n\n\nClick and drag to move display.'})
            skill_props:show()
        elseif not visible then
            skill_props:hide()
        end
    elseif cmd == 'save' then
        local arg = ... and ...:lower() == 'all' and ...
        config.save(settings, arg)
        windower.add_to_chat(207, '%s: settings saved to %s character%s.':format(_addon.name,arg or 'current',arg and 's' or ''))
    elseif default.Show[cmd] then
        if not default.Show[cmd][info.job] then
            windower.add_to_chat(207, '%s: unable to set %s on %s.':format(_addon.name,cmd,info.job))
            return
        end
        local key = settings.Show[cmd][info.job]
        if not key then
            settings.Show[cmd]:add(info.job)
        else
            settings.Show[cmd]:remove(info.job)
        end
        config.save(settings)
        config.reload(settings)
        windower.add_to_chat(207, '%s: %s info will no%s be displayed on %s.':format(_addon.name,cmd,key and ' longer' or 'w',info.job))--'t' or 'w'
    elseif type(default[cmd]) == 'boolean' then
        settings[cmd] = not settings[cmd]
        windower.add_to_chat(207, '%s: %s %s':format(_addon.name,cmd,settings[cmd] and 'on' or 'off'))
    elseif cmd == 'eval' then
        assert(loadstring(table.concat({...}, ' ')))()
    else
        windower.add_to_chat(207, '%s: valid commands [save | move | burst | weapon | spell | pet | props | step | timer | color | aeonic]':format(_addon.name))
    end
end)

windower.register_event('job change', function(job,lvl)
    job = res.jobs:with('id', job).english_short
    if job ~= info.job then
        info.job = job
        config.reload(settings)
    end
end)

windower.register_event('unload', function()
    coroutine.close(check_weapon)
    coroutine.close(do_loop)
end)

function reset()
    ja_flag = {}
    resonating = {}
    buffs = {}
end
windower.register_event('zone change', reset)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        local equip = windower.ffxi.get_items('equipment')
        update_weapon(equip.main_bag, equip.main)
    end
    reset()
    do_loop = do_stuff:loop(settings.UpdateFrequency)
end)

windower.register_event('logout', function()
    coroutine.close(check_weapon) check_weapon = nil
    info = {}
    reset()
end)
