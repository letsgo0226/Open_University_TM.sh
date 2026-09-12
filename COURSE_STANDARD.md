# Course Generation Standard

This repository uses a machine-checkable **distance-learning textbook profile**. It is designed for rigorous independent study and correspondence-style learning. It is not a claim of institutional accreditation or affiliation.

## 1. Course-level requirements

A generated course must contain:

- a course title;
- `## Course Profile`;
- intended learners and prerequisites;
- 6-10 measurable course outcomes;
- study schedule;
- assessment plan;
- academic-integrity and source policy;
- accessibility guidance;
- `## Contents`;
- exactly the requested number of chapters;
- an end-of-course integrative review;
- final self-assessment with explanatory answers;
- revision plan;
- glossary;
- general references.

## 2. Chapter-level requirements

Every chapter must contain these headings exactly once and in this order:

```text
### Learning Objectives
### Chapter Overview
### Key Terms
### Main Text
### Learning Activity
### Self-Assessment
### Answer Key
### Chapter Summary
### References
```

Each chapter must contain **5-8 measurable learning objectives**. Assessment items should align with those objectives, and the answer key should explain rather than merely state answers.

## 3. Length envelope

The default validator accepts:

```text
50,000 <= characters per credit <= 90,000
```

The envelope can be overridden for another institutional profile:

```bash
MIN_CHARS_PER_CREDIT=40000 \
MAX_CHARS_PER_CREDIT=100000 \
./Open_University_TM.sh ...
```

The validator measures Unicode characters rather than claiming equivalence with words, pages, contact hours, or any particular university's current credit rule.

## 4. Source protocol

A source pack is a UTF-8 text file containing one verified bibliographic source per non-comment line. The generator numbers the entries internally:

```text
[SRC:1] ...
[SRC:2] ...
```

AI output is instructed to cite only these markers. A citation marker is mechanically valid only when its integer refers to an existing source-pack entry.

If a factual claim is not supported by the supplied pack, the generator instructs the model to append:

```text
[SOURCE NEEDED]
```

This yields two distinct residuals:

```text
STRUCTURAL_RESIDUAL
ACADEMIC_RESIDUAL
```

`STRUCTURAL_RESIDUAL=0` means the machine-checkable format, objective-count, length and reversible-byte checks passed.

`ACADEMIC_RESIDUAL=0` means a nonempty source pack was supplied, no invalid source IDs were used, and no `[SOURCE NEEDED]` markers remain.

It does **not** prove semantic entailment between every citation and every claim. That stronger task requires source inspection and, where appropriate, scholarly review.

## 5. Publication states

The generator distinguishes:

```text
DRAFT
PUBLISHABLE
```

A structurally compliant output may be saved as `DRAFT` when source grounding is incomplete. With:

```bash
STRICT_SOURCES=1
```

an academic residual prevents writing the course at all.

## 6. Zero-residual interpretation

The formal acceptance state is:

\[
\Delta_{course}=(\Delta_{structure},\Delta_{academic}).
\]

The strongest machine state is:

\[
\Delta_{course}=(0,0).
\]

This is a specification-level fixed point: it means the encoded artifact satisfies the validator's explicit rules. It does not imply that every proposition in the course is universally true, that the course is absolutely complete, or that human educational judgment is unnecessary.

## 7. Open-system rule

The standard is intentionally revisable:

```text
OPEN=true
FINAL=false
```

New disciplines, assessment models, accessibility rules, citation systems, or institutional profiles can be added without treating the present specification as universally final.
