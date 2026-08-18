# sB Hub v1 — faithful GitHub split

Source: the uploaded `/mnt/data/sB Hub(1).txt` (4,576 lines).

This build preserves the original source code rather than substituting simplified module implementations. The monolith is split at natural boundaries to reduce the executor local-register pressure while keeping the original shared variables/functions available across chunks.

Files:
- loader.lua
- config.lua — original lines 1-340
- ui.lua — original lines 341-1732
- automation.lua — original lines 1733-2185 and 3430-3728
- notifications.lua — original lines 2186-2662 and 3730-3743
- spy.lua — original lines 2663-2893
- esp.lua — original lines 2894-3263
- stats.lua — original lines 3264-3429
- runtime.lua — original lines 3745-4235 and 4359-4576
- overlays.lua — original lines 4236-4357

The loader fetches each file from:
https://raw.githubusercontent.com/sssBHub/sB-Hub-v1/main/

Run only loader.lua in the executor.
