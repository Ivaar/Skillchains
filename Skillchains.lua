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
_addon.author = 'Ivaar, contributors: Sebyg666, Sammeh'
_addon.command = 'sc'
_addon.name = 'SkillChains'
_addon.version = '2.0.8'
_addon.updated = '2017.10.21'

texts = require('texts')
packets = require('packets')
config = require('config')
skills = require('skills')

default = {
    show = {weapon=true,immanence=true,pet=true,burst=true,properties=true,timer=true,step=true,aeonic=false},
    display = {text={size=12,font='Consolas'},pos={x=0,y=20},},
    burst_display = {text={size=12,font='Consolas'},pos={x=0,y=0},},
    }
  
settings = config.load(default)
skill_props = texts.new('',settings.display,settings)
magic_bursts = texts.new('',settings.burst_display,settings)

skillchains = L{
    [288] = 'Light',
    [289] = 'Darkness',
    [290] = 'Gravitation',
    [291] = 'Fragmentation',
    [292] = 'Distortion',
    [293] = 'Fusion',
    [294] = 'Compression',
    [295] = 'Liquefaction',
    [296] = 'Induration',
    [297] = 'Reverberation',
    [298] = 'Transfixion',
    [299] = 'Scission',
    [300] = 'Detonation',
    [301] = 'Impaction',
    [385] = 'Light',
    [386] = 'Darkness',
    [387] = 'Gravitation',
    [388] = 'Fragmentation',
    [389] = 'Distortion',
    [390] = 'Fusion',
    [391] = 'Compression',
    [392] = 'Liquefaction',
    [393] = 'Induration',
    [394] = 'Reverberation',
    [395] = 'Transfixion',
    [396] = 'Scission',
    [397] = 'Detonation',
    [398] = 'Impaction',
    [767] = 'Radiance',
    [768] = 'Umbra',
    [769] = 'Radiance',
    [770] = 'Umbra',
    }

colors = {
    ['Impaction'] = '\\cs(255,0,255)',
    ['Lightning'] = '\\cs(255,0,255)',
    ['Darkness'] = '\\cs(0,0,204)',
    ['Umbra'] = '\\cs(0,0,204)',
    ['Gravitation'] = '\\cs(102,51,0)',
    ['Fragmentation'] = '\\cs(250,156,247)',
    ['Distortion'] = '\\cs(51,153,255)',
    ['Compression'] = '\\cs(0,0,204)',
    ['Induration'] = '\\cs(0,255,255)',
    ['Ice'] = '\\cs(0,255,255)',
    ['Reverberation'] = '\\cs(0,0,255)',
    ['Water'] = '\\cs(0,0,255)',
    ['Transfixion'] = '\\cs(255,255,255)',
    ['Scission'] = '\\cs(153,76,0)',
    ['Stone'] = '\\cs(153,76,0)',
    ['Earth'] = '\\cs(153,76,0)',
    ['Detonation'] = '\\cs(102,255,102)',
    ['Wind'] = '\\cs(102,255,102)',
    ['Fusion'] = '\\cs(255,102,102)',
    ['Liquefaction'] = '\\cs(255,0,0)',
    ['Fire'] = '\\cs(255,0,0)',
    }

prop_info = {
    Radiance = {elements='Fire Wind Lightning Light',props={Light='Light'},lvl=3},
    Umbra = {elements='Earth Ice Water Darkness',props={Darkness='Darkness'},lvl=3},
    Light = {elements='Fire Wind Lightning Light',props={Light='Light'},aeonic='Radiance',lvl=3},
    Darkness = {elements='Earth Ice Water Darkness',props={Darkness='Darkness'},aeonic='Umbra',lvl=3},
    Gravitation = {elements='Earth Darkness',props={Distortion='Darkness',Fragmentation='Fragmentation'},lvl=2},
    Fragmentation = {elements='Wind Lightning',props={Fusion='Light',Distortion='Distortion'},lvl=2},
    Distortion = {elements='Ice Water',props={Gravitation='Darkness',Fusion='Fusion'},lvl=2},
    Fusion = {elements='Fire Light',props={Fragmentation='Light',Gravitation='Gravitation'},lvl=2},
    Compression = {elements='Darkness',props={Transfixion='Transfixion',Detonation='Detonation'},lvl=1},
    Liquefaction = {elements='Fire',props={Impaction='Fusion',Scission='Scission'},lvl=1},
    Induration = {elements='Ice',props={Reverberation='Fragmentation',Compression='Compression',Impaction='Impaction'},lvl=1},
    Reverberation = {elements='Water',props={Induration='Induration',Impaction='Impaction'},lvl=1},
    Transfixion = {elements='Light',props={Scission='Distortion',Reverberation='Reverberation',Compression='Compression'},lvl=1},
    Scission = {elements='Earth',props={Liquefaction='Liquefaction',Reverberation='Reverberation',Detonation='Detonation'},lvl=1},
    Detonation = {elements='Wind',props={Compression='Gravitation',Scission='Scission'},lvl=1},
    Impaction = {elements='Lightning',props={Liquefaction='Liquefaction',Detonation='Detonation'},lvl=1},
    }

function reset()
    chain_ability = {[1]={},[2]={}}
    resonating = {}
end
reset()

function create_timer(dur,ind,act)
    local start = os.time()
    chain_ability[ind][act] = start
    coroutine.schedule(function(ind,act,start)
        return function()
            if chain_ability[ind][act] == start then
              chain_ability[ind][act] = nil
            end
        end
    end(ind,act,start), dur)
end

function get_buffs(buff_list)
    local buffs = {}
    for i,v in pairs(buff_list) do
        buffs[v] = true
    end
    return buffs
end

function check_am(buffs)
    buffs = get_buffs(buffs)
    if buffs[272] then
        return 2
    elseif buffs[271] then
        return 3
    elseif buffs[270] then
        return 4
    end
end

function check_aeonic()
    local equip = windower.ffxi.get_items().equipment
    return skills.aeonic[windower.ffxi.get_items(equip.main_bag, equip.main).id]
end

function aeonic_props(ability,actor,aeonic)
    local self = windower.ffxi.get_mob_by_target('me').id
    if not ability.aeonic or actor == self and not aeonic or actor ~= self and not settings.show.aeonic then
        return ability.skillchain
    end
    local sc_ele = {}
    table.update(sc_ele,ability.skillchain)
    table.insert(sc_ele,3,ability.aeonic)
    return sc_ele
end

function check_lvl(active,new)
    for k,v in pairs(active) do
        if prop_info[new].lvl == 3 and prop_info[v].lvl == 3 then
            return 4
        end
    end
    return prop_info[new].lvl
end

function check_props(active,new)
    for key,element in ipairs(active) do
        local props = prop_info[element].props
        for x=1,#new do
            for k,v in pairs(props) do
                if k == new[x] then
                    return v
                end
            end
        end
    end
end

function check_results(reson)
    local weapon,spell,pet= {},{},{}
    local player = windower.ffxi.get_player()
    local abilities = windower.ffxi.get_abilities()
    local aeonic = check_aeonic()
    local aeonic_am = aeonic and check_am(player.buffs)
    if settings.show.weapon then
        for i,t in ipairs(abilities.weapon_skills) do
            local ability = skills[3][t]
            local prop = ability and check_props(reson.active,aeonic_props(ability,player.id,aeonic))
            if prop then
                local lvl = check_lvl(reson.active,prop)
                if lvl == 4 and aeonic_am and aeonic_am <= reson.step then
                    prop = prop_info[prop].aeonic
                end
                weapon[ability.en] = {lvl=lvl,prop=prop}
            end
        end
    end
    if settings.show.immanence and player.main_job == 'SCH' then
        for k,v in pairs(prop_info) do
            if v.lvl == 1 then
                local prop = check_props(reson.active,{k})
                if prop then 
                    spell[v.elements..' Magic'] = {lvl=check_lvl(reson.active,prop),prop=prop}
                end
            end
        end
    elseif settings.show.blu and player.main_job == 'BLU' then
        for i,t in ipairs(windower.ffxi.get_mjob_data().spells) do
            local ability = skills[4][t]
            local prop = ability and check_props(reson.active,ability.skillchain)
            if prop then
                spell[ability.en] = {lvl=check_lvl(reson.active,prop),prop=prop}
            end
        end
    elseif settings.show.pet and windower.ffxi.get_mob_by_target('pet') then
        for i,t in ipairs(abilities.job_abilities) do
            local ability = skills[13][t]
            local prop = ability and check_props(reson.active,ability.skillchain)
            if prop then 
                pet[ability.en] = {lvl=check_lvl(reson.active,prop),prop=prop}
            end
        end
    end
    return {[1]=weapon,[2]=spell,[3]=pet}
end

function display_results(results)
    local str = ''
    for x=1,4 do
        for i,t in ipairs(results) do
            for k,v in pairs(t) do
                if v.lvl == x then
                    if i == 3 then
                        str = ' \\cs(0,255,0)%s\\cs(255,255,255) >> Lv.%d %s \n':format(k:rpad(' ', 15),v.lvl,v.prop)..str
                    else
                        str = ' %s >> Lv.%d %s \n':format(k:rpad(' ', 15),v.lvl,v.prop)..str
                    end
                end
            end
        end
    end
    return str
end

function do_stuff()
    local targ = windower.ffxi.get_mob_by_target('t','bt')
    local now = os.time()
    for k,v in pairs(resonating) do
        if v.timer and now-v.timer > v.dur then
            resonating[k] = nil
        end
    end
    if targ and targ.hpp > 0 and resonating[targ.id] and resonating[targ.id].dur-(now-resonating[targ.id].timer) > 0 then
        local disp_info = ''
        if settings.show.properties and not resonating[targ.id].closed then
            if #resonating[targ.id].active < 4 then
                for k,element in ipairs(resonating[targ.id].active) do
                    disp_info = disp_info..' [%s]':format(element)
                end
            else
                disp_info = ' [Chainbound Lv %d]':format(prop_info[resonating[targ.id].active[1]].lvl)
            end
            disp_info = disp_info..'\n'
        end
        if not resonating[targ.id].closed then
            disp_info = disp_info..display_results(check_results(resonating[targ.id]))
        end
        if settings.show.timer and not resonating[targ.id].closed and now-resonating[targ.id].timer < resonating[targ.id].wait then
            disp_info = ' wait %s \n':format(resonating[targ.id].wait-(now-resonating[targ.id].timer))..disp_info
        elseif settings.show.timer and not resonating[targ.id].closed then
            disp_info = '  GO! %s \n':format(resonating[targ.id].dur-(now-resonating[targ.id].timer))..disp_info
            --for i,v in pairs(colors) do
            --    disp_info = string.gsub(disp_info, i, v..i..'\\cs(255,255,255)')
            --end
        end
        if settings.show.step and not resonating[targ.id].closed then
            disp_info = ' Step: %d >> [%s] >> ':format(resonating[targ.id].step,resonating[targ.id].en)..disp_info
        end
        if settings.show.burst and resonating[targ.id].step > 1 then
            magic_bursts:text(' Burst:(%s) %s ':format(prop_info[resonating[targ.id].active[1]].elements, resonating[targ.id].dur-(now-resonating[targ.id].timer)))
            magic_bursts:show()
        else
            magic_bursts:hide()
        end
        skill_props:text(disp_info)
        skill_props:show()
    elseif not visible then
        skill_props:hide()
        magic_bursts:hide()
    end
end

function loop()
	while doloop do
		do_stuff()
		coroutine.sleep(0.2)
	end	
end

function apply_props(packet)
    local mob = windower.ffxi.get_mob_by_id(packet['Target 1 ID'])
    if not mob or not mob.is_npc or mob.hpp == 0 then return end
    local ability = skills[packet.Category][packet.Param]
    local skillchain = skillchains[packet['Target 1 Action 1 Added Effect Message']]
    if skillchain then
        local step = (resonating[mob.id] and resonating[mob.id].step or 1) + 1
        local closed = resonating[mob.id] and (check_lvl(resonating[mob.id].active,skillchain) == 4 or step >= 6)
        resonating[mob.id] = {en=ability.en,active={skillchain},timer=os.time(),dur=11-step,wait=3,chain=true,closed=closed,step=step}
    elseif L{2,110,161,162,185,187,317}:contains(packet['Target 1 Action 1 Message']) then
        resonating[mob.id] = {en=ability.en,active=aeonic_props(ability,packet.Actor,check_aeonic()),timer=os.time(),dur=10,wait=3,step=1}
    elseif packet['Target 1 Action 1 Message'] == 529 then
        resonating[mob.id] = {en=ability.en,active=ability.skillchain,timer=os.time(),dur=ability.dur,wait=0,step=1}
    end          
end

windower.register_event('incoming chunk', function(id,data)
    if id == 0x028 then
        local packet = packets.parse('incoming', data)
        if packet.Category == 4 and skills[4][packet.Param] and 
            (packet['Target 1 Action 1 Has Added Effect'] or chain_ability[1][packet.Actor] or chain_ability[2][packet.Actor]) then
            chain_ability[1][packet.Actor] = nil
            apply_props(packet)
        elseif L{3,11,13,14}:contains(packet.Category) and skills[packet.Category][packet.Param] then
            apply_props(packet)
        elseif packet.Category == 6 then
            if packet.Param == 93 then
                create_timer(40,2,packet.Actor)
            elseif packet.Param == 94 then
                create_timer(30,1,packet.Actor)
            elseif packet.Param == 317 then
                create_timer(60,1,packet.Actor)
            end
        end
    --[[elseif id == 0x076 then  -- Byrth Gearswap
        partybuffs = {}
        for i = 0,4 do
            if data:unpack('I',i*48+5) == 0 then
                break
            else
                partybuffs[data:unpack('I',i*48+5+0)] = {index = data:unpack('H',i*48+5+4), buffs = {}}
                for n=1,32 do
                    partybuffs[data:unpack('I',i*48+5+0)].buffs[n] = data:byte(i*48+5+16+n-1) + 256*( math.floor( data:byte(i*48+5+8+ math.floor((n-1)/4)) / 4^((n-1)%4) )%4)
                end
            end
        end]]
    end
end)

windower.register_event('addon command', function(...)
    local commands = {...}
    for x=1,#commands do commands[x] = commands[x]:lower() end
    if commands[1] == 'move' then
        visible = true
        if not skill_props:visible() then
            skill_props:text('\n      --- SkillChains ---\n\n Click and drag to move display. \n\n')
            magic_bursts:text(' ----- Magic Burst ----- ')
            magic_bursts:show()
            skill_props:show()
            return
        end
        visible = false
        magic_bursts:hide()
        skill_props:hide()
   elseif S{'weapon','immanence','pet','burst','properties','timer','step','aeonic'}:contains(commands[1]) then
        if not commands[2] then
            settings.show[commands[1]] = not settings.show[commands[1]]
        elseif commands[2] == 'off' then
            settings.show[commands[1]] = false
        elseif commands[2] == 'on' then
            settings.show[commands[1]] = true
        end
        windower.add_to_chat(207, '%s: %s.':format(commands[1],settings.show[commands[1]] and 'TRUE' or 'FALSE'))
    elseif commands[1] == 'save' then
        config.save(settings, 'all')
    elseif commands[1] == 'eval' then
        assert(loadstring(table.concat(commands, ' ',2)))()
    end
end)

windower.register_event('unload', function()
	doloop = false
end)

windower.register_event('load', function()
	doloop = true
	loop()
end)

windower.register_event('zone change','logout', reset)
