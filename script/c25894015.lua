--c25894015
--Made by R0bo7M4n
--Meklord Feast
local s, id = GetID()

function s.initial_effect(c)
    --Hand Activation 
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e0:SetCondition(s.handcon)
    c:RegisterEffect(e0)

    -- Target, Look & Equip / Half LP Damage
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_EQUIP + CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Banish to target up to 3 "Meklord" monsters for protection
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0, TIMING_END_PHASE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

s.listed_series = { 0x13, 0x3013 }

function s.emperor_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x3013)
end

function s.handcon(e)
    return Duel.IsExistingMatchingCard(s.emperor_filter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.synchro_filter(c)
    return c:IsType(TYPE_SYNCHRO)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.emperor_filter(chkc) end
    if chk == 0 then 
        return Duel.IsExistingTarget(s.emperor_filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.emperor_filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, 1 - tp, LOCATION_EXTRA)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local full_ex = Duel.GetFieldGroup(tp, 0, LOCATION_EXTRA)
    local exg = Duel.GetMatchingGroup(s.synchro_filter, tp, 0, LOCATION_EXTRA, nil)
    local took_damage = false
    
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 then

        if #full_ex > 0 then
            Duel.ConfirmCards(tp, full_ex)
        end
        
        if #exg > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
            local ec = exg:Select(tp, 1, 1, nil):GetFirst()
            if ec then
                if Duel.Equip(tp, ec, tc, true) then
                    local e1 = Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_EQUIP_LIMIT)
                    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
                    e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
                    e1:SetLabelObject(tc)
                    ec:RegisterEffect(e1)
                    
                    local code = tc:GetCode()
                    ec:RegisterFlagEffect(code, RESET_EVENT + RESETS_STANDARD, 0, 1)
                    
                    local atk = ec:GetTextAttack()
                    if atk < 0 then atk = 0 end
                    if atk > 0 then
                        local e2 = Effect.CreateEffect(c)
                        e2:SetType(EFFECT_TYPE_EQUIP)
                        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_OWNER_RELATE)
                        e2:SetCode(EFFECT_UPDATE_ATTACK)
                        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
                        
                        if code == 25894010 or code == 25894011 or code == 25894012 then
                            e2:SetValue(atk / 2)
                        else
                            e2:SetValue(atk)
                        end
                        ec:RegisterEffect(e2)
                    end
                else
                    took_damage = true
                end
            else
                took_damage = true
            end
        else
            
            took_damage = true
        end
    else
        took_damage = true
    end
    
    if took_damage then
        local lp = Duel.GetLP(tp)
        Duel.Damage(tp, math.floor(lp / 2), REASON_EFFECT)
    end
end

function s.profilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x13) or c:IsSetCard(0x3013) or c:IsSetCard(0x6013) or c:IsSetCard(0x9013))
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.profilter(chkc) end
    if chk == 0 then 
        return Duel.IsExistingTarget(s.profilter, tp, LOCATION_MZONE, 0, 1, nil) 
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.profilter, tp, LOCATION_MZONE, 0, 1, 3, nil)
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetTargetCards(e)
    if #g > 0 then
        for tc in aux.Next(g) do
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e1:SetRange(LOCATION_MZONE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e1:SetValue(function(e, re, rp) return rp ~= e:GetHandlerPlayer() end)
            e1:SetReset(RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1)
            
            tc:RegisterFlagEffect(id + 200, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        end
        g:KeepAlive()
        
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE + PHASE_END)
        e2:SetCountLimit(1)
        e2:SetReset(RESET_PHASE + PHASE_END)
        e2:SetLabelObject(g)
        e2:SetOperation(s.desop)
        Duel.RegisterEffect(e2, tp)
    end
end

function s.desfilter(c)
    return c:GetFlagEffect(id + 200) > 0
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    local tg = g:Filter(s.desfilter, nil)
    if #tg > 0 then
        Duel.Destroy(tg, REASON_EFFECT)
    end
    g:DeleteGroup()
end
