// RideLink TVDE platform - MongoDB 7 collections (Iteration 1 draft)
// Run: mongosh mongodb://localhost:27017 mongo/01_collections.js
const dbr = db.getSiblingDB("ridelink");

// 1. GPS telemetry - high-volume time series (bucketed by driver, auto-expired)
dbr.createCollection("driver_locations", {
  timeseries: { timeField: "ts", metaField: "meta", granularity: "seconds" },
  expireAfterSeconds: 60 * 60 * 24 * 90            // 90 days retention
});
// document: { ts: ISODate, meta: { driverId: 42, tripId: 9001|null }, loc: {type:"Point", coordinates:[lon,lat]}, speedKmh: 38, heading: 90 }
dbr.driver_locations.createIndex({ loc: "2dsphere" });

// 2. Live position of each driver (one document per driver, upserted) - for "nearest drivers" queries
dbr.createCollection("driver_live_state");
dbr.driver_live_state.createIndex({ loc: "2dsphere" });
dbr.driver_live_state.createIndex({ status: 1, categoryId: 1 });
dbr.driver_live_state.createIndex({ updatedAt: 1 }, { expireAfterSeconds: 300 }); // stale drivers vanish

// 3. Completed-trip route (summary kept per trip, referenced by PostgreSQL trip_id)
dbr.createCollection("trip_routes", {
  validator: { $jsonSchema: {
    bsonType: "object",
    required: ["tripId", "polyline", "distanceKm"],
    properties: {
      tripId:     { bsonType: "long" },
      polyline:   { bsonType: "string" },
      distanceKm: { bsonType: "double", minimum: 0 },
      events:     { bsonType: "array" }               // hard-brake, detour, SOS...
    } } }
});
dbr.trip_routes.createIndex({ tripId: 1 }, { unique: true });

// 4. Ratings and reviews (flexible, free text, tags)
dbr.createCollection("reviews", {
  validator: { $jsonSchema: {
    bsonType: "object",
    required: ["tripId", "fromUserId", "toUserId", "stars", "createdAt"],
    properties: {
      stars: { bsonType: "int", minimum: 1, maximum: 5 },
      tags:  { bsonType: "array", items: { bsonType: "string" } },
      comment: { bsonType: "string", maxLength: 1000 }
    } } }
});
dbr.reviews.createIndex({ toUserId: 1, createdAt: -1 });
dbr.reviews.createIndex({ tripId: 1, fromUserId: 1 }, { unique: true });

// 5. In-app chat between rider and driver during a trip
dbr.createCollection("trip_messages");
dbr.trip_messages.createIndex({ tripId: 1, sentAt: 1 });
dbr.trip_messages.createIndex({ sentAt: 1 }, { expireAfterSeconds: 60 * 60 * 24 * 30 });

// 6. Notifications / push events
dbr.createCollection("notifications");
dbr.notifications.createIndex({ userId: 1, createdAt: -1 });

// 7. Support tickets / incidents (variable structure, attachments)
dbr.createCollection("support_tickets");
dbr.support_tickets.createIndex({ userId: 1, status: 1 });

// 8. Application audit log
dbr.createCollection("audit_log", { capped: false });
dbr.audit_log.createIndex({ ts: -1 });
dbr.audit_log.createIndex({ actorId: 1, ts: -1 });

// Example operational queries
// nearest 5 available Standard drivers within 3 km:
// dbr.driver_live_state.find({ status: "AVAILABLE", categoryId: 1,
//   loc: { $nearSphere: { $geometry: { type: "Point", coordinates: [-8.611, 41.1496] }, $maxDistance: 3000 } } }).limit(5)
// driver's average rating:
// dbr.reviews.aggregate([{ $match: { toUserId: 42 } }, { $group: { _id: null, avg: { $avg: "$stars" }, n: { $sum: 1 } } }])
