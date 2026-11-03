// Typical MongoDB operations O8-O13 from §1.5 of the report.
const dbr = db.getSiblingDB("ridelink");

// O8 - ingest one GPS ping (time-series collection)
dbr.driver_locations.insertOne({
  ts: new Date(), meta: { driverId: 2001, tripId: null },
  loc: { type: "Point", coordinates: [-8.611, 41.1496] }, speedKmh: 32, heading: 90
});

// O9 - upsert the live position of a driver
dbr.driver_live_state.updateOne(
  { _id: 2001 },
  { $set: { status: "AVAILABLE", categoryId: 1, loc: { type: "Point", coordinates: [-8.611, 41.1496] }, updatedAt: new Date() } },
  { upsert: true });

// O10 - nearest 5 available drivers of category 1 within 3 km of the pickup point
printjson(dbr.driver_live_state.find({
  status: "AVAILABLE", categoryId: 1,
  loc: { $nearSphere: { $geometry: { type: "Point", coordinates: [-8.611, 41.1496] }, $maxDistance: 3000 } }
}).limit(5).toArray().map(d => d._id));

// O11 - add a review and compute the driver's average (value later cached in PostgreSQL driver.avg_rating)
dbr.reviews.updateOne({ tripId: NumberLong(99999), fromUserId: 1 },
  { $setOnInsert: { toUserId: 2001, stars: NumberInt(5), tags: ["polite"], comment: "Great", createdAt: new Date() } },
  { upsert: true });                                              // idempotent thanks to the unique index
printjson(dbr.reviews.aggregate([
  { $match: { toUserId: 2001 } },
  { $group: { _id: "$toUserId", avg: { $avg: "$stars" }, n: { $sum: 1 } } }]).toArray());

// O12 - chat history of a trip and unread notifications of a user
printjson(dbr.trip_messages.find({ tripId: NumberLong(1) }).sort({ sentAt: 1 }).limit(20).toArray().length);
dbr.notifications.insertOne({ userId: 1, type: "DRIVER_ARRIVED", payload: { tripId: 1 }, read: false, createdAt: new Date() });
printjson(dbr.notifications.find({ userId: 1, read: false }).sort({ createdAt: -1 }).limit(10).toArray().length);

// O13 - route of a trip for support
dbr.trip_routes.updateOne({ tripId: NumberLong(1) },
  { $setOnInsert: { polyline: "encoded-polyline", distanceKm: 4.2, events: [] } }, { upsert: true });
printjson(dbr.trip_routes.findOne({ tripId: NumberLong(1) }, { _id: 0, distanceKm: 1 }));

// Analytical example: pings per driver in the last hour (telemetry volume check)
printjson(dbr.driver_locations.aggregate([
  { $match: { ts: { $gte: new Date(Date.now() - 3600 * 1000) } } },
  { $group: { _id: "$meta.driverId", pings: { $sum: 1 } } },
  { $sort: { pings: -1 } }, { $limit: 3 }]).toArray());
