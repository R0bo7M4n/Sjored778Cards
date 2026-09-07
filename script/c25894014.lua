--c25894014
--Made by R0bo7M4n
--Meklord Malfunction
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon then destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Shuffle back when a Meklord is destroyed
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id,1})
    e2:SetCondition(s.tdcon)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

s.listed_series = {SET_MEKLORD}

function s.spfilter(c, e, tp)
    return c:IsSetCard(SET_MEKLORD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK + LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK + LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e1, tp)
    aux.RegisterClientHint(e:GetHandler(), nil, tp, 1, 0, aux.Stringid(id, 0))
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        Duel.AdjustInstantly(tc)
        Duel.Destroy(tc, REASON_EFFECT)
    end
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return not c:IsRace(RACE_MACHINE)
end

function s.cfilter(c, tp)
    return c:IsSetCard(SET_MEKLORD) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) 
        and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_EFFECT)
end

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    return rp == 1 - tp and eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.tdfilter(c)
    return c:IsSetCard(SET_MEKLORD) and c:IsAbleToDeck()
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then 
        return c:IsAbleToDeck() 
            and Duel.IsExistingMatchingCard(s.tdfilter, tp, LOCATION_GRAVE, 0, 1, c) 
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 2, tp, LOCATION_GRAVE)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.tdfilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
    if #g > 0 then
        g:AddCard(c)
        Duel.HintSelection(g)
        Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end
