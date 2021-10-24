---
-- Lerp methods
---

function SMH.LerpLinear(s, e, p)

    return Lerp(p, s, e);

end

function SMH.LerpLinearVector(s, e, p)

    return LerpVector(p, s, e);

end

function SMH.LerpLinearAngle(s, e, p)

    return LerpAngle(p, s, e);

end
