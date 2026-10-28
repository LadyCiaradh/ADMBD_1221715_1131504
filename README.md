# ADMBD_1221715_1131504

**Academic Year:** 2026/2027  
**Institution:** ISEP  
**Course:** ADMBD
**Project:** Ride-Hailing Platform (TVDE)  
**Repository:** [ADMBD_1221715_1131504](https://github.com/LadyCiaradh/ADMBD_1221715_1131504)

## 1. Project Overview

This project is developed as part of the Database Administration course at ISEP.

The objective is to design and develop a Ride-Hailing Platform (TVDE) that connects passengers with drivers and supports the management of trips, vehicles, payments, ratings, and operational information.

The project adopts a **polyglot persistence architecture**, combining relational and non-relational database management systems to address different data consistency, storage, and workload requirements.

The project is organized into two iterations:

- **Iteration 1 — Specification and Planning:** Requirements analysis, database technology selection, conceptual data models, deployment architecture, backup policy, and scalability planning.
- **Iteration 2 — Implementation and Validation:** Database implementation, administration, security configuration, performance evaluation, backup and recovery testing, and demonstration.

## 2. Project Team

| Student Number | Student Name |
|---|---|
| 1221715 | Jorge Cruz |
| 1131504 | Joana Soares |
| [Student number] | [Full name] |


## 3. Technology Stack

The following technologies have been selected for the project:

| Component | Technology | Purpose |
|---|---|---|
| Backend | Django (Python) | Application logic and database integration |
| Relational DBMS | PostgreSQL | Transactional and business data |
| Non-relational DBMS | MongoDB | Operational data, driver locations, trip events and notifications |
| Prototype Deployment | Docker Compose | Local development and testing (planned) |


## 4. Current Repository Structure

The repository currently contains the project documentation and technical diagrams for Iteration 1.

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
```

The `diagrams/` directory contains database models in DBML and PNG formats, as well as deployment, backup, and scalability diagrams.

## 5. Iteration 1 — Documentation

The following documentation is currently available:

1. [Project Description and Requirements](docs/iteration1/01-project-description-requirements.md)
2. [Selection of Database Technologies](docs/iteration1/02-database-technologies.md)
3. [Database Models Specification](docs/iteration1/03-database-models.md)
4. [Deployment and Architecture Analysis](docs/iteration1/04-deployment-architecture.md)
5. [Backup Policy Specification](docs/iteration1/05-backup-policy.md)
6. [Scalability and Elasticity Plan](docs/iteration1/06-scalability-elasticity.md)
7. [Use of Generative AI Tools](docs/iteration1/07-generative-ai.md)

Additional documentation:

- [Iteration 1 Documentation Index](docs/iteration1/README.md)
- [Technical Diagrams](docs/iteration1/diagrams/)


## 6. Planned Repository Structure

During Iteration 2, the repository is expected to be extended with the following directories:

```text
docs/
└── iteration2/

src/
└── django/

database/
├── sql/
└── nosql/

scripts/
```

These directories are **planned and are not yet part of the current repository**.

Their intended purposes are:

- `docs/iteration2/` — Implementation, testing, and evaluation documentation.
- `src/django/` — Django backend source code.
- `database/sql/` — Relational database scripts and related artefacts.
- `database/nosql/` — Non-relational database scripts and related artefacts.
- `scripts/` — Database administration, automation, backup, and recovery scripts.

The directory structure may evolve according to the implementation requirements.

## 7. Project Status

**Current phase:** Iteration 1 — Specification and Planning.

**Iteration 1 deadline:** November 8, 2026  
**Iteration 2 deadline:** December 18, 2026

The current documentation describes the initial design decisions. Implementation and technical validation are planned for Iteration 2.

At the end of Iteration 1, the submitted repository version will be identified using the Git tag `iteration1`.

## 8. Project Scope

The implementation will focus on database administration rather than the development of a complete commercial ride-hailing application.

The main areas of work include:

- Database design and data integrity.
- SQL and NoSQL database administration.
- Security and access control.
- Database performance and indexing.
- Backup and recovery procedures.
- Scalability and availability planning.
- Workload analysis and technical validation.
