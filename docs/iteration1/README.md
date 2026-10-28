# ADMBD — Iteration 1: Specification and Planning

**Project:** Ride-Hailing Platform (TVDE)  
**Academic year:** 2026/2027  
**Course:** Database Administration (ADMBD), ISEP  
**Submission deadline:** November 8, 2026

[Back to the main project README](../../README.md)

## Overview

Iteration 1 defines the requirements and initial technical approach for a Ride-Hailing Platform. The project uses **PostgreSQL** as the authoritative store for business and transactional data and **MongoDB** for selected operational information, including driver locations, trip events, and notifications.

The purpose of this iteration is to document and justify the proposed solution. Implementation, workload measurements, and recovery testing are planned for Iteration 2.

## Documentation Index

| Section | Document | Main content |
|---|---|---|
| 1 | [Project Description and Requirements](01-project-description-requirements.md) | Application domain, motivation, actors, use cases, requirements, and workloads |
| 2 | [Selection of Database Technologies](02-database-technologies.md) | PostgreSQL/MongoDB roles, rationale, and alternatives |
| 3 | [Database Models Specification](03-database-models.md) | SQL entities, NoSQL collections, data ownership, relationships, and constraints |
| 4 | [Deployment and Architecture Analysis](04-deployment-architecture.md) | Local prototype, on-premises versus cloud, proposed deployment, and availability |
| 5 | [Backup Policy Specification](05-backup-policy.md) | SQL/NoSQL backups, retention, recovery strategy, RPO, and RTO |
| 6 | [Scalability and Elasticity Plan](06-scalability-elasticity.md) | Workload growth, vertical/horizontal scaling, replication, and trade-offs |
| 7 | [Use of Generative AI Tools](07-generative-ai.md) | Language review, brainstorming, diagram digitization, and human validation |

## Technical Diagrams

The diagrams in [`diagrams/`](diagrams/) support the specifications above.

| Topic | Files |
|---|---|
| PostgreSQL relational model | [Diagram](diagrams/relational-model.png) · [Editable DBML](diagrams/relational-model.dbml) |
| MongoDB document model | [Diagram](diagrams/mongodb-model.png) · [Editable DBML](diagrams/mongodb-model.dbml) |
| Initial system architecture | [Deployment architecture](diagrams/deployment-architecture.png) |
| Local prototype | [Prototype deployment](diagrams/prototype-deployment.png) |
| Proposed cloud deployment | [Deployment](diagrams/deployment.png) · [Target cloud architecture](diagrams/target-cloud-architecture.png) |
| Backup and recovery | [Backup/recovery strategy](diagrams/backup-recovery-strategy.png) |
| Scalability | [Scalability strategy](diagrams/scalability-strategy.png) |

The DBML files contain editable representations of the database models. Architecture, backup, and scalability images describe **planned designs**, not completed production deployments.

## Design Summary

- **PostgreSQL:** the source of truth for passengers, drivers, vehicles, trips, payments, and ratings.
- **MongoDB:** operational driver location records, trip events, and notifications, with logical references to PostgreSQL identifiers.
- **Backend:** a Django application is planned to manage business logic and interact with both databases.
- **Prototype:** a local environment using Docker Compose is proposed for the implementation and validation work.
- **Target architecture:** cloud deployment with Microsoft Azure services is discussed as a production-oriented option.
- **Recovery and growth:** separate backup and scaling strategies are defined for PostgreSQL and MongoDB.

## Iteration 1 Deliverables

The Iteration 1 submission requires a PDF report generated from editable documentation, a GitHub repository archive corresponding to the `iteration1` tag, and the required group self-evaluation.

The `iteration1` tag should only be created after the Iteration 1 documents and diagrams have been finalized.

[Return to the repository overview](../../README.md)
