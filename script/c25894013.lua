--c25894013
--Made by R0bo7M4n
--Meklord Army of Mekanikle
local s,id=GetID()
function s.initial_effect(c)

    --special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.effcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --field spell
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.actcon)
    e2:SetCost(s.effcost)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    --special summon on destruction
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.spcon3)
    e3:SetCost(s.effcost)
    e3:SetTarget(s.sptg3)
    e3:SetOperation(s.spop3)
    c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsRace(RACE_MACHINE) end)
   
end

s.listed_series = {SET_MEKLORD}

function s.meklord_filter(c)
    return c:IsSetCard(SET_MEKLORD) or c:IsSetCard(SET_MEKLORD_ARMY)
end

function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon, except Machine monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_MACHINE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetFieldGroup(tp, LOCATION_ONFIELD, 0)
    return #g == 0 or g:FilterCount(s.meklord_filter, nil) == #g
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end



function s.field_spell_filter(c)
    return c:IsType(TYPE_FIELD) and c:IsSetCard(SET_MEKLORD)
end

function s.actcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

function s.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.meklord_filter, tp, LOCATION_ONFIELD, 0, 1, nil)
            and Duel.IsExistingMatchingCard(s.field_spell_filter, tp, LOCATION_DECK, 0, 1, nil)
    end
    local g = Duel.GetMatchingGroup(s.meklord_filter, tp, LOCATION_ONFIELD, 0, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.op2(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, s.meklord_filter, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
    if #g > 0 and Duel.Destroy(g, REASON_EFFECT) ~= 0 then
        local b1 = Duel.IsExistingMatchingCard(s.field_spell_filter, tp, LOCATION_DECK, 0, 1, nil)
        local b2 = true
        
        if not b1 then return end
        
        local op = 0
        if b1 and b2 then
            op = Duel.SelectOption(tp, aux.Stringid(id,4), aux.Stringid(id,3))
        elseif b1 then
            op = Duel.SelectOption(tp, aux.Stringid(id,4))
        else
            return
        end
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sc = Duel.SelectMatchingCard(tp, s.field_spell_filter, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
        if sc then
            if op == 0 then
                Duel.SendtoHand(sc, nil, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, sc)
            else
                Duel.MoveToField(sc, tp, tp, LOCATION_FZONE, POS_FACEUP, true)
            end
        end
    end
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x13) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.spcon3(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.sptg3(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.spop3(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end
