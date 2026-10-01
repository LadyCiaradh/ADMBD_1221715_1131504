# 1. Project Description and Requirements

## 1.1 Application Domain
This system is Ride-Hailing Platform which is designed for transportation of individual passenger, and it is based on the operational model of TVDE (Transport in an Uncharacterized Vehicle from an Electronic Platform) services.
The platform creates digital environment, which allows to connect passengers, who need transportation services, with drivers and their vehicles.
Passengers may request the trips with the specified pickup point and destination, while drivers may accept such requests.
The trip is going through its life cycle which includes request and assignment of a driver, passenger pickup, execution of the trip, its end and payment. Within this process, the platform should deal with transactional information and information generated continuously during the service.
Therefore, this system contains both stable information with high structure (passenger accounts, drivers, vehicles, trips and payments) and dynamic information (availability of drivers, geolocation of passengers, events generated during the trip).
The application will be developed with Django framework as a main application framework. Polyglot persistence approach will be used in order to develop the database architecture. It means that various database technologies may be used depending on the type of the data.

## 1.2 Motivation
A ride-hailing service is a pertinent case study with respect to the administration of databases because it involves the concomitant management of transactional, spatial and high frequency data.
The core processes of business operations, which include user registration, vehicle registration, creation of trips, allocation of drivers, payment registration and rating submissions, entail consistency and data integrity. However, at the same time, the system should process volatile data including the availability and location of drivers and events during the course of a trip.
The coexistence of these different aspects of the data make it a particularly appropriate setting to examine a polyglot persistence architecture that uses relational and non-relational databases as per the needs.
The system also allows one to examine the issue of indexing, concurrent access, transactions, scalability, database growth, backups and recovery, availability and scaling.
For all these reasons, the domain of ride-hailing services offers enough complexity to examine database design and administration issues without being too complex for implementation in a prototype.

## 1.3 System Scope
The project concentrates on database and backend systems which are necessary to implement the primary life cycle for ride hailing system.
The prototype will cover:
- passenger management;
- driver management;
- vehicle management;
- driver availability;
- trip requests;
- driver assignment;
- trip lifecycle management;
- driver location information;
- payments;
- passenger and driver ratings;
- notifications;
- trip history;
- administrative operations.
Real payment gateway interface, route optimization, dynamic pricing algorithm, identity verification services, mobile applications and maps provided by third-party applications do not belong to the first iteration of the prototype.
If required, they can be implemented in simulated form to have corresponding database operations performed and tested.

## 1.4 Main Actors
### Passenger
The passenger can:
- manage their account and profile;
- request a trip;
- define pickup and destination locations;
- cancel a trip when permitted;
- follow the current state of a trip;
- consult previous trips;
- consult payment information;
- rate a driver after a completed trip;
- receive notifications related to the requested service.

### Driver
The driver can:
- manage their profile;
- associate or use an authorized vehicle;
- change their availability status;
- update their current location;
- receive trip requests;
- accept or reject eligible requests;
- update the state of an assigned trip;
- consult completed trips;
- rate passengers;
- receive operational notifications.

### Administrator
The administrator can:
- manage passenger and driver accounts;
- manage registered vehicles;
- activate or suspend accounts when required;
- inspect trips and their current states;
- inspect payment records;
- access operational information required for platform management;
- investigate inconsistent or failed operations.

### Support Operator
The operator can:
- search for users and trips;
- inspect the lifecycle and relevant events of a trip;
- inspect payment status;
- consult relevant operational records;
- register or follow incidents associated with a trip.

## 1.5 Use Cases
| ID | Actor | Use Case |
|---|---|---|
| UC01 | Passenger | Register account |
| UC02 | Passenger | Manage profile |
| UC03 | Passenger | Request trip |
| UC04 | Passenger | Cancel trip |
| UC05 | Passenger | View trip status |
| UC06 | Passenger | View trip history |
| UC07 | Passenger | Rate driver |
| UC08 | Driver | Manage profile |
| UC09 | Driver | Manage availability |
| UC10 | Driver | Update current location |
| UC11 | Driver | Receive trip request |
| UC12 | Driver | Accept/reject trip |
| UC13 | Driver | Start trip |
| UC14 | Driver | Complete trip |
| UC15 | Driver | Rate passenger |
| UC16 | System | Register payment |
| UC17 | System | Generate notification |
| UC18 | Administrator | Manage users |
| UC19 | Administrator | Manage vehicles |
| UC20 | Administrator | Inspect trips/payments |
| UC21 | Support Operator | Investigate trip incident |

The core use case in this system is **Request Trip (UC03)**. The passenger inputs his/her pick-up location and destination, and a new trip request gets created. The system finds a suitable available driver and puts him/her in a position to accept the request.
When a driver accepts the request (UC12), the trip gets assigned to that particular driver and his/her current car. The trip will move through all its states till it gets either completed or cancelled.
During the course of the trip, many operational events and location data may be created at frequent intervals. When the trip gets completed, all the details of that particular trip get saved in the system and its related payment process is also noted. The passengers and drivers may rate the completed trips.

### Trip Lifecycle

A trip is expected to progress through a controlled set of states:
`REQUESTED → DRIVER_ASSIGNED → DRIVER_ARRIVING → IN_PROGRESS → COMPLETED`
A trip may transition to `CANCELLED` from an eligible state according to the business rules of the platform.
The trip state is considered critical business data. Invalid state transitions must therefore be prevented by the application and, whenever appropriate, reinforced through database constraints or transactional operations.

## 1.6 Functional Requirements

| ID | Requirement |
|---|---|
| FR01 | The system shall allow passengers to create and manage an account. |
| FR02 | The system shall allow drivers to maintain a driver profile. |
| FR03 | The system shall maintain information about vehicles authorized for use on the platform. |
| FR04 | The system shall allow drivers to change their availability status. |
| FR05 | The system shall receive and maintain the current location of available/active drivers. |
| FR06 | The system shall allow passengers to request a trip by specifying pickup and destination locations. |
| FR07 | The system shall associate a trip request with an eligible driver. |
| FR08 | The system shall allow a driver to accept or reject a trip request. |
| FR09 | The system shall maintain the lifecycle and current status of each trip. |
| FR10 | The system shall allow eligible trips to be cancelled. |
| FR11 | The system shall record the final price and payment information associated with a completed trip. |
| FR12 | The system shall allow passengers to consult their trip history. |
| FR13 | The system shall allow drivers to consult their trip history. |
| FR14 | The system shall allow passengers and drivers to rate each other after a completed trip. |
| FR15 | The system shall generate and store relevant notifications. |
| FR16 | The system shall record relevant operational events generated during a trip. |
| FR17 | Administrators shall be able to manage users, drivers and vehicles. |
| FR18 | Authorized administrative/support users shall be able to search and inspect trips and their associated operational information. |

## 1.7 Data Requirements
The platform must manage data with different consistency, persistence, access and scalability characteristics.

### Core Transactional Data
The system must persist structured information concerning:
- passengers;
- drivers;
- vehicles;
- driver–vehicle associations;
- trips;
- trip participants;
- trip status;
- pickup and destination information;
- trip timestamps;
- prices;
- payments;
- ratings.
This information represents the core business state of the platform.
Relationships between these records must remain consistent and the system must preserve referential integrity.

### Operational Data
The platform needs to handle operation data that will be produced at a much higher rate than the majority of transactional business information.
This includes:
- driver location updates;
- driver availability information;
- trip lifecycle events;
- notification data;
- operational metadata associated with active trips.
This data can be created frequently and may not necessarily need the same relational model that transactional information does.

### Identifiers
Every single business organization has to have unique identifier numbers. The identifier should be able to remain constant regardless of changing parameters like name, email, and car license plate.
The connection between two transactional entities has to be captured using unique identifiers.

## 1.8 Typical Database Operations
| Operation | Type | Frequency | Criticality |
|---|---|---:|---|
| Authenticate user | Read | High | High |
| Retrieve passenger profile | Read | Medium | Medium |
| Retrieve driver profile | Read | Medium | Medium |
| Update driver availability | Write | High | High |
| Update driver location | Write | Very High | High |
| Find available drivers | Read | Very High | High |
| Create trip request | Write | High | Critical |
| Assign driver to trip | Read/Write | High | Critical |
| Update trip status | Write | High | Critical |
| Retrieve active trip | Read | Very High | Critical |
| Complete trip | Transaction | High | Critical |
| Register payment | Transaction | Medium/High | Critical |
| Retrieve trip history | Read | Medium | Medium |
| Create rating | Write | Medium | Low/Medium |
| Generate notification | Write | High | Medium |
| Retrieve notifications | Read | High | Medium |
| Store trip event | Write | Very High | Medium |
| Administrative reporting | Read/Aggregation | Low | Low/Medium |

The expected operations are shown to have two very distinct load profiles.
Transaction operations have fewer writes than location or event information but need strong consistency assurances. Creating a trip, associating a driver with it, concluding a trip and recording payment for the same are some examples of operations which would cause changes in the business state of the platform through partial or inconsistent update of information.
Operations will consist of many more writes. In particular, active drivers can send location information again and again whereas active trips can send operational events continuously.
Read load is also expected to be important. Active trips and available drivers need to be fetched frequently. Current trip information and historical information needs to be made available frequently to users.

## 1.9 Expected Workloads

### Normal Operation
For the platform to work under standard circumstances, it should consist of many more registered users than simultaneous users.
The database is made up of profile reading, trip request, active trip update, location update and notification queries.

### High Demand
In times when there is high demand for transportation, the number of passengers making requests and drivers posting their location may significantly grow.
This produces simultaneous growth in:
- trip creation operations;
- searches for available drivers;
- driver assignment operations;
- location writes;
- active trip reads;
- trip event writes;
- notifications.
The database design should be prepared to account for the non-constant load and allow scaling of the parts of the system affected by it.

## 1.10 Initial Data Classification - SQL vs NoSQL
| Data | Initial classification | Main reason |
|---|---|---|
| Passenger | Relational | Structured/core business data |
| Driver | Relational | Structured/core business data |
| Vehicle | Relational | Integrity and relationships |
| Trip | Relational | Transactional consistency |
| Payment | Relational | Transactional consistency |
| Rating | Relational | Relationship with completed trip |
| Driver location | NoSQL candidate | Frequent updates/geospatial data |
| Trip events | NoSQL candidate | High write volume/flexible event structure |
| Notifications | NoSQL candidate | Flexible operational data |