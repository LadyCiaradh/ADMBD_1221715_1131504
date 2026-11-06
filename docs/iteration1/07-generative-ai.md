# 7. Use of Generative AI Tools

## 7.1 Tool Used

ChatGPT created by OpenAI was one of the tools used as a helper in the first iteration of the Ride-Hailing Platform project.

## 7.2 Scope of Use and Validation

The following table summarises the tasks supported by ChatGPT and how its outputs were reviewed by the team.

| Purpose | Project artefacts or tasks | Review and validation |
|---|---|---|
| Writing and language correction: spelling, grammar and word choice improvements. | Written project documentation. | The team reviewed the changes to ensure that the original technical meaning was preserved. |
| Brainstorming: discussing possible approaches and alternatives to support decision-making. | Project planning and technical decision-making tasks. | The team evaluated suggestions against the project requirements. The evaluation of alternatives and final technical decisions remained the team’s responsibility. |
| Diagram digitization: converting manually drawn diagrams into a digital format without changing their structure. | Digital versions of manually drawn project diagrams. | The team compared the digital diagrams with the original sketches to verify that their structure was preserved. |

Brainstorming: Help with discussion of possible approaches and alternatives during the decision-making process. However, alternative evaluation and technical decisions were made by the team.

Diagram digitization: Assistance in transferring manually drawn diagrams into a digital format without changing the structure.

For example to generate the image docs/iteration1/diagrams/deployment-architecture.png we used the manual draw (docs/interaction1/diagrams/deployment-architecture_draw.png) with the following prompt:

"With Diagram.io style on mind create a professional technical architecture diagram for TVDE (Ride-Hailing Platform). Three client applications should be included in the diagram: Passenger App (Web/Mobile), Driver App (Web/Mobile), and Admin/Support (Web).

These three client applications send and receive communication requests to/from Django REST API backend using HTTPS protocol.

Django backend is in charge of performing business logic, performing authentication, and working as a data access layer.

Django backend is connected to two types of databases:

PostgreSQL (SQL) stores relational entities such as Passenger, Driver, Vehicle, DriverVehicle, Trip, Payment, and Rating.

MongoDB (NoSQL) stores document collections such as driver_locations, trip_events, and notifications.

Label the communication with PostgreSQL database as "SQL" and communication with MongoDB database as "MongoDB Driver".

Make sure your diagram uses hierarchical structure with client applications on the top level, Django backend at the center, and two databases on the bottom level. Use directional arrows, different component colors, and academic-style design."


## 7.3 Review and Validation

All outputs assisted with AI were reviewed by the team before being included into the project.

Changes in language were verified to make sure that technical meaning had not been changed. Brainstorming suggestions were evaluated in regard to project requirements, and digital diagrams were compared with manual sketches to check if they were correct.

Team was responsible for design, technical decisions, documentations and outputs of the project.

## 7.4 Responsibility and Limitations

The usage of ChatGPT does not substitute the team's liability concerning the design, development, documenting and verification of the project.

The full responsibility for the quality, safety, correctness, consistency and technical adequacy of all the artefacts submitted by the team falls upon the team members, whether some of the artefacts have been generated or improved using GenAI technologies.

ChatGPT was used as an additional source. The ultimate decision-making process concerning the project architecture and technical solutions was made by the team itself.


