# Intent-Based RAN Energy Efficiency Blueprint

[![Reproducible](https://img.shields.io/badge/Reproducible-Yes-success.svg)](#)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/athpra/intent-based-ran-energy-optimization.svg?style=social&label=Star)](https://github.com/athpra/intent-based-ran-energy-optimization)


<p align="center">
        <img src="image/icon.png" width="550" height="350" alt="RAN Optimization Logo" />
</p>



Closed-Loop RAN Energy Optimization using VIAVI TeraVM AI RAN Scenario Generator (AI RSG) and Cloudera AI Model Endpoints

> **Based on** the original [NVIDIA Intent-Based RAN Energy Efficiency Blueprint](https://github.com/VIAVI-CTOO/es-blueprint-rsg) by VIAVI Solutions and NVIDIA, adapted to use [Cloudera AI](https://www.cloudera.com/products/machine-learning.html) for LLM hosting via an OpenAI-compatible inference endpoint.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Problem Statement](#problem-statement)
- [System Architecture](#system-architecture)
- [Agent Architecture](#agent-architecture)
  - [Planner Agent](#planner-agent)
  - [Validation Agent](#validation-agent)
- [Closed-Loop Execution Flow](#closed-loop-execution-flow)
- [Demo](#demo)
- [Repository Structure](#repository-structure)
- [Requirements](#requirements)
- [Setup Instructions](#setup-instructions)
- [Running the Notebook](#running-the-notebook)
- [Operator Intent Input](#operator-intent-input)
- [Output](#output)
- [Troubleshooting](#troubleshooting)
- [Purpose](#purpose)
- [References](#references)
- [Contributors](#contributors)
- [Disclaimer](#disclaimer)

## Overview

The Intent-Based RAN Energy Efficiency Blueprint provides a simulation-validated framework for evaluating AI-driven energy optimization strategies in 5G Radio Access Networks (RAN).

This blueprint integrates:
- VIAVI RAN Scenario Generator (AI RSG)
- VIAVI ADK simulation environment
- Cloudera AI-hosted Large Language Models via an OpenAI-compatible inference endpoint
- Closed-loop Planner and Validation agent architecture

The system simulates network behavior, generates energy-saving actions, validates those actions against QoS constraints, and applies safe optimizations iteratively.

This enables engineering teams to evaluate AI-assisted network control policies before deployment.

## Key Features

- **Intent-based optimization**: operators specify QoS targets in natural language; the system translates intent into concrete network actions
- **Dual-LLM closed loop**: a Planner LLM proposes energy-saving actions, a Validator LLM reviews and approves each action before it is applied
- **Simulation-backed safety**: every candidate action is tested in the VIAVI AI RSG simulator — no action is applied without first passing simulation
- **Model-agnostic**: compatible with any OpenAI-compatible LLM endpoint (Cloudera AI Inference, NVIDIA NIM, OpenAI, and others)
- **Private AI by design**: LLM inference runs entirely on Cloudera AI, keeping sensitive network telemetry inside your environment

## Problem Statement

Reducing RAN energy consumption while maintaining strict Quality of Service (QoS) guarantees is a critical engineering challenge. Aggressive energy-saving techniques, such as cell sleeping, can negatively impact throughput and user experience if applied incorrectly. This blueprint evaluates AI-generated energy optimization actions in a validated simulation loop to ensure:
- Energy efficiency improvements
- QoS preservation
- Safe and controlled optimization

## System Architecture

![System Architecture](image/image001.jpeg)

The system operates as a closed-loop optimization pipeline. Each iteration loads current network KPIs, generates candidate energy-saving actions via the Planner Agent, simulates their impact using VIAVI AI RSG, validates them through the Validation Agent, and applies the approved actions before advancing to the next simulation interval.

## Agent Architecture

### Planner Agent

The Planner Agent generates candidate energy-saving actions.

**Inputs:**
- Network KPIs
- Cell activity and sleep state
- Throughput and utilization
- Operator intent
- QoS constraints

**Output:**
- Proposed sleep/wake actions

**Objective:**

Maximize energy efficiency while satisfying operator-specified QoS intent. Action selection is driven by LLM reasoning over current network state rather than a fixed mathematical objective function.

### Validation Agent

The Validation Agent ensures safety and QoS compliance.

**Responsibilities:**
- Evaluate Planner recommendations
- Reject unsafe or QoS-violating actions
- Approve valid actions
- Ensure network stability

The Validation Agent acts as a safety layer before any action is applied.

## Closed-Loop Execution Flow

Each iteration performs:

1. Load network state and KPIs
2. Generate candidate actions using Planner Agent
3. Simulate proposed actions using VIAVI AI RSG
4. Validate actions using Validation Agent
5. Apply validated actions
6. Record KPIs and system state
7. Advance simulation time

This creates a validated continuous optimization loop.

## Demo

The notebook produces iteration-by-iteration logs showing planner proposals, validator decisions, and applied network state:

![Closed-loop run results](notebooks/closed_loop_results_nextloopcheckmissing.png)

Each run generates a timestamped output folder with per-iteration KPI summaries, decision logs, and structured data files for downstream analysis. See the [Output](#output) section for details.

## Repository Structure

```
es-blueprint-rsg/
│
├── notebooks/
│   └── es_blueprint_poc.ipynb      # Main PoC notebook
│
├── data/
│   ├── UEReports.csv
│   └── CellReports.csv
│
├── ai_rsg_config/
│   └── config.conf
│
├── output/                         # Simulation results (gitignored)
│
├── .env.example
├── requirements.txt
├── setup.sh
├── run.sh
└── README.md
```

## Requirements

- Python 3.10 or newer
- Jupyter Notebook or Jupyter Lab
- Access to a VIAVI AI RSG instance (see [VIAVI AI RSG Setup](#4-connect-to-a-viavi-ai-rsg-instance))
- A running Cloudera AI model endpoint (any OpenAI-compatible LLM)

### Supported models

Any model deployed on Cloudera AI Inference Service works. Tested with:

| Model | Parameters | Notes |
|---|---|---|
| `nvidia/nemotron-3-super-120b-a12b` | 120B LatentMoE | recommended |
| `Qwen/Qwen2.5-7B-Instruct` | 7B | Lightweight |
| `Qwen/Qwen2.5-Coder-7B-Instruct` | 7B | Code-tuned; strong SQL generation |

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/athpra/intent-based-ran-energy-optimization.git
cd intent-based-ran-energy-optimization
```

### 2. Run setup script

```bash
./setup.sh
```

This creates a virtual environment and installs dependencies.

Activate environment:

```bash
source .venv/bin/activate
```

Install VIAVI ADK package (requires authorized access):

```bash
pip install http://<rsg-host>:8000/adk
```

### 3. Configure Cloudera AI credentials

Copy the example file and fill in your values:

```bash
cp .env.example .env
```

Edit `.env`:

```
CDSW_API_URL=https://<your-cml-domain>/namespaces/serving-default/endpoints/<endpoint-name>/v1
CDSW_API_KEY=<your-api-key>
LLM_MODEL=Qwen/Qwen2.5-Coder-7B-Instruct
```

**On Cloudera ML Workbench**, `CDSW_API_URL` and `CDSW_API_KEY` can also be configured as project-level environment variables via **CML UI → Project Settings → Environment Variables** — these are injected automatically at session start and take precedence over `.env` values.

**Getting `CDSW_API_URL`:** Cloudera AI → AI Inference Service → click your endpoint → copy the Endpoint URL (add `/v1` suffix if not present).

**Getting `CDSW_API_KEY`:** In a CML workbench terminal run `echo $CDSW_APIV2_KEY`, or go to CML UI → User Settings → API Keys → Create API Key.

| Variable | Description |
|---|---|
| `CDSW_API_URL` | Full URL of the Cloudera AI model endpoint (`/v1` suffix required) |
| `CDSW_API_KEY` | Cloudera AI API key for the endpoint |
| `LLM_MODEL` | Model name as registered in the endpoint |
| `AUTH_MODE` | `jwt` (CML workbench, default) or `api_key` (external endpoints) |

> **On Cloudera ML Workbench:** the notebook reads a fresh token from `/tmp/jwt` (auto-refreshed by the platform) when `AUTH_MODE=jwt`, so tokens stay valid across long simulation runs.

### 4. Connect to a VIAVI AI RSG instance

This blueprint requires access to a running VIAVI TeraVM AI RAN Scenario Generator (AI RSG) instance with a valid ADK license (TVM6238).

**Getting access:**
Contact VIAVI Solutions at [IB_ES_blueprint@viavisolutions.com](mailto:IB_ES_blueprint@viavisolutions.com) to request access to an AI RSG instance.

**Verifying connectivity:**
Once you have an RSG host address, confirm it is reachable:

```bash
curl http://<rsg-host>:8000/status
```

A successful response returns a JSON object with container counts and an RSG container address.

**Configuring the connection:**
By default, the notebook auto-discovers the RSG container from `RSG_HOST`. Add to `.env` to override:

```
RSG_HOST=<your-rsg-host-ip>
RSG_ADDRESS=http://<host>:<port>/c/<hash>/   # optional: full container URL override
```

## Running the Notebook

Launch Jupyter:

```bash
./run.sh
```

Open:

```
notebooks/es_blueprint_poc.ipynb
```

Run all cells sequentially.

### Expected Successful Startup Output

You should see:

```
✓ Credentials configured (.env found)
✓ LLM sanity check passed (model: Qwen/Qwen2.5-Coder-7B-Instruct)
```

If these messages appear, the system is correctly configured.

## Operator Intent Input

The notebook accepts operator QoS intent. Examples:

```
Keep QoS above 5 Mbps
>= 4.5 Mbps
6 Mbps
5
```

## Output

Each run creates a timestamped folder under `output/run_<timestamp>_<model>/` containing:

- `closed_loop.txt` — full iteration log with timings and decisions
- `summary.csv` — per-iteration KPI summary (sleeping cells, throughput, latency)
- `*.parquet` — structured data for downstream analysis

These results allow engineers to evaluate optimization strategies across models and configurations.

## Troubleshooting

### LLM sanity check failed — 401 Unauthorized

**Cause:**
Missing or expired API key.

**Solution:**

- In a CML terminal, refresh the key in `.env`:

```bash
python3 -c "
import re, os
key = os.environ.get('CDSW_APIV2_KEY','').strip()
txt = open('/home/cdsw/.env').read()
txt = re.sub(r'^CDSW_API_KEY=.*', f'CDSW_API_KEY={key}', txt, flags=re.MULTILINE)
open('/home/cdsw/.env','w').write(txt)
print(f'Updated ({len(key)} chars)')
"
```

- Restart the kernel and re-run all cells.

### LLM sanity check failed — 503 Service Unavailable

**Cause:**
The model endpoint is stopped or the vLLM backend process is not running.

**Solution:**

- Go to **CML → AI Inference Service** → find the endpoint → **Restart**.
- Wait 2–5 minutes for model weights to load, then re-run.

### LLM sanity check failed — model not found

**Cause:**
`LLM_MODEL` in `.env` does not match the model name registered in the endpoint.

**Solution:**

- Check the exact model name shown in CML → AI Inference Service → your endpoint.
- Update `LLM_MODEL` in `.env` to match exactly, then restart the kernel.

### ADKError: ADK is not licensed — TVM6238 required

**Cause:**
The VIAVI RSG server does not have the ADK license (TVM6238) installed or active.

**Solution:**

- Contact the RSG administrator to verify that TVM6238 is active on the server.
- If the RSG server was recently restarted, licenses may need to be re-applied.

### Missing data files

Ensure these files exist:

```
data/UEReports.csv
data/CellReports.csv
```

## Purpose

This blueprint provides a research and engineering framework for:

- Evaluating AI-driven energy optimization
- Testing network control policies safely
- Simulating RAN energy optimization scenarios
- Validating AI-assisted network automation

## References

- Fransiscus, B. et al. (2025). [Intent-Based RAN Energy Efficiency Blueprint](https://arxiv.org/pdf/2507.14230). *arXiv preprint arXiv:2507.14230*.

## Contributors

**Original blueprint (VIAVI Solutions & NVIDIA):**

1. [Ari Uskudar](https://www.linkedin.com/in/ari-u-628b30148/) — NVIDIA
2. [Bimo Fransiscus](https://www.linkedin.com/in/fransiscusbimo/) — CTO Office, VIAVI Solutions
3. [Mahdi Sharara](https://www.linkedin.com/in/mahdisharara/) — CTO Office, VIAVI Solutions
4. [Georgy Myagkov](https://www.linkedin.com/in/georgy-myagkov-03a2486) — Wireless R&D, VIAVI Solutions

For blueprint related questions: [IB_ES_blueprint@viavisolutions.com](mailto:IB_ES_blueprint@viavisolutions.com)

**Cloudera AI adaptation:**

5. [Athul Prasad](https://www.linkedin.com/in/athul-prasad/) — Applied AI, Cloudera

## Disclaimer

*This Intent-Based RAN Energy Efficiency Blueprint is intended for Proof-of-Concept and research use only. It is not designed for production deployment. Use in production environments is at the user's own risk. The authors and contributors accept no liability for operational impacts or damages.*
