#!/usr/bin/env python3
"""Compile production Luau and run deterministic tests. Needs official luau + luau-compile on PATH."""
import argparse, os, pathlib, subprocess
root=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(); p.add_argument('--tools',default=''); args=p.parse_args()
def tool(name): return str(pathlib.Path(args.tools)/name) if args.tools else name
def run(*argv): subprocess.run(argv,cwd=root,check=True,stdout=None)
files=list((root/'src').rglob('*.luau'))+list((root/'studio-snapshot').rglob('*.luau'))
for file in files:
    result=subprocess.run([tool('luau-compile'),str(file)],capture_output=True,text=True,encoding="utf-8")
    if result.returncode: raise SystemExit(result.stderr)
print(f'PASS: {len(files)} source and Studio snapshot Luau files compile',flush=True)
run(tool('luau'),'tests/Rules.spec.luau')
run(tool('luau'),'tests/Duel.spec.luau')
work=root/'work';work.mkdir(exist_ok=True)
def wrapped(file,name):
    source=(root/file).read_text(encoding="utf-8")
    source=source.replace('require(game.ReplicatedStorage.ZIVRA.Weapons)','W').replace('require(game.ReplicatedStorage.ZIVRA.Rules)','R')
    source=source.replace('require(script.Parent.HeldModels)','Held')
    return f'\nlocal {name}=(function()\n{source}\nend)()\n'
bundle=(root/'tests/EngineMocks.luau').read_text(encoding="utf-8")+wrapped('src/server/Combat.luau','Combat')+wrapped('src/server/Utility.luau','Utility')+(root/'tests/Combat.spec.luau').read_text(encoding="utf-8")
(work/'CombatTests.luau').write_text(bundle)
run(tool('luau'),'work/CombatTests.luau')

profile_test=(root/'tests/Profiles.spec.luau').read_text(encoding="utf-8").replace('-- MODULE_INSERT',wrapped('src/server/Profiles.luau','Profiles'))
(work/'ProfilesTests.luau').write_text(profile_test)
run(tool('luau'),'work/ProfilesTests.luau')
