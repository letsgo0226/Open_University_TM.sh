# Open_University_TM.sh

A zero-residual generator and validator for AI-assisted, self-study distance-learning course materials.

The project turns a topic into a structured correspondence-course manuscript, validates its mechanical course specification, tracks source grounding separately from format compliance, and writes the result atomically only after the structural checks pass.

## Design

The generator follows this pipeline:

```text
TOPIC
  -> CURRICULUM
  -> COURSE PROFILE
  -> CHAPTERS
  -> LEARNING OBJECTIVES
  -> ACTIVITIES
  -> SELF-ASSESSMENT
  -> ANSWER KEY
  -> SOURCE CHECK
  -> VALIDATION
  -> ATOMIC WRITE
```

Its core acceptance idea is a zero-residual specification:

```text
STRUCTURAL_RESIDUAL = 0
```

for mechanically verified course structure. Source grounding is deliberately tracked as a separate quantity:

```text
ACADEMIC_RESIDUAL = 0
```

only when a verified source pack exists, every `[SRC:n]` citation refers to that pack, and no `[SOURCE NEEDED]` marker remains.

This separation matters: a perfectly formatted AI manuscript is not automatically academically verified.

## Course structure

Every generated chapter must contain each of these sections exactly once, in order:

1. Learning Objectives
2. Chapter Overview
3. Key Terms
4. Main Text
5. Learning Activity
6. Self-Assessment
7. Answer Key
8. Chapter Summary
9. References

Each chapter must contain 5-8 measurable learning objectives. The whole course also includes a Course Profile, Contents, and an end-of-course review with final self-assessment, explanatory answers, revision plan, glossary, and general references.

The default length envelope is 50,000-90,000 characters per credit. It can be changed with `MIN_CHARS_PER_CREDIT` and `MAX_CHARS_PER_CREDIT`.

## Requirements

- POSIX shell
- Python 3
- an AI command that accepts the prompt on standard input and writes the answer to standard output

The default AI command is:

```bash
ollama run qwen2.5:7b
```

You can replace it through the `AI` environment variable.

## Usage

```bash
chmod +x Open_University_TM.sh

./Open_University_TM.sh \
  "Introduction to Philosophy" \
  philosophy_course.md \
  12 \
  2
```

Arguments are:

```text
TOPIC OUTPUT_FILE CHAPTERS CREDITS
```

Defaults are:

```text
Professional Philosophy course.md 12 2
```

### Another model

```bash
AI="ollama run llama3.1:8b" \
./Open_University_TM.sh "Logic" logic.md 12 2
```

### Source-grounded mode

Place one verified bibliographic source per non-comment line in:

```text
sources/bibliography.txt
```

or point `SOURCE_PACK` to another file:

```bash
SOURCE_PACK=my_sources.txt \
STRICT_SOURCES=1 \
./Open_University_TM.sh "Ethics" ethics.md 12 2
```

The model is instructed to cite only exact markers such as `[SRC:1]`. The validator rejects citation IDs that do not exist in the source pack. Unsupported factual claims must remain marked `[SOURCE NEEDED]`.

`STRICT_SOURCES=1` prevents writing the course unless the academic residual is also zero. Without strict mode, a structurally valid but incompletely sourced manuscript is written as `DRAFT`, not `PUBLISHABLE`.

This is a mechanical citation-integrity check; it does not prove that a cited source semantically entails every sentence. Expert review is still appropriate for high-stakes or accredited use.

## Validation-only mode

An existing course can be checked without invoking AI:

```bash
./Open_University_TM.sh --validate course.md 12 2
```

It reports compact JSON including:

```text
STRUCTURAL_RESIDUAL
ACADEMIC_RESIDUAL
FORMAT
OBJECTIVES
LENGTH_OK
SOURCE_GROUNDED
PUBLISHABLE
```

## Machine modes

```bash
./Open_University_TM.sh --self
./Open_University_TM.sh --spec
```

`--self` verifies the reversible sentinel-byte integer encoding used by the model kernel. `--spec` emits the currently enforced course-section specification.

## Output

A successful structural generation writes:

```text
course.md
course.md.manifest.json
```

The manifest records validation results. Writes are atomic, so a structurally failed generation does not replace the target course file.

## Educational interpretation

This repository is intended as open infrastructure for AI-assisted independent study. It can help anyone with access to a compatible AI model generate a structured course manuscript, but it does **not** itself confer university credit, accreditation, instructor supervision, or guaranteed factual correctness.

A useful deployment model is:

```text
open source generator
+ verified source pack
+ user-selected AI
+ automated structural validation
+ human/academic review when required
```

The system remains explicitly open-ended:

```text
OPEN=true
FINAL=false
```
