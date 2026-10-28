# ADMBD — Ride-Hailing Platform (TVDE)

**Academic year:** 2026/2027  
**Institution:** Instituto Superior de Engenharia do Porto (ISEP)  
**Course:** Database Administration (ADMBD)  
**Project repository:** [ADMBD_1221715_1131504](https://github.com/LadyCiaradh/ADMBD_1221715_1131504)

## 1. Project Overview

This academic project specifies a **Ride-Hailing Platform (TVDE)** that connects passengers and drivers and manages vehicles, trip requests, assignments, trip lifecycles, payments, ratings, and operational information.

The primary focus is **database administration**. The proposed solution adopts **polyglot persistence**, using PostgreSQL for authoritative transactional and business data and MongoDB for selected operational data, such as driver locations, trip events, and notifications.

The work is divided into two iterations:

- **Iteration 1 — Specification and Planning:** requirements, technology selection, database models, deployment analysis, backup and recovery policy, and scalability and elasticity planning.
- **Iteration 2 — Implementation and Validation:** implementation of the proposed database solution, administration and security configuration, workload testing, tuning, and backup/recovery validation.

## 2. Project Team

| Student number | Student |
|---|---|
| 1221715 | Jorge Cruz |
| 1131504 | Joana Soares |

*The final team roster must be checked against the course's group requirements before submission.*

## 3. Selected Technologies and Deployment Plans

| Component | Technology | Intended role |
|---|---|---|
| Backend | Django (Python) | Business logic and integration with both databases |
| Relational DBMS | PostgreSQL | Passengers, drivers, vehicles, trips, payments, and ratings |
| Non-relational DBMS | MongoDB | Driver locations, trip events, and notifications |
| Local prototype | Docker Compose (planned) | Reproducible environment for development and tests |
| Proposed target environment | Microsoft Azure | Cloud deployment with managed application and database services |

The target architecture discussed in the documentation considers **Azure Container Apps**, **Azure Database for PostgreSQL**, and **Azure Cosmos DB for MongoDB**. These are **design proposals**, not services claimed to be deployed in Iteration 1.

## 4. Current Repository Structure

The following structure reflects the files currently available in the repository:

```text
ADMBD_1221715_1131504/
├── README.md
└── docs/
    └── iteration1/
        ├── README.md
        ├── 01-project-description-requirements.md
        ├── 02-database-technologies.md
        ├── 03-database-models.md
        ├── 04-deployment-architecture.md
        ├── 05-backup-policy.md
        ├── 06-scalability-elasticity.md
        ├── 07-generative-ai.md
        └── diagrams/
            ├── relational-model.dbml
            ├── relational-model.png
            ├── mongodb-model.dbml
            ├── mongodb-model.png
            ├── deployment-architecture.png
            ├── prototype-deployment.png
            ├── deployment.png
            ├── target-cloud-architecture.png
            ├── backup-recovery-strategy.png
            └── scalability-strategy.png
```

## 5. Iteration 1 — Documentation

All seven Iteration 1 documentation sections are available in Markdown:

1. [Project Description and Requirements](docs/iteration1/01-project-description-requirements.md) — domain, actors, use cases, data requirements, and expected workloads.
2. [Selection of Database Technologies](docs/iteration1/02-database-technologies.md) — PostgreSQL and MongoDB selection, rationale, and alternatives.
3. [Database Models Specification](docs/iteration1/03-database-models.md) — relational entities, MongoDB documents, relationships, and constraints.
4. [Deployment and Architecture Analysis](docs/iteration1/04-deployment-architecture.md) — local prototype, cloud/on-premises comparison, and proposed Azure architecture.
5. [Backup Policy Specification](docs/iteration1/05-backup-policy.md) — backup, retention, restoration, and recovery objectives.
6. [Scalability and Elasticity Plan](docs/iteration1/06-scalability-elasticity.md) — workload growth, scaling strategies, and trade-offs.
7. [Use of Generative AI Tools](docs/iteration1/07-generative-ai.md) — declaration of AI assistance and team validation.

See the [Iteration 1 documentation index](docs/iteration1/README.md) for direct links to the technical diagrams and their editable DBML sources.

## 6. Project Status and Next Steps

**Current phase:** Iteration 1 — specification and planning.

- **Iteration 1 deadline:** November 8, 2026.
- **Iteration 2 deadline:** December 18, 2026.

The repository currently contains the design documentation and diagrams. The application, database scripts, administration scripts, and validation results are planned for later development.

The anticipated directories for this work are:

```text
docs/iteration2/
src/django/
database/sql/
database/nosql/
scripts/
```

**These directories do not yet exist in the current repository.** Their structure may be refined during implementation.

At the end of Iteration 1, the exact submitted version must be identified by a Git tag named `iteration1`, with the report generated from the repository's editable documentation.

## 7. Use of Generative AI

As described in [Section 7](docs/iteration1/07-generative-ai.md), ChatGPT was used as a supporting tool for language review, brainstorming during team discussions, and digitization of diagrams initially drawn by the team. The group reviewed these outputs and retained responsibility for technical decisions and submitted artefacts.

## 8. Academic Scope

This repository is maintained for academic purposes as part of the ADMBD course at ISEP. The objective is to apply database administration principles to a realistic application scenario, not to deliver a complete commercial ride-hailing service.
