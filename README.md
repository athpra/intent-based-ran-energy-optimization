# Intent-Based RAN Energy Efficiency Blueprint

Closed-Loop RAN Energy Optimization using VIAVI TeraVM AI RAN Scenario Generator (AI RSG) and NVIDIA LLM Agents

## Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [System Architecture](#system-architecture)
- [Agent Architecture](#agent-architecture)
  - [Planner Agent](#planner-agent)
  - [Validation Agent](#validation-agent)
- [Closed-Loop Execution Flow](#closed-loop-execution-flow)
- [Repository Structure](#repository-structure)
- [Requirements](#requirements)
- [Setup Instructions](#setup-instructions)
- [Running the Notebook](#running-the-notebook)
- [Operator Intent Input](#operator-intent-input)
- [Output](#output)
- [Troubleshooting](#troubleshooting)
- [Purpose](#purpose)
- [Contributors](#contributors)
- [Disclaimer](#disclaimer)

## Overview

The Intent-Based RAN Energy Efficiency Blueprint provides a simulation-validated framework for evaluating AI-driven energy optimization strategies in 5G Radio Access Networks (RAN).

This blueprint integrates:
- VIAVI RAN Scenario Generator (AI RSG)
- VIAVI ADK simulation environment
- NVIDIA-hosted Large Language Models (LLMs)
- Closed-loop Planner and Validation agent architecture

The system simulates network behavior, generates energy-saving actions, validates those actions against QoS constraints, and applies safe optimizations iteratively.

This enables engineering teams to evaluate AI-assisted network control policies before deployment.


## Problem Statement

Reducing RAN energy consumption while maintaining strict Quality of Service (QoS) guarantees is a critical engineering challenge.

Aggressive energy-saving techniques, such as cell sleeping, can negatively impact throughput and user experience if applied incorrectly.

This blueprint evaluates AI-generated energy optimization actions in a validated simulation loop to ensure:
- Energy efficiency improvements
- QoS preservation
- Safe and controlled optimization

## System Architecture

![System Architecture](image/image001.jpeg)

The system operates as a closed-loop optimization pipeline:

```
UEReports + CellReports
        |
        v
KPI Processing Layer
        |
        v
State Store (SQL + LoopState)
        |
        v
Planner Agent (LLM)
  Generate energy-saving actions
        |
        v
AI RSG Simulation
  Evaluate impact of proposed actions
        |
        v
Validation Agent (LLM)
  Approve / reject / modify actions
        |
        v
AI RSG Simulation 
  Apply approved actions
        |
        v
Updated Network State 
        |
        v
Next Iteration
```

Each iteration represents one simulation interval.

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

Maximize energy efficiency while maintaining QoS.

### Validation Agent

The Validation Agent ensures safety and QoS compliance.

**Responsibilities:**
- Evaluate Planner recommendations
- Reject unsafe or QoS-violating actions
- Approve valid actions
- Ensure network stability

The Validation Agent acts as a safety layer.

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
├── output/                         # Simulation results
│
├── .env.example
├── requirements.txt
├── setup.sh
├── run.sh
└── README.md
```

## Requirements

System requirements:

- Python 3.10 or newer
- Jupyter Notebook or Jupyter Lab
- Access to VIAVI AI RSG instance
- NVIDIA API Key

Get your NVIDIA API key here: 

https://build.nvidia.com/settings/api-keys

## Setup Instructions

### 1. Clone the repository

   ```bash
   git clone https://github.com/VIAVI-CTOO/es-blueprint-rsg.git
   cd es-blueprint-rsg
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
pip install http://3.211.96.252:8000/adk
```

### 3. Configure NVIDIA API Key

   Create a `.env` file:

   ```
   NVIDIA_API_KEY=nvapi-xxxxxxxxxxxxxxxx
   ```
   
   Optional environment variables:

   | Variable | Description |
   |---|---|
   | `NVIDIA_API_KEY` | API key for NVIDIA AI endpoints |

## Running the Notebook

Launch Jupyter:

```bash
./run.sh
```

Open:

```
notebooks/es_blueprint_poc.ipynb
````

Run all cells sequentially.

### Expected Successful Startup Output

You should see:

```
✓ NVIDIA_API_KEY loaded (hidden)
✓ LLM sanity check passed
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

The system produces:

- Planner Agent recommendations
- Validation decisions
- Applied energy-saving actions
- QoS and throughput metrics
- Iteration summaries

These results allow engineers to evaluate optimization strategies.

## Troubleshooting

### NVIDIA_API_KEY error

**Cause:** 
Missing or invalid API key.

**Solution:** 

- Verify the key is set:

```bash
echo $NVIDIA_API_KEY
```

- Ensure the key is correctly configured in `.env`.

### LLM sanity check failed

- **Cause:** 
  - Invalid API key or network access issue.

- **Solution:** 
  - Verify API key and internet connectivity.

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

## Contributors

1. [Bimo Fransiscus](https://www.linkedin.com/in/fransiscusbimo/) — CTO Office, VIAVI Solutions
2. [Mahdi Sharara](https://www.linkedin.com/in/mahdisharara/) — CTO Office, VIAVI Solutions
3. [Georgy Myagkov](https://www.linkedin.com/in/georgy-myagkov-03a2486) —  Wireless R&D, VIAVI Solutions
4. [Ari Uskudar](https://www.linkedin.com/in/ari-u-628b30148/) — NVIDIA

For blueprint related questions send e-mail to: IB_ES_blueprint@viavisolutions.com 

## Disclaimer

*This Intent-Based RAN Energy Efficiency blueprint is intended for Proof-of-Concept and research use only. It is not designed for production deployment. Use in production environments is at the user's own risk. The authors and contributors accept no liability for operational impacts or damages.*