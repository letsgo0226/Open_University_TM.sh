# Open_University_TM.sh

A **sub-2 KB, one-line, AI-optional correspondence-course generator**.

The main file `Open_University_TM.sh` remains one physical line and `<2048` bytes. It is now course-total in the practical sense that, for a valid finite topic/chapter request and working Python runtime, the absence or failure of an AI backend does not prevent course output: the program deterministically falls back to a structured offline study guide and only then exits.

## Model

```text
TOPIC
  -> deterministic course structure
  -> optional AI lesson enrichment
  -> fallback if AI is absent/fails
  -> source markers
  -> atomic course write
  -> HALT
```

The intended invariant is:

```text
HALT => COURSE_FILE_EXISTS
```

AI is therefore an optional semantic accelerator, not a required oracle.

## Course structure

Every chapter is constructed with exactly these nine headings:

1. Learning Objectives
2. Chapter Overview
3. Key Terms
4. Main Text
5. Learning Activity
6. Self-Assessment
7. Answer Key
8. Chapter Summary
9. References

Five learning-objective lines are always emitted. The course also contains a Course Profile, Contents, and Course Review.

## Offline / no-AI mode

No setup is required beyond Python 3:

```bash
sh Open_University_TM.sh "Introduction to Philosophy" philosophy.md 12
```

With no `AI` environment variable, the program emits:

```json
{"R":0,"MODE":"fallback","SOURCES":false}
```

and writes a complete structured course. Its offline `Main Text` is deliberately a rigorous study framework rather than fabricated subject-matter expertise. Factual claims should still be checked against authoritative sources.

## Optional AI enrichment

Set `AI` only when you want an external model to enrich each unit's `Main Text`:

```bash
AI="ollama run qwen2.5:7b" \
sh Open_University_TM.sh "Logic" logic.md 12
```

Any command that reads a prompt from stdin and writes a response to stdout can be used. If the command fails or returns no usable text, that unit falls back to the deterministic offline lesson instead of aborting the course.

## Source pack

Put one verified bibliographic source per non-comment line in:

```text
sources/bibliography.txt
```

or set:

```bash
SOURCE_PACK=my_sources.txt sh Open_University_TM.sh "Ethics" ethics.md 12
```

The compact program lists these entries as `[SRC:n]` in chapter References. If no pack exists it emits `[SOURCE NEEDED]`. This is provenance scaffolding, not proof that a source entails any particular claim.

## Output semantics

`R=0` denotes successful structural construction and output. `SOURCES=true` only means a nonempty source pack was available. It does not certify factual correctness or accreditation.

The write is atomic at the final step (`.tmp` followed by `os.replace`).

## CI

`.github/workflows/verify.yml` runs every five minutes and on push, pull request, manual dispatch, and `course-verify`. It verifies:

- one physical line;
- `<2048` bytes;
- valid shell syntax;
- no-AI fallback writes a complete course;
- even a broken AI command still falls back and writes a course;
- an optional mock AI can enrich the lesson text;
- repository policy/source files remain present.

## Scope

The repository provides open infrastructure for independent study. A deterministic fallback can guarantee a structured learning artifact, but the halting condition itself cannot create missing expert knowledge. A source pack, AI model, or human academic review is still needed when substantive factual reliability matters.

```text
OPEN=true
FINAL=false
```
