# WORK IN PROGRESS!!!

# AIDDEV  
Ascension Integrated Developer Environment (In‑Game)

AIDDEV is the ingame IDE for Ascension addon developers.  
It provides a unified interface for **static analysis**, **runtime diagnostics**, and **developer tooling**, all inside the WoW client.

AIDDEV is the *consumer* layer in the three addon toolchain:

AIDDEV_Companion → AIDDEV_DevTools → AIDDEV

AIDDEV never loads files directly from disk.  
It only consumes **validated, normalized project data** provided by the Companion and approved by DevTools.

---

## Features

### ✔ Static Analysis
- Project browser  
- File viewer  
- AST based handler signature inference  
- Static diagnostics (ruleset‑driven)

### ✔ Runtime Diagnostics
- Live function call tracking  
- Error tracking  
- Argument pattern analysis  
- Snapshot system  
- Diffing (snapshot vs now, previous session vs now)  
- Per‑function drill‑down diff  
- Color‑coded severity output  
- Live monitor window

### ✔ Integrated DevTools Access
AIDDEV includes a **Run DevTools** button that triggers pre‑flight validation before loading a project.

### ✔ Environment Banner
Shows metadata provided by AIDDEV_Companion:
- Realm  
- Ruleset  
- Client build  
- Encoding  
- Line endings  

---

## How AIDDEV Works

AIDDEV does **not** load or validate projects.  
Instead, it relies on:

### 1. AIDDEV_Companion  
Provides:
- Project files  
- Environment metadata  

### 2. AIDDEV_DevTools  
Validates:
- Syntax  
- Encoding  
- TOC/environment  
- Line endings  
- Fatal/non‑fatal rule taxonomy  

Only after DevTools approves the project does AIDDEV load it.

---

## How to Use AIDDEV

### Open AIDDEV

/aiddev

### Tabs

#### **Static Analysis**
Browse project files, inspect content, and view static diagnostics.

#### **Runtime Diagnostics**
Analyze runtime behavior:
- Take snapshots  
- Diff snapshots  
- Compare with previous session  
- Drill into specific functions  
- Monitor live calls  

### Live Monitor

/aiddevlive

## When to Use AIDDEV

Use AIDDEV when you want to:

- Inspect your addon’s source code in‑game  
- Compare static expectations vs runtime behavior  
- Debug event handlers, message handlers, and UI callbacks  
- Track argument patterns and runtime anomalies  
- Capture snapshots before/after gameplay scenarios  
- Validate that your addon behaves deterministically  

AIDDEV is the **analysis layer**, not the validation layer.

---

## Requirements

- AIDDEV_Companion  
- AIDDEV_DevTools  
- Ascension client  
