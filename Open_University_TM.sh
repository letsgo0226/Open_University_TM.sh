#!/bin/sh
command -v python3 >/dev/null 2>&1 || exit 127
exec python3 -u - "$@" <<'PY'
import sys,os,re,json,shlex,subprocess,tempfile

HEADINGS=("Learning Objectives","Chapter Overview","Key Terms","Main Text","Learning Activity","Self-Assessment","Answer Key","Chapter Summary","References")
O=b"OPEN_UNIVERSITY|COURSE_TM|ZERO_RESIDUAL|OPEN"
E=lambda b:int.from_bytes(b"\1"+b,"big")
D=lambda n:n.to_bytes((n.bit_length()+7)//8,"big")[1:]
V=lambda b:D(E(b))==b
J=lambda x:json.dumps(x,separators=(",",":"),ensure_ascii=False)

def atomic(path,data):
    d=os.path.dirname(os.path.abspath(path)); os.makedirs(d,exist_ok=True)
    q=tempfile.NamedTemporaryFile(dir=d,delete=False)
    try:
        q.write(data); q.close(); os.replace(q.name,path)
    finally:
        try: os.unlink(q.name)
        except FileNotFoundError: pass

def sources(path):
    if not os.path.isfile(path): return []
    xs=[x.strip() for x in open(path,encoding="utf-8") if x.strip() and not x.lstrip().startswith("#")]
    if len(xs)>200: raise SystemExit("SOURCE_PACK_TOO_LARGE")
    return xs

def objective_count(block):
    m=re.search(r"(?ms)^### Learning Objectives\s*$\n(.*?)(?=^### Chapter Overview\s*$)",block)
    if not m:return 0
    return sum(bool(re.match(r"^\s*(?:[-*]|\d+[.)])\s+\S",x)) for x in m.group(1).splitlines())

def validate(text,n,credits,src):
    starts=list(re.finditer(r"(?m)^## Chapter \d+ - .+$",text))
    blocks=[]
    for i,m in enumerate(starts):
        e=starts[i+1].start() if i+1<len(starts) else text.find("\n## Course Review",m.end())
        blocks.append(text[m.start():e if e>=0 else len(text)])
    fmt=len(blocks)==n and all(all(b.count("### "+h)==1 for h in HEADINGS) for b in blocks)
    obj=fmt and all(5<=objective_count(b)<=8 for b in blocks)
    shell=("## Course Profile" in text and "## Contents" in text and "## Course Review, Final Self-Assessment, Glossary and General References" in text)
    mn=int(os.getenv("MIN_CHARS_PER_CREDIT","50000")); mx=int(os.getenv("MAX_CHARS_PER_CREDIT","90000")); chars=len(text)
    length_ok=credits*mn<=chars<=credits*mx
    ids=[int(x) for x in re.findall(r"\[SRC:(\d+)\]",text)]
    bad=sorted({x for x in ids if x<1 or x>len(src)})
    gaps=text.count("[SOURCE NEEDED]")
    source_grounded=bool(src) and not bad and gaps==0
    rev=V(text.encode())
    structural=all((fmt,obj,shell,length_ok,rev))
    sr=0 if structural else 1
    ar=0 if source_grounded else 1
    return {"STATE":"G" if structural else "~G","STRUCTURAL_RESIDUAL":sr,"ACADEMIC_RESIDUAL":ar,"CHAPTERS":len(blocks),"EXPECTED_CHAPTERS":n,"CREDITS":credits,"CHARS":chars,"REV":rev,"FORMAT":fmt,"OBJECTIVES":bool(obj),"COURSE_SHELL":shell,"LENGTH_OK":length_ok,"SOURCE_COUNT":len(src),"SOURCE_MARKERS":len(ids),"BAD_SOURCE_IDS":bad,"SOURCE_NEEDED":gaps,"SOURCE_GROUNDED":source_grounded,"PUBLISHABLE":structural and source_grounded}

def ai(prompt):
    cmd=shlex.split(os.getenv("AI","ollama run "+os.getenv("MODEL","qwen2.5:7b")))
    if not cmd: raise SystemExit("AI_COMMAND_EMPTY")
    r=subprocess.run(cmd,input=prompt,text=True,capture_output=True,timeout=int(os.getenv("AI_TIMEOUT","900")))
    if r.returncode: sys.stderr.write(r.stderr); raise SystemExit("AI_FAIL")
    return r.stdout.strip()

A=sys.argv[1:]
if A and A[0]=="--self": print(J({"MODE":"self","FIXPOINT":O.decode(),"REV":V(O),"INDEX":hex(E(O)),"OPEN":True,"FINAL":False})); raise SystemExit
if A and A[0]=="--spec": print(J({"MODE":"spec","HEADINGS":HEADINGS,"OBJECTIVES":"5-8","ZERO_RESIDUAL":"structural compliance","OPEN":True,"FINAL":False})); raise SystemExit
sp=os.getenv("SOURCE_PACK","sources/bibliography.txt"); src=sources(sp)
if A and A[0]=="--validate":
    if len(A)<2: raise SystemExit("USAGE: --validate FILE [CHAPTERS] [CREDITS]")
    f=A[1]; n=int(A[2]) if len(A)>2 else 12; c=int(A[3]) if len(A)>3 else 2
    print(J(validate(open(f,encoding="utf-8").read(),n,c,src))); raise SystemExit
T=A[0] if A else "Professional Philosophy"; F=A[1] if len(A)>1 else "course.md"; N=int(A[2]) if len(A)>2 else 12; C=int(A[3]) if len(A)>3 else 2
if N<1 or C<1: raise SystemExit("CHAPTERS_AND_CREDITS_MUST_BE_POSITIVE")
pack="\n".join(f"[SRC:{i}] {s}" for i,s in enumerate(src,1)) or "(No verified source pack supplied. Mark factual claims [SOURCE NEEDED] and do not invent references.)"
base=("Act as a senior university distance-learning textbook author and academic editor. Write original, rigorous, self-contained university material for adult independent learners on "+T+". Progress from foundations to advanced material; define terms; separate facts, arguments, objections, evidence and interpretation; use worked examples and retrieval practice. Cite only the verified source pack with exact markers [SRC:n]. If the pack does not support a factual claim, append [SOURCE NEEDED]. Never invent a source, author, title, DOI, quotation or page number.\nVERIFIED SOURCE PACK:\n"+pack+"\n")
raw=ai(base+f"Return exactly {N} chapter titles, one per line and nothing else.")
L=[re.sub(r"^\s*(?:[-*]|\d+[.)])\s*","",x).strip() for x in raw.splitlines() if x.strip()][:N]
if len(L)!=N: raise SystemExit("OUTLINE_FAIL")
profile=ai(base+f"Write only a Course Profile for a {C}-credit correspondence course: intended learners, prerequisites, 6-10 measurable course outcomes, study schedule, assessment plan, academic-integrity policy, accessibility guidance, and source policy. Do not add a heading.")
chs=[]
H="\n".join("### "+x for x in HEADINGS)
for i,h in enumerate(L,1):
    prompt=base+f"Write Chapter {i}/{N} titled {h!r}, about 1800-2500 words. Use each heading below exactly once and in exactly this order:\n{H}\nLearning Objectives must contain 5-8 measurable bullet or numbered objectives. Self-Assessment must test those objectives; Answer Key must explain answers. References may contain only cited [SRC:n] entries from the verified pack. Output only the chapter body."
    chs.append(ai(prompt))
final=ai(base+"Write only the end-of-course material with: integrative review, a 20-item final self-assessment, explanatory answer key, four-week revision plan, alphabetized glossary, and general references restricted to cited [SRC:n] entries. Do not add the outer heading.")
P=["# "+T,"","## Course Profile","",profile,"","## Contents"]+[f"{i}. {h}" for i,h in enumerate(L,1)]
for i,(h,b) in enumerate(zip(L,chs),1): P += ["",f"## Chapter {i} - {h}","",b]
P += ["","## Course Review, Final Self-Assessment, Glossary and General References","",final,""]
text="\n".join(P); v=validate(text,N,C,src); strict=os.getenv("STRICT_SOURCES","0")=="1"; print(J(v))
if v["STRUCTURAL_RESIDUAL"] or (strict and v["ACADEMIC_RESIDUAL"]): raise SystemExit(1)
atomic(F,text.encode())
manifest=F+".manifest.json"; atomic(manifest,(json.dumps(v,indent=2,ensure_ascii=False)+"\n").encode())
print(J({"COURSE_OK":True,"FILE":F,"MANIFEST":manifest,"STATUS":"PUBLISHABLE" if v["PUBLISHABLE"] else "DRAFT","OPEN_EDU":True,"OPEN":True,"FINAL":False}))
PY
