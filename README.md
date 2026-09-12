# Open_University_TM.sh

A **sub-2 KB one-line** AI-assisted correspondence-course generator with zero-residual structural and source checks.

The main file `Open_University_TM.sh` is intentionally compressed to one physical line and must remain `<2048` bytes. GitHub Actions verifies both constraints on every push, pull request, manual run, repository dispatch, and every five minutes.

## Model

```text
TOPIC -> OUTLINE -> COURSE PROFILE -> CHAPTERS -> ASSESSMENT -> SOURCE CHECK -> ZERO RESIDUAL -> ATOMIC PUBLISH
```

Each chapter is required to contain exactly these nine headings:

1. Learning Objectives
2. Chapter Overview
3. Key Terms
4. Main Text
5. Learning Activity
6. Self-Assessment
7. Answer Key
8. Chapter Summary
9. References

The prompt requires 5-8 measurable objectives per chapter, aligned assessment and answers, plus a course profile and final review material.

The compact validator emits JSON such as:

```json
{"R":0,"STRUCTURE":true,"SOURCES":true}
```

`R=0` means both the structural check and source check pass. The target file is written only after this zero-residual condition; writing uses a temporary file followed by `os.replace()`.

## AI backend

The default backend is:

```bash
ollama run qwen2.5:7b
```

If `ollama` is not installed, the program now exits cleanly with a message such as:

```text
AI_FAIL:/bin/sh: 1: ollama: not found
```

instead of producing a Python traceback.

You can use any command that reads a prompt from standard input and writes its answer to standard output:

```bash
AI="ollama run llama3.1:8b" sh Open_University_TM.sh "Logic" logic.md 12
```

or set `AI` to another local/API-backed CLI wrapper.

## Verified source pack

Put one verified bibliographic source per non-comment line in:

```text
sources/bibliography.txt
```

or choose another file:

```bash
SOURCE_PACK=my_sources.txt AI="ollama run qwen2.5:7b" \
sh Open_University_TM.sh "Ethics" ethics.md 12
```

The model may cite only `[SRC:n]` identifiers from that pack. Invalid source identifiers or any remaining `[SOURCE NEEDED]` marker make the source residual nonzero. The compact edition deliberately requires a nonempty source pack before publication.

This is a mechanical integrity check, not proof that every citation semantically entails every sentence. Expert review is still appropriate for accredited or high-stakes education.

## Usage

```bash
sh Open_University_TM.sh "Introduction to Philosophy" philosophy.md 12
```

Arguments are:

```text
TOPIC OUTPUT_FILE CHAPTERS
```

Defaults are:

```text
Philosophy course.md 12
```

## CI

`.github/workflows/verify.yml` checks:

- the main program is one physical line;
- its byte size is `<2048`;
- shell syntax is valid;
- a missing AI executable fails cleanly without a traceback;
- a deterministic mock AI can generate a one-chapter zero-residual course;
- repository policy/source files remain present.

## Scope

This repository provides open infrastructure for AI-assisted independent study. It does not itself confer university credit, accreditation, instructor supervision, or guaranteed factual correctness.

```text
OPEN=true
FINAL=false
```
